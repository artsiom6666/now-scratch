@isTest
public class PaymentProcessorTest {

	private static Order__c insertOrder(Id accId) {
		Order__c order = new Order__c(
			Account__c = accId, Billing_Email__c = 'test@gmail.com', Status__c = 'Initiated', Billing_First_Name__c = 'test',
			Billing_Last_Name__c = 'dx', Billing_Phone__c = '9876543210', Billing_Address__c = '123 main Street',
			Billing_City__c =  'New York', Billing_State__c = 'LA', Billing_Country__c = 'United States',
			Billing_Zip_Postal__c = '10035', Shipping_Address__c = '123 main Street', Shipping_City__c = 'New York',
			Shipping_State__c = 'LA', Shipping_Country__c = 'United States', Shipping_Zip_Postal__c = '10035',
			Subtotal__c = 10, Shipping__c = 2, Tax__c= 2, Named_Agent__c = 'TouchCR Agent',
			Currency__c = 'US Dollar', Payment_Method__c = 'Credit Card'
		);
		insert order;
		return order;
	}

	private static Order_Transaction__c insertOrderTransaction(Id orderId, String typeTransaction) {
		Order_Transaction__c transection = new Order_Transaction__c(
			Order__c = orderId, Type__c = typeTransaction, Response_Status__c = 'Approved',
			Response_Message__c = 'Message', Payment_Response_Body__c = 'original', Payment_Profile__c = 'cus_7cBFHD6iiBaTUU',
			Named_Agent__c = 'TouchCR Agent', Card_Last_4__c = '4242', Payment_Entity_Id__c = 'card_1A4lgrCF2TV51fDnD0sQWldG',
			Payment_Date__c = Datetime.now().addDays(-1), Payment_Method__c = 'Credit Card', Currency__c = 'US Dollars',
			Amount__c = 11
		);
		insert transection;
		return transection;
	}

