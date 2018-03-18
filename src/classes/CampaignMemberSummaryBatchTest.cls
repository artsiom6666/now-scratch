@isTest
private class CampaignMemberSummaryBatchTest {

    @isTest static void test_order() {
        Campaign testCamp = new Campaign(
            Landing_Page__c = 'test',
            Name = 'test', Campaign__c = 'test', //UTM_Campaign__c
            Ad_Platform__c = 'test', //utm_source
            Buying_Type__c = 'test', //utm_medium
            Ad_Type__c = 'test', Content__c = 'test', //UTM_Content__c
            Term__c = 'test' //Term__c
        );
        insert testCamp;

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

        Order__c testOrd1 = new Order__c(
            Account__c = testAcc.Id,
            Subtotal__c = 100,
            utm_source__c = 'test',
            utm_medium__c = 'test',
            utm_campaign__c = 'testtest',
            utm_content__c = 'test',
            utm_term__c = 'testtest',
            Campaign__c = testCamp.Id
        );
        insert testOrd1;

        Order__c testOrd2 = new Order__c(
            Account__c = testAcc.Id,
            Subtotal__c = 150,
            utm_source__c = 'test',
            utm_medium__c = 'test',
            utm_campaign__c = 'testtest',
            utm_content__c = 'test',
            utm_term__c = 'testtest',
            Campaign__c = testCamp.Id
        );
        insert testOrd2;

        Test.startTest();
            CampaignMemberSummaryBatch b = new CampaignMemberSummaryBatch(2);
            Database.executeBatch(b);
        Test.stopTest();

        List<Campaign> testCampaign = [SELECT Total_Orders_Value__c, Total_Orders__c FROM Campaign];

        System.assertEquals(250, testCampaign[0].Total_Orders_Value__c);
        System.assertEquals(2, testCampaign[0].Total_Orders__c);
    }

    @isTest static void test_customer() {
        Campaign testCamp = new Campaign(
            Landing_Page__c = 'test',
            Name = 'test', Campaign__c = 'test', //UTM_Campaign__c
            Ad_Platform__c = 'test', //utm_source
            Buying_Type__c = 'test', //utm_medium
            Ad_Type__c = 'test', Content__c = 'test', //UTM_Content__c
            Term__c = 'test' //Term__c
        );
        insert testCamp;

        List<RecordType> paRt = [SELECT Id FROM RecordType WHERE Name = 'Person Account' LIMIT 1];
        Account testAcc1 = new Account(
            FirstName = 'jane',
            LastName = 'doe',
            RecordTypeId = paRt[0].Id,
            utm_source__c = 'test',
            utm_medium__c = 'test',
            utm_campaign__c = 'testtest',
            utm_content__c = 'test',
            utm_term__c = 'testtest',
            Subtotal_From_Zero_Balance_Orders__c = 100,
            Lead_CTL__c = 5
        );
        insert testAcc1;

        Account testAcc2 = new Account(
            FirstName = 'john',
            LastName = 'doe',
            RecordTypeId = paRt[0].Id,
            utm_source__c = 'test',
            utm_medium__c = 'test',
            utm_campaign__c = 'testtest',
            utm_content__c = 'test',
            utm_term__c = 'testtest',
            Subtotal_From_Zero_Balance_Orders__c = 100,
            Lead_CTL__c = 10
        );
        insert testAcc2;

        List<Account> testAccList = [SELECT Id, PersonContactId, Subtotal_From_Zero_Balance_Orders__c FROM Account];

        CampaignMember testMember1 = new CampaignMember(
            ContactId = testAccList[0].PersonContactId,
            CampaignId = testCamp.Id
        );
        insert testMember1;

        CampaignMember testMember2 = new CampaignMember(
            ContactId = testAccList[1].PersonContactId,
            CampaignId = testCamp.Id
        );
        insert testMember2;

        Test.startTest();
            CampaignMemberSummaryBatch b = new CampaignMemberSummaryBatch(1);
            Database.executeBatch(b);
        Test.stopTest();

        List<Campaign> testCampaign = [SELECT Total_Customers_Value__c, Lead_CTL_Sum__c FROM Campaign];

        System.assertEquals(200, testCampaign[0].Total_Customers_Value__c);
        System.assertEquals(15, testCampaign[0].Lead_CTL_Sum__c);
    }
}