public with sharing class CampaignHierarchyBatch implements Database.Batchable<sObject>, Database.Stateful {

	private Integer campaignLevel;
	private Integer prevCampaignLevel;
	private Boolean runAgain;

	public CampaignHierarchyBatch() {
		this(0);
	}

	public CampaignHierarchyBatch(Integer level) {
		this.campaignLevel = level;
		this.runAgain = false;
		this.prevCampaignLevel = (this.campaignLevel == 0) ? this.campaignLevel : this.campaignLevel - 1;
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		String soqlStr;
		if (this.campaignLevel == 0) {
			//top level campaigns
			soqlStr = 'SELECT Id, Campaign_Level__c FROM Campaign WHERE ParentId = NULL';
		}
		else {
			soqlStr = 'SELECT Id, Campaign_Level__c FROM Campaign WHERE Parent.Campaign_Level__c = :prevCampaignLevel';
		}
		Database.QueryLocator dbQl = Database.getQueryLocator(soqlStr);
		Database.QueryLocatorIterator dbQIt =  dbQl.iterator();
		this.runAgain = (dbQIt.hasNext()) ? true : false;
		return dbql;
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {

		List<Campaign> campaignsToUpdate = new List<Campaign>();
		for (sObject aObject : scope) {
			Campaign aCampaign = (Campaign) aObject;
			aCampaign.Campaign_Level__c = this.campaignLevel;
			campaignsToUpdate.add(aCampaign);
		}

		try {
			SFDCAccessController.UpdateWithoutSharing (
				campaignsToUpdate,
				'CampaignHierarchyBatch.cls [execute]',
				new List<Schema.DescribeFieldResult> {
					Campaign.Campaign_Level__c.getDescribe()
				}
			);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	public void finish(Database.BatchableContext BC) {
		this.campaignLevel++;
		if (this.runAgain && this.campaignLevel <= 15) {
			CampaignHierarchyBatch job = new CampaignHierarchyBatch(this.campaignLevel);
			Database.executeBatch(job);
		}
		else {
			CampaignHierarchySummaryBatch job = new CampaignHierarchySummaryBatch(this.campaignLevel);
			Database.executeBatch(job);
		}
	}

}