@isTest
public class TouchCRAuraSettingsControllerTest {

	static testMethod void test_TouchCRAuraSettingsController() {
		TouchCRAuraSettingsController.AccessWrapper access;

		String resp = '{"collect": "Collect", "datafinder": "Datafinder"}';
		Test.setMock(HttpCalloutMock.class, new TouchCRConfigurationMock(resp));

		Test.startTest();

		access = (TouchCRAuraSettingsController.AccessWrapper)System.JSON.deserialize(TouchCRAuraSettingsController.getServices(), TouchCRAuraSettingsController.AccessWrapper.class);

		System.assertEquals(false, access.isAbleMinfraud);
		System.assertEquals(false, access.isAbleUsps);
		System.assertEquals(false, access.isAbleDataAppend);
		//		System.assertEquals(false, access.isAbleFullContact);

		resp = '{"fraudDetect": "Fraud Detect", "shipping": "Shipping", "person": "Person", "emailCheck": "Email Check", "collect": "Collect", "datafinder": "Datafinder", "fullContact": "FullContact"}';
		Test.setMock(HttpCalloutMock.class, new TouchCRConfigurationMock(resp));

		access = (TouchCRAuraSettingsController.AccessWrapper)System.JSON.deserialize(TouchCRAuraSettingsController.getServices(), TouchCRAuraSettingsController.AccessWrapper.class);

		Test.stopTest();

		System.assertEquals(true, access.isAbleMinfraud);
		System.assertEquals(true, access.isAbleUsps);
		System.assertEquals(true, access.isAbleDataAppend);
		//		System.assertEquals(true, access.isAbleFullContact);
	}

// PaymentAgentBrandSelection

	static testMethod void test_PaymentAgentBrandSelection() {

		/*List<Map<String, String>> newPaymentAgents = new List<Map<String, String>>();
		Map<String, String> newPaymentAgent = new Map<String, String>();
		newPaymentAgent.put('Name', 'Test Agent Name');
		newPaymentAgent.put('TouchCRBase__Security_Key__c', 'test');
		newPaymentAgent.put('TouchCRBase__Active__c', 'true');
		newPaymentAgent.put('TouchCRBase__Merchant_ID__c', 'test');
		newPaymentAgents.add(newPaymentAgent);
		TouchCRHelper.setCustomSettings('TouchCRBase__Payment_Agents__c', newPaymentAgents);*/

		String paymentAgents = TouchCRAuraSettingsController.getPaymentOptions();
		List<PaymentOptionsWrapper> paymentAgentsDesirialized = (List<PaymentOptionsWrapper>)System.JSON.deserialize(paymentAgents, List<PaymentOptionsWrapper>.class);
		PaymentOptionsWrapper currentPaymentOption = new PaymentOptionsWrapper();

		/*for (PaymentOptionsWrapper paymentAgent : paymentAgentsDesirialized) {
			if (paymentAgent.value == newPaymentAgents[0].get('Name')) {
				currentPaymentOption = paymentAgent;
			}
		}*/

		//System.assertEquals(currentPaymentOption.value, newPaymentAgents[0].get('Name'));
		System.assertEquals(0, paymentAgentsDesirialized.size());

		String profiles = TouchCRAuraSettingsController.getPaymentProfOptions();
		List<PaymentOptionsWrapper> profilesDesirialized = (List<PaymentOptionsWrapper>)System.JSON.deserialize(profiles, List<PaymentOptionsWrapper>.class);

		System.assertEquals(profilesDesirialized.size() > 0, true);

		String settings = TouchCRAuraSettingsController.getPaymentSettingsApex();
		
		List<PaymentSettingsWrapper> settingsDesirialized = (List<PaymentSettingsWrapper>)System.JSON.deserialize(settings, List<PaymentSettingsWrapper>.class);
		
		String brandName = settingsDesirialized[0].name;

		System.assertEquals(settingsDesirialized[0].commValue, '');
		System.assertEquals(settingsDesirialized[0].gatewayId, '');
		System.assertEquals(settingsDesirialized[0].googleValue, '');
		System.assertEquals(settingsDesirialized[0].status, false);

		settingsDesirialized[0].commValue = 'test';
		settingsDesirialized[0].gatewayId = 'test';
		settingsDesirialized[0].googleValue = 'test';
		settingsDesirialized[0].status = true;

		TouchCRAuraSettingsController.savePaymentSettings(JSON.serialize(settingsDesirialized[0]));

		String savedSettings = TouchCRAuraSettingsController.getPaymentSettingsApex();

		List<PaymentSettingsWrapper> savedSettingsDesirialized = (List<PaymentSettingsWrapper>)System.JSON.deserialize(savedSettings, List<PaymentSettingsWrapper>.class);

		PaymentSettingsWrapper currentSetting = new PaymentSettingsWrapper();
		
		for (PaymentSettingsWrapper savedSetting : savedSettingsDesirialized) {
			if (savedSetting.name == brandName) {
				currentSetting = savedSetting;
			}
		}

		System.assertEquals(currentSetting.commValue, 'test');
		System.assertEquals(currentSetting.gatewayId, 'test');
		System.assertEquals(currentSetting.googleValue, 'test');
		System.assertEquals(currentSetting.status, true);
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
	}

// MinFraudSettings

