@isTest
private class CampaignHierarchyBatchTest {

    @isTest static void test_hierarchylevels() {
        Campaign testCamp1 = new Campaign(
            Landing_Page__c = 'campaign_1_',
            Name = 'campaign_1_', Campaign__c = 'campaign_1_', //UTM_Campaign__c
            Ad_Platform__c = 'campaign_1_', //utm_source
            Buying_Type__c = 'campaign_1_', //utm_medium
            Ad_Type__c = 'campaign_1_', Content__c = 'campaign_1_', //UTM_Content__c
            Term__c = 'campaign_1_', //Term__c
            Total_Orders__c = 1,
            Total_Orders_Value__c = 1,
            Total_Customers_Value__c = 1
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
            Total_Customers_Value__c = 2
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
            Total_Customers_Value__c = 3
        );
        insert testCamp3;
        Test.startTest();
            CampaignHierarchyBatch job = new CampaignHierarchyBatch(0);
            Database.executeBatch(job);
        Test.stopTest();

        List<Campaign> testCampaign1 = [
            SELECT Campaign_Level__c
            FROM Campaign
            WHERE Id = :testCamp1.Id
        ];
        System.assertEquals(1, testCampaign1.size());
        System.assertEquals(0, testCampaign1[0].Campaign_Level__c);

        List<Campaign> testCampaign2 = [
            SELECT Campaign_Level__c
            FROM Campaign
            WHERE Id = :testCamp2.Id
        ];
        System.assertEquals(1, testCampaign2.size());
        System.assertEquals(1, testCampaign2[0].Campaign_Level__c);

        List<Campaign> testCampaign3 = [
            SELECT Campaign_Level__c
            FROM Campaign
            WHERE Id = :testCamp3.Id
        ];
        System.assertEquals(1, testCampaign3.size());
        System.assertEquals(2, testCampaign3[0].Campaign_Level__c);
    }

    @isTest static void test_hierarchylevels_bulk() {
        Integer numRepeats = 5;
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
                Total_Customers_Value__c = 1
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
                    Total_Orders__c = 1,
                    Total_Orders_Value__c = 1,
                    Total_Customers_Value__c = 1,
                    ParentId = parentCampaign.Id
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
                    Total_Orders__c = 1,
                    Total_Orders_Value__c = 1,
                    Total_Customers_Value__c = 1,
                    ParentId = parentCampaign.Id
                );
                campaigns2.add(testCamp2);
            }
        }
        insert campaigns2;

        Test.startTest();
            CampaignHierarchyBatch job = new CampaignHierarchyBatch(0);
            Database.executeBatch(job);
        Test.stopTest();

        List<Campaign> testCampaign0 = [
            SELECT Campaign_Level__c
            FROM Campaign
            WHERE Id IN :campaigns0
        ];
        System.assertEquals(5, testCampaign0.size());
        for (Campaign aCampaign : testCampaign0) {
            System.assertEquals(0, aCampaign.Campaign_Level__c);
        }

        List<Campaign> testCampaign1 = [
            SELECT Campaign_Level__c
            FROM Campaign
            WHERE Id IN :campaigns1
        ];
        System.assertEquals(25, testCampaign1.size());
        for (Campaign aCampaign : testCampaign1) {
            System.assertEquals(1, aCampaign.Campaign_Level__c);
        }

        List<Campaign> testCampaign2 = [
            SELECT Campaign_Level__c
            FROM Campaign
            WHERE Id IN :campaigns2
        ];
        System.assertEquals(125, testCampaign2.size());
        for (Campaign aCampaign : testCampaign2) {
            System.assertEquals(2, aCampaign.Campaign_Level__c);
        }
    }

}