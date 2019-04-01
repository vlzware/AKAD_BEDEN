package mywebshop;

/**
 * Hilfsklasse zur Verwaltung von Ergebnis-Nachricht Paaren.
 */
class Result {
	private boolean success;
	private String message;

	public Result(boolean success, String message) {
		if (message == null) {
			throw new IllegalArgumentException();
		}
		this.success = success;
		this.message = message;
	}

	public boolean success() {
		return success;
	}

	public String getMessage() {
		return message;
	}
}
