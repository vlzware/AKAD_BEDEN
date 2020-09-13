package mywebshop;

/**
 * Hilfsklasse zur Verwaltung von Artikel-Anzahl Paaren.
 */
class Position {
	private int artikelnummer;
	private int anzahl;
	private Datenbank db;

	/**
	 * Konstruktor.
	 * 
	 * @param artikelnummer
	 * @param anzahl
	 * @param db            Datenbank
	 * @throws IllegalArgumentException
	 */
	Position(int artikelnummer, int anzahl, Datenbank db) {
		if (anzahl < 0 || db == null || db.findArtikel(artikelnummer) == null) {
			throw new IllegalArgumentException(" (!) Position: ungültige Parameter.");
		}
		this.artikelnummer = artikelnummer;
		this.anzahl = anzahl;
		this.db = db;
	}

	public int getArtikelnummer() {
		return artikelnummer;
	}

	public int getAnzahl() {
		return anzahl;
	}

	public Result setAnzahl(int anzahl) {
		if (anzahl < 0) {
			return new Result(false, " (!) Unmögliche Anzahl.");
		}
		this.anzahl = anzahl;
		return Utils.okay();
	}

	public Result addAnzahl(int anzahl) {
		if (this.anzahl + anzahl < 0) {
			return new Result(false,
					"Verfügbare Menge (" + this.anzahl + ") nicht genug für die Änderung (" + anzahl + ")");
		}
		this.anzahl += anzahl;
		return Utils.okay();
	}

	/**
	 * Gibt die Position formatiert als String geeignet für System.out zurück.
	 */
	@Override
	public String toString() {
		Artikel artikel = db.findArtikel(artikelnummer);
		if (artikel == null)
			return "";
		return String.format("    (%2d)  %-20.20s %6.6s €  %2.2s %%  %3d", artikelnummer, artikel.getBeschreibung(),
				artikel.getNettopreis().toString(), artikel.getSteuersatz().toString(), anzahl);
	}
}
