@isTest
private class ScoreBrandCounterSchedulerTest {

    @isTest static void test_ScoreBrandCounterScheduler() {
        Test.startTest();
            ScoreBrandCounterScheduler sc = new ScoreBrandCounterScheduler();
            String sch = Datetime.now().addMinutes(1).format('s m H d M ? yyyy');
            System.schedule('ScoreBrandCounterScheduler', sch, sc);
        Test.stopTest();

        List<CronTrigger> crn = [SELECT Id
            FROM CronTrigger
            WHERE CronJobDetail.Name = 'ScoreBrandCounterScheduler'
        ];

        List<AsyncApexJob> aaj = [SELECT Id
            FROM AsyncApexJob
            WHERE ApexClass.Name IN ('ScoreBrandCounterBatch')
            AND JobType = 'BatchApex'
            AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
        ];

        System.assertEquals(1, crn.size());
        System.assertEquals(1, aaj.size());
    }

}