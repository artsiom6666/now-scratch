@isTest
private class DataAppendSingleTest {

    @isTest static void test_invalidid() {
        Test.setMock(HttpCalloutMock.class, new TowerDataApiMock());

        Test.startTest();
            String result = DataAppendSingle.doAppend('');
        Test.stopTest();

        System.assert(result.contains('Invalid id'));
    }

    @isTest static void test_account() {
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

        Test.setMock(HttpCalloutMock.class, new TowerDataApiMock());

        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        Account testObj = new Account(
            RecordTypeId = customerRecordType.Id,
            FirstName = 'John',
            LastName = 'Doe',
            PersonEmail = 'johndoe@example.com');
        insert testObj;

        Test.startTest();
            String result = DataAppendSingle.doAppend(testObj.Id);
        Test.stopTest();

        System.assert(true, result);
    }

    @isTest static void test_lead() {
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

        Test.setMock(HttpCalloutMock.class, new TowerDataApiMock());

        Lead testObj = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@example.com');
        insert testObj;

        Test.startTest();
            String result = DataAppendSingle.doAppend(testObj.Id);
        Test.stopTest();

        System.assert(true, result);
    }

}