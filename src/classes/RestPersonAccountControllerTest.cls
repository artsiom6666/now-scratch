@isTest
private class RestPersonAccountControllerTest{

	static testMethod void RestPersonAccountControllerTestUpdateAccount() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account acc = new Account(
			RecordTypeId = customerRecordType.Id,
			LastName = 'Gerdegedi',
			FirstName = 'Itsig',
			PersonEmail = 'Gerdegedi.Itsig@gmail.com'
		);
		insert acc;

		Test.startTest();

			String result;
			result = RestPersonAccountController.setPersonAccount(new Map<String, String>{});
			System.assertEquals(true, result.contains('error'));
			result = RestPersonAccountController.setPersonAccount(new Map<String, String>{'id' => 'invalidId'});
			System.assertEquals(true, result.contains('error'));
			result = RestPersonAccountController.setPersonAccount(new Map<String, String>{'id' => acc.Id});
			System.assertEquals(true, result.contains('success'));

			result = RestPersonAccountController.setPersonAccount(new Map<String, String>{'id' => acc.Id,'lastName' => 'GerdegediTwo'});
			System.assertEquals(true, result.contains('success'));
			result = RestPersonAccountController.setPersonAccount(new Map<String, String>{'id' => acc.Id, 'firstName' => 'ItsigTwo'});
			System.assertEquals(true, result.contains('success'));
			result = RestPersonAccountController.setPersonAccount(new Map<String, String>{'id' => acc.Id, 'personEmail' => 'gerdegedi.itsig@gmail.com'});
			System.assertEquals(true, result.contains('success'));
			result = RestPersonAccountController.setPersonAccount(new Map<String, String>{'id' => acc.Id, 'phone' => '1234567890'});
			System.assertEquals(true, result.contains('success'));
			result = RestPersonAccountController.setPersonAccount(new Map<String, String>{'id' => acc.Id,
																						  'billingStreet' => 'Vulture St, Woolloongabba',
																						  'billingCity' => 'Brisbane',
																						  'billingState' => 'Queensland',
																						  'billingStateCode' => 'QLD',
																						  'billingPostalCode' => '4102',
																						  'billingCountry' => 'Australia',
																						  'billingCountryCode' => 'AU'});
			System.assertEquals(true, result.contains('success'));
			result = RestPersonAccountController.setPersonAccount(new Map<String, String>{'id' => acc.Id, 'shippingStreet' => 'Vulture St, Woolloongabba'});
			System.assertEquals(true, result.contains('success'));
			result = RestPersonAccountController.setPersonAccount(new Map<String, String>{'id' => acc.Id, 'shippingCity' => 'Brisbane'});
			System.assertEquals(true, result.contains('success'));
			result = RestPersonAccountController.setPersonAccount(new Map<String, String>{'id' => acc.Id, 'shippingPostalCode' => '4102'});
			System.assertEquals(true, result.contains('success'));
			result = RestPersonAccountController.setPersonAccount(new Map<String, String>{'id' => acc.Id, 'shippingCountryCode' => 'AU'});
			System.assertEquals(true, result.contains('success'));
			result = RestPersonAccountController.setPersonAccount(new Map<String, String>{'id' => acc.Id, 'shippingCountry' => 'Australia'});
			System.assertEquals(true, result.contains('success'));
			result = RestPersonAccountController.setPersonAccount(new Map<String, String>{'id' => acc.Id, 'shippingStateCode' => 'QLD'});
			System.assertEquals(true, result.contains('success'));
			result = RestPersonAccountController.setPersonAccount(new Map<String, String>{'id' => acc.Id, 'shippingState' => 'Queensland'});
			System.assertEquals(true, result.contains('success'));

			result = RestPersonAccountController.setPersonAccount(new Map<String, String>{'id' => acc.Id, 'currencyIsoCode' => 'AUD'});
			System.assertEquals(true, result.contains('success'));

			String codeFields = TouchCRHelper.isSCPEnabled() == TRUE ? ' BillingCountryCode, ShippingCountryCode, BillingStateCode, ShippingStateCode, ' : '';
			String query = 'SELECT Id, FirstName, LastName, PersonEmail, Phone, BillingStreet, BillingAddress, ' + codeFields + 
								  'BillingCity, BillingState, BillingPostalCode, BillingCountry, ' +
								  'ShippingStreet, ShippingCity, ShippingState, ' +
								  'ShippingPostalCode, ShippingCountry ' +
								  'FROM Account ';
			List<Account> accs = Database.query(query);

