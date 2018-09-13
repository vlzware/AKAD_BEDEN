/*
 * Artikel.h
 */

#ifndef ARTIKEL_H_
#define ARTIKEL_H_

#include <iostream>
#include <iomanip>
#define WIDTH_BEZ 10
#define WIDTH_PREIS 8
using namespace std;

class Artikel {
private:
	int nummer;
	string bezeichnung;
	double preis;
public:
	Artikel(int nummer, const string& bezeichnung, double preis) :
		nummer(nummer), bezeichnung(bezeichnung), preis(preis) {}
	~Artikel() {}

	const string& getBezeichnung() const {
		return bezeichnung;
	}

	void setBezeichnung(const string& bezeichnung) {
		this->bezeichnung = bezeichnung;
	}

	int getNummer() const {
		return nummer;
	}

	void setNummer(int nummer) {
		this->nummer = nummer;
	}

	double getPreis() const {
		return preis;
	}

	void setPreis(double preis) {
		this->preis = preis;
	}

	friend ostream& operator<<(ostream& out, Artikel& artikel) {
		out << fixed;
		out.precision(2);
		out << artikel.nummer << ": " << setw(WIDTH_BEZ) << artikel.bezeichnung
				<< setw(WIDTH_PREIS) << artikel.preis << "€";
		return out;
	}
};

#endif /* ARTIKEL_H_ */
