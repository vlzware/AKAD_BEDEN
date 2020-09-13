// Werte müssen auf die Zahl der LED's eingestellt werden!
#define LEDCOUNT    9
#define ALLOFF      0B0000000000000000
#define ALLON       0B0000000111111111
#define HALFON      0B0000000010101010

#define MINDELAY    5
#define MAXDELAY    5000

// Positionen im EEPROM zum Speichern von den Status-Variablen
#define EE_PATTERN  0
#define EE_SHTYPE   2
#define EE_SHIFT    3
#define EE_DELAY    4

/**
    Datenaustauschvorgaben:
    (siehe auch setState)
*/
#define COMMSTART   0x7E
#define COMMEND     0x7F
#define COMMLENGTH  9
#define COMMOKAY    0x59    // "Y"
#define COMMFAIL    0x21    // "!"
#define CMDSET      0x00
#define CMDMINUS    0x01
#define CMDPLUS     0x02
#define CMDSHBLINK  0x00
#define CMDSHLEFT   0x01
#define CMDSHRIGHT  0x02

byte comm[COMMLENGTH] = {0};
byte commPos = 0;

#include <EEPROM.h>
#include <SoftwareSerial.h>
// HC-06 TX zu 2; HC-06 RX zu 3 (über Spannungsteiler)
SoftwareSerial BTserial(2, 3);

// Schieberegister-Pins. Verbindungen Arduino zu Schieberegister
const int shiftClock = 13;      // Clock: (PB5/SCK) zu SRCLK => a13 zu s11
const int storageClock = 10;    // Latch:  (PB2/SS) zu RCLK => a10 zu s12
const int serialData = 11;      // Data:   (PB3/MOSI) zu SER => a11 zu s14

/**
    Globale struct für den aktuellen Status.
*/
struct stateStruct {
    unsigned int    sPattern;
    byte            sShiftType;
    byte            sShift;
    unsigned int    sDelay;
} state;

/**
    Wert vom EEPROM ablesen.

    @param pos Position im EEPROM
*/
unsigned int readInt(byte pos) {
    return (unsigned int) EEPROM.read(pos);
}

/**
    Wert in EEPROM speichern.

    @param pos Position im EEPROM
    @param value Wert zum Speichern
*/
void writeByte(byte pos, byte value) {
    if (EEPROM.read(pos) != value) {
        EEPROM.write(pos, value);
        Serial.print("wrote ");
        Serial.print(value);
        Serial.print(" at pos: ");
        Serial.println(pos);
    }
}

/**
    Letzter Status vom EEPROM ablesen. Big-endian Reihenfolge
*/
void initState() {
    state.sPattern = (readInt(EE_PATTERN) << 8) | readInt(EE_PATTERN + 1);
    state.sShiftType = readInt(EE_SHTYPE);
    state.sShift = readInt(EE_SHIFT);
    state.sDelay = (readInt(EE_DELAY) << 8) | readInt(EE_DELAY + 1);

    Serial.print("Read from EEPROM:  ");
    for (int i = 0; i < 6; i++) {
        Serial.print(EEPROM.read(i));
        Serial.print(" ");
    }
    Serial.println();
}

/**
    Status in EEPROM speichern.
*/
void saveState() {
    writeByte(EE_PATTERN, state.sPattern >> 8);
    writeByte(EE_PATTERN + 1, state.sPattern & 0xFF);
    writeByte(EE_SHTYPE, state.sShiftType);
    writeByte(EE_SHIFT, state.sShift);
    writeByte(EE_DELAY, state.sDelay >> 8);
    writeByte(EE_DELAY + 1, state.sDelay & 0xFF);
}

