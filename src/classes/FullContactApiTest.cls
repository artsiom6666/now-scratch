@isTest
private class FullContactApiTest {

	public static final String EMAIL_NOT_FOUND = '{"status":404,"message":"Searched within last 24 hours. No results found for this Id.","requestId":"02af96df-fab9-48db-bb41-9daf2b301990"}';
	public static final String BAD_RESPONSE = '';

	@isTest static void test_account_email_not_found() {
		
		Map<String, String> touchCrSettingsToUpsert = new Map<String, String>();
			touchCrSettingsToUpsert.put('Endpoint.TokenPart1', '');
			touchCrSettingsToUpsert.put('Endpoint.TokenPart2', '');
			touchCrSettingsToUpsert.put('Endpoint.TokenType', 'Bearer');
			touchCrSettingsToUpsert.put('Endpoint.ClientId', 'Test');
			touchCrSettingsToUpsert.put('Endpoint.ClientSecret', 'Test');

		TouchCRHelper.setSettings(touchCrSettingsToUpsert);

		Test.setMock(HttpCalloutMock.class, new FullContactApiMock(EMAIL_NOT_FOUND));

		//set all custom settings to true
		TouchCRConfigurationController objTD = new TouchCRConfigurationController();
		for (TouchCRConfigurationController.SettingsWr setting : objTD.globalSettingsBWr) {
			setting.valueB = true;
		}
		for (TouchCRConfigurationController.SettingsWr setting : objTD.globalSettingsNWr) {
			setting.valueN = '10';
		}
		//SAVE
		objTD.saveDASettings();

		TouchCRConfigurationController objFC = new TouchCRConfigurationController();
		for (TouchCRConfigurationController.SettingsWr setting : objFC.fcSettingsSWr) {
			setting.valueS = 'apikey';
		}
		//SAVE
		objFC.saveFCSettings();

		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testObj = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'john.doe@gmail.org');
		insert testObj;

		Test.startTest();
			FullContactApi api = new FullContactApi();
			api.setObject(testObj);
			api.callApi();
			testObj = (Account) api.appendData();
			Log__c aLog = api.logCall();
		Test.stopTest();

		//LOG
		System.assertNotEquals(null, aLog);
		System.assertEquals(FullContactApi.SUCCESS_MESSAGE, aLog.Event_Status__c);
		System.assertEquals(testObj.Id, aLog.Account__c);

