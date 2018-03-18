public with sharing class ScoreBrandCounterScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        List<AsyncApexJob> jobs = [
            SELECT Id, Status, ApexClassId, ApexClass.Name
            FROM AsyncApexJob
            WHERE ApexClass.Name IN : TouchCRConfigurationController.NAME_TO_CLASSES.get('ScoreBrandCounter')
            AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
        ];
        if (jobs.isEmpty()) {
            //execute counter with empty previous processed brands
            ScoreBrandCounterBatch b = new ScoreBrandCounterBatch(new Set<String>());
            database.executebatch(b, 2000);
        }
    }
}