@isTest
private class TouchCRHouseCleanerBatchTest {
	
	@isTest static void testDeleteOldData() {

		Account acc = new Account(Name = 'test');
		insert acc;

		DateTime oldDate = DateTime.now().addYears(-1);
		Test.setCreatedDate(acc.Id, oldDate);

		Map<String, String> setting = new Map<String, String>();
		setting.put('HouseCleaner.RecordAge', '3');
		setting.put('HouseCleaner.ObjectApiName', 'Account');
		TouchCRHelper.setSettings(setting);
		
		DateTime now = Datetime.now().addHours(1);
		String year = String.valueOf( now.year() );
		String month = String.valueOf( now.month() );
		String day = String.valueOf( now.day() );
		String hour = String.valueOf( now.hour() );
		String minute = String.valueOf( now.minute() );
		String sec = String.valueOf( now.second() );
		
		String sch = sec + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ' + '?' + ' ' + year;

		List<CronTrigger> jobs = [SELECT Id	FROM CronTrigger WHERE CronJobDetail.Name = 'HouseCleaner'];
		String jobId = (jobs.isEmpty()) ? null : jobs.get(0).Id;		
		if (!String.isBlank(jobId)) {
			System.abortJob(jobId);
		}

		Test.startTest();
		System.schedule('HouseCleaner', sch, new TouchCRHouseCleanerBatchScheduler());
		Database.executeBatch(new TouchCRHouseCleanerBatch());
		Test.stopTest();

		List<Account> accList = [SELECT Id FROM Account LIMIT 10];
		System.assertEquals(accList.isEmpty(), true);
	}

	@isTest static void testMissedSettings() {

		Account acc = new Account(Name = 'test');
		insert acc;

		DateTime oldDate = DateTime.now().addYears(-1);
		Test.setCreatedDate(acc.Id, oldDate);

		Test.startTest();
		Database.executeBatch(new TouchCRHouseCleanerBatch());
		Test.stopTest();

		List<Account> accList = [SELECT Id FROM Account LIMIT 10];
		System.assertEquals(accList.isEmpty(), false);
	}

	@isTest static void testInvalidObject() {

		Account acc = new Account(Name = 'test');
		insert acc;

		DateTime oldDate = DateTime.now().addYears(-1);
		Test.setCreatedDate(acc.Id, oldDate);

		Map<String, String> setting = new Map<String, String>();
		setting.put('HouseCleaner.RecordAge', '3');
		setting.put('HouseCleaner.ObjectApiName', 'invalidTestObjectAPIName');
		TouchCRHelper.setSettings(setting);

		Test.startTest();
		Database.executeBatch(new TouchCRHouseCleanerBatch());
		Test.stopTest();

		List<Account> accList = [SELECT Id FROM Account LIMIT 10];
		System.assertEquals(accList.isEmpty(), false);
	}

	@isTest static void testInvalidAge() {

		Account acc = new Account(Name = 'test');
		insert acc;

		DateTime oldDate = DateTime.now().addYears(-1);
		Test.setCreatedDate(acc.Id, oldDate);

		Map<String, String> setting = new Map<String, String>();
		setting.put('HouseCleaner.RecordAge', 'z');
		setting.put('HouseCleaner.ObjectApiName', 'Account');
		TouchCRHelper.setSettings(setting);

		Test.startTest();
		Database.executeBatch(new TouchCRHouseCleanerBatch());
		Test.stopTest();

		List<Account> accList = [SELECT Id FROM Account LIMIT 10];
		System.assertEquals(accList.isEmpty(), false);
	}

	@isTest static void testInvalidUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Read Only']; 
		User u = new User(Alias = 'readon', Email='readonly@testorg.com', 
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, 
		TimeZoneSidKey='America/Los_Angeles', UserName='readonly@testorg.com');

		Account acc = new Account(Name = 'test');
		insert acc;

		DateTime oldDate = DateTime.now().addYears(-1);
		Test.setCreatedDate(acc.Id, oldDate);

		Map<String, String> setting = new Map<String, String>();
		setting.put('HouseCleaner.RecordAge', '3');
		setting.put('HouseCleaner.ObjectApiName', 'Account');
		TouchCRHelper.setSettings(setting);

		System.runAs(u) {
			Test.startTest();
			Database.executeBatch(new TouchCRHouseCleanerBatch());
			Test.stopTest();
		}

		List<Account> accList = [SELECT Id FROM Account LIMIT 10];
		System.assertEquals(accList.isEmpty(), false);
	}
}