/**
    Bitmusterbearbeitung: circular shift / Bitflip

    @param n        Zahl die geschoben/geflipt wird
    @param shift    Schiebeweite. 0 entspricht Bitflip
    @param toLeft   Richtung
*/
int workOnPattern(int n, byte shiftType, byte shift) {
    if (n == 0) {
        return n;
    }
    if (shift == LEDCOUNT) {
        return n;
    }
    if (shiftType == CMDSHBLINK) {
        return ~n;
    }
    if (shift > LEDCOUNT) {
        shift %= LEDCOUNT;
    }
    if (shiftType == CMDSHLEFT) {
        return
            ((n & ~(ALLON >> shift)) >> (LEDCOUNT - shift)) |
            ((n << shift) & ALLON);
    } else if (shiftType == CMDSHRIGHT) {
        return
            ((n & (ALLON >> (LEDCOUNT - shift))) << (LEDCOUNT - shift)) |
            (n >> shift);
    }
    return 0;   // Fehlparameter
}

/**
    Funktion zum Übertragen der Informationen. MSB zuerst.

    @param value LEDCOUNT-Bit Wert zum Übertragen
*/
void showOutput(int value) {
    digitalWrite(storageClock, LOW);
    for (int i = 0; i < LEDCOUNT; i++) {
        digitalWrite(serialData, (value >> (LEDCOUNT - 1 - i)) & 1);
        digitalWrite(shiftClock, HIGH);
        digitalWrite(shiftClock, LOW);
    }
    digitalWrite(storageClock, HIGH);
}

/**
    Prüft ob etwas im Serial vorliegt.
*/
bool checkForInput() {
    return BTserial.available() > 0;
}

/**
    Wartefunktion mit Unterbrechungsmöglichkeit.

    @param interval Wartezeit
*/
void waitAwake(unsigned long interval) {
    unsigned long currentMillis = millis();
    unsigned long previousMillis = currentMillis;;
    do {
        if (currentMillis - previousMillis >= interval) {
            return;
        }
        if (checkForInput()) {
            return;
        }
        currentMillis = millis();
    } while (1);
}

/**
    Warteinterval ändern.

    @param lbyte Linkes Byte
    @param rbyte Rechtes Byte
    @int modifier Multiplikator
*/
void updateDelay(byte lbyte, byte rbyte, int modifier) {
    int change = (((unsigned int) lbyte) << 8) | ((unsigned int) rbyte);
    int newValue = state.sDelay + change * modifier;
    if ((newValue <= MAXDELAY) && (newValue >= MINDELAY)) {
        state.sDelay = newValue;
    }
}

/**
    Status nach Benutzereingabe aktualisieren.
*/
void setState() {
    if (comm[1] == CMDSET) {
        state.sPattern =
            (((unsigned int) comm[2]) << 8) |
            ((unsigned int) comm[3]);

        state.sShiftType = comm[4];
        state.sShift = comm[5];

        state.sDelay =
            (((unsigned int) comm[6]) << 8) |
            ((unsigned int) comm[7]);

        return;
    }

    if (comm[1] == CMDMINUS) {
        updateDelay(comm[6], comm[7], -1);
        return;
    }

    if (comm[1] == CMDPLUS) {
        updateDelay(comm[6], comm[7], 1);
        return;
    }
}

/**
    Eingabe dekodieren.

    @param input Eigabe
*/
void parseInput(byte input) {
    if (commPos == 0 && input != COMMSTART) {
        return;
    }
    comm[commPos++] = input;
    if (commPos == COMMLENGTH) {
        if (comm[COMMLENGTH - 1] != COMMEND) {
            commPos = 0;
            return;
        }
        BTserial.write(COMMOKAY);
        commPos = 0;
        Serial.println("Okay!");
        setState();
        saveState();
    }
}

/**
    Muster abspielen und weiter bearbeiten
*/
void ll_play() {
    showOutput(state.sPattern);
    state.sPattern = workOnPattern(state.sPattern, state.sShiftType, state.sShift);
    waitAwake(state.sDelay);
}

void setup() {
    pinMode(shiftClock, OUTPUT);
    pinMode(storageClock, OUTPUT);
    pinMode(serialData, OUTPUT);
    Serial.begin(115200);
    BTserial.begin(38400);
//    BTserial.begin(115200);
    showOutput(ALLOFF);
    initState();
}

void loop() {
    ll_play();

    if (BTserial.available() > 0) {
        byte input = BTserial.read();
        Serial.print(commPos);
        Serial.print(" ");
        Serial.println(input);
        parseInput(input);
    }
}
