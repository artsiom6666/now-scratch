public class SFDCValidationException extends Exception {
	// ValidationType - this enum defines the different types of validations.
	public enum ValidationType {
		// This error is a generic validation type.
		GENERIC,
		//This error type is an input validation.
		INPUT_VALIDATION,
		// This error type is a data validation.
		DATA_VALIDATION,
		// This error type is a limits validation.
		LIMIT_VALIDATION
	}

	@TestVisible private String eText;
	@TestVisible private ValidationType eType;

	public String ExceptionMessage {
		get {
			return eText;
		}
	}

	/*
	 * Constructor for SFDCValidationException.
	 * @param eText Error text
	 */
	public SFDCValidationException(String eText, ValidationType eType) {
		this.setMessage(eText);
		this.eText = eText;
		this.eType = eType;
		System.Debug(Logginglevel.ERROR, 'SFDCValidationException: ' + ExceptionMessage + ' - ' + this.getStackTraceString());
	}
}