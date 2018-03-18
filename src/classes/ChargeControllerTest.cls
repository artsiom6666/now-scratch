@isTest
private class ChargeControllerTest {

	@isTest
	static void chargeAuthorizationTransaction() {
		Payment_Agents__c newPaymentAgents = new Payment_Agents__c(
			Name = 'Test Agent Name', Security_Key__c = 'test', Active__c = true,
			Type__c = 'Stripe', Merchant_ID__c = 'test'
		);
		insert newPaymentAgents;

		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testAcc = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'Test FName', LastName = 'Test LName',
			PersonEmail = 'test@example.com'
		);
		insert testAcc;

		Order__c order = new Order__c(
			Account__c = testAcc.Id, Subtotal__c = 1000, Named_Agent__c = 'Test Agent Name',
			Subscription__c = true, Subscription_Charge_Amount__c = 100
		);
		insert order;

		Order_Transaction__c transection = new Order_Transaction__c(
			Order__c = order.Id, Type__c = 'Authorization',
			Response_Status__c = 'Approved', Response_Message__c = 'Message',
			Payment_Response_Body__c = 'original', Payment_Profile__c = 'cus_7cBFHD6iiBaTUU',
			Named_Agent__c = 'Test Agent Name', Card_Last_4__c = '4242',
			Payment_Entity_Id__c = 'ch_19dfhSCF2TV51fDnaXu3lB1J', Payment_Date__c = Datetime.now().addDays(-1),
			Payment_Method__c = 'Credit Card', Currency__c = 'US Dollars',
			Amount__c = 11
		);
		insert transection;

		ApexPages.StandardController sc = new ApexPages.standardController(order);

		Test.startTest();
			ChargeController cc = new ChargeController(sc);
			cc.chargeOrder();
		Test.stopTest();

		List<Order_Transaction__c> resultTransactions = [
			SELECT Id, Response_Status__c, Type__c, Amount__c
			FROM Order_Transaction__c
		];

