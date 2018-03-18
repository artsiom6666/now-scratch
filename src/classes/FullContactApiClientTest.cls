@isTest
private class FullContactApiClientTest {

	@isTest static void test_account_nosettings() {
		Test.setMock(HttpCalloutMock.class, new FullContactApiMock());

		Account testObj = new Account();
		Map<String, List<SObject>> result = FullContactApiClient.makeAppend(testObj);
		// no callouts, logs list is empty
		System.assertEquals(0, result.get(FullContactApiClient.LOGS_SECTION).size());
		//no data appended
		System.assertEquals(testObj, result.get(FullContactApiClient.OBJECT_SECTION)[0]);
	}

	@isTest static void test_lead_nosettings() {
		Test.setMock(HttpCalloutMock.class, new FullContactApiMock());

		Lead testObj = new Lead();
		Map<String, List<SObject>> result = FullContactApiClient.makeAppend(testObj);
		// no callouts, logs list is empty
		System.assertEquals(0, result.get(FullContactApiClient.LOGS_SECTION).size());
		//no data appended
		System.assertEquals(testObj, result.get(FullContactApiClient.OBJECT_SECTION)[0]);
	}

	@isTest static void test_account() {
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

		Account testObj = new Account(PersonEmail = 'john.doe@email.com');
		Map<String, List<SObject>> result = FullContactApiClient.makeAppend(testObj);
		//all settings on, one callout is made
		System.assertEquals(1, result.get(FullContactApiClient.LOGS_SECTION).size());
		//no data appended
		System.assertEquals(testObj, result.get(FullContactApiClient.OBJECT_SECTION)[0]);
	}

	@isTest static void test_account_soqlstrings() {
		String resultSObject = FullContactApiClient.getSoqlStringWithoutWhereClause(new Account());
		System.assertEquals('SELECT Id, PersonEmail FROM Account', resultSObject);

		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testObj = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'john.doe@example.com'
		);
		insert testObj;

		String resultId = FullContactApiClient.getSoqlStringWithoutWhereClause(testObj.Id);
		System.assertEquals('SELECT Id, PersonEmail FROM Account', resultSObject);
	}

	@isTest static void test_lead_soqlstrings() {
		String resultSObject = FullContactApiClient.getSoqlStringWithoutWhereClause(new Lead());
		System.assertEquals('SELECT Id, Email FROM Lead', resultSObject);

		Lead testObj = new Lead(
			FirstName = 'John',
			LastName = 'Doe',
			Email = 'john.doe@example.com'
		);
		insert testObj;

		String resultId = FullContactApiClient.getSoqlStringWithoutWhereClause(testObj.Id);
		System.assertEquals('SELECT Id, Email FROM Lead', resultSObject);
	}

	@isTest static void test_batch_methods() {
		insert new TouchCR_Settings__c(Name = 'FullContact.Limit', Value__c = '0');

		Map<String, TouchCR_Settings__c> allDataSettings = FullContactApiClient.selectAndDeleteSettings(DateTime.now());
		Integer limitRecords = FullContactApiClient.getLimits(allDataSettings);
		FullContactApiClient.setDaySettings(allDataSettings, 1);

		System.assertEquals(0, limitRecords);
		FullContactApiClient.upsertTouchCRSettings(allDataSettings, 1 - limitRecords);

		List<TouchCR_Settings__c> allSettings  = [
			SELECT Id, Value__c
			FROM TouchCR_Settings__c
			WHERE Name =: 'FullContact.Excess'
		];

		System.assertEquals(1, allSettings.size());
		System.assertEquals('1', allSettings[0].Value__c);
	}

	@isTest static void test_account_invalid_email() {
		Test.setMock(HttpCalloutMock.class, new FullContactApiMock());

		Account testObj = new Account(PersonEmail = '');
		Map<String, List<SObject>> result = FullContactApiClient.makeAppend(testObj);
		// no callouts, logs list is empty
		System.assertEquals(0, result.get(FullContactApiClient.LOGS_SECTION).size());
		//no data appended
		System.assertEquals(testObj, result.get(FullContactApiClient.OBJECT_SECTION)[0]);
	}

	@isTest static void test_isapproved() {
		insert new TouchCR_Settings__c(Name = 'FullContact.DateTimeApprove', Value__c = String.valueOf(DateTime.now().addHours(25)));

		Map<String, TouchCR_Settings__c> allDataSettings = FullContactApiClient.selectAndDeleteSettings(DateTime.now());
		Boolean result = FullContactApiClient.isApproved(allDataSettings);

		System.assertEquals(true, result);
	}

	@isTest static void test_deletesettings() {
		String dateApprove = String.valueOf(DateTime.now());
		insert new TouchCR_Settings__c(Name = 'FullContact.DateTimeApprove', Value__c = dateApprove);
		insert new TouchCR_Settings__c(Name = 'FullContact.D.test', Value__c = String.valueOf(DateTime.now()));

		Map<String, TouchCR_Settings__c> allDataSettings = FullContactApiClient.selectAndDeleteSettings(DateTime.now().addHours(65));

		System.assertEquals(1, allDataSettings.size());
		TouchCR_Settings__c itemAllSettings  = [
			SELECT Id, Name, Value__c
			FROM TouchCR_Settings__c
			WHERE Name =: 'FullContact.DateTimeApprove'
		];
		System.assertEquals(dateApprove, itemAllSettings.Value__c);
	}

	@isTest static void test_sendemailtoapprove() {
		//Approver changed from FullContact to DataAppend
		insert new TouchCR_Settings__c(Name = 'DataAppend.ApproverEmail1', Value__c = 'test1@example.com');
		insert new TouchCR_Settings__c(Name = 'DataAppend.ApproverEmail2', Value__c = 'test2@example.com');
		insert new TouchCR_Settings__c(Name = 'DataAppend.ApproverEmail3', Value__c = 'test3@example.com');

		//allDataSettings changed from FullContactApiClient to TowerDataApiClient
		Map<String, TouchCR_Settings__c> allDataSettings = TowerDataApiClient.selectAndDeleteSettings(DateTime.now());
		Test.startTest();
		FullContactApiClient.sendEmailToApprove(allDataSettings, 100);
		Test.stopTest();

		System.assertEquals(1, [SELECT Id FROM Log__c].size());
	}

	@isTest static void test_batch_methodsupsert() {
		insert new TouchCR_Settings__c(Name = 'FullContact.Limit', Value__c = '0');
		insert new TouchCR_Settings__c(Name = 'FullContact.Excess', Value__c = '10');
		insert new TouchCR_Settings__c(Name = 'FullContact.Confirmed', Value__c = 'true');

		Map<String, TouchCR_Settings__c> allDataSettings = FullContactApiClient.selectAndDeleteSettings(DateTime.now());
		Integer limitRecords = FullContactApiClient.getLimits(allDataSettings);
		FullContactApiClient.setDaySettings(allDataSettings, 1);

		System.assertEquals(0, limitRecords);
		FullContactApiClient.upsertTouchCRSettings(allDataSettings, 1 - limitRecords);

		List<TouchCR_Settings__c> allSettings  = [
			SELECT Id, Value__c
			FROM TouchCR_Settings__c
			WHERE Name =: 'FullContact.Excess' OR Name =: 'FullContact.Confirmed'
			ORDER BY Name DESC
		];

		System.assertEquals(2, allSettings.size());
		System.assertEquals('1', allSettings[0].Value__c);
		System.assertEquals('false', allSettings[1].Value__c);
	}
}