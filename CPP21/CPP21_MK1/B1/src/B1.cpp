/* MK1 Aufgabe B1 (Komplexaufgabe 2):
 *
 * Assoziation, Überladen eines Operators
 * Problem: Erstellen eines Angebotes
 * ...
 */
#include <iostream>
#include "Angebot.h"
#include "AngebotContainer.h"
#include "Artikel.h"
#include "Bearbeiter.h"
#include "Datum.h"
#include "Position.h"

using namespace std;

int main() {
	vector<Angebot*> angebote;
	AngebotContainer m_container(angebote);

	Artikel a_gpu(1001, "Palit GTX 1070", 430.00);
	Artikel a_ram(1002, "Crucial 4Gb", 58.00);
	Artikel a_drive(1003, "WD Green 1Tb", 130.00);
	Artikel a_ssd(1004, "Vertex 240Gb", 120.00);

//	cout << a_gpu << endl;

	Datum d_one(12, 4, 2018);
	Datum d_two(25, 7, 2018);

//	cout << d_one << endl;

	Bearbeiter b_max("Max Schmidt");
	Bearbeiter b_karla("Karla Krause");

//	cout << b_max << endl;

	// angebot 1
	vector<Position*> v_pos_a;
	Position* pos_aa = new Position(1, 2, a_ram);
	v_pos_a.push_back(pos_aa);
	Angebot* angebot_a = new Angebot("P13001", false, d_one, b_max, v_pos_a);
	m_container.angebotHinzu(angebot_a);

//	cout << *angebot_a << endl;

	// angebot 2
	vector<Position*> v_pos_b;
	Position* pos_ba = new Position(1, 2, a_gpu);
	Position* pos_bb = new Position(2, 2, a_ram);
	Position* pos_bc = new Position(3, 1, a_drive);
	Position* pos_bd = new Position(4, 1, a_ssd);
	v_pos_b.push_back(pos_ba);
	v_pos_b.push_back(pos_bb);
	v_pos_b.push_back(pos_bc);
	v_pos_b.push_back(pos_bd);
	Angebot* angebot_b = new Angebot("G10003", false, d_two, b_karla, v_pos_b);
	m_container.angebotHinzu(angebot_b);

//	cout << m_container << endl;

	string m_num = "G10003";
	Angebot* an = m_container.getAngebot(m_num);
	if (an == 0)
		cout << "Kein Angebot mit der Nummer " << m_num << "!" << endl;
	else
		cout << *an << endl;

	delete pos_aa;
	delete angebot_a;
	delete pos_ba;
	delete pos_bb;
	delete pos_bc;
	delete pos_bd;
	delete angebot_b;

	return 0;
}
