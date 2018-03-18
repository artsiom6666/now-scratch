@isTest
private class CampaignHierarchySummaryBatchTest {

    @isTest static void test_hierarchyvalues() {
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
            Lead_CTL_Sum__c = 10
        );
        insert testCamp1;
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
            Lead_CTL_Sum__c = 20
        );
        insert testCamp2;
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
            Lead_CTL_Sum__c = 30
        );
        insert testCamp3;
        Test.startTest();
            CampaignHierarchySummaryBatch job = new CampaignHierarchySummaryBatch(2);
            Database.executeBatch(job);
        Test.stopTest();

        List<Campaign> testCampaign1 = [
            SELECT Total_Orders_Hierarchy__c, Total_Orders_Value_Hierarchy__c, Total_Customers_Value_Hierarchy__c, ParentId,
                Lead_CTL_Sum_Hierarchy__c
            FROM Campaign
            WHERE Id = :testCamp1.Id
        ];
        System.assertEquals(1, testCampaign1.size());
        System.assertEquals(6, testCampaign1[0].Total_Orders_Hierarchy__c);
        System.assertEquals(6, testCampaign1[0].Total_Orders_Value_Hierarchy__c);
        System.assertEquals(6, testCampaign1[0].Total_Customers_Value_Hierarchy__c);
        System.assertEquals(60, testCampaign1[0].Lead_CTL_Sum_Hierarchy__c);

        List<Campaign> testCampaign2 = [
            SELECT Total_Orders_Hierarchy__c, Total_Orders_Value_Hierarchy__c, Total_Customers_Value_Hierarchy__c, ParentId,
                Lead_CTL_Sum_Hierarchy__c
            FROM Campaign
            WHERE Id = :testCamp2.Id
        ];
        System.assertEquals(1, testCampaign2.size());
        System.assertEquals(5, testCampaign2[0].Total_Orders_Hierarchy__c);
        System.assertEquals(5, testCampaign2[0].Total_Orders_Value_Hierarchy__c);
        System.assertEquals(5, testCampaign2[0].Total_Customers_Value_Hierarchy__c);
        System.assertEquals(50, testCampaign2[0].Lead_CTL_Sum_Hierarchy__c);

        List<Campaign> testCampaign3 = [
            SELECT Total_Orders_Hierarchy__c, Total_Orders_Value_Hierarchy__c, Total_Customers_Value_Hierarchy__c, ParentId,
                Lead_CTL_Sum_Hierarchy__c
            FROM Campaign
            WHERE Id = :testCamp3.Id
        ];
        System.assertEquals(1, testCampaign3.size());
        System.assertEquals(3, testCampaign3[0].Total_Orders_Hierarchy__c);
        System.assertEquals(3, testCampaign3[0].Total_Orders_Value_Hierarchy__c);
        System.assertEquals(3, testCampaign3[0].Total_Customers_Value_Hierarchy__c);
        System.assertEquals(30, testCampaign3[0].Lead_CTL_Sum_Hierarchy__c);
    }

    @isTest static void test_hierarchyvalues_bulk() {
        Integer numRepeats = 2;
        Integer start = 1;
        List<Campaign> campaigns0 = new List<Campaign>();
        //campaign level 0
        for (Integer idx = start; idx <= numRepeats; idx++) {
            Campaign testCamp0 = new Campaign(
                Landing_Page__c = 'campaign_0_' + idx,
                Name = 'campaign_0_' + idx, Campaign__c = 'campaign_0_' + idx, //UTM_Campaign__c
                Ad_Platform__c = 'campaign_0_' + idx, //utm_source
                Buying_Type__c = 'campaign_0_' + idx, //utm_medium
                Ad_Type__c = 'campaign_0_' + idx, Content__c = 'campaign_0_' + idx, //UTM_Content__c
                Term__c = 'campaign_0_' + idx, //Term__c
                Total_Orders__c = 1,
                Total_Orders_Value__c = 1,
                Total_Customers_Value__c = 1,
                Campaign_Level__c = 0,
                Lead_CTL_Sum__c = 10
            );
            campaigns0.add(testCamp0);
        }
        insert campaigns0;
        //campaigns level 1
        //each campaign lvl0 gets numRepeats child campaigns
        List<Campaign> campaigns1 = new List<Campaign>();
        for (Campaign parentCampaign : campaigns0) {
            //campaign level 1
            for (Integer idx = start; idx <= numRepeats; idx++) {
                Campaign testCamp1 = new Campaign(
                    Landing_Page__c = parentCampaign.Name + idx,
                    Name = parentCampaign.Name + idx, Campaign__c = parentCampaign.Name + idx, //UTM_Campaign__c
                    Ad_Platform__c = parentCampaign.Name + idx, //utm_source
                    Buying_Type__c = parentCampaign.Name + idx, //utm_medium
                    Ad_Type__c = parentCampaign.Name + idx, Content__c = parentCampaign.Name + idx, //UTM_Content__c
                    Term__c = parentCampaign.Name + idx, //Term__c
                    Total_Orders__c = 2,
                    Total_Orders_Value__c = 2,
                    Total_Customers_Value__c = 2,
                    ParentId = parentCampaign.Id,
                    Campaign_Level__c = 1,
                    Lead_CTL_Sum__c = 20
                );
                campaigns1.add(testCamp1);
            }
        }
        insert campaigns1;
        //campaigns level 2
        //each campaign lvl1 gets numRepeats child campaigns
        List<Campaign> campaigns2 = new List<Campaign>();
        for (Campaign parentCampaign : campaigns1) {
            //campaign level 2
            for (Integer idx = start; idx <= numRepeats; idx++) {
                Campaign testCamp2 = new Campaign(
                    Landing_Page__c = parentCampaign.Name + idx,
                    Name = parentCampaign.Name + idx, Campaign__c = parentCampaign.Name + idx, //UTM_Campaign__c
                    Ad_Platform__c = parentCampaign.Name + idx, //utm_source
                    Buying_Type__c = parentCampaign.Name + idx, //utm_medium
                    Ad_Type__c = parentCampaign.Name + idx, Content__c = parentCampaign.Name + idx, //UTM_Content__c
                    Term__c = parentCampaign.Name + idx, //Term__c
                    Total_Orders__c = 3,
                    Total_Orders_Value__c = 3,
                    Total_Customers_Value__c = 3,
                    ParentId = parentCampaign.Id,
                    Campaign_Level__c = 2,
                    Lead_CTL_Sum__c = 30
                );
                campaigns2.add(testCamp2);
            }
        }
        insert campaigns2;

        Test.startTest();
            CampaignHierarchySummaryBatch job = new CampaignHierarchySummaryBatch(2);
            Database.executeBatch(job);
        Test.stopTest();

        List<Campaign> testCampaign0 = [
            SELECT Campaign_Level__c,Total_Orders_Hierarchy__c, Total_Orders_Value_Hierarchy__c, Total_Customers_Value_Hierarchy__c,
                Lead_CTL_Sum_Hierarchy__c
            FROM Campaign
            WHERE Id IN :campaigns0
        ];
        System.assertEquals(numRepeats, testCampaign0.size());
        for (Campaign aCampaign : testCampaign0) {
            System.assertEquals(0, aCampaign.Campaign_Level__c);
            System.assertEquals(17, aCampaign.Total_Orders_Hierarchy__c);
            System.assertEquals(17, aCampaign.Total_Orders_Value_Hierarchy__c);
            System.assertEquals(17, aCampaign.Total_Customers_Value_Hierarchy__c);
            System.assertEquals(170, aCampaign.Lead_CTL_Sum_Hierarchy__c);
        }

        List<Campaign> testCampaign1 = [
            SELECT Campaign_Level__c,Total_Orders_Hierarchy__c, Total_Orders_Value_Hierarchy__c, Total_Customers_Value_Hierarchy__c,
                Lead_CTL_Sum_Hierarchy__c
            FROM Campaign
            WHERE Id IN :campaigns1
        ];
        System.assertEquals(4, testCampaign1.size());
        for (Campaign aCampaign : testCampaign1) {
            System.assertEquals(1, aCampaign.Campaign_Level__c);
            System.assertEquals(8, aCampaign.Total_Orders_Hierarchy__c);
            System.assertEquals(8, aCampaign.Total_Orders_Value_Hierarchy__c);
            System.assertEquals(8, aCampaign.Total_Customers_Value_Hierarchy__c);
            System.assertEquals(80, aCampaign.Lead_CTL_Sum_Hierarchy__c);
        }

        List<Campaign> testCampaign2 = [
            SELECT Campaign_Level__c,Total_Orders_Hierarchy__c, Total_Orders_Value_Hierarchy__c, Total_Customers_Value_Hierarchy__c,
                Lead_CTL_Sum_Hierarchy__c
            FROM Campaign
            WHERE Id IN :campaigns2
        ];
        System.assertEquals(8, testCampaign2.size());
        for (Campaign aCampaign : testCampaign2) {
            System.assertEquals(2, aCampaign.Campaign_Level__c);
            System.assertEquals(3, aCampaign.Total_Orders_Hierarchy__c);
            System.assertEquals(3, aCampaign.Total_Orders_Value_Hierarchy__c);
            System.assertEquals(3, aCampaign.Total_Customers_Value_Hierarchy__c);
            System.assertEquals(30, aCampaign.Lead_CTL_Sum_Hierarchy__c);
        }
    }

    @isTest static void test_schedulersettings() {
        TouchCR_Settings__c settingCampaignMemberStatus = new TouchCR_Settings__c();
        settingCampaignMemberStatus.Name = 'Batch.CampaignMemberStatus';
        settingCampaignMemberStatus.Value__c = 'On';

        TouchCR_Settings__c settingCampaignMemberDay = new TouchCR_Settings__c();
        settingCampaignMemberDay.Name = 'Batch.CampaignMemberDay';
        settingCampaignMemberDay.Value__c = '1';

        TouchCR_Settings__c settingCampaignMemberTime = new TouchCR_Settings__c();
        settingCampaignMemberTime.Name = 'Batch.CampaignMemberTime';
        settingCampaignMemberTime.Value__c = '1';

        insert new List<TouchCR_Settings__c>{settingCampaignMemberStatus, settingCampaignMemberDay, settingCampaignMemberTime};

        Test.startTest();

            CampaignHierarchySummaryBatch job = new CampaignHierarchySummaryBatch(2);
            Database.executeBatch(job);

        Test.stopTest();

        List<CronTrigger> scheduleInProgress = [
            SELECT Id, NextFireTime, CronExpression, TimesTriggered
            FROM CronTrigger
            WHERE CronJobDetail.Name =: 'CampaignMember'
            LIMIT 1
        ];

        String NEXT_CRON_STR = '0 0 1 1/1 * ? *';
        System.assertEquals(NEXT_CRON_STR, scheduleInProgress.get(0).CronExpression);
        System.assertEquals(0, scheduleInProgress.get(0).TimesTriggered);
    }

}