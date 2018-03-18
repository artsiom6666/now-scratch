@isTest
private class CampaignTriggerTest {

    @isTest static void test_hashurlduplicatevalue() {
        Campaign testCamp1 = new Campaign(
            Landing_Page__c = 'test',
            Name = 'test', Campaign__c = 'test', //UTM_Campaign__c
            Ad_Platform__c = 'test', //utm_source
            Buying_Type__c = 'test', //utm_medium
            Ad_Type__c = 'test', Content__c = 'test', //UTM_Content__c
            Term__c = 'test' //Term__c
        );
        insert testCamp1;

        List<Campaign> testObj = [SELECT URL__c, UTM_Hash__c FROM Campaign];
        system.debug(testObj[0]);

        //assert 5 'test' because of default values in some fields
        //actual hash was 'test cpc test test bannerad test test'
        System.assertEquals('testtesttesttesttesttesttest', testObj[0].UTM_Hash__c);

        //actual url, default values
        //test?utm_campaign=testtest&utm_content=banneradtest&utm_medium=cpc&utm_source=test&utm_term=test
        PageReference pr = new PageReference(testObj[0].URL__c);
        System.assertEquals('testtest', pr.getParameters().get('utm_campaign'));
        System.assertEquals('testtest', pr.getParameters().get('utm_content'));
        System.assertEquals('test', pr.getParameters().get('utm_source'));
        System.assertEquals('test', pr.getParameters().get('utm_term'));

        Campaign testCamp2 = new Campaign(
            Landing_Page__c = 'test',
            Name = 'test', Campaign__c = 'test', //UTM_Campaign__c
            Ad_Platform__c = 'test', //utm_source
            Buying_Type__c = 'test', //utm_medium
            Ad_Type__c = 'test', Content__c = 'test', //UTM_Content__c
            Term__c = 'test' //Term__c
        );
        Database.SaveResult srList = Database.insert(testCamp2, false);
        //assert DUPLICATE_VALUE
        System.assertEquals(false, srList.isSuccess());
    }

    @isTest static void test_bulkcampaigns() {
        Integer start = 1;
        Integer numRepeats = 200;
        List<Campaign> testObjList = new List<Campaign>();
        //first batch 200
        for (Integer idx = start; idx <= numRepeats; idx++) {
            Campaign testObj = new Campaign(
                Name = 'test' + idx,
                Landing_Page__c = 'test' + idx,
                Ad_Platform__c = 'test' + idx,
                Content__c = 'test' + idx,
                Campaign__c = 'test' + idx,
                Term__c = 'test' + idx
            );
            testObjList.add(testObj);
        }
        //second batch 200, this will be duplicates
        for (Integer idx = start; idx <= numRepeats; idx++) {
            Campaign testObj = new Campaign(
                Name = 'test' + idx,
                Landing_Page__c = 'test' + idx,
                Ad_Platform__c = 'test' + idx,
                Content__c = 'test' + idx,
                Campaign__c = 'test' + idx,
                Term__c = 'test' + idx
            );
            testObjList.add(testObj);
        }

        List<Database.SaveResult> srList = Database.insert(testObjList, false);
        Integer successCount = 0;
        Integer errorCount = 0;
        //assert DUPLICATE_VALUE
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                successCount++;
            }
            else {
                errorCount++;
            }
        }
        System.assertEquals(400, srList.size());
        System.assertEquals(200, successCount);
        System.assertEquals(200, errorCount);
    }
}