/*
 * Datum.h
 */

#ifndef DATUM_H_
#define DATUM_H_

class Datum {
private:
	int tag;
	int monat;
	int jahr;
public:
	Datum(int tag, int monat, int jahr) :
		tag(tag), monat(monat), jahr(jahr) {}
	~Datum() {}

	int getJahr() const {
		return jahr;
	}

	void setJahr(int jahr) {
		this->jahr = jahr;
	}

	int getMonat() const {
		return monat;
	}

	void setMonat(int monat) {
		this->monat = monat;
	}

	int getTag() const {
		return tag;
	}

	void setTag(int tag) {
		this->tag = tag;
	}

	friend ostream& operator<<(ostream& out, const Datum& datum) {
		out << "Datum: " << datum.tag << "." << datum.monat
				<< "." << datum.jahr;
		return out;
	}
};

#endif /* DATUM_H_ */
