@isTest
private class DataAppendSchedulerTest {

	@isTest static void test_scheduler() {
		Test.startTest();
			DataAppendScheduler sc = new DataAppendScheduler();
			String sch = Datetime.now().addMinutes(1).format('s m H d M ? yyyy');
			System.schedule('DataAppendScheduler', sch, sc);
		Test.stopTest();

		List<CronTrigger> crn = [SELECT Id
			FROM CronTrigger
			WHERE CronJobDetail.Name = 'DataAppendScheduler'
		];

		List<AsyncApexJob> aaj = [SELECT Id
			FROM AsyncApexJob
			WHERE ApexClass.Name IN ('DataAppendBatch')
			AND JobType = 'BatchApex'
			AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
		];

		System.assertEquals(1, crn.size());
		System.assertEquals(1, aaj.size());
	}

}