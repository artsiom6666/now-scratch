public with sharing class TowerDataApiDemo {

	public static final Integer DEFAULT_TIMEOUT = 5000;

	public static final String SUCCESS_MESSAGE = TowerDataApi.SUCCESS_MESSAGE;
	public static final String ERROR_MESSAGE = TowerDataApi.ERROR_MESSAGE;

	public static final String EVENT_TYPE_SINGLE = 'Demo-ManualAppend';
	public static final String EVENT_TYPE_BATCH = 'Demo-Batch';

	private String apiUrl;
	private SObject aObject;

	private String rawResponse;
	private Integer rawResponseCode;
	private Map<String, Object> response = new Map<String, Object>();
	private TowerDataDTO.TowerDataSettings settings = new TowerDataDTO.TowerDataSettings();
	private TowerDataDTO.TowerDataResponseDemo responseS = new TowerDataDTO.TowerDataResponseDemo();

	//Get stormpath credentials
	private Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();


	// CONSTRUCTOR
	public TowerDataApiDemo(String endpoint) {
		this();
		this.apiUrl = endpoint;
	}

	public TowerDataApiDemo() {
		this.settings = TouchCRConfigurationController.initSettings();
		this.apiUrl = 'callout:TouchCRBase__TowerDataDemo';
	}

	private String createParamString() {
		PageReference result = new PageReference('');
		//required param on all requests
		result.getParameters().put('api_key', settings.demokey);
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
				result.getParameters().put('first', aLead.FirstName);
			}
			if (!String.isBlank(aLead.LastName)) {
				result.getParameters().put('last', aLead.LastName);
			}
			if (!String.isBlank(aLead.Street)) {
				result.getParameters().put('street', aLead.Street);
			}
			if (!String.isBlank(aLead.City)) {
				result.getParameters().put('city', aLead.City);
			}
			if (TouchCRHelper.isSCPEnabled() && !String.isBlank((String)aLead.get('StateCode'))) {
				result.getParameters().put('state', (String)aLead.get('StateCode'));
			}
			if (!String.isBlank(aLead.PostalCode)) {
				result.getParameters().put('zip4', aLead.PostalCode);
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
				result.getParameters().put('first', aAccount.FirstName);
			}
			if (!String.isBlank(aAccount.LastName)) {
				result.getParameters().put('last', aAccount.LastName);
			}
			if (!String.isBlank(aAccount.BillingStreet)) {
				result.getParameters().put('street', aAccount.BillingStreet);
			}
			if (!String.isBlank(aAccount.BillingCity)) {
				result.getParameters().put('city', aAccount.BillingCity);
			}
			if (TouchCRHelper.isSCPEnabled() && !String.isBlank((String)aAccount.get('BillingStateCode'))) {
				result.getParameters().put('state', (String)aAccount.get('BillingStateCode'));
			}
			if (!String.isBlank(aAccount.BillingPostalCode)) {
				result.getParameters().put('zip4', aAccount.BillingPostalCode);
			}
		}

		return result.getUrl();
	}

	private String getEmail(String emailStr) {
		return (String.isBlank(emailStr)) ? null : emailStr;
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
			this.rawResponseCode = response.getStatusCode();
			this.rawResponse = responseBody;
			//generic response
			this.response = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
			//parsed reaponse
			this.responseS = (TowerDataDTO.TowerDataResponseDemo) JSON.deserialize(responseBody, TowerDataDTO.TowerDataResponseDemo.class);
			//update token
			if (response.getHeader('Access-Token') != null) {
				TouchCRHelper.setAuthCredentinals(response.getHeader('Access-Token'));
			}
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
			Event_Type__c = (System.isBatch()) ? EVENT_TYPE_BATCH : EVENT_TYPE_SINGLE,
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
		if (getHttpStatusCode() == 200) {
			//LEAD
			if (aObject.getSObjectType() == Schema.Lead.getSObjectType()) {
				Lead aLead = (Lead) aObject;
				TowerDataDTO.TowerDataResponseDemo demoResponse = getDemoResponse();
				if (demoResponse != null) {
					//BASIC AND EAM
					if (settings.leadAppendDemoBasic) {
						aLead.Append_Demo_Age__c = demoResponse.age;
						aLead.Append_Demo_Gender__c = demoResponse.gender;
						aLead.Append_Demo_Zip__c = demoResponse.zip;
						aLead.Append_Demo_Education__c = demoResponse.education;
						aLead.Append_Demo_Net_Worth__c = demoResponse.net_worth;
					}
					//HOUSING
					if (settings.leadAppendDemoHousing) {
						aLead.Append_House_Value__c = demoResponse.home_market_value;
						aLead.Append_House_Owner_Status__c = demoResponse.home_owner_status;
						aLead.Append_House_Income__c = demoResponse.household_income;
						aLead.Append_House_Length_of_Residence__c = demoResponse.length_of_residence;
						aLead.Append_House_Marital_Status__c = demoResponse.marital_status;
						aLead.Append_House_Occupation__c = demoResponse.occupation;
						aLead.Append_House_Children__c = demoResponse.presence_of_children;
					}
					//EAM
					TowerDataDTO.TowerDataResponseDemoEam eamResponse = getEamResponse();
					if (eamResponse != null) {
						if (settings.leadAppendEam) {
							aLead.EAM_Date_First_Seen__c = eamResponse.date_first_seen;
							aLead.EAM_Velocity__c = eamResponse.velocity;
							aLead.EAM_Popularity__c = eamResponse.popularity;
							aLead.EAM_Month_Last_Opened__c = eamResponse.month_last_open;
						}
					}
					TowerDataDTO.TowerDataResponseDemoInterests interestsResponse = getInterestsResponse();
					if (interestsResponse != null) {
						//INTERESTS
						if (settings.leadAppendDemoInterest) {
							aLead.Append_Interest_Arts_Craft__c = interestsResponse.arts_and_crafts;
							aLead.Append_Interest_Blogging__c = interestsResponse.blogging;
							aLead.Append_Interest_Books__c = interestsResponse.books;
							aLead.Append_Interest_Business__c = interestsResponse.business;
							aLead.Append_Interest_Health_Wellness__c = interestsResponse.health_and_wellness;
							aLead.Append_Interest_News_Current_Affairs__c = interestsResponse.news_and_current_events;
						}
						//PURCHASE
						if (settings.leadAppendDemoPurchase) {
							aLead.Append_Purchase_Automotive__c = interestsResponse.automotive;
							aLead.Append_Purchase_Baby_Product_Buyer__c = interestsResponse.baby_product_buyer;
							aLead.Append_Purchase_Beauty__c = interestsResponse.beauty;
							aLead.Append_Purchase_Charitable_Doner__c = interestsResponse.charitable_donors;
							aLead.Append_Purchase_Cooking__c = interestsResponse.cooking;
							aLead.Append_Purchase_Discount_Shopper__c = interestsResponse.discount_shopper;
							aLead.Append_Purchase_High_End_Brand_Buyer__c = interestsResponse.high_end_brand_buyer;
							aLead.Append_Purchase_Home_Garden__c = interestsResponse.home_and_garden;
							aLead.Append_Purchase_Home_Improvement__c = interestsResponse.home_improvement;
							aLead.Append_Purchase_Luxury_Goods_Jewelry__c = interestsResponse.luxury_goods;
							aLead.Append_Purchase_Magazine_Buyer__c = interestsResponse.magazine_buyer;
							aLead.Append_Purchase_Outdoor_Adventure__c = interestsResponse.outdoor_and_adventure;
							aLead.Append_Purchase_Pets__c = interestsResponse.pets;
							aLead.Append_Purchase_Sports__c = interestsResponse.sports;
							aLead.Append_Purchase_Technology__c = interestsResponse.technology;
							aLead.Append_Purchase_Travel__c = interestsResponse.travel;
						}
					} //interests and purchase
				} // demo response

			} // lead
			//ACCOUNT
			if (aObject.getSObjectType() == Schema.Account.getSObjectType()) {
				Account aAccount = (Account) aObject;
				TowerDataDTO.TowerDataResponseDemo demoResponse = getDemoResponse();
				if (demoResponse != null) {
					//BASIC AND EAM
					if (settings.accountAppendDemoBasic) {
						aAccount.Append_Demo_Age__c = demoResponse.age;
						aAccount.Append_Demo_Gender__c = demoResponse.gender;
						aAccount.Append_Demo_Zip__c = demoResponse.zip;
						aAccount.Append_Demo_Education__c = demoResponse.education;
						aAccount.Append_Demo_Net_Worth__c = demoResponse.net_worth;

					}
					//HOUSING
					if (settings.accountAppendDemoHousing) {
						aAccount.Append_House_Value__c = demoResponse.home_market_value;
						aAccount.Append_House_Owner_Status__c = demoResponse.home_owner_status;
						aAccount.Append_House_Income__c = demoResponse.household_income;
						aAccount.Append_House_Length_of_Residence__c = demoResponse.length_of_residence;
						aAccount.Append_House_Marital_Status__c = demoResponse.marital_status;
						aAccount.Append_House_Occupation__c = demoResponse.occupation;
						aAccount.Append_House_Children__c = demoResponse.presence_of_children;
					}
					//EAM
					TowerDataDTO.TowerDataResponseDemoEam eamResponse = getEamResponse();
					if (eamResponse != null) {
						if (settings.accountAppendEam) {
							aAccount.EAM_Date_First_Seen__c = eamResponse.date_first_seen;
							aAccount.EAM_Velocity__c = eamResponse.velocity;
							aAccount.EAM_Popularity__c = eamResponse.popularity;
							aAccount.EAM_Month_Last_Opened__c = eamResponse.month_last_open;
						}
					}
					TowerDataDTO.TowerDataResponseDemoInterests interestsResponse = getInterestsResponse();
					if (interestsResponse != null) {
						//INTERESTS
						if (settings.accountAppendDemoInterest) {
							aAccount.Append_Interest_Arts_Craft__c = interestsResponse.arts_and_crafts;
							aAccount.Append_Interest_Blogging__c = interestsResponse.blogging;
							aAccount.Append_Interest_Books__c = interestsResponse.books;
							aAccount.Append_Interest_Business__c = interestsResponse.business;
							aAccount.Append_Interest_Health_Wellness__c = interestsResponse.health_and_wellness;
							aAccount.Append_Interest_News_Current_Affairs__c = interestsResponse.news_and_current_events;
						}
						//PURCHASE
						if (settings.accountAppendDemoPurchase) {
							aAccount.Append_Purchase_Automotive__c = interestsResponse.automotive;
							aAccount.Append_Purchase_Baby_Product_Buyer__c = interestsResponse.baby_product_buyer;
							aAccount.Append_Purchase_Beauty__c = interestsResponse.beauty;
							aAccount.Append_Purchase_Charitable_Doner__c = interestsResponse.charitable_donors;
							aAccount.Append_Purchase_Cooking__c = interestsResponse.cooking;
							aAccount.Append_Purchase_Discount_Shopper__c = interestsResponse.discount_shopper;
							aAccount.Append_Purchase_High_End_Brand_Buyer__c = interestsResponse.high_end_brand_buyer;
							aAccount.Append_Purchase_Home_Garden__c = interestsResponse.home_and_garden;
							aAccount.Append_Purchase_Home_Improvement__c = interestsResponse.home_improvement;
							aAccount.Append_Purchase_Luxury_Goods_Jewelry__c = interestsResponse.luxury_goods;
							aAccount.Append_Purchase_Magazine_Buyer__c = interestsResponse.magazine_buyer;
							aAccount.Append_Purchase_Outdoor_Adventure__c = interestsResponse.outdoor_and_adventure;
							aAccount.Append_Purchase_Pets__c = interestsResponse.pets;
							aAccount.Append_Purchase_Sports__c = interestsResponse.sports;
							aAccount.Append_Purchase_Technology__c = interestsResponse.technology;
							aAccount.Append_Purchase_Travel__c = interestsResponse.travel;
						}
					} //interests and purchase
				} // demo response
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

	public TowerDataDTO.TowerDataResponseDemo getDemoResponse() {
		return responseS;
	}

	public TowerDataDTO.TowerDataResponseDemoInterests getInterestsResponse() {
		return responseS.interests;
	}

	public TowerDataDTO.TowerDataResponseDemoEam getEamResponse() {
		return responseS.eam;
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