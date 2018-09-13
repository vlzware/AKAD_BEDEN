/* MK1 Aufgabe 2:
 * 	In einem Array vom Typ string sind vier Worte ( unsortiert ) abgelegt.
 *	Schreiben Sie eine Befehlsfolge, die diese vier Worte in lexikogra-
 *	phisch absteigender Reihenfolge ausgibt.
 *
 *	Siehe https://de.wikipedia.org/wiki/Insertionsort
 */

#include <iostream>
using namespace std;

int main() {
	const int len = 4;
	string worte[len] = { "Susanne", "Alex", "Karl", "Barbara" };

	int i = 1;
	int j;
	string buf;
	while (i < len) {
		j = i;
		while ((j > 0) && (worte[j-1] < worte[j])) {
			buf = worte[j];
			worte[j] = worte[j-1];
			worte[j-1] = buf;
			j--;
		}
		i++;
	}

	for (int i = 0; i < len; i++)
		cout << worte[i] << endl;

	return 0;
}
