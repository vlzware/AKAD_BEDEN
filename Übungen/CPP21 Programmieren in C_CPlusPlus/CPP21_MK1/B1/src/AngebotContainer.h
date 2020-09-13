/*
 * AngebotContainer.h
 */

#ifndef ANGEBOTCONTAINER_H_
#define ANGEBOTCONTAINER_H_

#include <vector>
#include <iomanip>
#define WIDTH 10
#include "Angebot.h"

class AngebotContainer {
private:
	vector<Angebot*> angebote;
public:
	AngebotContainer(vector<Angebot*>& angebote) :
		angebote(angebote) {}
	~AngebotContainer() {}

	vector<Angebot*> getAlleAngebote () const {
		return angebote;
	}

	void angebotHinzu(Angebot* angebot) {
		angebote.push_back(angebot);
	}

	Angebot* getAngebot(const string& angebotsNr) const;

	friend ostream& operator<<(ostream& out, AngebotContainer& container) {
		out << fixed;
		out.precision(2);
		out << "Angebote:" << endl;
		for (size_t i = 0; i < container.angebote.size(); i++) {
			cout << setw(WIDTH) << container.angebote[i]->getNummer();
			cout << setw(WIDTH) << container.angebote[i]->getDate();
			cout << setw(WIDTH) << container.angebote[i]->getAngebotsSumme() << " €";
			cout << endl;
		}
		return out;
	}
};

Angebot* AngebotContainer::getAngebot(const string& angebotsNr) const {
	for (size_t i = 0; i < this->angebote.size(); i++) {
		if (this->angebote[i]->getNummer() == angebotsNr)
			return this->angebote[i];
	}
	return 0;
}

#endif /* ANGEBOTCONTAINER_H_ */
