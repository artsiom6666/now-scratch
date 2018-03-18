@isTest
private class PaymentAgentControllerTest {

	@isTest static void test_configuration_new_setting() {
		PaymentAgentController objPaymentAgent = new PaymentAgentController();
		objPaymentAgent.newPaymentAgent();
			objPaymentAgent.newAgent.Name = 'Test Agent Name';
			objPaymentAgent.newAgent.Security_Key__c = 'test';
			objPaymentAgent.newAgent.Active__c = true;
			objPaymentAgent.newAgent.Merchant_ID__c = 'test';
		objPaymentAgent.savePaymentAgent();

		List<Payment_Agents__c> newPaymentAgentsList = [SELECT Id, Name FROM Payment_Agents__c];
		System.assertEquals(1, newPaymentAgentsList.size());
		System.assertEquals('Test Agent Name', newPaymentAgentsList[0].Name);
	}

	@isTest static void test_configuration_edit_setting() {
		Payment_Agents__c newPaymentAgents = new Payment_Agents__c(
			Name = 'Test Agent Name',
			Security_Key__c = 'test',
			Active__c = true,
			Merchant_ID__c = 'test'
		);
		insert newPaymentAgents;

		PaymentAgentController objPaymentAgent = new PaymentAgentController();
		objPaymentAgent.namePaymentAgent = 'Test Agent Name';
		objPaymentAgent.editPaymentAgent();
		objPaymentAgent.newAgent.Active__c = false;
		objPaymentAgent.savePaymentAgent();

		List<Payment_Agents__c> newPaymentAgentsList = [SELECT Id, Name, Active__c FROM Payment_Agents__c];
		System.assertEquals(1, newPaymentAgentsList.size());
		System.assertEquals('Test Agent Name', newPaymentAgentsList[0].Name);
		System.assertEquals(false, newPaymentAgentsList[0].Active__c);

		objPaymentAgent.namePaymentAgent = 'Test Agent Name';
		objPaymentAgent.deletedPaymentAgent();

		newPaymentAgentsList = [SELECT Id FROM Payment_Agents__c];
		System.assertEquals(0, newPaymentAgentsList.size());
	}

	@isTest static void test_configuration_methods() {
		Payment_Agents__c newPaymentAgents = new Payment_Agents__c(
			Name = 'Test Agent Name',
			Security_Key__c = 'test',
			Active__c = true,
			Merchant_ID__c = 'test'
		);
		insert newPaymentAgents;

		String nameParamAgents = PaymentAgentController.idToNameParamAgents((String)newPaymentAgents.Id);
		System.assertEquals('Test Agent Name', nameParamAgents);

	}

}