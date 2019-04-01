package mywebshop;

import java.util.Scanner;

import org.apache.commons.lang3.math.NumberUtils;

/**
 * Hilfsklasse zum Main-Programm, um die Interaktion mit dem Benutzer zu
 * steuern. Die Klasse arbeitet mit der Konsole (System.in und System.out)
 */
class UI {
	private final String HEADER = " ArtNum |    Beschreibung      | Preis | MwSt | Anzahl";

	/**
	 * Konstante für die Benutzeroberfläche
	 * 
	 * @return Überschrift für die Tabelle im Menü
	 */
	public String getHeader() {
		return HEADER;
	}

	private Scanner user;

	/**
	 * Konstruktor
	 * 
	 * @param user Benutzer-ID
	 * @throws IllegalArgumentException
	 */
	public UI(Scanner user) {
		if (user == null) {
			throw new IllegalArgumentException();
		}
		this.user = user;
	}

	/**
	 * Füllt den Warenkorb mit der Bestellung.
	 * 
	 * @param wk         Der Warenkorb, der befüllt wird
	 * @param bestellung Die Elemente der Bestellung als int[][]
	 * @param db         Datenbank mit den Artikel und Bestand
	 */
	void einkaufen(Warenkorb wk, int[][] bestellung, Datenbank db) {
		if (wk == null || bestellung == null || db == null) {
			System.out.println(" (!) UI.einkaufen: Keine Parameter zum Einkaufen.");
			return;
		}
		for (int[] bestelle : bestellung) {
			Result res = wk.addPosition(bestelle[0], bestelle[1]);
			if (!res.success()) {
				System.out.println(" (!) Artikel '" + bestelle[0] + "' nicht in dieser Menge verfügbar:");
				System.out.println("     " + res.getMessage());
				System.out.println();
			}
		}
	}

	/**
	 * Drückt den Warenkorb auf dem Bildschirm aus.
	 * 
	 * @param wk Warenkorb zu drucken
	 */
	void printInfo(Warenkorb wk) {
		if (wk == null) {
			System.out.println(" (!) UI.printInfo: Kein Warenkorb zu zeigen.");
			return;
		}
		System.out.println(".......");
		System.out.println("Benutzer ID: " + wk.getBenutzerId());
		System.out.println("Warenkorb:");
		System.out.println(HEADER);
		System.out.println(wk.toString());
		System.out.println();
		System.out.println("Positionen:  " + wk.getAnzahlPositionen());
		System.out.println("Artikel:     " + wk.getAnzahlArtikel());
		System.out.println("Summe Netto: " + wk.getSummeNetto());
		System.out.println("Summe Total: " + wk.getSummeTotal());
		System.out.println(".......");
		System.out.println();
	}

	/**
	 * Eingabe vom Benutzer holen (String).
	 * 
	 * @param msg Nachricht die dem Benutzer gezeigt wird
	 * @return Benutzereingabe
	 */
	String getInput(String msg) {
		if (msg == null) {
			System.out.println(" (!) UI.getInput: Keine Nachricht zum Zeigen.");
			return "";
		}
		return getInput(msg, null);
	}

	/**
	 * Eingabe vom Benutzer holen (String). Mit Liste der erlaubten Eingaben.
	 * 
	 * @param msg          Nachricht, die dem Benutzer angezeigt wird
	 * @param allowedInput Liste mir erlaubte Eingaben
	 * @return Benutzereingabe
	 */
	String getInput(String msg, String[] allowedInput) {
		if (msg == null) {
			System.out.println(" (!) UI.getInput: Keine Nachricht.");
			return "";
		}
		String input = "";
		while (true) {
			System.out.println(msg);
			input = user.nextLine();
			if (allowedInput == null) {
				break;
			}
			for (String str : allowedInput) {
				if (input.equals(str)) {
					return input;
				}
			}
		}
		return input;
	}

	/**
	 * Eingabe vom Benutzer holen (int).
	 * 
	 * @param msg Nachricht, die dem Benutzer angezeigt wird
	 * @return Benutzereingabe
	 */
	int getInt(String msg) {
		if (msg == null) {
			System.out.println(" (!) UI.getInt: Keine Nachricht zum Zeigen.");
			return -1;
		}
		String input;
		while (true) {
			input = getInput(msg);
			if (NumberUtils.isParsable(input)) {
				return Integer.parseInt(input);
			}
		}
	}

	/**
	 * Eingabe vom Benutzer holen (int). Mit erlaubtem Bereich.
	 * 
	 * @param msg  Nachricht, die dem Benutzer angezeigt wird
	 * @param from Minimalwert
	 * @param to   Maximalwert
	 * @return Benutzereingabe
	 */
	int getInt(String msg, int from, int to) {
		if (msg == null || (from >= to)) {
			System.out.println(" (!) UI.getInt: ungültige Parameter.");
			return -1;
		}
		int res;
		while (true) {
			res = getInt(msg);
			if (res >= from && res <= to) {
				return res;
			}
		}
	}
}
