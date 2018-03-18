public with sharing class DataAppendScheduler implements Schedulable {
	public void execute(SchedulableContext sc) {

		List<AsyncApexJob> jobs = [
			SELECT Id, Status, ApexClassId, ApexClass.Name
			FROM AsyncApexJob
			WHERE ApexClass.Name IN : TouchCRConfigurationController.NAME_TO_CLASSES.get('DataAppend')
			AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
		];

		if (jobs.isEmpty()) {
			DataAppendBatch job = new DataAppendBatch(1);
			database.executebatch(job, 1);
		}
	}
}