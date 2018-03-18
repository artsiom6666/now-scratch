@isTest
public class DataAppendLeadListViewControllerTest {


    static testMethod void test_returntoaccouts() {
        List <Lead> lstLead = new List<Lead>();
        Lead testLead1 = new Lead(LastName='Test1');
        lstLead.add(testLead1);
        Lead testLead2 = new Lead(LastName='Test2');
        lstLead.add(testLead2);
        Lead testLead3 = new Lead(LastName='Test3');
        lstLead.add(testLead3);
        Lead testLead4 = new Lead(LastName='Test4');
        lstLead.add(testLead4);
        insert  lstLead;

        Apexpages.currentPage().getParameters().put('id',testLead1.id);
        Apexpages.currentPage().getParameters().put('Recordtype','Test Recordtype Id');

        Test.StartTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstLead);
        stdSetController.setSelected(lstLead);
        DataAppendLeadListViewController appendDataListController = new DataAppendLeadListViewController(stdSetController);
        String nextPage = appendDataListController.returnToLeads().getUrl();
        Test.stopTest();

        System.assertEquals('/00Q', nextPage);

    }

    static testMethod void test_warningmessage() {
        List <Lead> lstLead = new List<Lead>();
        Lead testLead1 = new Lead(LastName='Test1');
        lstLead.add(testLead1);
        Lead testLead2 = new Lead(LastName='Test2');
        lstLead.add(testLead2);
        Lead testLead3 = new Lead(LastName='Test3');
        lstLead.add(testLead3);
        Lead testLead4 = new Lead(LastName='Test4');
        lstLead.add(testLead4);
        insert  lstLead;

        String nextPage;
        Apexpages.currentPage().getParameters().put('id',testLead1.id);
        Apexpages.currentPage().getParameters().put('Recordtype','Test Recordtype Id');

        Test.StartTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstLead);
        stdSetController.setSelected(lstLead);
        DataAppendLeadListViewController appendDataListController = new DataAppendLeadListViewController(stdSetController);
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Test.stopTest();

        Boolean message = false;
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            if (msg.getSummary() == 'It is possible to exceed the limit after execution!') {
                message = true;
            }
            System.assertEquals(ApexPages.Severity.WARNING, msg.getSeverity());
        }
            System.assertEquals(true, message);
    }

    static testMethod void test_settintgsok() {
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
            new TouchCR_Settings__c(Name = 'DataAppend.D.test', Value__c = '2'),
            new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '10')
        };
        insert settingsList;

        List <Lead> lstLead = new List<Lead>();
        Lead testLead1 = new Lead(LastName='Test1', Email = 'johndoe@example.com', Status = 'New - Not Contacted' );
        lstLead.add(testLead1);
        insert  lstLead;

        Apexpages.currentPage().getParameters().put('id', testLead1.id);
        Apexpages.currentPage().getParameters().put('Recordtype', 'Test Recordtype Id');

        Test.StartTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstLead);
        stdSetController.setSelected(lstLead);
        DataAppendLeadListViewController appendDataListController = new DataAppendLeadListViewController(stdSetController);
        String nextPage = appendDataListController.init().getUrl();
        Test.stopTest();

        System.assertEquals('/00Q', nextPage);

        testLead1 = [SELECT Email_Checked__c FROM Lead WHERE Id = :testLead1.Id];
        System.assertEquals(true, testLead1.Email_Checked__c);
    }

    static testMethod void fc_test_settintgsok() {
        Test.setMock(HttpCalloutMock.class, new TowerDataApiMock());

        List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
            new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'true'),
            new TouchCR_Settings__c(Name = 'FullContact.APIKey', Value__c = 'apikey'),
            new TouchCR_Settings__c(Name = 'FullContact.D.test', Value__c = '2'),
            new TouchCR_Settings__c(Name = 'FullContact.Limit', Value__c = '8')
        };
        insert settingsList;

        List <Lead> lstLead = new List<Lead>();
        Lead testLead1 = new Lead(LastName='Test1', Email = 'johndoe@example.com', Status = 'New - Not Contacted', Append_Need_Append__c = true);
        lstLead.add(testLead1);
        insert  lstLead;

        Apexpages.currentPage().getParameters().put('id', testLead1.id);
        Apexpages.currentPage().getParameters().put('Recordtype', 'Test Recordtype Id');

        Test.StartTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstLead);
        stdSetController.setSelected(lstLead);
        DataAppendLeadListViewController appendDataListController = new DataAppendLeadListViewController(stdSetController);
        String nextPage = appendDataListController.init().getUrl();
        Test.stopTest();

        System.assertEquals('/00Q', nextPage);

        testLead1 = [SELECT Append_Need_Append__c FROM Lead WHERE Id = :testLead1.Id];
        System.assertEquals(false, testLead1.Append_Need_Append__c);

    }

}