@isTest
private class DataAppendBatchTest {

	public static final Integer OLDER_THAN_DAYS = 5;
	public static final Integer REAPPEND_ON_DAYS = 10;
	public static final String OK_EMAIL = '{"email":{"ok":true,"status_code":110,"status_desc":"Invalid character in address","validation_level":2,"address":"john;doe@example.com","username":null,"domain":null,"domain_type":null,"role":false,"corrections":["john.doe@example.com","johndoe@example.com"]},"found_postal":{"ok":true,"status_code":10,"status_desc":"Data found","fname":"JANE","lname":"SMITH","address1":"100 MAIN ST APT 3","address2":null,"city":"SPRINGFIELD","state":"MA","zip":"11111","plus4":"1234","source":"email"},"ip":{"status_code":10,"status_desc":"IP Found","ok":true,"address":"66.108.76.101","country_code":"US","country_name":"UNITED STATES","region":"NY","city":"NEW YORK","isp":"TIME WARNER CABLE","domain":"roadrunner.com"},"status_code":10,"status_desc":"Success"}';
	public static final String NOT_CORRECTION_EMAIL = '{"email":{"corrections":["gbrown696@gmail.com"],"ok":false,"validation_level":2,"status_code":310,"status_desc":"Domain does not exist","address":"gbrown696@gmail.org","username":"gbrown696","domain":"gmail.org","domain_type":"org","role":false},"status_code":10,"status_desc":"Success"}';

	@isTest static void test_needtoappendonnew() {
		// SETTINGS
		// new accounts processed
		// new leads NOT processed
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Lead.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Lead.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.EmailOn', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.License', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'Global.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '10')
		};
		insert settingsList;

		// insert new TouchCR_Settings__c(Name = 'Global.ReappendOnDays', Value__c = String.valueOf(REAPPEND_ON_DAYS));
		// insert new TouchCR_Settings__c(Name = 'Global.IgnoreOlderThan', Value__c = String.valueOf(Date.today().addDays(-OLDER_THAN_DAYS)));

