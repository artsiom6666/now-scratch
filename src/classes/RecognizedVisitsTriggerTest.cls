@isTest
private class RecognizedVisitsTriggerTest {

	@isTest static void test_bulk_leads_copy_utm() {
		Integer start = 1;
		Integer numRepeats = 5;

		String firstEmail = 'yahoo.com';
		String secondEmail = 'example.com';

		Lead aLead1 = new Lead(
			FirstName = 'Test1 FName',
			LastName = 'Test1 LName',
			Email = 'test@yahoo.com'
		);
		insert aLead1;

		Lead aLead2 = new Lead(
			FirstName = 'Test2 FName',
			LastName = 'Test2 LName',
			Email = 'test@example.com'/*,
			utm_campaign__c = 'email'*/
		);
		insert aLead2;

		List<Recognized_Visits__c> recVisList = new List<Recognized_Visits__c>();
		// Name = OptIn, valid
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Recognized_Visits__c recVisit = new Recognized_Visits__c();
			recVisit.put('Name', 'optIn');

			recVisit.put('utm_campaign__c', 'utm1_' + idx);
			recVisit.put('utm_content__c', 'utm1_' + idx);
			recVisit.put('utm_medium__c', 'utm1_' + idx);
			recVisit.put('utm_source__c', 'utm1_' + idx);
			recVisit.put('Utm_Term__c', 'utm1_' + idx);

			recVisit.put('Date_and_Time__c', System.now());
			recVisit.put('User_Email_Address__c', 'test@' + firstEmail);
			recVisList.add(recVisit);
		}
		// Name != OptIn, invalid
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Recognized_Visits__c recVisit = new Recognized_Visits__c();
			recVisit.put('Name', 'Conversion');

			recVisit.put('utm_campaign__c', 'utm2_' + idx);
			recVisit.put('utm_content__c', 'utm2_' + idx);
			recVisit.put('utm_medium__c', 'utm2_' + idx);
			recVisit.put('utm_source__c', 'utm2_' + idx);
			recVisit.put('Utm_Term__c', 'utm2_' + idx);

