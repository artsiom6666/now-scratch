public with sharing class DataAppendBatch implements Database.Batchable<sObject>,  Database.Stateful, Database.AllowsCallouts {

	private Integer batchStep;
	private Boolean batchAllowExecuteTD;
	private Boolean batchAllowExecuteFC;

	public DataAppendBatch(Integer step) {
		this.batchStep = step;
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		//1) Pick up all accounts/leads that have Append_Need_Append__c = TRUE

		//2) Pick up all accounts/leads that have Append_Run_Date__c != null AND Append_Run_Date__c < DateTime.now() - Global.ReappendOnDays

		//3) Pick up all accounts/leads that have Append_Run_Date__c = null AND Append_Run_Date__c > Global.IgnoreOlderThan
		//4) Pick up all accounts/leads that have Append_Run__c = FALSE AND Append_Run_Date__c > Global.IgnoreOlderThan

		String soqlStr;
		Date reappendSince = null;
		Date ignoreOlderThan = null;
		Boolean isReappendOnDays = false;
		Boolean isIgnoreOlderThan = false;

		//check allow to execute TowerData
		Map<String, String> getSettingsTD = TouchCRHelper.getSettings('DataAppend.');
		Boolean confirmedTD = getSettingsTD.containsKey('DataAppend.Confirmed') ? Boolean.valueOf(getSettingsTD.get('DataAppend.Confirmed')) : true;
		Map<String, TouchCR_Settings__c> personDAApprovedSettings = TouchCRConfigurationController.getSettings(TouchCRConfigurationController.APPROVED_SETTING.keySet());
		Boolean enableExecuteDataAppend = personDAApprovedSettings.get('DataAppend.EnableExecute').Value__c != null ? Boolean.valueOf(personDAApprovedSettings.get('DataAppend.EnableExecute').Value__c) : false;
		batchAllowExecuteTD = ((enableExecuteDataAppend && confirmedTD) || Test.isRunningTest()) ? true : false;


		//check allow to execute FullContact
		Map<String, String> getSettingsFC = TouchCRHelper.getSettings('FullContact.');
		Boolean confirmedFC = getSettingsFC.containsKey('FullContact.Confirmed') ? Boolean.valueOf(getSettingsFC.get('FullContact.Confirmed')) : true;
		Map<String, TouchCR_Settings__c> personFCApprovedSettings = TouchCRConfigurationController.getSettings(TouchCRConfigurationController.FULLCONTACT_APPROVED_SETTING.keySet());
		Boolean enableExecuteFullContact = personFCApprovedSettings.get('FullContact.EnableExecute').Value__c != null ? Boolean.valueOf(personFCApprovedSettings.get('FullContact.EnableExecute').Value__c) : false;
		batchAllowExecuteFC = ((enableExecuteFullContact && confirmedFC) || Test.isRunningTest()) ? true : false;


		TowerDataDTO.TowerDataSettings settings = TouchCRConfigurationController.initSettings();
		if (settings.reappendOnDays > 0) {
			reappendSince = DateTime.now().date().addDays(-settings.reappendOnDays);
			isReappendOnDays = true;
		}
		if (settings.appendIgnoreOlderThan != null) {
			ignoreOlderThan = settings.appendIgnoreOlderThan;
			isIgnoreOlderThan = true;
		}
		//account
		if (batchStep == 1) {
			soqlStr = TowerDataAPIClient.getSoqlStringWithoutWhereClause(Schema.Account.getSObjectType());
			// Amazon Customer has empty PersonEmail, workaround for all accounts
			soqlStr += ' WHERE RecordType.DeveloperName = \'Customer_Account\' ';
		}
		//lead
		else if (batchStep == 2) {
			soqlStr = TowerDataAPIClient.getSoqlStringWithoutWhereClause(Schema.Lead.getSObjectType());
			soqlStr += ' WHERE Email != NULL';
		}
		// always process records marked as need to append
		soqlStr += ' AND (Append_Need_Append__c = TRUE';
		// if reappend on days is set
		// append on any previously appended records where time since last append > set in settings
		if (isReappendOnDays) {
			soqlStr += ' OR (Append_Run_Date__c != null AND Append_Run_Date__c < :reappendSince)';
		}
		if (isIgnoreOlderThan) {
			soqlStr += ' OR (Append_Run_Date__c = null AND CreatedDate > :ignoreOlderThan)';
			soqlStr += ' OR (Append_Run__c = FALSE AND CreatedDate > :ignoreOlderThan)';
		}
		soqlStr += ' )';

		Database.QueryLocator ql = Database.getQueryLocator(soqlStr);
		Database.QueryLocatorIterator it =  ql.iterator();

		//Number of records to be processed in this batch
		Integer countRecords = 0;
		while (it.hasNext()) {
			if (batchStep == 1) {
				Account a = (Account)it.next();
				countRecords = countRecords + 1;
			}
			else if (batchStep == 2) {
				Lead l = (Lead)it.next();
				countRecords = countRecords + 1;
			}
		}

		//LIMIT check TowerData
		Map<String, TouchCR_Settings__c> allDataSettingsTD = TowerDataApiClient.selectAndDeleteSettings(DateTime.now());

		Integer totalRecordsTD = 0;
		//Records processed in 24 hours
		for (TouchCR_Settings__c item : allDataSettingsTD.values()) {
			if (item.Name.contains(TouchCRConfigurationController.DATAAPPEND_DATE_SETTINGS_PREFIX)) {
				totalRecordsTD = totalRecordsTD + Integer.valueOf(item.Value__c);
			}
		}

		//Get the value of the limits from settings
		Integer limitRecordsTD = TowerDataApiClient.getLimits(allDataSettingsTD);
		Boolean approvedTD = TowerDataApiClient.isApproved(allDataSettingsTD);

		//Check the allowed limits before execute
		if (countRecords + totalRecordsTD > limitRecordsTD && !approvedTD) {
			//Upsert "Excess" and "Confirmed" Settings
			TowerDataApiClient.upsertTouchCRSettings(allDataSettingsTD, totalRecordsTD + countRecords - limitRecordsTD);
			//Only send in the second step
			if (batchStep == 2) {
				//Sending a letter with notification
				TowerDataApiClient.sendEmailToApprove(allDataSettingsTD, totalRecordsTD + countRecords - limitRecordsTD);
			}
			batchAllowExecuteTD = false;
		} else {
			TowerDataApiClient.setDaySettings(allDataSettingsTD, countRecords);
		}


		//LIMIT check FullContact
		Map<String, TouchCR_Settings__c> allDataSettingsFC = FullContactApiClient.selectAndDeleteSettings(DateTime.now());

		Integer totalRecordsFC = 0;
		//Records processed in 24 hours
		for (TouchCR_Settings__c item : allDataSettingsFC.values()) {
			if (item.Name.contains(TouchCRConfigurationController.FULLCONTACT_DATE_SETTINGS_PREFIX)) {
				totalRecordsFC = totalRecordsFC + Integer.valueOf(item.Value__c);
			}
		}

		//Get the value of the limits from settings
		Integer limitRecordsFC = FullContactApiClient.getLimits(allDataSettingsFC);
		Boolean approvedFC = FullContactApiClient.isApproved(allDataSettingsFC);

		//Check the allowed limits before execute
		if (countRecords + totalRecordsFC > limitRecordsFC && !approvedFC) {
			//Upsert "Excess" and "Confirmed" Settings
			FullContactApiClient.upsertTouchCRSettings(allDataSettingsFC, totalRecordsFC + countRecords - limitRecordsFC);
			//Only send in the second step
			if (batchStep == 2) {
				//Sending a letter with notification (allDataSettingsTD we have the same approvers)
				FullContactApiClient.sendEmailToApprove(allDataSettingsTD, totalRecordsFC + countRecords - limitRecordsFC);
			}
			batchAllowExecuteFC = false;
		} else {
			FullContactApiClient.setDaySettings(allDataSettingsFC, countRecords);
		}

		return ql;

	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		if (scope.size() > 0) {
			//get sobject and set need to append flag to false in any case
			SObject sObj = scope[0];

			//Execute and save TowerData results
			if (batchAllowExecuteTD) {
				Map<String, List<SObject>> appendResultTD = TowerDataAPIClient.makeAppend(sObj);
				if (sObj.getSObjectType() == Schema.Account.getSObjectType()) {
					try {
						SFDCAccessController.UpdateWithoutSharing (
							appendResultTD.get(TowerDataAPIClient.OBJECT_SECTION),
							'DataAppendBatch.cls [execute]',
							new List<Schema.DescribeFieldResult> {
								Account.Email_Append_Run__c.getDescribe(), Account.Email_Append_Run_Date__c.getDescribe(),
								Account.Email_Checked__c.getDescribe(), Account.Email_Valid__c.getDescribe(),
								Account.Email_Box_Valid__c.getDescribe(), Account.Email_Corrections__c.getDescribe(),
								Account.IP_Address_Location_City__c.getDescribe(), Account.IP_Address_Location_Region__c.getDescribe(),
								Account.IP_Address_Location_Country_Code__c.getDescribe(), Account.IP_Address_Location_Country_Name__c.getDescribe(),
								Account.Append_Address_Street__c.getDescribe(), Account.Append_Address_City__c.getDescribe(),
								Account.Append_Address_State__c.getDescribe(), Account.Append_Address_ZIp__c.getDescribe(),
								Account.Append_Demo_Age__c.getDescribe(), Account.Append_Demo_Gender__c.getDescribe(),
								Account.Append_Demo_Zip__c.getDescribe(), Account.Append_Demo_Education__c.getDescribe(),
								Account.Append_Demo_Net_Worth__c.getDescribe(), Account.Append_House_Value__c.getDescribe(),
								Account.Append_House_Owner_Status__c.getDescribe(), Account.Append_House_Income__c.getDescribe(),
								Account.Append_House_Length_of_Residence__c.getDescribe(), Account.Append_House_Marital_Status__c.getDescribe(),
								Account.Append_House_Occupation__c.getDescribe(), Account.Append_House_Children__c.getDescribe(),
								Account.EAM_Date_First_Seen__c.getDescribe(), Account.EAM_Velocity__c.getDescribe(),
								Account.EAM_Popularity__c.getDescribe(), Account.EAM_Month_Last_Opened__c.getDescribe(),
								Account.Append_Interest_Arts_Craft__c.getDescribe(), Account.Append_Interest_Blogging__c.getDescribe(),
								Account.Append_Interest_Books__c.getDescribe(), Account.Append_Interest_Business__c.getDescribe(),
								Account.Append_Interest_Health_Wellness__c.getDescribe(), Account.Append_Interest_News_Current_Affairs__c.getDescribe(),
								Account.Append_Purchase_Automotive__c.getDescribe(), Account.Append_Purchase_Baby_Product_Buyer__c.getDescribe(),
								Account.Append_Purchase_Beauty__c.getDescribe(), Account.Append_Purchase_Charitable_Doner__c.getDescribe(),
								Account.Append_Purchase_Cooking__c.getDescribe(), Account.Append_Purchase_Discount_Shopper__c.getDescribe(),
								Account.Append_Purchase_High_End_Brand_Buyer__c.getDescribe(), Account.Append_Purchase_Home_Garden__c.getDescribe(),
								Account.Append_Purchase_Home_Improvement__c.getDescribe(), Account.Append_Purchase_Luxury_Goods_Jewelry__c.getDescribe(),
								Account.Append_Purchase_Magazine_Buyer__c.getDescribe(), Account.Append_Purchase_Outdoor_Adventure__c.getDescribe(),
								Account.Append_Purchase_Pets__c.getDescribe(), Account.Append_Purchase_Sports__c.getDescribe(),
								Account.Append_Purchase_Technology__c.getDescribe(), Account.Append_Purchase_Travel__c.getDescribe(),
								Account.Append_Need_Append__c.getDescribe()
							}
						);
					}
					catch (Exception e) {throw new SFDCAccessControlException();}

				}
				if (sObj.getSObjectType() == Schema.Lead.getSObjectType()) {
					try {
						SFDCAccessController.UpdateWithoutSharing (
							appendResultTD.get(TowerDataAPIClient.OBJECT_SECTION),
							'DataAppendBatch.cls [execute]',
							new List<Schema.DescribeFieldResult> {
								Lead.Email_Append_Run__c.getDescribe(), Lead.Email_Append_Run_Date__c.getDescribe(),
								Lead.Email_Checked__c.getDescribe(), Lead.Email_Valid__c.getDescribe(),
								Lead.Email_Box_Valid__c.getDescribe(), Lead.Email_Corrections__c.getDescribe(),
								Lead.IP_Address_Location_City__c.getDescribe(), Lead.IP_Address_Location_Region__c.getDescribe(),
								Lead.IP_Address_Location_Country_Code__c.getDescribe(), Lead.IP_Address_Location_Country_Name__c.getDescribe(),
								Lead.Append_Address_Street__c.getDescribe(), Lead.Append_Address_City__c.getDescribe(),
								Lead.Append_Address_State__c.getDescribe(), Lead.Append_Address_ZIp__c.getDescribe(),
								Lead.Append_Demo_Age__c.getDescribe(), Lead.Append_Demo_Gender__c.getDescribe(),
								Lead.Append_Demo_Zip__c.getDescribe(), Lead.Append_Demo_Education__c.getDescribe(),
								Lead.Append_Demo_Net_Worth__c.getDescribe(), Lead.Append_House_Value__c.getDescribe(),
								Lead.Append_House_Owner_Status__c.getDescribe(), Lead.Append_House_Income__c.getDescribe(),
								Lead.Append_House_Length_of_Residence__c.getDescribe(), Lead.Append_House_Marital_Status__c.getDescribe(),
								Lead.Append_House_Occupation__c.getDescribe(), Lead.Append_House_Children__c.getDescribe(),
								Lead.EAM_Date_First_Seen__c.getDescribe(), Lead.EAM_Velocity__c.getDescribe(),
								Lead.EAM_Popularity__c.getDescribe(), Lead.EAM_Month_Last_Opened__c.getDescribe(),
								Lead.Append_Interest_Arts_Craft__c.getDescribe(), Lead.Append_Interest_Blogging__c.getDescribe(),
								Lead.Append_Interest_Books__c.getDescribe(), Lead.Append_Interest_Business__c.getDescribe(),
								Lead.Append_Interest_Health_Wellness__c.getDescribe(), Lead.Append_Interest_News_Current_Affairs__c.getDescribe(),
								Lead.Append_Purchase_Automotive__c.getDescribe(), Lead.Append_Purchase_Baby_Product_Buyer__c.getDescribe(),
								Lead.Append_Purchase_Beauty__c.getDescribe(), Lead.Append_Purchase_Charitable_Doner__c.getDescribe(),
								Lead.Append_Purchase_Cooking__c.getDescribe(), Lead.Append_Purchase_Discount_Shopper__c.getDescribe(),
								Lead.Append_Purchase_High_End_Brand_Buyer__c.getDescribe(), Lead.Append_Purchase_Home_Garden__c.getDescribe(),
								Lead.Append_Purchase_Home_Improvement__c.getDescribe(), Lead.Append_Purchase_Luxury_Goods_Jewelry__c.getDescribe(),
								Lead.Append_Purchase_Magazine_Buyer__c.getDescribe(), Lead.Append_Purchase_Outdoor_Adventure__c.getDescribe(),
								Lead.Append_Purchase_Pets__c.getDescribe(), Lead.Append_Purchase_Sports__c.getDescribe(),
								Lead.Append_Purchase_Technology__c.getDescribe(), Lead.Append_Purchase_Travel__c.getDescribe(),
								Lead.Append_Need_Append__c.getDescribe()
							}
						);
					}
					catch (Exception e) {throw new SFDCAccessControlException();}
				}

				if (!appendResultTD.get(TowerDataAPIClient.LOGS_SECTION).isEmpty()) {
					try {
						SFDCAccessController.InsertWithoutSharing (
							appendResultTD.get(TowerDataAPIClient.LOGS_SECTION),
							'DataAppendBatch.cls [execute]',
							new List<Schema.DescribeFieldResult> {
								Log__c.Event_Type__c.getDescribe(), Log__c.Event_Status__c.getDescribe(),
								Log__c.Event_Endpoint__c.getDescribe(), Log__c.Event_Description__c.getDescribe(),
								Log__c.Account__c.getDescribe(), Log__c.Lead__c.getDescribe()
							}
						);
					}
					catch (Exception e) {throw new SFDCAccessControlException();}
				}

				if (!appendResultTD.get(TowerDataAPIClient.CASE_SECTION).isEmpty() && sObj.getSObjectType() == Schema.Account.getSObjectType()) {
					try {
						SFDCAccessController.InsertWithoutSharing (
							appendResultTD.get(TowerDataAPIClient.CASE_SECTION),
							'DataAppendBatch.cls [execute]',
							new List<Schema.DescribeFieldResult> {
								Case.Subject.getDescribe(), Case.AccountId.getDescribe(),
								Case.Description.getDescribe(), Case.Status.getDescribe(),
								Case.Origin.getDescribe()
							}
						);
					}
					catch (Exception e) {throw new SFDCAccessControlException();}
				}
			}

			//Execute and save FullContact results
			if (batchAllowExecuteFC) {
				Map<String, List<SObject>> appendResultFC = FullContactApiClient.makeAppend(sObj);
				if (sObj.getSObjectType() == Schema.Account.getSObjectType()) {
					try {
						SFDCAccessController.UpdateWithoutSharing (
							appendResultFC.get(FullContactApiClient.OBJECT_SECTION),
							'DataAppendBatch.cls [execute]',
							new List<Schema.DescribeFieldResult> {
								Account.Append_Need_Append__c.getDescribe(),
								Account.Social_Append_Run_Date__c.getDescribe(),
								Account.Social_Append_Success__c.getDescribe()
							}
						);
					}
					catch (Exception e) {throw new SFDCAccessControlException();}

				}

				if (sObj.getSObjectType() == Schema.Lead.getSObjectType()) {
					try {
						SFDCAccessController.UpdateWithoutSharing (
							appendResultFC.get(FullContactApiClient.OBJECT_SECTION),
							'DataAppendBatch.cls [execute]',
							new List<Schema.DescribeFieldResult> {
								Lead.Append_Need_Append__c.getDescribe(),
								Lead.Social_Append_Run_Date__c.getDescribe(),
								Lead.Social_Append_Success__c.getDescribe()
							}
						);
					}
					catch (Exception e) {throw new SFDCAccessControlException();}
				}

				if (!appendResultFC.get(FullContactApiClient.LOGS_SECTION).isEmpty()) {
					try {
						SFDCAccessController.InsertWithoutSharing (
							appendResultFC.get(FullContactApiClient.LOGS_SECTION),
							'DataAppendBatch.cls [execute]',
							new List<Schema.DescribeFieldResult> {
								Log__c.Event_Type__c.getDescribe(), Log__c.Event_Status__c.getDescribe(),
								Log__c.Event_Endpoint__c.getDescribe(), Log__c.Event_Description__c.getDescribe(),
								Log__c.Account__c.getDescribe(), Log__c.Lead__c.getDescribe()
							}
						);
					}
					catch (Exception e) {throw new SFDCAccessControlException();}
				}

			}

			//update Append_Run__c and Append_Run_Date__c
			if (batchAllowExecuteTD || batchAllowExecuteFC) {
				//ACCOUNT
				if (sObj.getSObjectType() == Schema.Account.getSObjectType()) {
					Account aAccount = (Account) sObj;
					aAccount.Append_Run__c = true;
					aAccount.Append_Run_Date__c = System.now();
					try {
						SFDCAccessController.UpdateWithoutSharing (
							aAccount,
							'DataAppendBatch.cls [execute]',
							new List<Schema.DescribeFieldResult> {
								Account.Append_Run__c.getDescribe(),
								Account.Append_Run_Date__c.getDescribe()
							}
						);
					}
					catch (Exception e) {throw new SFDCAccessControlException();}
				}
				//LEAD
				if (sObj.getSObjectType() == Schema.Lead.getSObjectType()) {
					Lead aLead = (Lead) sObj;
					aLead.Append_Run__c = true;
					aLead.Append_Run_Date__c = System.now();
					try {
						SFDCAccessController.UpdateWithoutSharing (
							aLead,
							'DataAppendBatch.cls [execute]',
							new List<Schema.DescribeFieldResult> {
								Lead.Append_Run__c.getDescribe(),
								Lead.Append_Run_Date__c.getDescribe()
							}
						);
					}
					catch (Exception e) {throw new SFDCAccessControlException();}
				}
			}

		}
	}

	public void finish(Database.BatchableContext BC) {
		Integer bStep = this.batchStep;

		if (batchStep < 2) {
			bStep = bStep + 1;
			DataAppendBatch job = new DataAppendBatch(bStep);
			Database.executeBatch(job, 1);
		}
		else {
			Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();

			if (settingsMap.containsKey('Batch.DataAppendState') && settingsMap.containsKey('Batch.DataAppendTime')) {
				TouchCR_Settings__c settingDataAppendState = settingsMap.get('Batch.DataAppendState');
				TouchCR_Settings__c settingDataAppendTime = settingsMap.get('Batch.DataAppendTime');

				if (settingDataAppendState.Value__c == 'On' && settingDataAppendTime.Value__c != '') {
					List<CronTrigger> scheduleInProgress = [
						SELECT Id, NextFireTime
						FROM CronTrigger
						WHERE CronJobDetail.Name =: 'DataAppend'
						LIMIT 1
					];
					if (!scheduleInProgress.isEmpty()) {
						System.abortJob(scheduleInProgress.get(0).Id);
					}

					DataAppendScheduler scheduler = new DataAppendScheduler();
					String cronStr = '0 0 0/' + settingDataAppendTime.Value__c + ' 1/1 * ? *';
					System.schedule('DataAppend' , cronStr, scheduler);
				}

			}
		}

	}

}