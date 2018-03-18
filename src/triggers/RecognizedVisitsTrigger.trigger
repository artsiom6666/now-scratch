trigger RecognizedVisitsTrigger on Recognized_Visits__c (after insert) {
	/**
	 * INIT SECTION
	 * all required maps prepared
	 * emailToAccIdMap => Email to Account Id
	 * emailToLeadIdMap => Email to Lead Id
	 * objectIdToDeviceNameMap => sObject Id (Account or Lead) to devices Map (device name, device id)
	 */

	//get distinct email addresses from visits
	Set<String> emailAddr = new Set<String>();
	for (Recognized_Visits__c aVisit : Trigger.new) {
		emailAddr.add(aVisit.User_Email_Address__c.toLowerCase());
	}

	//Email to Account id map
	Map<String, Id> emailToAccIdMap = new Map<String, Id>();

	//Email to Lead id map
	Map<String, Id> emailToLeadIdMap = new Map<String, Id>();
	// for utm copying and lead updates
	Map<String, Lead> leadWithEmptyUtmIdToLeadMap = new Map<String, Lead>();

	//Account OR Lead Id to device map {name and device id}
	Map<Id, Map<String, Id>> objectIdToDeviceNameMap = new Map<Id, Map<String, Id>>();

	//Existing Accounts with Devices
	List<Account> existingAccountsWithDevices = [
		SELECT Id, PersonEmail,
			(SELECT Id, Name FROM Recognized_Visit_Devices__r)
		FROM Account
		WHERE isPersonAccount = true
		AND PersonEmail in :emailAddr
	];
	for (Account aAccount : existingAccountsWithDevices) {

		//build Account existing devices map
		Map<String, Id> deviceNameToIdMap = new Map<String, Id>();
		for (Recognized_Visit_Device__c aDevice : aAccount.Recognized_Visit_Devices__r) {
			deviceNameToIdMap.put(aDevice.Name.toLowerCase(), aDevice.Id);
		}

		if (!deviceNameToIdMap.isEmpty()) {
			objectIdToDeviceNameMap.put(aAccount.Id, deviceNameToIdMap);
		}
		//build Email to Account id map
		emailToAccIdMap.put(aAccount.PersonEmail.toLowerCase(), aAccount.Id);
	}

	//LEAD
	for (Lead aLead : [
			SELECT Id, Email, utm_campaign__c, utm_content__c, utm_medium__c, utm_source__c, utm_term__c,
				(SELECT Id, Name FROM Recognized_Visit_Devices__r)
			FROM Lead
			WHERE Email in :emailAddr]) {

		//build Lead existing devices map
		Map<String, Id> deviceNameToIdMap = new Map<String, Id>();
		for (Recognized_Visit_Device__c aDevice : aLead.Recognized_Visit_Devices__r) {
			deviceNameToIdMap.put(aDevice.Name.toLowerCase(), aDevice.Id);
		}

		if (!deviceNameToIdMap.isEmpty()) {
			objectIdToDeviceNameMap.put(aLead.Id, deviceNameToIdMap);
		}
		//build Email to Lead id map
		emailToLeadIdMap.put(aLead.Email.toLowerCase(), aLead.Id);

		Boolean hasLeadAllUtmEmpty = (String.isBlank(aLead.utm_campaign__c) &&
			String.isBlank(aLead.utm_content__c) &&
			String.isBlank(aLead.utm_medium__c) &&
			String.isBlank(aLead.utm_source__c) &&
			String.isBlank(aLead.utm_term__c)
		);
		if (hasLeadAllUtmEmpty) {
			//build lead with empty utms map
			leadWithEmptyUtmIdToLeadMap.put(aLead.Id, aLead);
		}
	}

	/**
	 * MAPPING SECTION
	 * visitListToInsert => main visits insert list
	 * visitListToDelete => list for non mapped visits (non mapped = no Account or Lead with same email found)
	 *
	 * visitNotMappedAccountList => tmp list for visits if its Account does not have such device
	 * visitNotMappedLeadList => tmp list for visits if its Lead does not have such device
	 *
	 * devicesToInsert => list for the new devices
	 */

	List<Recognized_Visits__c> visitListToInsert = new List<Recognized_Visits__c>();
	List<Recognized_Visits__c> visitListToDelete = new List<Recognized_Visits__c>();
	List<Recognized_Visits__c> visitNotMappedAccountList = new List<Recognized_Visits__c>();
	List<Recognized_Visits__c> visitNotMappedLeadList = new List<Recognized_Visits__c>();
	List<Lead> leadToUpdateWithUtmFromVisits = new List<Lead>();
	Map<String, Recognized_Visit_Device__c> devicesToInsertMap = new Map<String, Recognized_Visit_Device__c>();
	//device Id => values Map {OS => value, DateTime(LastVisit) => value}
	Map<Id, Map<String, String>> devicesToUpdateMap = new Map<Id, Map<String, String>>();

	List<Recognized_Visits__c> newVisits = [
		SELECT Id, Name, Customer_Contact__c, Lead__c, User_Email_Address__c, User_Device__c, User_Operating_System__c, Recognized_Visit_Device__c, Date_and_Time__c,
			utm_campaign__c, utm_content__c, utm_medium__c, utm_source__c, Utm_Term__c
		FROM Recognized_Visits__c
		WHERE Id IN :Trigger.newMap.keySet()
	];

	for (Recognized_Visits__c aVisit : newVisits) {

		if (String.isBlank(aVisit.User_Device__c)) {
			aVisit.User_Device__c = 'Unknown Device';
		}

		if (String.isBlank(aVisit.User_Operating_System__c)) {
			aVisit.User_Operating_System__c = 'Unknown Operating System';
		}

		//ACCOUNT mapping if email address is in account map
		if (emailToAccIdMap.containsKey(aVisit.User_Email_Address__c.toLowerCase())) {
			aVisit.Customer_Contact__c = emailToAccIdMap.get(aVisit.User_Email_Address__c);

			//check devices
			Boolean isThisAccountHasThisDevice = (
				objectIdToDeviceNameMap.containsKey(aVisit.Customer_Contact__c)
				&& objectIdToDeviceNameMap.get(aVisit.Customer_Contact__c)
					.containsKey(aVisit.User_Device__c.toLowerCase())
			);

			if (isThisAccountHasThisDevice) {
				//if same device already present, map it
				aVisit.Recognized_Visit_Device__c = objectIdToDeviceNameMap
					.get(aVisit.Customer_Contact__c)
					.get(aVisit.User_Device__c.toLowerCase());

				//Build Info about Operating System and Last Visit for existing Device to Update
				devicesToUpdateMap.put(aVisit.Recognized_Visit_Device__c, new Map<String, String> {'OS' => aVisit.User_Operating_System__c,
																									'DateTime' => aVisit.Date_and_Time__c.format()});
			}
			else {
				// create new device and related it to account
				// in case we have a few devices with the same name in one scope, use map with device name as a key
				// key for device is DeviceName__Os__CustomerId
				String customerNewDeviceUniqueKey = aVisit.User_Device__c + '__' + aVisit.User_Operating_System__c + '__' + aVisit.Customer_Contact__c;
				devicesToInsertMap.put(customerNewDeviceUniqueKey.toLowerCase(), new Recognized_Visit_Device__c(
					Name = aVisit.User_Device__c,
					Customer_Contact__c = aVisit.Customer_Contact__c,
					Operating_System__c = aVisit.User_Operating_System__c,
					Last_Visit__c = aVisit.Date_and_Time__c
				));
				//hold non mapped visit
				visitNotMappedAccountList.add(aVisit);
				//skip adding visit to crrect mapped visits list
				continue;
			}

			//hold mapped to corect devices visits
			visitListToInsert.add(aVisit);

			//do not check lead if pa found
			continue;
		}
		//LEAD mapping if email address is in lead map
		if (emailToLeadIdMap.containsKey(aVisit.User_Email_Address__c.toLowerCase())) {
			aVisit.Lead__c = emailToLeadIdMap.get(aVisit.User_Email_Address__c);
			// Lets check if a Lead has empty utm, if it is, and visit has at least one utm set,
			// we need to update Lead
			Boolean hasVisitAtLeastOneUtm = (
				String.isNotBlank(aVisit.utm_campaign__c) ||
				String.isNotBlank(aVisit.utm_content__c) ||
				String.isNotBlank(aVisit.utm_medium__c) ||
				String.isNotBlank(aVisit.utm_source__c) ||
				String.isNotBlank(aVisit.Utm_Term__c)
			);

			Boolean isVisitOptin = (aVisit.Name.toLowerCase() == 'optin');

			// if one lead has a few visits and all of them has different utms. how to choose?
			// it will be the FIRST visit with optin name
			if (leadWithEmptyUtmIdToLeadMap.containsKey(aVisit.Lead__c) && isVisitOptin && hasVisitAtLeastOneUtm) {
				Lead aLeadToUpdate = leadWithEmptyUtmIdToLeadMap.remove(aVisit.Lead__c);
				// just copy all utm from visit to lead
				aLeadToUpdate.utm_campaign__c = aVisit.utm_campaign__c;
				aLeadToUpdate.utm_content__c = aVisit.utm_content__c;
				aLeadToUpdate.utm_medium__c = aVisit.utm_medium__c;
				aLeadToUpdate.utm_source__c = aVisit.utm_source__c;
				aLeadToUpdate.utm_term__c = aVisit.Utm_Term__c;
				// put lead to map for update
				leadToUpdateWithUtmFromVisits.add(aLeadToUpdate);
			}

			//check devices
			Boolean isThisLeadHasThisDevice = (
				objectIdToDeviceNameMap.containsKey(aVisit.Lead__c)
				&& objectIdToDeviceNameMap.get(aVisit.Lead__c)
					.containsKey(aVisit.User_Device__c.toLowerCase())
			);

			if (isThisLeadHasThisDevice) {
				//if same device already present, map it
				aVisit.Recognized_Visit_Device__c = objectIdToDeviceNameMap
					.get(aVisit.Lead__c)
					.get(aVisit.User_Device__c.toLowerCase());

				//Build Info about Operating System and Last Visit for existing Device to Update
				devicesToUpdateMap.put(aVisit.Recognized_Visit_Device__c, new Map<String, String> {'OS' => aVisit.User_Operating_System__c,
																							'DateTime' => aVisit.Date_and_Time__c.format()});
			}
			else {
				//create new device and related it to Lead
				String leadNewDeviceUniqueKey = aVisit.User_Device__c + '__' + aVisit.User_Operating_System__c + '__' + aVisit.Lead__c;
				devicesToInsertMap.put(leadNewDeviceUniqueKey.toLowerCase() ,new Recognized_Visit_Device__c(
					Name = aVisit.User_Device__c,
					Lead__c = aVisit.Lead__c,
					Operating_System__c = aVisit.User_Operating_System__c,
					Last_Visit__c = aVisit.Date_and_Time__c
				));
				//hold non mapped visit
				visitNotMappedLeadList.add(aVisit);
				//skip adding visit to crrect mapped visits list
				continue;
			}

			//hold mapped to corect devices visits
			visitListToInsert.add(aVisit);
			continue;
		}

		//if we got here not insert record
		visitListToDelete.add(aVisit);
	}

	/**
	 * DML SECTION
	 */

	 // Update devices info
	if (!devicesToUpdateMap.isEmpty()) {
		Set<Id> devicesToUpdateIds = devicesToUpdateMap.keySet();
		List<Recognized_Visit_Device__c> relatedDevices = [SELECT Id, Operating_System__c, Last_Visit__c
															FROM Recognized_Visit_Device__c
															WHERE Id IN : devicesToUpdateIds];
		for (Recognized_Visit_Device__c device : relatedDevices) {
			device.Operating_System__c = devicesToUpdateMap.get(device.Id).get('OS');
			device.Last_Visit__c = DateTime.parse( devicesToUpdateMap.get(device.Id).get('DateTime') );
		}
		if (!relatedDevices.isEmpty()) {
			Database.update(relatedDevices, false);
		}
	}

	//insert new devices first,
	//then relate and insert visits
	if (!devicesToInsertMap.isEmpty()) {
		//if there are new devices
		Database.insert(devicesToInsertMap.values(), false);
	}

	//update objectIdToDeviceNameMap with new devices
	for (Recognized_Visit_Device__c aDevice: devicesToInsertMap.values()) {
		//if device related to account
		if (aDevice.Customer_Contact__c != null) {
			if (objectIdToDeviceNameMap.containsKey(aDevice.Customer_Contact__c)) {
				//if Account already has another devices and present in map then just add new device
				objectIdToDeviceNameMap
				.get(aDevice.Customer_Contact__c)
				.put(aDevice.Name.toLowerCase(), aDevice.Id);
			}
			else {
				//add new Account with devices
				objectIdToDeviceNameMap
				.put(aDevice.Customer_Contact__c, new Map<String, Id> {aDevice.Name.toLowerCase() => aDevice.Id});
			}
		}
		//if device related to lead
		if (aDevice.Lead__c != null) {
			if (objectIdToDeviceNameMap.containsKey(aDevice.Lead__c)) {
				//if Lead already has another devices and present in map then just add new device
				objectIdToDeviceNameMap
				.get(aDevice.Lead__c)
				.put(aDevice.Name.toLowerCase(), aDevice.Id);
			}
			else {
				//add new Lead with devices
				objectIdToDeviceNameMap
				.put(aDevice.Lead__c, new Map<String, Id> {aDevice.Name.toLowerCase() => aDevice.Id});
			}
		}
	}

	//Map nonmapped visits to newly created devices
	//Account related visits
	for (Recognized_Visits__c aVisitNotMapedAccount : visitNotMappedAccountList) {
		if (objectIdToDeviceNameMap.containsKey(aVisitNotMapedAccount.Customer_Contact__c)) {
			aVisitNotMapedAccount.Recognized_Visit_Device__c = objectIdToDeviceNameMap
				.get(aVisitNotMapedAccount.Customer_Contact__c)
				.get(aVisitNotMapedAccount.User_Device__c.toLowerCase());

			visitListToInsert.add(aVisitNotMapedAccount);
		}
	}

	//Lead related visits
	for (Recognized_Visits__c aVisitNotMapedLead : visitNotMappedLeadList) {
		if (objectIdToDeviceNameMap.containsKey(aVisitNotMapedLead.Lead__c)) {
			aVisitNotMapedLead.Recognized_Visit_Device__c = objectIdToDeviceNameMap
				.get(aVisitNotMapedLead.Lead__c)
				.get(aVisitNotMapedLead.User_Device__c.toLowerCase());
			visitListToInsert.add(aVisitNotMapedLead);
		}
	}

	if (!visitListToInsert.isEmpty()) {
		Database.update(visitListToInsert, false);
	}

	// update leads with copied utm from visits
	if (!leadToUpdateWithUtmFromVisits.isEmpty()) {
		Database.update(leadToUpdateWithUtmFromVisits, false);
	}

	if (!visitListToDelete.isEmpty()) {
		Database.delete(visitListToDelete, false);
	}
}