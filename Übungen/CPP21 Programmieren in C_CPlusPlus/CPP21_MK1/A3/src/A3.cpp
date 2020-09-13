/* MK1 Aufgabe 3:
 * a) Legen Sie ein Array auf dem Heap an, das 5 Katzenobjekte aufnehmen
 *	kann. Es genügt, wenn Sie im Array zwei Katzenobjekte zur Verfügung
 *	stellen. Die Klasse Katze brauchen Sie nicht zu codieren. Sie hat als
 *	Attribute einen Namen und ein Alter der Katze, als Methoden einen allge-
 *	Meinen Konstruktor mit individuellen Werten und get/ set- Methoden.
 *
 * b ) Codieren Sie eine main- Funktion, die es, für den Fall, daß fünf Katzen-
 *	objekte im Array ( das Sie unter a) angeleg haben ) sind, ermöglicht,
 *	die Namen und das Alter der Katzen am Bildschirm anzuzeigen. Sprechen
 *	Sie die Array- Elemente einmal mit Indices an und einmal mit Adressen.
 */

#include <iostream>	// für cout, string
#include <iomanip>	// für setw()
#include "Katze.h"
using namespace std;

void init(Katze *kp) {
	kp->setName("Max");
	kp->setAlter(1.2);
	kp++;
	kp->setName("Mieze");
	kp->setAlter(0.5);
	kp++;
	kp->setName("Felix");
	kp->setAlter(2);
	kp++;
	kp->setName("Simba");
	kp->setAlter(3);
	kp++;
	kp->setName("Amy");
	kp->setAlter(1.8);
}

int main() {
	const int count = 5;
	Katze *katzen = new Katze[5];
	init(katzen);

	// a)
	cout << "Nach Index:" << endl;
	for (int i = 0; i < count; i++) {
		cout << katzen[i];
	}
	cout << endl;
	// b)
	cout << "Nach Adressen:" << endl;
	Katze *kp = katzen;
	for (int i = 0; i < count; i++, kp++) {
		cout << *kp;
	}

	delete[] katzen;
	return 0;
}