	private static Account insertAccount() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true AND IsActive = true];
		Account testAcc = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'FirstName', LastName = 'LastName', Phone = '9876543210',
			PersonEmail = 'testUsr@mail.ru'
		);
		insert testAcc;
		return testAcc;
	}

	private static Payment_Agents__c insertPaymentAgent() {
		Payment_Agents__c newPaymentAgents = new Payment_Agents__c(
			Name = 'TouchCR Agent', Security_Key__c = 'test',
			Active__c = true, Type__c = 'Stripe', Merchant_ID__c = 'test'
		);
		insert newPaymentAgents;
		return newPaymentAgents;
	}

	private static Payment_Option__c insertPaymentOption(Id accId) {
		Payment_Option__c newPaymentOption = new Payment_Option__c(
			Account__c = accId,
			Option_Id__c = 'card_1A4lgrCF2TV51fDnD0sQWldG',
			Profile_Id__c = 'cus_7cBFHD6iiBaTUU',
			Named_Agent__c = 'TouchCR Agent',
			Status__c = 'Active',
			Last_4__c = '4242'
		);
		insert newPaymentOption;
		return newPaymentOption;
	}

	static testMethod void chargeProcessorCorrectRequest() {

		Payment_Agents__c newPaymentAgents = insertPaymentAgent();
		Account testAcc = insertAccount();
		Order__c order = insertOrder(testAcc.Id);

		Test.startTest();
		Map<String, Object> result = PaymentProcessor.doPayment(
			new Map<String,Object>{
				'Method' => 'Charge',
				'OrderId' => order.Id,
				'Amount' => 1,
				'CreditCard' => new Map<String, Object>{
					'CardNumber' => '4242424242424242',
					'CardExpirationMonth' => '01',
					'CardExpirationYear' => '01',
					'CardCCV' => '123'
				}
			}
		);
		Test.stopTest();

		System.assertEquals('Approved', result.get('Status'));

		List<Order_Transaction__c> transections = [SELECT Id, Type__c, Amount__c FROM Order_Transaction__c WHERE Id =: (Id)result.get('Transaction')];
		System.assertEquals('Charge', transections[0].Type__c);
		System.assertEquals(1, transections[0].Amount__c);
		
		List<Payment_Option__c> paymentOption = [
			SELECT Id, Option_Id__c, Profile_Id__c, Named_Agent__c, Status__c, Last_4__c 
			FROM Payment_Option__c 
			WHERE Account__c =: testAcc.Id
		];
		System.assertEquals('4242', paymentOption[0].Last_4__c);
		System.assertEquals('Active', paymentOption[0].Status__c);
		System.assertEquals('TouchCR Agent', paymentOption[0].Named_Agent__c);
	}

	static testMethod void chargeProcessorWithPaymentOptionCorrectRequest() {

		Payment_Agents__c newPaymentAgents = insertPaymentAgent();
		Account testAcc = insertAccount();
		Payment_Option__c existingPaymentOption = insertPaymentOption(testAcc.Id);
		Order__c order = insertOrder(testAcc.Id);

		Test.startTest();
		Map<String, Object> result = PaymentProcessor.doPayment(
			new Map<String,Object>{
				'Method' => 'Charge',
				'OrderId' => order.Id,
				'Amount' => 1,
				'PaymentOptionId' => existingPaymentOption.Id
			}
		);
		Test.stopTest();

		System.assertEquals('Approved', result.get('Status'));

		List<Order_Transaction__c> transections = [SELECT Id, Type__c, Amount__c FROM Order_Transaction__c WHERE Id =: (Id)result.get('Transaction')];
		System.assertEquals('Charge', transections[0].Type__c);
		System.assertEquals(1, transections[0].Amount__c);
		
		List<Payment_Option__c> paymentOption = [
			SELECT Id, Option_Id__c, Profile_Id__c, Named_Agent__c, Status__c, Last_4__c 
			FROM Payment_Option__c 
			WHERE Account__c =: testAcc.Id
		];

		System.assertEquals(1, paymentOption.size());
		System.assertEquals('4242', paymentOption[0].Last_4__c);
		System.assertEquals('Active', paymentOption[0].Status__c);
		System.assertEquals('TouchCR Agent', paymentOption[0].Named_Agent__c);
	}

	static testMethod void chargeAuthorizeProcessorCorrectRequest() {

		Payment_Agents__c newPaymentAgents = insertPaymentAgent();
		Account testAcc = insertAccount();
		Order__c order = insertOrder(testAcc.Id);
		Order_Transaction__c transection = insertOrderTransaction(order.Id, 'Authorization');

		Test.startTest();
		Map<String, Object> result = PaymentProcessor.doPayment(
			new Map<String,Object>{
				'Method' => 'Charge',
				'OrderId' => order.Id,
				'CreditCard' => new Map<String, Object>{
					'CardNumber' => '4242424242424242',
					'CardExpirationMonth' => '01',
					'CardExpirationYear' => '01',
					'CardCCV' => '123'
				}
			}
		);
		Test.stopTest();

		System.assertEquals('Approved', result.get('Status'));

		List<Order_Transaction__c> transections = [SELECT Id, Type__c FROM Order_Transaction__c WHERE Id =: (Id)result.get('Transaction')];
		System.assertEquals('Charge', transections[0].Type__c);
	}

	static testMethod void paymentAttemptProcessorCorrectRequest() {

		Payment_Agents__c newPaymentAgents = insertPaymentAgent();
		Account testAcc = insertAccount();
		Order__c order = insertOrder(testAcc.Id);
		Order_Transaction__c transection = insertOrderTransaction(order.Id, 'Charge');

		Payment_Attempt__c paymentAttempt = new Payment_Attempt__c(
			Order__c = order.Id, Date__c = Date.today(),
			Remaining_Retries__c = 3, Amount__c = 1
		);
		insert paymentAttempt;

		Test.startTest();
		Map<String, Object> result = PaymentProcessor.doPayment(
			new Map<String,Object>{
				'Method' => 'Charge',
				'PaymentAttempt' => paymentAttempt.Id
			}
		);
		Test.stopTest();

		System.assertEquals('Approved', result.get('Status'));

		List<Order_Transaction__c> transections = [SELECT Id, Type__c FROM Order_Transaction__c WHERE Id =: (Id)result.get('Transaction')];
		System.assertEquals('Charge', transections[0].Type__c);
	}

	static testMethod void transactionProcessorCorrectRequest() {

		Payment_Agents__c newPaymentAgents = insertPaymentAgent();
		Account testAcc = insertAccount();
		Order__c order = insertOrder(testAcc.Id);
		Order_Transaction__c transection = insertOrderTransaction(order.Id, 'Authorization');

		Test.startTest();
		Map<String, Object> result = PaymentProcessor.doPayment(
			new Map<String,Object>{
				'Method' => 'Charge',
				'Transaction' => transection.Id
			}
		);
		Test.stopTest();

		System.assertEquals('Approved', result.get('Status'));

		List<Order_Transaction__c> transections = [SELECT Id, Type__c FROM Order_Transaction__c WHERE Id =: (Id)result.get('Transaction')];
		System.assertEquals('Charge', transections[0].Type__c);
	}

	static testMethod void paymentProcessorUpsell() {

		Payment_Agents__c newPaymentAgents = insertPaymentAgent();
		Account testAcc = insertAccount();
		Order__c order = insertOrder(testAcc.Id);
		Order__c order2 = insertOrder(testAcc.Id);
		Order_Transaction__c transection = insertOrderTransaction(order2.Id, 'Charge');

		Test.startTest();
		Map<String, Object> result = PaymentProcessor.doPayment(
			new Map<String,Object>{
				'Method' => 'Charge',
				'OrderId' => order2.Id,
				'Upsell' => true
			}
		);
		Test.stopTest();

		System.assertEquals('Approved', result.get('Status'));

		List<Order_Transaction__c> transections = [SELECT Id, Type__c FROM Order_Transaction__c WHERE Id =: (Id)result.get('Transaction')];
		System.assertEquals('Charge', transections[0].Type__c);
	}

	static testMethod void paymentProcessorUpsellFromPaymentOption() {

		Payment_Agents__c newPaymentAgents = insertPaymentAgent();
		Account testAcc = insertAccount();
		Order__c order = insertOrder(testAcc.Id);
		Order__c order2 = insertOrder(testAcc.Id);
		Order_Transaction__c transection = insertOrderTransaction(order2.Id, 'Charge');


		Test.startTest();
		List<Payment_Option__c> paymentOption = [SELECT Id FROM Payment_Option__c];

		Map<String, Object> result = PaymentProcessor.doPayment(
			new Map<String,Object>{
				'Method' => 'Charge',
				'OrderId' => order2.Id,
				'PaymentOptionId' => paymentOption[0].Id,
				'Upsell' => true
			}
		);
		Test.stopTest();

		System.assertEquals('Approved', result.get('Status'));

		List<Order_Transaction__c> transections = [SELECT Id, Type__c FROM Order_Transaction__c];
		System.assertEquals(2, transections.size());
	}

	static testMethod void authorizationProcessorCorrect() {

		Payment_Agents__c newPaymentAgents = insertPaymentAgent();
		Account testAcc = insertAccount();
		Order__c order = insertOrder(testAcc.Id);

		Test.startTest();
		Map<String, Object> result = PaymentProcessor.doPayment(
			new Map<String,Object>{
				'Method' => 'Authorization',
				'OrderId' => order.Id,
				'Amount' => 1,
				'CreditCard' => new Map<String, Object>{
					'CardNumber' => '4242424242424242',
					'CardExpirationMonth' => '01',
					'CardExpirationYear' => '01',
					'CardCCV' => '123'
				}
			}
		);
		Test.stopTest();

		System.assertEquals('Approved', result.get('Status'));

		List<Order_Transaction__c> transections = [SELECT Id, Type__c FROM Order_Transaction__c WHERE Id =: (Id)result.get('Transaction')];
		System.assertEquals('Authorization', transections[0].Type__c);
	}

	static testMethod void refundProcessorCorrect() {

		Payment_Agents__c newPaymentAgents = insertPaymentAgent();
		Account testAcc = insertAccount();
		Order__c order = insertOrder(testAcc.Id);
		Order_Transaction__c transection = insertOrderTransaction(order.Id, 'Charge');

		Test.startTest();
		Map<String, Object> result = PaymentProcessor.doPayment(
			new Map<String,Object>{
				'Method' => 'Refund',
				'Transaction' => transection.Id
			}
		);
		Test.stopTest();

		System.assertEquals('Approved', result.get('Status'));

		List<Order_Transaction__c> transections = [SELECT Id, Type__c FROM Order_Transaction__c WHERE Id =: (Id)result.get('Transaction')];
		System.assertEquals('Refund', transections[0].Type__c);
	}

	static testMethod void voidProcessorCorrect() {

		Payment_Agents__c newPaymentAgents = insertPaymentAgent();
		Account testAcc = insertAccount();
		Order__c order = insertOrder(testAcc.Id);
		Order_Transaction__c transection = insertOrderTransaction(order.Id, 'Charge');

		Test.startTest();
		Map<String, Object> result = PaymentProcessor.doPayment(
			new Map<String,Object>{
				'Method' => 'Void',
				'Transaction' => transection.Id
			}
		);
		Test.stopTest();

		System.assertEquals('Approved', result.get('Status'));

		List<Order_Transaction__c> transections = [SELECT Id, Type__c FROM Order_Transaction__c WHERE Id =: transection.Id];
		System.assertEquals('Void', transections[0].Type__c);
	}
}