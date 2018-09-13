/* MK1 Aufgabe B3 (Komplexaufgabe 4)
 * ein-und zwei-dimensionale Array‘s,
 * kleine Logik in den Methoden
 * ...
 */
#include <iostream>
using namespace std;

#define spalten 4
#define zeilen 10

class Silben {
	bool istVokal(const char c) {
		const char* vokale = "aeiou";
		for (const char *cp = vokale; *cp; cp++) {
			if (c == *cp)
				return true;
		}
		return false;
	}
public:
	int silbenZaehlen(char woher[]) {
		int zahl = 0;
		char *cp = woher;
		while(*cp != ' ') {
			if (!istVokal(*(cp++))) {
				zahl++;
			}
		}
		return zahl;
	}
	void silbenEintragen(char wohin[zeilen][spalten], char woher[]) {
		char *cp = woher;
		int j = 0;
		for (int i = 0; i < zeilen; i++) {
			if (*cp != ' ') {
				wohin[i][j++] = *(cp++);
				while(*cp != ' ' && istVokal(*cp)) {
					wohin[i][j++] = *(cp++);
				}
			}
			while(j < spalten) {
				wohin[i][j++] = ' ';
			}
			j = 0;
		}
	}
};

int main() {
	char arr[] = "rarierabegete ";
	Silben silben;

	cout << "Silben: " << silben.silbenZaehlen(arr) << "\n\n";

	char silbenArr[zeilen][spalten];
	silben.silbenEintragen(silbenArr, arr);

	for (int i = 0; i < zeilen; i++) {
		int j = 0;
		while(silbenArr[i][j] != ' ' && j < spalten)
			cout << (silbenArr[i][j++]);
		cout << endl;
	}

	return 0;
}
