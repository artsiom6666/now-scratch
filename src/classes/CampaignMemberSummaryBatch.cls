public with sharing class CampaignMemberSummaryBatch implements Database.Batchable<sObject> {

	//allowed values for batchStep 1,2
	private Integer batchStep;

	public CampaignMemberSummaryBatch(Integer step) {
		this.batchStep = (step > 0 && step <= 2) ? step : 1;
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		String soqlStr;
		//CUSTOMERS
		if (this.batchStep == 1) {
			soqlStr = 'SELECT ContactId, CampaignId, Campaign.Apex_Job_Id__c, Contact.Total_Customer_Value__c, Contact.Lead_CTL__c, Campaign.NumberOfConvertedLeads ' +
			' FROM CampaignMember WHERE ContactId != null ORDER BY CampaignId';
		}
		//ORDER
		if (this.batchStep == 2) {
			soqlStr = 'SELECT Id, Campaign__c, Total__c ' +
			+ ' FROM Order__c WHERE Campaign__c != null ORDER BY Campaign__c';
		}
		return Database.getQueryLocator(soqlStr);
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		Set<Id> campaignIds = new Set<Id>();
		for (sObject obj : scope) {
			if (this.batchStep == 1) {
				CampaignMember aCampaignMember = (CampaignMember) obj;
				campaignIds.add(aCampaignMember.CampaignId);
			}
			if (this.batchStep == 2) {
				Order__c aOrder = (Order__c) obj;
				campaignIds.add(aOrder.Campaign__c);
			}
		}
		Map<Id, Campaign> campaignsToUpdate = new Map<Id, Campaign>([
			SELECT Id, Apex_Job_Id__c, Total_Customers_Value__c, Total_Orders__c, Total_Orders_Value__c, Lead_CTL_Sum__c
			FROM Campaign
			WHERE Id IN :campaignIds
		]);

		for (sObject obj : scope) {
			//CUSTOMERS
			if (this.batchStep == 1) {
				CampaignMember aCampaignMember = (CampaignMember) obj;
				Id campaignId = aCampaignMember.CampaignId;
				Decimal customerValue = (aCampaignMember.Contact.Total_Customer_Value__c != null) ? aCampaignMember.Contact.Total_Customer_Value__c : 0;
				Decimal leadCTLSum = (aCampaignMember.Contact.Lead_CTL__c != null) ? aCampaignMember.Contact.Lead_CTL__c : 0;
				if (campaignsToUpdate.containsKey(campaignId)) {
					Campaign aCampaign = campaignsToUpdate.get(campaignId);
					if (aCampaign.Apex_Job_Id__c == BC.getJobId()) {
						//cmapign updated by this apex job add customerValue
						aCampaign.Total_Customers_Value__c = aCampaign.Total_Customers_Value__c + customerValue;
						aCampaign.Lead_CTL_Sum__c = aCampaign.Lead_CTL_Sum__c + leadCTLSum;
					}
					else {
						aCampaign.Apex_Job_Id__c = BC.getJobId();
						//replace values
						aCampaign.Total_Customers_Value__c = customerValue;
						aCampaign.Lead_CTL_Sum__c = leadCTLSum;
					}
				}
			}
			//ORDERS
			if (this.batchStep == 2) {
				Order__c aOrder = (Order__c)obj;
				Id campaignId = aOrder.Campaign__c;
				Decimal value = (aOrder.Total__c != null) ? aOrder.Total__c : 0;
				if (campaignsToUpdate.containsKey(campaignId)) {
					Campaign aCampaign = campaignsToUpdate.get(campaignId);
					if (aCampaign.Apex_Job_Id__c == BC.getJobId()) {
						//cmapign updated by this apex job add value
						aCampaign.Total_Orders_Value__c = aCampaign.Total_Orders_Value__c + value;
						aCampaign.Total_Orders__c = aCampaign.Total_Orders__c + 1;
					}
					else {
						aCampaign.Apex_Job_Id__c = BC.getJobId();
						//replace values
						aCampaign.Total_Orders_Value__c = value;
						aCampaign.Total_Orders__c = 1;
					}
				}
			}
		} //for scope

		try {
			SFDCAccessController.UpdateWithoutSharing (
				campaignsToUpdate.values(),
				'CampaignMemberSummaryBatch.cls [execute]',
				new List<Schema.DescribeFieldResult> {
					Campaign.Apex_Job_Id__c.getDescribe(), Campaign.Total_Customers_Value__c.getDescribe(),
					Campaign.Total_Orders__c.getDescribe(), Campaign.Total_Orders_Value__c.getDescribe(),
					Campaign.Lead_CTL_Sum__c.getDescribe()
				}
			);

		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	public void finish(Database.BatchableContext BC) {
		if (this.batchStep < 2) {
			CampaignMemberSummaryBatch job = new CampaignMemberSummaryBatch(++this.batchStep);
			Database.executeBatch(job, 200);
		}
		else {
			CampaignHierarchyBatch job = new CampaignHierarchyBatch();
			Database.executeBatch(job);
		}
	}

}