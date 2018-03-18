@isTest
private class DataFinderApiTest {


	@isTest static void test_tworesults_notappended() {
		Test.setMock(HttpCalloutMock.class, new DataFinderApiMock(DataFinderApiMock.RESULTS_ONE_NOT_INDIVHHLD));

		String access_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyU0xZMU9FU1VHMzZDVFBIUlhMS1lLQ0EzIiwiaXNzIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hcHBsaWNhdGlvbnMvVWJlVU9WYlNVM1dCMVlCR05QaVl5IiwiaWF0IjoxNDg4MjgyNjA4LCJleHAiOjE0ODkxNDY2MDgsInNjb3BlIjoiIn0.5oTNt5CmE80imx4DvyZtgz8hOsaH22iePiDhT7Xpeqw';

		Map<String, String> touchCrSettingsToUpsert = new Map<String, String>();
			touchCrSettingsToUpsert.put('Endpoint.TokenPart1', access_token.substring(0, 254));
			touchCrSettingsToUpsert.put('Endpoint.TokenPart2', access_token.substring(254));
			touchCrSettingsToUpsert.put('Endpoint.TokenType', 'Bearer');
			touchCrSettingsToUpsert.put('Endpoint.ClientId', 'Test');
			touchCrSettingsToUpsert.put('Endpoint.ClientSecret', 'Test');

		TouchCRHelper.setSettings(touchCrSettingsToUpsert);
		Test.startTest();

		Account account = new Account();
		account.FirstName = 'John';
		account.LastName = 'Doe';
		account.BillingStreet = '123 Lucky Ave';
		account.BillingCity = 'City';
		account.BillingPostalCode = '12345';
		account.PersonEmail = 'amz@marketplace1.io';
		if (TouchCRHelper.isSCPEnabled()) {
			account.put('BillingStateCode', 'TX');
		}

		DataFinderApi api = new DataFinderApi()
		.setConfKey('apikey')
		.setSObject(account)
		.doGetData()
		.doAppend();
		Test.stopTest();
		Account testObj = (Account) api.getAppendedObject();
		
		Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();
	        TouchCR_Settings__c tokenPart1 = settingsMap.get('Endpoint.TokenPart1');
	        TouchCR_Settings__c tokenPart2 = settingsMap.get('Endpoint.TokenPart2');

		String updated_access_token = 'updatedToken' + access_token;

		//AUTH
		System.assertEquals(updated_access_token, tokenPart1.Value__c + tokenPart2.Value__c);

		System.assertEquals('amz@marketplace1.io', testObj.PersonEmail);
		System.assertEquals(true, testObj.DF_Append_Run__c);
		System.assertEquals(false, testObj.DF_Append_Success__c);
		System.assertEquals('Success', api.getLogs().Event_Status__c);
	}

	@isTest static void test_nores() {
		Test.setMock(HttpCalloutMock.class, new DataFinderApiMock(DataFinderApiMock.RESULTS_TWO_INDIVHHLD));

		Map<String, String> touchCrSettingsToUpsert = new Map<String, String>();
			touchCrSettingsToUpsert.put('Endpoint.TokenPart1', '');
			touchCrSettingsToUpsert.put('Endpoint.TokenPart2', '');
			touchCrSettingsToUpsert.put('Endpoint.TokenType', 'Bearer');
			touchCrSettingsToUpsert.put('Endpoint.ClientId', 'Test');
			touchCrSettingsToUpsert.put('Endpoint.ClientSecret', 'Test');

		TouchCRHelper.setSettings(touchCrSettingsToUpsert);
		
		Test.startTest();
			Account account = new Account();
			account.FirstName = 'John';
			account.LastName = 'Doe';
			account.BillingStreet = '123 Lucky Ave';
			account.BillingCity = 'City';
			account.BillingPostalCode = '12345';
			account.PersonEmail = 'amz@marketplace1.io';
			if (TouchCRHelper.isSCPEnabled()) {
				account.put('BillingStateCode', 'TX');
			}
			DataFinderApi api = new DataFinderApi()
			.setConfKey('apikey')
			.setSObject(account)
			.doGetData()
			.doAppend();
		Test.stopTest();
		
		Account testObj = (Account) api.getAppendedObject();

		// wyoarts@google.com score 85 - wyoarts@yahoo.com score 90.342857142857
		System.assertEquals('wyoarts@yahoo.com', testObj.PersonEmail);
		System.assertEquals(true, testObj.DF_Append_Run__c);
		System.assertEquals(true, testObj.DF_Append_Success__c);
		// store original email
		System.assertEquals('amz@marketplace1.io', testObj.DF_Email__c);
		System.assertEquals(90.342857142857, testObj.DF_Match_Probability__c);
	}

	@isTest static void test_nonvalidresponse() {
		Test.setMock(HttpCalloutMock.class, new DataFinderApiMock(DataFinderApiMock.ERR));

		Account account = new Account();
		account.FirstName = 'John';
		account.LastName = 'Doe';
		account.BillingStreet = '123 Lucky Ave';
		account.BillingCity = 'City';
		account.BillingPostalCode = '12345';
		account.PersonEmail = 'amz@marketplace1.io';
		if (TouchCRHelper.isSCPEnabled()) {
			account.put('BillingStateCode', 'TX');
		}

		DataFinderApi api = new DataFinderApi()
		.setConfKey('apikey')
		.setSObject(account)
		.doGetData()
		.doAppend();

		Account testObj = (Account) api.getAppendedObject();

		// email didnt chage as there invalid response
		System.assertEquals('amz@marketplace1.io', testObj.PersonEmail);
		System.assertEquals(false, testObj.DF_Append_Run__c);
		System.assertEquals(false, testObj.DF_Append_Success__c);
	}
}