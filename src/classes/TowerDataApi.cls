public with sharing class TowerDataApi {

	public static final Integer DEFAULT_TIMEOUT = 5000;
	// Validation flags
	/**
	 * Do not validate.
	 * Nothing will be validated if the validate parameter has a value of “none”
	 */
	public static String VALIDATE_NONE = 'none';
	/**
	 * Validate email parameter.
	 * A value of "email" means that that syntax, domain, and the mailbox will be checked.
	 */
	public static String VALIDATE_EMAIL = 'email';
	/**
	 * Validate email with email-domain-only option.
	 * A value of "email-domain-only" means that the service will only
	 * check the syntax and domain of an email address.
	 */
	public static String VALIDATE_EMAIL_DOMAIN = 'email-domain-only';
	/**
	 * Validate phone parameter.
	 * A value of “phone” means that the service fill validate the first 7 digits of a phone number
	 */
	public static String VALIDATE_PHONE = 'phone';
	/**
	 * Validate phone full parameter.
	 * the service will compare a 10 digit phone number with the American 411 directory
	 */
	public static String VALIDATE_PHONE_FULL = 'phone-full';
	/**
	 * Validate postal parameter.
	 */
	public static String VALIDATE_POSTAL = 'postal';
	/**
	 * Validate email, phone and postal parameters.
	 */
	public static String VALIDATE_ALL = '';

	// Response section names
	public static String EMAIL_SECTION = 'email';
	public static String FOUND_POSTAL_SECTION = 'found_postal';
	public static String IP_SECTION = 'ip';
	public static String DEMOGRAPHICS_SECTION = 'demographics';
	// format
	public static String JSON_FORMAT = 'json';
	public static String HTML_FORMAT = 'html';
	// find
	public static String FIND_NONE = '';
	/**
	 * "postal", to find name and address based on email address or phone number (email is tried first)
	 */
	public static String FIND_POSTAL = 'postal';
	/**
	 * “postal-email”, to find name and address by email address only
	 */
	public static String FIND_POSTAL_EMAIL = 'postal-email';
	/**
	 * “postal-phone”, to find name and address by phone number only
	 */
	public static String FIND_POSTAL_PHONE = 'postal-phone';
	//correct
	/**
	 * Specifies which pieces of information provided should be
	 * corrected, if they are invalid. The only valid value is "email".
	 * Postal information will always be corrected if it is validated.
	 */
	public static String CORRECT_NONE = '';
	public static String CORRECT_EMAIL = 'email';
	// log
	public static String LOG_OFF = '';
	public static String LOG_ON = 'log';
	// IP detection
	/**
	 * IP address. If the value of the ip parameter is “detect”, the
	 * service will use the IP address of the machine connecting to it.
	 */
	public static String DETECT_IP = 'detect';

	// LOG STATUS MESSAGES
	public static String SUCCESS_MESSAGE = 'Success';
	public static String ERROR_MESSAGE = 'Error';

	public static String EVENT_TYPE_SINGLE = 'Email-ManualAppend';
	public static String EVENT_TYPE_BATCH = 'Email-Batch';

	private String apiUrl;
	private SObject aObject;

	private String rawResponse;

	private Integer rawResponseCode;

	private Map<String, Object> response = new Map<String, Object>();
	private TowerDataDTO.TowerDataSettings settings = new TowerDataDTO.TowerDataSettings();
	private TowerDataDTO.TowerDataResponse responseS = new TowerDataDTO.TowerDataResponse();

	//Get stormpath credentials
	private Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();

	// CONSTRUCTOR
	public TowerDataApi(String endpoint) {
		this();
		this.apiUrl = endpoint;
	}

	public TowerDataApi() {
		this.settings = TouchCRConfigurationController.initSettings();
		this.apiUrl = 'callout:TouchCRBase__TowerData';
	}

	private String getEmail(String emailStr) {
		return (String.isBlank(emailStr)) ? null : emailStr;
	}

	private Boolean isEmailAppendEnabled() {
		if (aObject.getSObjectType() == Schema.Lead.getSObjectType()) {
			return (settings.leadValidateEmail) ? true : false;
		}
		else if (aObject.getSObjectType() == Schema.Account.getSObjectType()) {
			return (settings.accountValidateEmail) ? true : false;
		}
		else {
			return false;
		}
	}

	private Boolean isEmailValidateEnabled() {
		if (aObject.getSObjectType() == Schema.Lead.getSObjectType()) {
			return (settings.leadValidateEmail) ? true : false;
		}
		else if (aObject.getSObjectType() == Schema.Account.getSObjectType()) {
			return (settings.accountValidateEmail) ? true : false;
		}
		else {
			return false;
		}
	}

	private Boolean isEmailCorrectEnabled() {
		if (aObject.getSObjectType() == Schema.Lead.getSObjectType()) {
			return (settings.leadCorrectEmail) ? true : false;
		}
		else if (aObject.getSObjectType() == Schema.Account.getSObjectType()) {
			return (settings.accountCorrectEmail) ? true : false;
		}
		else {
			return false;
		}
	}

	private Boolean isFindPostalByEmailEnabled() {
		if (aObject.getSObjectType() == Schema.Lead.getSObjectType()) {
			return (settings.leadAppendNameAddress) ? true : false;
		}
		else if (aObject.getSObjectType() == Schema.Account.getSObjectType()) {
			return (settings.accountAppendNameAddress) ? true : false;
		}
		else {
			return false;
		}
	}

	private String createParamString() {
		PageReference result = new PageReference('');
		//required param on all requests
		result.getParameters().put('license', settings.license);
		/*Put version of request into params
			with v=1 or without v param makes request without checking stormpath credentials
			with v=2 param makes request with checking stormpath credentials			
		*/
		result.getParameters().put('v', '2');
		/*If v=2 it is required to set ClientId and ClientSecret params or/and set auth token on header*/

		if (this.settingsMap.containsKey('Endpoint.ClientId') && this.settingsMap.containsKey('Endpoint.ClientSecret')) {
			TouchCR_Settings__c clientId = this.settingsMap.get('Endpoint.ClientId');
			TouchCR_Settings__c clientSecret = this.settingsMap.get('Endpoint.ClientSecret');
			result.getParameters().put('spApiKeyId', clientId.Value__c);
			result.getParameters().put('spApiKeySecret', ClientSecret.Value__c);
		}

		//if object is lead
		if (aObject.getSObjectType() == Schema.Lead.getSObjectType()) {
			Lead aLead = (Lead) aObject;
			//lead data fields
			if (!String.isBlank(getEmail(aLead.Email))) {
				result.getParameters().put('email', aLead.Email);
			}
			if (!String.isBlank(aLead.FirstName)) {
				result.getParameters().put('fname', aLead.FirstName);
			}
			if (!String.isBlank(aLead.LastName)) {
				result.getParameters().put('lname', aLead.LastName);
			}
			if (!String.isBlank(aLead.Street)) {
				result.getParameters().put('address1', aLead.Street);
			}
			if (!String.isBlank(aLead.City)) {
				result.getParameters().put('city', aLead.City);
			}
			if (TouchCRHelper.isSCPEnabled() && !String.isBlank((String)aLead.get('StateCode'))) {
				result.getParameters().put('state', (String)aLead.get('StateCode'));
			}
			if (!String.isBlank(aLead.PostalCode)) {
				result.getParameters().put('zip', aLead.PostalCode);
			}
			//lead settings
			if (isEmailValidateEnabled()) {
				result.getParameters().put('validate', VALIDATE_EMAIL);
			}
			else {
				result.getParameters().put('validate', VALIDATE_NONE);
			}
			/*if (settings.leadIpAddress) {
				result.getParameters().put('ip', DETECT_IP);
			}*/
			if (isEmailCorrectEnabled()) {
				result.getParameters().put('correct', CORRECT_EMAIL);
			}
			if (isFindPostalByEmailEnabled()) {
				result.getParameters().put('find', FIND_POSTAL_EMAIL);
			}
		}
		//if object is account
		if (aObject.getSObjectType() == Schema.Account.getSObjectType()) {
			Account aAccount = (Account) aObject;
			//account data fields
			if (!String.isBlank(getEmail(aAccount.PersonEmail))) {
				result.getParameters().put('email', aAccount.PersonEmail);
			}
			if (!String.isBlank(aAccount.FirstName)) {
				result.getParameters().put('fname', aAccount.FirstName);
			}
			if (!String.isBlank(aAccount.LastName)) {
				result.getParameters().put('lname', aAccount.LastName);
			}
			if (!String.isBlank(aAccount.BillingStreet)) {
				result.getParameters().put('address1', aAccount.BillingStreet);
			}
			if (!String.isBlank(aAccount.BillingCity)) {
				result.getParameters().put('city', aAccount.BillingCity);
			}
			if (TouchCRHelper.isSCPEnabled() && !String.isBlank((String)aAccount.get('BillingStateCode'))) {
				result.getParameters().put('state', (String)aAccount.get('BillingStateCode'));
			}
			if (!String.isBlank(aAccount.BillingPostalCode)) {
				result.getParameters().put('zip', aAccount.BillingPostalCode);
			}
			//account settings
			if (isEmailValidateEnabled()) {
				result.getParameters().put('validate', VALIDATE_EMAIL);
			}
			else {
				result.getParameters().put('validate', VALIDATE_NONE );
			}
			/*if (settings.accountEnableDemo) {
				result.getParameters().put('demos', settings.demokey);
			}
			if (settings.accountIpAddress) {
				result.getParameters().put('ip', DETECT_IP);
			}*/
			if (isEmailCorrectEnabled()) {
				result.getParameters().put('correct', CORRECT_EMAIL);
			}
			if (isFindPostalByEmailEnabled()) {
				result.getParameters().put('find', FIND_POSTAL_EMAIL);
			}
		}

		return result.getUrl();
	}

	public void setObject(SObject aObject) {
		this.aObject = aObject;
		createParamString();
	}
	// API call
	public Map<String, Object> callApi() {
		try {
			String fullUrl = getFullApiUrl();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(fullUrl);
			request.setMethod('GET');
			request.setHeader('X-OrgID', UserInfo.getOrganizationId());
			if (this.settingsMap.containsKey('Endpoint.TokenType') && this.settingsMap.containsKey('Endpoint.TokenPart1') && this.settingsMap.containsKey('Endpoint.TokenPart2')) {
				TouchCR_Settings__c tokenType = this.settingsMap.get('Endpoint.TokenType');
				TouchCR_Settings__c tokenPart1 = this.settingsMap.get('Endpoint.TokenPart1');
				TouchCR_Settings__c tokenPart2 = this.settingsMap.get('Endpoint.TokenPart2');
				request.setHeader('Authorization', tokenType.Value__c.capitalize() + ' ' + tokenPart1.Value__c + tokenPart2.Value__c);
			}
			//request.setTimeout(timeout);
			Http http = new Http();
			HTTPResponse response = http.send(request);
			String responseBody = response.getBody();
			this.rawResponse = responseBody;

			this.rawResponseCode = response.getStatusCode();

			//generic response
			this.response = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
			//parsed reaponse
			this.responseS = (TowerDataDTO.TowerDataResponse) JSON.deserialize(responseBody, TowerDataDTO.TowerDataResponse.class);
		}
		catch (Exception e) {
			this.rawResponseCode = 999;
			this.rawResponse = rawResponse + '\n' + e.getMessage() + '\n' + e.getStackTraceString();
		}

		return this.response;
	}
	// LOG
	public Log__c logCall() {
		Log__c logRecord = new Log__c(
			Event_Type__c = (System.isBatch()) ? EVENT_TYPE_BATCH: EVENT_TYPE_SINGLE,
			Event_Status__c = getHttpStatus(),
			Event_Endpoint__c = getFullApiUrl().abbreviate(255),
			Event_Description__c = getRawResponse()
		);
		if (aObject.getSObjectType() == Schema.Account.getSObjectType()) {
			logRecord.Account__c = (aObject != null) ? aObject.Id : null;
		}
		if (aObject.getSObjectType() == Schema.Lead.getSObjectType()) {
			logRecord.Lead__c = (aObject != null) ? aObject.Id : null;
		}
		return logRecord;
	}
	// APPEND
	public SObject appendData() {
		//we have valid response
		if (getOverallStatusCode() == 10) {
			//LEAD
			if (aObject.getSObjectType() == Schema.Lead.getSObjectType()) {
				Lead aLead = (Lead) aObject;
				//append datetime and status
				aLead.Email_Append_Run__c = true;
				aLead.Email_Append_Run_Date__c = System.now();
				//EMAIL
				if (isEmailAppendEnabled()) {
					aLead.Email_Checked__c = true;
					TowerDataDTO.TowerDataResponseEmail emailResponse = getEmailResponse();
					//email section present
					if (emailResponse != null) {
						//Data is valid or data requested was found
						if (emailResponse.ok == true) {
							aLead.Email_Valid__c = true;
							if (10 <= emailResponse.status_code && emailResponse.status_code <= 50) {
								aLead.Email_Box_Valid__c = true;
							}
						}
						//Data is invalid or requested data was not found
						//check only correction
						if (emailResponse.ok == false) {
							aLead.Email_Valid__c = false;
							aLead.Email_Box_Valid__c = false;
							List<Object> corrections = (List<Object>) emailResponse.corrections;
							if (corrections != null) {
								aLead.Email_Corrections__c = String.valueOf(corrections);
							}
						}
					}
				}
				//IP
				if (settings.leadIpAddress) {
					TowerDataDTO.TowerDataResponseIp ipResponse = getIpResponse();
					//email section present
					if (ipResponse != null) {
						//Data is valid or data requested was found
						if (ipResponse.ok == true && ipResponse.status_code == 10) {
							aLead.IP_Address_Location_City__c = ipResponse.city;
							aLead.IP_Address_Location_Region__c = ipResponse.region;
							aLead.IP_Address_Location_Country_Code__c = ipResponse.country_code;
							aLead.IP_Address_Location_Country_Name__c = ipResponse.country_name;
						}
						//Data is invalid or requested data was not found
					}
				}
				//POSTAL
				if (settings.leadAppendNameAddress) {
					TowerDataDTO.TowerDataFoundPostal postalResponse = getPostalResponse();
					//email section present
					if (postalResponse != null) {
						//Data is valid or data requested was found
						if (postalResponse.ok == true && postalResponse.status_code == 10) {
							aLead.Append_Address_Street__c = postalResponse.address1;
							aLead.Append_Address_City__c = postalResponse.city;
							aLead.Append_Address_State__c = postalResponse.state;
							aLead.Append_Address_ZIp__c = postalResponse.zip;
						}
					}
				} //postal
			} // lead
			//ACCOUNT
			if (aObject.getSObjectType() == Schema.Account.getSObjectType()) {
				Account aAccount = (Account) aObject;
				//append datetime and status
				aAccount.Email_Append_Run__c = true;
				aAccount.Email_Append_Run_Date__c = System.now();
				//EMAIL
				if (isEmailAppendEnabled()) {
					aAccount.Email_Checked__c = true;
					TowerDataDTO.TowerDataResponseEmail emailResponse = getEmailResponse();
					//email section present
					if (emailResponse != null) {
						//Data is valid or data requested was found
						if (emailResponse.ok == true) {
							aAccount.Email_Valid__c = true;
							if (10 <= emailResponse.status_code && emailResponse.status_code <= 50) {
								aAccount.Email_Box_Valid__c = true;
							}
						}
						//Data is invalid or requested data was not found
						//check only correction
						if (emailResponse.ok == false) {
							aAccount.Email_Valid__c = false;
							aAccount.Email_Box_Valid__c = false;
							List<Object> corrections = (List<Object>) emailResponse.corrections;
							if (corrections != null) {
								aAccount.Email_Corrections__c = String.valueOf(corrections);
							}
						}
					}
				}
				//IP
				if (settings.accountIpAddress) {
					TowerDataDTO.TowerDataResponseIp ipResponse = getIpResponse();
					//email section present
					if (ipResponse != null) {
						//Data is valid or data requested was found
						if (ipResponse.ok == true && ipResponse.status_code == 10) {
							aAccount.IP_Address_Location_City__c = ipResponse.city;
							aAccount.IP_Address_Location_Region__c = ipResponse.region;
							aAccount.IP_Address_Location_Country_Code__c = ipResponse.country_code;
							aAccount.IP_Address_Location_Country_Name__c = ipResponse.country_name;
						}
					}
				} //ip
				//POSTAL
				if (settings.accountAppendNameAddress) {
					TowerDataDTO.TowerDataFoundPostal postalResponse = getPostalResponse();
					//email section present
					if (postalResponse != null) {
						//Data is valid or data requested was found
						if (postalResponse.ok == true && postalResponse.status_code == 10) {
							aAccount.Append_Address_Street__c = postalResponse.address1;
							aAccount.Append_Address_City__c = postalResponse.city;
							aAccount.Append_Address_State__c = postalResponse.state;
							aAccount.Append_Address_ZIp__c = postalResponse.zip;
						}
					}
				} //postal
			} // acc
		}

		return aObject;
	}
	// RESPONSE GETTERS
	public Integer getHttpStatusCode() {
		return rawResponseCode;
	}

	public String getHttpStatus() {
		return (getHttpStatusCode() == 200) ? SUCCESS_MESSAGE : ERROR_MESSAGE;
	}

	public Integer getOverallStatusCode() {
		return responseS.status_code;
	}

	public TowerDataDTO.TowerDataResponseEmail getEmailResponse() {
		return responseS.email;
	}

	public TowerDataDTO.TowerDataFoundPostal getPostalResponse() {
		return responseS.found_postal;
	}

	public TowerDataDTO.TowerDataResponseIp getIpResponse() {
		return responseS.ip;
	}
	// API GETTERS
	public String getRawResponse() {
		return rawResponse;
	}

	public String getFullApiUrl() {
		return getApiUrl() + createParamString();
	}

	public String getApiUrl() {
		return apiUrl;
	}
}