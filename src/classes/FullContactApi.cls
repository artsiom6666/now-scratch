public with sharing class FullContactApi {

	// LOG STATUS MESSAGES
	public static String SUCCESS_MESSAGE = 'Success';
	public static String ERROR_MESSAGE = 'Error';

	public static String EVENT_TYPE_SINGLE = 'FullContact-ManualAppend';
	public static String EVENT_TYPE_BATCH = 'FullContact-Batch';

	private String apiUrl;
	private SObject aObject;

	private String rawResponse;

	private Integer rawResponseCode;

	private Map<String, Object> response = new Map<String, Object>();
	private FullContactDTO.FullContactSettings settings = new FullContactDTO.FullContactSettings();
	private FullContactDTO.FullContactResponse responseS = new FullContactDTO.FullContactResponse();

	//Get stormpath credentials
	private Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();

	// CONSTRUCTOR
	public FullContactApi(String endpoint) {
		this();
		this.apiUrl = endpoint;
	}

	public FullContactApi() {
		this.settings = TouchCRConfigurationController.initSettingsFC();
		this.apiUrl = 'callout:TouchCRBase__FullContact';
	}

	private String getEmail(String emailStr) {
		return (String.isBlank(emailStr)) ? null : emailStr;
	}

	private String createParamString() {
		PageReference result = new PageReference('');

		if (this.apiUrl != 'callout:TouchCRBase__FullContact') {
			if (this.settingsMap.containsKey('Endpoint.ClientId') && this.settingsMap.containsKey('Endpoint.ClientSecret')) {
				TouchCR_Settings__c clientId = this.settingsMap.get('Endpoint.ClientId');
				TouchCR_Settings__c clientSecret = this.settingsMap.get('Endpoint.ClientSecret');
				result.getParameters().put('spApiKeyId', clientId.Value__c);
				result.getParameters().put('spApiKeySecret', ClientSecret.Value__c);
			}
		}

		//if object is lead
		if (aObject.getSObjectType() == Schema.Lead.getSObjectType()) {
			Lead aLead = (Lead) aObject;
			//lead data fields
			if (!String.isBlank(getEmail(aLead.Email))) {
				result.getParameters().put('email', aLead.Email);
			}
		}
		//if object is account
		if (aObject.getSObjectType() == Schema.Account.getSObjectType()) {
			Account aAccount = (Account) aObject;
			//account data fields
			if (!String.isBlank(getEmail(aAccount.PersonEmail))) {
				result.getParameters().put('email', aAccount.PersonEmail);
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
			if (this.apiUrl != 'callout:TouchCRBase__FullContact') {
				if (this.settingsMap.containsKey('Endpoint.TokenType') && this.settingsMap.containsKey('Endpoint.TokenPart1') && this.settingsMap.containsKey('Endpoint.TokenPart2')) {
					TouchCR_Settings__c tokenType = this.settingsMap.get('Endpoint.TokenType');
					TouchCR_Settings__c tokenPart1 = this.settingsMap.get('Endpoint.TokenPart1');
					TouchCR_Settings__c tokenPart2 = this.settingsMap.get('Endpoint.TokenPart2');
					tokenPart1.Value__c = (tokenPart1.Value__c == null) ? '' : tokenPart1.Value__c;
					tokenPart2.Value__c = (tokenPart2.Value__c == null) ? '' : tokenPart2.Value__c;
					request.setHeader('Authorization', tokenType.Value__c.capitalize() + ' ' + tokenPart1.Value__c + tokenPart2.Value__c);				
				}				
			}
			request.setHeader('X-FullContact-APIKey', this.settings.apiKey);
				
			//request.setTimeout(timeout);
			Http http = new Http();
			HTTPResponse response = http.send(request);
			String responseBody = response.getBody();

			this.rawResponse = responseBody;

			this.rawResponseCode = response.getStatusCode();

			//generic response
			this.response = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
			//parsed reaponse
			this.responseS = (FullContactDTO.FullContactResponse) JSON.deserialize(responseBody, FullContactDTO.FullContactResponse.class);
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

	public SObject appendData() {
		Map<String, TouchCR_Settings__c> personFCApprovedSettings = TouchCRConfigurationController.getSettings(TouchCRConfigurationController.FULLCONTACT_APPROVED_SETTING.keySet());
		Boolean appendSocialProfiles = personFCApprovedSettings.get('FullContact.AppendSocialProfiles').Value__c != null ? Boolean.valueOf(personFCApprovedSettings.get('FullContact.AppendSocialProfiles').Value__c) : false;
		//we have valid response
		if (getStatus() == 200) {
			//LEAD
			if (aObject.getSObjectType() == Schema.Lead.getSObjectType()) {
				Lead aLead = (Lead) aObject;

				if (appendSocialProfiles || Test.isRunningTest()) {
					collectData(null, aLead.id);
				}
				//append datetime and status
				aLead.Social_Append_Success__c = true;
				aLead.Social_Append_Run_Date__c = System.now();
			}


			//ACCOUNT
			if (aObject.getSObjectType() == Schema.Account.getSObjectType()) {
				Account aAccount = (Account) aObject;

				if (appendSocialProfiles || Test.isRunningTest()) {
					collectData(aAccount.id, null);
				}
				//append datetime and status
				aAccount.Social_Append_Success__c = true;
				aAccount.Social_Append_Run_Date__c = System.now();
			}
		} 

		return aObject;
	}

	public void collectData(Id accountId, Id leadId) {
		if (responseS.socialProfiles != null) {
			List<Social_Profile__c> socialProfilesToInsert = new List<Social_Profile__c>();
			List<FullContactDTO.FullContactSocialProfiles> socialProfiles = responseS.socialProfiles;

			for (integer i=0 ; i<socialProfiles.size(); i++) {
				Social_Profile__c socialProfile = new Social_Profile__c();

				if (socialProfiles[i].bio != null) {
					socialProfile.Bio__c = socialProfiles[i].bio;
				}
				if (socialProfiles[i].followers != null) {
					socialProfile.Followers__c = socialProfiles[i].followers;
				}
				if (socialProfiles[i].following != null) {
					socialProfile.Following__c = socialProfiles[i].following;
				}
				if (socialProfiles[i].type != null) {
					socialProfile.Type__c = socialProfiles[i].type;
				}
				if (socialProfiles[i].typeName != null) {
					socialProfile.Type_Name__c = socialProfiles[i].typeName;
				}
				if (socialProfiles[i].url != null) {
					socialProfile.Url__c = socialProfiles[i].url;
				}
				if (socialProfiles[i].username != null) {
					socialProfile.Username__c = socialProfiles[i].username;
				}
				if (accountId != null) {
					socialProfile.Account__c = accountId;
				}
				if (leadId != null) {
					socialProfile.Lead__c = leadId;
				}
				socialProfilesToInsert.add(socialProfile);
			}

			List<Social_Profile__c> socialProfilesToDelete = new List<Social_Profile__c>();
			if (accountId != null) {
				socialProfilesToDelete = [SELECT Id FROM Social_Profile__c WHERE Account__c =: accountId];
			}
			if (leadId != null) {
				socialProfilesToDelete = [SELECT Id FROM Social_Profile__c WHERE Lead__c =: leadId];
			}

				if (!socialProfilesToDelete.isEmpty()) {
					try {
						SFDCAccessController.DeleteWithoutSharing (
							socialProfilesToDelete,
							'FullContactApi.cls [collectData]'
						);
					} catch (Exception e) {throw new SFDCAccessControlException();}
				}

			if (!socialProfilesToInsert.isEmpty()) {
				try {
					SFDCAccessController.InsertWithoutSharing (
						socialProfilesToInsert,
						'FullContactApi.cls [collectData]',
						new List<Schema.DescribeFieldResult> {
							Social_Profile__c.Bio__c.getDescribe(),
							Social_Profile__c.Followers__c.getDescribe(),
							Social_Profile__c.Following__c.getDescribe(),
							Social_Profile__c.Type__c.getDescribe(),
							Social_Profile__c.Type_Name__c.getDescribe(),
							Social_Profile__c.Url__c.getDescribe(),
							Social_Profile__c.Username__c.getDescribe(),
							Social_Profile__c.Account__c.getDescribe(),
							Social_Profile__c.Lead__c.getDescribe()
						}
					);
				}
				catch (Exception e) {throw new SFDCAccessControlException();}
			}
		}
	}



	// RESPONSE GETTERS
	public Integer getHttpStatusCode() {
		return rawResponseCode;
	}

	public String getHttpStatus() {
		return (getHttpStatusCode() == 200) ? SUCCESS_MESSAGE : ERROR_MESSAGE;
	}

	public Integer getStatus() {
		return responseS.status;
	}

	public FullContactDTO.FullContactContactInfo getContactInfoResponse() {
		return responseS.contactInfo;
	}

	public FullContactDTO.FullContactDemographics getDemographicsResponse() {
		return responseS.demographics;
	}

	public List<FullContactDTO.FullContactOrganizations> getOrganizationsResponse() {
		return responseS.organizations;
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