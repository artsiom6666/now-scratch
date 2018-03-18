public with sharing class TouchCRHouseCleanerBatchScheduler implements Schedulable {
	public void execute(SchedulableContext sc) {
		TouchCRHouseCleanerBatch b = new TouchCRHouseCleanerBatch();
		Database.executeBatch(b);
	}
}