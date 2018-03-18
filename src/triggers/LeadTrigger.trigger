trigger LeadTrigger on Lead (before insert, after insert, after update, before delete) {

	/**
	 * NEED TO APPEND ON INSERT
	 */
	if (Trigger.isBefore && Trigger.isInsert) {
		//get settings
		TowerDataDTO.TowerDataSettings settings = TouchCRConfigurationController.initSettings();

		for (Lead aLead : Trigger.new) {
			// check settings, if we set Global.AppendOnNewLead
			// then all new leads will be processed by DataAppendBatch
			if (settings.appendOnNewLead) {
				aLead.Append_Need_Append__c = true;
			}
		}
	}

	/**
	 * OPTIN DUPLICATE CHECK
	 */
	if (Trigger.isAfter && Trigger.isInsert) {

		// DATA COLLECTIONS
		Map<String, String> emailToLeadIdMap = new Map<String, String>();
		Map<String, String> utmHashToLeadIdMap = new Map<String, String>();
		//
		Map<String, String> utmHashToCampaignIdMap = new Map<String, String>();
		Map<String, Account> emailToExistingAccountMap = new Map<String, Account>();
		Map<String, Lead> emailToExistingLeadMap = new Map<String, Lead>();
		// DML COLLECTIONS
		Map<String, Account> accountsToUpdate = new Map<String, Account>();
		Map<String, Lead> leadsToUpdate = new Map<String, Lead>();
		List<CampaignMember> campaignMembersToInsert = new List<CampaignMember>();
		Map<String, Task> activitiesToInsert = new Map<String, Task>();
		List<Lead> leadsToDelete = new List<Lead>();
		// DATA COLLECTION OPERATIONS
		// collect the data from NEW LEADS
		for (Lead aLead : Trigger.new) {
			emailToLeadIdMap.put(aLead.Email, aLead.Id);
			utmHashToLeadIdMap.put(getUtmHash(aLead), aLead.Id);
		}
		emailToLeadIdMap.remove(null);
		// collect EXISITNG ACCOUNTS
		List<Account> matchedAccounts = [
			SELECT Id, PersonEmail, PersonContactId, PersonHasOptedOutOfEmail,
				utm_source__c, utm_medium__c, utm_campaign__c, utm_content__c, utm_term__c
			FROM Account
			WHERE IsPersonAccount = true
			AND PersonEmail IN :emailToLeadIdMap.keySet()
		];
		for (Account aAccount : matchedAccounts) {
			emailToExistingAccountMap.put(aAccount.PersonEmail, aAccount);
		}
		// collect EXISTING LEADS
		List<Lead> matchedLeads = [
			SELECT Id, Email, HasOptedOutOfEmail,
				utm_source__c, utm_medium__c, utm_campaign__c, utm_content__c, utm_term__c
			FROM Lead
			WHERE Email IN :emailToLeadIdMap.keySet()
			AND Id NOT IN :Trigger.new
		];
		for (Lead aLead : matchedLeads) {
			emailToExistingLeadMap.put(aLead.Email, aLead);
		}
		// collect EXISTING CAMPAIGNS
		List<Campaign> matchedCampaigns = [
			SELECT Id, UTM_Hash__c
			FROM Campaign
			WHERE UTM_Hash__c IN :utmHashToLeadIdMap.keySet()
		];
		for (Campaign aCampaign : matchedCampaigns) {
			utmHashToCampaignIdMap.put(aCampaign.UTM_Hash__c, aCampaign.Id);
		}
		// DO WORK OPERATIONS
		// work with new Lead
		for (Lead aLead : [
			SELECT Id, Email,
				utm_source__c, utm_medium__c, utm_campaign__c, utm_content__c, utm_term__c
			FROM Lead
			WHERE Id IN :Trigger.newMap.keySet()]) {
			// TODO multibrand!!!
			// EXISTING ACCOUNT
			if (emailToExistingAccountMap.containsKey(aLead.Email)) {
				Boolean hasAccountUpdate = false;
				Account oldAccount = emailToExistingAccountMap.get(aLead.Email);
				// Re-optin update Account
				if (oldAccount.PersonHasOptedOutOfEmail) {
					oldAccount = (Account) setOptIn(oldAccount);
					hasAccountUpdate = true;
				}
				// Merge existing record to new record
				if (getUtmHash(oldAccount) != getUtmHash(aLead)) {
					oldAccount = (Account) mergeUtmToExisitingRecord(oldAccount, aLead);
					hasAccountUpdate = true;
				}
				// update Account only on data change
				if (hasAccountUpdate) {
					accountsToUpdate.put(oldAccount.Id, oldAccount);
				}
				// Add activity “Customer optin in on campaign”
				activitiesToInsert.put(oldAccount.Id, addActivity(oldAccount));

				// Add Account to campaign match utm
				// ASSUMPTION MERGE UTM TO ACCOUNT
				if (utmHashToCampaignIdMap.containsKey(getUtmHash(oldAccount))) {
					campaignMembersToInsert.add(addToCampaign(oldAccount, utmHashToCampaignIdMap.get(getUtmHash(oldAccount))));
				}
				// Delete new lead
				leadsToDelete.add(aLead);
			}
			// EXISTING LEAD
			else if (emailToExistingLeadMap.containsKey(aLead.Email)) {
				Boolean hasLeadUpdate = false;
				Lead oldLead = emailToExistingLeadMap.get(aLead.Email);
				// Re-optin
				if (oldLead.HasOptedOutOfEmail) {
					oldLead = (Lead) setOptIn(oldLead);
					hasLeadUpdate = true;
				}
				// Merge existing record to new record
				if (getUtmHash(aLead) != getUtmHash(oldLead)) {
					oldLead = (Lead) mergeUtmToExisitingRecord(oldLead, aLead);
					hasLeadUpdate = true;
				}
				// update Lead only on data change
				if (hasLeadUpdate) {
					leadsToUpdate.put(oldLead.Id, oldLead);
				}
				// Add Lead to campaign match utm
				if (utmHashToCampaignIdMap.containsKey(getUtmHash(oldLead))) {
					campaignMembersToInsert.add(addToCampaign(oldLead, utmHashToCampaignIdMap.get(getUtmHash(oldLead))));
				}
				// Delete new lead
				leadsToDelete.add(aLead);
			}
			// NEW LEAD
			else {
				// Add Lead to campaign match utm
				if (utmHashToCampaignIdMap.containsKey(getUtmHash(aLead))) {
					campaignMembersToInsert.add(addToCampaign(aLead, utmHashToCampaignIdMap.get(getUtmHash(aLead))));
				}
			}
		}
		// DML OPERATIONS
		if (!accountsToUpdate.isEmpty()) {
			Database.update(accountsToUpdate.values(), false);
		}
		if (!leadsToUpdate.isEmpty()) {
			Database.update(leadsToUpdate.values(), false);
		}
		if (!campaignMembersToInsert.isEmpty()) {
			// in case sobj is alreadt cm on that campaign, nothing will be inserted
			Database.insert(campaignMembersToInsert, false);
		}
		if (!activitiesToInsert.isEmpty()) {
			Database.insert(activitiesToInsert.values(), false);
		}
		if (!leadsToDelete.isEmpty()) {
			Database.delete(leadsToDelete, false);
		}
	}

	private static SObject mergeUtmToExisitingRecord(SObject sobj, Lead newLead) {
		sobj.put('utm_source__c', newLead.utm_source__c);
		sobj.put('utm_medium__c', newLead.utm_medium__c);
		sobj.put('utm_campaign__c', newLead.utm_campaign__c);
		sobj.put('utm_content__c', newLead.utm_content__c);
		sobj.put('utm_term__c', newLead.utm_term__c);
		return sobj;
	}

	private static SObject setOptIn(SObject sobj) {
		if (sobj.getSObjectType() == Account.getSObjectType()) {
			sobj.put('PersonHasOptedOutOfEmail', false);
		}
		else if (sobj.getSObjectType() == Lead.getSObjectType()) {
			sobj.put('HasOptedOutOfEmail', false);
		}
		return sobj;
	}

	private static CampaignMember addToCampaign(SObject sobj, String campaignId) {
		CampaignMember result = new CampaignMember(CampaignId = campaignId);

		if (sobj.getSObjectType() == Account.getSObjectType()) {
			result.ContactId = (Id) sobj.get('PersonContactId');
		}
		else if (sobj.getSObjectType() == Lead.getSObjectType()) {
			result.LeadId = (Id) sobj.get('Id');
		}
		return result;
	}

	private static Task addActivity(Account aAccount) {

		Task result = new Task(
			WhoId = aAccount.PersonContactId,
			WhatId = aAccount.Id,
			Subject = 'Customer optin in on campaign',
			Status = 'Opened'
		);

		return result;
	}

	private static String getUtmHash(SObject sobj) {
		String result = '';

		//utm_source__c
		String utmSource = (String)sobj.get('utm_source__c');
		if (String.isNotBlank(utmSource)) {
			result += utmSource.toLowerCase().trim();
		}
		//utm_medium__c
		String utmMedium = (String)sobj.get('utm_medium__c');
		if (String.isNotBlank(utmMedium)) {
			result += utmMedium.toLowerCase().trim();
		}
		//utm_campaign__c
		String utmCampaign = (String)sobj.get('utm_campaign__c');
		if (String.isNotBlank(utmCampaign)) {
			result += utmCampaign.toLowerCase().trim();
		}
		//utm_content__c
		String utmContent = (String)sobj.get('utm_content__c');
		if (String.isNotBlank(utmContent)) {
			result += utmContent.toLowerCase().trim();
		}
		//utm_term__c
		String utmTerm = (String)sobj.get('utm_term__c');
		if (String.isNotBlank(utmTerm)) {
			result += utmTerm.toLowerCase().trim();
		}

		return result;
	}

	/**
	 * LEAD CONVERT
	 */
	if (Trigger.isAfter && Trigger.isUpdate) {
		//map for converted leads and converted account id
		Map<Id, Id> leadIdToAccIdMap = new Map<Id, Id>();
		Map<Id, Integer> accIdToConversionLagMap = new Map<Id, Integer>();
		Map<Id, Date> accIdToConvertedDateMap = new Map<Id, Date>();
		for (Lead aLead : Trigger.new) {
			if (aLead.IsConverted && !Trigger.oldMap.get(aLead.id).IsConverted && aLead.ConvertedAccountId != null) {
				leadIdToAccIdMap.put(aLead.Id, aLead.ConvertedAccountId);
				Integer conversionTimeLag = aLead.CreatedDate.date().daysBetween(aLead.ConvertedDate);
				accIdToConversionLagMap.put(aLead.ConvertedAccountId, conversionTimeLag);
				accIdToConvertedDateMap.put(aLead.ConvertedAccountId, aLead.ConvertedDate);
			}
		}

		List<Account> convertedAccounts = [
			SELECT Id, Lead_CTL__c, Total_CPA__c, PersonContactId
			FROM Account
			WHERE Id IN :accIdToConversionLagMap.keySet()
		];

		//CAMPAIGNS CPA SECTION
		Set<Id> convertedAccountContactIds = new Set<Id>();
		for (Account aAccount : convertedAccounts) {
			convertedAccountContactIds.add(aAccount.PersonContactId);
		}
		//if there more than one CM associated with converted account
		//get most recent
		List<CampaignMember> convertedLeadCM = [
			SELECT Id, CampaignId, LeadId, ContactId, Campaign.Total_CPA__c
			FROM CampaignMember
			WHERE ContactId IN :convertedAccountContactIds
			ORDER BY CreatedDate ASC
		];

		Map<Id, Id> customerIdToCampaignIdMap = new Map<Id, Id>();
		Map<Id, Decimal> campaignIDToCPAMap = new Map<Id, Decimal>();

		for (CampaignMember aCamapignMember : convertedLeadCM) {
			//become a customer on a campaign (lead converted)
			Boolean isCustomerOnCampaign = (
				aCamapignMember.ContactId != null &&
				aCamapignMember.LeadId != null &&
				leadIdToAccIdMap.containsKey(aCamapignMember.LeadId) &&
				convertedAccountContactIds.contains(aCamapignMember.ContactId)
			);
			if (isCustomerOnCampaign) {
				customerIdToCampaignIdMap.put(aCamapignMember.ContactId, aCamapignMember.CampaignId);
				campaignIDToCPAMap.put(aCamapignMember.CampaignId, aCamapignMember.Campaign.Total_CPA__c);
			}
		}
		//END CAMPAIGNS CPA SECTION

		for (Account aAccount : convertedAccounts) {
			if (accIdToConversionLagMap.containsKey(aAccount.Id)) {
				aAccount.Lead_CTL__c = accIdToConversionLagMap.get(aAccount.Id);
			}
			if (accIdToConvertedDateMap.containsKey(aAccount.Id)) {
				aAccount.Date_Lead_Acquired__c = accIdToConvertedDateMap.get(aAccount.Id);
			}
			//CPA
			if (customerIdToCampaignIdMap.containsKey(aAccount.PersonContactId)) {
				Id campaignId = customerIdToCampaignIdMap.get(aAccount.PersonContactId);
				if (campaignIDToCPAMap.containsKey(campaignId)) {
					Decimal cpaValue = campaignIDToCPAMap.get(campaignId);
					aAccount.Total_CPA__c = cpaValue;
				}
			}
			//CPA
		}

		//VISITS
		List<Recognized_Visits__c> visitsList = [
			SELECT Lead__c, Customer_Contact__c
			FROM Recognized_Visits__c
			WHERE Lead__c IN :leadIdToAccIdMap.keySet()
		];
		//change lookups on visits from lead to converted accounts
		for (Recognized_Visits__c aVisit : visitsList) {
			if (leadIdToAccIdMap.containsKey(aVisit.Lead__c)) {
				aVisit.Customer_Contact__c = leadIdToAccIdMap.get(aVisit.Lead__c);
				aVisit.Lead__c = null;
			}
		}

		//DEVICES
		List<Recognized_Visit_Device__c> devicesList = [
			SELECT Lead__c, Customer_Contact__c
			FROM Recognized_Visit_Device__c
			WHERE Lead__c IN :leadIdToAccIdMap.keySet()
		];
		//change lookups on devices from lead to converted accounts
		for (Recognized_Visit_Device__c aDevice : devicesList) {
			if (leadIdToAccIdMap.containsKey(aDevice.Lead__c)) {
				aDevice.Customer_Contact__c = leadIdToAccIdMap.get(aDevice.Lead__c);
				aDevice.Lead__c = null;
			}
		}

		//re associate Social Profiles from lead to account
		List<Social_Profile__c> socialProfiles = [SELECT Id, Account__c, Lead__c FROM Social_Profile__c WHERE Lead__c IN :leadIdToAccIdMap.keySet()];
		for (Social_Profile__c aSocialProfile : socialProfiles) {
			if (leadIdToAccIdMap.containsKey(aSocialProfile.Lead__c)) {
				aSocialProfile.Account__c = leadIdToAccIdMap.get(aSocialProfile.Lead__c);
				aSocialProfile.Lead__c = null;
			}
		}


		if (!visitsList.isEmpty()) {
			Database.update(visitsList, false);
		}
		if (!devicesList.isEmpty()) {
			Database.update(devicesList, false);
		}
		if (!convertedAccounts.isEmpty()) {
			Database.update(convertedAccounts, false);
		}
		if (!socialProfiles.isEmpty()) {
			Database.update(socialProfiles, false);
		}

	}


	if (Trigger.isBefore && Trigger.isDelete) {
		List<Social_Profile__c> socialProfiles = [SELECT Id FROM Social_Profile__c WHERE Lead__c IN :Trigger.old];
		if (!socialProfiles.isEmpty()) {
			delete socialProfiles;
		}
	}

}