@isTest
private with sharing class FranchiseeHelperDummyTest {

	@isTest
	static void test_franchisee_one() {
		String classInternalFr = 'ExtensionsHelperDummy.FranchiseeHelperInnerClass';
		Type invokeClassTypeFr = Type.forName(ExtensionsHelperDummy.classInternalFr);
		ExtensionsHelperDummy.FranchiseeHelperInnerClass franchiseeInstance = (ExtensionsHelperDummy.FranchiseeHelperInnerClass) invokeClassTypeFr.newInstance();

		Map<String, String> test = new Map<String, String> ();
		String result;
		result = ExtensionsHelperDummy.setFranchisee(test);
		result = ExtensionsHelperDummy.getFranchisee(test);
		result = ExtensionsHelperDummy.getFranchiseeInfo(test);
		result = ExtensionsHelperDummy.getFranchiseeForTerritory(test);
		result = ExtensionsHelperDummy.getPaymentConnectSettings();
		result = ExtensionsHelperDummy.saveStripeConnect('{"paymentAgentId":"a0J41000003w4dEEAQ","PaymentAgentLabel":"Test"}');
		System.assertNotEquals(null, result);
	}

	@isTest
	static void test_franchisee_two() {
		ExtensionsHelperDummy.FranchiseeHelperInnerClass controller = new ExtensionsHelperDummy.FranchiseeHelperInnerClass();
		String result;
		Map<String, String> test = new Map<String, String> ();

		result = controller.setFranchiseeRest(test);
		result = controller.getFranchiseeRest(test);
		result = controller.getFranchiseeInfoRest(test);
		result = controller.getFranchiseeForTerritoryRest(test);
		result = controller.getPaymentConnectSettingsExt();
		result = controller.saveStripeConnectExt('{"paymentAgentId":"a0J41000003w4dEEAQ","PaymentAgentLabel":"Test"}');
		System.assertNotEquals(null, result);

	}

}