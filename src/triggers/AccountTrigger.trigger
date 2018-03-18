trigger AccountTrigger on Account (before insert, before update, before delete) {
	if (!Trigger.isDelete) {
	//get settings
	TowerDataDTO.TowerDataSettings settings = TouchCRConfigurationController.initSettings();
	Map<Id, String> personRtMap = new Map<Id, String>();
	List<RecordType> personRtList = [
		SELECT Name, SobjectType, IsPersonType, DeveloperName
		FROM RecordType
		WHERE SobjectType = 'Account'
		AND IsPersonType = true
		AND IsActive = true
	];

	for (RecordType personRt : personRtList) {
		personRtMap.put(personRt.Id, personRt.DeveloperName);
	}

	//list for all Id converted account
	List<Id> convertedAccountIds = new List<Id>();

	for (Account aAccount : Trigger.new) {
		// work with PA only
		if (personRtMap.containsKey(aAccount.RecordTypeId)) {
			// check settings, if we set Global.AppendOnNewAccount
			// then all new accounts will be processed by DataAppendBatch
			if (Trigger.isBefore && Trigger.isInsert) {
				if (settings.appendOnNewAccount && personRtMap.get(aAccount.RecordTypeId) == 'Customer_Account') {
					aAccount.Append_Need_Append__c = true;
				}
			}
			// check accounts converted from lead
			// touchcr trigger will set Lead_CTL__c flag to number of days it took for lead converting
			// if this flag is set, this is converted from lead account
			// set Append_Need_Append__c according to settings
			if (Trigger.isBefore && Trigger.isUpdate) {
				// update days after last order
				// difference will be counten in UTC format
				Datetime dtStart = aAccount.Last_order_date__c;
				Datetime dtEnd = System.now();
				Integer daysDiff = null;

				if (dtStart != null) {
					//get date part
					Date dStart = dtStart.dateGmt();
					Date dEnd = dtEnd.dateGmt();
					daysDiff = dStart.daysBetween(dEnd);
					aAccount.Days_After_Last_Order__c = daysDiff;
				}
				else {
					aAccount.Days_After_Last_Order__c = daysDiff;
				}
				//if converted account
				if (Trigger.oldMap.get(aAccount.id).Lead_CTL__c == null && aAccount.Lead_CTL__c != null) {
					convertedAccountIds.add(aAccount.id);
				}
			}
		}
	}

	//find the field Lead needed for Account
	Map<Id, Lead> convertedLead = new Map<Id, Lead>();
	for (Lead aLead : [SELECT Id, Append_Need_Append__c,
							Append_Run__c, Append_Run_Date__c,
							Social_Append_Run_Date__c, Social_Append_Success__c,
							Email_Append_Run__c, Email_Append_Run_Date__c, ConvertedAccountId
							FROM Lead WHERE ConvertedAccountId IN: convertedAccountIds]) {

		if (String.isNotBlank(aLead.ConvertedAccountId)) {
			convertedLead.put(aLead.ConvertedAccountId, aLead);
		}
	}

	for (Account aAccount : Trigger.new) {

		if (convertedLead.containsKey(aAccount.Id)) {
			aAccount.Append_Run__c = convertedLead.get(aAccount.id).Append_Run__c;
			aAccount.Append_Run_Date__c = convertedLead.get(aAccount.id).Append_Run_Date__c;
			aAccount.Social_Append_Run_Date__c = convertedLead.get(aAccount.id).Social_Append_Run_Date__c;
			aAccount.Social_Append_Success__c = convertedLead.get(aAccount.id).Social_Append_Success__c;
			aAccount.Email_Append_Run__c = convertedLead.get(aAccount.id).Email_Append_Run__c;
			aAccount.Email_Append_Run_Date__c = convertedLead.get(aAccount.id).Email_Append_Run_Date__c;
		}

		//field change for converted accounts
		for (Id item : convertedLead.keySet()) {
			Lead aLead = convertedLead.get(aAccount.id);		
			//"Re-append on Lead to Account Convert" + Append_Run__c == true
			if (settings.leadConvertAppend) {
				if (aLead.Append_Run__c) {
					aAccount.Append_Need_Append__c = true;
				}
			}
			//"Append on new Accounts" + Append_Run__c == false
			if (settings.AppendOnNewAccount) {
				if (!aLead.Append_Run__c) {
					aAccount.Append_Need_Append__c = true;
				}
				else {
					aAccount.Append_Need_Append__c = false;
				}
			}
			// !"Append on new Accounts" && "Re-append on Lead to Account Aged" > 0
			if (!settings.leadConvertAppend && settings.leadConvertAccountAged > 0) {
				if (aAccount.Lead_CTL__c > settings.leadConvertAccountAged) {
					aAccount.Append_Need_Append__c = true;
				}
				else {
					aAccount.Append_Need_Append__c = false;
				}
			}
		}
	}
	}

	if (Trigger.isUpdate) {
		//get Map AccountId => sorted by created date Account Orders
		Map<Id, List<Order__c>> accountOrders = new Map<Id, List<Order__c>>();
		for (Order__c ord : [SELECT Id, Account__c, Transaction_Total__c, Date__c 
							FROM Order__c 
							WHERE Account__c IN :Trigger.newMap.keySet()
							AND Date__c != NULL 
							AND Transaction_Total__c != 0 
							ORDER BY Date__c ASC]) {

			if (accountOrders.get(ord.Account__c) == null) {
				accountOrders.put(ord.Account__c, new List<Order__c>());
			}
			accountOrders.get(ord.Account__c).add(ord);
		}

		//get AccountId => List of only first day orders
		for (Id accId : accountOrders.keySet()) {
			List<Order__c> firstDayOrders = new List<Order__c>();
			Date firstOrderDate = null;
			for (Order__c ord : accountOrders.get(accId)) {
				if (firstOrderDate == null) {
					firstOrderDate = Date.newinstance(ord.Date__c.year(), ord.Date__c.month(), ord.Date__c.day());
				}
				if (Date.newinstance(ord.Date__c.year(), ord.Date__c.month(), ord.Date__c.day()) == firstOrderDate) {
					firstDayOrders.add(ord);
				}
				else {
					break;
				}
			}
			accountOrders.put(accId, firstDayOrders);
		}

		//set Account Initial Customer Value
		for (Id accId : accountOrders.keySet()) {
			Double initialVolume = 0;
			for (Order__c ord : accountOrders.get(accId)) {
				initialVolume += ord.Transaction_Total__c;
			}
			Trigger.newMap.get(accId).Initial_Customer_Value__c = initialVolume == 0 ? null : initialVolume;
		}
	}


	if (Trigger.isBefore && Trigger.isDelete) {
		List<Social_Profile__c> socialProfiles = [SELECT Id FROM Social_Profile__c WHERE Account__c IN :Trigger.old];
		if (!socialProfiles.isEmpty()) {
			delete socialProfiles;
		}
	}

}