@isTest(seeAllData = false)
private class OrderTriggerTest {

	@isTest static void test_afterinsert_wronguser_oneorder() {

		List<RecordType> rec = [
			SELECT Id, Name
			FROM RecordType
			WHERE SObjectType = 'Account'
			AND DeveloperName = 'Customer_Account'
			AND isActive = true
			LIMIT 1
		];
		Id personRTId;
		if (!rec.isEmpty()) {
			personRTId = rec[0].Id;
		}
		Account testAcc = new Account(LastName = 'LongLastName', RecordTypeId = personRTId);
		insert testAcc;

		insert new TouchCR_Settings__c(Name = 'Chargent.OrderUserCreation', Value__c = 'true');

		Test.startTest();
		Order__c testOrd = new Order__c();
		testOrd.Account__c = testAcc.Id;
		insert testOrd;
		Test.stopTest();

		List<Account> testObj = [
			SELECT
				Large_Order_Value__c, Number_of_Orders__c, Refunds_and_Fails_Total__c, Subtotal_From_Zero_Balance_Orders__c, Number_Of_Zero_Balance_Orders__c
			FROM Account
			WHERE Id = :testAcc.Id
		];
		System.assertEquals(0, testObj[0].Large_Order_Value__c);
		System.assertEquals(0, testObj[0].Refunds_and_Fails_Total__c);
		System.assertEquals(0, testObj[0].Subtotal_From_Zero_Balance_Orders__c);
		System.assertEquals(1, testObj[0].Number_Of_Zero_Balance_Orders__c);
	}

	@isTest static void test_afterinsert_gooduser() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		//Profile profUser = [SELECT Id, Name FROM Profile WHERE Name ='Customer Community Login User' LIMIT 1];
		Profile profUser = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

		Map<String, String> brandToProfileTest = new Map<String, String>{
			'brand1' => profUser.Id
		};
		TouchCRConfigurationController.setAvailableBrandsToProfileTest(new Map<String, String>(brandToProfileTest));

		List<RecordType> rec = [
			SELECT Id, Name
			FROM RecordType
			WHERE SObjectType = 'Account'
			AND DeveloperName = 'Customer_Account'
			AND isActive = true
			LIMIT 1
		];
		Id personRTId;
		if (!rec.isEmpty()) {
			personRTId = rec[0].Id;
		}

		Account testAcc = new Account(
			FirstName = 'Test FName',
			LastName = 'Test LName',
			Average_Order_Value__c = 0,
			RecordTypeId = personRTId,
			PersonEmail = 'test@example.com',
			Brand_Assortment__c = 'brand1'
		);

		insert new TouchCR_Settings__c(Name = 'Chargent.OrderUserCreation', Value__c = 'true');

		insert testAcc;
		List<Account> testObj1 = [
			SELECT OwnerId
			FROM Account
			WHERE Id = :testAcc.Id
		];

		System.runAs(thisUser) {
			Test.startTest();
			List<Order__c> testOrdList = new List<Order__c>();
			for (Integer idx = 0; idx < 10; idx++) {
				Order__c testOrd = new Order__c();
				testOrd.Account__c = testAcc.Id;
				testOrdList.add(testOrd);
			}
			insert testOrdList;
			Test.stopTest();
		}

		//List<User> testUser = [
		//	SELECT FirstName, LastName, Username, ProfileId
		//	FROM User
		//	WHERE LastName = :testAcc.LastName
		//];

		//System.assertEquals(1, testUser.size());
		//System.assertEquals(profUser.Id, testUser[0].ProfileId);

