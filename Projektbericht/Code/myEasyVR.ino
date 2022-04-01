#include "Arduino.h"
#if !defined(SERIAL_PORT_MONITOR)
#error "Arduino version not supported. Please update your IDE to the latest version."
#endif

#if defined(__SAMD21G18A__)
// Shield Jumper on HW (for Zero, use Programming Port)
#define port SERIAL_PORT_HARDWARE
#define pcSerial SERIAL_PORT_MONITOR
#elif defined(SERIAL_PORT_USBVIRTUAL)
// Shield Jumper on HW (for Leonardo and Due, use Native Port)
#define port SERIAL_PORT_HARDWARE
#define pcSerial SERIAL_PORT_USBVIRTUAL
#else
// Shield Jumper on SW (using pins 12/13 or 8/9 as RX/TX)
#include "SoftwareSerial.h"
SoftwareSerial port(12, 13);
#define pcSerial SERIAL_PORT_MONITOR
#endif

#include "EasyVR.h"
#include <Wire.h>
#include <util/atomic.h>
#define I2C_DEV 0x08

EasyVR easyvr(port);

//Groups and Commands
enum Groups
{
    GROUP_0 = 0,
    GROUP_1 = 1,
};

enum Group0
{
    G0_COMPUTER = 0,
};

enum Group1
{
    G1_ALEXA = 0,
    G1_LICHT_AN = 1,
    G1_LICHT_AUS = 2,
    G1_HELLER = 3,
    G1_DUNKLER = 4,
    G1_EINS_AN = 5,
    G1_EINS_AUS = 6,
    G1_ZWEI_AN = 7,
    G1_ZWEI_AUS = 8,
};

// use negative group for wordsets
int8_t group, idx;

// for communication with Pi
volatile bool m_eventAvailable = false;
volatile int8_t m_lastIdx = -1;

void setup()
{
    // setup PC serial port
    pcSerial.begin(9600);

    // join the I2C bus as slave
    Wire.begin(I2C_DEV);

    // send any new events, if available, on request
    Wire.onRequest(send_i2c);

bridge:
    // bridge mode?
    int mode = easyvr.bridgeRequested(pcSerial);
    switch (mode)
    {
    case EasyVR::BRIDGE_NONE:
        // setup EasyVR serial port
        port.begin(9600);
        // run normally
        pcSerial.println(F("Bridge not requested, run normally"));
        pcSerial.println(F("---"));
        break;

    case EasyVR::BRIDGE_NORMAL:
        // setup EasyVR serial port (low speed)
        port.begin(9600);
        // soft-connect the two serial ports (PC and EasyVR)
        easyvr.bridgeLoop(pcSerial);
        // resume normally if aborted
        pcSerial.println(F("Bridge connection aborted"));
        pcSerial.println(F("---"));
        break;

    case EasyVR::BRIDGE_BOOT:
        // setup EasyVR serial port (high speed)
        port.begin(115200);
        pcSerial.end();
        pcSerial.begin(115200);
        // soft-connect the two serial ports (PC and EasyVR)
        easyvr.bridgeLoop(pcSerial);
        // resume normally if aborted
        pcSerial.println(F("Bridge connection aborted"));
        pcSerial.println(F("---"));
        break;
    }

    // initialize EasyVR
    while (!easyvr.detect())
    {
        pcSerial.println(F("EasyVR not detected!"));
        for (int i = 0; i < 10; ++i)
        {
            if (pcSerial.read() == '?')
                goto bridge;
            delay(100);
        }
    }

    pcSerial.print(F("EasyVR detected, version "));
    pcSerial.print(easyvr.getID());

    if (easyvr.getID() < EasyVR::EASYVR3)
        easyvr.setPinOutput(EasyVR::IO1, LOW); // Shield 2.0 LED off

    if (easyvr.getID() < EasyVR::EASYVR)
        pcSerial.print(F(" = VRbot module"));
    else if (easyvr.getID() < EasyVR::EASYVR2)
        pcSerial.print(F(" = EasyVR module"));
    else if (easyvr.getID() < EasyVR::EASYVR3)
        pcSerial.print(F(" = EasyVR 2 module"));
    else
        pcSerial.print(F(" = EasyVR 3 module"));
    pcSerial.print(F(", FW Rev."));
    pcSerial.println(easyvr.getID() & 7);

    easyvr.setDelay(0); // speed-up replies

    easyvr.setTimeout(5);
    easyvr.setLanguage(0); //<-- same language set on EasyVR Commander when code was generated

    group = EasyVR::TRIGGER; //<-- start group (customize)

    easyvr.setPinOutput(EasyVR::IO1, LOW);
}

