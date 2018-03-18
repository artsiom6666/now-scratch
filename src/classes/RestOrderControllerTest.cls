@isTest
private class RestOrderControllerTest {

	private static Account insertAccount() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true AND IsActive = true];
		Account acc = new Account(
			RecordTypeId = customerRecordType.Id,
			LastName = 'Gerdegedi', FirstName = 'Itsig',
			PersonEmail = 'Gerdegedi.Itsig@gmail.com', Phone = '1234567890',
			BillingStreet = 'Vulture St, Woolloongabba', BillingCity = 'Brisbane',
			BillingState = 'Queensland', BillingPostalCode = '4102',
			BillingCountry = 'Australia', ShippingStreet = 'Vulture St, Woolloongabba',
			ShippingCity = 'Brisbane', ShippingState = 'Queensland',
			ShippingPostalCode = '4102', ShippingCountry = 'Australia',
			Last4__c = '4242'
		);
		insert acc;
		return acc;
	}

	private static Order_Transaction__c insertTransaction(Id orderId) {	
		Order_Transaction__c trans = new Order_Transaction__c(
			Order__c = orderId,
			Amount__c = 1,
			Card_Type__c = 'credit',
			Type__c = 'Charge',
			Response_Status__c = 'Approved',
			Payment_Date__c = Datetime.now(),
			Response_Message__c = 'Message',
			Payment_Response_Body__c = 'original',
			Payment_Profile__c = 'cus_7cBFHD6iiBaTUU',
			Named_Agent__c = 'Stripe',
			Card_Last_4__c = '4242',
			Payment_Entity_Id__c = 'card_1A4lgrCF2TV51fDnD0sQWldG'
		);
		insert trans;
		return trans;
	}

	private static Order__c insertOrder(Id accId, Id territoryId) {
		Order__c order = new Order__c(
			Account__c = accId, Billing_Email__c = 'test@gmail.com',
			Billing_First_Name__c = 'test', Billing_Last_Name__c = 'dx',
			Billing_Phone__c = '9876543210', Billing_Address__c = '123 main Street',
			Billing_City__c =  'New York', Billing_State__c = 'LA',
			Billing_Country__c = 'United States', Billing_Zip_Postal__c = '10035',
			Shipping_Address__c = '123 main Street', Shipping_City__c = 'New York',
			Shipping_State__c = 'LA', Shipping_Country__c = 'United States',
			Shipping_Zip_Postal__c = '10035', Named_Agent__c = 'Test Agent Name',
			Subtotal__c = 10, Shipping__c = 2, Tax__c = 2, 
			Currency__c = 'US Dollar', Payment_Method__c = 'Credit Card'
		);
		insert order;
		return order;
	}

	static testMethod void RestOrderControllerTestSetOrderRollback() {
		Account acc = insertAccount();
		Map<String, String> generalData = new Map<String, String> {
			'accountId' => String.valueOf(acc.id),
			'shippingPostalCode' => '9999'
		};

		RestHelper.DataForOrderItems dataForOrderItems = new RestHelper.DataForOrderItems();
		String result;

		result = RestOrderController.setOrder(generalData, dataForOrderItems);
		System.assertEquals(true, result.contains('error'));

		Account testRollback = [SELECT Id, ShippingPostalCode FROM Account LIMIT 1];
		System.assertEquals('4102', testRollback.ShippingPostalCode);
	}

	static testMethod void RestOrderControllerTestChargeOrder() {
		   Account acc = insertAccount();

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

		Map<String,String> newTouchCRSettings = new Map<String, String> {
			'MinFraud.ApiKey' => 'd4yoixUX1g1U',
			'MinFraud.RatingFirst' => '30',
			'MinFraud.RatingSecond' => '75'
		};
		TouchCRHelper.setSettings(newTouchCRSettings);

		Test.startTest();
		String result;
		result = RestOrderController.chargeOrder(
			new Map<String, String>{
				'orderId' => 'invalidId'
			},
			new Map<String, String>{
				'CardCCV' => '242',
				'CardExpirationYear' => '19',
				'CardExpirationMonth' => '12',
				'CardNumber' => '4242424242424242'
			}
		);
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.chargeOrder(
			new Map<String, String>{
				'orderId' => order.Id
			},
			new Map<String, String>{
				'CardCCV' => '242',
				'CardExpirationYear' => '31',
				'CardExpirationMonth' => '12',
				'CardNumber' => '4242424242424242'
			}
		);
		System.assertEquals(true, result.contains('success'));
		Test.stopTest();
	}

	static testMethod void RestOrderControllerTestUpsellOrder() {
		Account acc = insertAccount();

		Order__c order1 = new Order__c(
			Account__c = acc.Id,
			Charge_Amount__c = 1
		);
		Order__c order2 = new Order__c(
			Account__c = acc.Id,
			Charge_Amount__c = 1
		);
		insert new List<Order__c>{order1, order2};

		Order_Transaction__c trans = new Order_Transaction__c(
			Order__c = order1.Id,
			Amount__c = 1,
			Card_Type__c = 'credit',
			Type__c = 'Charge',
			Response_Status__c = 'Approved',
			Payment_Date__c = Datetime.now(),
			Response_Message__c = 'Message',
			Payment_Response_Body__c = 'original',
			Payment_Profile__c = 'cus_7cBFHD6iiBaTUU',
			Named_Agent__c = 'Stripe',
			Card_Last_4__c = '4242',
			Payment_Entity_Id__c = 'card_1A4lgrCF2TV51fDnD0sQWldG'
		);
		insert trans;

		Test.startTest();
		String result;
		result = RestOrderController.chargeUpsell(new Map<String, String>{});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.chargeUpsell(new Map<String, String>{'orderId' => 'invalidId'});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.chargeUpsell(new Map<String, String>{'orderId' => order2.Id});
		System.assertEquals(true, result.contains('success'));
		Test.stopTest();
	}

	static testMethod void RestOrderControllerTestGetOrders() {
		Account acc = insertAccount();

		Order__c order = new Order__c(
			Charge_Amount__c = 1,
			Status__c = 'Initiated',
			Account__c = acc.Id
		);
		insert order;

		Order_Transaction__c trans = new Order_Transaction__c(
			Order__c = order.Id,
			Amount__c = 1,
			Card_Last_4__c = '4242',
			Card_Type__c = 'credit',
			Type__c = 'Charge',
			Response_Status__c = 'Approved',
			Payment_Date__c = Datetime.now()
		);
		insert trans;

		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pricebook2 = new Pricebook2(
//			Name = 'QLD',					//Ready for use not Standard Price Book
			Name = 'Standard Price Book',
			IsActive = true
		);
		insert pricebook2;

		Product2 iceCreamProduct = new Product2(
			Name = 'iceCreamProduct',
			ProductCode = 'iceCreamProductCode',
			IsActive = true
		);
		insert iceCreamProduct;

		insert new List<PricebookEntry> {
			new PricebookEntry(
				Product2Id = iceCreamProduct.Id,
				Pricebook2Id = pricebookId,
				UnitPrice = 5,
				IsActive = true
			),
			new PricebookEntry(
				Product2Id = iceCreamProduct.Id,
				Pricebook2Id = pricebook2.Id,
				UnitPrice = 5,
				IsActive = true
			)
		};

		OrderItem__c orderItem = new OrderItem__c(
			Order__c = order.Id,
			Product__c = iceCreamProduct.Id,
			Product_Price__c = 1,
			Quantity__c = 1
		);
		insert orderItem;

		Test.startTest();
		String result;
		result = RestOrderController.getOrders(new Map<String, String>{});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.getOrders(new Map<String, String>{'accountId' => 'invalidId'});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.getOrders(new Map<String, String>{'accountId' => acc.Id});
		System.assertEquals(true, result.contains('success'));
		Test.stopTest();
	}


	static testMethod void RestOrderControllerTestGetOrder() {
		Account acc = insertAccount();

		Order__c order = new Order__c(
			Charge_Amount__c = 1,
			Account__c = acc.Id
		);
		insert order;

		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pricebook2 = new Pricebook2(
//			Name = 'QLD',					//Ready for use not Standard Price Book
			Name = 'Standard Price Book',
			IsActive = true
		);
		insert pricebook2;

		Product2 iceCreamProduct = new Product2(
			Name = 'iceCreamProduct',
			ProductCode = 'iceCreamProductCode',
			IsActive = true
		);
		insert iceCreamProduct;

		insert new List<Product_Image__c> {
			new Product_Image__c(
				Image_URL__c = 'https://cdn.shopify.com/s/files/1/0942/9930/products/Bronzer_Open_Bali_1_1024x1024.jpg?v=1500302809',
				Display_Order__c = 1,
				Product_Lookup__c = iceCreamProduct.id
			),
			new Product_Image__c(
				Image_URL__c = 'https://cdn.shopify.com/s/files/1/0942/9930/products/Bronzer_Open_Bali_0_1024x1024.jpg?v=1500302809',
				Display_Order__c = 0,
				Product_Lookup__c = iceCreamProduct.id
			)
		};

		insert new List<PricebookEntry> {
			new PricebookEntry(
				Product2Id = iceCreamProduct.Id,
				Pricebook2Id = pricebookId,
				UnitPrice = 5,
				IsActive = true
			),
			new PricebookEntry(
				Product2Id = iceCreamProduct.Id,
				Pricebook2Id = pricebook2.Id,
				UnitPrice = 5,
				IsActive = true
			)
		};

		OrderItem__c orderItem = new OrderItem__c(
			Order__c = order.Id,
			Product__c = iceCreamProduct.Id,
			Product_Price__c = 1,
			Quantity__c = 1
		);
		insert orderItem;

		Test.startTest();
		String result;
		result = RestOrderController.getOrder(new Map<String, String>{});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.getOrder(new Map<String, String>{'orderId' => 'invalidId'});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.getOrder(new Map<String, String>{'orderId' => order.Id});
		System.assertEquals(true, result.contains('success'));
		Test.stopTest();
	}

	static testMethod void RestOrderControllerTestTransactions() {
		Account acc = insertAccount();

		Order__c order = new Order__c(
			Charge_Amount__c = 1,
			Account__c = acc.Id
		);
		insert order;

		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pricebook2 = new Pricebook2(
//			Name = 'QLD',					//Ready for use not Standard Price Book
			Name = 'Standard Price Book',
			IsActive = true
		);
		insert pricebook2;

		Product2 iceCreamProduct = new Product2(
			Name = 'iceCreamProduct',
			ProductCode = 'iceCreamProductCode',
			IsActive = true
		);
		insert iceCreamProduct;

		insert new List<PricebookEntry> {
			new PricebookEntry(
				Product2Id = iceCreamProduct.Id,
				Pricebook2Id = pricebookId,
				UnitPrice = 5,
				IsActive = true
			),
			new PricebookEntry(
				Product2Id = iceCreamProduct.Id,
				Pricebook2Id = pricebook2.Id,
				UnitPrice = 5,
				IsActive = true
			)
		};

		OrderItem__c orderItem = new OrderItem__c(
			Order__c = order.Id,
			Product__c = iceCreamProduct.Id,
			Product_Price__c = 1,
			Quantity__c = 1
		);
		insert orderItem;

		Order_Transaction__c trans = new Order_Transaction__c(
			Order__c = order.Id,
			Amount__c = 10.5,
			Card_Last_4__c = '4242',
			Card_Type__c = 'credit',
			Type__c  = 'Charge',
			Payment_Date__c = Datetime.now()
		);
		insert trans;

		Test.startTest();
		String result;
		result = RestOrderController.getCardInfo(new Map<String, String>{});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.getCardInfo(new Map<String, String>{'accountId' => 'invalidId'});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.getCardInfo(new Map<String, String>{'accountId' => acc.Id});
		System.assertEquals(true, result.contains('success'));
		Test.stopTest();
	}

	static testMethod void RestOrderControllerTestGetOrdersTransactions() {
		Account acc = insertAccount();

		Order__c order = new Order__c(
			Charge_Amount__c = 1,
			Account__c = acc.Id
		);
		insert order;

		Product2 iceCreamProduct = new Product2(
			Name = 'iceCreamProduct',
			ProductCode = 'iceCreamProductCode',
			IsActive = true
		);
		insert iceCreamProduct;

		OrderItem__c orderItem = new OrderItem__c(
			Order__c = order.Id,
			Product__c = iceCreamProduct.Id,
			Product_Price__c = 1,
			Quantity__c = 1
		);
		insert orderItem;

		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pricebook2 = new Pricebook2(
//			Name = 'QLD',					//Ready for use not Standard Price Book
			Name = 'Standard Price Book',
			IsActive = true
		);
		insert pricebook2;

		insert new List<PricebookEntry> {
			new PricebookEntry(
				Product2Id = iceCreamProduct.Id,
				Pricebook2Id = pricebookId,
				UnitPrice = 5,
				IsActive = true
			),
			new PricebookEntry(
				Product2Id = iceCreamProduct.Id,
				Pricebook2Id = pricebook2.Id,
				UnitPrice = 5,
				IsActive = true
			)
		};

		Order_Transaction__c trans = new Order_Transaction__c(
			Order__c = order.Id, Amount__c = 10.5,
			Card_Last_4__c = '4242', Card_Type__c = 'credit',
			Type__c  = 'Charge', Payment_Date__c = Datetime.now(),
			Response_Status__c = 'Approved', Payment_Response_Body__c = 'test'
		);
		insert trans;

		Test.startTest();
		String result;
		result = RestOrderController.getOrdersTransactions(new Map<String, String>{});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.getOrdersTransactions(new Map<String, String>{'accountId' => 'invalidId'});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.getOrdersTransactions(new Map<String, String>{'accountId' => acc.Id});
		System.assertEquals(true, result.contains('success'));
		Test.stopTest();
	}

	static testMethod void RestOrderControllerTestAuthorizeOrder() {
		Account acc = insertAccount();

		Test.startTest();
		String result;
		result = RestOrderController.setAuthorizeOrder(new Map<String, String>{});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.setAuthorizeOrder(new Map<String, String>{'accountId' => 'invalidId'});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.setAuthorizeOrder(new Map<String, String>{'accountId' => acc.Id, 'last4' => '4242'});
		System.assertEquals(true, result.contains('success'));

		Map<String, String> resultAuthorizeOrder = (Map<String, String>)JSON.deserialize(result, Map<String, String>.class);
		Id orderId = Id.valueOf(resultAuthorizeOrder.get('orderId'));

		result = RestOrderController.authorizePaymentOption(new Map<String, String>{}, new Map<String, String>{});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.authorizePaymentOption(new Map<String, String>{'orderId' => 'invalidId'}, new Map<String, String>{});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.authorizePaymentOption(new Map<String, String>{'orderId' => orderId}, new Map<String, String>{});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.authorizePaymentOption(new Map<String, String>{'orderId' => orderId}, new Map<String, String>{
			'CardNumber' => '4242424242424242',
			'CardExpirationMonth' => '01',
			'CardExpirationYear' => '01',
			'CardCCV' => '123'
		});

		System.assertEquals(true, result.contains('success'));
		Test.stopTest();
	}

	static testMethod void RestOrderControllerTestRemovePaymentOption() {
		Account acc = insertAccount();

		Payment_Option__c paymentOption = new Payment_Option__c(
			Status__c = 'Active', Profile_Id__c = 'ProfileId',
			Option_Id__c = 'OptionId', Named_Agent__c = 'Stripe',
			Last_4__c = '4242', Account__c = acc.Id
		);
		Payment_Option__c paymentOption1 = new Payment_Option__c(
			Status__c = 'Active', Profile_Id__c = 'ProfileId',
			Option_Id__c = 'OptionId', Named_Agent__c = 'Stripe',
			Last_4__c = '4444', Account__c = acc.Id
		);
		insert new List<Payment_Option__c>{paymentOption, paymentOption1};	

		Test.startTest();
		String result;

		result = RestOrderController.removePaymentOption(new Map<String, String>{});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.removePaymentOption(new Map<String, String>{'paymentOptionId' => 'invalidId'});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.removePaymentOption(new Map<String, String>{'paymentOptionId' => paymentOption.Id});
		System.assertEquals(true, result.contains('success'));

		List<Payment_Option__c> inactivePaymentOption = [
			SELECT Id, Status__c 
			FROM Payment_Option__c 
			WHERE Id =: paymentOption.Id
		];

		System.assertEquals(1, inactivePaymentOption.size());
		System.assertEquals('Inactive', inactivePaymentOption[0].Status__c);

		List<Account> accs = [SELECT Id, Last4__c FROM Account WHERE Id =: acc.Id];
		System.assertEquals(null, accs[0].Last4__c);

		result = RestOrderController.removePaymentOption(new Map<String, String>{'paymentOptionId' => paymentOption1.Id});
		System.assertEquals(true, result.contains('success'));
		
		List<Payment_Option__c> inactivePaymentOptions = [
			SELECT Id, Status__c 
			FROM Payment_Option__c 
			WHERE Status__c = 'Inactive'
		];

		System.assertEquals(2, inactivePaymentOptions.size());
		Test.stopTest();
	}

	static testMethod void RestOrderControllerTestRefundAndDeleteOrder() {
		Account acc = insertAccount();

		Order__c order = insertOrder(acc.Id, null);

		Order_Transaction__c trans = insertTransaction(order.Id);

		Test.startTest();
		String result;

		result = RestOrderController.refundTransaction(new Map<String, String>{});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.refundTransaction(new Map<String, String>{'transactionId' => 'invalidId'});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.refundTransaction(new Map<String, String>{'transactionId' => trans.Id});
		System.assertEquals(true, result.contains('success'));

		result = RestOrderController.deleteOrder(new Map<String, String>{});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.deleteOrder(new Map<String, String>{'orderId' => 'invalidId'});
		System.assertEquals(true, result.contains('error'));
		result = RestOrderController.deleteOrder(new Map<String, String>{'orderId' => order.Id});
		System.assertEquals(true, result.contains('success'));


		List<Order__c> orders = [SELECT Id FROM Order__c WHERE Id =: order.Id];
		System.assertEquals(true, orders.isEmpty());

		Test.stopTest();
	}

	static testMethod void setGuestTest() {

		Map<String, String> orderFormData = new Map<String, String>{
			'fname' => 'Mouse',
			'lname' => 'Micke',
			'phone' => '12123232',
			'billingStreet' => 'TStreet',
			'billingCity' => 'TCity',
			'billingState' => 'Alaska',
			'billingPostalCode' => '1234',
			'billingCountry' => 'United States',
			'shippingStreet' => 'TStreet',
			'shippingCity' => 'TCity',
			'shippingState' => 'Alaska',
			'shippingPostalCode' => '1234',
			'shippingCountry' => 'United States'
		};

		RestHelper.DataForOrderItems dataForOrderItems = new RestHelper.DataForOrderItems();

		Test.startTest();
		String result;
		result = RestOrderController.setGuest(orderFormData, dataForOrderItems);
		System.assertEquals(true, result.contains('Email can not be empty'));

		orderFormData.put('email', 'testemail@gmail.com');
		result = RestOrderController.setGuest(orderFormData, dataForOrderItems);

		System.assertEquals(false, result.contains('Email can not be empty'));
		System.assertEquals(true, result.contains('error'));
		System.assertEquals(1, [SELECT Count() FROM Account]);

		orderFormData.put('email', 'testlead@gmail.com');
		Lead leadToAccount = new Lead (Lastname = 'LastName', Email = 'testlead@gmail.com');
		insert leadToAccount;

		result = RestOrderController.setGuest(orderFormData, dataForOrderItems);
		System.assertEquals(true, result.contains('error'));
		System.assertEquals(2, [SELECT Count() FROM Account]);
	}

}