		System.assertEquals(1, resultTransactions.size());
		System.assertEquals('Approved', resultTransactions[0].Response_Status__c);
		System.assertEquals('Charge', resultTransactions[0].Type__c);
		System.assertEquals(11, resultTransactions[0].Amount__c);
	}

	@isTest
	static void chargeTransaction() {
		Payment_Agents__c newPaymentAgents = new Payment_Agents__c(
			Name = 'Test Agent Name', Security_Key__c = 'test', Active__c = true,
			Type__c = 'Stripe', Merchant_ID__c = 'test'
		);
		insert newPaymentAgents;

		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testAcc = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'Test FName', LastName = 'Test LName',
			PersonEmail = 'test@example.com'
		);
		insert testAcc;

		Order__c order = new Order__c(
			Account__c = testAcc.Id, Subtotal__c = 1000, Named_Agent__c = 'Test Agent Name',
			Subscription__c = true, Subscription_Charge_Amount__c = 100
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

		ApexPages.StandardController sc = new ApexPages.standardController(order);

		Test.startTest();
			ChargeController cc = new ChargeController(sc);
			cc.chargeOrder();
		Test.stopTest();

		List<Order_Transaction__c> resultTransactions = [
			SELECT Id, Response_Status__c, Type__c, Amount__c
			FROM Order_Transaction__c
		];

		System.assertEquals(2, resultTransactions.size());
	}

	//added for Lighting Component
	@isTest static void chargeTest() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account acc = new Account(RecordTypeId = customerRecordType.Id, LastName = 'Barack', PersonEmail = 'barack123@mail.com');
		insert acc;

		Payment_Option__c pO = new Payment_Option__c(
			Account__c = acc.Id, Last_4__c = '4242', 
			Named_Agent__c = 'HIC', Option_Id__c = 'card_1BLxQaBtLSRuiG8TeSq0hPwu', 
			Profile_Id__c = 'cus_BjppUFrz7daGx4', Status__c = 'Active'
		);
		Payment_Option__c pO1 = new Payment_Option__c(
			Account__c = acc.Id, Last_4__c = '4242', 
			Named_Agent__c = 'HIC', Option_Id__c = 'card_1BLxQaBtLSRuiG8TeSq0hPwu', 
			Profile_Id__c = 'cus_BjppUFrz7daGx4', Status__c = 'Inactive'
		); 
		insert new List<Payment_Option__c>{pO, pO1};

		Order__c testOrdCrarge = new Order__c(
			Charge_Amount__c = 2, Account__c = acc.Id, 
			Named_Agent__c = 'HIC'
		);
		insert testOrdCrarge;

		String resultCardsAndGeneralInfo = ChargeController.getCardsAndGeneralInfo(testOrdCrarge.Id);
		ResultWrapper chargeDataWrapper = (ResultWrapper)JSON.deserialize(resultCardsAndGeneralInfo, ResultWrapper.class);
			
		System.assertEquals('success', chargeDataWrapper.status);
		System.assertEquals(2, chargeDataWrapper.amount);

		resultCardsAndGeneralInfo = ChargeController.getCardsAndGeneralInfo('');
		chargeDataWrapper = (ResultWrapper)JSON.deserialize(resultCardsAndGeneralInfo, ResultWrapper.class);
			
		System.assertEquals('error', chargeDataWrapper.status);

		Map<String, String> chargeData = new Map<String, String>{
			'amount' => '2',
			'orderId' => String.valueOf(testOrdCrarge.Id),
			'month' => '01',
			'newCard' => 'true'
		};

		String resultChargeOrderNow = ChargeController.chargeOrderNow(JSON.serialize(chargeData));
		ResultWrapper chargeOrderWrapper = (ResultWrapper)JSON.deserialize(resultChargeOrderNow, ResultWrapper.class);
		
		System.assertEquals('error', chargeOrderWrapper.status);    
		System.assertEquals('Data is not valid', chargeOrderWrapper.error); 

		chargeData = new Map<String, String>{
			'amount' => '2',
			'orderId' => String.valueOf(testOrdCrarge.Id),
			'newCard' => 'false'
		};

		resultChargeOrderNow = ChargeController.chargeOrderNow(JSON.serialize(chargeData));
		chargeOrderWrapper = (ResultWrapper)JSON.deserialize(resultChargeOrderNow, ResultWrapper.class);

		System.assertEquals('error', chargeOrderWrapper.status);    

		chargeData = new Map<String, String>{
			'orderId' => String.valueOf(testOrdCrarge.Id),
			'newCard' => 'false',
			'chosenPaymentOptionId' => String.valueOf(pO.Id)
		};

		resultChargeOrderNow = ChargeController.chargeOrderNow(JSON.serialize(chargeData));
		chargeOrderWrapper = (ResultWrapper)JSON.deserialize(resultChargeOrderNow, ResultWrapper.class);

		System.assertEquals('error', chargeOrderWrapper.status);    
		System.assertEquals('The Amount must not be less than 1 Dollar', chargeOrderWrapper.error); 

		chargeData = new Map<String, String>{
			'amount' => '2',
			'orderId' => String.valueOf(testOrdCrarge.Id),
			'newCard' => 'false',
			'chosenPaymentOptionId' => String.valueOf(pO1.Id)
		};

		resultChargeOrderNow = ChargeController.chargeOrderNow(JSON.serialize(chargeData));
		chargeOrderWrapper = (ResultWrapper)JSON.deserialize(resultChargeOrderNow, ResultWrapper.class);

		System.assertEquals('error', chargeOrderWrapper.status);
		System.assertEquals('Payment Option was not found', chargeOrderWrapper.error);
				
		chargeData = new Map<String, String>{
			'amount' => '2',
			'newCard' => 'false',
			'chosenPaymentOptionId' => String.valueOf(pO.Id)
		};

		resultChargeOrderNow = ChargeController.chargeOrderNow(JSON.serialize(chargeData));
		chargeOrderWrapper = (ResultWrapper)JSON.deserialize(resultChargeOrderNow, ResultWrapper.class);

		System.assertEquals('error', chargeOrderWrapper.status);    
		System.assertEquals('Order Id was not found', chargeOrderWrapper.error);    

		chargeData = new Map<String, String>{
			'amount' => '2',
			'orderId' => String.valueOf(testOrdCrarge.Id),
			'newCard' => 'true',
			'month' => '01',
			'year' => '20',
			'ccv' => '123',
			'cardNumber' => '4242424242424242'
		};

		resultChargeOrderNow = ChargeController.chargeOrderNow(JSON.serialize(chargeData));
		chargeOrderWrapper = (ResultWrapper)JSON.deserialize(resultChargeOrderNow, ResultWrapper.class);
		
		System.assertEquals('error', chargeOrderWrapper.status);
		//todo after add global setCustomSettings method on TouchCRHelper
		//System.assertEquals('success', chargeOrderWrapper.status);    
	}

	private class ResultWrapper {
		public String status { get; set; }
		public String error { get; set; }
		public Decimal amount { get; set; }
	}   

}