		List<Account> testObj = [
			SELECT OwnerId, Large_Order_Value__c, Number_of_Orders__c, Refunds_and_Fails_Total__c, Subtotal_From_Zero_Balance_Orders__c, Number_Of_Zero_Balance_Orders__c
			FROM Account
			WHERE Id = :testAcc.Id
		];
		System.assertEquals(10, testObj[0].Number_Of_Zero_Balance_Orders__c);
	}

	@isTest static void test_bulkorders_insert_delete() {

		List<RecordType> rec = [
			SELECT Id, Name
			FROM RecordType
			WHERE SObjectType = 'Account'
			AND DeveloperName = 'Customer_Account'
			AND isActive = true
			LIMIT 1
		];
		Id personRTId;
		if (!rec.isEmpty()) {
			personRTId = rec[0].Id;
		}

		Account testAcc = new Account(
			FirstName = 'Test FName',
			LastName = 'Test LName',
			Average_Order_Value__c = 0,
			RecordTypeId = personRTId,
			PersonEmail = 'test@example.com'
		);
		insert testAcc;

		Test.startTest();
		List<Order__c> testOrdList = new List<Order__c>();

		for (Integer idx = 0; idx < 10; idx++) {
			Order__c testOrd = new Order__c();
			testOrd.Account__c = testAcc.Id;
			testOrd.Subtotal__c = idx + 10;
			testOrdList.add(testOrd);
		}
		insert testOrdList;

		delete testOrdList[0];

		Test.stopTest();

		List<Account> testObj = [
			SELECT
				Average_Order_Value__c, Large_Order_Value__c, Number_of_Orders__c, Refunds_and_Fails_Total__c, Subtotal_From_Zero_Balance_Orders__c, Number_Of_Zero_Balance_Orders__c
			FROM Account
			WHERE Id = :testAcc.Id
		];

		System.assertEquals(9, testObj[0].Number_of_Orders__c);
	}

	@isTest static void test_update_positivevalues() {

		List<RecordType> rec = [
			SELECT Id, Name
			FROM RecordType
			WHERE SObjectType = 'Account'
			AND DeveloperName = 'Customer_Account'
			AND isActive = true
			LIMIT 1
		];
		Id personRTId;
		if (!rec.isEmpty()) {
			personRTId = rec[0].Id;
		}

		Account testAcc = new Account(
			FirstName = 'Test FName',
			LastName = 'Test LName',
			Average_Order_Value__c = 0,
			RecordTypeId = personRTId,
			PersonEmail = 'test@example.com'
		);
		insert testAcc;

		Test.startTest();
		List<Order__c> testOrdList = new List<Order__c>();

		for (Integer idx = 0; idx < 2; idx++) {
			Order__c testOrd = new Order__c();
			testOrd.Account__c = testAcc.Id;
			testOrd.Subtotal__c = idx;
			testOrdList.add(testOrd);
		}
		insert testOrdList;

		List<Order_Transaction__c> testTransList = new List<Order_Transaction__c>();

		for (Order__c testOrd : testOrdList) {
			Order_Transaction__c testTrans = new Order_Transaction__c();
			testTrans.Order__c = testOrd.Id;
			testTrans.Named_Agent__c = 'Authorize.net';
			testTrans.Type__c = 'Charge';
			testTrans.Payment_Date__c = Datetime.now();
			testTrans.Response_Status__c = 'Approved';
			testTrans.Amount__c = testOrd.Subtotal__c;
			testTransList.add(testTrans);
		}
		insert testTransList;

		update testOrdList;

		Test.stopTest();

		List<Account> testObj = [
			SELECT
				Average_Order_Value__c, Large_Order_Value__c, Number_of_Orders__c, Refunds_and_Fails_Total__c, Subtotal_From_Zero_Balance_Orders__c, Number_Of_Zero_Balance_Orders__c
			FROM Account
			WHERE Id = :testAcc.Id
		];

		System.assertEquals(0.5, testObj[0].Average_Order_Value__c);
		System.assertEquals(1, testObj[0].Large_Order_Value__c);
		System.assertEquals(2, testObj[0].Number_of_Orders__c);
		System.assertEquals(0, testObj[0].Refunds_and_Fails_Total__c);
		System.assertEquals(1, testObj[0].Subtotal_From_Zero_Balance_Orders__c);
		System.assertEquals(2, testObj[0].Number_Of_Zero_Balance_Orders__c);
	}

	@isTest static void test_paymentrequest_notcreated_unpaidorder() {
		List<RecordType> rec = [
			SELECT Id, Name
			FROM RecordType
			WHERE SObjectType = 'Account'
			AND DeveloperName = 'Customer_Account'
			AND isActive = true
			LIMIT 1
		];
		Id personRTId;
		if (!rec.isEmpty()) {
			personRTId = rec[0].Id;
		}

		Account testAcc = new Account(
			FirstName = 'Test FName',
			LastName = 'Test LName',
			Average_Order_Value__c = 0,
			RecordTypeId = personRTId,
			PersonEmail = 'test@example.com'
		);

		insert new TouchCR_Settings__c(Name = 'Chargent.OrderUserCreation', Value__c = 'false');

		insert testAcc;

		Test.startTest();
		Order__c testOrd = new Order__c();
		testOrd.Account__c = testAcc.Id;
		testOrd.Subtotal__c = 100;
		testOrd.Status__c = 'Initiated';
		testOrd.Billing_Email__c = 'test@example.com';
		insert testOrd;

		Order_Transaction__c testTrans = new Order_Transaction__c();
		testTrans.Order__c = testOrd.Id;
		testTrans.Payment_Date__c = Datetime.now();
		testTrans.Named_Agent__c = 'Authorize.net';
		testTrans.Type__c = 'Authorization';
		testTrans.Response_Status__c = 'Error';
		insert testTrans;

		Test.stopTest();

		List<Order__c> testOrder = [
			SELECT Balance_Due__c, Transaction_Count__c
			FROM Order__c
		];
		System.assertEquals(1, testOrder.size());
		System.assertEquals(100, testOrder[0].Balance_Due__c);

		List<Order_Transaction__c> testTransaction = [
			SELECT Order__c, Named_Agent__c, Type__c, Response_Status__c
			FROM Order_Transaction__c
		];
		System.assertEquals(1, testTransaction.size());
		System.assertEquals('Error', testTransaction[0].Response_Status__c);

		List<Case> testCase = [SELECT Status, Type, Reason_Case__c FROM Case];
		System.assertEquals(0, testCase.size());
	}

	@isTest static void test_paymentrequest_notcreated() {
		List<RecordType> rec = [
			SELECT Id, Name
			FROM RecordType
			WHERE SObjectType = 'Account'
			AND DeveloperName = 'Customer_Account'
			AND isActive = true
			LIMIT 1
		];
		Id personRTId;
		if (!rec.isEmpty()) {
			personRTId = rec[0].Id;
		}

		Account testAcc = new Account(
			FirstName = 'Test FName',
			LastName = 'Test LName',
			Average_Order_Value__c = 0,
			RecordTypeId = personRTId,
			PersonEmail = 'test@example.com'
		);

		insert new TouchCR_Settings__c(Name = 'Chargent.OrderUserCreation', Value__c = 'false');

		insert testAcc;

		Test.startTest();
		Order__c testOrd = new Order__c();
		testOrd.Account__c = testAcc.Id;
		testOrd.Subtotal__c = 100;
		testOrd.Billing_Email__c = 'test@example.com';
		insert testOrd;

		Order_Transaction__c testTrans = new Order_Transaction__c();
		testTrans.Order__c = testOrd.Id;
		testTrans.Named_Agent__c = 'Authorize.net';
		testTrans.Type__c = 'Charge';
		testTrans.Payment_Date__c = Datetime.now();
		testTrans.Response_Status__c = 'Approved';
		testTrans.Amount__c = testOrd.Subtotal__c;
		insert testTrans;

		Test.stopTest();

		List<Order__c> testOrder = [
			SELECT Balance_Due__c, Transaction_Count__c
			FROM Order__c
		];
		System.assertEquals(1, testOrder.size());
		System.assertEquals(0, testOrder[0].Balance_Due__c);

		List<Order_Transaction__c> testTransaction = [
			SELECT Order__c, Named_Agent__c, Type__c, Response_Status__c
			FROM Order_Transaction__c
		];
		System.assertEquals(1, testTransaction.size());
		System.assertEquals('Approved', testTransaction[0].Response_Status__c);
	}

	@isTest static void test_afterinsert_gooduser_checkprofilestobrands() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		//List<Profile> profUser = [SELECT Id, Name FROM Profile WHERE UserLicense.Name ='Customer Community Login' LIMIT 5];
		List<Profile> profUser = [SELECT Id, Name FROM Profile WHERE UserLicense.Name = 'System Administrator' LIMIT 5];

		Map<String, String> brandToProfileTest = new Map<String, String>();
		for (Integer idx = 0; idx < profUser.size(); idx++) {
			brandToProfileTest.put('brand' + idx, String.valueOf(profUser[idx].Id));
		}
		TouchCRConfigurationController.setAvailableBrandsToProfileTest(new Map<String, String>(brandToProfileTest));

		List<RecordType> rec = [
			SELECT Id, Name
			FROM RecordType
			WHERE SObjectType = 'Account'
			AND DeveloperName = 'Customer_Account'
			AND isActive = true
			LIMIT 1
		];
		Id personRTId;
		if (!rec.isEmpty()) {
			personRTId = rec[0].Id;
		}

		List<Account> accList = new List<Account>();
		Set<String> lastNameSet = new Set<String>();
		for (Integer idx = 0; idx < profUser.size(); idx++) {
			Account testAcc = new Account(
				FirstName = idx + 'FName',
				LastName = idx + 'LName',
				Average_Order_Value__c = 0,
				RecordTypeId = personRTId,
				PersonEmail = idx + 'test@example.com',
				Brand_Assortment__c = 'brand' + idx
			);
			lastNameSet.add(testAcc.LastName);
			accList.add(testAcc);
		}

		insert new TouchCR_Settings__c(Name = 'Chargent.OrderUserCreation', Value__c = 'true');

		insert accList;

		System.runAs(thisUser) {
			Test.startTest();
			List<Order__c> testOrdList = new List<Order__c>();
			for (Integer idx = 0; idx < profUser.size(); idx++) {
				Order__c testOrd = new Order__c();
				testOrd.Account__c = accList[idx].Id;
				testOrdList.add(testOrd);
			}
			insert testOrdList;
			Test.stopTest();
		}

		List<User> testUser = [
			SELECT FirstName, LastName, Username, ProfileId
			FROM User
			WHERE LastName IN :lastNameSet
			ORDER BY LastName
		];

		for (Integer idx = 0; idx < profUser.size(); idx++) {
			System.assertEquals(brandToProfileTest.get('brand' + idx), testUser[idx].ProfileId);
		}
		System.assertEquals(profUser.size(), testUser.size());
	}

	/*
	@isTest static void test_afterinsert_massaccount() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		//Profile profUser = [SELECT Id, Name FROM Profile WHERE UserLicense.Name ='Customer Community Login' LIMIT 1];
		Profile profUser = [SELECT Id, Name FROM Profile WHERE UserLicense.Name ='Customer Community Login' LIMIT 1];

		Map<String, String> brandToProfileTest = new Map<String, String>{'brand1' => profUser.Id};
		TouchCRConfigurationController.setAvailableBrandsToProfileTest(new Map<String, String>(brandToProfileTest));

		List<RecordType> rec = [
			SELECT Id, Name
			FROM RecordType
			WHERE SObjectType = 'Account'
			AND DeveloperName = 'Customer_Account'
			AND isActive = true
			LIMIT 1
		];
		Id personRTId;
		if (!rec.isEmpty()) {
			personRTId = rec[0].Id;
		}

		List<Account> accList = new List<Account>();
		Set<String> lastNameSet = new Set<String>();
		for (Integer idx = 0; idx < 100; idx++) {
			Account testAcc = new Account(
				FirstName = idx + 'FName',
				LastName = idx + 'LName',
				Average_Order_Value__c = 0,
				RecordTypeId = personRTId,
				PersonEmail = idx + 'test@example.com',
				Brand_Assortment__c = 'brand1'
			);
			lastNameSet.add(testAcc.LastName);
			accList.add(testAcc);
		}

		insert new TouchCR_Settings__c(Name = 'Chargent.OrderUserCreation', Value__c = 'true');

		insert accList;

		System.runAs(thisUser) {
			Test.startTest();
				List<Order__c> testOrdList = new List<Order__c>();
				for (Integer idx = 0; idx < 100; idx++) {
					Order__c testOrd = new Order__c();
					testOrd.Account__c = accList[idx].Id;
					testOrdList.add(testOrd);
				}
				insert testOrdList;
			Test.stopTest();
		}

		List<User> testUser = [
			SELECT FirstName, LastName, Username, ProfileId
			FROM User
			WHERE LastName IN : lastNameSet
		];

		System.assertEquals(100, testUser.size());
		for (User us : testUser) {
			System.assertEquals(profUser.Id, us.ProfileId);
		}
	}*/
}