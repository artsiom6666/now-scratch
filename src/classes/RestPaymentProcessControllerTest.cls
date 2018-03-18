@isTest
public class RestPaymentProcessControllerTest {

	private static Account insertAccount() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account ant = new Account(RecordTypeId = customerRecordType.Id, FirstName = 'test', LastName = 'test', Phone = '6547892456', PersonEmail = 'test@gmail.com');
		insert ant;
		return ant;
	}

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

	private static Payment_Agents__c insertPaymentAgent() {
		Payment_Agents__c newPaymentAgents = new Payment_Agents__c(
			Name = 'TouchCR Agent', Security_Key__c = 'test',
			Active__c = true, Type__c = 'Stripe', Merchant_ID__c = 'test'
		);
		insert newPaymentAgents;
		return newPaymentAgents;
	}

	static testMethod void processPaymentV2OrderTest() {

		Payment_Agents__c newPaymentAgents = insertPaymentAgent();
		Account ant = insertAccount();
		Order__c cOrder = insertOrder(ant.Id);

		Map<String,Object> creditCard = new Map<String,Object>{
			'CardNumber' => '4242424242424242',
			'CardCCV' => '123',
			'CardExpirationMonth' => '01',
			'CardExpirationYear' => '01'
		};

		Map<String, String> inputDataMap = new Map<String, String>{
			'orderId' => cOrder.Id,
			'Amount' => '5'
		}; 

		Test.startTest();
			String resultProcessPaymentV2 = RestPaymentProcessController.processPaymentV2(inputDataMap, creditCard);
		Test.stopTest();
		System.assertEquals('{"Result":"true","Status":"Success"}', resultProcessPaymentV2);
	}

	static testMethod void processPaymentV2WichPaymentOptionOrderTest() {

		Payment_Agents__c newPaymentAgents = insertPaymentAgent();
		Account ant = insertAccount();
		Order__c cOrder = insertOrder(ant.Id);

		Payment_Option__c newPaymentOption = new Payment_Option__c(
			Account__c = ant.Id, Option_Id__c = 'card_1A4lgrCF2TV51fDnD0sQWldG',
			Profile_Id__c = 'cus_7cBFHD6iiBaTUU', Named_Agent__c = 'TouchCR Agent',
			Status__c = 'Active', Last_4__c = '4242'
		);
		insert newPaymentOption;

		Map<String,Object> creditCard = new Map<String,Object>{
			'CardNumber' => '4242424242424242',
			'CardCCV' => '123',
			'CardExpirationMonth' => '01',
			'CardExpirationYear' => '01'
		};

		Map<String, String> inputDataMap = new Map<String, String>{
			'orderId' => cOrder.Id,
			'Amount' => '5',
			'PaymentOptionId' => newPaymentOption.Id
		}; 

		Test.startTest();
			String resultProcessPaymentV2 = RestPaymentProcessController.processPaymentV2(inputDataMap, creditCard);
		Test.stopTest();
		System.assertEquals('{"Result":"true","Status":"Success"}', resultProcessPaymentV2);
	}

    static testMethod void processPaymentUpdateOrderTest(){
		Account ant = insertAccount();
		Order__c cOrder = insertOrder(ant.Id);

        Test.startTest();
			String actual = RestPaymentProcessController.updateOrder(cOrder.Id);
        Test.stopTest();

        System.assertEquals('true', actual);
    }

    static testMethod void processPaymentUnpaidCaseTest(){
		Account ant = insertAccount();
		Order__c cOrder = insertOrder(ant.Id);

        Test.startTest();
            String actual = RestPaymentProcessController.unpaidCase(cOrder.Id);
        Test.stopTest();

        System.assertEquals('unpaid', actual);
    }

    static testMethod void processPaymentTestOne(){
        TouchCR_Settings__c objFirst = new TouchCR_Settings__c();
        objFirst.Name    ='MinFraud.RatingFirst';
        objFirst.value__c  ='30';
        insert objFirst;

        TouchCR_Settings__c objSecond = new TouchCR_Settings__c();
        objSecond.Name   ='MinFraud.RatingSecond';
        objSecond.value__c ='75';
        insert objSecond;

        Map<String, String> minFraudSetting = new Map<String, String>();
            minFraudSetting.put('MinFraud.ApiKey', 'testAPIkey');
        TouchCRHelper.setSettings(minFraudSetting);

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new RestPaymentProcessOneMockResponse());

		Account ant = insertAccount();
		Order__c cOrder = insertOrder(ant.Id);

        Map<String,Object> creditCard = new Map<String,Object>{
            'CardNumber' => '4242424242424242',
            'CardCCV' => '123',
            'CardExpirationMonth' => '01',
            'CardExpirationYear' => '01'
        };

        Test.startTest();
        String actual = RestPaymentProcessController.processPayment('Daily', 'Recurring', '09/20/2016', '09/21/2015', cOrder.Id, creditCard);
        Test.stopTest();

        System.assertEquals('true',actual);
    }

    static testMethod void processPaymentTestTwo(){
        TouchCR_Settings__c objFirst = new TouchCR_Settings__c();
        objFirst.Name    ='MinFraud.RatingFirst';
        objFirst.value__c  ='30';
        insert objFirst;

        TouchCR_Settings__c objSecond = new TouchCR_Settings__c();
        objSecond.Name   ='MinFraud.RatingSecond';
        objSecond.value__c ='75';
        insert objSecond;

        Map<String, String> minFraudSetting = new Map<String, String>();
            minFraudSetting.put('MinFraud.ApiKey', 'testAPIkey');
        TouchCRHelper.setSettings(minFraudSetting);

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new RestPaymentProcessTwoMockResponse());

		Account ant = insertAccount();
		Order__c cOrder = insertOrder(ant.Id);

        Map<String,Object> creditCard = new Map<String,Object>{
            'CardNumber' => '4242424242424242',
            'CardCCV' => '123',
            'CardExpirationMonth' => '01',
            'CardExpirationYear' => '01'
        };

        Test.startTest();
        String actual = RestPaymentProcessController.processPayment('Daily', 'Recurring', '09/20/2016', '09/21/2015', cOrder.Id, creditCard);
        Test.stopTest();

        System.assertEquals('true',actual);
    }

    static testMethod void processPaymentTestThree(){
        TouchCR_Settings__c objFirst = new TouchCR_Settings__c();
        objFirst.Name    ='MinFraud.RatingFirst';
        objFirst.value__c  ='30';
        insert objFirst;

        TouchCR_Settings__c objSecond = new TouchCR_Settings__c();
        objSecond.Name   ='MinFraud.RatingSecond';
        objSecond.value__c ='75';
        insert objSecond;

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new RestPaymentProcessThreeMockResponse());

		Account ant = insertAccount();
		Order__c cOrder = insertOrder(ant.Id);

        Map<String,Object> creditCard = new Map<String,Object>{
            'CardNumber' => '4242424242424242',
            'CardCCV' => '123',
            'CardExpirationMonth' => '01',
            'CardExpirationYear' => '01'
        };

        Test.startTest();
        String actual = RestPaymentProcessController.processPayment('Daily', 'Recurring', '09/20/2016', '09/21/2015', cOrder.Id, creditCard);
        Test.stopTest();
        System.assertEquals('true',actual);
    }

    static testMethod void testchargentone1(){
		Account ant = insertAccount();
		Order__c cOrder = insertOrder(ant.Id);

		String oid = RestPaymentProcessController.makeautoship(cOrder.Id);
        System.assertEquals(cOrder.Id, oid);
    }

    static testMethod void testCloseCase(){
		Account ant = insertAccount();
		Order__c cOrder = insertOrder(ant.Id);

        Case cs = new Case();
        cs.AccountId = ant.Id;
        cs.Order__c = cOrder.id;
        cs.Subject = 'Card was declined.';
        cs.Status = 'New';
        cs.Origin = 'Phone';
        cs.Type = 'Payment';
        cs.Reason = 'Unpaid Order';
        insert cs;

        String result = RestPaymentProcessController.clearCase(ant.Id);
        System.assertEquals('true', result);
    }

}