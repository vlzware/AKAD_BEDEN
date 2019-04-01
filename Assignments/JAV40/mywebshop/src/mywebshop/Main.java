package mywebshop;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Scanner;

public class Main {

	/**
	 * Main-Programm zum Testen der Webshop-Klassen
	 */
	@SuppressWarnings("unused")
	public static void main(String[] args) {

		Scanner user = new Scanner(System.in);
		UI ui = new UI(user);

		/**
		 * Datenbank anlegen: alle zur Verfügung stehenden Artikel und deren Bestand.
		 */
		Datenbank db = new Datenbank();
		Artikel artikel0 = new Artikel("Zahnpste", new BigDecimal("120"), new BigDecimal("0.19"), db);
		// fehlerhafte Einträge werden korrigiert
		artikel0.setBeschreibung("Zahnpaste");
		artikel0.setNettopreis(new BigDecimal("1.20"));
		artikel0.setSteuersatz(new BigDecimal("19"));
		Artikel artikel1 = new Artikel("Zahnbürste", new BigDecimal("3.20"), new BigDecimal("19"), db);
		Artikel artikel2 = new Artikel("Zahnseide", new BigDecimal("1.00"), new BigDecimal("19"), db);
		Artikel artikel3 = new Artikel("Windeln Baby", new BigDecimal("13.45"), new BigDecimal("15"), db);
		Artikel artikel4 = new Artikel("Flüssigseife", new BigDecimal("1.60"), new BigDecimal("19"), db);
		Artikel artikel5 = new Artikel("Kräutertee", new BigDecimal("1.99"), new BigDecimal("19"), db);
		Artikel artikel6 = new Artikel("Bonbons", new BigDecimal("2.00"), new BigDecimal("19"), db);
		Artikel artikel7 = new Artikel("Handyhülle", new BigDecimal("7.99"), new BigDecimal("19"), db);
		Artikel artikel8 = new Artikel("Handyhülle Luxus", new BigDecimal("19.99"), new BigDecimal("22"), db);
		ArrayList<Position> bestand = new ArrayList<Position>();
		for (int i = 0; i < 9; i++) {
			bestand.add(new Position(i, 10, db));
		}
		db.setBestand(bestand);

		System.out.println("Bestand vor dem Einkaufen:");
		System.out.println(ui.getHeader());
		System.out.println(db.toString());
		System.out.println();

		/**
		 * Drei Benutzer, drei Warenkörbe
		 */
		final int BENUTZER_A = 10;
		final int BENUTZER_B = 11;
		final int BENUTZER_C = 12;
		Warenkorb warenkorbA = new Warenkorb(BENUTZER_A, db);
		Warenkorb warenkorbB = new Warenkorb(BENUTZER_B, db);
		Warenkorb warenkorbC = new Warenkorb(BENUTZER_C, db);

		/**
		 * Drei unproblematische Bestellungen
		 */
		// 1 x Zahnpaste, 2 x Zahnbürste, 1 x Zahnseide, 3 x Kräutertee
		int[][] bestellungA = { { 0, 1 }, { 1, 2 }, { 2, 1 }, { 5, 3 } };

		// 2 x Windeln, 1 x Bonbons
		int[][] bestellungB = { { 3, 2 }, { 6, 1 } };

		// 1 x Seife, 1 x Handyhülle Luxus
		int[][] bestellungC = { { 4, 1 }, { 8, 1 } };

		/**
		 * Einkaufen:
		 */
		ui.einkaufen(warenkorbA, bestellungA, db);
		ui.einkaufen(warenkorbB, bestellungB, db);
		ui.einkaufen(warenkorbC, bestellungC, db);

		/**
		 * Alle Warenkörbe anzeigen:
		 */
		ui.printInfo(warenkorbA);
		ui.printInfo(warenkorbB);
		ui.printInfo(warenkorbC);

		/**
		 * "Lager" kontrollieren:
		 */
		System.out.println("Bestand nach dem Einkaufen:");
		System.out.println(ui.getHeader());
		System.out.println(db.toString());

		/**
		 * Interaktives Menü
		 */
		System.out.println();
		System.out.println();
		if (ui.getInput("Interaktives Menü starten? (j/n)", new String[] { "j", "n" }).equals("n")) {
			System.out.println("Bye!");
			user.close();
			return;
		}

		/**
		 * Testbenutzer mit Warenkörben anlegen
		 */
		Warenkorb wkListe[] = { new Warenkorb(0, db), new Warenkorb(1, db), new Warenkorb(2, db), new Warenkorb(3, db),
				new Warenkorb(4, db) };
		int currentUser = 0;

		/**
		 * Menü
		 */
		boolean weiter = true;
		while (weiter) {
			String input;
			int artikelnummer;
			int anzahl;
			Result result;
			System.out.println();
			System.out.println("Der aktulle Benutzer hat die ID: " + currentUser);
			String msg = "Bitte wählen:\n" + "  (1) Warenkorb ansehen,  (2) Bestand ansehen,"
					+ "\n  (3) Benutzer wechseln,  (4) neue Position,"
					+ "\n  (5) Position löschen,   (6) Position ändern," + "\n  (7) Warenkorb leeren,   (8) Bestellen,"
					+ "\n  (9) Schluss.";
			int choice = ui.getInt(msg, 1, 9);
			System.out.println();
			switch (choice) {
			case 1: // Warenkorb ansehen
				ui.printInfo(wkListe[currentUser]);
				break;
			case 2: // Bestand ansehen
				System.out.println("Bestand:");
				System.out.println(ui.getHeader());
				System.out.println(db.toString());
				break;
			case 3: // Benutzer wechseln
				currentUser = ui.getInt("Bitte Benutzer ID (0-4) wählen:", 0, 4);
				System.out.println("Benutzer gewechselt.");
				break;
			case 4: // neue Position
				System.out.println("Verfügbare Artikel:");
				System.out.println(ui.getHeader());
				System.out.println(db.toString());
				artikelnummer = ui.getInt("Bitte Artikel wählen (0-8):", 0, 8);
				anzahl = ui.getInt("Wieviel davon?");
				result = wkListe[currentUser].addPosition(artikelnummer, anzahl);
				if (result.success()) {
					System.out.println("Position hinzugefügt.");
				} else {
					System.out.println(" (!) Problem beim Anlegen der Position: " + result.getMessage());
				}
				break;
			case 5: // Positon löschen
				anzahl = wkListe[currentUser].getAnzahlPositionen();
				if (anzahl == 0) {
					System.out.println(" (!) Ihr Warenkorb ist leer!");
					break;
				}
				System.out.println("Ihr Warenkorb:");
				System.out.println(ui.getHeader());
				ui.printInfo(wkListe[currentUser]);
				artikelnummer = ui.getInt("Welcher Artikel soll gelöscht werden? Bitte die Artikelnummer eingeben:");
				result = wkListe[currentUser].deletePosition(artikelnummer);
				if (result.success()) {
					System.out.println("Position gelöscht.");
				} else {
					System.out.println(" (!) Problem beim Löschen der Position: " + result.getMessage());
				}
				break;
			case 6: // Position ändern
				anzahl = wkListe[currentUser].getAnzahlPositionen();
				if (anzahl == 0) {
					System.out.println(" (!) Ihr Warenkorb ist leer!");
					break;
				}
				System.out.println("Ihr Warenkorb:");
				System.out.println(ui.getHeader());
				ui.printInfo(wkListe[currentUser]);
				artikelnummer = ui.getInt("Welche Position soll geändert werden? Bitte die Artikelnummer eingeben:");
				anzahl = ui.getInt("Bitte die Änderung eingeben (z.B. '1' oder '-2' etc):");
				System.out.println(anzahl);
				result = wkListe[currentUser].updatePosition(artikelnummer, anzahl);
				if (result.success()) {
					System.out.println("Position aktualisiert.");
				} else {
					System.out.println(" (!) Problem bei der Aktualisierung der Position: " + result.getMessage());
				}
				break;
			case 7: // Warenkorb leeren
				anzahl = wkListe[currentUser].getAnzahlPositionen();
				if (anzahl == 0) {
					System.out.println(" (!) Ihr Warenkorb ist leer!");
					break;
				}
				wkListe[currentUser].delete();
				System.out.println("Warenkorb geleert.");
				break;
			case 8: // Bestellen
				anzahl = wkListe[currentUser].getAnzahlPositionen();
				if (anzahl == 0) {
					System.out.println(" (!) Ihr Warenkorb ist leer!");
					break;
				}
				wkListe[currentUser].bestelle();
				System.out.println("Danke für Ihre Bestellung!");
				break;
			case 9: // Schluss
				weiter = false;
				break;
			}
		}
		System.out.println("Bye!");
		user.close();
	}

}
