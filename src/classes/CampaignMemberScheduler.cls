public with sharing class CampaignMemberScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        List<AsyncApexJob> jobs = [
            SELECT Id, Status, ApexClassId, ApexClass.Name
            FROM AsyncApexJob
            WHERE ApexClass.Name IN : TouchCRConfigurationController.NAME_TO_CLASSES.get('CampaignMember')
            AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
        ];
        if (jobs.isEmpty()) {
            CampaignMemberBatch b = new CampaignMemberBatch(1);
            database.executebatch(b, 200);
        }
    }
}