			recVisit.put('Date_and_Time__c', System.now());
			recVisit.put('User_Email_Address__c', 'test@' + secondEmail);
			recVisList.add(recVisit);
		}

		//assert list has 2 nonmapped reconVisit records
		System.assertEquals(10, recVisList.size());
		Test.startTest();
			insert recVisList;
		Test.stopTest();

		List<Recognized_Visits__c> testObj1 = [
			SELECT Lead__c, User_Email_Address__c
			FROM Recognized_Visits__c
			WHERE Lead__c =:aLead1.Id
		];
		//assert half of numRepeats records realted to 1st lead
		System.assertEquals(5, testObj1.size());

		List<Recognized_Visits__c> testObj2 = [
			SELECT Lead__c, User_Email_Address__c
			FROM Recognized_Visits__c
			WHERE Lead__c =:aLead2.Id
		];
		//assert half of numRepeats records realted to 2nd lead
		System.assertEquals(5, testObj2.size());

		//all insert records
		List<Recognized_Visits__c> testObj = [SELECT Id FROM Recognized_Visits__c];
		//assert non mapped records deleted
		System.assertEquals(10, testObj.size());

		// assert 1st lead has set utm from visits
		aLead1 = [SELECT Id, utm_campaign__c, utm_content__c, utm_medium__c, utm_source__c, utm_term__c FROM Lead WHERE Id = :aLead1.Id];
		System.assertEquals('utm1_1', aLead1.utm_campaign__c);
		System.assertEquals('utm1_1', aLead1.utm_content__c);
		System.assertEquals('utm1_1', aLead1.utm_content__c);
		System.assertEquals('utm1_1', aLead1.utm_content__c);
		System.assertEquals('utm1_1', aLead1.utm_content__c);

		// assert 2nd lead has not utm copied, as RV related to it were notOptIn type
		aLead2 = [SELECT Id, utm_campaign__c, utm_content__c, utm_medium__c, utm_source__c, utm_term__c FROM Lead WHERE Id = :aLead2.Id];
		System.assertEquals(null, aLead2.utm_campaign__c);
		System.assertEquals(null, aLead2.utm_content__c);
		System.assertEquals(null, aLead2.utm_content__c);
		System.assertEquals(null, aLead2.utm_content__c);
		System.assertEquals(null, aLead2.utm_content__c);
	}

	@isTest static void test_bulk_leads_copy_utm_positive() {
		Integer start = 1;
		Integer numRepeats = 5;

		String firstEmail = 'yahoo.com';
		String secondEmail = 'example.com';

		Lead aLead1 = new Lead(
			FirstName = 'Test1 FName',
			LastName = 'Test1 LName',
			Email = 'test@yahoo.com'
		);
		insert aLead1;
		// lead 2 has 1 utm field set, it should not be updated at all
		Lead aLead2 = new Lead(
			FirstName = 'Test2 FName',
			LastName = 'Test2 LName',
			Email = 'test@example.com',
			utm_campaign__c = 'email'
		);
		insert aLead2;

		List<Recognized_Visits__c> recVisList = new List<Recognized_Visits__c>();
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Recognized_Visits__c recVisit = new Recognized_Visits__c();
			recVisit.put('Name', 'optIn');

			recVisit.put('utm_campaign__c', 'utm1_' + idx);
			recVisit.put('utm_content__c', 'utm1_' + idx);
			recVisit.put('utm_medium__c', 'utm1_' + idx);
			recVisit.put('utm_source__c', 'utm1_' + idx);
			recVisit.put('Utm_Term__c', 'utm1_' + idx);

			recVisit.put('Date_and_Time__c', System.now());
			recVisit.put('User_Email_Address__c', 'test@' + firstEmail);
			recVisList.add(recVisit);
		}
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Recognized_Visits__c recVisit = new Recognized_Visits__c();
			recVisit.put('Name', 'optIn');

			recVisit.put('utm_campaign__c', 'utm2_' + idx);
			recVisit.put('utm_content__c', 'utm2_' + idx);
			recVisit.put('utm_medium__c', 'utm2_' + idx);
			recVisit.put('utm_source__c', 'utm2_' + idx);
			recVisit.put('Utm_Term__c', 'utm2_' + idx);

			recVisit.put('Date_and_Time__c', System.now());
			recVisit.put('User_Email_Address__c', 'test@' + secondEmail);
			recVisList.add(recVisit);
		}

		//assert list has 2 nonmapped reconVisit records
		System.assertEquals(10, recVisList.size());
		Test.startTest();
			insert recVisList;
		Test.stopTest();

		List<Recognized_Visits__c> testObj1 = [
			SELECT Lead__c, User_Email_Address__c
			FROM Recognized_Visits__c
			WHERE Lead__c =:aLead1.Id
		];
		//assert half of numRepeats records realted to 1st lead
		System.assertEquals(5, testObj1.size());

		List<Recognized_Visits__c> testObj2 = [
			SELECT Lead__c, User_Email_Address__c
			FROM Recognized_Visits__c
			WHERE Lead__c =:aLead2.Id
		];
		//assert half of numRepeats records realted to 2nd lead
		System.assertEquals(5, testObj2.size());

		//all insert records
		List<Recognized_Visits__c> testObj = [SELECT Id FROM Recognized_Visits__c];
		//assert non mapped records deleted
		System.assertEquals(10, testObj.size());

		// assert 1st lead has set utm from visits
		aLead1 = [SELECT Id, utm_campaign__c, utm_content__c, utm_medium__c, utm_source__c, utm_term__c FROM Lead WHERE Id = :aLead1.Id];
		System.assertEquals('utm1_1', aLead1.utm_campaign__c);
		System.assertEquals('utm1_1', aLead1.utm_content__c);
		System.assertEquals('utm1_1', aLead1.utm_content__c);
		System.assertEquals('utm1_1', aLead1.utm_content__c);
		System.assertEquals('utm1_1', aLead1.utm_content__c);

		// assert 2nd lead has old utm
		aLead2 = [SELECT Id, utm_campaign__c, utm_content__c, utm_medium__c, utm_source__c, utm_term__c FROM Lead WHERE Id = :aLead2.Id];
		System.assertEquals('email', aLead2.utm_campaign__c);
		System.assertEquals(null, aLead2.utm_content__c);
		System.assertEquals(null, aLead2.utm_content__c);
		System.assertEquals(null, aLead2.utm_content__c);
		System.assertEquals(null, aLead2.utm_content__c);
	}

	@isTest static void test_bulk_accounts() {

		List<RecordType> paRt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Customer_Account' LIMIT 1];

		Integer start = 1;
		Integer numRepeats = 200;

		String firstEmail = 'yahoo.com';
		String secondEmail = 'example.com';

		Account aPersAcc1 = new Account(
			FirstName = 'Test1 FName',
			LastName = 'Test1 LName',
			PersonEmail = 'test@yahoo.com',
			RecordTypeId = paRt[0].Id
		);
		insert aPersAcc1;

		Account aPersAcc2 = new Account(
			FirstName = 'Test2 FName',
			LastName = 'Test2 LName',
			PersonEmail = 'test@example.com',
			RecordTypeId = paRt[0].Id
		);
		insert aPersAcc2;

		List<Recognized_Visits__c> recVisList = new List<Recognized_Visits__c>();
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Recognized_Visits__c recVisit = new Recognized_Visits__c();
			recVisit.put('Name', 'test_' + idx);
			recVisit.put('Date_and_Time__c', System.now());
			recVisit.put('User_Email_Address__c', (Math.mod(idx, 2) == 0) ? 'test@' + firstEmail : 'test@' + secondEmail);
			recVisList.add(recVisit);
		}
		//not mapped recV
		Recognized_Visits__c recVisit1 = new Recognized_Visits__c();
		recVisit1.put('Name', 'John_1');
		recVisit1.put('Date_and_Time__c', System.now());
		recVisit1.put('User_Email_Address__c', 'not@mapped.com');
		recVisList.add(recVisit1);

		Recognized_Visits__c recVisit2 = new Recognized_Visits__c();
		recVisit2.put('Name', 'John_1');
		recVisit2.put('Date_and_Time__c', System.now());
		recVisit2.put('User_Email_Address__c', 'not@mapped.com');
		recVisList.add(recVisit2);

		//assert list has 2 nonmapped reconVisit records
		System.assertEquals(202, recVisList.size());
		Test.startTest();
			insert recVisList;
		Test.stopTest();

		List<Recognized_Visits__c> testObj1 = [
			SELECT Customer_Contact__c, User_Email_Address__c
			FROM Recognized_Visits__c
			WHERE Customer_Contact__c =:aPersAcc1.Id
		];
		//assert half of numRepeats records realted to 1st lead
		System.assertEquals(100, testObj1.size());

		List<Recognized_Visits__c> testObj2 = [
			SELECT Customer_Contact__c, User_Email_Address__c
			FROM Recognized_Visits__c
			WHERE Customer_Contact__c =:aPersAcc2.Id
		];
		//assert half of numRepeats records realted to 2nd lead
		System.assertEquals(100, testObj2.size());

		//all insert records
		List<Recognized_Visits__c> testObj = [SELECT Id FROM Recognized_Visits__c];
		//assert non mapped records deleted
		System.assertEquals(200, testObj.size());
	}

	@isTest static void test_emladdrecasesens_account() {

		List<RecordType> paRt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Customer_Account' LIMIT 1];

		Account aPersAcc1 = new Account(
			FirstName = 'Test1 FName',
			LastName = 'Test1 LName',
			RecordTypeId = paRt[0].Id,
			PersonEmail = 'test@yahoo.com'
		);
		insert aPersAcc1;

		Account aPersAcc2 = new Account(
			FirstName = 'Test2 FName',
			LastName = 'Test2 LName',
			RecordTypeId = paRt[0].Id,
			PersonEmail = 'TEST@YAHOO.COM'
		);
		insert aPersAcc2;

		Recognized_Visits__c recVisit1 = new Recognized_Visits__c();
		recVisit1.put('Name', 'John_1');
		recVisit1.put('Date_and_Time__c', System.now());
		recVisit1.put('User_Email_Address__c', 'test@yahoo.com');
		insert recVisit1;

		Recognized_Visits__c recVisit2 = new Recognized_Visits__c();
		recVisit2.put('Name', 'John_2');
		recVisit2.put('Date_and_Time__c', System.now());
		recVisit2.put('User_Email_Address__c', 'TEST@YAHOO.COM');
		insert recVisit2;

		List<Recognized_Visits__c> testObj = [SELECT Customer_Contact__c FROM Recognized_Visits__c];
		//email address is case insesitive, so only a 2nd account receives relation
		System.assertEquals(2, testObj.size());
		System.assertEquals(aPersAcc2.Id, testObj[0].Customer_Contact__c);
		System.assertEquals(aPersAcc2.Id, testObj[1].Customer_Contact__c);
	}

	@isTest static void test_bulk_leads() {
		Integer start = 1;
		Integer numRepeats = 200;

		String firstEmail = 'yahoo.com';
		String secondEmail = 'example.com';

		Lead aLead1 = new Lead(
			FirstName = 'Test1 FName',
			LastName = 'Test1 LName',
			Email = 'test@yahoo.com'
		);
		insert aLead1;

		Lead aLead2 = new Lead(
			FirstName = 'Test2 FName',
			LastName = 'Test2 LName',
			Email = 'test@example.com'
		);
		insert aLead2;

		List<Recognized_Visits__c> recVisList = new List<Recognized_Visits__c>();
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Recognized_Visits__c recVisit = new Recognized_Visits__c();
			recVisit.put('Name', 'test_' + idx);
			recVisit.put('Date_and_Time__c', System.now());
			recVisit.put('User_Email_Address__c', (Math.mod(idx, 2) == 0) ? 'test@' + firstEmail : 'test@' + secondEmail);
			recVisList.add(recVisit);
		}
		//not mapped recV
		Recognized_Visits__c recVisit1 = new Recognized_Visits__c();
		recVisit1.put('Name', 'John_1');
		recVisit1.put('Date_and_Time__c', System.now());
		recVisit1.put('User_Email_Address__c', 'not@mapped.com');
		recVisList.add(recVisit1);

		Recognized_Visits__c recVisit2 = new Recognized_Visits__c();
		recVisit2.put('Name', 'John_1');
		recVisit2.put('Date_and_Time__c', System.now());
		recVisit2.put('User_Email_Address__c', 'not@mapped.com');
		recVisList.add(recVisit2);

		//assert list has 2 nonmapped reconVisit records
		System.assertEquals(202, recVisList.size());
		Test.startTest();
			insert recVisList;
		Test.stopTest();

		List<Recognized_Visits__c> testObj1 = [
			SELECT Lead__c, User_Email_Address__c
			FROM Recognized_Visits__c
			WHERE Lead__c =:aLead1.Id
		];
		//assert half of numRepeats records realted to 1st lead
		System.assertEquals(100, testObj1.size());

		List<Recognized_Visits__c> testObj2 = [
			SELECT Lead__c, User_Email_Address__c
			FROM Recognized_Visits__c
			WHERE Lead__c =:aLead2.Id
		];
		//assert half of numRepeats records realted to 2nd lead
		System.assertEquals(100, testObj2.size());

		//all insert records
		List<Recognized_Visits__c> testObj = [SELECT Id FROM Recognized_Visits__c];
		//assert non mapped records deleted
		System.assertEquals(200, testObj.size());
	}

	@isTest static void test_lead_devices() {
		Lead aLead1 = new Lead(
			FirstName = 'Test1 FName',
			LastName = 'Test1 LName',
			Email = 'test@yahoo.com'
		);
		insert aLead1;

		Lead aLead2 = new Lead(
			FirstName = 'Test2 FName',
			LastName = 'Test2 LName',
			Email = 'test@example.com'
		);
		insert aLead2;
		//account 1 got 2 different devices
		Recognized_Visits__c recVisit1Acc1 = new Recognized_Visits__c();
		recVisit1Acc1.put('Name', 'test_1');
		recVisit1Acc1.put('Date_and_Time__c', System.now());
		recVisit1Acc1.put('User_Email_Address__c', 'test@yahoo.com');
		insert recVisit1Acc1;
		Recognized_Visits__c recVisit2Acc1 = new Recognized_Visits__c();
		recVisit2Acc1.put('Name', 'test_1');
		recVisit2Acc1.put('Date_and_Time__c', System.now());
		recVisit2Acc1.put('User_Email_Address__c', 'test@yahoo.com');
		recVisit2Acc1.put('User_Device__c', 'Device#1');
		insert recVisit2Acc1;
		//account 2 got two same devices
		Recognized_Visits__c recVisit1Acc2 = new Recognized_Visits__c();
		recVisit1Acc2.put('Name', 'test_1');
		recVisit1Acc2.put('Date_and_Time__c', System.now());
		recVisit1Acc2.put('User_Email_Address__c', 'test@example.com');
		recVisit1Acc2.put('User_Device__c', 'Device#2');
		insert recVisit1Acc2;
		Recognized_Visits__c recVisit2Acc2 = new Recognized_Visits__c();
		recVisit2Acc2.put('Name', 'test_1');
		recVisit2Acc2.put('Date_and_Time__c', System.now());
		recVisit2Acc2.put('User_Email_Address__c', 'test@example.com');
		recVisit2Acc2.put('User_Device__c', 'Device#2');
		insert recVisit2Acc2;

		List<Recognized_Visit_Device__c> testObj = [SELECT Id FROM Recognized_Visit_Device__c];
		//3 devices, 2 for acc1 and 1 for acc2
		System.assertEquals(3, testObj.size());
		List<Recognized_Visit_Device__c> testObj1 = [SELECT Name FROM Recognized_Visit_Device__c WHERE Lead__c = :aLead1.Id];
		//2 devices for acc1
		System.assertEquals(2, testObj1.size());
		System.assertEquals('Unknown Device', testObj1[0].Name);
		System.assertEquals('Device#1', testObj1[1].Name);

		List<Recognized_Visit_Device__c> testObj2 = [SELECT Name FROM Recognized_Visit_Device__c WHERE Lead__c = :aLead2.Id];
		//2 devices for acc2
		System.assertEquals(1, testObj2.size());
		System.assertEquals('Device#2', testObj2[0].Name);
	}

	@isTest static void test_updateLastVisit() {

		List<RecordType> paRt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Customer_Account' LIMIT 1];

		Account aPersAcc1 = new Account(
			FirstName = 'Test1 FName',
			LastName = 'Test1 LName',
			RecordTypeId = paRt[0].Id,
			PersonEmail = 'test@yahoo.com'
		);
		insert aPersAcc1;

		Recognized_Visit_Device__c recVisitDev1 = new Recognized_Visit_Device__c(Name = 'TestDev1', Customer_Contact__c = aPersAcc1.Id);
		insert recVisitDev1;

		Recognized_Visits__c recVisit1 = new Recognized_Visits__c();
		recVisit1.put('Name', 'John_1');
		recVisit1.put('Date_and_Time__c', System.now()-1);
		recVisit1.put('User_Email_Address__c', 'test@yahoo.com');
		recVisit1.put('User_Device__c', 'TestDev1');
		recVisit1.put('User_Operating_System__c', 'MyTestOS');
		insert recVisit1;

		Recognized_Visits__c recVisit2 = new Recognized_Visits__c();
		recVisit2.put('Name', 'John_1');
		recVisit2.put('Date_and_Time__c', System.now());
		recVisit2.put('User_Email_Address__c', 'test@yahoo.com');
		recVisit2.put('User_Device__c', 'TestDev1');
		recVisit2.put('User_Operating_System__c', 'MyTestOS');
		insert recVisit2;


		List<Recognized_Visits__c> testObj = [SELECT Id, Recognized_Visit_Device__c FROM Recognized_Visits__c WHERE Recognized_Visit_Device__c = :recVisitDev1.Id];
		System.assertEquals(2, testObj.size());
	}

	@isTest static void test_account_devices() {

		List<RecordType> paRt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Customer_Account' LIMIT 1];

		Account aPersAcc1 = new Account(
			FirstName = 'Test1 FName',
			LastName = 'Test1 LName',
			PersonEmail = 'test@yahoo.com',
			RecordTypeId = paRt[0].Id
		);
		insert aPersAcc1;

		Account aPersAcc2 = new Account(
			FirstName = 'Test2 FName',
			LastName = 'Test2 LName',
			PersonEmail = 'test@example.com',
			RecordTypeId = paRt[0].Id
		);
		insert aPersAcc2;
		//account 1 got 2 different devices
		Recognized_Visits__c recVisit1Acc1 = new Recognized_Visits__c();
		recVisit1Acc1.put('Name', 'test_1');
		recVisit1Acc1.put('Date_and_Time__c', System.now());
		recVisit1Acc1.put('User_Email_Address__c', 'test@yahoo.com');
		//insert recVisit1Acc1;
		Recognized_Visits__c recVisit2Acc1 = new Recognized_Visits__c();
		recVisit2Acc1.put('Name', 'test_1');
		recVisit2Acc1.put('Date_and_Time__c', System.now());
		recVisit2Acc1.put('User_Email_Address__c', 'test@yahoo.com');
		recVisit2Acc1.put('User_Device__c', 'Device#1');
		//insert recVisit2Acc1;

		insert new List<Recognized_Visits__c>{recVisit1Acc1, recVisit2Acc1};

		//account 2 got two same devices
		Recognized_Visits__c recVisit1Acc2 = new Recognized_Visits__c();
		recVisit1Acc2.put('Name', 'test_1');
		recVisit1Acc2.put('Date_and_Time__c', System.now());
		recVisit1Acc2.put('User_Email_Address__c', 'test@example.com');
		recVisit1Acc2.put('User_Device__c', 'SMARTPHONE iPhone');
		recVisit1Acc2.put('User_Operating_System__c', 'Chrome');
		//insert recVisit1Acc2;
		Recognized_Visits__c recVisit2Acc2 = new Recognized_Visits__c();
		recVisit2Acc2.put('Name', 'test_1');
		recVisit2Acc2.put('Date_and_Time__c', System.now());
		recVisit2Acc2.put('User_Email_Address__c', 'test@example.com');
		recVisit2Acc2.put('User_Device__c', 'SMARTPHONE iPhone');
		recVisit2Acc2.put('User_Operating_System__c', 'Chrome');
		//insert recVisit2Acc2;

		insert new List<Recognized_Visits__c>{recVisit1Acc2, recVisit2Acc2};

		List<Recognized_Visit_Device__c> testObj = [SELECT Id FROM Recognized_Visit_Device__c];
		//3 devices, 2 for acc1 and 1 for acc2
		System.assertEquals(3, testObj.size());
		List<Recognized_Visit_Device__c> testObj1 = [SELECT Name FROM Recognized_Visit_Device__c WHERE Customer_Contact__c = :aPersAcc1.Id];
		//2 devices for acc1
		System.assertEquals(2, testObj1.size());
		System.assertEquals('Unknown Device', testObj1[0].Name);
		System.assertEquals('Device#1', testObj1[1].Name);

		List<Recognized_Visit_Device__c> testObj2 = [SELECT Name FROM Recognized_Visit_Device__c WHERE Customer_Contact__c = :aPersAcc2.Id];
		//1 devices for acc2
		System.assertEquals(1, testObj2.size());
		System.assertEquals('SMARTPHONE iPhone', testObj2[0].Name);
	}
}