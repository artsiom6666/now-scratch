@isTest
private class CampaignMemberSchedulerTest {

    @isTest static void test_method_one() {
        Test.startTest();
            CampaignMemberScheduler sc = new CampaignMemberScheduler();
            String sch = Datetime.now().addMinutes(1).format('s m H d M ? yyyy');
            System.schedule('CampaignMemberScheduler', sch, sc);
        Test.stopTest();

        List<CronTrigger> crn = [SELECT Id
            FROM CronTrigger
            WHERE CronJobDetail.Name = 'CampaignMemberScheduler'
        ];

        List<AsyncApexJob> aaj = [SELECT Id
            FROM AsyncApexJob
            WHERE ApexClass.Name IN ('CampaignMemberBatch')
            AND JobType = 'BatchApex'
            AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
        ];

        System.assertEquals(1, crn.size());
        System.assertEquals(1, aaj.size());
    }
}