@isTest
private class SubscriptionOrderSchedulerTest {

    @isTest static void test_method_one() {
        Test.startTest();
            SubscriptionOrderScheduler so = new SubscriptionOrderScheduler ();
            String sch = Datetime.now().addMinutes(1).format('s m H d M ? yyyy');
            System.schedule('SubscriptionOrderScheduler', sch, so);
        Test.stopTest();

        List<CronTrigger> crn = [SELECT Id
            FROM CronTrigger
            WHERE CronJobDetail.Name = 'SubscriptionOrderScheduler'
        ];

        List<AsyncApexJob> aaj = [SELECT Id
            FROM AsyncApexJob
            WHERE ApexClass.Name IN ('SubscriptionOrderBatch')
            AND JobType = 'BatchApex'
            AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
        ];

        System.assertEquals(1, crn.size());
        System.assertEquals(1, aaj.size());
    }
}