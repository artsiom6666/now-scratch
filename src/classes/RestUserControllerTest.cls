@isTest
private class RestUserControllerTest{

	static testMethod void RestUserControllerTest() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account acc = new Account(
			RecordTypeId = customerRecordType.Id,
			LastName = 'Pahuschy',
			FirstName = 'Eugene',
			PersonEmail = 'eugene.pahuschy@gmail.com'
		);
		insert acc;

		Map<String, String> generalData = new Map<String, String>{
			'accountId' => acc.Id,
			'lastName' => 'Beam13579',
			'firstName' => 'Tou13579',
			'alias' => 'jTou',
			'email' => 'testestest13579@testcraft.com',
			'username' => 'TestUserName13579@gmail.com',
			'timeZoneSidKey' => 'Australia/Sydney',
			'languageLocaleKey' => 'en_US',
			'emailEncodingKey' => 'ISO-8859-1',
			'localeSidKey' => 'en_AU'
		};

		Test.startTest();
			String result = RestUserController.setUser(generalData);
			List<User> users = [SELECT Id, LastName, ContactId, AccountId FROM User WHERE Email = 'testestest13579@testcraft.com'];
			System.assertEquals(result.contains('success'), TRUE);
			System.assertEquals(1, users.size());
		Test.stopTest();
	}

}