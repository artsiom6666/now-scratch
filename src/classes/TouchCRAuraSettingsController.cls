public class TouchCRAuraSettingsController {

	// User types for external users
	public static final List<String> portalUserLicensesTypes = new List<String> {'PID_Customer_Community_Login', 'PID_Customer_Community_Plus_Login', 'PID_Customer_Community_Plus', 'PID_Customer_Community', 'PID_External_Identity'};

	@auraEnabled
	public static String getServices() {

		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');

		String endpoint = 'callout:TouchCRBase__SecureProxy/supportedServices?v=2';
		if (settingsMap.containsKey('Endpoint.ClientId') && settingsMap.containsKey('Endpoint.ClientSecret')) {
			endpoint += '&spApiKeyId=' + settingsMap.get('Endpoint.ClientId');
			endpoint += '&spApiKeySecret=' + settingsMap.get('Endpoint.ClientSecret');
		}

		HttpRequest req = new HttpRequest();

		req.setEndpoint(endpoint);
		req.setMethod('GET');
		Http http = new Http();
		AccessWrapper access = new AccessWrapper();
		access.isErrorGetServices = true;
		access.isAbleAffiliate = TouchCRHelper.isAffiliateEnabled();
		access.isAbleFranchisee = TouchCRHelper.isFranchiseeEnabled();
		access.isAbleMinfraud = false;
		access.isAbleUsps = false;
		access.isAbleDataAppend = false;
		//		access.isAbleFullContact = false;
		try {
			HTTPResponse res = http.send(req);

			//update token
			if (res.getHeader('Access-Token') != null) {
				TouchCRHelper.setAuthCredentinals(res.getHeader('Access-Token'));
			}

			Map<String, String> availableServices = (Map<String, String>) JSON.deserialize(res.getBody(), Map<String, String>.class);
			if (availableServices.containsKey('fraudDetect')) {
				access.isAbleMinfraud = true;
			}

			if (availableServices.containsKey('shipping')) {
				access.isAbleUsps = true;
			}

			if (availableServices.containsKey('person') && availableServices.containsKey('emailCheck')) {
				access.isAbleDataAppend = true;
			}

			if (availableServices.containsKey('fullContact')) {
				access.isAbleFullContact = true;
			}

			access.isErrorGetServices = false;
			return JSON.serialize(access);
		}
		catch(Exception ex) {
			return JSON.serialize(access);
		}

	}

	public class AccessWrapper {
		public Boolean isAbleMinfraud { get; set; }
		public Boolean isAbleUsps { get; set; }
		public Boolean isAbleDataAppend { get; set; }
		public Boolean isAbleFullContact { get; set; }
		public Boolean isAbleAffiliate{ get; set; }
		public Boolean isAbleFranchisee { get; set; }
		public Boolean isErrorGetServices { get; set; }
	}

// PaymentAgentBrandSelection

	// BRANDS settings
	public static final String BRAND_SETTINGS_PREFIX = 'B.';
	public static final String COMMUNITY_SETTINGS_PREFIX = 'C.';
	public static final String GATEWAYS_SETTINGS_PREFIX = 'D.';
	public static final String GOOGLE_SETTINGS_PREFIX = 'GA.';

	@auraEnabled
	public static String getPaymentSettingsApex() {

		return JSON.serialize(getPaymentSettings());
	}

	@auraEnabled
	public static String getPaymentOptions() {

		List<PaymentOptionsWrapper> paymentOptions = new List<PaymentOptionsWrapper>();
		List<Map<String, String>> paymentAgents = TouchCRHelper.getCustomSettings('TouchCRBase__Payment_Agents__c');

		for (Map<String, String> itemPaymentAgents : paymentAgents) {
			if (Boolean.valueOf(itemPaymentAgents.get('TouchCRBase__Active__c'))) {
				PaymentOptionsWrapper paymentOption = new PaymentOptionsWrapper();
				paymentOption.key = itemPaymentAgents.get('Id');
				paymentOption.value = itemPaymentAgents.get('Name');

				paymentOptions.add(paymentOption);
			}
		}

		return JSON.serialize(paymentOptions);
	}

	@auraEnabled
	public static String getPaymentProfOptions() {

		List<PaymentOptionsWrapper> profOptions = new List<PaymentOptionsWrapper>();

		Map<String, Id> allProfileValue = getPaymentNameToProfileIdForBrand();
		if (Test.isRunningTest()) {
			allProfileValue.put('Customer Community Login User', '00e41000000fIH8AAM');
		}

		for (String item : allProfileValue.keySet()) {
			PaymentOptionsWrapper profOption = new PaymentOptionsWrapper();
			profOption.key = allProfileValue.get(item);
			profOption.value = item;

			profOptions.add(profOption);
		}

		return JSON.serialize(profOptions);
	}

	@auraEnabled
	public static String savePaymentSettings(String settings) {

		PaymentSettingsWrapper settingsDeserialized = (PaymentSettingsWrapper)JSON.deserialize(settings, PaymentSettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();

		//Settings for BRANDS
		Map<String, String> allBrandSettings = getPaymentBrandSettings();

		String newNameSetting = allBrandSettings.get(settingsDeserialized.brandSetting);
		if (newNameSetting != String.valueOf(settingsDeserialized.status)) {
			newNameSetting = String.valueOf(settingsDeserialized.status);
			settingsToUpsert.put(settingsDeserialized.brandSetting, newNameSetting);
		}
		String newCommSetting = allBrandSettings.get(settingsDeserialized.commSetting);
		if (newCommSetting != settingsDeserialized.commValue) {
			newCommSetting = settingsDeserialized.commValue;
			settingsToUpsert.put(settingsDeserialized.commSetting, newCommSetting);
		}
		String newGatewaySetting = allBrandSettings.get(settingsDeserialized.gatewaySetting);
		if (newGatewaySetting != settingsDeserialized.gatewayId) {
			newGatewaySetting = settingsDeserialized.gatewayId;
			settingsToUpsert.put(settingsDeserialized.gatewaySetting, newGatewaySetting);
		}
		String newGoogleSetting = allBrandSettings.get(settingsDeserialized.googleSetting);
		if (newGoogleSetting != settingsDeserialized.googleValue) {
			newGoogleSetting = settingsDeserialized.googleValue;
			settingsToUpsert.put(settingsDeserialized.googleSetting, newGoogleSetting);
		}

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'Organization has been successfully saved!';
		} else {
			return 'Error! ';
		}
	}

	@auraEnabled
	public static String getPaymentConnectSettingsApex() {
		return ExtensionsHelperDummy.getPaymentConnectSettings();
	}

	@auraEnabled
	public static String saveStripeConnect(String settings) {
		return ExtensionsHelperDummy.saveStripeConnect(settings);
	}

	private static List<PaymentSettingsWrapper> getPaymentSettings() {
		Map<String, Map<String, String>> allBrandValuesMap = getPaymentAllBrandValues();
		Map<String, String> allBrandSettings = getPaymentBrandSettings();
		List<PaymentSettingsWrapper> brandSettings = new List<PaymentSettingsWrapper>();

		for (String brandKey : allBrandValuesMap.keySet()) {
			String brandSetting = allBrandSettings.get(allBrandValuesMap.get(brandKey).get(BRAND_SETTINGS_PREFIX));
			String commSetting = allBrandSettings.get(allBrandValuesMap.get(brandKey).get(COMMUNITY_SETTINGS_PREFIX));
			String gatewaySetting = allBrandSettings.get(allBrandValuesMap.get(brandKey).get(GATEWAYS_SETTINGS_PREFIX));
			String googleSetting = allBrandSettings.get(allBrandValuesMap.get(brandKey).get(GOOGLE_SETTINGS_PREFIX));
			brandSettings.add(new PaymentSettingsWrapper(
					brandKey,
					allBrandValuesMap.get(brandKey).get(BRAND_SETTINGS_PREFIX), brandSetting,
					allBrandValuesMap.get(brandKey).get(COMMUNITY_SETTINGS_PREFIX), commSetting,
					allBrandValuesMap.get(brandKey).get(GATEWAYS_SETTINGS_PREFIX), gatewaySetting,
					allBrandValuesMap.get(brandKey).get(GOOGLE_SETTINGS_PREFIX), googleSetting
			));
		}

		return brandSettings;
	}

	// method return map of all picklist values
	// the value in this map will be map
	// key - prefix and value - is brand value WITH a prefix
	private static Map<String, Map<String, String>> getPaymentAllBrandValues() {
		Map<String, Map<String, String>> result = new Map<String, Map<String, String>>();
		Schema.DescribeFieldResult fieldResult = Account.Brand_Assortment__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		for (Schema.PicklistEntry f : ple) {
			if (f.isActive()) {
				String value = f.getValue().abbreviate(33);
				result.put(f.getLabel(), new Map<String, String>{
				BRAND_SETTINGS_PREFIX => BRAND_SETTINGS_PREFIX + value,
				COMMUNITY_SETTINGS_PREFIX => COMMUNITY_SETTINGS_PREFIX + value,
				GATEWAYS_SETTINGS_PREFIX => GATEWAYS_SETTINGS_PREFIX + value,
				GOOGLE_SETTINGS_PREFIX => GOOGLE_SETTINGS_PREFIX + value
				});
			}
		}
		return result;
	}

	private static Map<String, String> getPaymentBrandSettings() {
		return getPaymentSettingsForBrandPLValues(getPaymentAllBrandValues().keySet());
	}

	// returns custom settings according to active brands picklist values
	private static Map<String, String> getPaymentSettingsForBrandPLValues(Set<String> brands) {
		//get all settings
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		Map<String, Map<String, String>> allBrandValuesMap = getPaymentAllBrandValues();
		Map<String, Id> allProfMap = getPaymentNameToProfileIdForBrand();

		for (String settingKey : brands) {
			Map<String, String> settingsNameMap = allBrandValuesMap.get(settingKey);
			for (String item : settingsNameMap.values()) {
				if (settingsMap.containsKey(item)) {
					result.put(item, settingsMap.get(item));
				}
				else {
					//create setting with the default 'Customer Community Login User' Profile
					if (allProfMap.containsKey('Customer Community Login User') && item.contains(COMMUNITY_SETTINGS_PREFIX + '.')) {
						result.put(item, String.valueOf(allProfMap.get('Customer Community Login User')));
					}
					else {
						result.put(item, '');
					}
				}
			}
		}
		return result;
	}

	private static Map<String, Id> getPaymentNameToProfileIdForBrand() {
		Map<String, Id> result = new Map<String, Id>();
		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'Profile',
					'PaymentAgentBrandController.cls [getNameToProfileIdForBrand]',
					new List<Schema.DescribeFieldResult> {
							Profile.Name.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'UserLicense',
					'PaymentAgentBrandController.cls [getNameToProfileIdForBrand]',
					new List<Schema.DescribeFieldResult> {
							UserLicense.Name.getDescribe()
							}
			);
			List<Profile> profList = new List<Profile>([
					SELECT Id, Name
					FROM Profile
					WHERE UserLicense.LicenseDefinitionKey IN :portalUserLicensesTypes
					LIMIT 100
			]);
			for (Profile profileItem : profList) {
				result.put(profileItem.Name, profileItem.Id);
			}
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
		return result;
	}


	public class PaymentOptionsWrapper {
		protected String key { get; set; }
		protected String value { get; set; }
	}

	public class PaymentSettingsWrapper {
		protected String name { get; set; }
		protected String brandSetting { get; set; }
		protected String commSetting { get; set; }
		protected String gatewaySetting { get; set; }
		protected String commValue { get; set; }
		protected String gatewayId { get; set; }
		protected String googleSetting { get; set; }
		protected String googleValue { get; set; }
		protected Boolean status { get; set; }

		public PaymentSettingsWrapper(String name, String brandSetting, String status, String commSetting, String commValue, String gatewaySetting, String gatewayId, String googleSetting, String googleValue) {
			this.name = name;
			this.brandSetting = brandSetting;
			this.status = Boolean.valueOf(status);
			this.commSetting = commSetting;
			this.commValue = commValue;
			this.gatewaySetting = gatewaySetting;
			this.gatewayId = gatewayId;
			this.googleSetting = googleSetting;
			this.googleValue = googleValue;
		}
	}

// MinFraudSettings

	// MINFRAUD settings
	public static final Map<String, String> MINFRAUD_SETTING = new Map<String, String> {
		'MinFraud.ApiKey' => 'ApiKey',
		'MinFraud.RatingFirst' => 'First Rating',
		'MinFraud.RatingSecond' => 'Second Rating'
	};

	public static Map<String, String> getMinFraudSettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}

	@auraEnabled
	public static String getMinFraudSettingsApex() {
		return JSON.serialize(getMinFraudSettings(MINFRAUD_SETTING.keySet()));
	}


	@auraEnabled
	public static String saveMinFraud(String settings) {

		MinFraudSettingsWrapper settingsDeserialized = (MinFraudSettingsWrapper)JSON.deserialize(settings, MinFraudSettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();

		Map<String, String> minFraudSettings = getMinFraudSettings(MINFRAUD_SETTING.keySet());


		if (minFraudSettings.get('MinFraud.ApiKey') != settingsDeserialized.apiKey) {
			String newApiKeySetting = minFraudSettings.get('MinFraud.ApiKey');
			newApiKeySetting = settingsDeserialized.apiKey;
			settingsToUpsert.put('MinFraud.ApiKey', newApiKeySetting);
		}

		if (minFraudSettings.get('MinFraud.RatingFirst') != String.valueOf(settingsDeserialized.firstRating)) {
			String newFirstRatingSetting = minFraudSettings.get('MinFraud.RatingFirst');
			newFirstRatingSetting = String.valueOf(settingsDeserialized.firstRating);
			settingsToUpsert.put('MinFraud.RatingFirst', newFirstRatingSetting);
		}

		if (minFraudSettings.get('MinFraud.RatingSecond') != String.valueOf(settingsDeserialized.secondRating)) {
			String newSecondRatingSetting = minFraudSettings.get('MinFraud.RatingSecond');
			newSecondRatingSetting = String.valueOf(settingsDeserialized.secondRating);
			settingsToUpsert.put('MinFraud.RatingSecond', newSecondRatingSetting);
		}

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'MinFraud Settings have been successfully saved!';
		} else {
			return 'Error! ';
		}
	}

	public class MinFraudSettingsWrapper {
		public String apiKey { get; set; }
		public Integer firstRating { get; set; }
		public Integer secondRating { get; set; }
	}

