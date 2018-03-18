@isTest
private class RestCaseControllerTest{

	static testMethod void RestCaseControllerTestCase() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account acc = new Account(
			RecordTypeId = customerRecordType.Id,
			LastName = 'Gerdegedi',
			PersonEmail = 'Gerdegedi.Itsig@gmail.com'
		);
		insert acc;

		Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		List<Contact> cont = [SELECT Id FROM Contact WHERE AccountId =: acc.Id];
		User newUser = new User(
			Alias = 'Itsig', Email = 'Itsig.Gerdegedi@gmail.com',
			EmailEncodingKey = 'UTF-8', LastName = 'Gerdegedi',
			LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
			ProfileId = profileId.Id, TimeZoneSidKey='America/Los_Angeles',
			UserName = 'Itsig.Gerdegedi@gmail.com'
		);
		insert newUser;

		Order__c order = new Order__c(
			Account__c = acc.Id, Billing_Email__c = 'test@gmail.com',
			Billing_First_Name__c = 'test', Billing_Last_Name__c = 'dx',
			Billing_Phone__c = '9876543210', Billing_Address__c = '123 main Street',
			Billing_City__c =  'New York', Billing_State__c = 'LA',
			Billing_Country__c = 'United States', Billing_Zip_Postal__c = '10035',
			Shipping_Address__c = '123 main Street', Shipping_City__c = 'New York',
			Shipping_State__c = 'LA', Shipping_Country__c = 'United States',
			Shipping_Zip_Postal__c = '10035',
			Subtotal__c = 10, Shipping__c = 2, Tax__c= 2, Named_Agent__c = 'Test Agent Name',
			Currency__c = 'US Dollar', Payment_Method__c = 'Credit Card'
		);
		insert order;

		Test.startTest();
		String result;
		result = RestCaseController.setCase(new Map<String, String>{});
		System.assertEquals(true, result.contains('success'));
		List<Case> cases = [SELECT Id, Status, Origin FROM Case];

		result = RestCaseController.setCase(new Map<String, String>{'id' => cases[0].Id, 'orderId' => 'invalidId'});
		System.assertEquals(true, result.contains('error'));
		result = RestCaseController.setCase(new Map<String, String>{'id' => cases[0].Id, 'orderId' => order.Id});
		System.assertEquals(true, result.contains('success'));

		result = RestCaseController.setCase(new Map<String, String>{'id' => cases[0].Id, 'accountId' => acc.Id});
		System.assertEquals(true, result.contains('success'));

	}
}