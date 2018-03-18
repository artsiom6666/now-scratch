@isTest
private class CampaignMemberBatchTest {

	@isTest static void test_match_account_campaignlink() {
		Campaign testCamp = new Campaign(
			Landing_Page__c = 'test',
			Name = 'test', Campaign__c = 'test', //UTM_Campaign__c
			Ad_Platform__c = 'test', //utm_source
			Buying_Type__c = 'test', //utm_medium
			Ad_Type__c = 'test', Content__c = 'test', //UTM_Content__c
			Term__c = 'test' //Term__c
		);
		insert testCamp;

		List<Campaign_Links__c> allCampaignLinks = new List<Campaign_Links__c>{
			new Campaign_Links__c(
				Device__c = 'Desktop',
				Image_Name__c = 'ImageName',
				Headline_Text_Name__c = 'HeadlineText',
				Email_Name__c = 'EmailName',
				Email_Section_Name__c = 'EmailSection',
				Email_Link_Name__c = 'LinkName',
				Campaign__c = testCamp.Id
			),
			new Campaign_Links__c(
				Device__c = 'Desktop',
				Image_Name__c = 'ImageName2',
				Headline_Text_Name__c = 'HeadlineText2',
				Email_Name__c = 'EmailName2',
				Email_Section_Name__c = 'EmailSection2',
				Email_Link_Name__c = 'LinkName2',
				Campaign__c = testCamp.Id
			)
		};
		insert allCampaignLinks;

		List<RecordType> paRt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer_Account' LIMIT 1];
		List<Account> allAccounts = new List<Account>{
			new Account(
				FirstName = 'jane',
				LastName = 'doe',
				RecordTypeId = paRt[0].Id,
				utm_source__c = 'test',
				utm_medium__c = 'test',
				utm_campaign__c = 'testtest',
				utm_content__c = 'test',
				utm_term__c = 'testtest_desktop_imagename_headlinetext_emailname_emailsection_linkname'
			),
			new Account(
				FirstName = 'jane',
				LastName = 'doe1',
				RecordTypeId = paRt[0].Id,
				utm_source__c = 'test',
				utm_medium__c = 'test',
				utm_campaign__c = 'testtest',
				utm_content__c = 'test',
				utm_term__c = 'testtest_desktop_imagename2_headlinetext2_emailname2_emailsection2_linkname2'
			)
		};
		insert allAccounts;

		Test.startTest();
			CampaignMemberBatch b = new CampaignMemberBatch(1);
			database.executebatch(b);
		Test.stopTest();

		List<CampaignMember> testObjList = [SELECT ContactId FROM CampaignMember];
		System.assertEquals(2, testObjList.size());
	}

	@isTest static void test_match_lead_campaignlink() {
		Campaign testCamp = new Campaign(
			Landing_Page__c = 'test',
			Name = 'test', Campaign__c = 'test', //UTM_Campaign__c
			Ad_Platform__c = 'test', //utm_source
			Buying_Type__c = 'test', //utm_medium
			Ad_Type__c = 'test', Content__c = 'test', //UTM_Content__c
			Term__c = 'test' //Term__c
		);
		insert testCamp;

		Campaign_Links__c aCampaignLink = new Campaign_Links__c(
			Device__c = 'Desktop',
			Email_Link_Name__c = 'Link',
			Email_Name__c = 'EmailName',
			Email_Section_Name__c = 'Section',
			Headline_Text_Name__c = 'HeadlineText',
			Image_Name__c = 'ImageName',
			Campaign__c = testCamp.Id
		);
		insert aCampaignLink;

		Lead testLead = new Lead(
			FirstName = 'jane',
			LastName = 'doe',
			utm_source__c = 'test',
			utm_medium__c = 'test',
			utm_campaign__c = 'testtest',
			utm_content__c = 'test',
			utm_term__c = 'testtest_desktop_imagename_headlinetext_emailname_section_link'
		);
		insert testLead;

		Test.startTest();
			CampaignMemberBatch b = new CampaignMemberBatch(2);
			database.executebatch(b);
		Test.stopTest();

		List<CampaignMember> testObjList = [SELECT LeadId FROM CampaignMember];

		System.assertEquals(testLead.Id, testObjList[0].LeadId);
	}

