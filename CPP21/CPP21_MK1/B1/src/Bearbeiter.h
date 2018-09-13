/*
 * Bearbeiter.h
 */

#ifndef BEARBEITER_H_
#define BEARBEITER_H_

#include <iostream>
using namespace std;

class Bearbeiter {
private:
	string name;
public:
	Bearbeiter(const string& name) : name(name) {}
	~Bearbeiter() {}

	const string& getName() const {
		return name;
	}

	void setName(const string& name) {
		this->name = name;
	}

	friend ostream& operator<<(ostream& out, Bearbeiter& bearbeiter) {
		out << "Bearbeiter: " << bearbeiter.name;
		return out;
	}
};

#endif /* BEARBEITER_H_ */
