@isTest
public class DataAppendSelectedBatchTest {

    @isTest static void test_needtoappendaccounts() {

        Test.setMock(HttpCalloutMock.class, new TowerDataApiMock());

        List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
            new TouchCR_Settings__c(Name = 'Account.ValidateEmail', Value__c = 'true'),
            new TouchCR_Settings__c(Name = 'Account.EnableDemographics', Value__c = 'true'),
            new TouchCR_Settings__c(Name = 'Global.EmailOn', Value__c = 'true'),
            new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'true'),
            new TouchCR_Settings__c(Name = 'Global.License', Value__c = 'apikey'),
            new TouchCR_Settings__c(Name = 'Global.APIKey', Value__c = 'apikey'),
            new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '10')
        };
        insert settingsList;

        List<Id> selectAccount = new List<Id>();
        List<Account> listAccount = new List<Account>();

        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        Account testObj1 = new Account(
            RecordTypeId = customerRecordType.Id,
            FirstName = 'John',
            LastName = 'Doe',
            PersonEmail = 'johndoe@example.com');
        insert testObj1;
        selectAccount.add(testObj1.Id);

        Test.startTest();
            DataAppendSelectedBatch job = new DataAppendSelectedBatch(selectAccount);
            database.executebatch(job, 1);
        Test.stopTest();
    
        testObj1 = [SELECT Email_Checked__c FROM Account WHERE Id = :testObj1.Id];
        System.assertEquals(true, testObj1.Email_Checked__c);
    }


    @isTest static void test_needtoappendleads() {

        Test.setMock(HttpCalloutMock.class, new TowerDataApiMock());

        List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
            new TouchCR_Settings__c(Name = 'Lead.ValidateEmail', Value__c = 'true'),
            new TouchCR_Settings__c(Name = 'Lead.EnableDemographics', Value__c = 'true'),
            new TouchCR_Settings__c(Name = 'Account.ValidateEmail', Value__c = 'true'),
            new TouchCR_Settings__c(Name = 'Account.EnableDemographics', Value__c = 'true'),
            new TouchCR_Settings__c(Name = 'Global.EmailOn', Value__c = 'true'),
            new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'false'),
            new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'true'),
            new TouchCR_Settings__c(Name = 'Global.License', Value__c = 'apikey'),
            new TouchCR_Settings__c(Name = 'Global.APIKey', Value__c = 'apikey'),
            new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '10')
        };
        insert settingsList;

        List<Id> selectAccount = new List<Id>();

        Lead testObj1 = new Lead(
            FirstName = 'Jane',
            LastName = 'Doe',
            Email = 'janedoe@example.com');
        insert testObj1;
        selectAccount.add(testObj1.Id);

        Test.startTest();
            DataAppendSelectedBatch job = new DataAppendSelectedBatch(selectAccount);
            database.executebatch(job, 1);
        Test.stopTest();

        testObj1 = [SELECT Email_Checked__c FROM Lead WHERE Id = :testObj1.Id]; 
        System.assertEquals(true, testObj1.Email_Checked__c);

    }


    @isTest static void fc_test_needtoappendaccounts() {

        Test.setMock(HttpCalloutMock.class, new FullContactApiMock());

        List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
            new TouchCR_Settings__c(Name = 'Global.EmailOn', Value__c = 'true'),
            new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'true'),
            new TouchCR_Settings__c(Name = 'FullContact.APIKey', Value__c = 'apikey'),
            new TouchCR_Settings__c(Name = 'FullContact.Limit', Value__c = '10')
        };
        insert settingsList;

        List<Id> selectAccount = new List<Id>();
        List<Account> listAccount = new List<Account>();

        Account testObj1 = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            PersonEmail = 'johndoe@example.com',
            Append_Need_Append__c = true);
        insert testObj1;
        selectAccount.add(testObj1.Id);

        Test.startTest();
            DataAppendSelectedBatch job = new DataAppendSelectedBatch(selectAccount);
            database.executebatch(job, 1);
        Test.stopTest();
    
        testObj1 = [SELECT Append_Need_Append__c FROM Account WHERE Id = :testObj1.Id];
        System.assertEquals(false, testObj1.Append_Need_Append__c);
    }


    @isTest static void fc_test_needtoappendleads() {

        Test.setMock(HttpCalloutMock.class, new FullContactApiMock());

        List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
            new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'false'),
            new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'true'),
            new TouchCR_Settings__c(Name = 'Global.License', Value__c = 'apikey'),
            new TouchCR_Settings__c(Name = 'FullContact.APIKey', Value__c = 'apikey'),
            new TouchCR_Settings__c(Name = 'FullContact.Limit', Value__c = '10')
        };
        insert settingsList;

        List<Id> selectAccount = new List<Id>();

        Lead testObj1 = new Lead(
            FirstName = 'Jane',
            LastName = 'Doe',
            Email = 'janedoe@example.com',
            Append_Need_Append__c = true);
        insert testObj1;
        selectAccount.add(testObj1.Id);

        Test.startTest();
            DataAppendSelectedBatch job = new DataAppendSelectedBatch(selectAccount);
            database.executebatch(job, 1);
        Test.stopTest();

        testObj1 = [SELECT Append_Need_Append__c FROM Lead WHERE Id = :testObj1.Id]; 
        System.assertEquals(false, testObj1.Append_Need_Append__c);
    }


}