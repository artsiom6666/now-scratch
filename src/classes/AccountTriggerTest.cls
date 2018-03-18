@isTest
private class AccountTriggerTest {

	public static final Integer AGED_LEAD = 30; 

	@isTest static void test_reappendonconvert_false_aged_true() {
		//set settings
		insert new TouchCR_Settings__c(Name = 'Global.LeadConvert', Value__c = 'false');
		insert new TouchCR_Settings__c(Name = 'Global.LeadAccountAged', Value__c = String.valueOf(AGED_LEAD));

		Integer numRepeats = 2;
		List<Lead> testObjList = new List<Lead>();

		for (Integer idx = 1; idx <= numRepeats; idx++) {
			Lead testObj = new Lead(
				FirstName = 'John' + idx,
				LastName = 'Doe' + idx,
				Email = 'john.doe' + idx + '@domain.com'
			);
			testObjList.add(testObj);
		}
		insert testObjList;
		//set ctl in and out of range
		//1st out of range
		Test.setCreatedDate(testObjList[0].Id, DateTime.now().addDays(-(AGED_LEAD + 5)));
		//2nd in range
		Test.setCreatedDate(testObjList[1].Id, DateTime.now().addDays(-(AGED_LEAD - 5)));

		Test.startTest();
			LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
			List<Database.LeadConvert> lcList = new List<Database.LeadConvert>();
			for (Lead testObj : testObjList) {
				Database.LeadConvert lc = new Database.LeadConvert();
				lc.setLeadId(testObj.Id);
				lc.setConvertedStatus(convertStatus.MasterLabel);
				lc.setDoNotCreateOpportunity(true);
				lcList.add(lc);
			}

			List<Database.LeadConvertResult> lcrList = Database.convertLead(lcList);
			for (Database.LeadConvertResult lcr : lcrList) {
				System.assert(lcr.isSuccess());
			}
		Test.stopTest();

		List<Account> objList = [SELECT Append_Need_Append__c, Lead_CTL__c FROM Account ORDER BY Lead_CTL__c ASC];
		//if Global.LeadConvert set to false
		//converted accs with Lead CTL > LeadAccountAged must be processed
		System.assert(objList[0].Lead_CTL__c < AGED_LEAD);
		System.assertEquals(false, objList[0].Append_Need_Append__c);

		System.assert(objList[1].Lead_CTL__c > AGED_LEAD);
		System.assertEquals(true, objList[1].Append_Need_Append__c);
	}

	@isTest static void test_reappendonconvert_accountregulardml() {
		//set settings
		insert new TouchCR_Settings__c(Name = 'Global.LeadConvert', Value__c = 'true');
		insert new TouchCR_Settings__c(Name = 'Global.LeadAccountAged', Value__c = String.valueOf(AGED_LEAD));

		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];

		Integer numRepeats = 2;
		List<Account> testObjList = new List<Account>();

		for (Integer idx = 1; idx <= numRepeats; idx++) {
			Account testObj = new Account(
				FirstName = 'John' + idx,
				LastName = 'Doe' + idx,
				RecordTypeId = customerRecordType.Id,
				PersonEmail = 'john.doe' + idx + '@domain.com'
			);
			testObjList.add(testObj);
		}
		insert testObjList;
		//set ctl in and out of range
		//1st out of range
		Test.setCreatedDate(testObjList[0].Id, DateTime.now().addDays(-(AGED_LEAD + 5)));
		//2nd in range
		Test.setCreatedDate(testObjList[1].Id, DateTime.now().addDays(-(AGED_LEAD - 5)));

		Test.startTest();
			for (Account testObj : testObjList) {
				testObj.FirstName = testObj.FirstName + 'updated Name';
			}
			update testObjList;
		Test.stopTest();

