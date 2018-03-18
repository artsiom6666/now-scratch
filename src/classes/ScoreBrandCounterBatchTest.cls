@isTest
private class ScoreBrandCounterBatchTest {

    @isTest static void test_activebrands() {
        List<String> brandTest = new List<String> {'brand1', 'brand2'};
        TouchCRConfigurationController.setActiveBrandsTest(new Set<String>(brandTest));

        Integer numRepeats = 100;
        List<Account> testObjList = new List<Account>();
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        for (Integer idx = 1; idx <= numRepeats; idx++) {
            Account testObj = new Account(
                RecordTypeId = customerRecordType.Id,
                FirstName = 'John' + idx,
                LastName = 'Doe' + idx,
                PersonEmail = 'John.doe@example' + idx + '.com',
                Brand_Assortment__c = (Math.mod(idx, 2) == 0) ? brandTest[0] : brandTest[1]
            );
            testObjList.add(testObj);
        }
        insert testObjList;
        List<Order__c> orders = new List<Order__c>();
        for (Account acc : testObjList) {
            orders.add(new Order__c(Account__c = acc.Id));
        }
        insert orders;

        Test.startTest();
            ScoreBrandCounterBatch b = new ScoreBrandCounterBatch(new Set<String>());
            Id batchInstanceId = Database.executebatch(b, 100);
        Test.stopTest();
        List<AsyncApexJob> aaj = [SELECT Id, JobItemsProcessed FROM AsyncApexJob WHERE Id = :batchInstanceId];
        System.assertEquals(1, aaj.size());
        System.assertEquals(1, aaj[0].JobItemsProcessed);
    }

    @isTest static void test_noactivebrands() {
        List<String> brandTest = new List<String> {'brand1', 'brand2'};
        TouchCRConfigurationController.setActiveBrandsTest(new Set<String>());
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        Integer numRepeats = 100;
        List<Account> testObjList = new List<Account>();
        for (Integer idx = 1; idx <= numRepeats; idx++) {
            Account testObj = new Account(
                RecordTypeId = customerRecordType.Id,
                FirstName = 'John' + idx,
                LastName = 'Doe' + idx,
                PersonEmail = 'John.doe@example' + idx + '.com',
                Brand_Assortment__c = (Math.mod(idx, 2) == 0) ? brandTest[0] : brandTest[1]
            );
            testObjList.add(testObj);
        }
        insert testObjList;

        Test.startTest();
            ScoreBrandCounterBatch b = new ScoreBrandCounterBatch(new Set<String>());
            Id batchInstanceId = Database.executebatch(b, 100);
        Test.stopTest();
        List<AsyncApexJob> aaj = [SELECT Id, JobItemsProcessed FROM AsyncApexJob WHERE Id = :batchInstanceId];

        system.debug(aaj);

        System.assertEquals(1, aaj.size());
        System.assertEquals(0, aaj[0].JobItemsProcessed);
    }

    @isTest static void test_scheduler() {
        TouchCR_Settings__c settingRFMScoreBrandStatus = new TouchCR_Settings__c();
        settingRFMScoreBrandStatus.Name = 'Batch.RFMScoreBrandStatus';
        settingRFMScoreBrandStatus.Value__c = 'On';

        TouchCR_Settings__c settingRFMScoreBrandTime = new TouchCR_Settings__c();
        settingRFMScoreBrandTime.Name = 'Batch.RFMScoreBrandTime';
        settingRFMScoreBrandTime.Value__c = '1';

        TouchCR_Settings__c settingRFMScoreBrandDay = new TouchCR_Settings__c();
        settingRFMScoreBrandDay.Name = 'Batch.RFMScoreBrandDay';
        settingRFMScoreBrandDay.Value__c = '1';
        insert new List<TouchCR_Settings__c>{settingRFMScoreBrandStatus, settingRFMScoreBrandTime, settingRFMScoreBrandDay};

        Test.startTest();
            ScoreBrandCounterBatch b = new ScoreBrandCounterBatch(new Set<String>());
            Id batchInstanceId = Database.executebatch(b, 100);
        Test.stopTest();
        List<CronTrigger> scheduleInProgress = [SELECT Id, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name =: 'ScoreBrandCounter'];
        System.assertEquals(1, scheduleInProgress.size());
    }
}