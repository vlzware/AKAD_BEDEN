package mywebshop;

import java.util.ArrayList;

/**
 * Datenbank-Daten
 */
class Datenbank {
	private int indexArtikel;
	private ArrayList<Artikel> alleArtikel;
	private ArrayList<Position> bestand;

	public Datenbank() {
		bestand = new ArrayList<Position>();
		indexArtikel = 0;
		alleArtikel = new ArrayList<Artikel>();
	}

	/**
	 * Gibt die nächste Artikelnummer zurück. Das wird benutzt um neue Artikel in
	 * der Datenbank anzulegen.
	 * 
	 * @return nächste Artikelnummer
	 */
	public int nextIndex() {
		return indexArtikel++;
	}

	/**
	 * Neuer Artikel zur Datenbank hinzufügen.
	 * 
	 * @param artikel der neue Artikel
	 * @throws IllegalArgumentException
	 */
	public void newArtikel(Artikel artikel) {
		if (artikel == null) {
			throw new IllegalArgumentException();
		}
		alleArtikel.add(artikel);
	}

	/**
	 * Findet ein Artikel nach Artikelnummer in der Datenbank.
	 * 
	 * @param artikelnummer Artikelnummer zu suchen
	 * @return Artikel, wenn gefunden, oder null wenn nicht
	 */
	public Artikel findArtikel(int artikelnummer) {
		for (int i = 0; i < alleArtikel.size(); i++) {
			if (alleArtikel.get(i).getArtikelnummer() == artikelnummer) {
				return alleArtikel.get(i);
			}
		}
		return null;
	}

	/**
	 * Legt die Bestandliste in der Datenbank fest.
	 * 
	 * @param bestand Bestandliste
	 * @throws IllegalArgumentException
	 */
	public void setBestand(ArrayList<Position> bestand) {
		if (bestand == null) {
			throw new IllegalArgumentException();
		}
		this.bestand = bestand;
	}

	/**
	 * Aktualisiert vorhandene Position im Bestand. Wenn die Anzahl der Artikel in
	 * der Position Null wird, bleibt die Position erhalten (der Artikel existiert
	 * in der Datenbank immer noch).
	 * 
	 * @param artikelnummer Artikelnummer
	 * @param anzahl        Änderung (z.B. 1, oder -2 etc.)
	 * @return <code>Result</code> mit entsprechende Meldung
	 * @see mywebshop.Result
	 */
	public Result updateBestand(int artikelnummer, int anzahl) {
		int posBestand = Utils.findArtikelPos(artikelnummer, bestand);
		if (posBestand == -1) {
			return new Result(false, "Artikel '" + artikelnummer + "' ist nicht im Bestand!");
		}
		return bestand.get(posBestand).addAnzahl(anzahl);
	}

	/**
	 * Gibt die Bestandliste als String zurück.
	 * 
	 * @see mywebshop.Utils#listeToString
	 */
	@Override
	public String toString() {
		return Utils.listeToString(bestand);
	}
}
