package mywebshop;

/**
 * Hilfsklasse mit oft-benutzten Werkzeugen.
 */
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;

class Utils {
	/**
	 * Ein String auf vorgegebene Länge zuschneiden.
	 * 
	 * @param mString
	 * @param n
	 * @return
	 */
	static final String trimToN(String mString, int n) {
		if (mString == null || n <= 0) {
			return "";
		}
		return mString.substring(0, Math.min(mString.length(), n));
	}

	/**
	 * Prüft, ob ein BigDecimal positiv ist.
	 * 
	 * @param bd BigDecimal
	 * @return true, wenn positiv
	 */
	static final boolean positive(BigDecimal bd) {
		if (bd == null) {
			return false;
		}
		return (bd.compareTo(BigDecimal.ZERO) >= 0);
	}

	/**
	 * Formatiert BigDecimal für die Arbeit mit Währung.
	 * 
	 * @param bd BigDecimal unformatiert
	 * @return BigDecimal formatiert
	 */
	static final BigDecimal formatBigDecimal(BigDecimal bd) {
		if (bd == null) {
			return BigDecimal.ZERO;
		}
		return bd.setScale(2, RoundingMode.HALF_EVEN);
	}

	/**
	 * Findet die Position vom Artikel in der vorhandenen Positionsliste.
	 * 
	 * @param artikelnummer Artikel zu suchen
	 * @param liste         Positionsliste
	 * @return Position, wenn gefunden, oder -1 wenn nicht
	 */
	static final int findArtikelPos(int artikelnummer, ArrayList<Position> liste) {
		if (liste == null) {
			return -1;
		}
		for (int i = 0; i < liste.size(); i++) {
			if (liste.get(i).getArtikelnummer() == artikelnummer) {
				return i;
			}
		}
		return -1;
	}

	/**
	 * Formatiert eine Positionsliste als String.
	 * 
	 * @param liste Positionsliste
	 * @return als String formatiere Liste
	 */
	static final String listeToString(ArrayList<Position> liste) {
		String result = "";
		if (liste == null) {
			return result;
		}
		int len = liste.size();
		for (int i = 0; i < len; i++) {
			result += "\n" + liste.get(i).toString();
		}
		return result;
	}

	/**
	 * Einfach ein "okay" Result zurückgeben.
	 * 
	 * @return "okay" Result
	 */
	static final Result okay() {
		return new Result(true, "Okay");
	}
}
