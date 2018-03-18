@isTest
private class TowerDataApiClientTest {

    @isTest static void test_account_nosettings() {
        Test.setMock(HttpCalloutMock.class, new TowerDataApiMock());

        Account testObj = new Account();
        Map<String, List<SObject>> result = TowerDataAPIClient.makeAppend(testObj);
        // no callouts, logs list is empty
        System.assertEquals(0, result.get(TowerDataAPIClient.LOGS_SECTION).size());
        //no data appended
        System.assertEquals(testObj, result.get(TowerDataAPIClient.OBJECT_SECTION)[0]);
    }

    @isTest static void test_lead_nosettings() {
        Test.setMock(HttpCalloutMock.class, new TowerDataApiMock());

        Lead testObj = new Lead();
        Map<String, List<SObject>> result = TowerDataAPIClient.makeAppend(testObj);
        // no callouts, logs list is empty
        System.assertEquals(0, result.get(TowerDataAPIClient.LOGS_SECTION).size());
        //no data appended
        System.assertEquals(testObj, result.get(TowerDataAPIClient.OBJECT_SECTION)[0]);
    }

    @isTest static void test_account() {
        Test.setMock(HttpCalloutMock.class, new TowerDataApiMock());

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

		Account testObj = new Account(PersonEmail = 'john.doe@email.com');
        Map<String, List<SObject>> result = TowerDataAPIClient.makeAppend(testObj);
        //all settings on, two callouts are made
        System.assertEquals(2, result.get(TowerDataAPIClient.LOGS_SECTION).size());
        //no data appended
        System.assertEquals(testObj, result.get(TowerDataAPIClient.OBJECT_SECTION)[0]);
    }

    @isTest static void test_account_soqlstrings() {
        String resultSObject = TowerDataAPIClient.getSoqlStringWithoutWhereClause(new Account());
        String codeFields = TouchCRHelper.isSCPEnabled() == TRUE ? ' ,BillingStateCode ' : '';
        System.assertEquals('SELECT Id, FirstName, LastName, EAM_Date_First_Seen__c, EAM_Month_Last_Opened__c, EAM_Velocity__c, EAM_Popularity__c, Email_Box_Valid__c, Email_Valid__c, PersonEmail, BillingStreet, BillingCity, BillingPostalCode ' + codeFields + ' FROM Account', resultSObject);

        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        Account testObj = new Account(
            RecordTypeId = customerRecordType.Id,
            FirstName = 'John',
            LastName = 'Doe',
            PersonEmail = 'john.doe@example.com'
        );
        insert testObj;

        String resultId = TowerDataAPIClient.getSoqlStringWithoutWhereClause(testObj.Id);
        System.assertEquals('SELECT Id, FirstName, LastName, EAM_Date_First_Seen__c, EAM_Month_Last_Opened__c, EAM_Velocity__c, EAM_Popularity__c, Email_Box_Valid__c, Email_Valid__c, PersonEmail, BillingStreet, BillingCity, BillingPostalCode ' + codeFields + ' FROM Account', resultSObject);
    }

    @isTest static void test_lead_soqlstrings() {
        String resultSObject = TowerDataAPIClient.getSoqlStringWithoutWhereClause(new Lead());
        String codeFields = TouchCRHelper.isSCPEnabled() == TRUE ? ' ,StateCode ' : '';
        System.assertEquals('SELECT Id, FirstName, LastName, EAM_Date_First_Seen__c, EAM_Month_Last_Opened__c, EAM_Velocity__c, EAM_Popularity__c, Email_Box_Valid__c, Email_Valid__c, Email, Street, City, PostalCode ' + codeFields + ' FROM Lead', resultSObject);

        Lead testObj = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com'
        );
        insert testObj;

