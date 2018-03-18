@isTest
public class RestFraudDetectionControllerTest {

	@testSetup
	static void setupTest() {
		String email = 'json@gmail.com';

		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account accountObj     = new Account();
		accountObj.RecordTypeId = customerRecordType.Id;
		accountObj.FirstName   = 'test';
		accountObj.LastName    = 'test';
		accountObj.Phone       = '6547892456';
		accountObj.PersonEmail = email;
		accountObj.BillingState = 'Alaska';
		accountObj.BillingCountry = 'United States';
		accountObj.ShippingState = 'Alaska';
		accountObj.ShippingCountry = 'United States';
		insert accountObj;

		Product2 productObj = new Product2();
		productObj.Name         = 'test';
		productObj.ProductCode  = 'DSX';
		productObj.IsActive     = true;
		insert productObj;

		Product_Variant__c variant = new Product_Variant__c();
		variant.Product__c = productObj.Id;
		variant.Price__c = 20;
		variant.Product_Title__c = 'test';
		variant.sku__c = 'DSX';
		insert variant;

		Map<String, String> orderFormData = new Map<String, String>();
		orderFormData.put('product_id', productObj.Id);
		orderFormData.put('product_variant', variant.Id);
		orderFormData.put('email', email);
		orderFormData.put('fname', 'david');
		orderFormData.put('lname', 'huggs');
		orderFormData.put('phone', '9876543210');
		orderFormData.put('b_common', '123 main Street~New York~LA~US~10035');
		orderFormData.put('s_common', '123 main Street~New York~LA~US~10035');
		orderFormData.put('cc_number', '4242424242424242');
		orderFormData.put('security_code', '242');
		orderFormData.put('cc_exp_month', '05');
		orderFormData.put('cc_exp_year', '2020');
		orderFormData.put('cc_type', 'Visa');
		orderFormData.put('ip', '127.1.1.1');
		orderFormData.put('utm_source', 'test source');
		orderFormData.put('utm_medium', 'test medium');
		orderFormData.put('utm_campaign', 'test campaign');
		orderFormData.put('utm_content', 'test content');
		orderFormData.put('utm_term', 'test term');
		orderFormData.put('sales_funnel_name', 'test state funnel');
		orderFormData.put('landing_page_url', 'test landing page url');
		orderFormData.put('referral_domain_url', 'test referral domian');
		orderFormData.put('start_date', '9/20/2016');
		orderFormData.put('shipping', '2');
		orderFormData.put('tax', '2');
		orderFormData.put('total', '24');
		orderFormData.put('subtotal', '20');
		orderFormData.put('quantity', '1');
		orderFormData.put('Offerprice', '20');
		orderFormData.put('token', '');
		orderFormData.put('brand', 'test brand');
		String orderId = RestNewOrderProcessController.setOrders(orderFormData);

		List<Account> testAccounts = [SELECT Id FROM Account];
		List<Product2> testProduct2s = [SELECT Id FROM Product2];
		List<Product_Variant__c> testProductVariants = [SELECT Id FROM Product_Variant__c];
		List<Order__c> orderRecords = [SELECT Id FROM Order__c WHERE Id =: orderId];

		System.assertEquals(orderRecords[0].Id, orderId);
		System.assertEquals(testAccounts.size(), 1);
		System.assertEquals(testProduct2s.size(), 1);
		System.assertEquals(testProductVariants.size(), 1);
	}

	/* This method is used to Test get_Fraud_Detection(orderId) without auth*/
	@istest static void get_Fraud_DetectionTestWithoutAuth(){

		Map<String, String> minFraudSetting = new Map<String, String>();
			minFraudSetting.put('MinFraud.ApiKey', 'testAPIkey');
		TouchCRHelper.setSettings(minFraudSetting);

		List<Order__c> orderRecords = [SELECT Id FROM Order__c LIMIT 1];

		// Set mock callout class
		Test.setMock(HttpCalloutMock.class, new RestFraudDetectionControllerMockResponse());
		RestFraudDetectionController fraud = new RestFraudDetectionController();

		Test.startTest();
		Decimal actual = fraud.get_Fraud_Detection(orderRecords[0].Id);
		Test.stopTest();

		Decimal expected = 0.23;
		System.assertEquals(expected, actual);
	}

	/* This method is used to
		1.Test get_Fraud_Detection(orderId, endpoint)
		2.Test Exception if MinFraud.ApiKey is null
	*/
	@istest static void get_Fraud_DetectionTestMinFraudApiKeyNull(){

		// Set mock callout class
		Test.setMock(HttpCalloutMock.class, new RestFraudDetectionControllerMockResponse());
		RestFraudDetectionController fraud = new RestFraudDetectionController();
		List<String> result = new List<String>();

		List<Order__c> orderRecords = [SELECT Id FROM Order__c LIMIT 1];

		Test.startTest();
		Decimal actual = fraud.get_Fraud_Detection(orderRecords[0].Id, 'callout:TouchCR__SecureProxy/frauddetect');
		result = fraud.getApiCallInfo();
		Test.stopTest();

		Decimal expected = NULL;
		System.assertEquals(expected, actual);
	}

	/* This method is used to
		1.Test get_Fraud_Detection(orderId, endpoint)
		2.Test proxy auth
	*/
	@istest static void get_Fraud_DetectionTestWithAuth(){

		Map<String, String> minFraudSetting = new Map<String, String>();
			minFraudSetting.put('MinFraud.ApiKey', 'testAPIkey');
		TouchCRHelper.setSettings(minFraudSetting);

		String access_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyU0xZMU9FU1VHMzZDVFBIUlhMS1lLQ0EzIiwiaXNzIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hcHBsaWNhdGlvbnMvVWJlVU9WYlNVM1dCMVlCR05QaVl5IiwiaWF0IjoxNDg4MjgyNjA4LCJleHAiOjE0ODkxNDY2MDgsInNjb3BlIjoiIn0.5oTNt5CmE80imx4DvyZtgz8hOsaH22iePiDhT7Xpeqw';

		List<Order__c> orderRecords = [SELECT Id FROM Order__c LIMIT 1];

		Map<String, String> touchCrSettingsToUpsert = new Map<String, String>();
			touchCrSettingsToUpsert.put('Endpoint.TokenPart1', access_token.substring(0, 254));
			touchCrSettingsToUpsert.put('Endpoint.TokenPart2', access_token.substring(254));
			touchCrSettingsToUpsert.put('Endpoint.TokenType', 'Bearer');
			touchCrSettingsToUpsert.put('Endpoint.ClientId', 'Test');
			touchCrSettingsToUpsert.put('Endpoint.ClientSecret', 'Test');

		TouchCRHelper.setSettings(touchCrSettingsToUpsert);

		// Set mock callout class
		Test.setMock(HttpCalloutMock.class, new RestFraudDetectionControllerMockResponse());
		RestFraudDetectionController fraud = new RestFraudDetectionController();
		List<String> result = new List<String>();

		Test.startTest();
		Decimal actual = fraud.get_Fraud_Detection(orderRecords[0].Id, 'callout:TouchCR__SecureProxy/frauddetect');
		result = fraud.getApiCallInfo();
		Test.stopTest();

		Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();
		TouchCR_Settings__c tokenPart1 = settingsMap.get('Endpoint.TokenPart1');
		TouchCR_Settings__c tokenPart2 = settingsMap.get('Endpoint.TokenPart2');

		Decimal expected = 0.23;
		String updated_access_token = 'updatedToken' + access_token;
		System.assertEquals(expected, actual);
		System.assertEquals(updated_access_token, tokenPart1.Value__c + tokenPart2.Value__c);
	}
}