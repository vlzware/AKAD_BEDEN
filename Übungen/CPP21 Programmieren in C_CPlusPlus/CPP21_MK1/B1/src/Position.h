/*
 * Position.h
 */

#ifndef POSITION_H_
#define POSITION_H_

#include <iomanip>
#include "Artikel.h"
#define WIDTH 10

class Position {
private:
	int posNr;
	int menge;
	Artikel artikel;
public:
	Position(int posNr, int menge, Artikel& artikel) :
		posNr(posNr), menge(menge), artikel(artikel) {}
	~Position() {}

	double getPositionsSumme() const {
		return menge * artikel.getPreis();
	}

	int getMenge() const {
		return menge;
	}

	void setMenge(int menge) {
		this->menge = menge;
	}

	int getPosNr() const {
		return posNr;
	}

	void setPosNr(int posNr) {
		this->posNr = posNr;
	}

	const Artikel& getArtikel() const {
		return artikel;
	}

	void setArtikel(const Artikel& artikel) {
		this->artikel = artikel;
	}

	friend ostream& operator<<(ostream& out, Position& position) {
		out << fixed;
		out.precision(2);
		Artikel art = position.artikel;
		out << setw(WIDTH) << position.posNr;
		out << setw(WIDTH) << position.menge;
		out << setw(WIDTH) << art.getNummer();
		out	<< setw(WIDTH) << art.getBezeichnung();
		out << setw(WIDTH) << art.getPreis();
		out << setw(WIDTH) << position.getPositionsSumme();

		return out;
	}
};

#endif /* POSITION_H_ */
