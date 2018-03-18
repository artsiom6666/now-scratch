@isTest
public class DataAppendAccountListViewControllerTest {

	static testMethod void test_returntoaccouts() {
		List <Account> lstAccount = new List<Account>();
		Account acc1 = new Account(Name='Test1');
		lstAccount.add(acc1);
		Account acc2 = new Account(Name='Test2');
		lstAccount.add(acc2);
		Account acc3 = new Account(Name='Test3');
		lstAccount.add(acc3);
		Account acc4 = new Account(Name='Test4');
		lstAccount.add(acc4);
		insert  lstAccount;

		Apexpages.currentPage().getParameters().put('id',acc1.id);
		Apexpages.currentPage().getParameters().put('Recordtype','Test Recordtype Id');

		Test.StartTest();
		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstAccount);
		stdSetController.setSelected(lstAccount);
		DataAppendAccountListViewController appendDataListController = new DataAppendAccountListViewController(stdSetController);
		String nextPage = appendDataListController.returnToAccouts().getUrl();
		Test.stopTest();

		System.assertEquals('/001', nextPage);

	}

	static testMethod void test_warningmessage() {
		List <Account> lstAccount = new List<Account>();
		Account acc1 = new Account(Name='Test1');
		lstAccount.add(acc1);
		Account acc2 = new Account(Name='Test2');
		lstAccount.add(acc2);
		Account acc3 = new Account(Name='Test3');
		lstAccount.add(acc3);
		Account acc4 = new Account(Name='Test4');
		lstAccount.add(acc4);
		insert  lstAccount;
		
		String nextPage;
		Apexpages.currentPage().getParameters().put('id',acc1.id);
		Apexpages.currentPage().getParameters().put('Recordtype','Test Recordtype Id');

		Test.StartTest();
		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstAccount);
		stdSetController.setSelected(lstAccount);
		DataAppendAccountListViewController appendDataListController = new DataAppendAccountListViewController(stdSetController);
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
			new TouchCR_Settings__c(Name = 'Account.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.EmailOn', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.License', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'Global.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'DataAppend.D.test', Value__c = '2'),
			new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '8')
		};
		insert settingsList;

		List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true AND DeveloperName = 'Customer_Account'];

		List <Account> lstAccount = new List<Account>();
		Account acc1 = new Account(
			FirstName = 'John', LastName = 'Doe',
			PersonEmail = 'johndoe@example.com', RecordTypeId = rtList[0].Id
		);
		lstAccount.add(acc1);
		insert  lstAccount;

		Apexpages.currentPage().getParameters().put('id',acc1.id);
		Apexpages.currentPage().getParameters().put('Recordtype','Test Recordtype Id');

		Test.StartTest();
		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstAccount);
		stdSetController.setSelected(lstAccount);
		DataAppendAccountListViewController appendDataListController = new DataAppendAccountListViewController(stdSetController);
		String nextPage = appendDataListController.init().getUrl();
		Test.stopTest();

		System.assertEquals('/001', nextPage);

		acc1 = [SELECT Email_Checked__c FROM Account WHERE Id = :acc1.Id];
		System.assertEquals(true, acc1.Email_Checked__c);
	}

	static testMethod void fc_test_settintgsok() {
		Test.setMock(HttpCalloutMock.class, new FullContactApiMock());

		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'FullContact.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'FullContact.D.test', Value__c = '2'),
			new TouchCR_Settings__c(Name = 'FullContact.Limit', Value__c = '8')
		};
		insert settingsList;

		List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true AND DeveloperName = 'Customer_Account'];

		List <Account> lstAccount = new List<Account>();
		Account acc1 = new Account(
			FirstName = 'John', LastName = 'Doe',
			PersonEmail = 'johndoe@example.com', RecordTypeId = rtList[0].Id,
			Append_Need_Append__c = true
		);
		lstAccount.add(acc1);
		insert  lstAccount;

		Apexpages.currentPage().getParameters().put('id',acc1.id);
		Apexpages.currentPage().getParameters().put('Recordtype','Test Recordtype Id');

		Test.StartTest();
		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstAccount);
		stdSetController.setSelected(lstAccount);
		DataAppendAccountListViewController appendDataListController = new DataAppendAccountListViewController(stdSetController);
		String nextPage = appendDataListController.init().getUrl();
		Test.stopTest();

		System.assertEquals('/001', nextPage);

		acc1 = [SELECT Append_Need_Append__c FROM Account WHERE Id = :acc1.Id];
		System.assertEquals(false, acc1.Append_Need_Append__c);
	}

}