        String resultId = TowerDataAPIClient.getSoqlStringWithoutWhereClause(testObj.Id);
        System.assertEquals('SELECT Id, FirstName, LastName, EAM_Date_First_Seen__c, EAM_Month_Last_Opened__c, EAM_Velocity__c, EAM_Popularity__c, Email_Box_Valid__c, Email_Valid__c, Email, Street, City, PostalCode ' + codeFields + ' FROM Lead', resultSObject);
    }

    @isTest static void test_batch_methods() {
        insert new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '0');

        Map<String, TouchCR_Settings__c> allDataSettings = TowerDataApiClient.selectAndDeleteSettings(DateTime.now());
        Integer limitRecords = TowerDataApiClient.getLimits(allDataSettings);
        TowerDataApiClient.setDaySettings(allDataSettings, 1);

        System.assertEquals(0, limitRecords);
        TowerDataApiClient.upsertTouchCRSettings(allDataSettings, 1 - limitRecords);

        List<TouchCR_Settings__c> allSettings  = [
            SELECT Id, Value__c
            FROM TouchCR_Settings__c
            WHERE Name =: 'DataAppend.Excess'
        ];

        System.assertEquals(1, allSettings.size());
        System.assertEquals('1', allSettings[0].Value__c);
    }

    @isTest static void test_account_nosettings_email_corrections() {
        Test.setMock(HttpCalloutMock.class, new TowerDataApiMock());

        Account testObj = new Account(Email_Corrections__c = 'test');
        Map<String, List<SObject>> result = TowerDataAPIClient.makeAppend(testObj);
        // no callouts, logs list is empty
        System.assertEquals(0, result.get(TowerDataAPIClient.LOGS_SECTION).size());
        System.assertEquals(1, result.get(TowerDataAPIClient.CASE_SECTION).size());
        Case itemCase = (Case)result.get(TowerDataAPIClient.CASE_SECTION)[0];
        System.assertEquals('test', itemCase.Description);
        System.assertEquals(testObj.Id, itemCase.AccountId);
        //no data appended
        System.assertEquals(testObj, result.get(TowerDataAPIClient.OBJECT_SECTION)[0]);
    }

    @isTest static void test_isapproved() {
        insert new TouchCR_Settings__c(Name = 'DataAppend.DateTimeApprove', Value__c = String.valueOf(DateTime.now().addHours(25)));

        Map<String, TouchCR_Settings__c> allDataSettings = TowerDataApiClient.selectAndDeleteSettings(DateTime.now());
        Boolean result = TowerDataApiClient.isApproved(allDataSettings);

        System.assertEquals(true, result);
    }

    @isTest static void test_deletesettings() {
        String dateApprove = String.valueOf(DateTime.now());
        insert new TouchCR_Settings__c(Name = 'DataAppend.DateTimeApprove', Value__c = dateApprove);
        insert new TouchCR_Settings__c(Name = 'DataAppend.D.test', Value__c = String.valueOf(DateTime.now()));

        Map<String, TouchCR_Settings__c> allDataSettings = TowerDataApiClient.selectAndDeleteSettings(DateTime.now().addHours(65));

        System.assertEquals(1, allDataSettings.size());
        TouchCR_Settings__c itemAllSettings  = [
            SELECT Id, Name, Value__c
            FROM TouchCR_Settings__c
            WHERE Name =: 'DataAppend.DateTimeApprove'
        ];
        System.assertEquals(dateApprove, itemAllSettings.Value__c);
    }

    @isTest static void test_sendemailtoapprove() {
        insert new TouchCR_Settings__c(Name = 'DataAppend.ApproverEmail1', Value__c = 'test1@example.com');
        insert new TouchCR_Settings__c(Name = 'DataAppend.ApproverEmail2', Value__c = 'test2@example.com');
        insert new TouchCR_Settings__c(Name = 'DataAppend.ApproverEmail3', Value__c = 'test3@example.com');

        Map<String, TouchCR_Settings__c> allDataSettings = TowerDataApiClient.selectAndDeleteSettings(DateTime.now());
        Test.startTest();
        TowerDataApiClient.sendEmailToApprove(allDataSettings, 100);
        Test.stopTest();

		System.assertEquals(1, [SELECT Id FROM Log__c].size());
    }

    @isTest static void test_batch_methodsupsert() {
        insert new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '0');
        insert new TouchCR_Settings__c(Name = 'DataAppend.Excess', Value__c = '10');
        insert new TouchCR_Settings__c(Name = 'DataAppend.Confirmed', Value__c = 'true');

        Map<String, TouchCR_Settings__c> allDataSettings = TowerDataApiClient.selectAndDeleteSettings(DateTime.now());
        Integer limitRecords = TowerDataApiClient.getLimits(allDataSettings);
        TowerDataApiClient.setDaySettings(allDataSettings, 1);

        System.assertEquals(0, limitRecords);
        TowerDataApiClient.upsertTouchCRSettings(allDataSettings, 1 - limitRecords);

        List<TouchCR_Settings__c> allSettings  = [
            SELECT Id, Value__c
            FROM TouchCR_Settings__c
            WHERE Name =: 'DataAppend.Excess' OR Name =: 'DataAppend.Confirmed'
        ];

        System.assertEquals(2, allSettings.size());
        //System.assertEquals('1', allSettings[0].Value__c);
        //System.assertEquals('false', allSettings[1].Value__c);
    }
}