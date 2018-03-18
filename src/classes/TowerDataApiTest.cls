@isTest
private class TowerDataApiTest {

	public static final String NOTVALIDEMAIL_IP_VALIDATE_CORRECTION = '{"email":{"ok":false,"status_code":110,"status_desc":"Invalid character in address","validation_level":2,"address":"john;doe@example.com","username":null,"domain":null,"domain_type":null,"role":false,"corrections":["john.doe@example.com","johndoe@example.com"]},"found_postal":{"ok":true,"status_code":10,"status_desc":"Data found","fname":"JANE","lname":"SMITH","address1":"100 MAIN ST APT 3","address2":null,"city":"SPRINGFIELD","state":"MA","zip":"11111","plus4":"1234","source":"email"},"ip":{"status_code":10,"status_desc":"IP Found","ok":true,"address":"66.108.76.101","country_code":"US","country_name":"UNITED STATES","region":"NY","city":"NEW YORK","isp":"TIME WARNER CABLE","domain":"roadrunner.com"},"status_code":10,"status_desc":"Success"}';
	public static final String EMAILOKFALSE_NOCORRECTION = '{"email":{"ok":false,"validation_level":2,"status_code":125,"status_desc":"Invalid username syntax for that domain","address":"789465@yahoo.com","username":null,"domain":null,"domain_type":null,"role":false},"found_postal":{"ok":false,"status_code":15,"status_desc":"No data found"},"status_code":10,"status_desc":"Success"}';
	public static final String VALIDEMAIL_NOTVALIDATE = '{"email":{"ok":true,"validation_level":5,"status_code":50,"status_desc":"Syntax OK, domain exists, and mailbox does not reject mail","address":"gbrown696@gmail.com","username":"gbrown696","domain":"gmail.com","domain_type":"freeisp","role":false},"status_code":10,"status_desc":"Success"}';
	public static final String BAD_RESPONSE;

	@isTest static void test_account_validate_emailnonvalid_corrections() {
		
		Map<String, String> touchCrSettingsToUpsert = new Map<String, String>();
			touchCrSettingsToUpsert.put('Endpoint.TokenPart1', '');
			touchCrSettingsToUpsert.put('Endpoint.TokenPart2', '');
			touchCrSettingsToUpsert.put('Endpoint.TokenType', 'Bearer');
			touchCrSettingsToUpsert.put('Endpoint.ClientId', 'Test');
			touchCrSettingsToUpsert.put('Endpoint.ClientSecret', 'Test');

		TouchCRHelper.setSettings(touchCrSettingsToUpsert);

		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock(NOTVALIDEMAIL_IP_VALIDATE_CORRECTION));

