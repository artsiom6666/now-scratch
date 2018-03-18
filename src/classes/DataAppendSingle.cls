public with sharing class DataAppendSingle {

	public static String doAppend(String param) {
		Id objectId;
		try {
			objectId = Id.valueOf(param);
		}
		catch (Exception e) {
			return JSON.serialize(e.getMessage() + e.getStackTraceString());
		}

		//append TowerData
		String soqlString = TowerDataAPIClient.getSoqlStringWithoutWhereClause(objectId);
		soqlString += ' WHERE Id =: objectId';
		SObject aObjectTD = Database.query(soqlString);
		Map<String, List<SObject>> appendResultTD = TowerDataAPIClient.makeAppend(aObjectTD);

		//append FullContact
		String soqlStringFC = FullContactApiClient.getSoqlStringWithoutWhereClause(objectId);
		soqlStringFC += ' WHERE Id =: objectId';
		SObject aObjectFC = Database.query(soqlStringFC);
		Map<String, List<SObject>> appendResultFC = FullContactApiClient.makeAppend(aObjectFC);

		//Save result TowerData
		if (aObjectTD.getSObjectType() == Schema.Account.getSObjectType()) {
			try {
				SFDCAccessController.UpdateWithoutSharing (
					appendResultTD.get(TowerDataAPIClient.OBJECT_SECTION),
					'DataAppendSingle.cls [doAppend]',
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
		if (aObjectTD.getSObjectType() == Schema.Lead.getSObjectType()) {
			try {
				SFDCAccessController.UpdateWithoutSharing (
					appendResultTD.get(TowerDataAPIClient.OBJECT_SECTION),
					'DataAppendSingle.cls [doAppend]',
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
					'DataAppendSingle.cls [doAppend]',
					new List<Schema.DescribeFieldResult> {
						Log__c.Event_Type__c.getDescribe(), Log__c.Event_Status__c.getDescribe(),
						Log__c.Event_Endpoint__c.getDescribe(), Log__c.Event_Description__c.getDescribe(),
						Log__c.Account__c.getDescribe(), Log__c.Lead__c.getDescribe()
					}
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}

		if (aObjectTD.getSObjectType() == Schema.Account.getSObjectType()) {
			if (!appendResultTD.get(TowerDataAPIClient.CASE_SECTION).isEmpty()) {
				try {
					SFDCAccessController.InsertWithoutSharing (
						appendResultTD.get(TowerDataAPIClient.CASE_SECTION),
						'DataAppendSingle.cls [doAppend]',
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

	
		//Save result FullContact
		if (aObjectFC.getSObjectType() == Schema.Account.getSObjectType()) {
			try {
				SFDCAccessController.UpdateWithoutSharing (
					appendResultFC.get(FullContactApiClient.OBJECT_SECTION),
					'DataAppendSingle.cls [doAppend]',
					new List<Schema.DescribeFieldResult> {
							Account.Append_Need_Append__c.getDescribe(),
							Account.Social_Append_Run_Date__c.getDescribe(),
							Account.Social_Append_Success__c.getDescribe()
					}
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}

		if (aObjectFC.getSObjectType() == Schema.Lead.getSObjectType()) {
			try {
				SFDCAccessController.UpdateWithoutSharing (
					appendResultFC.get(FullContactApiClient.OBJECT_SECTION),
					'DataAppendSingle.cls [doAppend]',
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
					'DataAppendSingle.cls [doAppend]',
					new List<Schema.DescribeFieldResult> {
						Log__c.Event_Type__c.getDescribe(), Log__c.Event_Status__c.getDescribe(),
						Log__c.Event_Endpoint__c.getDescribe(), Log__c.Event_Description__c.getDescribe(),
						Log__c.Account__c.getDescribe(), Log__c.Lead__c.getDescribe()
					}
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}

		//Update Append_Run__c and Append_Run_Date__c
		//ACCOUNT
		if (aObjectTD.getSObjectType() == Schema.Account.getSObjectType()) {
			Account aAccount = (Account) aObjectTD;
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
		if (aObjectTD.getSObjectType() == Schema.Lead.getSObjectType()) {
			Lead aLead = (Lead) aObjectTD;
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


		return 'true';
	}
}