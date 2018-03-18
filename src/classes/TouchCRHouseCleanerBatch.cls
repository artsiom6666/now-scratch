public with sharing class TouchCRHouseCleanerBatch implements Database.Batchable<sObject>, Database.Stateful {

	String query;
	String objectApiName;

	Boolean isFailedConfig;

	public TouchCRHouseCleanerBatch() {
		this.isFailedConfig = false;
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		Map<String, String> hcSettings = TouchCRHelper.getSettings('HouseCleaner.');

		try{
			if (!hcSettings.containsKey('HouseCleaner.RecordAge') || !hcSettings.containsKey('HouseCleaner.ObjectApiName')) {
				throw new houseCleanerException('HouseCleaner settings does not specified');
			}
			else {
				this.objectApiName = hcSettings.get('HouseCleaner.ObjectApiName');
				if (Schema.getGlobalDescribe().get(this.objectApiName) == null) {
					throw new houseCleanerException('Invalid Object Type');
				}
				Integer age = Integer.valueOf(hcSettings.get('HouseCleaner.RecordAge'));
			}
		}
		catch(Exception ex) {
			this.isFailedConfig = true;
			query = 'SELECT Id FROM Log__c LIMIT 1';

			Log__c log = new Log__c();
			log.Event_Status__c = 'ERROR';
			log.Event_Type__c = 'HouseCleaner Batch';
			log.Event_Description__c = 'HouseCleaner settings error.';
			if (Log__c.Event_Type__c.getDescribe().isCreateable() &&
				Log__c.Event_Description__c.getDescribe().isCreateable() &&
				Log__c.Event_Status__c.getDescribe().isCreateable() ) {
				insert log;
			}
			return Database.getQueryLocator(query);
		}


		this.objectApiName = hcSettings.get('HouseCleaner.ObjectApiName');
		String recordAge = hcSettings.get('HouseCleaner.RecordAge');
		Integer age = Integer.valueOf(recordAge);

		Datetime now = Datetime.now();
		now = now.addDays(-age);

		this.query = 'SELECT Id FROM ' + this.objectApiName + ' WHERE CreatedDate <= :now';

		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		if (isFailedConfig) {
			return;
		}

		try {
			if (Schema.getGlobalDescribe().get(this.objectApiName).getDescribe().isDeletable()) {
				delete scope;
			}
			else {
				throw new houseCleanerException('Privileges Exception');
			}
		}
		catch(Exception ex) {
			Log__c log = new Log__c();
			log.Event_Status__c = 'ERROR';
			log.Event_Type__c = 'HouseCleaner Batch';
			log.Event_Description__c = 'Privileges Exception';
			if (Log__c.Event_Type__c.getDescribe().isCreateable() &&
				Log__c.Event_Description__c.getDescribe().isCreateable() &&
				Log__c.Event_Status__c.getDescribe().isCreateable() ) {
				insert log;
			}
		}
	}

	public void finish(Database.BatchableContext BC) {

		Map<String, String> batchSettings = TouchCRHelper.getSettings('Batch.');

		String selectedStateHouseCleaner = batchSettings.get('Batch.HouseCleanerState');
		String selectedExecuteHouseCleaner = batchSettings.get('Batch.HouseCleanerTime');
		String selectedExecuteHouseCleanerDay = batchSettings.get('Batch.HouseCleanerDay');

		List<CronTrigger> hcJob = [SELECT Id, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name = 'HouseCleaner'];
		String nextfiretime = !hcJob.isEmpty() ? String.valueOf( hcJob[0].NextFireTime ) : null;

		String cronStr = '0 0 ' + selectedExecuteHouseCleaner + ' 1/' + selectedExecuteHouseCleanerDay + ' * ? *';

		if (selectedStateHouseCleaner == 'On' && String.isBlank(nextfiretime)) {
			List<CronTrigger> jobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'HouseCleaner'];
			String jobId = (jobs.isEmpty()) ? null : jobs.get(0).Id;
			if (!String.isBlank(jobId)) {
				System.abortJob(jobId);
			}

			System.schedule('HouseCleaner' , cronStr, new TouchCRHouseCleanerBatchScheduler());
		}
	}

	public class houseCleanerException extends Exception {}
}