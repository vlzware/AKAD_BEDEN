/*
 * Angebot.h
 */

#ifndef ANGEBOT_H_
#define ANGEBOT_H_

#include "Position.h"
#include "Datum.h"
#include "Bearbeiter.h"

#include <iostream>
#include <iomanip>
#include <vector>
#define WIDTH 10
#define WIDTH_BIG 20

using namespace std;

class Angebot {
private:
	string nummer;
	bool zustand;
	Datum date;
	Bearbeiter bearbeiter;
	vector<Position*> positionen;
public:
	Angebot(const string& nummer,
			bool zustand,
			Datum& date,
			Bearbeiter& bearbeiter,
			vector<Position*>& positionen) :
				nummer(nummer), zustand(zustand), date(date),
				bearbeiter(bearbeiter), positionen(positionen) {}
	~Angebot() {}

	bool hatNummer(string nummer) const {
		return nummer == this->nummer;
	}

	double getAngebotsSumme() const {
		double summe = 0;

		for (size_t i = 0; i < positionen.size(); i++) {
			summe += positionen.at(i)->getPositionsSumme();
		}
		return summe;
	}

	void positionHinzu(Position *position) {
		positionen.push_back(position);
	}

	string getNameBearbeiter() const {
		return bearbeiter.getName();
	}

	friend ostream& operator<<(ostream& out, Angebot& angebot) {
		out << fixed;
		out.precision(2);
		out << "***" << endl;
		out << "Agebotsnummer: " << angebot.nummer << endl;
		out << angebot.date << endl;
		out << angebot.bearbeiter << endl;
		out << endl;
		out << setw(WIDTH) << "PosNr";
		out << setw(WIDTH) << "Menge";
		out << setw(WIDTH) << "ArtikelNr";
		out << setw(WIDTH_BIG) << "Bezeichnung";
		out	<< setw(WIDTH) << "Preis";
		out << setw(WIDTH) << "Summe" << "\n\n";

		vector<Position*> ap = angebot.positionen;
		for (size_t i = 0; i < ap.size(); i++) {
			out << setw(WIDTH) << ap.at(i)->getPosNr();
			out << setw(WIDTH) << ap.at(i)->getMenge();
			out << setw(WIDTH) << ap.at(i)->getArtikel().getNummer();
			out << setw(WIDTH_BIG) << ap.at(i)->getArtikel().getBezeichnung();
			out << setw(WIDTH) << ap.at(i)->getArtikel().getPreis() << " €";
			out << setw(WIDTH) << ap.at(i)->getPositionsSumme() << " €";
			out << endl;
		}
		out << endl;
		out << "Angebotssumme: " << angebot.getAngebotsSumme() << " €" << endl;
		out << "***" << endl;

		return out;
	}

	const string& getNummer() const {
		return nummer;
	}

	void setNummer(const string& nummer) {
		this->nummer = nummer;
	}

	bool isZustand() const {
		return zustand;
	}

	void setZustand(bool zustand) {
		this->zustand = zustand;
	}

	const Bearbeiter& getBearbeiter() const {
		return bearbeiter;
	}

	void setBearbeiter(const Bearbeiter& bearbeiter) {
		this->bearbeiter = bearbeiter;
	}

	const Datum& getDate() const {
		return date;
	}

	void setDate(const Datum& date) {
		this->date = date;
	}

	const vector<Position*>& getPositionen() const {
		return positionen;
	}

	void setPositionen(const vector<Position*>& positionen) {
		this->positionen = positionen;
	}
};

#endif /* ANGEBOT_H_ */
