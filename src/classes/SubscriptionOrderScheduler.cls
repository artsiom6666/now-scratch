public with sharing class SubscriptionOrderScheduler implements Schedulable {
	public void execute(SchedulableContext sc) {
		List<AsyncApexJob> jobs = [
			SELECT Id, Status, ApexClassId, ApexClass.Name
			FROM AsyncApexJob
			WHERE ApexClass.Name IN : TouchCRConfigurationController.NAME_TO_CLASSES.get('SubscriptionOrder')
			AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
		];
		if (jobs.isEmpty()) {
			SubscriptionOrderBatch job = new SubscriptionOrderBatch();
			Database.executeBatch(job, 200);
		}
	}
}