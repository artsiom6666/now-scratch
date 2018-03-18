public with sharing class CampaignMemberBatch implements Database.Batchable<sObject> {

	/**
	 * step 1 check accounts not campaign members, if there any relate it
	 * step 2 check leads not campaign members, if there any realte it
	 * step 3 check order not campaign members, if there any realte it
	 */

	private String query;
	//allowed values for batchStep 1,2,3
	private Integer batchStep;

	public CampaignMemberBatch(Integer step) {
		this.batchStep = (step > 0 && step <= 3) ? step : 1;
		String soqlStr;

		//ACCOUNT
		if (this.batchStep == 1) {
			soqlStr = 'SELECT Id, PersonContactId, Utm_Source__c, Utm_Medium__c, Utm_Campaign__c, Utm_Content__c, Utm_Term__c ' +
				+ ' FROM Account ' +
				+ ' WHERE PersonContactId NOT IN (SELECT ContactId FROM CampaignMember)';
		}
		//LEAD
		else if (this.batchStep == 2) {
			soqlStr = 'SELECT Id, Utm_Source__c, Utm_Medium__c, Utm_Campaign__c, Utm_Content__c, Utm_Term__c ' +
				+ ' FROM Lead ' +
				+ ' WHERE Id NOT IN (SELECT LeadId FROM CampaignMember)';
		}
		//ORDER
		else {
			soqlStr = 'SELECT Id, Campaign__c, Utm_Source__c, Utm_Medium__c, Utm_Campaign__c, Utm_Content__c, Utm_Term__c, Account_Person_Contact_Id__c ' +
			+ ' FROM Order__c WHERE Campaign__c = null AND Campaign_Link__c = null';
		}

		this.query = soqlStr;
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		Map<Id, Order__c> ordersObjMap = new Map<Id, Order__c>();

		Set<Id> orderCustomersIds = new Set<Id>();

		Map<String, List<Id>> utmToObjectIdMap = new Map<String, List<Id>>();
		//Collect map utm hash to a list of object ids
		for (SObject anObject : scope) {
			//calculate utm hash for the object
			String utmHash = '';
			//Utm_Source__c
			String utmSource = (String)anObject.get('Utm_Source__c');
			if (String.isNotBlank(utmSource)) {
				utmHash += utmSource.toLowerCase().trim();
			}
			//Utm_Medium__c
			String utmMedium = (String)anObject.get('Utm_Medium__c');
			if (String.isNotBlank(utmMedium)) {
				utmHash += utmMedium.toLowerCase().trim();
			}
			//Utm_Campaign__c
			String utmCampaign = (String)anObject.get('Utm_Campaign__c');
			if (String.isNotBlank(utmCampaign)) {
				utmHash += utmCampaign.toLowerCase().trim();
			}
			//Utm_Content__c
			String utmContent = (String)anObject.get('Utm_Content__c');
			if (String.isNotBlank(utmContent)) {
				utmHash += utmContent.toLowerCase().trim();
			}
			//Utm_Term__c
			String utmTerm = (String)anObject.get('Utm_Term__c');
			if (String.isNotBlank(utmTerm)) {
				utmHash += utmTerm.toLowerCase().trim();
			}
			//account => PersonContactId
			//Lead => Id
			//Order => Id
			if (String.isNotBlank(utmHash)) {
				if (utmToObjectIdMap.containsKey(utmHash)) {
					List<Id> idsList = utmToObjectIdMap.get(utmHash);

					if (this.batchStep == 1) {
						idsList.add((Id)anObject.get('PersonContactId'));
					}
					else if (this.batchStep == 2) {
						idsList.add((Id)anObject.get('Id'));
					}
					else if (this.batchStep == 3) {
						idsList.add((Id)anObject.get('Id'));
						ordersObjMap.put((Id)anObject.get('Id'), (Order__c)anObject);
						//
						orderCustomersIds.add((Id)anObject.get('Account_Person_Contact_Id__c'));
					}

					utmToObjectIdMap.put(utmHash, idsList);
				}
				else {
					if (this.batchStep == 1) {
						utmToObjectIdMap.put(utmHash, new List<Id> { (Id)anObject.get('PersonContactId') });
					}
					else if (this.batchStep == 2) {
						utmToObjectIdMap.put(utmHash, new List<Id> { (Id)anObject.get('Id') });
					}
					else if (this.batchStep == 3) {
						utmToObjectIdMap.put(utmHash, new List<Id> { (Id)anObject.get('Id') });
						ordersObjMap.put((Id)anObject.get('Id'), (Order__c)anObject);
						//
						orderCustomersIds.add((Id)anObject.get('Account_Person_Contact_Id__c'));
					}
				}
			}
		}

		List<CampaignMember> campMemberToInsert = new List<CampaignMember>();
		List<Order__c> ordersToUpdate = new List<Order__c>();

		//key -> UTM_Hash__c, value -> Campaign or Campaign_Links__c
		Map<String, sObject> utmToObject = new Map<String, sObject>();

		//get campaign with matching UTM_Hash__c field
		//get all customers from orders and their related campaigns
		//use last to prevent linking cusotmer to the same campaign twice or more
		List<Campaign> campaigns = [
			SELECT Id, UTM_Hash__c,
				(SELECT CampaignId, ContactId FROM CampaignMembers WHERE ContactId IN :orderCustomersIds)
			FROM Campaign
			WHERE UTM_Hash__c IN :utmToObjectIdMap.keySet()
		];

		//get campaign links with matching UTM_Hash__c field
		List<Campaign_Links__c> campaignLinks = [
			SELECT UTM_Hash__c, Campaign__c, Campaign__r.UTM_Hash__c
			FROM Campaign_Links__c
			WHERE UTM_Hash__c IN :utmToObjectIdMap.keySet()
		];

		Map<Id, Set<Id>> customerOnCampaigns = new Map<Id, Set<Id>>();

		//getting utmHash to Campaign
		for (Campaign aCampaign : campaigns) {
			utmToObject.put(aCampaign.UTM_Hash__c, aCampaign);
			// collect campaigns for order cusotmers
			for (CampaignMember cmpm : aCampaign.CampaignMembers) {
				if (customerOnCampaigns.containsKey(cmpm.ContactId)) {
					Set<Id> campaignsForTheCusomer = customerOnCampaigns.get(cmpm.ContactId);
					campaignsForTheCusomer.add(cmpm.CampaignId);
					customerOnCampaigns.put(cmpm.ContactId, campaignsForTheCusomer);
				}
				else {
					customerOnCampaigns.put(cmpm.ContactId,  new Set<Id>{cmpm.CampaignId});
				}
			}
		}
		// getting utmHash to Campaign_Links__c
		// if matches with utm Hash Campaign, then replaces Campaign Links__c
		for (Campaign_Links__c aCampaignLink : campaignLinks) {
			utmToObject.put(aCampaignLink.UTM_Hash__c, aCampaignLink);
		}
		// find CampaignLinks or Campaign with required utmHash
		// if CampaignLinks, then use their Campaign for Lead and Account
		// create CampaignMember for Lead and Account and updated if Order
		for (String utmHash : utmToObject.keySet()) {
			// getting CampaignLinks or Campaign with required UTM
			sObject obj = utmToObject.get(utmHash);
			// getting all the objects (Account, Lead, Order) which have the same UTM
			List<Id> objIdsList = utmToObjectIdMap.get(utmHash);

			for (Id objId : objIdsList) {
				CampaignMember memberShip = new CampaignMember();
				if (obj.getSObjectType() == Schema.Campaign_Links__c.getSObjectType()) {
					memberShip.CampaignId = (Id) obj.get('Campaign__c');
				}
				else {
					memberShip.CampaignId = (Id) obj.get('Id');
				}
				// account step
				if (this.batchStep == 1) {
					memberShip.ContactId = objId;
					campMemberToInsert.add(memberShip);
				}
				// lead step
				else if (this.batchStep == 2) {
					memberShip.LeadId = objId;
					campMemberToInsert.add(memberShip);
				}
				else if (this.batchStep == 3) {
					// create temp order with id, fill relation, try to update
					Order__c orderToUpdate = ordersObjMap.get(objId);
					// check if customer of the order is already connected to a campaign we are going to connect that order
					if (obj.getSObjectType() == Schema.Campaign_Links__c.getSObjectType()) {
						orderToUpdate.Campaign__c = (Id) obj.get('Campaign__c');
						orderToUpdate.Campaign_Link__c = (Id) obj.get('Id');
					}
					else if (obj.getSObjectType() == Schema.Campaign.getSObjectType()) {
						orderToUpdate.Campaign__c = (Id) obj.get('Id');
					}
					// if order matched to a campaign, match customer to the same campaign
					// check customer from order if it is already belongs to a campaign we are going to add it
					if (orderToUpdate.Account_Person_Contact_Id__c != null) {
						// get campaigns for the customer, if any
						memberShip.ContactId = orderToUpdate.Account_Person_Contact_Id__c;
						if (customerOnCampaigns.containsKey(memberShip.ContactId)) {
							Set<Id> cmpIdsForTheCusomer = customerOnCampaigns.get(memberShip.ContactId);
							// check the customer alredy belongs to the campaign
							if (!cmpIdsForTheCusomer.contains(memberShip.CampaignId)) {
								campMemberToInsert.add(memberShip);
								// add new campaign for the customer
								cmpIdsForTheCusomer.add(memberShip.CampaignId);
								customerOnCampaigns.put(memberShip.ContactId, cmpIdsForTheCusomer);
							}
						}
						else {
							campMemberToInsert.add(memberShip);
							// update cusomer to linked campaigns
							customerOnCampaigns.put(memberShip.ContactId, new Set<Id>{memberShip.CampaignId});
						}
					}
					ordersToUpdate.add(orderToUpdate);
				}
			}
		}

		if (!campMemberToInsert.isEmpty()) {
			try {
				SFDCAccessController.InsertWithoutSharing (
					campMemberToInsert,
					'CampaignMemberBatch.cls [execute]',
					new List<Schema.DescribeFieldResult> {
						CampaignMember.ContactId.getDescribe(), CampaignMember.CampaignId.getDescribe(),
						CampaignMember.LeadId.getDescribe()
					}
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}
		if (!ordersToUpdate.isEmpty()) {
			try {
				SFDCAccessController.UpdateWithoutSharing (
					ordersToUpdate,
					'CampaignMemberBatch.cls [execute]',
					new List<Schema.DescribeFieldResult> {
						Order__c.Campaign__c.getDescribe(), Order__c.Campaign_Link__c.getDescribe()
					}
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}
	}

	public void finish(Database.BatchableContext BC) {
		if (this.batchStep < 3) {
			CampaignMemberBatch job = new CampaignMemberBatch(++this.batchStep);
			Database.executeBatch(job, 200);
		}
		else {
			CampaignMemberSummaryBatch job = new CampaignMemberSummaryBatch(1);
			Database.executeBatch(job, 200);
		}
	}

}