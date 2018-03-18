public class SFDCErrorException extends Exception {

	// ErrorType - this enum defines the different types of validations.
	public enum ErrorType {
		// This error is a generic validation type.
		GENERIC,
		// This error type is an input validation.
		LOGIC_ERROR,
		// This error type is a data validation.
		CODE_ERROR
	}

	@TestVisible private String eText;
	@TestVisible private ErrorType eType;

	public String ExceptionMessage {
		get {
			return eText;
		}
	}

	/*
	 * Constructor for SFDCErrorException.
	 * @param eText Error text
	 */
	public SFDCErrorException(String eText, ErrorType eType) {
		this.setMessage(eText);
		this.eText = eText;
		this.eType = eType;
		System.Debug(Logginglevel.ERROR, 'SFDCErrorException: ' + ExceptionMessage + ' - ' + this.getStackTraceString());
	}
}