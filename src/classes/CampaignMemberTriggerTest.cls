@isTest
private class CampaignMemberTriggerTest {

    @isTest static void test_cpa_byonecustomer() {
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
        Campaign testCamp2 = new Campaign(
            Landing_Page__c = 'campaign_2_',
            Name = 'campaign_2_', Campaign__c = 'campaign_2_', //UTM_Campaign__c
            Ad_Platform__c = 'campaign_2_', //utm_source
            Buying_Type__c = 'campaign_2_', //utm_medium
            Ad_Type__c = 'campaign_2_', Content__c = 'campaign_2_', //UTM_Content__c
            Term__c = 'campaign_2_', //Term__c
            ParentId = testCamp1.Id,
            Total_Orders__c = 2,
            Total_Orders_Value__c = 2,
            Total_Customers_Value__c = 2,
            Campaign_Level__c = 1,
            Lead_CTL_Sum__c = 20,
            ActualCost = 200
        );
        insert testCamp2;
        Campaign_Cost__c testCC2 = new Campaign_Cost__c(
            Campaign__c = testCamp2.Id,
            Cost__c = 100
        );
        insert testCC2;
        Campaign testCamp3 = new Campaign(
            Landing_Page__c = 'campaign_3_',
            Name = 'campaign_3_', Campaign__c = 'campaign_3_', //UTM_Campaign__c
            Ad_Platform__c = 'campaign_3_', //utm_source
            Buying_Type__c = 'campaign_3_', //utm_medium
            Ad_Type__c = 'campaign_3_', Content__c = 'campaign_3_', //UTM_Content__c
            Term__c = 'campaign_3_', //Term__c
            ParentId = testCamp2.Id,
            Total_Orders__c = 3,
            Total_Orders_Value__c = 3,
            Total_Customers_Value__c = 3,
            Campaign_Level__c = 2,
            Lead_CTL_Sum__c = 30,
            ActualCost = 300
        );
        insert testCamp3;
        Campaign_Cost__c testCC3 = new Campaign_Cost__c(
            Campaign__c = testCamp3.Id,
            Cost__c = 300
        );
        insert testCC3;

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
        Account testAcc2 = new Account(
            FirstName = 'jane2',
            LastName = 'doe2',
            RecordTypeId = paRt[0].Id,
            utm_source__c = 'test2',
            utm_medium__c = 'test2',
            utm_campaign__c = 'test2test2',
            utm_content__c = 'test2',
            utm_term__c = 'test2test2'
        );
        insert testAcc2;
        testAcc2 = [SELECT Id, Total_CPA__c, PersonContactId FROM Account WHERE Id = :testAcc2.Id LIMIT 1];
        Account testAcc3 = new Account(
            FirstName = 'jane3',
            LastName = 'doe3',
            RecordTypeId = paRt[0].Id,
            utm_source__c = 'test3',
            utm_medium__c = 'test3',
            utm_campaign__c = 'test3test3',
            utm_content__c = 'test3',
            utm_term__c = 'test3test3'
        );
        insert testAcc3;
        testAcc3 = [SELECT Id, Total_CPA__c, PersonContactId FROM Account WHERE Id = :testAcc3.Id LIMIT 1];
        Account testAcc4 = new Account(
            FirstName = 'jane4',
            LastName = 'doe4',
            RecordTypeId = paRt[0].Id,
            utm_source__c = 'test4',
            utm_medium__c = 'test4',
            utm_campaign__c = 'test4test4',
            utm_content__c = 'test4',
            utm_term__c = 'test4test4'
        );
        insert testAcc4;
        testAcc4 = [SELECT Id, Total_CPA__c, PersonContactId FROM Account WHERE Id = :testAcc4.Id LIMIT 1];

        //MEMBERS
        //Camp#1 + Customer#1
        //Campaign NumberOfContacts 0 => 1
        //Campaign CPA null=>100
        //Customer CPA => null
        //CPA = ActualCost / NumberContacts

        CampaignMember testCM1 = new CampaignMember(
            CampaignId = testCamp1.Id,
            ContactId = testAcc1.PersonContactId
        );
        insert testCM1;

        //Campaign CPA now calculated and equals to 100 as 1st member inserted
        List<Campaign> testC1 = [SELECT Id, ActualCost, Total_CPA__c FROM Campaign WHERE Id =:testCamp1.Id];
        System.assertEquals(100, testC1[0].Total_CPA__c);
        //but customer CPA is null, cause it was 1st customer
        List<Account> testA1 = [SELECT Id, Total_CPA__c FROM Account WHERE Id =:testAcc1.Id];
        System.assertEquals(null, testA1[0].Total_CPA__c);

        //Camp#1 + Customer#2
        //Campaign NumberOfContacts 1=>2
        //Campaign CPA 100 => 50
        //Customer CPA => 100

        CampaignMember testCM2 = new CampaignMember(
            CampaignId = testCamp1.Id,
            ContactId = testAcc2.PersonContactId
        );
        insert testCM2;
        //now existing CPA from campaign will be captured in customer
        List<Account> testA2 = [SELECT Id, Total_CPA__c FROM Account WHERE Id =:testAcc2.Id];
        System.assertEquals(100, testA2[0].Total_CPA__c);

        //Camp#1 + Customer#3
        //Campaign NumberOfContacts 2=>3
        //Campaign CPA 50 => 33.3
        //Customer CPA => 50

        CampaignMember testCM3 = new CampaignMember(
            CampaignId = testCamp1.Id,
            ContactId = testAcc3.PersonContactId
        );
        insert testCM3;
        //now existing CPA from campaign will be captured in customer
        List<Account> testA3 = [SELECT Id, Total_CPA__c FROM Account WHERE Id =:testAcc3.Id];
        System.assertEquals(50, testA3[0].Total_CPA__c);

        //Camp#2 + Customer#1
        //Campaign NumberOfContacts 0 => 1
        //Campaign CPA null => 200
        //Customer CPA => null
        //CPA = ActualCost / NumberContacts
        CampaignMember testCM4 = new CampaignMember(
            CampaignId = testCamp2.Id,
            ContactId = testAcc1.PersonContactId
        );
        insert testCM4;

        //but customer CPA is null, cause it was 1st customer
        List<Account> testA4 = [SELECT Id, Total_CPA__c FROM Account WHERE Id =:testAcc1.Id];
        System.assertEquals(null, testA1[0].Total_CPA__c);

        //Camp#2 + Customer#2
        //Campaign NumberOfContacts 1=>2
        //Campaign CPA 200 => 100
        //Customer CPA => 100!!! not changed as customer already campaign member
        CampaignMember testCM5 = new CampaignMember(
            CampaignId = testCamp2.Id,
            ContactId = testAcc2.PersonContactId
        );
        insert testCM5;
        //customer CPA will not updated as he is already campaign member
        List<Account> testA5 = [SELECT Id, Total_CPA__c FROM Account WHERE Id =:testAcc2.Id];
        System.assertEquals(100, testA5[0].Total_CPA__c);
    }

