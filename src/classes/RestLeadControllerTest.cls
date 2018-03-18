@isTest 
public class RestLeadControllerTest {

	static testMethod void testMethod1() {
		Lead leadObj = new Lead();
		leadObj.FirstName = 'fname';
		leadObj.LastName = 'lname';
		leadObj.Email = 'test@test.com';
		leadObj.Status = 'Open'; 
		insert leadObj;
		String strResponse = RestLeadController.createLead('test1@test.com','12345','FName','LName', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term', 'sales_funnel_name', 'referral_domain_url',
														   'landing_page_url', 'utm_source'); 
		System.assertEquals('Added',strResponse);
	}

	static testMethod void testMethod2(){
		Lead leadObj = new Lead();
		leadObj.FirstName = 'fname';
		leadObj.LastName = 'lname';
		leadObj.Email = 'test@test.com';
		leadObj.Phone = '9878976778';
		leadObj.Status = 'Open'; 
		insert leadObj;    
		String strResponse =RestLeadController.createLead('test@test.com','12345','FName','LName', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term', 'sales_funnel_name', 'referral_domain_url',
														   'landing_page_url', 'utm_source');
		System.assertEquals('Updated',strResponse);
	}
 
	static testMethod void testMethod3(){
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account ant = new Account();
		ant.RecordTypeId = customerRecordType.Id;
		ant.FirstName = 'test';
		ant.LastName = 'test';
		ant.Phone = '6547892456';
		ant.PersonEmail = 'test@test.com';
		insert ant;
		String strResponse =RestLeadController.createLead('test@test.com','12345','FName','LName', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term', 'sales_funnel_name', 'referral_domain_url',
														   'landing_page_url', 'utm_source');
		System.assertEquals('Exist',strResponse);
	}

	@isTest static void RestLeadControllerTestSuccessInsertLead() {
		Map<String, String> generalData = new Map<String, String>{
			'lastName'=> 'test',
			'firstName'=> 'Eugene',
			'email'=> 'test@gmail.com',
			'phone'=> '1234567890',
			'street'=> 'Vulture St, Woolloongabba',
			'city'=> 'Brisbane',
			'state'=> 'Queensland',
			'postalCode'=> '4102',
			'country'=> 'Australia',
			'stateCode'=> 'QLD',
			'countryCode'=> 'AU',
			'longitude'=> '153.062496',
			'latitude'=> '-27.579233',
			'uniqueCode' => 'testCode'
		};

		Test.startTest();
			String result = RestLeadController.setLead(generalData);
		Test.stopTest();

		List<Lead> lead = [SELECT Id, Phone FROM Lead];
		System.assertEquals(true, result.contains('success'));
		System.assertEquals('1234567890', lead[0].Phone);
		System.assertEquals(1, lead.size());
	}

	@isTest static void RestLeadControllerTestSuccessInsertAccount() {
		Map<String, String> generalData = new Map<String, String>{
			'lastName'=> 'test',
			'firstName'=> 'Eugene',
			'email'=> 'test@gmail.com',
			'phone'=> '1234567890',
			'street'=> 'Vulture St, Woolloongabba',
			'city'=> 'Brisbane',
			'state'=> 'Queensland',
			'postalCode'=> '4102',
			'country'=> 'Australia',
			'stateCode'=> 'QLD',
			'countryCode'=> 'AU',
			'longitude'=> '153.062496',
			'latitude'=> '-27.579233',
			'uniqueCode' => 'testCode'
		};
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account acc = new Account(
			RecordTypeId = customerRecordType.Id,
			LastName = 'test',
			PersonEmail = 'test@gmail.com'
		);
		insert acc;

		Test.startTest();
		String result = RestLeadController.setLead(generalData);
		Test.stopTest();

		List<Lead> leads = [SELECT Id FROM Lead];
		System.assertEquals(0, leads.size());
		System.assertEquals(true, result.contains('success'));
	}

	@isTest static void RestLeadControllerTestLeadError() {
		Map<String, String> generalData = new Map<String, String>();

		Test.startTest();
			String result = RestLeadController.setLead(generalData);
		Test.stopTest();

		List<Lead> lead = [SELECT Id, Phone FROM Lead];
		System.assertEquals(true, result.contains('error'));
		System.assertEquals(0, lead.size());
	}

}