void loop()
{
    if (easyvr.getID() < EasyVR::EASYVR3)
        easyvr.setPinOutput(EasyVR::IO1, HIGH); // LED on (listening)

    if (group < 0) // SI wordset/grammar
    {
        pcSerial.print("Say a word in Wordset ");
        pcSerial.println(-group);
        easyvr.recognizeWord(-group);
    }
    else // SD group
    {
        pcSerial.print("Say a command in Group ");
        pcSerial.println(group);
        easyvr.recognizeCommand(group);
    }

    do
    {
        // allows Commander to request bridge on Zero (may interfere with user protocol)
        if (pcSerial.read() == '?')
        {
            setup();
            return;
        }
        // <<-- can do some processing here, while the module is busy
    } while (!easyvr.hasFinished());

    if (easyvr.getID() < EasyVR::EASYVR3)
        easyvr.setPinOutput(EasyVR::IO1, LOW); // LED off

    idx = easyvr.getWord();
    if (idx == 0 && group == EasyVR::TRIGGER)
    {
        return; // this is the "ROBOT" wakeword, which performs bad (to put it mildly...)
    }
    else if (idx >= 0)
    {
        // beep
        easyvr.playSound(0, EasyVR::VOL_FULL);
        // print debug message
        uint8_t flags = 0, num = 0;
        char name[32];
        pcSerial.print("Word: ");
        pcSerial.print(idx);
        if (easyvr.dumpGrammar(-group, flags, num))
        {
            for (uint8_t pos = 0; pos < num; ++pos)
            {
                if (!easyvr.getNextWordLabel(name))
                    break;
                if (pos != idx)
                    continue;
                pcSerial.print(F(" = "));
                pcSerial.println(name);
                break;
            }
        }
        action();
        return;
    }
    idx = easyvr.getCommand();
    if (idx >= 0)
    {
        // beep
        easyvr.playSound(0, EasyVR::VOL_FULL);
        // print debug message
        uint8_t train = 0;
        char name[32];
        pcSerial.print("Command: ");
        pcSerial.print(idx);
        if (easyvr.dumpCommand(group, idx, name, train))
        {
            pcSerial.print(" = ");
            pcSerial.println(name);
        }
        else
            pcSerial.println();
        action();
    }
    else // errors or timeout
    {
        if (easyvr.isTimeout())
            pcSerial.println("Timed out, try again...");
        int16_t err = easyvr.getError();
        if (err >= 0)
        {
            pcSerial.print("Error ");
            pcSerial.println(err, HEX);
        }
        group = EasyVR::TRIGGER;
    }
}

/*
 On request from the master
 check for available events (new command understood by EasyVR)
 and send their ID over the wire
*/
void send_i2c()
{
    if (!m_eventAvailable) {
        return;
    }

    int8_t m_idx;
    //noInterrupts();
    ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
        m_idx = m_lastIdx;
        m_eventAvailable = false;
    }
    //interrupts();

    Wire.write(m_idx);

    // print debug message
    pcSerial.print("sending on i2c: ");
    pcSerial.println(m_idx, HEX);
}

void action()
{
    switch (group)
    {
    case GROUP_0:
        switch (idx)
        {
        case G0_COMPUTER:
            group = GROUP_1;
            break;
        }
        break;
    case GROUP_1:
        switch (idx)
        {
        case G1_ALEXA:
            easyvr.setPinOutput(EasyVR::IO1, HIGH);
            delay(500);
            easyvr.setPinOutput(EasyVR::IO1, LOW);
            break;
        case G1_LICHT_AN:
        case G1_LICHT_AUS:
        case G1_HELLER:
        case G1_DUNKLER:
        case G1_EINS_AN:
        case G1_EINS_AUS:
        case G1_ZWEI_AN:
        case G1_ZWEI_AUS:
            //noInterrupts();
            ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
                m_eventAvailable = true;
                m_lastIdx = idx;
            }
            //interrupts();
            break;
        }
        group = EasyVR::TRIGGER;
        break;
    }
}