// UspsSettings

	// GLOBAL settings
	public static final Map<String, String> USPSUSER_SETTING = new Map<String, String> {
		'USPS.UserID' => 'USPSUserID'
	};

	public static Map<String, String> getUspsSettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}

	@auraEnabled
	public static String getUspsSettingsApex() {

		return JSON.serialize(getUspsSettings(USPSUSER_SETTING.keySet()));
	}


	@auraEnabled
	public static String saveUsps(String settings) {

		UspsSettingsWrapper settingsDeserialized = (UspsSettingsWrapper)JSON.deserialize(settings, UspsSettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();

		Map<String, String> allUspsUserSettings = getUspsSettings(USPSUSER_SETTING.keySet());


		String settingUspsValue = allUspsUserSettings.get('USPS.UserID');
		settingUspsValue = settingsDeserialized.uspsValue;
		settingsToUpsert.put('USPS.UserID', settingUspsValue);

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'USPS settings have been successfully saved!';
		} else {
			return 'Error! ';
		}
	}

	public class UspsSettingsWrapper {
		public String uspsValue { get; set; }
	}

// TriggerSettings

	public static final Map<String, String> CHARGENT_SETTING = new Map<String, String> {
		'Chargent.OrderUserCreation' => 'Chargent.OrderUserCreation'
	};

	public static Map<String, String> getTriggerSettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}

	@auraEnabled
	public static String getTriggerSettingsApex() {

		return JSON.serialize(getTriggerSettings(CHARGENT_SETTING.keySet()));
	}


	@auraEnabled
	public static String saveTrigger(String settings) {

		TriggerSettingsWrapper settingsDeserialized = (TriggerSettingsWrapper)JSON.deserialize(settings, TriggerSettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();

		Map<String, String> allTriggerSettings = getTriggerSettings(CHARGENT_SETTING.keySet());

		String settingisUserCreation = allTriggerSettings.get('Chargent.OrderUserCreation');
		settingisUserCreation = String.valueOf(settingsDeserialized.isUserCreation);
		settingsToUpsert.put('Chargent.OrderUserCreation', settingisUserCreation);

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'Trigger settings have been successfully saved!';
		} else {
			return 'Error! ';
		}
	}

	public class TriggerSettingsWrapper {
		public Boolean isUserCreation { get; set; }
	}

