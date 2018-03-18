public with sharing class CampaignHierarchySummaryBatch implements Database.Batchable<sObject>, Database.Stateful {

	private Integer campaignLevel;

	public CampaignHierarchySummaryBatch(Integer level) {
		//traversal begin from lowest campaign hiearchy to topmost.
		this.campaignLevel = level;
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		String soqlStr =
			' SELECT Id, Total_Customers_Value_Hierarchy__c, Total_Orders_Hierarchy__c, Total_Orders_Value_Hierarchy__c, '
			+ ' Total_Customers_Value__c, Total_Orders__c, Total_Orders_Value__c, Lead_CTL_Sum__c, Lead_CTL_Sum_Hierarchy__c, '
				+ ' (SELECT Total_Customers_Value_Hierarchy__c, Total_Orders_Hierarchy__c, Total_Orders_Value_Hierarchy__c, Lead_CTL_Sum_Hierarchy__c '
				+ ' FROM ChildCampaigns) '
			+ ' FROM Campaign '
			+ ' WHERE Campaign_Level__c != NULL'
			+ ' AND Campaign_Level__c = :campaignLevel';
		return Database.getQueryLocator(soqlStr);
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		//List<Campaign> aCampaigns = (List<Campaign>) scope;
		List<Campaign> campaignsToUpdate = new List<Campaign>();
		for (Campaign aParentCampaign : (List<Campaign>)scope) {
			Decimal totalCustomersValue = (aParentCampaign.Total_Customers_Value__c != null) ? aParentCampaign.Total_Customers_Value__c : 0;
			Decimal totalOrders = (aParentCampaign.Total_Orders__c != null) ? aParentCampaign.Total_Orders__c : 0;
			Decimal totalOrdersValue = (aParentCampaign.Total_Orders_Value__c != null) ? aParentCampaign.Total_Orders_Value__c : 0;
			Decimal leadCtlValue = (aParentCampaign.Lead_CTL_Sum__c != null) ? aParentCampaign.Lead_CTL_Sum__c : 0;
			for (Campaign aChildCampaign : aParentCampaign.ChildCampaigns) {
				totalCustomersValue += (aChildCampaign.Total_Customers_Value_Hierarchy__c != null) ? aChildCampaign.Total_Customers_Value_Hierarchy__c : 0;
				totalOrders += (aChildCampaign.Total_Orders_Hierarchy__c != null) ? aChildCampaign.Total_Orders_Hierarchy__c : 0;
				totalOrdersValue += (aChildCampaign.Total_Orders_Value_Hierarchy__c != null) ? aChildCampaign.Total_Orders_Value_Hierarchy__c : 0;
				leadCtlValue += (aChildCampaign.Lead_CTL_Sum_Hierarchy__c != null) ? aChildCampaign.Lead_CTL_Sum_Hierarchy__c : 0;
			}
			aParentCampaign.Total_Orders_Hierarchy__c = totalOrders;
			aParentCampaign.Total_Orders_Value_Hierarchy__c = totalOrdersValue;
			aParentCampaign.Total_Customers_Value_Hierarchy__c = totalCustomersValue;
			aParentCampaign.Lead_CTL_Sum_Hierarchy__c = leadCtlValue;
			campaignsToUpdate.add(aParentCampaign);
		}

		try {
			SFDCAccessController.UpdateWithoutSharing (
				campaignsToUpdate,
				'CampaignMemberSummaryBatch.cls [execute]',
				new List<Schema.DescribeFieldResult> {
					Campaign.Total_Customers_Value_Hierarchy__c.getDescribe(), Campaign.Total_Customers_Value__c.getDescribe(),
					Campaign.Total_Orders_Value_Hierarchy__c.getDescribe(), Campaign.Total_Orders_Hierarchy__c.getDescribe(),
					Campaign.Total_Orders__c.getDescribe(), Campaign.Total_Orders_Value__c.getDescribe(),
					Campaign.Lead_CTL_Sum_Hierarchy__c.getDescribe(), Campaign.Lead_CTL_Sum__c.getDescribe()
				}
			);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

	}

	public void finish(Database.BatchableContext BC) {
		//if we get to the topmost campaign(no parent campaign) stop
		this.campaignLevel = this.campaignLevel - 1;
		if (this.campaignLevel > -1) {
			CampaignHierarchySummaryBatch job = new CampaignHierarchySummaryBatch(this.campaignLevel);
			Database.executeBatch(job, 200);
		}
		else {
			Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();

			if (settingsMap.containsKey('Batch.CampaignMemberStatus') && settingsMap.containsKey('Batch.CampaignMemberDay') && settingsMap.containsKey('Batch.CampaignMemberTime')) {
				TouchCR_Settings__c settingCampaignMemberStatus = settingsMap.get('Batch.CampaignMemberStatus');
				TouchCR_Settings__c settingCampaignMemberDay = settingsMap.get('Batch.CampaignMemberDay');
				TouchCR_Settings__c settingCampaignMemberTime = settingsMap.get('Batch.CampaignMemberTime');

				if (settingCampaignMemberStatus.Value__c == 'On' && settingCampaignMemberDay.Value__c != '' && settingCampaignMemberTime.Value__c != '') {
					List<CronTrigger> scheduleInProgress = [
						SELECT Id, NextFireTime
						FROM CronTrigger
						WHERE CronJobDetail.Name =: 'CampaignMember'
						LIMIT 1
					];
					if (!scheduleInProgress.isEmpty()) {
						System.abortJob(scheduleInProgress.get(0).Id);
					}

					CampaignMemberScheduler scheduler = new CampaignMemberScheduler();
					String cronStr = '0 0 ' + settingCampaignMemberTime.Value__c + ' 1/' + settingCampaignMemberDay.Value__c + ' * ? *';
					System.schedule('CampaignMember' , cronStr, scheduler);
				}
			}
		}
	}

}