		//set all custom settings to true
		TouchCRConfigurationController obj = new TouchCRConfigurationController();
		for (TouchCRConfigurationController.SettingsWr setting : obj.accountSettingsBWr) {
			setting.valueB = true;
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.leadSettingsBWr) {
			setting.valueB = true;
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.globalSettingsBWr) {
			setting.valueB = true;
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.globalSettingsNWr) {
			setting.valueN = '10';
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.globalSettingsSWr) {
			setting.valueS = 'apikey';
		}
		//SAVE
		obj.saveDASettings();

		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testObj = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'john.doe@gmail.org');
		insert testObj;

		Test.startTest();
			TowerDataApi api = new TowerDataApi();
			api.setObject(testObj);
			api.callApi();
			testObj = (Account) api.appendData();
			Log__c aLog = api.logCall();
		Test.stopTest();

		//LOG
		System.assertNotEquals(null, aLog);
		System.assertEquals(TowerDataApi.SUCCESS_MESSAGE, aLog.Event_Status__c);
		System.assertEquals(testObj.Id, aLog.Account__c);

		//EMAIL
		System.assertEquals(true, testObj.Email_Append_Run__c);
		System.assertEquals(System.today(), testObj.Email_Append_Run_Date__c.date());
		System.assertEquals(true, testObj.Email_Checked__c);
		System.assertEquals(false, testObj.Email_Valid__c);
		System.assertEquals(false, testObj.Email_Box_Valid__c);
		System.assertNotEquals('', testObj.Email_Corrections__c);
		//POSTAL
		System.assertEquals('100 MAIN ST APT 3', testObj.Append_Address_Street__c);
		System.assertEquals('SPRINGFIELD', testObj.Append_Address_City__c);
		System.assertEquals('MA', testObj.Append_Address_State__c);
		System.assertEquals('11111', testObj.Append_Address_Zip__c);
		//IP
		/*System.assertEquals('NEW YORK', testObj.IP_Address_Location_City__c);
		System.assertEquals('NY', testObj.IP_Address_Location_Region__c);
		System.assertEquals('US', testObj.IP_Address_Location_Country_Code__c);
		System.assertEquals('UNITED STATES', testObj.IP_Address_Location_Country_Name__c);*/
	}

	@isTest static void test_account_validate_emailvalid() {
		//validate
		insert new TouchCR_Settings__c(Name = 'Account.ValidateEmail', Value__c = 'true');

		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock(VALIDEMAIL_NOTVALIDATE));

		Account testObj = new Account(
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'john;doe@example.com');
		Test.startTest();
			TowerDataApi api = new TowerDataApi();
			api.setObject(testObj);
			api.callApi();
			testObj = (Account) api.appendData();
		Test.stopTest();

		//EMAIL
		System.assertEquals(true, testObj.Email_Append_Run__c);
		System.assertEquals(System.today(), testObj.Email_Append_Run_Date__c.date());
		System.assertEquals(true, testObj.Email_Checked__c);
		System.assertEquals(true, testObj.Email_Valid__c);
		System.assertEquals(true, testObj.Email_Box_Valid__c);
	}

	@isTest static void test_account_validate_emailnotvalid_nocorrections() {
		//validate
		insert new TouchCR_Settings__c(Name = 'Account.ValidateEmail', Value__c = 'true');

		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock(EMAILOKFALSE_NOCORRECTION));

		Account testObj = new Account(
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'john;doe@example.com');
		Test.startTest();
			TowerDataApi api = new TowerDataApi();
			api.setObject(testObj);
			api.callApi();
			testObj = (Account) api.appendData();
		Test.stopTest();

		//EMAIL
		System.assertEquals(true, testObj.Email_Append_Run__c);
		System.assertEquals(System.today(), testObj.Email_Append_Run_Date__c.date());
		System.assertEquals(true, testObj.Email_Checked__c);
		System.assertEquals(false, testObj.Email_Valid__c);
		System.assertEquals(false, testObj.Email_Box_Valid__c);
		System.assertEquals(null, testObj.Email_Corrections__c);
	}

	@isTest static void test_lead_validate_emailnotvalid_nocorrections() {
		//validate
		insert new TouchCR_Settings__c(Name = 'Lead.ValidateEmail', Value__c = 'true');

		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock(EMAILOKFALSE_NOCORRECTION));

		Lead testObj = new Lead(
			FirstName = 'John',
			LastName = 'Doe',
			Email = 'john;doe@example.com');
		Test.startTest();
			TowerDataApi api = new TowerDataApi();
			api.setObject(testObj);
			api.callApi();
			testObj = (Lead) api.appendData();
		Test.stopTest();

		//EMAIL
		System.assertEquals(true, testObj.Email_Append_Run__c);
		System.assertEquals(System.today(), testObj.Email_Append_Run_Date__c.date());
		System.assertEquals(true, testObj.Email_Checked__c);
		System.assertEquals(false, testObj.Email_Valid__c);
		System.assertEquals(false, testObj.Email_Box_Valid__c);
		System.assertEquals(null, testObj.Email_Corrections__c);
	}

	@isTest static void test_account_notvalidate() {
		//not validate
		insert new TouchCR_Settings__c(Name = 'Account.ValidateEmail', Value__c = 'false');

		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock(VALIDEMAIL_NOTVALIDATE));

		Account testObj = new Account(
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'john;doe@example.com');
		Test.startTest();
			TowerDataApi api = new TowerDataApi();
			api.setObject(testObj);
			api.callApi();
			testObj = (Account) api.appendData();
		Test.stopTest();

		//EMAIL
		System.assertEquals(true, testObj.Email_Append_Run__c);
		System.assertEquals(System.today(), testObj.Email_Append_Run_Date__c.date());
		System.assertEquals(false, testObj.Email_Checked__c);
		System.assertEquals(false, testObj.Email_Valid__c);
		System.assertEquals(false, testObj.Email_Box_Valid__c);
	}

	@isTest static void test_lead_validate_emailnonvalid_corrections() {

		Map<String, String> touchCrSettingsToUpsert = new Map<String, String>();
			touchCrSettingsToUpsert.put('Endpoint.TokenPart1', '');
			touchCrSettingsToUpsert.put('Endpoint.TokenPart2', '');
			touchCrSettingsToUpsert.put('Endpoint.TokenType', 'Bearer');
			touchCrSettingsToUpsert.put('Endpoint.ClientId', 'Test');
			touchCrSettingsToUpsert.put('Endpoint.ClientSecret', 'Test');

		TouchCRHelper.setSettings(touchCrSettingsToUpsert);

		//set all custom settings to true
		TouchCRConfigurationController obj = new TouchCRConfigurationController();
		for (TouchCRConfigurationController.SettingsWr setting : obj.accountSettingsBWr) {
			setting.valueB = true;
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.leadSettingsBWr) {
			setting.valueB = true;
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.globalSettingsBWr) {
			setting.valueB = true;
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.globalSettingsNWr) {
			setting.valueN = '10';
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.globalSettingsSWr) {
			setting.valueS = 'apikey';
		}
		//SAVE
		obj.saveDASettings();

		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock(NOTVALIDEMAIL_IP_VALIDATE_CORRECTION));

		Lead testObj = new Lead(
			FirstName = 'John',
			LastName = 'Doe',
			Email = 'john.doe@gmail.org');
		insert testObj;

		Test.startTest();
			TowerDataApi api = new TowerDataApi();
			api.setObject(testObj);
			api.callApi();
			testObj = (Lead) api.appendData();
			Log__c aLog = api.logCall();
		Test.stopTest();

		//LOG
		System.assertNotEquals(null, aLog);
		System.assertEquals(TowerDataApi.SUCCESS_MESSAGE, aLog.Event_Status__c);
		System.assertEquals(testObj.Id, aLog.Lead__c);

		//EMAIL
		System.assertEquals(true, testObj.Email_Append_Run__c);
		System.assertEquals(System.today(), testObj.Email_Append_Run_Date__c.date());
		System.assertEquals(true, testObj.Email_Checked__c);
		System.assertEquals(false, testObj.Email_Valid__c);
		System.assertEquals(false, testObj.Email_Box_Valid__c);
		System.assertNotEquals('', testObj.Email_Corrections__c);
		//POSTAL
		System.assertEquals('100 MAIN ST APT 3', testObj.Append_Address_Street__c);
		System.assertEquals('SPRINGFIELD', testObj.Append_Address_City__c);
		System.assertEquals('MA', testObj.Append_Address_State__c);
		System.assertEquals('11111', testObj.Append_Address_Zip__c);
		//IP
		/*System.assertEquals('NEW YORK', testObj.IP_Address_Location_City__c);
		System.assertEquals('NY', testObj.IP_Address_Location_Region__c);
		System.assertEquals('US', testObj.IP_Address_Location_Country_Code__c);
		System.assertEquals('UNITED STATES', testObj.IP_Address_Location_Country_Name__c);*/
	}

	@isTest static void test_lead_validate_emailvalid() {
		//validate
		insert new TouchCR_Settings__c(Name = 'Lead.ValidateEmail', Value__c = 'true');

		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock(VALIDEMAIL_NOTVALIDATE));

		Lead testObj = new Lead(
			FirstName = 'John',
			LastName = 'Doe',
			Email = 'john;doe@example.com');
		Test.startTest();
			TowerDataApi api = new TowerDataApi();
			api.setObject(testObj);
			api.callApi();
			testObj = (Lead) api.appendData();
		Test.stopTest();

		//EMAIL
		System.assertEquals(true, testObj.Email_Append_Run__c);
		System.assertEquals(System.today(), testObj.Email_Append_Run_Date__c.date());
		System.assertEquals(true, testObj.Email_Checked__c);
		System.assertEquals(true, testObj.Email_Valid__c);
		System.assertEquals(true, testObj.Email_Box_Valid__c);
	}

	@isTest static void test_lead_notvalidate() {
		//not validate
		insert new TouchCR_Settings__c(Name = 'Lead.ValidateEmail', Value__c = 'false');

		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock(VALIDEMAIL_NOTVALIDATE));

		Lead testObj = new Lead(
			FirstName = 'John',
			LastName = 'Doe',
			Email = 'john;doe@example.com');
		Test.startTest();
			TowerDataApi api = new TowerDataApi();
			api.setObject(testObj);
			api.callApi();
			testObj = (Lead) api.appendData();
		Test.stopTest();

		//EMAIL
		System.assertEquals(true, testObj.Email_Append_Run__c);
		System.assertEquals(System.today(), testObj.Email_Append_Run_Date__c.date());
		System.assertEquals(false, testObj.Email_Checked__c);
		System.assertEquals(false, testObj.Email_Valid__c);
		System.assertEquals(false, testObj.Email_Box_Valid__c);
	}

	@isTest static void test_lead_badresponse() {

		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock(BAD_RESPONSE));

		Lead testObj = new Lead(
			FirstName = 'John',
			LastName = 'Doe',
			Email = 'john;doe@example.com');

		System.debug('AAAAA before ' + testObj);

		Test.startTest();
			TowerDataApi api = new TowerDataApi();
			api.setObject(testObj);
			Map<String, Object> response = api.callApi();
			testObj = (Lead) api.appendData();
		Test.stopTest();

		System.assertEquals(true, response.isEmpty());
	}

	@isTest static void test_lead_validate_emailvalid_with_auth() {
		//validate
		insert new TouchCR_Settings__c(Name = 'Lead.ValidateEmail', Value__c = 'true');

		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock(VALIDEMAIL_NOTVALIDATE));

		Lead testObj = new Lead(
			FirstName = 'John',
			LastName = 'Doe',
			Email = 'john;doe@example.com');

		String access_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyU0xZMU9FU1VHMzZDVFBIUlhMS1lLQ0EzIiwiaXNzIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hcHBsaWNhdGlvbnMvVWJlVU9WYlNVM1dCMVlCR05QaVl5IiwiaWF0IjoxNDg4MjgyNjA4LCJleHAiOjE0ODkxNDY2MDgsInNjb3BlIjoiIn0.5oTNt5CmE80imx4DvyZtgz8hOsaH22iePiDhT7Xpeqw';

		Map<String, String> touchCrSettingsToUpsert = new Map<String, String>();
            touchCrSettingsToUpsert.put('Endpoint.TokenPart1', access_token.substring(0, 254));
            touchCrSettingsToUpsert.put('Endpoint.TokenPart2', access_token.substring(254));
            touchCrSettingsToUpsert.put('Endpoint.TokenType', 'Bearer');
            touchCrSettingsToUpsert.put('Endpoint.ClientId', 'Test');
            touchCrSettingsToUpsert.put('Endpoint.ClientSecret', 'Test');

        TouchCRHelper.setSettings(touchCrSettingsToUpsert);

		Test.startTest();
			TowerDataApi api = new TowerDataApi();
			api.setObject(testObj);
			api.callApi();
			testObj = (Lead) api.appendData();
		Test.stopTest();

		

		Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();
        TouchCR_Settings__c tokenPart1 = settingsMap.get('Endpoint.TokenPart1');
        TouchCR_Settings__c tokenPart2 = settingsMap.get('Endpoint.TokenPart2');

		String updated_access_token = 'updatedToken' + access_token;

		//EMAIL
		System.assertEquals(true, testObj.Email_Append_Run__c);
		System.assertEquals(System.today(), testObj.Email_Append_Run_Date__c.date());
		System.assertEquals(true, testObj.Email_Checked__c);
		System.assertEquals(true, testObj.Email_Valid__c);
		System.assertEquals(true, testObj.Email_Box_Valid__c);
		//System.assertEquals(updated_access_token, tokenPart1.Value__c + tokenPart2.Value__c);
	}

}