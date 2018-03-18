@isTest
private class CampaignLinkTriggerTest {

	@isTest static void test_campaignlink() {
		//CAMPAIGNS
		Campaign testCamp1 = new Campaign(
			Landing_Page__c = 'campaign_1_',
			Name = 'campaign_1_',
			Campaign__c = 'test1', //UTM_Campaign__c
			Ad_Platform__c = 'test2', //utm_source
			Buying_Type__c = 'test3', //utm_medium
			Content__c = 'test4', //UTM_Content__c
			Term__c = 'Term', //Term__c
			Total_Orders__c = 1,
			Total_Orders_Value__c = 1,
			Total_Customers_Value__c = 1,
			Campaign_Level__c = 0,
			Lead_CTL_Sum__c = 10,
			ActualCost = 100
		);
		insert testCamp1;

		Test.startTest();
			Campaign_Links__c newCampaignLink = new Campaign_Links__c(
				Device__c = 'Desktop',
				Landing_Page_Override__c = 'testLandingPage',
				Email_Link_Name__c = 'LinkName',
				Email_Name__c = 'EmailName',
				Email_Section_Name__c = 'EmailSection',
				Headline_Text_Name__c = 'HeadlineText',
				Image_Name__c = 'ImageName',
				Campaign__c = testCamp1.Id
			);
			insert newCampaignLink;

		Test.stopTest();

		List<Campaign_Links__c> campaignLinksList = [
			SELECT Id, URL__c, UTM_Hash__c
			FROM Campaign_Links__c
			WHERE Id =: newCampaignLink.Id
		];
		List<Campaign> testCampList = [
			SELECT Id, URL__c, UTM_Hash__c, UTM_Source__c, UTM_Medium__c,
				UTM_Content__c, UTM_Campaign__c, Term__c
			FROM Campaign
			WHERE Id =: testCamp1.Id
		];

		//check the correct URL and UTM
		//&utm_term=term_desktop_imagename_headlinetext_emailname_emailsection_linkname
		String strURL = testCampList[0].Term__c + '_' +  newCampaignLink.Device__c +
			'_' + newCampaignLink.Image_Name__c + '_' + newCampaignLink.Headline_Text_Name__c +
			'_' + newCampaignLink.Email_Name__c + '_' + newCampaignLink.Email_Section_Name__c +
			'_' + newCampaignLink.Email_Link_Name__c;
		Pagereference prOld = new Pagereference(campaignLinksList[0].URL__c);
		System.assertEquals(strURL.toLowerCase().trim(), prOld.getParameters().get('utm_term'));

		String strUTM = testCampList[0].UTM_Hash__c + '_' + newCampaignLink.Device__c + '_' +
			newCampaignLink.Image_Name__c + '_' + newCampaignLink.Headline_Text_Name__c + '_' +
			newCampaignLink.Email_Name__c + '_' + newCampaignLink.Email_Section_Name__c + '_' +
			newCampaignLink.Email_Link_Name__c;
		System.assertEquals(strUTM.toLowerCase().trim(), campaignLinksList[0].UTM_Hash__c);
	}