	static testMethod void test_MinFraudSettingsController() {
		String settings = TouchCRAuraSettingsController.getMinFraudSettingsApex();
		Map<String, String> settingsDesirialized = (Map<String, String>)System.JSON.deserialize(settings, Map<String, String>.class);
		System.assertEquals('', settingsDesirialized.get('MinFraud.ApiKey'));
		System.assertEquals('', settingsDesirialized.get('MinFraud.RatingFirst'));
		System.assertEquals('', settingsDesirialized.get('MinFraud.RatingSecond'));

		TouchCRAuraSettingsController.MinFraudSettingsWrapper newSetting = new TouchCRAuraSettingsController.MinFraudSettingsWrapper();
		newSetting.apiKey = 'test';
		newSetting.firstRating = 9;
		newSetting.secondRating = 11;
		TouchCRAuraSettingsController.saveMinFraud(JSON.serialize(newSetting));

		String savedSettings = TouchCRAuraSettingsController.getMinFraudSettingsApex();
		Map<String, String> savedSettingsDesirialized = (Map<String, String>)System.JSON.deserialize(savedSettings, Map<String, String>.class);
		System.assertEquals('test', savedSettingsDesirialized.get('MinFraud.ApiKey'));
		System.assertEquals('9', savedSettingsDesirialized.get('MinFraud.RatingFirst'));
		System.assertEquals('11', savedSettingsDesirialized.get('MinFraud.RatingSecond'));
	}

// UspsSettings

	static testMethod void test_UspsSettingsController() {
		String settings = TouchCRAuraSettingsController.getUspsSettingsApex();
		Map<String, String> settingsDesirialized = (Map<String, String>)System.JSON.deserialize(settings, Map<String, String>.class);
		System.assertEquals('', settingsDesirialized.get('USPS.UserID'));

		TouchCRAuraSettingsController.UspsSettingsWrapper newSetting = new TouchCRAuraSettingsController.UspsSettingsWrapper();
		newSetting.uspsValue = 'test';
		TouchCRAuraSettingsController.saveUsps(JSON.serialize(newSetting));

		String savedSettings = TouchCRAuraSettingsController.getUspsSettingsApex();
		Map<String, String> savedSettingsDesirialized = (Map<String, String>)System.JSON.deserialize(savedSettings, Map<String, String>.class);
		System.assertEquals('test', savedSettingsDesirialized.get('USPS.UserID'));
	}

// TriggerSettings

	static testMethod void test_TriggerSettingsController() {
		String settings = TouchCRAuraSettingsController.getTriggerSettingsApex();
		Map<String, String> settingsDesirialized = (Map<String, String>)System.JSON.deserialize(settings, Map<String, String>.class);
		System.assertEquals('', settingsDesirialized.get('Chargent.OrderUserCreation'));

		TouchCRAuraSettingsController.TriggerSettingsWrapper newSetting = new TouchCRAuraSettingsController.TriggerSettingsWrapper();
		newSetting.isUserCreation = true;
		TouchCRAuraSettingsController.saveTrigger(JSON.serialize(newSetting));

		String savedSettings = TouchCRAuraSettingsController.getTriggerSettingsApex();
		Map<String, String> savedSettingsDesirialized = (Map<String, String>)System.JSON.deserialize(savedSettings, Map<String, String>.class);
		System.assertEquals('true', savedSettingsDesirialized.get('Chargent.OrderUserCreation'));
	}

// ProxySettings

	static testMethod void test_ProxySettingsController() {
		String settings = TouchCRAuraSettingsController.getProxySettingsApex();
		Map<String, String> settingsDesirialized = (Map<String, String>)System.JSON.deserialize(settings, Map<String, String>.class);
		System.assertEquals('', settingsDesirialized.get('Proxy.isEnabled'));

		TouchCRAuraSettingsController.ProxySettingsWrapper newSetting = new TouchCRAuraSettingsController.ProxySettingsWrapper();
		newSetting.isProxyEnabled = true;
		TouchCRAuraSettingsController.saveProxy(JSON.serialize(newSetting));

		String savedSettings = TouchCRAuraSettingsController.getProxySettingsApex();
		Map<String, String> savedSettingsDesirialized = (Map<String, String>)System.JSON.deserialize(savedSettings, Map<String, String>.class);
		System.assertEquals('true', savedSettingsDesirialized.get('Proxy.isEnabled'));
	}

// AuthorizeAura

