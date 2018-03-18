global with sharing class DataFinderApi {

	// CONNECTION
	public static String REQUEST_GET = 'GET';
	public static String REQUEST_POST = 'POST';
	// default NC
	public static String DEFAULT_NC = 'callout:DataFinderApi';

	public static String CONTENT_KEY = 'Content-Type';
	public static String CONTENT_TYPE = 'application/json';

	public static String CONF_KEY = 'k2';
	public static String CONF_SERVICE = 'service';
	public static String CONF_CODES = 'cfg_mc';

	// CONSTRUCTOR
	global DataFinderApi(String endpoint) {
		this.apiUrl = endpoint;
	}

	global DataFinderApi() {
		this(DEFAULT_NC);
	}

	// PAYLOAD DATA MAP
	public static Map<String, String> payloadDataConfig = new Map<String, String> {
		CONF_KEY => '',
		CONF_SERVICE => 'email',
		CONF_CODES => 'LF,ACSZ'
	};

	public static Map<String, String> payloadDataObject = new Map<String, String>();

	// privates
	private String apiUrl;
	private SObject aObject;

	private Integer rawGetResponseCode;
	private String rawGetResponse;

	private DFResposne dataResponse;

	//Get stormpath credentials
	private Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();

	// API call
	global DataFinderApi doGetData() {
		try {
			HttpRequest request = new HttpRequest();
			request.setEndpoint(getApiUrl());
			//request.setMethod(REQUEST_GET);
			request.setTimeout(120000);
			request.setMethod(REQUEST_POST);
			request.setBody(createRequestBody());
			if (this.settingsMap.containsKey('Endpoint.TokenType') && this.settingsMap.containsKey('Endpoint.TokenPart1') && this.settingsMap.containsKey('Endpoint.TokenPart2')) {
				TouchCR_Settings__c tokenType = this.settingsMap.get('Endpoint.TokenType');
				TouchCR_Settings__c tokenPart1 = this.settingsMap.get('Endpoint.TokenPart1');
				TouchCR_Settings__c tokenPart2 = this.settingsMap.get('Endpoint.TokenPart2');
				request.setHeader('Authorization', tokenType.Value__c.capitalize() + ' ' + tokenPart1.Value__c + tokenPart2.Value__c);
			}

			Http http = new Http();
			HTTPResponse response = http.send(request);
			rawGetResponseCode = response.getStatusCode();
			rawGetResponse = response.getBody();

			//update token
			if (response.getHeader('Access-Token') != null) {
				TouchCRHelper.setAuthCredentinals(response.getHeader('Access-Token'));
			}

			dataResponse = doParseResponse(rawGetResponse);
		}
		catch (Exception e) {
			rawGetResponseCode = 999;
			rawGetResponse = rawGetResponse + '\n' + e.getMessage() + '\n' + e.getStackTraceString();
		}
		return this;
	}

	// PRIVATE HELPER METHODS
	private DFResposne doParseResponse(String rawGetResponse) {
		if (rawGetResponse == null || String.isBlank(rawGetResponse)) {
			return null;
		}

		// str replace for inbound response
		String replacedResponse = rawGetResponse.replace('input-query', 'input_query');
		replacedResponse = replacedResponse.replace('num-results', 'num_results');
		replacedResponse = replacedResponse.replace('#RawScore', 'RawScore');
		replacedResponse = replacedResponse.replace('#RawMatchCodes', 'RawMatchCodes');

		DFResposne dataResponse = (DFResposne) JSON.deserialize(replacedResponse, DFResposne.class);

		return dataResponse;
	}

	private DFResposneObj getResponseObj(DFResposne response) {

		return (response == null) ? null : response.datafinder;
	}

	/**
	 * check response for errors
	 */
	private Boolean isValidResponse(DFResposneObj response) {
		Boolean result = (
			response.num_results != null
			&& (response.errors == null || response.errors.isEmpty())
		);
		return result;
	}

	/**
	 * check response for results
	 */
	private Boolean hasResultsResponse(DFResposneObj response) {
		Boolean result = (
			response.num_results != null
			&& response.num_results > 0
		);
		return result;
	}

	/** two required flags should be in a response */
	private Boolean hasRequiredMarkers(DFResposneResults resultObj) {
		String markerINDIV = 'INDIV';
		String markerHHLD = 'HHLD';

		Boolean result = (resultObj.RawMatchCodes.contains(markerINDIV)
			&& resultObj.RawMatchCodes.contains(markerHHLD)
		);
		return result;
	}

	/**
	 * if response valid => we have results, return all resluts array with raw scores
	 */
	private Map<String, Double> getAllEmailsFromResponseObj(DFResposneObj response) {
		// in case we got array of results
		Map<String, Double> allResults = new Map<String, Double>();

		for (DFResposneResults aResult : response.results) {
			//if rawmatchcodes have INDIV AND HHLD markers
			if (hasRequiredMarkers(aResult)) {
				allResults.put(aResult.EmailAddr, aResult.RawScore);
			}
			else {
				continue;
			}
		}
		return allResults;
	}

	/** returns email with highest score */
	private String getHighestMatchEmail(Map<String, Double> emailsWithScores) {
		Double highestSocre = 0;
		String emailWithHighestScore = '';

		for (String anEmail : emailsWithScores.keySet()) {
			if (emailsWithScores.get(anEmail) > highestSocre) {
				highestSocre = emailsWithScores.get(anEmail);
				emailWithHighestScore = anEmail;
			}
		}
		return emailWithHighestScore;
	}

	// PUBLIC SETTERS
	global DataFinderApi setConfKey(String aKey) {
		payloadDataConfig.put(CONF_KEY, aKey);
		return this;
	}

	global DataFinderApi setSObject(SObject pObject) {
		aObject = pObject;
		return this;
	}

	global DataFinderApi doAppend() {
		if (dataResponse == null) {
			return this;
		}
		DFResposneObj response = getResponseObj(dataResponse);
		// valid response with NO errors
		if (isValidResponse(response)) {
			if (aObject.getSObjectType() == Schema.Account.getSObjectType()) {
				Account aAccount = (Account) aObject;
				aAccount.DF_Append_Run__c = true;
				aAccount.DF_Append_Run_Date__c = System.now();
				// response has results
				if (hasResultsResponse(response)) {
					Map<String, Double> emailsWithScore = getAllEmailsFromResponseObj(response);
					String highScoreEmail = getHighestMatchEmail(emailsWithScore);
					// email in response is not empty => overwrite email
					if (String.isNotBlank(highScoreEmail)) {
						aAccount.DF_Append_Success__c = true;
						aAccount.DF_Email__c = aAccount.PersonEmail;
						aAccount.PersonEmail = highScoreEmail;
						aAccount.DF_Match_Probability__c = emailsWithScore.get(highScoreEmail);
					}
				}
			}
		}

		return this;
	}

	// PUBLIC GETTERS
	global String getFullApiUrl() {
		return getApiUrl() + createRequestBody();
	}

	global String getApiUrl() {
		return apiUrl;
	}

	global SObject getAppendedObject() {
		return aObject;
	}

	global List<String> getRawLogs() {
		List<String> result = new List<String>();
		result.add(rawGetResponse);
		return result;
	}

	global Log__c getLogs() {
		Log__c logRecord = new Log__c(
			Event_Type__c = 'DataFinder Append',
			Event_Status__c = (rawGetResponseCode == 200) ? 'Success' : 'Error',
			Event_Endpoint__c = createRequestBody().abbreviate(255),
			Event_Description__c = rawGetResponse
		);
		if (aObject.getSObjectType() == Schema.Account.getSObjectType()) {
			logRecord.Account__c = (aObject != null) ? aObject.Id : null;
		}
		if (aObject.getSObjectType() == Schema.Lead.getSObjectType()) {
			logRecord.Lead__c = (aObject != null) ? aObject.Id : null;
		}
		return logRecord;
	}

	public String createRequestBody() {
		PageReference result = new PageReference('');
		//required param on all requests
		for (String aKey : payloadDataConfig.keySet()) {
			result.getParameters().put(aKey, payloadDataConfig.get(aKey));
		}
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
		
		//if object is account
		if (aObject.getSObjectType() == Schema.Account.getSObjectType()) {
			Account aAccount = (Account) aObject;
			//account data fields
			if (!String.isBlank(aAccount.FirstName)) {
				result.getParameters().put('d_first', aAccount.FirstName);
			}
			if (!String.isBlank(aAccount.LastName)) {
				result.getParameters().put('d_last', aAccount.LastName);
			}
			if (!String.isBlank(aAccount.BillingStreet)) {
				result.getParameters().put('d_fulladdr', aAccount.BillingStreet);
			}
			if (!String.isBlank(aAccount.BillingCity)) {
				result.getParameters().put('d_city', aAccount.BillingCity);
			}
			if (TouchCRHelper.isSCPEnabled() && !String.isBlank((String)aAccount.get('BillingStateCode'))) {
				result.getParameters().put('d_state', (String)aAccount.get('BillingStateCode'));
			}
			if (!String.isBlank(aAccount.BillingPostalCode)) {
				// submit only 5 digits
				result.getParameters().put('d_zip', aAccount.BillingPostalCode.left(5));
			}
			if (!String.isBlank(aAccount.Phone) && aAccount.Phone.length() == 10) {
				result.getParameters().put('d_phone', aAccount.Phone);
			}
		}

		return result.getUrl();
	}

	// DATAFINDER API DTO
	public class DFResposne {
		public DFResposneObj datafinder { get; set; }
	}

	public class DFResposneObj {
		// replaced from num-results
		public Integer num_results { get; set; }

		public List<DFResposneResults> results { get; set; }
		public List<String> errors { get; set; }
	}

	public class DFResposneResults {
		public String EmailAddr { get; set; }

		public Double RawScore { get; set; }
		public String RawMatchCodes { get; set; }
	}

}