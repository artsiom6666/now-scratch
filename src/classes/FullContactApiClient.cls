public with sharing class FullContactApiClient {

	public static final String LOGS_SECTION = 'logs';
	public static final String OBJECT_SECTION = 'object';

	/**
	 * @description append data to aObject brought back from FullContact API
	 * @param  aObject is SObject for appending data
	 * @return result map where keys are:
	 * 'object' modified sobject with appended data
	 * 'logs' list of logs records for each callout
	 */
	public static Map<String, List<SObject>> makeAppend(SObject aObject) {
		Map<String, List<SObject>> result = new Map<String, List<SObject>>();
		FullContactDTO.FullContactSettings settings = TouchCRConfigurationController.initSettingsFC();
		List<Log__c> calloutLogs = new List<Log__c>();
		List<Case> correctionsCases = new List<Case>();
		// Proxy
		TouchCR_Settings__c proxySettings = TouchCR_Settings__c.getValues('Proxy.isEnabled');
		Boolean isProxyEnabled = false;
		if (proxySettings != null) {
			isProxyEnabled = Boolean.valueOf(proxySettings.Value__c);
		}

		// Skip Amazon Customers
		Boolean validEmail = isValidForEmailAppend(aObject);
		//in every append set need to append to false
		aObject.put('Append_Need_Append__c', false);
		
		//Email valid?
		if (validEmail) {
			FullContactApi api = (isProxyEnabled) ? new FullContactApi('callout:TouchCRBase__SecureProxy/v2/person.json') : new FullContactApi();
			api.setObject(aObject);
			api.callApi();
			calloutLogs.add(api.logCall());
			aObject = api.appendData();

		}
		result.put(OBJECT_SECTION, new List<SObject> {aObject});
		result.put(LOGS_SECTION, calloutLogs);

		return result;
	}

	/**
	 * @description create soql string for fullcontact request. it can be Lead or Account
	 * @param  SObject
	 * @return soql string without where clause
	 */
	public static String getSoqlStringWithoutWhereClause(SObject aObject) {
		return getSoqlStringWithoutWhereClause(aObject.getSobjectType());
	}

	/**
	 * @description create soql string for fullcontact request. it can be Lead or Account
	 * @param  Id
	 * @return soql string without where clause
	 */
	public static String getSoqlStringWithoutWhereClause(Id aObjectId) {
		return getSoqlStringWithoutWhereClause(aObjectId.getSobjectType());
	}

	public static String getSoqlStringWithoutWhereClause(Schema.SObjectType objectType) {
		String result = 'SELECT Id, ';

		if (objectType == Schema.Account.getSObjectType()) {
			result += 'PersonEmail';
		}
		if (objectType == Schema.Lead.getSObjectType()) {
			result += 'Email';
		}
		result += ' FROM ' + objectType.getDescribe().getName();
		return result;
	}

	/**
	 * @description If settings "FullContact.D." older than 24 hours - removes.
	 * Returns the current settings.
	 * @param  Datetime
	 * @return Map<String, TouchCR_Settings__c>
	 */
	public static Map<String, TouchCR_Settings__c> selectAndDeleteSettings(Datetime startBatch) {
		Map<String, TouchCR_Settings__c> results = new Map<String, TouchCR_Settings__c>();
		List<TouchCR_Settings__c> deleteRecords = new List<TouchCR_Settings__c>();
		List<TouchCR_Settings__c> allSettings  = [
			SELECT Id, Name, CreatedDate, Value__c
			FROM TouchCR_Settings__c
			WHERE Name LIKE: TouchCRConfigurationController.FULLCONTACT_SETTINGS_PREFIX + '%'
		];

		for (TouchCR_Settings__c item : allSettings) {
			Datetime createdDateSetting = item.CreatedDate;

			if (createdDateSetting.addHours(24) < startBatch && item.Name.contains(TouchCRConfigurationController.FULLCONTACT_DATE_SETTINGS_PREFIX)) {
				deleteRecords.add(item);
			}
			else {
				results.put(item.Name, item);
			}
		}
		if (!deleteRecords.isEmpty()) {
			try {
				SFDCAccessController.DeleteWithoutSharing (
					deleteRecords,
					'FullContactApiClient.cls [selectAndDeleteSettings]'
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}
		return results;
	}

	/**
	 * @description Send email for approval
	 * @param  Map<String, TouchCR_Settings__c> allDataSettings
	 * @param  Integer excess - excess records
	 */
	public static void sendEmailToApprove(Map<String, TouchCR_Settings__c> allDataSettings, Integer excess) {
		List<String> userEmails = new List<String>();
		//Mail first approver
		if (allDataSettings.containsKey('DataAppend.ApproverEmail1')) {
			if (String.isNotBlank(allDataSettings.get('DataAppend.ApproverEmail1').Value__c)) {
				userEmails.add(allDataSettings.get('DataAppend.ApproverEmail1').Value__c);
			}
		}
		//Mail second approver
		if (allDataSettings.containsKey('DataAppend.ApproverEmail2')) {
			if (String.isNotBlank(allDataSettings.get('DataAppend.ApproverEmail2').Value__c)) {
				userEmails.add(allDataSettings.get('DataAppend.ApproverEmail2').Value__c);
			}
		}
		//Mail third approver
		if (allDataSettings.containsKey('DataAppend.ApproverEmail3')) {
			if (String.isNotBlank(allDataSettings.get('DataAppend.ApproverEmail3').Value__c)) {
				userEmails.add(allDataSettings.get('DataAppend.ApproverEmail3').Value__c);
			}
		}

		if (!userEmails.isEmpty()) {
			try {
				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
				message.toAddresses = userEmails;
				message.optOutPolicy = 'FILTER';
				message.subject = 'Request for Approval of Limits';
				message.plainTextBody = 'The Data Append (Social Append) process is currently stopped due the exceeding the limit. ' + excess + ' record(s) are pending for Approval: ' +
					URL.getSalesforceBaseUrl().toExternalForm() + Page.TouchCRConfiguration.getUrl();
				Messaging.SingleEmailMessage[] messages =
					new List<Messaging.SingleEmailMessage> {message};
				if (Test.isRunningTest()) {
					insert new Log__c(
						Event_Type__c = 'FC Append Limits email',
						Event_Description__c = 'The Data Append (Social Append) process is currently stopped due the exceeding the limit. ' + excess +
					' record(s) are pending for Approval: ' + URL.getSalesforceBaseUrl().toExternalForm() + Page.TouchCRConfiguration.getUrl());
				}
				else {
					Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
				}
			} catch (Exception e) {
				insert new Log__c(
					Event_Type__c = 'FC Append Limits email',
					Event_Description__c = 'The Data Append (Social Append) process is currently stopped due the exceeding the limit. ' + excess +
					' record(s) are pending for Approval: ' + URL.getSalesforceBaseUrl().toExternalForm() + Page.TouchCRConfiguration.getUrl(),
					Description__c = e.getMessage()
				);
			}
		}
	}

	/**
	 * @description Method updates 'FullContact.Excess' and 'FullContact.Confirmed' Settings
	 * @param  Map<String, TouchCR_Settings__c> allDataSettings
	 * @param  Integer excess - excess records
	 */
	public static void upsertTouchCRSettings(Map<String, TouchCR_Settings__c> allDataSettings, Integer excess) {
		List<TouchCR_Settings__c> deleteRecords = new List<TouchCR_Settings__c>();
		List<TouchCR_Settings__c> insertRecords = new List<TouchCR_Settings__c>();
		//Delete the settings if they already have
		if (allDataSettings.containsKey('FullContact.Excess')) {
			TouchCR_Settings__c deleteRecord = allDataSettings.get('FullContact.Excess');
			deleteRecords.add(deleteRecord);
		}

		TouchCR_Settings__c newExcess = new TouchCR_Settings__c(
			Name = 'FullContact.Excess',
			Value__c = String.valueOf(excess)
		);
		insertRecords.add(newExcess);

		if (allDataSettings.containsKey('FullContact.Confirmed')) {
			TouchCR_Settings__c deleteRecord = allDataSettings.get('FullContact.Confirmed');
			deleteRecords.add(deleteRecord);
		}

		TouchCR_Settings__c newConfirmed = new TouchCR_Settings__c(
			Name = 'FullContact.Confirmed',
			Value__c = 'false'
		);
		insertRecords.add(newConfirmed);

		try {
			if (!deleteRecords.isEmpty()) {
				SFDCAccessController.DeleteWithoutSharing (
					deleteRecords,
					'FullContactApiClient.cls [upsertTouchCRSettings]'
				);
			}
			SFDCAccessController.InsertWithoutSharing (
				insertRecords,
				'FullContactApiClient.cls [upsertTouchCRSettings]',
				new List<Schema.DescribeFieldResult> {
					TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
				}
			);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	public static Boolean isApproved(Map<String, TouchCR_Settings__c> allDataSettings) {
		DateTime dateTimeToApprove;
		Boolean isApproved = false;
		if (allDataSettings.containsKey('FullContact.DateTimeApprove')) {
			if (String.isNotBlank(allDataSettings.get('FullContact.DateTimeApprove').Value__c)) {
				dateTimeToApprove = DateTime.valueOf(allDataSettings.get('FullContact.DateTimeApprove').Value__c);
			}
		}

		//get the dateTimeToApprove if you pressed "Approve"
		if (dateTimeToApprove != null) {
			isApproved = dateTimeToApprove.addHours(24) > DateTime.now();
		}
		return isApproved;
	}

	/**
	 * @description Method checked existing limits.
	 * @param  Map<String, TouchCR_Settings__c> allDataSettings
	 * @return Integer limitRecords
	 */
	public static Integer getLimits(Map<String, TouchCR_Settings__c> allDataSettings) {
		Integer limitRecords = 0;
		if (allDataSettings.containsKey('FullContact.Limit')) {
			if (String.isNotBlank(allDataSettings.get('FullContact.Limit').Value__c)) {
				limitRecords = Integer.valueOf(allDataSettings.get('FullContact.Limit').Value__c);
			}
		}
		return limitRecords;
	}

	/**
	 * @description Method creates the settings for new entries
	 * @param  Map<String, TouchCR_Settings__c> allDataSettings
	 * @param  Integer - number of records you want to process
	 */
	public static void setDaySettings(Map<String, TouchCR_Settings__c> allDataSettings, Integer countRecords) {
		TouchCR_Settings__c countRecordsSetting = new TouchCR_Settings__c();
			countRecordsSetting.Name = TouchCRConfigurationController.FULLCONTACT_DATE_SETTINGS_PREFIX + DateTime.now();

		//That would not create two TouchCR Settings in one DateTime.now()
		if (allDataSettings.containsKey(TouchCRConfigurationController.FULLCONTACT_DATE_SETTINGS_PREFIX + DateTime.now())) {
			Integer oldValue = Integer.valueOf(allDataSettings.get(TouchCRConfigurationController.FULLCONTACT_DATE_SETTINGS_PREFIX + DateTime.now()).Value__c);
			//Delete the settings if they already have
			TouchCR_Settings__c deleteRecord = allDataSettings.get(TouchCRConfigurationController.FULLCONTACT_DATE_SETTINGS_PREFIX + DateTime.now());
			try {
				SFDCAccessController.DeleteWithoutSharing (
					deleteRecord,
					'FullContactApiClient.cls [setDaySettings]'
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
			//merge records processed at one time
			countRecordsSetting.Value__c = String.valueOf(countRecords + oldValue);
		}
		else {
			countRecordsSetting.Value__c = String.valueOf(countRecords);
		}
		try {
			SFDCAccessController.InsertWithoutSharing (
				countRecordsSetting,
				'FullContactApiClient.cls [setDaySettings]',
				new List<Schema.DescribeFieldResult> {
					TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
				}
			);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	// HELPERS
	public static Boolean isValidForEmailAppend(SObject aObject) {
		if (aObject.getSObjectType() == Schema.Lead.getSObjectType()) {
			Lead aLead = (Lead) aObject;
			return (String.isBlank(aLead.Email)) ? false : true;
		}
		else if (aObject.getSObjectType() == Schema.Account.getSObjectType()) {
			Account aAccount = (Account) aObject;
			return (String.isBlank(aAccount.PersonEmail)) ? false : true;
		}
		else {
			return false;
		}
	}
}