// ProxySettings

	public static final Map<String, String> PROXY_SETTINGS = new Map<String, String> {
		'Proxy.isEnabled' => 'Proxy Enabled'
	};

	public static Map<String, String> getProxySettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}

	@auraEnabled
	public static String getProxySettingsApex() {

		return JSON.serialize(getProxySettings(PROXY_SETTINGS.keySet()));
	}


	@auraEnabled
	public static String saveProxy(String settings) {

		ProxySettingsWrapper settingsDeserialized = (ProxySettingsWrapper)JSON.deserialize(settings, ProxySettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();

		Map<String, String> allProxySettings = getProxySettings(PROXY_SETTINGS.keySet());

		String settingProxyValue = allProxySettings.get('Proxy.isEnabled');
		settingProxyValue = String.valueOf(settingsDeserialized.isProxyEnabled);
		settingsToUpsert.put('Proxy.isEnabled', settingProxyValue);

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'Proxy settings have been successfully saved!';

		} else {
			return 'Error! ';
		}
	}

	public class ProxySettingsWrapper {
		public Boolean isProxyEnabled { get; set; }
	}

// AuthorizeAura

	//Endpoint settings STRING
	public static final Map<String, String> AUTHORIZE_ENDPOINT_SETTING = new Map<String, String> {
		'Endpoint.ClientId' => '',
		'Endpoint.ClientSecret' => '',
		'Endpoint.TokenType' => '',
		'Endpoint.TokenPart1' => '',
		'Endpoint.TokenPart2' => '',
		'Endpoint.ExpiresIn' => ''
	};
	
	public static Map<String, String> getAuthorizeSettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}
	
	@auraEnabled
	public static Map<String, String> getAuthorizeSettingsApex() {
		Map<String, String> endpointSettings = getAuthorizeSettings(AUTHORIZE_ENDPOINT_SETTING.keySet());
		return endpointSettings;
	}

	@auraEnabled
	public static String linkAuthorizeEndpointToken(String credentials) {

		String tokenTypeEndpoint;
		String tokenPart1Endpoint;
		String tokenPart2Endpoint;
		String expiresInEndpoint;

		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setEndpoint('callout:PaymentEndpoint/oauth/token');
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		req.setHeader('application', 'x-www-form-urlencoded');
		req.setTimeout(120000);

		CredentialsWrapper credentialsDeserialized = (CredentialsWrapper)JSON.deserialize(credentials, CredentialsWrapper.class);

		Blob headerValue = Blob.valueOf(credentialsDeserialized.clientIdEndpoint + ':' + credentialsDeserialized.clientSecretEndpoint);
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);
		req.setBody('grant_type=client_credentials&client_id' + credentialsDeserialized.clientIdEndpoint + '&client_secret=' + credentialsDeserialized.clientSecretEndpoint);
		Http binding = new Http();
		HttpResponse res = binding.send(req);

		if (res.getStatus() == 'OK') {

			String access_token;

			JSONParser parser = JSON.createParser(res.getBody());
			while (parser.nextToken() != null) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					if (parser.getText() == 'access_token') {
						parser.nextToken();
						access_token = parser.getText();
					}
					if (parser.getText() == 'token_type') {
						parser.nextToken();
						tokenTypeEndpoint = parser.getText().capitalize();
					}
					if (parser.getText() == 'expires_in') {
						parser.nextToken();
						expiresInEndpoint = parser.getText();
					}
				}
			}
			//received token is not placed to one setting
			if (access_token.length() > 253) {
				tokenPart1Endpoint = access_token.substring(0, 254);
				tokenPart2Endpoint = access_token.substring(254);
			}
			else {
				tokenPart1Endpoint = access_token;
				tokenPart2Endpoint = '';
			}


			Map<String, String> endpointSettings = getAuthorizeSettings(AUTHORIZE_ENDPOINT_SETTING.keySet());
			Map<String, String> settingsToUpsert = new Map<String, String>();

			String userNameSetting = endpointSettings.get('Endpoint.ClientId');
			userNameSetting = credentialsDeserialized.clientIdEndpoint;
			settingsToUpsert.put('Endpoint.ClientId', userNameSetting);

			String clientSecretSetting = endpointSettings.get('Endpoint.ClientSecret');
			clientSecretSetting = credentialsDeserialized.clientSecretEndpoint;
			settingsToUpsert.put('Endpoint.ClientSecret', clientSecretSetting);

			String tokenTypeSetting = endpointSettings.get('Endpoint.TokenType');
			tokenTypeSetting = tokenTypeEndpoint;
			settingsToUpsert.put('Endpoint.TokenType', tokenTypeSetting);
			
			String tokenPart1Setting = endpointSettings.get('Endpoint.TokenPart1');
			tokenPart1Setting = tokenPart1Endpoint;
			settingsToUpsert.put('Endpoint.TokenPart1', tokenPart1Setting);

			String tokenPart2Setting = endpointSettings.get('Endpoint.TokenPart2');
			tokenPart2Setting = tokenPart2Endpoint;
			settingsToUpsert.put('Endpoint.TokenPart2', tokenPart2Setting);


			String expiresInSetting = endpointSettings.get('Endpoint.ExpiresIn');
			expiresInSetting = expiresInEndpoint;
			settingsToUpsert.put('Endpoint.ExpiresIn', expiresInSetting);

			if (!settingsToUpsert.isEmpty()) {
				TouchCRHelper.setSettings(settingsToUpsert);
				return 'Organization has been successfully linked!';
			}
			else {
				return 'Error!';
			}
		}
		else {
			return 'Error!';
		}
	}

	@auraEnabled
	public static String unlinkAuthorizeEndpointToken() {
		Map<String, String> endpointSettings = getAuthorizeSettings(AUTHORIZE_ENDPOINT_SETTING.keySet());

		Map<String, String> settingsToUpsert = new Map<String, String>();

		String userNameSetting = endpointSettings.get('Endpoint.ClientId');
		userNameSetting = '';
		settingsToUpsert.put('Endpoint.ClientId', userNameSetting);

		String clientSecretSetting = endpointSettings.get('Endpoint.ClientSecret');
		clientSecretSetting = '';
		settingsToUpsert.put('Endpoint.ClientSecret', clientSecretSetting);

		String tokenTypeSetting = endpointSettings.get('Endpoint.TokenType');
		tokenTypeSetting = '';
		settingsToUpsert.put('Endpoint.TokenType', tokenTypeSetting);

		String tokenPart1Setting = endpointSettings.get('Endpoint.TokenPart1');
		tokenPart1Setting = '';
		settingsToUpsert.put('Endpoint.TokenPart1', tokenPart1Setting);

		String tokenPart2Setting = endpointSettings.get('Endpoint.TokenPart2');
		tokenPart2Setting = '';
		settingsToUpsert.put('Endpoint.TokenPart2', tokenPart2Setting);

		String expiresInSetting = endpointSettings.get('Endpoint.ExpiresIn');
		expiresInSetting = '';
		settingsToUpsert.put('Endpoint.ExpiresIn', expiresInSetting);

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'Organization has been successfully unlinked!';
		} else {
			return 'Error!';
		}

	}
	public class CredentialsWrapper {
		protected String clientIdEndpoint { get; set; }
		protected String clientSecretEndpoint { get; set; }
	}

}