		System.assertEquals(null, testObj.Social_Append_Run_Date__c);
		System.assertEquals(false, testObj.Append_Need_Append__c);
		System.assertEquals(false, testObj.Social_Append_Success__c);
	}

	@isTest static void test_account_validemail() {
		Test.setMock(HttpCalloutMock.class, new FullContactApiMock());

		//set all custom settings to true
		TouchCRConfigurationController objTD = new TouchCRConfigurationController();
		for (TouchCRConfigurationController.SettingsWr setting : objTD.globalSettingsBWr) {
			setting.valueB = true;
		}
		for (TouchCRConfigurationController.SettingsWr setting : objTD.globalSettingsNWr) {
			setting.valueN = '10';
		}
		//SAVE
		objTD.saveDASettings();

		TouchCRConfigurationController objFC = new TouchCRConfigurationController();
		for (TouchCRConfigurationController.SettingsWr setting : objFC.fcSettingsSWr) {
			setting.valueS = 'apikey';
		}
		//SAVE
		objFC.saveFCSettings();

		Account testObj = new Account(
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'john.doe@example.com');
		Test.startTest();
			FullContactApi api = new FullContactApi();
			api.setObject(testObj);
			System.debug(api.callApi());
			testObj = (Account) api.appendData();
		Test.stopTest();

		System.assertEquals(System.now(), testObj.Social_Append_Run_Date__c);
		System.assertEquals(false, testObj.Append_Need_Append__c);
		System.assertEquals(true, testObj.Social_Append_Success__c);
	}

	@isTest static void test_account_badresponse() {

		Test.setMock(HttpCalloutMock.class, new FullContactApiMock(BAD_RESPONSE));

		Account testObj = new Account(
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'john.doe@example.com');

		Test.startTest();
			FullContactApi api = new FullContactApi();
			api.setObject(testObj);
			Map<String, Object> response = api.callApi();
			testObj = (Account) api.appendData();
		Test.stopTest();

		System.assertEquals(true, response.isEmpty());
	}

	@isTest static void test_lead_email_not_found() {
		
		Map<String, String> touchCrSettingsToUpsert = new Map<String, String>();
			touchCrSettingsToUpsert.put('Endpoint.TokenPart1', '');
			touchCrSettingsToUpsert.put('Endpoint.TokenPart2', '');
			touchCrSettingsToUpsert.put('Endpoint.TokenType', 'Bearer');
			touchCrSettingsToUpsert.put('Endpoint.ClientId', 'Test');
			touchCrSettingsToUpsert.put('Endpoint.ClientSecret', 'Test');

		TouchCRHelper.setSettings(touchCrSettingsToUpsert);

		Test.setMock(HttpCalloutMock.class, new FullContactApiMock(EMAIL_NOT_FOUND));

		//set all custom settings to true
		TouchCRConfigurationController objTD = new TouchCRConfigurationController();
		for (TouchCRConfigurationController.SettingsWr setting : objTD.globalSettingsBWr) {
			setting.valueB = true;
		}
		for (TouchCRConfigurationController.SettingsWr setting : objTD.globalSettingsNWr) {
			setting.valueN = '10';
		}
		//SAVE
		objTD.saveDASettings();

		TouchCRConfigurationController objFC = new TouchCRConfigurationController();
		for (TouchCRConfigurationController.SettingsWr setting : objFC.fcSettingsSWr) {
			setting.valueS = 'apikey';
		}
		//SAVE
		objFC.saveFCSettings();

		Lead testObj = new Lead(
			FirstName = 'John',
			LastName = 'Doe',
			Email = 'john.doe@gmail.org');
		insert testObj;

		Test.startTest();
			FullContactApi api = new FullContactApi();
			api.setObject(testObj);
			api.callApi();
			testObj = (Lead) api.appendData();
			Log__c aLog = api.logCall();
		Test.stopTest();

		//LOG
		System.assertNotEquals(null, aLog);
		System.assertEquals(FullContactApi.SUCCESS_MESSAGE, aLog.Event_Status__c);
		System.assertEquals(testObj.Id, aLog.Lead__c);

		System.assertEquals(null, testObj.Social_Append_Run_Date__c);
		System.assertEquals(false, testObj.Social_Append_Success__c);
	}

	@isTest static void test_lead_validemail() {
		Test.setMock(HttpCalloutMock.class, new FullContactApiMock());

		//set all custom settings to true
		TouchCRConfigurationController objTD = new TouchCRConfigurationController();
		for (TouchCRConfigurationController.SettingsWr setting : objTD.globalSettingsBWr) {
			setting.valueB = true;
		}
		for (TouchCRConfigurationController.SettingsWr setting : objTD.globalSettingsNWr) {
			setting.valueN = '10';
		}
		//SAVE
		objTD.saveDASettings();

		TouchCRConfigurationController objFC = new TouchCRConfigurationController();
		for (TouchCRConfigurationController.SettingsWr setting : objFC.fcSettingsSWr) {
			setting.valueS = 'apikey';
		}
		//SAVE
		objFC.saveFCSettings();

		Lead testObj = new Lead(
			FirstName = 'John',
			LastName = 'Doe',
			Email = 'john.doe@example.com');
		Test.startTest();
			FullContactApi api = new FullContactApi();
			api.setObject(testObj);
			System.debug(api.callApi());
			testObj = (Lead) api.appendData();
		Test.stopTest();

		System.assertEquals(System.now(), testObj.Social_Append_Run_Date__c);
		System.assertEquals(false, testObj.Append_Need_Append__c);
		System.assertEquals(true, testObj.Social_Append_Success__c);
	}

	@isTest static void test_lead_badresponse() {

		Test.setMock(HttpCalloutMock.class, new FullContactApiMock(BAD_RESPONSE));

		Lead testObj = new Lead(
			FirstName = 'John',
			LastName = 'Doe',
			Email = 'john.doe@example.com');

		Test.startTest();
			FullContactApi api = new FullContactApi();
			api.setObject(testObj);
			Map<String, Object> response = api.callApi();
			testObj = (Lead) api.appendData();
		Test.stopTest();

		System.assertEquals(true, response.isEmpty());
	}

}