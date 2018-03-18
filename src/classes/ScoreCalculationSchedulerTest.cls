@isTest
private class ScoreCalculationSchedulerTest {

    @isTest static void test_ScoreCalculationScheduler() {
        Test.startTest();
            ScoreCalculationScheduler sc = new ScoreCalculationScheduler();
            String sch = Datetime.now().addMinutes(1).format('s m H d M ? yyyy');
            System.schedule('ScoreCalculationScheduler', sch, sc);
        Test.stopTest();

        List<CronTrigger> crn = [SELECT Id
            FROM CronTrigger
            WHERE CronJobDetail.Name = 'ScoreCalculationScheduler'
        ];

        List<AsyncApexJob> aaj = [SELECT Id
            FROM AsyncApexJob
            WHERE ApexClass.Name IN ('ScoreCalculationCounterBatch')
            AND JobType = 'BatchApex'
            AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
        ];

        System.assertEquals(1, crn.size());
        System.assertEquals(1, aaj.size());
    }

}