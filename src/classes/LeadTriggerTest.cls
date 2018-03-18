@isTest
private class LeadTriggerTest {

	@isTest static void test_leadconvert_moveVisitlookup() {

		Lead aLead1 = new Lead(
			FirstName = 'Test1 FName',
			LastName = 'Test1 LName',
			Email = 'test@yahoo.com'
		);
		insert aLead1;

		Recognized_Visits__c recVisit1 = new Recognized_Visits__c(
			Name = 'John_1',
			Date_and_Time__c = System.now(),
			User_Email_Address__c = 'test@yahoo.com'
		);
		insert recVisit1;

		Test.startTest();
			List<Recognized_Visits__c> testObj1 = [
				SELECT Lead__c, Customer_Contact__c
				FROM Recognized_Visits__c
			];
			//assert visit lead lookup filled
			System.assertEquals(aLead1.Id, testObj1[0].Lead__c);
			//assert customer lookup empty
			System.assertEquals(null, testObj1[0].Customer_Contact__c);

			List<Recognized_Visit_Device__c> testObj2 = [
				SELECT Lead__c, Customer_Contact__c
				FROM Recognized_Visit_Device__c
			];

			//assert device lead lookup filled
			System.assertEquals(aLead1.Id, testObj2[0].Lead__c);
			//assert customer lookup empty
			System.assertEquals(null, testObj2[0].Customer_Contact__c);

			LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];

			Database.LeadConvert lc = new database.LeadConvert();
				lc.setLeadId(aLead1.id);
				lc.setConvertedStatus(convertStatus.MasterLabel);
				lc.setDoNotCreateOpportunity(true);
			Database.LeadConvertResult lcr = Database.convertLead(lc);
			System.assert(lcr.isSuccess());

			testObj1 = [
				SELECT Lead__c, Customer_Contact__c
				FROM Recognized_Visits__c
			];
			//assert lead lookup deleted
			System.assertEquals(null, testObj1[0].Lead__c);
			//assert new customer lookup filled
			System.assertNotEquals(lc.getAccountId(), testObj1[0].Customer_Contact__c);