		//do not set response body
		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock());
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testObj1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'johndoe@example.com');
		insert testObj1;
		testObj1 = [SELECT Append_Need_Append__c, Email_Append_Run__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(true, testObj1.Append_Need_Append__c);

		Lead testObj2 = new Lead(
			FirstName = 'Jane',
			LastName = 'Doe',
			Email = 'janedoe@example.com');
		insert testObj2;

		testObj2 = [SELECT Append_Need_Append__c, Email_Append_Run__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(false, testObj2.Append_Need_Append__c);

		// Test.setCreatedDate(testObj1.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS + 1)));
		// Test.setCreatedDate(testObj2.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS - 1)));

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		testObj1 = [SELECT Email_Checked__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(true, testObj1.Email_Checked__c);

		testObj2 = [SELECT Email_Checked__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(false, testObj2.Email_Checked__c);
	}

	@isTest static void test_reappendondays() {
		// SETTINGS
		// new accounts NOT processed
		// new leads NOT processed
		// reappend on account IN range
		// reappend on lead OUT OF range
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Lead.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Lead.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Lead.AppendDemographicBasics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.AppendDemographicBasics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.EmailOn', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.ReappendOnDays', Value__c = String.valueOf(REAPPEND_ON_DAYS)),
			new TouchCR_Settings__c(Name = 'Global.License', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'Global.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '10')
		};
		insert settingsList;

		//insert new TouchCR_Settings__c(Name = 'Global.IgnoreOlderThan', Value__c = String.valueOf(Date.today().addDays(-OLDER_THAN_DAYS)));

		//do not set response body
		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock());
		List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testObj1 = new Account(
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'johndoe@example.com',
			RecordTypeId = rtList[0].Id,
			Append_Run__c = true,
			Append_Run_Date__c = DateTime.now().addDays(-(REAPPEND_ON_DAYS + 2))
		);
		insert testObj1;

		testObj1 = [SELECT Append_Need_Append__c, Email_Append_Run__c, Email_Append_Run_Date__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(false, testObj1.Append_Need_Append__c);

		Lead testObj2 = new Lead(
			FirstName = 'Jane',
			LastName = 'Doe',
			Email = 'janedoe@example.com',
			Append_Run__c = true,
			Append_Run_Date__c = DateTime.now().addDays(-(REAPPEND_ON_DAYS - 2))
		);
		insert testObj2;

		testObj2 = [SELECT Append_Need_Append__c, Email_Append_Run__c, Email_Append_Run_Date__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(false, testObj2.Append_Need_Append__c);

		//Test.setCreatedDate(testObj1.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS + 1)));
		//Test.setCreatedDate(testObj2.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS - 1)));

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		//LOGS
		List<Log__c> logs = [SELECT Event_Status__c, Event_Description__c, Event_Endpoint__c, Event_Type__c FROM Log__c];
		// 2 logs, account 1 for EMAIL and 1 for DEMO
		System.assertEquals(2, logs.size());
		// ACCOUNT
		testObj1 = [SELECT Email_Checked__c, Append_Demo_Gender__c FROM Account WHERE Id = :testObj1.Id];
		//assert EMAIL APPEND
		System.assertEquals(true, testObj1.Email_Checked__c);
		//assert DEMO APPEND
		System.assertEquals('Female', testObj1.Append_Demo_Gender__c);
		//LEAD
		testObj2 = [SELECT Email_Checked__c, Append_Demo_Gender__c FROM Lead WHERE Id = :testObj2.Id];
		//assert EMAIL APPEND
		System.assertEquals(false, testObj2.Email_Checked__c);
		//assert DEMO APPEND
		System.assertEquals(null, testObj2.Append_Demo_Gender__c);
	}

	@isTest static void test_reappendondays_null() {
		// SETTINGS
		// new accounts NOT processed
		// new leads NOT processed
		// reappend on account IN range
		// reappend on lead OUT OF range
		// REAPPENDONDAYS IS NOT SET, NO RECORDS WILL BE PROCESSED
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Lead.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Lead.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Lead.AppendDemographicBasics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.AppendDemographicBasics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.EmailOn', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.License', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'Global.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '10')
		};
		insert settingsList;

		//insert new TouchCR_Settings__c(Name = 'Global.ReappendOnDays', Value__c = String.valueOf(REAPPEND_ON_DAYS));
		//insert new TouchCR_Settings__c(Name = 'Global.IgnoreOlderThan', Value__c = String.valueOf(Date.today().addDays(-OLDER_THAN_DAYS)));

		//do not set response body
		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock());
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testObj1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'johndoe@example.com',
			Append_Run__c = true,
			Append_Run_Date__c = DateTime.now().addDays(-(REAPPEND_ON_DAYS + 1))
		);
		insert testObj1;
		testObj1 = [SELECT Append_Need_Append__c, Email_Append_Run__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(false, testObj1.Append_Need_Append__c);

		Lead testObj2 = new Lead(
			FirstName = 'Jane',
			LastName = 'Doe',
			Email = 'janedoe@example.com',
			Append_Run__c = true,
			Append_Run_Date__c = DateTime.now().addDays(-(REAPPEND_ON_DAYS - 1))
		);
		insert testObj2;
		testObj2 = [SELECT Append_Need_Append__c, Email_Append_Run__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(false, testObj2.Append_Need_Append__c);

		// Test.setCreatedDate(testObj1.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS + 1)));
		// Test.setCreatedDate(testObj2.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS - 1)));

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		//LOGS
		List<Log__c> logs = [SELECT Event_Status__c, Event_Description__c, Event_Endpoint__c, Event_Type__c FROM Log__c];
		// 0
		System.assertEquals(0, logs.size());
		// ACCOUNT
		testObj1 = [SELECT Email_Checked__c, Append_Demo_Gender__c FROM Account WHERE Id = :testObj1.Id];
		//assert EMAIL APPEND
		System.assertEquals(false, testObj1.Email_Checked__c);
		//assert DEMO APPEND
		System.assertEquals(null, testObj1.Append_Demo_Gender__c);
		//LEAD
		testObj2 = [SELECT Email_Checked__c, Append_Demo_Gender__c FROM Lead WHERE Id = :testObj2.Id];
		//assert EMAIL APPEND
		System.assertEquals(false, testObj2.Email_Checked__c);
		//assert DEMO APPEND
		System.assertEquals(null, testObj2.Append_Demo_Gender__c);
	}

	@isTest static void test_ignoreolderthan() {
		// SETTINGS
		// new accounts NOT processed
		// new leads NOT processed
		// reappend on account FALSE
		// reappend on lead FALSE
		// ignore older that 10 DAYS
		// account created OLDER_THAN_DAYS - 1 days ago processed
		// lead created OLDER_THAN_DAYS + 1 days ago NOT processed
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Lead.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Lead.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Lead.AppendDemographicBasics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.AppendDemographicBasics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.EmailOn', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.IgnoreOlderThan', Value__c = String.valueOf(DateTime.now().addDays(-OLDER_THAN_DAYS).dateGMT())),
			new TouchCR_Settings__c(Name = 'Global.License', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'Global.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '10')
		};
		insert settingsList;

		//insert new TouchCR_Settings__c(Name = 'Global.ReappendOnDays', Value__c = String.valueOf(REAPPEND_ON_DAYS));

		//do not set response body
		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock());
		List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testObj1 = new Account(
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'johndoe@example.com',
			RecordTypeId = rtList[0].Id,
			Append_Run__c = false,
			Append_Run_Date__c = DateTime.now().addDays(-(REAPPEND_ON_DAYS + 2))
		);
		insert testObj1;
		testObj1 = [SELECT Append_Need_Append__c, Email_Append_Run__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(false, testObj1.Append_Need_Append__c);

		Lead testObj2 = new Lead(
			FirstName = 'Jane',
			LastName = 'Doe',
			Email = 'janedoe@example.com',
			Append_Run__c = false,
			Append_Run_Date__c = DateTime.now().addDays(-(REAPPEND_ON_DAYS - 2))
		);
		insert testObj2;
		testObj2 = [SELECT Append_Need_Append__c, Email_Append_Run__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(false, testObj2.Append_Need_Append__c);

		Test.setCreatedDate(testObj1.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS - 2))); // ok
		Test.setCreatedDate(testObj2.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS + 2)));

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		//LOGS
		List<Log__c> logs = [SELECT Event_Status__c, Event_Description__c, Event_Endpoint__c, Event_Type__c FROM Log__c];
		// 2 logs, account 1 for EMAIL and 1 for DEMO
		System.assertEquals(2, logs.size());
		// ACCOUNT
		testObj1 = [SELECT Email_Checked__c, Append_Demo_Gender__c FROM Account WHERE Id = :testObj1.Id];
		//assert EMAIL APPEND
		System.assertEquals(true, testObj1.Email_Checked__c);
		//assert DEMO APPEND
		System.assertEquals('Female', testObj1.Append_Demo_Gender__c);
		//LEAD
		testObj2 = [SELECT Email_Checked__c, Append_Demo_Gender__c FROM Lead WHERE Id = :testObj2.Id];
		//assert EMAIL APPEND
		System.assertEquals(false, testObj2.Email_Checked__c);
		//assert DEMO APPEND
		System.assertEquals(null, testObj2.Append_Demo_Gender__c);
	}

	@isTest static void test_creatednewcasefornotcorrectemail () {
		// SETTINGS
		// new accounts processed
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
		new TouchCR_Settings__c(Name = 'Account.ValidateEmail', Value__c = 'true'),
		new TouchCR_Settings__c(Name = 'Account.EnableDemographics', Value__c = 'true'),
		new TouchCR_Settings__c(Name = 'Global.EmailOn', Value__c = 'true'),
		new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'true'),
		new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'false'),
		new TouchCR_Settings__c(Name = 'Global.License', Value__c = 'apikey'),
		new TouchCR_Settings__c(Name = 'Global.APIKey', Value__c = 'apikey'),
		new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '10')
		};
		insert settingsList;

		//do not set response body
		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock(NOT_CORRECTION_EMAIL));
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testObj1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'johndoe@example.com');
		insert testObj1;

		testObj1 = [SELECT Append_Need_Append__c, Email_Append_Run__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(true, testObj1.Append_Need_Append__c);

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		testObj1 = [SELECT Email_Checked__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(true, testObj1.Email_Checked__c);

		List<Case> testCase = [SELECT Id FROM Case WHERE AccountId = :testObj1.Id AND Subject = 'Correction Email'];
		System.assertEquals(1, testCase.size());
	}

	@isTest static void test_repeatedcasecorrectemail () {
		// SETTINGS
		// new accounts processed
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Account.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.EmailOn', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.License', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'Global.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '10')
		};
		insert settingsList;

		//do not set response body
		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock(OK_EMAIL));

		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testObj1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'johndoe@example.com',
			Email_Corrections__c = 'Email_Corrections');
		insert testObj1;

		Case testCase1 = new Case (
			Subject = 'Correction Email', AccountId = testObj1.Id,
			Status = 'New', Origin = 'Email'
			);
		insert testCase1;

		testObj1 = [SELECT Append_Need_Append__c, Email_Append_Run__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(true, testObj1.Append_Need_Append__c);

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		testObj1 = [SELECT Email_Checked__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(true, testObj1.Email_Checked__c);

		List<Case> testCase = [SELECT Id FROM Case WHERE AccountId = :testObj1.Id AND Subject = 'Correction Email'];
		System.assertEquals(1, testCase.size());
	}

	@isTest static void test_settingscheduler () {
		// SETTINGS
		// new accounts processed
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Account.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.EmailOn', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.License', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'Global.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'Batch.DataAppendState', Value__c = 'On'),
			new TouchCR_Settings__c(Name = 'Batch.DataAppendTime', Value__c = '1'),
			new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '10')
		};
		insert settingsList;

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		List<CronTrigger> scheduleInProgress = [SELECT Id, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name =: 'DataAppend'];
		System.assertEquals(1, scheduleInProgress.size());
	}

	@isTest static void test_needtoappendonnew_ignoreamazon() {
		// SETTINGS
		// new accounts processed
		// new leads NOT processed
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Lead.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Lead.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.EmailOn', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.License', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'Global.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '10')
		};
		insert settingsList;

		// insert new TouchCR_Settings__c(Name = 'Global.ReappendOnDays', Value__c = String.valueOf(REAPPEND_ON_DAYS));
		// insert new TouchCR_Settings__c(Name = 'Global.IgnoreOlderThan', Value__c = String.valueOf(Date.today().addDays(-OLDER_THAN_DAYS)));

		//do not set response body
		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock());
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testObj1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'John',
			LastName = 'Doe'
		);
		insert testObj1;
		testObj1 = [SELECT Append_Need_Append__c, Email_Append_Run__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(true, testObj1.Append_Need_Append__c);

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		testObj1 = [SELECT Email_Append_Run__c, Email_Checked__c FROM Account WHERE Id = :testObj1.Id];
		// skip email append callout at all
		System.assertEquals(false, testObj1.Email_Append_Run__c);
		// email skipped
		System.assertEquals(false, testObj1.Email_Checked__c);
		// 1 logs for demo append only
		List<Log__c> logs = [SELECT Id FROM Log__c WHERE Account__c = :testObj1.Id];
		// no log records were created, no api call
		System.assertEquals(1, logs.size());
	}

	@isTest static void test_needtoappendonnewlead() {
		// SETTINGS
		// new accounts NOT processed
		// new leads processed
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Lead.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Lead.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Account.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.EmailOn', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.License', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'Global.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '10')
		};
		insert settingsList;

		// insert new TouchCR_Settings__c(Name = 'Global.ReappendOnDays', Value__c = String.valueOf(REAPPEND_ON_DAYS));
		// insert new TouchCR_Settings__c(Name = 'Global.IgnoreOlderThan', Value__c = String.valueOf(Date.today().addDays(-OLDER_THAN_DAYS)));

		//do not set response body
		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock());
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testObj1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'johndoe@example.com');
		insert testObj1;
		testObj1 = [SELECT Append_Need_Append__c, Email_Append_Run__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(false, testObj1.Append_Need_Append__c);

		Lead testObj2 = new Lead(
			FirstName = 'Jane',
			LastName = 'Doe',
			Email = 'janedoe@example.com');
		insert testObj2;

		testObj2 = [SELECT Append_Need_Append__c, Email_Append_Run__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(true, testObj2.Append_Need_Append__c);

		// Test.setCreatedDate(testObj1.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS + 1)));
		// Test.setCreatedDate(testObj2.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS - 1)));

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		testObj1 = [SELECT Email_Checked__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(false, testObj1.Email_Checked__c);

		testObj2 = [SELECT Email_Checked__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(true, testObj2.Email_Checked__c);
	}

	@isTest static void test_settingschedulerlead() {
		// SETTINGS
		// new lead processed
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Lead.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Lead.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.EmailOn', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.License', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'Global.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'Batch.DataAppendState', Value__c = 'On'),
			new TouchCR_Settings__c(Name = 'Batch.DataAppendTime', Value__c = '1'),
			new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '10')
		};
		insert settingsList;

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		List<CronTrigger> scheduleInProgress = [SELECT Id, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name =: 'DataAppend'];
		System.assertEquals(1, scheduleInProgress.size());
	}

	@isTest static void test_settingsnotapprove() {
		// SETTINGS
		// new lead processed
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Lead.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Lead.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.EmailOn', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.License', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'Global.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '0'),
			new TouchCR_Settings__c(Name = 'DataAppend.ApproverEmail1', Value__c = 'test@mail.com'),
			new TouchCR_Settings__c(Name = 'DataAppend.ApproverEmail2', Value__c = 'test1@mail.com'),
			new TouchCR_Settings__c(Name = 'DataAppend.ApproverEmail3', Value__c = 'test2@mail.com')
		};
		insert settingsList;
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testObj1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'johndoe@example.com',
			Append_Need_Append__c = true
		);
		insert testObj1;

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();


		testObj1 = [SELECT Append_Need_Append__c, Email_Append_Run__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(false, testObj1.Email_Append_Run__c);

		List<TouchCR_Settings__c> listTouchCRSettings = [SELECT Id, Name, Value__c FROM TouchCR_Settings__c WHERE Name =: 'DataAppend.Excess'];
		System.assertEquals('1', listTouchCRSettings[0].Value__c);
	}

	@isTest static void test_settingsapprove() {
		// SETTINGS
		// new lead processed
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Lead.ValidateEmail', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Lead.EnableDemographics', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.EmailOn', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.License', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'Global.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'DataAppend.Limit', Value__c = '0'),
			new TouchCR_Settings__c(Name = 'DataAppend.Confirmed', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'DataAppend.DateTimeApprove', Value__c = String.valueOf(Datetime.now().addHours(1))),
			new TouchCR_Settings__c(Name = 'DataAppend.ApproverEmail3', Value__c = 'test2@mail.com')
		};
		insert settingsList;

		Lead testObj2 = new Lead(
			FirstName = 'Jane',
			LastName = 'Doe',
			Email = 'janedoe@example.com',
			Append_Need_Append__c = true
		);
		insert testObj2;

		testObj2 = [SELECT Append_Need_Append__c, Email_Append_Run__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(true, testObj2.Append_Need_Append__c);

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		testObj2 = [SELECT Email_Checked__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(false, testObj2.Email_Checked__c);

		List<TouchCR_Settings__c> listTouchCRSettings = [SELECT Id, Name, Value__c FROM TouchCR_Settings__c WHERE Name =: 'DataAppend.Excess'];
		System.assertEquals(0, listTouchCRSettings.size());
	}

	//testing FullContact
	@isTest static void fc_test_needtoappendonnew() {
		// SETTINGS
		// new accounts processed
		// new leads NOT processed
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'FullContact.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'FullContact.Limit', Value__c = '10')
		};
		insert settingsList;

		//do not set response body
		Test.setMock(HttpCalloutMock.class, new FullContactApiMock());
		List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true AND DeveloperName = 'Customer_Account'];
		Account testObj1 = new Account(FirstName = 'John', LastName = 'Doe', PersonEmail = 'johndoe@example.com', RecordTypeId = rtList[0].Id);
		insert testObj1;
		testObj1 = [SELECT Append_Need_Append__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(true, testObj1.Append_Need_Append__c);

		Lead testObj2 = new Lead(FirstName = 'Jane', LastName = 'Doe', Email = 'janedoe@example.com');
		insert testObj2;

		testObj2 = [SELECT Append_Need_Append__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(false, testObj2.Append_Need_Append__c);

		// Test.setCreatedDate(testObj1.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS + 1)));
		// Test.setCreatedDate(testObj2.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS - 1)));

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		testObj1 = [SELECT Social_Append_Run_Date__c, Social_Append_Success__c FROM Account WHERE Id = :testObj1.Id];
		System.assertNotEquals(null, testObj1.Social_Append_Run_Date__c);
		System.assertEquals(true, testObj1.Social_Append_Success__c);

		testObj2 = [SELECT Social_Append_Run_Date__c, Social_Append_Success__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(null, testObj2.Social_Append_Run_Date__c);
		System.assertEquals(false, testObj2.Social_Append_Success__c);
	}

	@isTest static void fc_test_reappendondays() {
		// SETTINGS
		// new accounts NOT processed
		// new leads NOT processed
		// reappend on account IN range
		// reappend on lead OUT OF range
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.ReappendOnDays', Value__c = String.valueOf(REAPPEND_ON_DAYS)),
			new TouchCR_Settings__c(Name = 'FullContact.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'FullContact.Limit', Value__c = '10')
		};
		insert settingsList;

		//do not set response body
		Test.setMock(HttpCalloutMock.class, new FullContactApiMock());
		List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true AND DeveloperName = 'Customer_Account'];

		Account testObj1 = new Account(FirstName = 'John', LastName = 'Doe', PersonEmail = 'johndoe@example.com', RecordTypeId = rtList[0].Id, Append_Run_Date__c = DateTime.now().addDays(-(REAPPEND_ON_DAYS + 2)));
		insert testObj1;
		testObj1 = [SELECT Append_Need_Append__c, Social_Append_Run_Date__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(false, testObj1.Append_Need_Append__c);

		Lead testObj2 = new Lead(FirstName = 'Jane', LastName = 'Doe', Email = 'janedoe@example.com', Append_Run_Date__c = DateTime.now().addDays(-(REAPPEND_ON_DAYS - 2)));
		insert testObj2;
		testObj2 = [SELECT Append_Need_Append__c, Social_Append_Run_Date__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(false, testObj2.Append_Need_Append__c);

		// Test.setCreatedDate(testObj1.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS + 1)));
		// Test.setCreatedDate(testObj2.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS - 1)));

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		//LOGS
		List<Log__c> logs = [SELECT Event_Status__c, Event_Description__c, Event_Endpoint__c, Event_Type__c FROM Log__c];
		// 1 log, account 1
		System.assertEquals(1, logs.size());
		// ACCOUNT
		testObj1 = [SELECT Social_Append_Run_Date__c, Social_Append_Success__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(DateTime.now().date(), Datetime.valueOf(testObj1.Social_Append_Run_Date__c).date());
		System.assertEquals(true, testObj1.Social_Append_Success__c);
		//LEAD
		testObj2 = [SELECT Social_Append_Run_Date__c, Social_Append_Success__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(null, testObj2.Social_Append_Run_Date__c);
		System.assertEquals(false, testObj2.Social_Append_Success__c);
	}

	@isTest static void fc_test_reappendondays_null() {
		// SETTINGS
		// new accounts NOT processed
		// new leads NOT processed
		// reappend on account IN range
		// reappend on lead OUT OF range
		// REAPPENDONDAYS IS NOT SET, NO RECORDS WILL BE PROCESSED
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'FullContact.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'FullContact.Limit', Value__c = '10')
		};
		insert settingsList;

		//do not set response body
		Test.setMock(HttpCalloutMock.class, new FullContactApiMock());
		List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true AND DeveloperName = 'Customer_Account'];
		Account testObj1 = new Account(FirstName = 'John', LastName = 'Doe', PersonEmail = 'johndoe@example.com', RecordTypeId = rtList[0].Id, Social_Append_Run_Date__c = DateTime.now().addDays(-(REAPPEND_ON_DAYS + 1)));
		insert testObj1;
		testObj1 = [SELECT Append_Need_Append__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(false, testObj1.Append_Need_Append__c);

		Lead testObj2 = new Lead(
			FirstName = 'Jane',
			LastName = 'Doe',
			Email = 'janedoe@example.com',
			Social_Append_Run_Date__c = DateTime.now().addDays(-(REAPPEND_ON_DAYS - 1))
		);
		insert testObj2;
		testObj2 = [SELECT Append_Need_Append__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(false, testObj2.Append_Need_Append__c);

		// Test.setCreatedDate(testObj1.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS + 1)));
		// Test.setCreatedDate(testObj2.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS - 1)));

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		//LOGS
		List<Log__c> logs = [SELECT Event_Status__c, Event_Description__c, Event_Endpoint__c, Event_Type__c FROM Log__c];
		// 0
		System.assertEquals(0, logs.size());
		// ACCOUNT
		testObj1 = [SELECT Social_Append_Run_Date__c, Social_Append_Success__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(DateTime.now().addDays(-(REAPPEND_ON_DAYS + 1)).date(), Datetime.valueOf(testObj1.Social_Append_Run_Date__c).date());
		System.assertEquals(false, testObj1.Social_Append_Success__c);
		//LEAD
		testObj2 = [SELECT Social_Append_Run_Date__c, Social_Append_Success__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(DateTime.now().addDays(-(REAPPEND_ON_DAYS - 1)).date(), Datetime.valueOf(testObj2.Social_Append_Run_Date__c).date());
		System.assertEquals(false, testObj2.Social_Append_Success__c);
	}

	@isTest static void fc_test_ignoreolderthan() {
		// SETTINGS
		// new accounts NOT processed
		// new leads NOT processed
		// reappend on account FALSE
		// reappend on lead FALSE
		// ignore older that 10 DAYS
		// account created OLDER_THAN_DAYS - 1 days ago processed
		// lead created OLDER_THAN_DAYS + 1 days ago NOT processed
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.IgnoreOlderThan', Value__c = String.valueOf(Date.today().addDays(-OLDER_THAN_DAYS))),
			new TouchCR_Settings__c(Name = 'FullContact.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'FullContact.Limit', Value__c = '10')
		};
		insert settingsList;

		//do not set response body
		Test.setMock(HttpCalloutMock.class, new FullContactApiMock());
		List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true AND DeveloperName = 'Customer_Account'];
		Account testObj1 = new Account(FirstName = 'John', LastName = 'Doe', PersonEmail = 'johndoe@example.com', RecordTypeId = rtList[0].Id, Social_Append_Run_Date__c = null);
		insert testObj1;
		testObj1 = [SELECT Append_Need_Append__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(false, testObj1.Append_Need_Append__c);

		Lead testObj2 = new Lead(FirstName = 'Jane', LastName = 'Doe', Email = 'janedoe@example.com', Social_Append_Run_Date__c = null);
		insert testObj2;
		testObj2 = [SELECT Append_Need_Append__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(false, testObj2.Append_Need_Append__c);

		Test.setCreatedDate(testObj1.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS - 2))); // ok
		Test.setCreatedDate(testObj2.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS + 2)));

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		//LOGS
		List<Log__c> logs = [SELECT Event_Status__c, Event_Description__c, Event_Endpoint__c, Event_Type__c FROM Log__c];
		// 1 log, account 1
		System.assertEquals(1, logs.size());
		// ACCOUNT
		testObj1 = [SELECT Social_Append_Run_Date__c, Social_Append_Success__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(DateTime.now().date(), Datetime.valueOf(testObj1.Social_Append_Run_Date__c).date());
		System.assertEquals(true, testObj1.Social_Append_Success__c);
		//LEAD
		testObj2 = [SELECT Social_Append_Run_Date__c, Social_Append_Success__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(null, testObj2.Social_Append_Run_Date__c);
		System.assertEquals(false, testObj2.Social_Append_Success__c);
	}

	@isTest static void fc_test_needtoappendonnew_ignoreamazon() {
		// SETTINGS
		// new accounts processed
		// new leads NOT processed
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'FullContact.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'FullContact.Limit', Value__c = '10')
		};
		insert settingsList;

		//do not set response body
		Test.setMock(HttpCalloutMock.class, new FullContactApiMock(''));
		List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true AND DeveloperName = 'Customer_Account'];
		Account testObj1 = new Account(FirstName = 'John', LastName = 'Doe', RecordTypeId = rtList[0].Id);
		insert testObj1;
		testObj1 = [SELECT Append_Need_Append__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(true, testObj1.Append_Need_Append__c);

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		testObj1 = [SELECT Social_Append_Run_Date__c, Social_Append_Success__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(null, testObj1.Social_Append_Run_Date__c);
		System.assertEquals(false, testObj1.Social_Append_Success__c);
		List<Log__c> logs = [SELECT Id FROM Log__c WHERE Account__c = :testObj1.Id];
		// no log records were created, no api call
		System.assertEquals(0, logs.size());
	}

	@isTest static void fc_test_needtoappendonnewlead() {
		// SETTINGS
		// new accounts NOT processed
		// new leads processed
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'FullContact.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'FullContact.Limit', Value__c = '10')
		};
		insert settingsList;

		//do not set response body
		Test.setMock(HttpCalloutMock.class, new FullContactApiMock());
		List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true AND DeveloperName = 'Customer_Account'];
		Account testObj1 = new Account(FirstName = 'John', LastName = 'Doe', PersonEmail = 'johndoe@example.com', RecordTypeId = rtList[0].Id);
		insert testObj1;
		testObj1 = [SELECT Append_Need_Append__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(false, testObj1.Append_Need_Append__c);

		Lead testObj2 = new Lead(
			FirstName = 'Jane',
			LastName = 'Doe',
			Email = 'janedoe@example.com');
		insert testObj2;

		testObj2 = [SELECT Append_Need_Append__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(true, testObj2.Append_Need_Append__c);

		// Test.setCreatedDate(testObj1.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS + 1)));
		// Test.setCreatedDate(testObj2.Id, DateTime.now().addDays(-(OLDER_THAN_DAYS - 1)));

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		testObj1 = [SELECT Social_Append_Run_Date__c, Social_Append_Success__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(null, testObj1.Social_Append_Run_Date__c);
		System.assertEquals(false, testObj1.Social_Append_Success__c);

		testObj2 = [SELECT Social_Append_Run_Date__c, Social_Append_Success__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertNotEquals(null, testObj2.Social_Append_Run_Date__c);
		System.assertEquals(true, testObj2.Social_Append_Success__c);
	}

	@isTest static void fc_test_settingsnotapprove() {
		// SETTINGS
		// new lead processed
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'FullContact.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'FullContact.Limit', Value__c = '0')
		};
		insert settingsList;
		List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true AND DeveloperName = 'Customer_Account'];
		Account testObj1 = new Account(FirstName = 'John', LastName = 'Doe', PersonEmail = 'johndoe@example.com', RecordTypeId = rtList[0].Id, Append_Need_Append__c = true);
		insert testObj1;

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();


		testObj1 = [SELECT Social_Append_Run_Date__c, Social_Append_Success__c FROM Account WHERE Id = :testObj1.Id];
		System.assertEquals(null, testObj1.Social_Append_Run_Date__c);
		System.assertEquals(false, testObj1.Social_Append_Success__c);

		List<TouchCR_Settings__c> listTouchCRSettings = [SELECT Id, Name, Value__c FROM TouchCR_Settings__c WHERE Name =: 'FullContact.Excess'];
		System.assertEquals('1', listTouchCRSettings[0].Value__c);
	}

	@isTest static void fc_test_settingsapprove() {
		// SETTINGS
		// new lead processed
		List<TouchCR_Settings__c> settingsList = new List<TouchCR_Settings__c> {
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'false'),
			new TouchCR_Settings__c(Name = 'FullContact.APIKey', Value__c = 'apikey'),
			new TouchCR_Settings__c(Name = 'FullContact.Limit', Value__c = '0'),
			new TouchCR_Settings__c(Name = 'FullContact.Confirmed', Value__c = 'true'),
			new TouchCR_Settings__c(Name = 'FullContact.DateTimeApprove', Value__c = String.valueOf(Datetime.now().addHours(1)))
		};
		insert settingsList;

		Lead testObj2 = new Lead(FirstName = 'Jane', LastName = 'Doe', Email = 'janedoe@example.com', Append_Need_Append__c = true);
		insert testObj2;

		testObj2 = [SELECT Append_Need_Append__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(true, testObj2.Append_Need_Append__c);

		Test.startTest();
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		Test.stopTest();

		testObj2 = [SELECT Social_Append_Success__c FROM Lead WHERE Id = :testObj2.Id];
		System.assertEquals(false, testObj2.Social_Append_Success__c);

		List<TouchCR_Settings__c> listTouchCRSettings = [SELECT Id, Name, Value__c FROM TouchCR_Settings__c WHERE Name =: 'FullContact.Excess'];
		System.assertEquals(0, listTouchCRSettings.size());

	}

}