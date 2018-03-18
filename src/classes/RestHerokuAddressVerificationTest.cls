@isTest
public class RestHerokuAddressVerificationTest {

	static testMethod void testcreateNewShipping(){
		Map<String, String> minFraudSetting = new Map<String, String>();
	            minFraudSetting.put('USPS.UserID', 'testUserID');
	        TouchCRHelper.setSettings(minFraudSetting);
		String address = '73 east lake street~Chicago~IL~60601';
		Test.startTest();
		String strResponse = RestHerokuAddressVerification.getValidateHerokuData(address);
		Test.stopTest();
		System.assertEquals('invalid',strResponse);
	}

	static testMethod void testcreateNewShippingCatch(){

		String address = '73 east lake street~Chicago~IL';
		Test.startTest();
		try {
			String strResponse = RestHerokuAddressVerification.getValidateHerokuData(address);
		} catch (Exception e) {
			List<Log__c> logs = [SELECT Event_Type__c, Account__c FROM Log__c];
			System.assertEquals(1, logs.size());
			System.assertEquals('Address Varification', logs[0].Event_Type__c);
			System.assertEquals(null, logs[0].Account__c);
		}
		Test.stopTest();
	}

}