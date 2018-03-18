public with sharing class DataAppendAccountListViewController {

	public List<Account> selectedAccount { get; set; }
	private List<Id> selectedId { get; set; }
	private ApexPages.StandardSetController standardController;
	private Map<String, TouchCR_Settings__c> allDataSettingsTD = TowerDataApiClient.selectAndDeleteSettings(DateTime.now());
	private Map<String, TouchCR_Settings__c> allDataSettingsFC = FullContactApiClient.selectAndDeleteSettings(DateTime.now());

	public DataAppendAccountListViewController (ApexPages.StandardSetController standardController) {
		this.standardController = standardController;
		this.selectedAccount = (List<Account>) standardController.getSelected();

		this.selectedId = new List<Id>();
		for (Account acc : selectedAccount) {
			this.selectedId.add(acc.Id);
		}

		//check TowerData Limits
		Integer totalRecordsTD = 0;
		//Records processed in 24 hours
		for (TouchCR_Settings__c item : allDataSettingsTD.values()) {
			if (item.Name.contains(TouchCRConfigurationController.DATAAPPEND_DATE_SETTINGS_PREFIX)) {
				totalRecordsTD = totalRecordsTD + Integer.valueOf(item.Value__c);
			}
		}
		Integer limitRecordsTD = TowerDataApiClient.getLimits(allDataSettingsTD);
		Boolean approvedTD = TowerDataApiClient.isApproved(allDataSettingsTD);

		//check FullContact Limits
		Integer totalRecordsFC = 0;
		//Records processed in 24 hours
		for (TouchCR_Settings__c item : allDataSettingsFC.values()) {
			if (item.Name.contains(TouchCRConfigurationController.FULLCONTACT_DATE_SETTINGS_PREFIX)) {
				totalRecordsFC = totalRecordsFC + Integer.valueOf(item.Value__c);
			}
		}
		Integer limitRecordsFC = FullContactApiClient.getLimits(allDataSettingsFC);
		Boolean approvedFC = FullContactApiClient.isApproved(allDataSettingsFC);

		if ((limitRecordsFC < selectedId.size() + totalRecordsFC && !approvedFC) || (limitRecordsTD < selectedId.size() + totalRecordsTD && !approvedTD)) {
			ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'It is possible to exceed the limit after execution!'));
		}

		if (limitRecordsTD < selectedId.size() + totalRecordsTD && !approvedTD) {
			String messageWarning = 'Email Append. Limit records in 24 hours: ' + limitRecordsTD + '.   Processed records in 24 hours: ' + totalRecordsTD + '.   Selected records: ' + selectedId.size() +'.';
			ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, messageWarning));
		}

		if (limitRecordsFC < selectedId.size() + totalRecordsFC && !approvedFC) {
			String messageWarning = 'Social Append. Limit records in 24 hours: ' + limitRecordsFC + '.   Processed records in 24 hours: ' + totalRecordsFC + '.   Selected records: ' + selectedId.size() +'.';
			ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, messageWarning));
		}

	}

	public PageReference init() {
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'AsyncApexJob',
				'DataAppendAccountListViewController.cls [init]',
				new List<Schema.DescribeFieldResult> {
					AsyncApexJob.ApexClassId.getDescribe(), AsyncApexJob.Status.getDescribe()
				}
			);
			SFDCAccessController.AccessibleWithoutSharing (
				'ApexClass',
				'DataAppendAccountListViewController.cls [init]',
				new List<Schema.DescribeFieldResult> {
					ApexClass.Name.getDescribe()
				}
			);

			List<AsyncApexJob> jobs = [
				SELECT Id, Status, ApexClassId, ApexClass.Name
				FROM AsyncApexJob
				WHERE ApexClass.Name IN : TouchCRConfigurationController.NAME_TO_CLASSES.get('DataAppend')
				AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
			];

			if (jobs.isEmpty()) {
				TowerDataApiClient.setDaySettings(allDataSettingsTD, selectedId.size());
				FullContactApiClient.setDaySettings(allDataSettingsFC, selectedId.size());
			
				DataAppendSelectedBatch job = new DataAppendSelectedBatch(selectedId);
				Database.executeBatch(job, 1);

				PageReference redirectPage = new PageReference('/001');
				redirectPage.setRedirect(true);
				return redirectPage;
			}
			else {
				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.WARNING, 'Now Batch is working, please try again later.')
				);
			}
		} catch (Exception e) {throw new SFDCAccessControlException();}
		return null;
	}

	public PageReference returnToAccouts() {
		PageReference redirectPage = new PageReference('/001');
		redirectPage.setRedirect(true);
		return redirectPage;
	}

}