	@isTest static void test_bulk_account() {
		List<Campaign> testCampaigns = new List<Campaign>();
		Campaign testCampAcc = new Campaign(
			Landing_Page__c = 'account',
			Name = 'account', Campaign__c = 'account', //UTM_Campaign__c
			Ad_Platform__c = 'account', //utm_source
			Buying_Type__c = 'account', //utm_medium
			Ad_Type__c = 'account', Content__c = 'account', //UTM_Content__c
			Term__c = 'account' //Term__c
		);
		testCampaigns.add(testCampAcc);

		Campaign testCampLead = new Campaign(
			Landing_Page__c = 'lead',
			Name = 'lead', Campaign__c = 'lead', //UTM_Campaign__c
			Ad_Platform__c = 'lead', //utm_source
			Buying_Type__c = 'lead', //utm_medium
			Ad_Type__c = 'lead', Content__c = 'lead', //UTM_Content__c
			Term__c = 'lead' //Term__c
		);
		testCampaigns.add(testCampLead);

		Campaign testCampOrder = new Campaign(
			Landing_Page__c = 'order',
			Name = 'order', Campaign__c = 'order', //UTM_Campaign__c
			Ad_Platform__c = 'order', //utm_source
			Buying_Type__c = 'order', //utm_medium
			Ad_Type__c = 'order', Content__c = 'order', //UTM_Content__c
			Term__c = 'order' //Term__c
		);
		testCampaigns.add(testCampOrder);
		insert testCampaigns;

		List<RecordType> paRt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer_Account' LIMIT 1];
		Integer start = 1;
		Integer numRepeats = 50;
		List<Account> testAccount1stCampaignList = new List<Account>();
		List<Account> testAccount2ndCampaignList = new List<Account>();
		List<Account> testAccount3rdCampaignList = new List<Account>();
		List<Account> testAccount4thNonCampaignList = new List<Account>();
		//1st campaign account
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Account testAcc = new Account(
				FirstName = 'jane_' + idx,
				LastName = 'doe_' + idx,
				RecordTypeId = paRt[0].Id,
				utm_source__c = 'account',
				utm_medium__c = 'account',
				utm_campaign__c = 'accountaccount',
				utm_content__c = 'account',
				utm_term__c = 'accountaccount'
			);
			testAccount1stCampaignList.add(testAcc);
		}
		//2nd campaign account
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Account testAcc = new Account(
				FirstName = 'jane_' + idx * 10,
				LastName = 'doe_' + idx * 10,
				RecordTypeId = paRt[0].Id,
				utm_source__c = 'lead',
				utm_medium__c = 'lead',
				utm_campaign__c = 'leadlead',
				utm_content__c = 'lead',
				utm_term__c = 'leadlead'
			);
			testAccount2ndCampaignList.add(testAcc);
		}
		//3rd campaign account
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Account testAcc = new Account(
				FirstName = 'jane_' + idx * 20,
				LastName = 'doe_' + idx * 20,
				RecordTypeId = paRt[0].Id,
				utm_source__c = 'order',
				utm_medium__c = 'order',
				utm_campaign__c = 'orderorder',
				utm_content__c = 'order',
				utm_term__c = 'orderorder'
			);
			testAccount3rdCampaignList.add(testAcc);
		}
		//4th campaign account nonmapped acmpaign
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Account testAcc = new Account(
				FirstName = 'jane_' + idx * 20,
				LastName = 'doe_' + idx * 20,
				RecordTypeId = paRt[0].Id,
				utm_source__c = 'nonmapped',
				utm_medium__c = 'nonmapped',
				utm_campaign__c = 'nonmappednonmapped',
				utm_content__c = 'nonmapped',
				utm_term__c = 'nonmappednonmapped'
			);
			testAccount4thNonCampaignList.add(testAcc);
		}

		insert testAccount1stCampaignList;
		insert testAccount2ndCampaignList;
		insert testAccount3rdCampaignList;
		insert testAccount4thNonCampaignList;

		Test.startTest();
			CampaignMemberBatch b = new CampaignMemberBatch(1);
			database.executebatch(b);
		Test.stopTest();
		//totoal 150 of 200 relations createdÅ
		System.assertEquals(150, [SELECT Count() FROM CampaignMember]);

		//1st campaign
		List<CampaignMember> testObjList = [
			SELECT CampaignId
			FROM CampaignMember
			WHERE ContactId IN (SELECT PersonContactId FROM Account WHERE Id IN :testAccount1stCampaignList)
		];
		//assert testAccount1stCampaignList related to 1st campaign
		for (CampaignMember testObj : testObjList) {
			System.assertEquals(testCampAcc.Id, testObj.CampaignId);
		}
		//2nd campaign
		testObjList = [
			SELECT CampaignId
			FROM CampaignMember
			WHERE ContactId IN (SELECT PersonContactId FROM Account WHERE Id IN :testAccount2ndCampaignList)
		];
		//assert testAccount2ndCampaignList related to 2nd campaign
		for (CampaignMember testObj : testObjList) {
			System.assertEquals(testCampLead.Id, testObj.CampaignId);
		}
		//3rd campaign
		testObjList = [
			SELECT CampaignId
			FROM CampaignMember
			WHERE ContactId IN (SELECT PersonContactId FROM Account WHERE Id IN :testAccount3rdCampaignList)
		];
		//assert testAccount2ndCampaignList related to 2nd campaign
		for (CampaignMember testObj : testObjList) {
			System.assertEquals(testCampOrder.Id, testObj.CampaignId);
		}
	}

	@isTest static void test_bulk_lead() {
		List<Campaign> testCampaigns = new List<Campaign>();
		Campaign testCampAcc = new Campaign(
			Landing_Page__c = 'account',
			Name = 'account', Campaign__c = 'account', //UTM_Campaign__c
			Ad_Platform__c = 'account', //utm_source
			Buying_Type__c = 'account', //utm_medium
			Ad_Type__c = 'account', Content__c = 'account', //UTM_Content__c
			Term__c = 'account' //Term__c
		);
		testCampaigns.add(testCampAcc);

		Campaign testCampLead = new Campaign(
			Landing_Page__c = 'lead',
			Name = 'lead', Campaign__c = 'lead', //UTM_Campaign__c
			Ad_Platform__c = 'lead', //utm_source
			Buying_Type__c = 'lead', //utm_medium
			Ad_Type__c = 'lead', Content__c = 'lead', //UTM_Content__c
			Term__c = 'lead' //Term__c
		);
		testCampaigns.add(testCampLead);

		Campaign testCampOrder = new Campaign(
			Landing_Page__c = 'order',
			Name = 'order', Campaign__c = 'order', //UTM_Campaign__c
			Ad_Platform__c = 'order', //utm_source
			Buying_Type__c = 'order', //utm_medium
			Ad_Type__c = 'order', Content__c = 'order', //UTM_Content__c
			Term__c = 'order' //Term__c
		);
		testCampaigns.add(testCampOrder);
		insert testCampaigns;

		Integer start = 1;
		Integer numRepeats = 50;
		List<Lead> testLead1stCampaignList = new List<Lead>();
		List<Lead> testLead2ndCampaignList = new List<Lead>();
		List<Lead> testLead3rdCampaignList = new List<Lead>();
		List<Lead> testLead4thNonCampaignList = new List<Lead>();
		//1st campaign Lead
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Lead testLead = new Lead(
				FirstName = 'jane_' + idx,
				LastName = 'doe_' + idx,
				utm_source__c = 'account',
				utm_medium__c = 'account',
				utm_campaign__c = 'accountaccount',
				utm_content__c = 'account',
				utm_term__c = 'accountaccount'
			);
			testLead1stCampaignList.add(testLead);
		}
		//2nd campaign lead
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Lead testLead = new Lead(
				FirstName = 'jane_' + idx * 10,
				LastName = 'doe_' + idx * 10,
				utm_source__c = 'lead',
				utm_medium__c = 'lead',
				utm_campaign__c = 'leadlead',
				utm_content__c = 'lead',
				utm_term__c = 'leadlead'
			);
			testLead2ndCampaignList.add(testLead);
		}
		//3rd campaign lead
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Lead testLead = new Lead(
				FirstName = 'jane_' + idx * 20,
				LastName = 'doe_' + idx * 20,
				utm_source__c = 'order',
				utm_medium__c = 'order',
				utm_campaign__c = 'orderorder',
				utm_content__c = 'order',
				utm_term__c = 'orderorder'
			);
			testLead3rdCampaignList.add(testLead);
		}
		//4th campaign lead nonmapped acmpaign
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Lead testLead = new Lead(
				FirstName = 'jane_' + idx * 20,
				LastName = 'doe_' + idx * 20,
				utm_source__c = 'nonmapped',
				utm_medium__c = 'nonmapped',
				utm_campaign__c = 'nonmappednonmapped',
				utm_content__c = 'nonmapped',
				utm_term__c = 'nonmappednonmapped'
			);
			testLead4thNonCampaignList.add(testLead);
		}

		insert testLead1stCampaignList;
		insert testLead2ndCampaignList;
		insert testLead3rdCampaignList;
		insert testLead4thNonCampaignList;

		Test.startTest();
			CampaignMemberBatch b = new CampaignMemberBatch(2);
			database.executebatch(b);
		Test.stopTest();
		//totoal 150 of 200 relations createdÅ
		System.assertEquals(150, [SELECT Count() FROM CampaignMember]);

		//1st campaign
		List<CampaignMember> testObjList = [
			SELECT CampaignId
			FROM CampaignMember
			WHERE LeadId IN (SELECT Id FROM Lead WHERE Id IN :testLead1stCampaignList)
		];
		//assert testAccount1stCampaignList related to 1st campaign
		for (CampaignMember testObj : testObjList) {
			System.assertEquals(testCampAcc.Id, testObj.CampaignId);
		}
		//2nd campaign
		testObjList = [
			SELECT CampaignId
			FROM CampaignMember
			WHERE LeadId IN (SELECT Id FROM Lead WHERE Id IN :testLead2ndCampaignList)
		];
		//assert testAccount2ndCampaignList related to 2nd campaign
		for (CampaignMember testObj : testObjList) {
			System.assertEquals(testCampLead.Id, testObj.CampaignId);
		}
		//3rd campaign
		testObjList = [
			SELECT CampaignId
			FROM CampaignMember
			WHERE LeadId IN (SELECT Id FROM Lead WHERE Id IN :testLead3rdCampaignList)
		];
		//assert testAccount2ndCampaignList related to 2nd campaign
		for (CampaignMember testObj : testObjList) {
			System.assertEquals(testCampOrder.Id, testObj.CampaignId);
		}
	}

	@isTest static void test_bulk_order() {
		List<Campaign> testCampaigns = new List<Campaign>();
		Campaign testCampAcc = new Campaign(
			Landing_Page__c = 'account',
			Name = 'account', Campaign__c = 'account', //UTM_Campaign__c
			Ad_Platform__c = 'account', //utm_source
			Buying_Type__c = 'account', //utm_medium
			Ad_Type__c = 'account', Content__c = 'account', //UTM_Content__c
			Term__c = 'account' //Term__c
		);
		testCampaigns.add(testCampAcc);

		Campaign testCampLead = new Campaign(
			Landing_Page__c = 'lead',
			Name = 'lead', Campaign__c = 'lead', //UTM_Campaign__c
			Ad_Platform__c = 'lead', //utm_source
			Buying_Type__c = 'lead', //utm_medium
			Ad_Type__c = 'lead', Content__c = 'lead', //UTM_Content__c
			Term__c = 'lead' //Term__c
		);
		testCampaigns.add(testCampLead);

		Campaign testCampOrder = new Campaign(
			Landing_Page__c = 'order',
			Name = 'order', Campaign__c = 'order', //UTM_Campaign__c
			Ad_Platform__c = 'order', //utm_source
			Buying_Type__c = 'order', //utm_medium
			Ad_Type__c = 'order', Content__c = 'order', //UTM_Content__c
			Term__c = 'order' //Term__c
		);
		testCampaigns.add(testCampOrder);
		insert testCampaigns;

		List<RecordType> rec = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Customer_Account' AND isActive = true LIMIT 1];
		Id personRTId;
		if (!rec.isEmpty()) {personRTId = rec[0].Id; }

		Account testAcc = new Account(
			FirstName = 'Test FName',
			LastName = 'Test LName',
			Average_Order_Value__c = 0,
			RecordTypeId = personRTId,
			PersonEmail = 'test@example.com'
		);
		insert new TouchCR_Settings__c(Name = 'Chargent.OrderUserCreation', Value__c = 'false');
		insert testAcc;

		Integer start = 1;
		Integer numRepeats = 50;

		List<Order__c> testOrder1stCampaignList = new List<Order__c>();
		List<Order__c> testOrder2ndCampaignList = new List<Order__c>();
		List<Order__c> testOrder3rdCampaignList = new List<Order__c>();
		List<Order__c> testOrder4thNonCampaignList = new List<Order__c>();

		//1st campaign order
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Order__c testOrd = new Order__c(
				Account__c = testAcc.Id,
				Subtotal__c = 100,
				utm_source__c = 'account',
				Utm_Medium__c = 'account',
				Utm_Campaign__c = 'accountaccount',
				Utm_Content__c = 'account',
				Utm_Term__c = 'accountaccount'
			);
			testOrder1stCampaignList.add(testOrd);
		}
		//2nd campaign lead
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Order__c testOrd = new Order__c(
				Account__c = testAcc.Id,
				Subtotal__c = 100,
				Utm_Source__c = 'lead',
				Utm_Medium__c = 'lead',
				Utm_Campaign__c = 'leadlead',
				Utm_Content__c = 'lead',
				Utm_Term__c = 'leadlead'
			);
			testOrder2ndCampaignList.add(testOrd);
		}
		//3rd campaign lead
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Order__c testOrd = new Order__c(
				Account__c = testAcc.Id,
				Subtotal__c = 100,
				Utm_Source__c = 'order',
				Utm_Medium__c = 'order',
				Utm_Campaign__c = 'orderorder',
				Utm_Content__c = 'order',
				Utm_Term__c = 'orderorder'
			);
			testOrder3rdCampaignList.add(testOrd);
		}
		//4th campaign lead nonmapped acmpaign
		for (Integer idx = start; idx <= numRepeats; idx++) {
			Order__c testOrd = new Order__c(
				Account__c = testAcc.Id,
				Subtotal__c = 100,
				Utm_Source__c = 'nonmapped',
				Utm_Medium__c = 'nonmapped',
				Utm_Campaign__c = 'nonmappednonmapped',
				Utm_Content__c = 'nonmapped',
				Utm_Term__c = 'nonmappednonmapped'
			);
			testOrder4thNonCampaignList.add(testOrd);
		}

		insert testOrder1stCampaignList;
		insert testOrder2ndCampaignList;
		insert testOrder3rdCampaignList;
		insert testOrder4thNonCampaignList;

		Test.startTest();
			CampaignMemberBatch b = new CampaignMemberBatch(3);
			database.executebatch(b);
		Test.stopTest();
		//totoal 150 of 200 relations created
		System.assertEquals(150, [SELECT Count() FROM Order__c WHERE Campaign__c != null]);

		//1st campaign
		List<Order__c> testObjList = [
			SELECT Campaign__c
			FROM Order__c
			WHERE Id IN :testOrder1stCampaignList
		];
		//assert testAccount1stCampaignList related to 1st campaign
		for (Order__c testObj : testObjList) {
			System.assertEquals(testCampAcc.Id, testObj.Campaign__c);
		}
		//2nd campaign
		testObjList = [
			SELECT Campaign__c
			FROM Order__c
			WHERE Id IN :testOrder2ndCampaignList
		];
		//assert testAccount2ndCampaignList related to 2nd campaign
		for (Order__c testObj : testObjList) {
			System.assertEquals(testCampLead.Id, testObj.Campaign__c);
		}
		//3rd campaign
		testObjList = [
			SELECT Campaign__c
			FROM Order__c
			WHERE Id IN :testOrder3rdCampaignList
		];
		//assert testAccount2ndCampaignList related to 2nd campaign
		for (Order__c testObj : testObjList) {
			System.assertEquals(testCampOrder.Id, testObj.Campaign__c);
		}
		//4th campaign
		testObjList = [
			SELECT Campaign__c
			FROM Order__c
			WHERE Id IN :testOrder4thNonCampaignList
		];
		//assert testAccount2ndCampaignList related to 2nd campaign
		for (Order__c testObj : testObjList) {
			System.assertEquals(null, testObj.Campaign__c);
		}
	}

	@isTest static void test_match_order_campaignlink() {
		Campaign testCamp = new Campaign(
			Landing_Page__c = 'test',
			Name = 'test', Campaign__c = 'test', //UTM_Campaign__c
			Ad_Platform__c = 'test', //utm_source
			Buying_Type__c = 'test', //utm_medium
			Ad_Type__c = 'test', Content__c = 'test', //UTM_Content__c
			Term__c = 'test' //Term__c
		);
		insert testCamp;

		Campaign_Links__c aCampaignLink = new Campaign_Links__c(
			Device__c = 'Desktop',
			Email_Link_Name__c = 'Link',
			Email_Name__c = 'EmailName',
			Email_Section_Name__c = 'Section',
			Headline_Text_Name__c = 'HeadlineText',
			Image_Name__c = 'ImageName',
			Campaign__c = testCamp.Id
		);
		insert aCampaignLink;

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

		testAcc = [SELECT Id, FirstName, LastName, PersonEmail, PersonContactId FROM Account WHERE Id = : testAcc.Id];

		Order__c testOrd = new Order__c(
			Account__c = testAcc.Id,
			Subtotal__c = 100,
			Utm_Source__c = 'test',
			Utm_Medium__c = 'test',
			Utm_Campaign__c = 'testtest',
			Utm_Content__c = 'test',
			Utm_Term__c = 'testtest_desktop_imagename_headlinetext_emailname_section_link'
		);
		insert testOrd;

		Test.startTest();
			CampaignMemberBatch b = new CampaignMemberBatch(3);
			database.executebatch(b);
		Test.stopTest();

		List<Order__c> testObjList = [SELECT Campaign__c FROM Order__c];

		System.assertEquals(testCamp.Id, testObjList[0].Campaign__c);

		//new
		List<CampaignMember> testCM = [SELECT Id, CampaignId, ContactId FROM CampaignMember];
		System.assertEquals(1, testCM.size());
		System.assertEquals(testCamp.Id, testCM[0].CampaignId);
		System.assertEquals(testAcc.PersonContactId, testCM[0].ContactId);
	}
}