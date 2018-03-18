public with sharing class TowerDataApiClient {

	public static final String LOGS_SECTION = 'logs';
	public static final String OBJECT_SECTION = 'object';
	public static final String CASE_SECTION = 'case';
	public static final String AMAZON_EMAIL = 'marketplace.amazon.com';

	/**
	 * @description append data to aObject brought back from TowerData API
	 * @param  aObject is SObject for appending data
	 * @return result map where keys are:
	 * 'object' modified sobject with appended data
	 * 'logs' list of logs records for each callout
	 */
	public static Map<String, List<SObject>> makeAppend(SObject aObject) {
		Map<String, List<SObject>> result = new Map<String, List<SObject>>();
		TowerDataDTO.TowerDataSettings settings = TouchCRConfigurationController.initSettings();
		List<Log__c> calloutLogs = new List<Log__c>();
		List<Case> correctionsCases = new List<Case>();
		Boolean enableEmail = false;
		Boolean enableDemo = false;
		// Proxy
		TouchCR_Settings__c proxySettings = TouchCR_Settings__c.getValues('Proxy.isEnabled');
		Boolean isProxyEnabled = false;
		if (proxySettings != null) {
			isProxyEnabled = Boolean.valueOf(proxySettings.Value__c);
		}
		// Email scoring
		Boolean requestHttpStatusOK = false;

		// Skip Amazon Customers
		Boolean validEmail = isValidForEmailAppend(aObject);

		//in every append set need to append to false
		aObject.put('Append_Need_Append__c', false);

		if (aObject.getSObjectType() == Schema.Account.getSObjectType()) {
			//set flag for email section
			enableEmail = settings.accountAppendEmailOn;
			//set flag for demo section
			enableDemo = settings.accountEnableDemo;
		}
		if (aObject.getSObjectType() == Schema.Lead.getSObjectType()) {
			//set flag for email section
			enableEmail = settings.leadAppendEmailOn;
			//set flag for demo section
			enableDemo = settings.leadEnableDemo;
		}

		//callout allowed?
		if (settings.appendOn) {
			//email section
			if (enableEmail && validEmail) {
				TowerDataApi api = (isProxyEnabled) ? new TowerDataApi('callout:TouchCRBase__SecureProxy/person') : new TowerDataApi();
				api.setObject(aObject);
				api.callApi();
				calloutLogs.add(api.logCall());
				aObject = api.appendData();
				if (api.getHttpStatusCode() == 200) {
					requestHttpStatusOK = true;
				}
			}
			//demo section
			if (enableDemo) {
				TowerDataApiDemo api = (isProxyEnabled) ? new TowerDataApiDemo('callout:TouchCRBase__SecureProxy/emailcheck') : new TowerDataApiDemo();
				api.setObject(aObject);
				api.callApi();
				calloutLogs.add(api.logCall());
				aObject = api.appendData();
				if (api.getHttpStatusCode() == 200) {
					requestHttpStatusOK = true;
				}
			}
		}
		//correct email?
		if (aObject.getSObjectType() == Schema.Account.getSObjectType() && aObject.get('Email_Corrections__c') != null) {
			correctionsCases.add(callCase(aObject));
		}
		result.put(OBJECT_SECTION, new List<SObject> {aObject});
		result.put(LOGS_SECTION, calloutLogs);
		result.put(CASE_SECTION, correctionsCases);

		// Email scoring
		if (requestHttpStatusOK) {
			// either one of TD successful requests is enough to calculate eamil score
			result = EmailQualityScore.scoreEmailQuality(result);
		}

		return result;
	}

	/**
	 * @description create soql string for towerdata request. it can be Lead or Account
	 * @param  SObject
	 * @return soql string without where clause
	 */
	public static String getSoqlStringWithoutWhereClause(SObject aObject) {
		return getSoqlStringWithoutWhereClause(aObject.getSobjectType());
	}

	/**
	 * @description create soql string for towerdata request. it can be Lead or Account
	 * @param  Id
	 * @return soql string without where clause
	 */
	public static String getSoqlStringWithoutWhereClause(Id aObjectId) {
		return getSoqlStringWithoutWhereClause(aObjectId.getSobjectType());
	}

	public static String getSoqlStringWithoutWhereClause(Schema.SObjectType objectType) {
		String result = 'SELECT Id, FirstName, LastName, EAM_Date_First_Seen__c, EAM_Month_Last_Opened__c, EAM_Velocity__c, EAM_Popularity__c, Email_Box_Valid__c, Email_Valid__c,';

		if (objectType == Schema.Account.getSObjectType()) {
			String codeFields = TouchCRHelper.isSCPEnabled() == TRUE ? ' ,BillingStateCode ' : '';
			result += ' PersonEmail, BillingStreet, BillingCity, BillingPostalCode ' + codeFields;
		}
		if (objectType == Schema.Lead.getSObjectType()) {
			String codeFields = TouchCRHelper.isSCPEnabled() == TRUE ? ' ,StateCode ' : '';
			result += ' Email, Street, City, PostalCode ' + codeFields;
		}
		result += ' FROM ' + objectType.getDescribe().getName();
		return result;
	}

	//Created new Case for not correct Email
	public static Case callCase(SObject aObject) {
		Case caseRecord = new Case(
			Subject = 'Correction Email', AccountId = (Id) aObject.Id,
			Description = (String) aObject.get('Email_Corrections__c'),
			Status = 'New', Origin = 'Email'
		);
		return caseRecord;
	}

	/**
	 * @description If settings "DataAppend.D." older than 24 hours - removes.
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
			WHERE Name LIKE: TouchCRConfigurationController.DATAAPPEND_SETTINGS_PREFIX + '%'
		];

		for (TouchCR_Settings__c item : allSettings) {
			Datetime createdDateSetting = item.CreatedDate;

			if (createdDateSetting.addHours(24) < startBatch && item.Name.contains(TouchCRConfigurationController.DATAAPPEND_DATE_SETTINGS_PREFIX)) {
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
					'TowerDataApiClient.cls [selectAndDeleteSettings]'
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
				message.plainTextBody = 'The Data Append (Email Append) process is currently stopped due the exceeding the limit. ' + excess + ' record(s) are pending for Approval: ' +
					URL.getSalesforceBaseUrl().toExternalForm() + Page.TouchCRConfiguration.getUrl();
				Messaging.SingleEmailMessage[] messages =
					new List<Messaging.SingleEmailMessage> {message};
				if (Test.isRunningTest()) {
					insert new Log__c(
						Event_Type__c = 'TD Append Limits email',
						Event_Description__c = 'The Data Append (Email Append) process is currently stopped due the exceeding the limit. ' + excess +
					' record(s) are pending for Approval: ' + URL.getSalesforceBaseUrl().toExternalForm() + Page.TouchCRConfiguration.getUrl());
				}
				else {
					Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
				}
			} catch (Exception e) {
				insert new Log__c(
					Event_Type__c = 'TD Append Limits email',
					Event_Description__c = 'The Data Append (Email Append) process is currently stopped due the exceeding the limit. ' + excess +
					' record(s) are pending for Approval: ' + URL.getSalesforceBaseUrl().toExternalForm() + Page.TouchCRConfiguration.getUrl(),
					Description__c = e.getMessage()
				);
			}
		}
	}

	/**
	 * @description Method updates 'DataAppend.Excess' and 'DataAppend.Confirmed' Settings
	 * @param  Map<String, TouchCR_Settings__c> allDataSettings
	 * @param  Integer excess - excess records
	 */
	public static void upsertTouchCRSettings(Map<String, TouchCR_Settings__c> allDataSettings, Integer excess) {
		List<TouchCR_Settings__c> deleteRecords = new List<TouchCR_Settings__c>();
		List<TouchCR_Settings__c> insertRecords = new List<TouchCR_Settings__c>();
		//Delete the settings if they already have
		if (allDataSettings.containsKey('DataAppend.Excess')) {
			TouchCR_Settings__c deleteRecord = allDataSettings.get('DataAppend.Excess');
			deleteRecords.add(deleteRecord);
		}

		TouchCR_Settings__c newExcess = new TouchCR_Settings__c(
			Name = 'DataAppend.Excess',
			Value__c = String.valueOf(excess)
		);
		insertRecords.add(newExcess);

		if (allDataSettings.containsKey('DataAppend.Confirmed')) {
			TouchCR_Settings__c deleteRecord = allDataSettings.get('DataAppend.Confirmed');
			deleteRecords.add(deleteRecord);
		}

		TouchCR_Settings__c newConfirmed = new TouchCR_Settings__c(
			Name = 'DataAppend.Confirmed',
			Value__c = 'false'
		);
		insertRecords.add(newConfirmed);

		try {
			if (!deleteRecords.isEmpty()) {
				SFDCAccessController.DeleteWithoutSharing (
					deleteRecords,
					'TowerDataApiClient.cls [upsertTouchCRSettings]'
				);
			}
			SFDCAccessController.InsertWithoutSharing (
				insertRecords,
				'TowerDataApiClient.cls [upsertTouchCRSettings]',
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
		if (allDataSettings.containsKey('DataAppend.DateTimeApprove')) {
			if (String.isNotBlank(allDataSettings.get('DataAppend.DateTimeApprove').Value__c)) {
				dateTimeToApprove = DateTime.valueOf(allDataSettings.get('DataAppend.DateTimeApprove').Value__c);
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
		if (allDataSettings.containsKey('DataAppend.Limit')) {
			if (String.isNotBlank(allDataSettings.get('DataAppend.Limit').Value__c)) {
				limitRecords = Integer.valueOf(allDataSettings.get('DataAppend.Limit').Value__c);
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
			countRecordsSetting.Name = TouchCRConfigurationController.DATAAPPEND_DATE_SETTINGS_PREFIX + DateTime.now();

		//That would not create two TouchCR Settings in one DateTime.now()
		if (allDataSettings.containsKey(TouchCRConfigurationController.DATAAPPEND_DATE_SETTINGS_PREFIX + DateTime.now())) {
			Integer oldValue = Integer.valueOf(allDataSettings.get(TouchCRConfigurationController.DATAAPPEND_DATE_SETTINGS_PREFIX + DateTime.now()).Value__c);
			//Delete the settings if they already have
			TouchCR_Settings__c deleteRecord = allDataSettings.get(TouchCRConfigurationController.DATAAPPEND_DATE_SETTINGS_PREFIX + DateTime.now());
			try {
				SFDCAccessController.DeleteWithoutSharing (
					deleteRecord,
					'TowerDataApiClient.cls [setDaySettings]'
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
				'TowerDataApiClient.cls [upsertTouchCRSettings]',
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