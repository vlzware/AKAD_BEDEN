package mywebshop;

/**
 * Verwaltung vom Artikel
 */
import java.math.BigDecimal;

class Artikel {
	private final int MAX_BESCHREIBUNG = 20;
	private int artikelnummer;
	private String beschreibung;
	private BigDecimal nettopreis;
	private BigDecimal steuersatz;

	/**
	 * Konstruktor für neuen Artikel.
	 * 
	 * @param beschreibung Beschreibung
	 * @param nettopreis   Nettopreis
	 * @param steuersatz   Steuersatz
	 * @param db           Datenbank
	 * @throws IllegalArgumentException
	 */
	public Artikel(String beschreibung, BigDecimal nettopreis, BigDecimal steuersatz, Datenbank db) {
		if (beschreibung == null || !Utils.positive(nettopreis) || !Utils.positive(steuersatz) || db == null) {
			throw new IllegalArgumentException(" (!) Artikel: ungültige Parameter.");
		}
		this.nettopreis = nettopreis;
		this.steuersatz = steuersatz;
		this.beschreibung = Utils.trimToN(beschreibung, MAX_BESCHREIBUNG);
		artikelnummer = db.nextIndex();
		db.newArtikel(this);
	}

	public int getArtikelnummer() {
		return artikelnummer;
	}

	public String getBeschreibung() {
		return beschreibung;
	}

	public BigDecimal getNettopreis() {
		return nettopreis;
	}

	public BigDecimal getSteuersatz() {
		return steuersatz;
	}

	public Result setBeschreibung(String beschreibung) {
		if (beschreibung == null) {
			return new Result(false, " (!) Leere Beschreibung.");
		}
		this.beschreibung = Utils.trimToN(beschreibung, MAX_BESCHREIBUNG);
		return Utils.okay();
	}

	public Result setNettopreis(BigDecimal nettopreis) {
		if (!Utils.positive(nettopreis)) {
			return new Result(false, "Unmöglicher Nettopreis: " + nettopreis);
		}
		this.nettopreis = nettopreis;
		return Utils.okay();
	}

	public Result setSteuersatz(BigDecimal steuersatz) {
		if (!Utils.positive(steuersatz)) {
			return new Result(false, "Unmöglicher Steuersatz: " + steuersatz);
		}
		this.steuersatz = steuersatz;
		return Utils.okay();
	}
}
