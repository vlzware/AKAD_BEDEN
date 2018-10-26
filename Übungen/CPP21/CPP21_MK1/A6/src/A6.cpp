/* MK1 Aufgabe 6:
 * Codieren Sie bitte gemäß dem folgenden UML- Klassendiagramm allge-
 * meine Konstruktoren mit individuellen Werten der Klassen
 * - Konto
 * - Sparkonto
 * - Festgeldkonto
 */

#include <iostream>
#include <iomanip>
#define WIDTH_K 25
#define WIDTH_S 7
using namespace std;

class Zinssatz {
private:
	float zinssatz;
public:
	Zinssatz(float zinssatz) : zinssatz(zinssatz) {}
	// In der UML sind die get/set Methode als private (mit "-") angezeigt,
	// vermutlich Tippfehler?
	float getZinssatz() const {
		return zinssatz;
	}
	void setZinssatz(float zinssatz) {
		this->zinssatz = zinssatz;
	}
};

class Konto {
private:
	int kontoNr;
	float kontostand;
	Zinssatz zinssatz;
public:
	Konto(int kontoNr, float kontostand, Zinssatz zinssatz) :
		kontoNr(kontoNr), kontostand(kontostand), zinssatz(zinssatz) {}

	int getKontoNr() const {
		return kontoNr;
	}
	void setKontoNr(int kontoNr) {
		this->kontoNr = kontoNr;
	}
	float getKontostand() const {
		return kontostand;
	}
	void setKontostand(float kontostand) {
		this->kontostand = kontostand;
	}
	Zinssatz getZinssatz() const {
		return zinssatz;
	}
	void setZinssatz(Zinssatz zinssatz) {
		this->zinssatz = zinssatz;
	}

	friend ostream& operator<< (ostream& out, const Konto& konto) {
		out << setw(WIDTH_K) << "Konto: " << konto.kontoNr;
		out << ", Stand: " << setw(WIDTH_S) << konto.kontostand;
		out << ", Zinssatz: " << konto.zinssatz.getZinssatz();
		out << "%" << endl;
		return out;
	}
};

class Sparkonto : public Konto {
public:
	Sparkonto(int kontoNr, float kontostand, Zinssatz zinssatz) :
		Konto(kontoNr, kontostand, zinssatz) {}

	friend ostream& operator<< (ostream& out, const Sparkonto& konto) {
		out << setw(WIDTH_K) << "Konto (Sparkonto): " << konto.getKontoNr();
		out << ", Stand: " << setw(WIDTH_S) << konto.getKontostand();
		out << ", Zinssatz: " << konto.getZinssatz().getZinssatz();
		out << "%" << endl;
		return out;
	}
};

class Festgeldkonto : public Konto {
private:
	int laufzeit;
public:
	Festgeldkonto(int kontoNr, float kontostand, Zinssatz zinssatz,
					int laufzeit) :
		Konto(kontoNr, kontostand, zinssatz), laufzeit(laufzeit) {}

	friend ostream& operator<< (ostream& out, const Festgeldkonto& konto) {
		out << setw(WIDTH_K) << "Konto (Festgeldkonto): " << konto.getKontoNr();
		out << ", Stand: " << setw(WIDTH_S) << konto.getKontostand();
		out << ", Zinssatz: " << konto.getZinssatz().getZinssatz();
		out << "%, Laufzeit: " << konto.laufzeit << " Jahre"<< endl;
		return out;
	}
};

int main() {

	Konto meinKonto(12345, 1000.0, Zinssatz(2.5));
	Sparkonto meinSparKonto(23456, 12000.0, Zinssatz(4.0));
	Festgeldkonto meinFestGeldKonto(34567, 5200.0, Zinssatz(5.1), 3);

	cout << meinKonto;
	cout << meinSparKonto;
	cout << meinFestGeldKonto;

	return 0;
}
