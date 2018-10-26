/*
 * Katze.h
 */

#ifndef KATZE_H_
#define KATZE_H_

#include <string>
using namespace std;

class Katze {
private:
	string name;
	float alter;
public:
	Katze() : name(""), alter(0) {}
	~Katze() {}

	float getAlter() const {
		return alter;
	}

	void setAlter(float alter) {
		this->alter = alter;
	}

	const string& getName() const {
		return name;
	}

	void setName(const string& name) {
		this->name = name;
	}
	friend ostream& operator<<(ostream& out, Katze katze) {
		out << setw(7) << katze.getName();
		out << " - " << setw(4) << katze.getAlter();
		out << " Jahre alt" << endl;
		return out;
	}
};

#endif /* KATZE_H_ */