		List<Account> objList = [SELECT Append_Need_Append__c, Lead_CTL__c FROM Account ORDER BY Lead_CTL__c ASC];
		for (Account testObj : objList) {
			System.assertEquals(false, testObj.Append_Need_Append__c);
		}
	}

	@isTest static void test_appendneedappend_true() {
		insert new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'true');
		List<RecordType> personRtList = [SELECT Name, SobjectType, IsPersonType
			FROM RecordType
			WHERE SobjectType = 'Account'
	 		AND DeveloperName = 'Customer_Account'
			AND IsPersonType = true
			AND IsActive = true
		];
		
		Id personRtId;
		if (!personRtList.isEmpty()) {
			personRtId = personRtList[0].Id;
		}

		Integer numRepeats = 20;
		List<Account> testObjList = new List<Account>();

		for (Integer idx = 1; idx <= numRepeats; idx++) {
			Account testObj = new Account(
				FirstName = 'John' + idx,
				LastName = 'Doe' + idx,
				RecordTypeId = personRtId,
				PersonEmail = 'john.doe' + idx + '@domain.com'
			);
			testObjList.add(testObj);
		}
		Test.startTest();
			insert testObjList;
		Test.stopTest();

		testObjList = [SELECT Append_Need_Append__c FROM Account];

		for (Account testObj : testObjList) {
			System.assertEquals(true, testObj.Append_Need_Append__c);
		}
	}

	@isTest static void test_appendneedappend_false() {
		//insert new TouchCR_Settings__c(Name = 'Global.AppendOnNewAccount', Value__c = 'true');
		List<RecordType> personRtList = [SELECT Name, SobjectType, IsPersonType
			FROM RecordType
			WHERE SobjectType = 'Account'
			AND DeveloperName = 'Customer_Account'
			AND IsPersonType = true
			AND IsActive = true
		];
		Id personRtId;
		if (!personRtList.isEmpty()) {
			personRtId = personRtList[0].Id;
		}

		Integer numRepeats = 20;
		List<Account> testObjList = new List<Account>();

		for (Integer idx = 1; idx <= numRepeats; idx++) {
			Account testObj = new Account(
				FirstName = 'John' + idx,
				LastName = 'Doe' + idx,
				RecordTypeId = personRtId,
				PersonEmail = 'john.doe' + idx + '@domain.com'
			);
			testObjList.add(testObj);
		}
		Test.startTest();
			insert testObjList;
		Test.stopTest();

		testObjList = [SELECT Append_Need_Append__c FROM Account];

		for (Account testObj : testObjList) {
			System.assertEquals(false, testObj.Append_Need_Append__c);
		}
	}

	@isTest static void test_dtStart_is_not_null() {        
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account newAccount = new Account(
			RecordTypeId = customerRecordType.Id,
			LastName = 'lastOrderDate'
		);
		insert newAccount;

		DateTime dt = DateTime.now().addDays(-1);       
		newAccount.Last_order_date__c = dt;     

		Test.startTest();
			update newAccount;
		Test.stopTest();

		Account updatedAccount = [SELECT Id, Days_After_Last_Order__c FROM Account WHERE Id = :newAccount.Id];
		System.assertEquals(1, updatedAccount.Days_After_Last_Order__c);
	}   

	@isTest static void test_leadConverting_with_leadConvertFlag() {
		//If Lead.Append_Run__c = true, Global.LeadConvert = true then
		//converted Account.Append_Need_Append__c = true
		//If Lead.Append_Run__c = false, Global.LeadConvert = true then
		//converted Account.Append_Need_Append__c = false
		//If Lead.Append_Run__c = true, Global.LeadConvert = false then
		//converted Account.Append_Need_Append__c = false
		//If Lead.Append_Run__c = false, Global.LeadConvert = true then
		//converted Account.Append_Need_Append__c = false
		List<Lead> newLeads = new List<Lead>();     

		Lead newLead = new Lead(
			LastName = 'Lead01',
			Append_Run__c = true);
		newLeads.add(newLead);      

		Lead newLead2 = new Lead(
			LastName = 'Lead02',
			Append_Run__c = false);
		newLeads.add(newLead2);

		Lead newLead3 = new Lead(
			LastName = 'Lead03',
			Append_Run__c = true);
		newLeads.add(newLead3);

		Lead newLead4 = new Lead(
			LastName = 'Lead04',
			Append_Run__c = false);
		newLeads.add(newLead4);     

		TouchCR_Settings__c leadConvert = new TouchCR_Settings__c(
			Name = 'Global.LeadConvert',
			Value__c = 'true');       
		
		insert newLeads;
		insert leadConvert;

		Test.startTest();
			LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
			Database.LeadConvert lc = new Database.LeadConvert();
				lc.setLeadId(newLeads[0].Id);
				lc.setConvertedStatus(convertStatus.MasterLabel);
				lc.setDoNotCreateOpportunity(true);
			Database.LeadConvertResult lcr = Database.convertLead(lc);
				system.assert(lcr.isSuccess());

			Database.LeadConvert lc2 = new Database.LeadConvert();
				lc2.setLeadId(newLeads[1].Id);
				lc2.setConvertedStatus(convertStatus.MasterLabel);
				lc2.setDoNotCreateOpportunity(true);
			Database.LeadConvertResult lcr2 = Database.convertLead(lc2);
				system.assert(lcr2.isSuccess());
		
		List<Lead> convertedLeads = [SELECT Id, Name, convertedAccountId FROM Lead ORDER BY Name ASC];
		List<Account> newAccounts = [SELECT Id, Name, Append_Need_Append__c FROM Account ORDER BY Name ASC];
		
		System.assertEquals(convertedLeads[0].convertedAccountId, newAccounts[0].Id);
		System.assertEquals(true, newAccounts[0].Append_Need_Append__c);
		
		System.assertEquals(convertedLeads[1].convertedAccountId, newAccounts[1].Id);
		System.assertEquals(false, newAccounts[1].Append_Need_Append__c);
		
		leadConvert.Value__c = 'false';
		update leadConvert;
		
			Database.LeadConvert lc3 = new Database.LeadConvert();
				lc3.setLeadId(newLeads[2].Id);
				lc3.setConvertedStatus(convertStatus.MasterLabel);
				lc3.setDoNotCreateOpportunity(true);
			Database.LeadConvertResult lcr3 = Database.convertLead(lc3);
				system.assert(lcr3.isSuccess());

			Database.LeadConvert lc4 = new Database.LeadConvert();
				lc4.setLeadId(newLeads[3].Id);
				lc4.setConvertedStatus(convertStatus.MasterLabel);
				lc4.setDoNotCreateOpportunity(true);
			Database.LeadConvertResult lcr4 = Database.convertLead(lc4);
				system.assert(lcr4.isSuccess());
		
		convertedLeads = [SELECT Id, Name, convertedAccountId FROM Lead ORDER BY Name ASC];
		newAccounts = [SELECT Id, Name, Append_Need_Append__c FROM Account ORDER BY Name ASC];
		
		System.assertEquals(convertedLeads[2].convertedAccountId, newAccounts[2].Id);
		System.assertEquals(false, newAccounts[2].Append_Need_Append__c);
		
		System.assertEquals(convertedLeads[3].convertedAccountId, newAccounts[3].Id);
		System.assertEquals(false, newAccounts[3].Append_Need_Append__c);           
		Test.stopTest();            
	}

	@isTest static void test_leadConverting_with_apendOnNewAccountFlag() {
		//If Lead.Append_Run__c = false, Global.AppendOnNewAccount = true then
		//converted Account.Append_Need_Append__c = true
		//If Lead.Append_Run__c = true, Global.AppendOnNewAccount = true then
		//converted Account.Append_Need_Append__c = false
		//If Lead.Append_Run__c = false, Global.AppendOnNewAccount = false then
		//converted Account.Append_Need_Append__c = true
		//If Lead.Append_Run__c = true, Global.AppendOnNewAccount = false then
		//converted Account.Append_Need_Append__c = false
		
		List<Lead> newLeads = new List<Lead>();     

		Lead newLead = new Lead(
			LastName = 'Lead01',
			Append_Run__c = false);
		newLeads.add(newLead);      

		Lead newLead2 = new Lead(
			LastName = 'Lead02',
			Append_Run__c = true);
		newLeads.add(newLead2);

		Lead newLead3 = new Lead(
			LastName = 'Lead03',
			Append_Run__c = false);
		newLeads.add(newLead3);

		Lead newLead4 = new Lead(
			LastName = 'Lead04',
			Append_Run__c = true);
		newLeads.add(newLead4);     

		TouchCR_Settings__c appendOnNewAccount = new TouchCR_Settings__c(
			Name = 'Global.AppendOnNewAccount',
			Value__c = 'true');       
		
		insert newLeads;
		insert appendOnNewAccount;

		Test.startTest();
			LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
			Database.LeadConvert lc = new Database.LeadConvert();
				lc.setLeadId(newLeads[0].Id);
				lc.setConvertedStatus(convertStatus.MasterLabel);
				lc.setDoNotCreateOpportunity(true);
			Database.LeadConvertResult lcr = Database.convertLead(lc);
				system.assert(lcr.isSuccess());

			Database.LeadConvert lc2 = new Database.LeadConvert();
				lc2.setLeadId(newLeads[1].Id);
				lc2.setConvertedStatus(convertStatus.MasterLabel);
				lc2.setDoNotCreateOpportunity(true);
			Database.LeadConvertResult lcr2 = Database.convertLead(lc2);
				system.assert(lcr2.isSuccess());
		
		List<Lead> convertedLeads = [SELECT Id, Name, convertedAccountId FROM Lead ORDER BY Name ASC];
		List<Account> newAccounts = [SELECT Id, Name, Append_Need_Append__c FROM Account ORDER BY Name ASC];
		
		System.assertEquals(convertedLeads[0].convertedAccountId, newAccounts[0].Id);
		System.assertEquals(true, newAccounts[0].Append_Need_Append__c);
		
		System.assertEquals(convertedLeads[1].convertedAccountId, newAccounts[1].Id);
		System.assertEquals(false, newAccounts[1].Append_Need_Append__c);
		
		appendOnNewAccount.Value__c = 'false';
		update appendOnNewAccount;
		
			Database.LeadConvert lc3 = new Database.LeadConvert();
				lc3.setLeadId(newLeads[2].Id);
				lc3.setConvertedStatus(convertStatus.MasterLabel);
				lc3.setDoNotCreateOpportunity(true);
			Database.LeadConvertResult lcr3 = Database.convertLead(lc3);
				system.assert(lcr3.isSuccess());

			Database.LeadConvert lc4 = new Database.LeadConvert();
				lc4.setLeadId(newLeads[3].Id);
				lc4.setConvertedStatus(convertStatus.MasterLabel);
				lc4.setDoNotCreateOpportunity(true);
			Database.LeadConvertResult lcr4 = Database.convertLead(lc4);
				system.assert(lcr4.isSuccess());
		
		convertedLeads = [SELECT Id, Name, convertedAccountId FROM Lead ORDER BY Name ASC];
		newAccounts = [SELECT Id, Name, Append_Need_Append__c FROM Account ORDER BY Name ASC];
		
		System.assertEquals(convertedLeads[2].convertedAccountId, newAccounts[2].Id);
		System.assertEquals(false, newAccounts[2].Append_Need_Append__c);
		
		System.assertEquals(convertedLeads[3].convertedAccountId, newAccounts[3].Id);
		System.assertEquals(false, newAccounts[3].Append_Need_Append__c);           
		Test.stopTest();
	}

	@isTest static void test_calculate_initial_value() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account newAccount = new Account(
			RecordTypeId = customerRecordType.Id,
			LastName = 'new Account'
		);
		insert newAccount;

		Datetime yesterday = Datetime.now().addDays(-1);

		Order__c order = new Order__c (
			Account__c = newAccount.Id, Subtotal__c = 100, Date__c = yesterday
		);
		insert order;

		Order__c order1 = new Order__c (
			Account__c = newAccount.Id, Subtotal__c = 50, Date__c = yesterday
		);
		insert order1;

		Order__c order2 = new Order__c (
			Account__c = newAccount.Id, Subtotal__c = 30, Date__c = Datetime.now()
		);
		insert order2;


		Order_Transaction__c trans = new Order_Transaction__c(
			Order__c = order.Id, Type__c = 'Charge', Response_Status__c = 'Approved', 
			Payment_Date__c = Datetime.now(), Amount__c = 100
		);
		insert trans;

		Order_Transaction__c trans1 = new Order_Transaction__c(
			Order__c = order1.Id, Type__c = 'Charge', Response_Status__c = 'Approved',
			Payment_Date__c = Datetime.now(), Amount__c = 50
		);
		insert trans1;

		Order_Transaction__c trans2 = new Order_Transaction__c(
			Order__c = order2.Id, Type__c = 'Charge', Response_Status__c = 'Approved',
			Payment_Date__c = Datetime.now(), Amount__c = 30
		);
		insert trans2;

		Account updatedAccount = [SELECT Id, Initial_Customer_Value__c FROM Account WHERE Id = :newAccount.Id];
		System.assertEquals(150, updatedAccount.Initial_Customer_Value__c);
	}

	@isTest static void test_deleteFcAccount_socialProfiles() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account accA = new Account(RecordTypeId = customerRecordType.Id, LastName = 'AAccount', FirstName = 'First', PersonEmail = 'testA@gmail.com', Phone = '1234567890');
		Account accB = new Account(RecordTypeId = customerRecordType.Id, LastName = 'BAccount', FirstName = 'First', PersonEmail = 'testB@gmail.com', Phone = '1234567890');
		insert new List<Account> {accA, accB};

		Social_Profile__c socialA = new Social_Profile__c (Account__c = accA.Id);
		Social_Profile__c socialB = new Social_Profile__c (Account__c = accB.Id);
		insert new List<Social_Profile__c> {socialA, socialB};

		delete accA;
		System.assertEquals(1, [SELECT COUNT() FROM Social_Profile__c]);

		delete accB;
		System.assertEquals(0, [SELECT COUNT() FROM Social_Profile__c]);
	}

}