    @isTest static void test_cpa_bylistcustomers() {
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
        Campaign testCamp2 = new Campaign(
            Landing_Page__c = 'campaign_2_',
            Name = 'campaign_2_', Campaign__c = 'campaign_2_', //UTM_Campaign__c
            Ad_Platform__c = 'campaign_2_', //utm_source
            Buying_Type__c = 'campaign_2_', //utm_medium
            Ad_Type__c = 'campaign_2_', Content__c = 'campaign_2_', //UTM_Content__c
            Term__c = 'campaign_2_', //Term__c
            ParentId = testCamp1.Id,
            Total_Orders__c = 2,
            Total_Orders_Value__c = 2,
            Total_Customers_Value__c = 2,
            Campaign_Level__c = 1,
            Lead_CTL_Sum__c = 20,
            ActualCost = 200
        );
        insert testCamp2;
        Campaign_Cost__c testCC2 = new Campaign_Cost__c(
            Campaign__c = testCamp2.Id,
            Cost__c = 200
        );
        insert testCC2;
        Campaign testCamp3 = new Campaign(
            Landing_Page__c = 'campaign_3_',
            Name = 'campaign_3_', Campaign__c = 'campaign_3_', //UTM_Campaign__c
            Ad_Platform__c = 'campaign_3_', //utm_source
            Buying_Type__c = 'campaign_3_', //utm_medium
            Ad_Type__c = 'campaign_3_', Content__c = 'campaign_3_', //UTM_Content__c
            Term__c = 'campaign_3_', //Term__c
            ParentId = testCamp2.Id,
            Total_Orders__c = 3,
            Total_Orders_Value__c = 3,
            Total_Customers_Value__c = 3,
            Campaign_Level__c = 2,
            Lead_CTL_Sum__c = 30,
            ActualCost = 300
        );
        insert testCamp3;
        Campaign_Cost__c testCC3 = new Campaign_Cost__c(
            Campaign__c = testCamp3.Id,
            Cost__c = 300
        );
        insert testCC3;

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
        Account testAcc2 = new Account(
            FirstName = 'jane2',
            LastName = 'doe2',
            RecordTypeId = paRt[0].Id,
            utm_source__c = 'test2',
            utm_medium__c = 'test2',
            utm_campaign__c = 'test2test2',
            utm_content__c = 'test2',
            utm_term__c = 'test2test2'
        );
        insert testAcc2;
        testAcc2 = [SELECT Id, Total_CPA__c, PersonContactId FROM Account WHERE Id = :testAcc2.Id LIMIT 1];

        //MEMBERS
        //Camp#3 + Customer#1
        CampaignMember testCM0 = new CampaignMember(
            CampaignId = testCamp3.Id,
            ContactId = testAcc1.PersonContactId
        );
        insert testCM0;

        //Camp#1,Camp#2,Camp#3 + Customer#2
        List<CampaignMember> cmList = new List<CampaignMember>();
        CampaignMember testCM1 = new CampaignMember(
            CampaignId = testCamp1.Id,
            ContactId = testAcc2.PersonContactId
        );
        cmList.add(testCM1);
        CampaignMember testCM2 = new CampaignMember(
            CampaignId = testCamp2.Id,
            ContactId = testAcc2.PersonContactId
        );
        cmList.add(testCM2);
        CampaignMember testCM3 = new CampaignMember(
            CampaignId = testCamp3.Id,
            ContactId = testAcc2.PersonContactId
        );
        cmList.add(testCM3);
        insert cmList;

        List<Campaign> testC1 = [SELECT Id, ActualCost, Total_CPA__c FROM Campaign WHERE Id =:testCamp1.Id];
        System.assertEquals(100, testC1[0].Total_CPA__c);
        List<Campaign> testC2 = [SELECT Id, ActualCost, Total_CPA__c FROM Campaign WHERE Id =:testCamp2.Id];
        System.assertEquals(200, testC2[0].Total_CPA__c);
        //campaign#3 has 2 customers so 300 / 2
        List<Campaign> testC3 = [SELECT Id, ActualCost, Total_CPA__c FROM Campaign WHERE Id =:testCamp3.Id];
        System.assertEquals(150, testC3[0].Total_CPA__c);

        //1st customer cpa = null
        List<Account> testA1 = [SELECT Id, Total_CPA__c FROM Account WHERE Id =:testAcc1.Id];
        System.assertEquals(null, testA1[0].Total_CPA__c);
        //2nd customer only counted in last 3rd campaign membership
        List<Account> testA2 = [SELECT Id, Total_CPA__c FROM Account WHERE Id =:testAcc2.Id];
        System.assertEquals(300, testA2[0].Total_CPA__c);
    }
}