/* MK1 Aufgabe B2 (Komplexaufgabe 3):
 *
 * Exception, enum, 1 : n- Assoziation, Array, kleine
 * Logik in Methoden
 * ...
 */

#include <iostream>
#include <exception>
#include <vector>
using namespace std;

enum Fruchtart { Apfel, Birne, Paprika, Keine };

class keineFruechteMehr : public exception {
public:
	const char* what() const throw() {
		return "Keine Früchte mehr!";
	}
};

class Frucht {
private:
	Fruchtart art;
	string herkunft;
	string farbe;
public:
	Frucht() : art(Keine), herkunft(""), farbe("") {}
	Frucht(Fruchtart art, string herkunft, string farbe) :
		art(art), herkunft(herkunft), farbe(farbe) {}
	friend ostream& operator<<(ostream& out, Frucht frucht) {

		switch(frucht.art) {
		case Apfel:
			out << "Apfel";
			break;
		case Birne:
			out << "Birne";
			break;
		case Paprika:
			out << "Paprika";
			break;
		default:
			out << "Keine Früchte";
		}
		out << " " << frucht.herkunft << " " << frucht.farbe;
		return out;
	}
};

class Obstkorb {
private:
	Frucht korb[9];
	int zaehlerFuerFruechte;
	int indexFuerArray;	// unnötig?
public:
	Obstkorb() {
		indexFuerArray = 0;
		for (int i = Apfel; i <= Paprika; i++) {
			korb[indexFuerArray++] =
					Frucht(static_cast<Fruchtart>(i), "Deutschland", "rot");
			korb[indexFuerArray++] =
					Frucht(static_cast<Fruchtart>(i), "Australien", "gruen");
			korb[indexFuerArray++] =
					Frucht(static_cast<Fruchtart>(i), "Holland", "gelb");
		}
		zaehlerFuerFruechte = 9;
	}
	void ausgeben() const {
		for (int i = 0; i < zaehlerFuerFruechte; i++) {
			cout << korb[i] << endl;
		}
	}
	Frucht fruchtEntnehmen() {
		if (zaehlerFuerFruechte == 0)
			throw keineFruechteMehr();
		return korb[--zaehlerFuerFruechte];
	}
	int getAnzahlVorhandenerFruechte() const {
		return zaehlerFuerFruechte;
	}
};

int main() {
	Obstkorb korb;
	korb.ausgeben();

	const int satt = 13; //
	int gegessen = 0;

	string answer = "j";
	cout << "\nGutten Appetit!\n";
	Frucht frucht;
	do {
		bool ok = true;
		try {
			frucht = korb.fruchtEntnehmen();
			cout << frucht << endl;
		} catch (keineFruechteMehr& msg) {
			cout << msg.what() << endl;
			ok = false;
		}
		if (ok && ((++gegessen) == satt)) {
			cout << "Satt!" << endl;
			break;
		}
		cout << "Weiter? ";
		getline(cin, answer);
	} while (answer == "j");

	return 0;
}
