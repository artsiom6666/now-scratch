public with sharing class ScoreCalculationScheduler implements Schedulable {
	public void execute(SchedulableContext sc) {
		List<AsyncApexJob> jobs = [
			SELECT Id, Status, ApexClassId, ApexClass.Name
			FROM AsyncApexJob
			WHERE ApexClass.Name IN : TouchCRConfigurationController.NAME_TO_CLASSES.get('ScoreCalculation')
			AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
		];
		if (jobs.isEmpty()) {
			ScoreCalculationCounterBatch b = new ScoreCalculationCounterBatch();
			database.executebatch(b, 2000);
		}
	}
}