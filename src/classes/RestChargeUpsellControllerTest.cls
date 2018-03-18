@isTest
public class RestChargeUpsellControllerTest {

	private static Account insertAccount() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account ant = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'test', LastName = 'test', 
			Phone = '6547892456', PersonEmail = 'test@gmail.com'
		);
		insert ant;
		return ant;
	}

	private static Order__c insertOrder(Id accId) {
		Order__c cOrder = new Order__c(
			Account__c = accId, Billing_Email__c = 'test@gmail.com', Status__c = 'Initiated', Billing_First_Name__c = 'test',
			Billing_Last_Name__c = 'dx', Billing_Phone__c = '9876543210', Billing_Address__c = '123 main Street',
			Billing_City__c =  'New York', Billing_State__c = 'LA', Billing_Country__c = 'United States',
			Billing_Zip_Postal__c = '10035', Shipping_Address__c = '123 main Street', Shipping_City__c = 'New York',
			Shipping_State__c = 'LA', Shipping_Country__c = 'United States', Shipping_Zip_Postal__c = '10035',
			Subtotal__c = 10, Shipping__c = 2, Tax__c= 2, Named_Agent__c = 'TouchCR Agent',
			Currency__c = 'US Dollar', Payment_Method__c = 'Credit Card'
		);
		insert cOrder;
		return cOrder;
	}

	private static Payment_Agents__c insertPaymentAgent() {
		Payment_Agents__c newPaymentAgents = new Payment_Agents__c(
			Name = 'TouchCR Agent', Security_Key__c = 'test',
			Active__c = true, Type__c = 'Stripe', Merchant_ID__c = 'test'
		);
		insert newPaymentAgents;
		return newPaymentAgents;
	}

    static testMethod void testupdateOrder(){

		Account ant = insertAccount();

		Order__c cOrder = insertOrder(ant.Id);

        Test.startTest();
			String actual = RestChargeUpsellController.updateOrder(cOrder.Id);
        Test.stopTest();

        System.assertEquals('true', actual);
    }

    static testMethod void testunpaidCase(){

		Account ant = insertAccount();

		Order__c cOrder = insertOrder(ant.Id);

        Test.startTest();
            String actual = RestChargeUpsellController.unpaidCase(cOrder.Id);
        Test.stopTest();

        System.assertEquals('false', actual);
    }

    static testMethod void testchargeupsell(){

		Account ant = insertAccount();

		Order__c cOrder = insertOrder(ant.Id);

        Test.startTest();
			String result = RestChargeUpsellController.chargeUpsell('Daily', 'Recurring', '09/28/2015', '10/28/2015', cOrder.Id);
        Test.stopTest();

        System.assertEquals('true', result);
	}

	static testMethod void testchargeupsellV2(){

		Account ant = insertAccount();

		Order__c cOrder = insertOrder(ant.Id);

		Payment_Agents__c newPaymentAgents = insertPaymentAgent();

		Payment_Option__c newPaymentOption = new Payment_Option__c(
			Account__c = ant.Id, Option_Id__c = 'card_1A4lgrCF2TV51fDnD0sQWldG',
			Profile_Id__c = 'cus_7cBFHD6iiBaTUU', Named_Agent__c = 'TouchCR Agent',
			Status__c = 'Active', Last_4__c = '4242'
		);
		insert newPaymentOption;

		Test.startTest();

			Map<String, String> inputDataMap = new Map<String, String>{
				'orderId' => 'invalidId',
				'applicationFee' => 'false',
				'destination' => 'false',
				'PaymentOptionId' => newPaymentOption.Id
			};
			String result = RestChargeUpsellController.chargeUpsellV2(inputDataMap);
			System.assertNotEquals('{"Result":"true","Status":"Success"}', result);

			inputDataMap = new Map<String, String>{
				'orderId' => cOrder.Id,
				'applicationFee' => 'false',
				'destination' => 'false',
				'PaymentOptionId' => newPaymentOption.Id
			};
			result = RestChargeUpsellController.chargeUpsellV2(inputDataMap);
			System.assertEquals('{"Result":"true","Status":"Success"}', result);
			
		Test.stopTest();
	}
}