	static testMethod void test_Authorize() {

		Test.startTest();
			Map<String, String> settings = TouchCRAuraSettingsController.getAuthorizeSettingsApex();
			
			System.assertEquals(settings.get('Endpoint.ClientId'), '');
			System.assertEquals(settings.get('Endpoint.ClientSecret'), '');
			System.assertEquals(settings.get('Endpoint.TokenType'), '');
			System.assertEquals(settings.get('Endpoint.TokenPart1'), '');
			System.assertEquals(settings.get('Endpoint.TokenPart2'), '');
			System.assertEquals(settings.get('Endpoint.ExpiresIn'), '');

			Map<String, String> responseHeaders = new Map<String, String>();
			responseHeaders.put('Access-Token', 'updatedTokeneyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyU0xZMU9FU1VHMzZDVFBIUlhMS1lLQ0EzIiwiaXNzIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hcHBsaWNhdGlvbnMvVWJlVU9WYlNVM1dCMVlCR05QaVl5IiwiaWF0IjoxNDg4MjgyNjA4LCJleHAiOjE0ODkxNDY2MDgsInNjb3BlIjoiIn0.5oTNt5CmE80imx4DvyZtgz8hOsaH22iePiDhT7Xpeqw');
			responseHeaders.put('Access-Token-Expire-Time', '86400');
			responseHeaders.put('Access-Token-Type', 'bearer');
			String body = '{"authenticationInfo":{"access_token":"updatedTokeneyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyU0xZMU9FU1VHMzZDVFBIUlhMS1lLQ0EzIiwiaXNzIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hcHBsaWNhdGlvbnMvVWJlVU9WYlNVM1dCMVlCR05QaVl5IiwiaWF0IjoxNDg4MjgyNjA4LCJleHAiOjE0ODkxNDY2MDgsInNjb3BlIjoiIn0.5oTNt5CmE80imx4DvyZtgz8hOsaH22iePiDhT7Xpeqw","expires_in":"86400","token_type":"Bearer"}}';
			Test.setMock(HttpCalloutMock.class, new TouchCRConfigurationMock(200, 'OK', body, responseHeaders));

			CredentialsWrapper creds = new CredentialsWrapper();
			creds.clientIdEndpoint = 'clientIdEndpoint';
			creds.clientSecretEndpoint = 'clientSecretEndpoint';

			String linkResult = TouchCRAuraSettingsController.linkAuthorizeEndpointToken(JSON.serialize(creds));

			System.assertEquals(linkResult, 'Organization has been successfully linked!');

			Map<String, String> savedSettings = TouchCRAuraSettingsController.getAuthorizeSettingsApex();
			
			System.assertEquals(savedSettings.get('Endpoint.ClientId'), 'clientIdEndpoint');
			System.assertEquals(savedSettings.get('Endpoint.ClientSecret'), 'clientSecretEndpoint');
			System.assertEquals(savedSettings.get('Endpoint.TokenType'), 'Bearer');
			System.assertEquals(savedSettings.get('Endpoint.TokenPart1'), 'updatedTokeneyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyU0xZMU9FU1VHMzZDVFBIUlhMS1lLQ0EzIiwiaXNzIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hcHBsaWNhdGlvbnMvVWJlVU9WYlNVM1dCMVlCR05QaVl5IiwiaWF0IjoxNDg4MjgyNjA4LCJleHAiOjE0ODkxNDY2MDgsInNjb3BlIjoiIn0.5');
			System.assertEquals(savedSettings.get('Endpoint.TokenPart2'), 'oTNt5CmE80imx4DvyZtgz8hOsaH22iePiDhT7Xpeqw');
			System.assertEquals(savedSettings.get('Endpoint.ExpiresIn'), '86400');

			String unlinkResult = TouchCRAuraSettingsController.unlinkAuthorizeEndpointToken();

			System.assertEquals(unlinkResult, 'Organization has been successfully unlinked!');

			Map<String, String> unlinkSettings = TouchCRAuraSettingsController.getAuthorizeSettingsApex();
			
			System.assertEquals(unlinkSettings.get('Endpoint.ClientId'), null);
			System.assertEquals(unlinkSettings.get('Endpoint.ClientSecret'), null);
			System.assertEquals(unlinkSettings.get('Endpoint.TokenType'), null);
			System.assertEquals(unlinkSettings.get('Endpoint.TokenPart1'), null);
			System.assertEquals(unlinkSettings.get('Endpoint.TokenPart2'), null);
			System.assertEquals(unlinkSettings.get('Endpoint.ExpiresIn'), null);

		Test.stopTest();
	}

	public class CredentialsWrapper {
		protected String clientIdEndpoint { get; set; }
		protected String clientSecretEndpoint { get; set; }
	}
}