	@isTest static void test_campaignlink_bulk() {
		Map<Id, Campaign> idToCampaign = new Map<Id, Campaign>();
		List<Campaign> campaignList = new List<Campaign>();
		List<Campaign_Links__c> campaignLinks = new List<Campaign_Links__c>();

		for (Integer idx = 0; idx < 300; idx++) {
			campaignList.add(new Campaign(
				Landing_Page__c = 'campaign_1_',
				Name = String.valueOf(idx),
				Campaign__c = 'campaign_' + idx, //UTM_Campaign__c
				Ad_Platform__c = 'campaign_' + idx, //utm_source
				Buying_Type__c = 'campaign_' + idx, //utm_medium
				Ad_Type__c = 'campaign_' + idx,
				Content__c = 'campaign_' + idx, //UTM_Content__c
				Term__c = 'campaign_' + idx, //Term__c
				Total_Orders__c = 1,
				Total_Orders_Value__c = 1,
				Total_Customers_Value__c = 1,
				Campaign_Level__c = 0,
				Lead_CTL_Sum__c = 10,
				ActualCost = 100
			));
		}
		insert campaignList;

		List<Campaign> testCampList = [
			SELECT Id, Name, Landing_Page__c, Campaign__c, Ad_Platform__c,
				Buying_Type__c, Ad_Type__c, Content__c, Term__c, URL__c, UTM_Hash__c
			FROM Campaign
			ORDER BY Name
		];

		for (Campaign item : testCampList) {
			idToCampaign.put(item.Id, item);
		}

		Test.startTest();
			for (Integer idx = 0; idx < 300; idx++) {
				Campaign_Links__c newCampaignLink = new Campaign_Links__c(
					Device__c = 'Desktop',
					Email_Link_Name__c = 'LinkName' + idx,
					Email_Name__c = 'EmailName' + idx,
					Email_Section_Name__c = 'EmailSection' + idx,
					Headline_Text_Name__c = 'HeadlineText' + idx,
					Image_Name__c = 'ImageName' + idx,
					Campaign__c = testCampList[idx].Id
				);
				campaignLinks.add(newCampaignLink);
			}
			insert campaignLinks;
		Test.stopTest();

		List<Id> Ids = new List<Id>();
		for (Campaign_Links__c aCampaignLink : campaignLinks) {
			Ids.add(aCampaignLink.Id);
		}

		List<Campaign_Links__c> campaignLinksList = [
			SELECT Id, URL__c, UTM_Hash__c, Device__c, Email_Link_Name__c,
				Email_Name__c, Email_Section_Name__c, Headline_Text_Name__c,
				Image_Name__c, Campaign__c
			FROM Campaign_Links__c
			WHERE Id IN: Ids
		];
		System.assertEquals(300, campaignLinksList.size());

		for (Campaign_Links__c aCampaignLink : campaignLinksList) {
			Campaign aCampaign = (Campaign) idToCampaign.get(aCampaignLink.Campaign__c);

			String strURL = aCampaign.Term__c + '_' + aCampaignLink.Device__c + '_' +
				aCampaignLink.Image_Name__c + '_' + aCampaignLink.Headline_Text_Name__c + '_' +
				aCampaignLink.Email_Name__c + '_' + aCampaignLink.Email_Section_Name__c + '_' +
				aCampaignLink.Email_Link_Name__c;
			Pagereference prOld = new Pagereference(aCampaignLink.URL__c);
			System.assertEquals(strURL.toLowerCase().trim(), prOld.getParameters().get('utm_term'));

			String strUTM = aCampaign.UTM_Hash__c + '_' + aCampaignLink.Device__c + '_' +
				aCampaignLink.Image_Name__c + '_' + aCampaignLink.Headline_Text_Name__c + '_' +
				aCampaignLink.Email_Name__c + '_' + aCampaignLink.Email_Section_Name__c + '_' +
				aCampaignLink.Email_Link_Name__c;
			System.assertEquals(strUTM.toLowerCase().trim(), aCampaignLink.UTM_Hash__c);
		}
	}

