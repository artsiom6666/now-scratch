@isTest
private class VoidControllerTest {

	@isTest
	static void voidTest() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testAcc = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'Test FName', LastName = 'Test LName',
			PersonEmail = 'test@example.com'
		);
		insert testAcc;

		Order__c order = new Order__c(
			Account__c = testAcc.Id, Subtotal__c = 100, Named_Agent__c = 'Test Agent Name',
			Subscription__c = true, Subscription_Charge_Amount__c = 1,
			Subscription_Frequency__c = 'Daily', Subscription_Start_Date__c = Date.today(),
			Subscription_Stop_On__c = 'Never', Status__c = 'Initiated',
			Subscription_Stop_Date__c = Date.today().addDays(5)
		);
		insert order;

		Order_Transaction__c transection = new Order_Transaction__c(
			Order__c = order.Id, Type__c = 'Charge',
			Response_Status__c = 'Approved', Response_Message__c = 'Message',
			Payment_Response_Body__c = 'original', Payment_Profile__c = 'cus_7cBFHD6iiBaTUU',
			Named_Agent__c = 'Test Agent Name', Card_Last_4__c = '4242',
			Payment_Entity_Id__c = 'ch_19dfhSCF2TV51fDnaXu3lB1J', Payment_Date__c = Datetime.now().addDays(-1),
			Payment_Method__c = 'Credit Card', Currency__c = 'US Dollars',
			Amount__c = 11
		);
		insert transection;

		ApexPages.StandardController sc = new ApexPages.standardController(transection);

		Test.startTest();
			VoidController vc = new VoidController(sc);
			vc.voidTransactionNow();
		Test.stopTest();

		List<Order_Transaction__c> resultTransactions = [
			SELECT Id, Response_Status__c, Payment_Attempt__c, Type__c
			FROM Order_Transaction__c
			WHERE Id =: transection.Id
		];

		System.assertEquals('Approved', resultTransactions[0].Response_Status__c);
		System.assertEquals('Void', resultTransactions[0].Type__c);
	}

	@isTest
	static void voidNotTest() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testAcc = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'Test FName', LastName = 'Test LName',
			PersonEmail = 'test@example.com'
		);
		insert testAcc;

		Order__c order = new Order__c(
			Account__c = testAcc.Id, Subtotal__c = 100, Named_Agent__c = 'Test Agent Name',
			Subscription__c = true, Subscription_Charge_Amount__c = 1,
			Subscription_Frequency__c = 'Daily', Subscription_Start_Date__c = Date.today(),
			Subscription_Stop_On__c = 'Never', Status__c = 'Initiated',
			Subscription_Stop_Date__c = Date.today().addDays(5)
		);
		insert order;

		Order_Transaction__c transection = new Order_Transaction__c(
			Order__c = order.Id, Type__c = 'Refund',
			Response_Status__c = 'Approved', Response_Message__c = 'Message',
			Payment_Response_Body__c = 'original', Payment_Profile__c = 'cus_7cBFHD6iiBaTUU',
			Named_Agent__c = 'Test Agent Name', Card_Last_4__c = '4242',
			Payment_Entity_Id__c = 'ch_19dfhSCF2TV51fDnaXu3lB1J', Payment_Date__c = Datetime.now().addDays(-1),
			Payment_Method__c = 'Credit Card', Currency__c = 'US Dollars',
			Amount__c = 11
		);
		insert transection;

		ApexPages.StandardController sc = new ApexPages.standardController(transection);

		Test.startTest();
			VoidController vc = new VoidController(sc);
			vc.voidTransactionNow();
		Test.stopTest();

		List<Order_Transaction__c> resultTransactions = [
			SELECT Id, Response_Status__c, Payment_Attempt__c, Type__c
			FROM Order_Transaction__c
			WHERE Id =: transection.Id
		];

		System.assertEquals('Approved', resultTransactions[0].Response_Status__c);
		System.assertEquals('Refund', resultTransactions[0].Type__c);
	}

	//added for Lighting Component
	@isTest static void voidTestLighting() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account acc = new Account(
			RecordTypeId = customerRecordType.Id,
			LastName = 'Gerdegedi', FirstName = 'Itsig',
			PersonEmail = 'Gerdegedi.Itsig@gmail.com', Phone = '1234567890',
			BillingStreet = 'Vulture St, Woolloongabba', BillingCity = 'Brisbane',
			BillingState = 'Queensland', BillingPostalCode = '4102',
			BillingCountry = 'Australia', ShippingStreet = 'Vulture St, Woolloongabba',
			ShippingCity = 'Brisbane', ShippingState = 'Queensland',
			ShippingPostalCode = '4102', ShippingCountry = 'Australia'
//          Geolocation__Longitude__s = 153.062496, Geolocation__Latitude__s = -27.579233
		);
		insert acc;

		Order__c order = new Order__c(
			Charge_Amount__c = 1,
			Account__c = acc.Id
		);
		insert order;
		
		Order_Transaction__c testTrans = new Order_Transaction__c(
			Order__c = order.Id,
			Named_Agent__c = 'Test Agent Name',
			Type__c = 'Charge',
			Response_Status__c = 'Approved',
			Payment_Date__c = Datetime.now(),
			Amount__c = 1
		);
		insert testTrans;

		Decimal amount = VoidController.getAmount(testTrans.Id);
		System.assertEquals(1, amount);

		String resultVoid = VoidController.voidNow(testTrans.Id, 1);
		System.assertEquals(true, resultVoid.containsIgnoreCase('Your transaction has been approved.'));
	}

}