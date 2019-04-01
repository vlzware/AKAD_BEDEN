package mywebshop;

import java.math.BigDecimal;
import java.util.ArrayList;

/**
 * Verwaltung von Warenkörben
 */
class Warenkorb {
	private int benutzerId;
	private ArrayList<Position> positionListe;
	private int anzahlPositionen;
	private int anzahlArtikel;
	private BigDecimal summeNetto;
	private BigDecimal summeTotal;
	private Datenbank db;

	/**
	 * Konstruktor
	 * 
	 * @param benutzerId
	 * @param db         Datenbank
	 * @throws IllegalArgumentException
	 */
	public Warenkorb(int benutzerId, Datenbank db) {
		if (db == null) {
			throw new IllegalArgumentException(" (!) Warenkorb: ungültige Parameter.");
		}
		this.benutzerId = benutzerId;
		anzahlPositionen = 0;
		anzahlArtikel = 0;
		summeNetto = BigDecimal.ZERO;
		summeTotal = BigDecimal.ZERO;
		positionListe = new ArrayList<Position>();
		this.db = db;
	}

	/**
	 * Aktualisiert die Gesamtsummen (Netto und Total)
	 * 
	 * @param artikelnummer der neu-zugefügte Artikel
	 * @param anzahl
	 * @return <code>Result</code> mit entsprechender Meldung
	 * @see mywebshop.Result
	 */
	private Result updateSumme(int artikelnummer, int anzahl) {
		Artikel artikel = db.findArtikel(artikelnummer);
		if (artikel == null) {
			return new Result(false, " (!) Artikel existiert nicht!");
		}
		BigDecimal netto = artikel.getNettopreis();
		BigDecimal steuer = artikel.getSteuersatz();

		summeNetto = summeNetto.add(netto.multiply(new BigDecimal(anzahl)));

		// summeTotal += anzahl * (nettopreis * (1 + steuersatz/100))
		summeTotal = summeTotal.add(steuer.divide(new BigDecimal("100")).add(BigDecimal.ONE).multiply(netto)
				.multiply(new BigDecimal(anzahl)));

		return Utils.okay();
	}

	public int getBenutzerId() {
		return benutzerId;
	}

	public int getAnzahlPositionen() {
		return anzahlPositionen;
	}

	public int getAnzahlArtikel() {
		return anzahlArtikel;
	}

	public BigDecimal getSummeNetto() {
		return Utils.formatBigDecimal(summeNetto);
	}

	public BigDecimal getSummeTotal() {
		return Utils.formatBigDecimal(summeTotal);
	}

	/**
	 * Fügt eine neue Position im Warenkorb hinzu.
	 * 
	 * @param artikelnummer
	 * @param anzahl
	 * @return <code>Result</code> mit entsprechender Meldung
	 * @see mywebshop.Result
	 */
	public Result addPosition(int artikelnummer, int anzahl) {
		if (anzahl <= 0) {
			return new Result(false, "Unmögliche Anzahl: " + anzahl);
		}
		Result result;
		if (!(result = db.updateBestand(artikelnummer, anzahl * (-1))).success())
			return result;

		int posWarenkorb = Utils.findArtikelPos(artikelnummer, positionListe);
		if (posWarenkorb == -1) {
			Position newPosition = new Position(artikelnummer, anzahl, db);
			positionListe.add(newPosition);
		} else {
			if (!(result = positionListe.get(posWarenkorb).addAnzahl(anzahl)).success())
				return result;
		}

		if (!(result = updateSumme(artikelnummer, anzahl)).success())
			return result;
		anzahlPositionen++;
		anzahlArtikel += anzahl;

		return Utils.okay();
	}

	/**
	 * Position im Warenkorb aktualisieren.
	 * 
	 * @param artikelnummer die Position wird mit Artikelnummer gegeben
	 * @param anzahl        die Änderung - kann positiv oder negativ sein
	 * @return <code>Result</code> mit entsprechender Meldung
	 * @see mywebshop.Result
	 */
	public Result updatePosition(int artikelnummer, int anzahl) {
		int posWarenkorb = Utils.findArtikelPos(artikelnummer, positionListe);
		if (posWarenkorb == -1) {
			return new Result(false, "Artikel ist nicht im Warenkorb!");
		}
		Result result;
		if (!(result = positionListe.get(posWarenkorb).addAnzahl(anzahl)).success())
			return result;
		if (!(result = db.updateBestand(artikelnummer, anzahl * (-1))).success())
			return result;
		if (!(result = updateSumme(artikelnummer, anzahl)).success())
			return result;
		anzahlArtikel += anzahl;
		if (positionListe.get(posWarenkorb).getAnzahl() == 0) {
			return deletePosition(artikelnummer);
		}

		return Utils.okay();
	}

	/**
	 * Position im Warenkorb löschen
	 * 
	 * @param artikelnummer die Position wird mit Artikelnummer gegeben
	 * @return <code>Result</code> mit entsprechender Meldung
	 * @see mywebshop.Result
	 */
	public Result deletePosition(int artikelnummer) {
		int posWarenkorb = Utils.findArtikelPos(artikelnummer, positionListe);
		if (posWarenkorb == -1) {
			return new Result(false, "Artikel ist nicht im Warenkorb!");
		}
		Result result;
		int anzahl = positionListe.get(posWarenkorb).getAnzahl();
		positionListe.remove(posWarenkorb);
		if (!(result = db.updateBestand(artikelnummer, anzahl)).success())
			return result;
		if (!(result = updateSumme(artikelnummer, anzahl)).success())
			return result;
		anzahlPositionen--;
		anzahlArtikel -= anzahl;

		return Utils.okay();
	}

	/**
	 * Positionen auflösen, Artikel zum Bestand zurückbuchen und Warenkorb leeren.
	 * Wie z.B: Der Benutzer logt sich aus, ohne zu bestellen (und will seinen
	 * Warenkorb nicht speichern).
	 */
	public void delete() {
		for (int i = 0; i < positionListe.size(); i++) {
			Position mPos = positionListe.get(i);
			db.updateBestand(mPos.getArtikelnummer(), mPos.getAnzahl());
		}
		clear();
	}

	/**
	 * Bestellung vom Warenkorb "auslösen". Jetzt leert nur diese Methode den
	 * Warenkorb. Der Benutzer hat "jetzt kaufen" bestätigt.
	 */
	public void bestelle() {
		clear();
	}

	/**
	 * Warenkorb leeren und Summen zurücksetzen.
	 */
	private void clear() {
		positionListe.clear();
		anzahlPositionen = 0;
		anzahlArtikel = 0;
		summeNetto = BigDecimal.ZERO;
		summeTotal = BigDecimal.ZERO;
	}

	/**
	 * Gibt den Warenkorb formatiert als String geeignet für System.out zurück.
	 * 
	 * @see Utils#listeToString(ArrayList)
	 */
	@Override
	public String toString() {
		return Utils.listeToString(positionListe);
	}
}
