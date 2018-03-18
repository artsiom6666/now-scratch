@isTest
private class AuthorizeControllerTest {

	@isTest
	static void approvedAuthorizeTest() {
		Payment_Agents__c newPaymentAgents = new Payment_Agents__c(
			Name = 'Test Agent Name', Security_Key__c = 'test', Active__c = true,
			Type__c = 'Stripe', Merchant_ID__c = 'test'
		);
		insert newPaymentAgents;

		Account testAcc = new Account(
			FirstName = 'Test FName', LastName = 'Test LName',
			PersonEmail = 'test@example.com'
		);
		insert testAcc;

		Order__c order = new Order__c(
			Account__c = testAcc.Id, Subtotal__c = 1000, Named_Agent__c = 'Test Agent Name',
			Subscription__c = true, Subscription_Charge_Amount__c = 100
		);
		insert order;

		ApexPages.StandardController sc = new ApexPages.standardController(order);

		Test.startTest();
			AuthorizeController ac = new AuthorizeController(sc);
			ac.cardNumber = '4242424242424242';
			ac.cardType = 'Visa';
			ac.cardExpirationYear = String.valueOf(Date.today().year() + 1);
			ac.cardExpirationMonth = '01';
			ac.ccv = '123';
			ac.authorizeOrderNow();
		Test.stopTest();

		List<Order_Transaction__c> resultTransactions = [
			SELECT Id, Response_Status__c, Type__c
			FROM Order_Transaction__c
		];

		System.assertEquals(1, resultTransactions.size());
		System.assertEquals('Approved', resultTransactions[0].Response_Status__c);
		System.assertEquals('Authorization', resultTransactions[0].Type__c);
	}

	@isTest
	static void notAuthorizeTest() {
		Account testAcc = new Account(
			FirstName = 'Test FName', LastName = 'Test LName',
			PersonEmail = 'test@example.com'
		);
		insert testAcc;

		Subscription__c subscription = new Subscription__c(
			Account__c = testAcc.Id,
			Active__c = true,
			Charge_Amount__c = 0
		);
		insert subscription;

		Order__c order = new Order__c(
			Account__c = testAcc.Id,
			Subtotal__c = 1000,
			Named_Agent__c = 'Test Agent Name',
			Subscription_To__c = subscription.Id
		);
		insert order;

		ApexPages.StandardController sc = new ApexPages.standardController(order);

		AuthorizeController ac = new AuthorizeController(sc);
		ac.cardNumber = '4242424242424242';
		System.assertEquals(null, ac.authorizeOrderNow());

		ac.ccv = '424';
		System.assertEquals(null, ac.authorizeOrderNow());
	}

	//added for Lighting Component
	@isTest static void authorizeTest() {
		Account acc = new Account(
			LastName = 'Gerdegedi', FirstName = 'Itsig',
			PersonEmail = 'Gerdegedi.Itsig@gmail.com', Phone = '1234567890',
			BillingStreet = 'Vulture St, Woolloongabba', BillingCity = 'Brisbane',
			BillingState = 'Queensland', BillingPostalCode = '4102',
			BillingCountry = 'Australia',
			ShippingStreet = 'Vulture St, Woolloongabba',
			ShippingCity = 'Brisbane', ShippingState = 'Queensland',
			ShippingPostalCode = '4102', ShippingCountry = 'Australia'
		);
		insert acc;

		Order__c order = new Order__c(
			Charge_Amount__c = 2,
			Account__c = acc.Id
		);
		insert order;

		Decimal amount = AuthorizeController.getAmount(order.Id);
		System.assertEquals(2, amount);

		Map<String, String> authorizeData = new Map<String, String>{
			'cardExpirationMonth' => '01',
			'cardExpirationYear' => '2018',
			'ccv' => '123',
			'cardNumber' => '4242424242424242',
			'recordId' => String.valueOf(order.Id),
			'amount' => String.valueOf(amount)
		};

		String resultAuthorize = AuthorizeController.authorizeOrderNow(JSON.serialize(authorizeData));
		System.assertEquals(true, resultAuthorize.containsIgnoreCase('success'));
	}


}