			System.assertEquals('GerdegediTwo', accs[0].LastName);
			System.assertEquals('ItsigTwo', accs[0].FirstName);
			System.assertEquals('gerdegedi.itsig@gmail.com', accs[0].PersonEmail);
			System.assertEquals('1234567890', accs[0].Phone);
			System.assertEquals('Vulture St, Woolloongabba', accs[0].BillingStreet);
			System.assertEquals('Brisbane', accs[0].BillingCity);
			System.assertEquals(TouchCRHelper.isSCPEnabled() == TRUE ? 'QLD' : '', TouchCRHelper.isSCPEnabled() == TRUE ? accs[0].get('BillingStateCode') : '');
			System.assertEquals(TouchCRHelper.isSCPEnabled() == TRUE ? 'AU' : '', TouchCRHelper.isSCPEnabled() == TRUE ? accs[0].get('BillingCountryCode') : '');
			System.assertEquals('Queensland', accs[0].BillingState);
			System.assertEquals('4102', accs[0].BillingPostalCode);
			System.assertEquals('Australia', accs[0].BillingCountry);
			System.assertEquals('Vulture St, Woolloongabba', accs[0].ShippingStreet);
			System.assertEquals('Brisbane', accs[0].ShippingCity);
			System.assertEquals('Queensland', accs[0].ShippingState);
			System.assertEquals('4102', accs[0].ShippingPostalCode);
			System.assertEquals('Australia', accs[0].ShippingCountry);
			System.assertEquals(TouchCRHelper.isSCPEnabled() == TRUE ? 'QLD' : '', TouchCRHelper.isSCPEnabled() == TRUE ? accs[0].get('ShippingStateCode') : '');
			System.assertEquals(TouchCRHelper.isSCPEnabled() == TRUE ? 'AU' : '', TouchCRHelper.isSCPEnabled() == TRUE ? accs[0].get('ShippingCountryCode') : '');
			System.assertEquals(1, accs.size());

		Test.stopTest();
	}

	static testMethod void RestPersonAccountControllerTestError() {
		Map<String, String> generalData = new Map<String, String>{
			'firstName' => 'Gerdegedi',
			'personEmail' => 'Gerdegedi.Itsig@gmail.com',
			'phone' => '1234567890',
			'billingStreet' => 'Vulture St, Woolloongabba',
			'billingCity' => 'Brisbane',
			'billingState' => 'Queensland',
			'billingPostalCode' => '4102',
			'billingCountry' => 'Australia',
			'billingStateCode' => 'QLD',
			'billingCountryCode' => 'AU',
			'shippingStreet' => 'Vulture St, Woolloongabba',
			'shippingCity' => 'Brisbane',
			'shippingState' => 'Queensland',
			'shippingPostalCode' => '4102',
			'shippingCountry' => 'Australia',
			'shippingStateCode' => 'QLD',
			'shippingCountryCode' => 'AU',
			'currencyIsoCode' => 'AUD'
		};

		Test.startTest();
			String result = RestPersonAccountController.setPersonAccount(generalData);
			List<Account> accs = [SELECT Id, Phone FROM Account];
			System.assertEquals(true, result.contains('error'));
			System.assertEquals(0, accs.size());
		Test.stopTest();
	}

	static testMethod void RestPersonAccountControllerTestRemoveAccount() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account acc = new Account(
			RecordTypeId = customerRecordType.Id,
			LastName = 'Itsig',
			FirstName = 'Gerdegedi',
			PersonEmail = 'Gerdegedi.Itsig@gmail.com'
		);
		insert acc;

		Test.startTest();
			String result;
			result = RestPersonAccountController.deletePersonAccount(new Map<String, String>{});
			System.assertEquals(true, result.contains('error'));
			result = RestPersonAccountController.deletePersonAccount(new Map<String, String>{'id' => 'ivalidId'});
			System.assertEquals(true, result.contains('error'));
			result = RestPersonAccountController.deletePersonAccount(new Map<String, String>{'id' => acc.Id});
			System.assertEquals(true, result.contains('success'));
			List<Account> accs = [SELECT Id, Phone FROM Account];
			System.assertEquals(0, accs.size());
		Test.stopTest();
	}

	static testMethod void RestPersonAccountControllerTestGetAccount() {
		List<RecordType> recordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer_Account' LIMIT 1];

		Account accA = new Account(LastName = 'Last13579', FirstName = 'First13579', PersonEmail = 'email13579@gmail.com', RecordTypeId = recordType[0].Id);
		Account accB = new Account(LastName = 'Last97531', FirstName = 'First97531', PersonEmail = 'email97531@gmail.com', RecordTypeId = recordType[0].Id);
		insert new List<Account> {accA, accB};


		Test.startTest();
			String result;
			result = RestPersonAccountController.getPersonAccount(new Map<String, String>{});
			System.assertEquals(true, result.contains('error'));
			result = RestPersonAccountController.getPersonAccount(new Map<String, String>{'personEmail' => 'invalidId'});
			System.assertEquals(true, result.contains('error'));
			result = RestPersonAccountController.getPersonAccount(new Map<String, String>{'personEmail' => 'email13579@gmail.com'});
			System.assertEquals(true, result.contains('success'));
			result = RestPersonAccountController.getPersonAccount(new Map<String, String>{'personEmail' => 'email97531@gmail.com'});
			System.assertEquals(true, result.contains('success'));
		Test.stopTest();
	}

	static testMethod void setAccountWithUser() {
		Test.startTest();
			String result;
			result = RestPersonAccountController.setAccountWithUser(new Map<String, String>{});
			System.assertEquals(true, result.contains('error'));

			result = RestPersonAccountController.setAccountWithUser(new Map<String, String>{'personEmail' => 'testtest13579@gmail.com', 'lastName' => 'IstestAccount13579'});
			System.assertEquals(true, result.contains('success'));
		Test.stopTest();
	}

}