	@isTest static void test_campaignlink_term() {
		//CAMPAIGNS
		Campaign testCamp1 = new Campaign(
			Landing_Page__c = 'campaign_1_',
			Name = 'campaign_1_',
			Campaign__c = 'campaign_1_', //UTM_Campaign__c
			Ad_Platform__c = 'campaign_1_', //utm_source
			Buying_Type__c = 'campaign_1_', //utm_medium
			Ad_Type__c = 'campaign_1_',
			Content__c = 'campaign_1_', //UTM_Content__c
			Total_Orders__c = 1,
			Total_Orders_Value__c = 1,
			Total_Customers_Value__c = 1,
			Campaign_Level__c = 0,
			Lead_CTL_Sum__c = 10,
			ActualCost = 100
		);
		insert testCamp1;

		Test.startTest();
			List<Campaign_Links__c> campaignLinks = new List<Campaign_Links__c>();

			//create Campaign_Links__c with different set of parameters
			Campaign_Links__c newCampaignLink0 = new Campaign_Links__c(
				Device__c = 'Desktop',
				Image_Name__c = 'ImageName',
				Headline_Text_Name__c = 'HeadlineText',
				Email_Name__c = 'EmailName',
				Email_Section_Name__c = 'EmailSection',
				Email_Link_Name__c = 'LinkName',
				Campaign__c = testCamp1.Id,
				Ad_Sizes__c = '120x600'
			);
			campaignLinks.add(newCampaignLink0);

			Campaign_Links__c newCampaignLink1 = new Campaign_Links__c(
				Image_Name__c = 'ImageName',
				Headline_Text_Name__c = 'HeadlineText',
				Email_Name__c = 'EmailName',
				Email_Section_Name__c = 'EmailSection',
				Email_Link_Name__c = 'LinkName',
				Campaign__c = testCamp1.Id,
				Ad_Sizes__c = '120x600'
			);
			campaignLinks.add(newCampaignLink1);

			Campaign_Links__c newCampaignLink2 = new Campaign_Links__c(
				Headline_Text_Name__c = 'HeadlineText',
				Email_Name__c = 'EmailName',
				Email_Section_Name__c = 'EmailSection',
				Email_Link_Name__c = 'LinkName',
				Campaign__c = testCamp1.Id,
				Ad_Sizes__c = '120x600'
			);
			campaignLinks.add(newCampaignLink2);

			Campaign_Links__c newCampaignLink3 = new Campaign_Links__c(
				Email_Name__c = 'EmailName',
				Email_Section_Name__c = 'EmailSection',
				Email_Link_Name__c = 'LinkName',
				Campaign__c = testCamp1.Id,
				Ad_Sizes__c = '120x600'
			);
			campaignLinks.add(newCampaignLink3);

			Campaign_Links__c newCampaignLink4 = new Campaign_Links__c(
				Email_Section_Name__c = 'EmailSection',
				Email_Link_Name__c = 'LinkName',
				Campaign__c = testCamp1.Id,
				Ad_Sizes__c = '120x600'
			);
			campaignLinks.add(newCampaignLink4);

			Campaign_Links__c newCampaignLink5 = new Campaign_Links__c(
				Email_Link_Name__c = 'LinkName',
				Campaign__c = testCamp1.Id,
				Ad_Sizes__c = '120x600'
			);
			campaignLinks.add(newCampaignLink5);

			Campaign_Links__c newCampaignLink6 = new Campaign_Links__c(
				Campaign__c = testCamp1.Id,
				Ad_Sizes__c = '120x600'
			);
			campaignLinks.add(newCampaignLink6);

			insert campaignLinks;

		Test.stopTest();

		List<Campaign_Links__c> campaignLinksList = [
			SELECT Id, URL__c, UTM_Hash__c, Ad_Sizes__c
			FROM Campaign_Links__c
			WHERE Id =: newCampaignLink6.Id
		];
		List<Campaign> testCampList = [
			SELECT Id, URL__c, UTM_Hash__c
			FROM Campaign
			WHERE Id =: testCamp1.Id
		];

		//verifies that filled only Ad_Sizes__c
		String strURL = campaignLinksList[0].Ad_Sizes__c ;
		Pagereference prOld = new Pagereference(campaignLinksList[0].URL__c);
		System.assertEquals(strURL.toLowerCase().trim(), prOld.getParameters().get('utm_term'));

		String strUTM = testCampList[0].UTM_Hash__c + campaignLinksList[0].Ad_Sizes__c ;
		System.assertEquals(strUTM.toLowerCase().trim(), campaignLinksList[0].UTM_Hash__c);
	}

}