			testObj2 = [
				SELECT Lead__c, Customer_Contact__c
				FROM Recognized_Visit_Device__c
			];
			//assert lead lookup deleted
			System.assertEquals(null, testObj2[0].Lead__c);
			//assert new customer lookup filled
			System.assertNotEquals(lc.getAccountId(), testObj2[0].Customer_Contact__c);
		Test.stopTest();
	}

	@isTest static void test_leadconvert_bulk_movelookup() {
		List<Lead> leads = new List<Lead> {
			new Lead(
				FirstName = 'Test1 FName',
				LastName = 'Test1 LName',
				Email = 'test@yahoo.com'
			),
			new Lead(
				FirstName = 'Test2 FName',
				LastName = 'Test2 LName',
				Email = 'test@example.com'
			)
		};
		insert leads;

		List<Recognized_Visits__c> recognizedVisits = new List<Recognized_Visits__c>{
			new Recognized_Visits__c(
				Name = 'John_1',
				Date_and_Time__c = System.now(),
				User_Email_Address__c = 'test@yahoo.com'
			),
			new Recognized_Visits__c(
				Name = 'John_2',
				Date_and_Time__c = System.now(),
				User_Email_Address__c = 'test@example.com'
			)
		};
		insert recognizedVisits;

		Test.startTest();
			//visits
			List<Recognized_Visits__c> testObj1 = [
				SELECT Lead__c, Customer_Contact__c
				FROM Recognized_Visits__c
			];
			//assert lead lookup filled
			System.assertEquals(leads[0].Id, testObj1[0].Lead__c);
			System.assertEquals(leads[1].Id, testObj1[1].Lead__c);
			//assert customer lookup empty
			System.assertEquals(null, testObj1[0].Customer_Contact__c);
			System.assertEquals(null, testObj1[1].Customer_Contact__c);

			//devices
			List<Recognized_Visit_Device__c> testObj2 = [
				SELECT Lead__c, Customer_Contact__c
				FROM Recognized_Visit_Device__c
			];
			//assert lead lookup filled
			System.assertEquals(leads[0].Id, testObj2[0].Lead__c);
			System.assertEquals(leads[1].Id, testObj2[1].Lead__c);
			//assert customer lookup empty
			System.assertEquals(null, testObj2[0].Customer_Contact__c);
			System.assertEquals(null, testObj2[1].Customer_Contact__c);

			LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];

			Database.LeadConvert lc1 = new database.LeadConvert();
				lc1.setLeadId(leads[0].Id);
				lc1.setConvertedStatus(convertStatus.MasterLabel);
				lc1.setDoNotCreateOpportunity(true);
			Database.LeadConvertResult lcr1 = Database.convertLead(lc1);
			System.assert(lcr1.isSuccess());

			Database.LeadConvert lc2 = new database.LeadConvert();
				lc2.setLeadId(leads[1].Id);
				lc2.setConvertedStatus(convertStatus.MasterLabel);
				lc2.setDoNotCreateOpportunity(true);
			Database.LeadConvertResult lcr2 = Database.convertLead(lc2);
			System.assert(lcr2.isSuccess());

			//visit
			testObj1 = [
				SELECT Lead__c, Customer_Contact__c
				FROM Recognized_Visits__c
			];
			//assert lead lookup deleted
			System.assertEquals(null, testObj1[0].Lead__c);
			System.assertEquals(null, testObj1[1].Lead__c);
			//assert new customer lookup filled
			System.assertNotEquals(lc1.getAccountId(), testObj1[0].Customer_Contact__c);
			System.assertNotEquals(lc2.getAccountId(), testObj1[1].Customer_Contact__c);

			//device
			testObj2 = [
				SELECT Lead__c, Customer_Contact__c
				FROM Recognized_Visit_Device__c
			];
			//assert lead lookup deleted
			System.assertEquals(null, testObj2[0].Lead__c);
			System.assertEquals(null, testObj2[1].Lead__c);
			//assert new customer lookup filled
			System.assertNotEquals(lc1.getAccountId(), testObj2[0].Customer_Contact__c);
			System.assertNotEquals(lc2.getAccountId(), testObj2[1].Customer_Contact__c);
		Test.stopTest();
	}

	@isTest static void test_leadconvert_timelag() {
		Lead aLead1 = new Lead(
			FirstName = 'Test1 FName',
			LastName = 'Test1 LName',
			Email = 'test@yahoo.com'
		);
		insert aLead1;

		aLead1.Street = 'some str 111';
		update aLead1;

		Test.startTest();
			LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];

			Database.LeadConvert lc = new database.LeadConvert();
				lc.setLeadId(aLead1.id);
				lc.setConvertedStatus(convertStatus.MasterLabel);
				lc.setDoNotCreateOpportunity(true);
			Database.LeadConvertResult lcr = Database.convertLead(lc);
			System.assert(lcr.isSuccess());
		Test.stopTest();

		List<Account> convertedAccounts = [
			SELECT Id, Lead_CTL__c
			FROM Account
		];
		List<Lead> convertedLeads = [
			SELECT Id, CreatedDate, ConvertedDate
			FROM Lead
		];
		Integer conversionTimeLag = convertedLeads[0].CreatedDate.date().daysBetween(convertedLeads[0].ConvertedDate);
		System.assertEquals(conversionTimeLag, convertedAccounts[0].Lead_CTL__c);
	}

	@isTest static void test_cpa_byconvertinglead() {
		//CAMPAIGNS
		Campaign testCamp1 = new Campaign(
			Landing_Page__c = 'campaign_1_',
			Name = 'campaign_1_', Campaign__c = 'campaign_1_', //UTM_Campaign__c
			Ad_Platform__c = 'campaign_1_', //utm_source
			Buying_Type__c = 'campaign_1_', //utm_medium
			Ad_Type__c = 'campaign_1_', Content__c = 'campaign_1_', //UTM_Content__c
			Term__c = 'campaign_1_', //Term__c
			Total_Orders__c = 1,
			Total_Orders_Value__c = 1,
			Total_Customers_Value__c = 1,
			Campaign_Level__c = 0,
			Lead_CTL_Sum__c = 10,
			ActualCost = 100
		);
		insert testCamp1;

		Campaign_Cost__c testCC1 = new Campaign_Cost__c(
			Campaign__c = testCamp1.Id,
			Cost__c = 100
		);
		insert testCC1;

		//CUSTOMERS
		List<RecordType> paRt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer_Account' LIMIT 1];
		Account testAcc1 = new Account(
			FirstName = 'jane1',
			LastName = 'doe1',
			RecordTypeId = paRt[0].Id,
			utm_source__c = 'test1',
			utm_medium__c = 'test1',
			utm_campaign__c = 'test1test1',
			utm_content__c = 'test1',
			utm_term__c = 'test1test1'
		);
		insert testAcc1;

		testAcc1 = [SELECT Id, Total_CPA__c, PersonContactId FROM Account WHERE Id = :testAcc1.Id LIMIT 1];

		//LEADS
		Lead testLead1 = new Lead(
			FirstName = 'john1',
			LastName = 'doe1'
		);
		insert testLead1;

		//MEMBERS
		//Camp#1 + Customer#1 + Lead#1
		List<CampaignMember> campaignMembers = new List<CampaignMember>{
			new CampaignMember(
				CampaignId = testCamp1.Id,
				ContactId = testAcc1.PersonContactId
			),
			new CampaignMember(
				CampaignId = testCamp1.Id,
				LeadId = testLead1.Id
			)
		};
		insert campaignMembers;

		List<Campaign> testC1 = [
			SELECT Id, ActualCost, Total_CPA__c, NumberOfContacts, NumberOfLeads
			FROM Campaign
			WHERE Id =:testCamp1.Id
		];

		System.assertEquals(100, testC1[0].Total_CPA__c);
		System.assertEquals(1, testC1[0].NumberOfContacts);
		System.assertEquals(1, testC1[0].NumberOfLeads);

		Test.startTest();
			LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
			Database.LeadConvert lc = new database.LeadConvert();
				lc.setLeadId(testLead1.id);
				lc.setConvertedStatus(convertStatus.MasterLabel);
				lc.setDoNotCreateOpportunity(true);
			Database.LeadConvertResult lcr = Database.convertLead(lc);
			System.assert(lcr.isSuccess());
		Test.stopTest();

		testC1 = [
			SELECT Id, ActualCost, Total_CPA__c,
				NumberOfContacts, NumberOfLeads, NumberOfConvertedLeads
			FROM Campaign
			WHERE Id =:testCamp1.Id
		];

		System.assertEquals(50, testC1[0].Total_CPA__c);
		System.assertEquals(2, testC1[0].NumberOfContacts);
		System.assertEquals(1, testC1[0].NumberOfConvertedLeads);
		System.assertEquals(1, testC1[0].NumberOfLeads);

		List<Account> testA1 = [SELECT Id, Total_CPA__c FROM Account WHERE Id = :lcr.getAccountId()];
		System.assertEquals(50, testA1[0].Total_CPA__c);
	}

	@isTest static void test_appendneedappend_true() {
		insert new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'true');
		Integer numRepeats = 20;
		List<Lead> testObjList = new List<Lead>();

		for (Integer idx = 1; idx <= numRepeats; idx++) {
			Lead testObj = new Lead(
				FirstName = 'John' + idx,
				LastName = 'Doe' + idx,
				Email = 'john.doe' + idx + '@domain.com'
			);
			testObjList.add(testObj);
		}

		Test.startTest();
			insert testObjList;
		Test.stopTest();

		testObjList = [SELECT Append_Need_Append__c FROM Lead];

		for (Lead testObj : testObjList) {
			System.assertEquals(true, testObj.Append_Need_Append__c);
		}
	}

	@isTest static void test_appendneedappend_false() {
		//insert new TouchCR_Settings__c(Name = 'Global.AppendOnNewLead', Value__c = 'true');
		Integer numRepeats = 20;
		List<Lead> testObjList = new List<Lead>();

		for (Integer idx = 1; idx <= numRepeats; idx++) {
			Lead testObj = new Lead(
				FirstName = 'John' + idx,
				LastName = 'Doe' + idx,
				Email = 'john.doe' + idx + '@domain.com'
			);
			testObjList.add(testObj);
		}

		Test.startTest();
			insert testObjList;
		Test.stopTest();

		testObjList = [SELECT Append_Need_Append__c FROM Lead];

		for (Lead testObj : testObjList) {
			System.assertEquals(false, testObj.Append_Need_Append__c);
		}
	}

	@isTest static void test_optinduplicate_allscenarios_existing_account() {
		Integer numRepeats = 20;
		Boolean EmailOptOut = true;
		//two loops below:
		//0, 2, 4 ...(even) - old Account's EmailOptOut = true without utm; new Lead's EmailOptOut = true without utm
		//1, 3, 5 ...(odd) old Account's EmailOptOut = false without utm, new Lead's EmailOptOut = false with utm1

		//create bulk of old accounts
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		List<Account> oldAccounts = new List<Account>();
		for (Integer i = 0; i < numRepeats; i++) {
			Account oldAccount = new Account(
				RecordTypeId = customerRecordType.Id,
				LastName = 'oldAccount' + i,
				PersonEmail = 'oldAccount' + i + '@domain.com'
			);

			if (math.mod(i, 2) == 0) {
				oldAccount.PersonHasOptedOutOfEmail = true;
			} else {
				oldAccount.PersonHasOptedOutOfEmail = false;
			}
			oldAccounts.add(oldAccount);
		}
		insert oldAccounts;

		//create bulk of new leads
		List<Lead> newLeads = new List<Lead>();

		for (Integer i = 0; i < numRepeats; i++) {
			Lead newLead = new Lead(
				LastName = 'newLead' + i,
				Status = 'Open',
				Email = 'oldAccount' + i + '@domain.com'
			);

			if (math.mod(i, 2) == 0) {
				newLead.HasOptedOutOfEmail = true;
			} else {
				newLead.HasOptedOutOfEmail = false;
				newLead.utm_campaign__c = 'campaign' + i;
				newLead.utm_content__c = 'content' + i;
				newLead.utm_medium__c = 'medium' + i;
				newLead.utm_source__c = 'source' + i;
				newLead.utm_term__c = 'term'+ i;
			}
			newLeads.add(newLead);
		}
		insert newLeads;

		List<Account> testOldAccounts = [SELECT PersonHasOptedOutOfEmail, utm_campaign__c FROM Account];
		List<Lead> testNewLeads = [SELECT LastName FROM Lead];

		for (integer i = 0; i < numRepeats; i++) {
			if (math.mod(i, 2) == 0) {
				System.assert(testOldAccounts[i].PersonHasOptedOutOfEmail == false);
			} else {
				System.assertEquals(newLeads[i].utm_campaign__c, testOldAccounts[i].utm_campaign__c);
			}
		}

		System.assertEquals(testNewLeads.size(), 0);
		delete oldAccounts;

		List<Account> accountsList = new List<Account>();
		List<Lead> leadsList = new List<Lead>();
		//new Lead(without utm, EmailOptOut = true)
		//which email is the same as existing Account(without utm, EmailOptOut = true)
		Account oldFirstAccount = new Account(
			RecordTypeId = customerRecordType.Id,
			LastName = 'oldFirstAccount',
			PersonEmail = 'oldFirstAccount@domain.com',
			PersonHasOptedOutOfEmail = true
		);
		accountsList.add(oldFirstAccount);

		Lead newFirstLead = new Lead(
			LastName = 'newFirstLead',
			Status = 'Open',
			Email = 'oldFirstAccount@domain.com',
			HasOptedOutOfEmail = true
		);
		leadsList.add(newFirstLead);

		//new Lead(with utm1, EmailOptOut = false)
		//which email is the same as existing Account(without utm, EmailOptOut = false)
		Account oldSecondAccount = new Account(
			RecordTypeId = customerRecordType.Id,
			LastName = 'oldSecondAccount',
			PersonEmail = 'oldSecondAccount@domain.com',
			PersonHasOptedOutOfEmail = false
		);
		accountsList.add(oldSecondAccount);

		Lead newThirdLead = new Lead(
			LastName = 'newThirdLead',
			Status = 'Open',
			Email = 'oldSecondAccount@domain.com',
			HasOptedOutOfEmail = false,
			utm_campaign__c = 'campaign',
			utm_content__c = 'content',
			utm_medium__c = 'medium',
			utm_source__c = 'source',
			utm_term__c = 'term'
		);
		leadsList.add(newThirdLead);

		//new Lead(with utm1, EmailOptOut = false)
		//which email is the same as existing Account(with utm2, EmailOptOut = true)
		Account oldThirdAccount = new Account(
			RecordTypeId = customerRecordType.Id,
			LastName = 'oldThirdAccount',
			PersonEmail = 'oldThirdAccount@domain.com',
			PersonHasOptedOutOfEmail = true,
			utm_campaign__c = 'campaign2',
			utm_content__c = 'content2',
			utm_medium__c = 'medium2',
			utm_source__c = 'source2',
			utm_term__c = 'term2'
		);
		accountsList.add(oldThirdAccount);

		Lead newFifthLead = new Lead(
			LastName = 'newFifthLead',
			Status = 'Open',
			Email = 'oldThirdAccount@domain.com',
			HasOptedOutOfEmail = false,
			utm_campaign__c = 'campaign',
			utm_content__c = 'content',
			utm_medium__c = 'medium',
			utm_source__c = 'source',
			utm_term__c = 'term'
		);
		leadsList.add(newFifthLead);

		//new Lead(without utm, EmailOptOut = true)
		//which email is the same as existing Account(with utm, EmailOptOut = false)
		Account oldFourthAccount = new Account(
			LastName = 'oldFourthAccount',
			PersonEmail = 'oldFourthAccount@domain.com',
			PersonHasOptedOutOfEmail = false,
			utm_campaign__c = 'campaign2',
			utm_content__c = 'content2',
			utm_medium__c = 'medium2',
			utm_source__c = 'source2',
			utm_term__c = 'term2'
		);
		accountsList.add(oldFourthAccount);

		Lead newSeventhLead = new Lead(
			LastName = 'newSeventhLead',
			Status = 'Open',
			Email = 'oldFourthAccount@domain.com',
			HasOptedOutOfEmail = true
		);
		leadsList.add(newSeventhLead);

		//existing campaing with utm1, existing lead with utm1, try to create lead with the same credentials.
		Campaign testCamp = new Campaign(
			Landing_Page__c = 'test',
			Name = 'test', Campaign__c = 'test', //UTM_Campaign__c
			Ad_Platform__c = 'test', //utm_source
			Buying_Type__c = 'test', //utm_medium
			Ad_Type__c = 'test', Content__c = 'test', //UTM_Content__c
			Term__c = 'test' //Term__c
		);
		insert testCamp;

		Account testAcc = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'jane',
			LastName = 'doe',
			PersonEmail = 'testLead@domain.com',
			utm_source__c = 'test',
			utm_medium__c = 'test',
			utm_campaign__c = 'testtest',
			utm_content__c = 'test',
			utm_term__c = 'testtest'
		);
		accountsList.add(testAcc);

		Lead testLead = new Lead(
			FirstName = 'jane2',
			LastName = 'doe2',
			Email = 'testLead@domain.com',
			utm_source__c = 'test',
			utm_medium__c = 'test',
			utm_campaign__c = 'testtest',
			utm_content__c = 'test',
			utm_term__c = 'testtest'
		);
		leadsList.add(testLead);

		Test.startTest();
		insert accountsList;
		insert leadsList;
		Test.stopTest();

		List<Account> testOldAccount = [SELECT PersonHasOptedOutOfEmail FROM Account WHERE LastName = 'oldFirstAccount']; //insert oldFirstAccount;
		List<Lead> testNewLead = [SELECT LastName FROM Lead WHERE LastName = 'newFirstLead']; //insert newFirstLead;
		System.assert(testOldAccount[0].PersonHasOptedOutOfEmail == false);
		System.assertEquals(testNewLead.size(), 0);

		testOldAccount = [SELECT utm_campaign__c FROM Account WHERE LastName = 'oldSecondAccount']; //insert oldSecondAccount;
		testNewLead = [SELECT LastName From Lead WHERE LastName = 'newThirdLead']; //insert newThirdLead;
		System.assert(testOldAccount[0].utm_campaign__c == 'campaign');
		System.assertEquals(testNewLead.size(), 0);

		testOldAccount = [SELECT PersonHasOptedOutOfEmail, utm_campaign__c FROM Account WHERE LastName = 'oldThirdAccount']; //insert oldThirdAccount;
		testNewLead = [SELECT LastName From Lead WHERE LastName = 'newFifthLead']; //insert newFifthLead;
		System.assert(testOldAccount[0].PersonHasOptedOutOfEmail == false && testOldAccount[0].utm_campaign__c == 'campaign');
		System.assertEquals(testNewLead.size(), 0);

		testOldAccount = [SELECT utm_campaign__c FROM Account WHERE LastName = 'oldFourthAccount'];
		testNewLead = [SELECT LastName From Lead WHERE LastName = 'newSeventhLead'];
		System.assert(testOldAccount[0].utm_campaign__c == null); //insert oldFourthAccount;
		System.assertEquals(testNewLead.size(), 0);//insert newSeventhLead;

		testNewLead = [SELECT FirstName From Lead WHERE FirstName = 'jane2'];//insert testLead;
		System.assertEquals(0, testNewLead.size());
	}

	@isTest static void test_optinduplicate_allscenarios_new_lead() {
		//new Lead(with new email, with utm)
		List<Lead> leads = new List<Lead>();
		Lead newNinthLead = new Lead(
			LastName = 'newNinthLead',
			Status = 'Open',
			Email = 'newNinthLead@domain.com',
			utm_campaign__c = 'campaign2',
			utm_content__c = 'content2',
			utm_medium__c = 'medium2',
			utm_source__c = 'source2',
			utm_term__c = 'term2'
		);
		leads.add(newNinthLead);

		//new Lead(with new email, without utm)
		Lead newTenthLead = new Lead(
			LastName = 'newTenthLead',
			Status = 'Open',
			Email = 'newTenthLead@domain.com'
		);
		leads.add(newTenthLead);

		//new Lead(without email)
		Lead newEleventhLead = new Lead(
			LastName = 'newEleventhLead',
			Status = 'Open'
		);
		leads.add(newEleventhLead);

		//new lead with utm1 and existing campaing with utm1
		Campaign testCamp = new Campaign(
			Landing_Page__c = 'test',
			Name = 'test', Campaign__c = 'test', //UTM_Campaign__c
			Ad_Platform__c = 'test', //utm_source
			Buying_Type__c = 'test', //utm_medium
			Ad_Type__c = 'test', Content__c = 'test', //UTM_Content__c
			Term__c = 'test' //Term__c
		);
		insert testCamp;

		Lead testLead = new Lead(
			FirstName = 'jane',
			LastName = 'doe',
			Email = 'testLead@domain.com',
			utm_source__c = 'test',
			utm_medium__c = 'test',
			utm_campaign__c = 'testtest',
			utm_content__c = 'test',
			utm_term__c = 'testtest'
		);
		leads.add(testLead);

		Test.startTest();
		insert leads;
		//RESULT: creating new lead
		//RESULT: creating new lead
		//RESULT: creating new lead
		//RESULT: add lead to existing campaing
		Test.stopTest();

		List<Lead> testNewLead = [SELECT LastName, utm_campaign__c FROM Lead WHERE LastName = 'newNinthLead']; //insert newNinthLead;
		System.assertEquals(testNewLead[0].LastName, newNinthLead.LastName);
		System.assertEquals(testNewLead[0].utm_campaign__c, newNinthLead.utm_campaign__c);

		testNewLead = [SELECT LastName, utm_campaign__c FROM Lead WHERE LastName = 'newTenthLead']; //insert newTenthLead;
		System.assertEquals(testNewLead[0].LastName, newTenthLead.LastName);
		System.assertEquals(testNewLead[0].utm_campaign__c, newTenthLead.utm_campaign__c);

		testNewLead = [SELECT LastName FROM Lead WHERE LastName = 'newEleventhLead'];//insert newEleventhLead;
		System.assertEquals(testNewLead[0].LastName, newEleventhLead.LastName);

		List<CampaignMember> testCampMember = [SELECT LeadId FROM CampaignMember];//insert testLead;
		System.assertEquals(testLead.id, testCampMember[0].LeadId);
	}

	 @isTest static void test_leadconvert_account_ctl_and_date_acquired() {

		Lead newLead = new Lead(
			LastName = 'newLead',
			Status = 'Open',
			Email = 'newLead@domain.com'
		);
		insert newLead;

		Social_Profile__c socialA = new Social_Profile__c (Lead__c = newLead.Id);
		Social_Profile__c socialB = new Social_Profile__c (Lead__c = newLead.Id);
		insert new List<Social_Profile__c> {socialA, socialB};

		Datetime yesterday = Datetime.now().addDays(-1);
		Test.setCreatedDate(newLead.Id, yesterday);

		LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];

		Test.startTest();
		Database.LeadConvert lc = new database.LeadConvert();
			lc.setLeadId(newLead.Id);
			lc.setConvertedStatus(convertStatus.MasterLabel);
			lc.setDoNotCreateOpportunity(true);
		Database.LeadConvertResult lcr = Database.convertLead(lc);
		Test.stopTest();

		System.assert(lcr.isSuccess());

		List<Lead> ld = [SELECT Id, ConvertedDate FROM Lead WHERE Id = :lcr.getLeadId()];
		List<Account> acc = [SELECT Id, Lead_CTL__c, Date_Lead_Acquired__c FROM Account WHERE Id = :lcr.getAccountId()];
		System.assertEquals(acc.isEmpty(), false);
		System.assertEquals(acc[0].Lead_CTL__c, 1);
		System.assertEquals(acc[0].Date_Lead_Acquired__c, ld[0].ConvertedDate);

		System.assertEquals(2, [SELECT COUNT() FROM Social_Profile__c WHERE Lead__c = null AND Account__c =: acc[0].id]);
	 }


	@isTest static void test_deleteFcLead_socialProfiles() {
		Lead leadA = new Lead(LastName = 'ALead', FirstName = 'First', Email = 'testA@gmail.com', Phone = '1234567890');
		Lead leadB = new Lead(LastName = 'BLead', FirstName = 'First', Email = 'testB@gmail.com', Phone = '1234567890');
		insert new List<Lead> {leadA, leadB};

		Social_Profile__c socialA = new Social_Profile__c (Lead__c = leadA.Id);
		Social_Profile__c socialB = new Social_Profile__c (Lead__c = leadB.Id);
		insert new List<Social_Profile__c> {socialA, socialB};

		delete leadA;
		System.assertEquals(1, [SELECT COUNT() FROM Social_Profile__c]);

		delete leadB;
		System.assertEquals(0, [SELECT COUNT() FROM Social_Profile__c]);
	}


}