/* MK1	 Aufgabe 7:
 * In der folgenden Übersicht wird gezeigt, welche Bedingungen bei einer
 * Blutübertragung beachtet werden müssen.
 * ...
 * Ergänzen Sie die unten abgebildete Klasse Person um die Methode
 * bool passtZu ( char spenderBlutgruppe ).
 * Verwenden Sie für Ihre Entscheidungen in der Methode nur einen “if“.
 */

#include <iostream>
using namespace std;

class Person
{
private:
	string m_name;
	char m_blutgruppe;
public:
	Person ( string name, char blutgruppe ) :
		m_name ( name ),
		m_blutgruppe ( blutgruppe ) { }
	bool passtZu ( char spenderBlutgruppe )
	{
		if (
				spenderBlutgruppe == this->m_blutgruppe ||
				spenderBlutgruppe == '0' ||
				this->m_blutgruppe == '0'
			) {
			return true;
		}
		return false;
	}
	char getBlutgruppe() const {
		return m_blutgruppe;
	}
	const string& getName() const {
		return m_name;
	}
};

int main() {
	Person person1("Hans", 'A');
	Person person2("Claudia", 'B');

	cout << person1.getName()
			<< " (Blugruppe " << person1.getBlutgruppe() << ")"
			<< (person1.passtZu(person2.getBlutgruppe())? " darf " : " darf nicht ")
			<< "von " << person2.getName()
			<< " (Blutgruppe " << person2.getBlutgruppe()
			<< ") Blut bekommen." << endl;

	return 0;
}
