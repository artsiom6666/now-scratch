global with sharing class TouchCRHelper {

	//The method returns the existing TouchCR_Settings__c in the base package
	//if nameSetting = 'allSettings' returns all TouchCR_Settings__c
	global static Map<String, String> getSettings(String nameSetting) {
		Map<String, String> result = new Map<String, String>();
		Map<String, TouchCR_Settings__c> allSettings = TouchCR_Settings__c.getAll();
		for (String item : allSettings.keySet()) {
			if (item.contains(nameSetting) && item != '' && item != 'null') {
				result.put(item, allSettings.get(item).Value__c);
			}
			else if (nameSetting == 'allSettings') {
				result.put(item, allSettings.get(item).Value__c);
			}
		}
		return result;
	}

	//Test method for creating TouchCR_Settings__c from extensions package
	global static void setSettings(Map<String, String> newSettings) {
		Map<String, TouchCR_Settings__c> result = new Map<String, TouchCR_Settings__c>();
		Map<String, TouchCR_Settings__c> allSettings = TouchCR_Settings__c.getAll();

		for (String settingKey : newSettings.keySet()) {
			if (settingKey != '' && settingKey != 'null') {
				if (allSettings.containsKey(settingKey)) {
					TouchCR_Settings__c itemTS = allSettings.get(settingKey);
					itemTS.Value__c = newSettings.get(settingKey);
					result.put(settingKey, itemTS);
				}
				else {
					result.put(settingKey, new TouchCR_Settings__c(
						Name = settingKey,
						Value__c = newSettings.get(settingKey)
					));
				}
			}
		}
		if (!result.isEmpty()) {
			try {
				SFDCAccessController.UpsertWithoutSharing (
					result.values(),
					'TouchCRHelper.cls [setSettings]',
					new List<Schema.DescribeFieldResult>{
						TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
					}
				);
			}
			catch (Exception e) {
				throw new SFDCAccessControlException();
			}
		}
	}

	// Are State and Country pickers enabled in this org?
	public static Boolean isSCPEnabled() {
		Map<String, Schema.SObjectField> accountFields = Account.sObjectType.getDescribe().fields.getMap();
		return accountFields.containsKey('BillingStateCode');
	}
	// Returns json for all available countries and codes
	// format is                    {"US":{label : "United States", value: "US", states: {"AK":"Alaska"}}
	// if feature not enabled       {}
	public static Map<String, PicklistEntryWrapper> getAvailableStatesAndCountries() {

		// Set up the return container - Map<ControllingValue, PicklistEntryWrapper>
		Map<String, PicklistEntryWrapper> objResults = new Map<String, PicklistEntryWrapper>();
		List<String> controllingValues = new List<String>();

		if (isSCPEnabled()) {
			Schema.SObjectField theField = Account.sObjectType.getDescribe().fields.getMap().get('BillingStateCode');
			Schema.SObjectField ctrlField = Account.sObjectType.getDescribe().fields.getMap().get('BillingCountryCode');
			// validFor property cannot be accessed via a method or a property,
			// so we need to serialize the PicklistEntry object and then deserialize into a wrapper.
			List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
			List<DependentPicklistEntryWrapper> depEntries =
					wrapPicklistEntries(theField.getDescribe().getPicklistValues());

			for (Schema.PicklistEntry ple : contrEntries) {
				String value = ple.getValue();

				PicklistEntryWrapper pickListEntry = new PicklistEntryWrapper();
				pickListEntry.label = EncodingUtil.urlEncode(ple.getLabel(), 'UTF-8');
				pickListEntry.value = value;
				pickListEntry.states = new Map<String,String>();

				objResults.put(value, pickListEntry);
				controllingValues.add(value);
			}

			for (DependentPicklistEntryWrapper plew : depEntries) {
				String label = plew.label;
				String value = plew.value;

				String validForBits = base64ToBits(plew.validFor);

				for (Integer i = 0; i < validForBits.length(); i++) {
					// For each bit, in order: if it's a 1, add this label to the dependent map for the corresponding controlling value
					String bit = validForBits.mid(i, 1);
					if (bit == '1') {
						Integer counter = 0;
						for (String controllingValue: controllingValues) {
							
							if (i == counter) {
								objResults.get(controllingValue).states.put(value, EncodingUtil.urlEncode(label, 'UTF-8'));
							}
							counter++;
						}
					}
				}
			}
		}

		return objResults;
	}

	static String base64ToBits(String validFor) {
		if (String.isEmpty(validFor)) return '';

		String validForBits = '';
		String base64Chars = '' +
			'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
			'abcdefghijklmnopqrstuvwxyz' +
			'0123456789+/';

		for (Integer i = 0; i < validFor.length(); i++) {
			String thisChar = validFor.mid(i, 1);

			Integer val = base64Chars.indexOf(thisChar);
			String bits = decimalToBinary(val).leftPad(6, '0');
			validForBits += bits;
		}

		return validForBits;
	}

	static String decimalToBinary(Integer val) {
		String bits = '';
		while (val > 0) {
			Integer remainder = Math.mod(val, 2);
			val = Integer.valueOf(Math.floor(val / 2));
			bits = String.valueOf(remainder) + bits;
		}
		return bits;
	}

	public static List<DependentPicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
		return (List<DependentPicklistEntryWrapper>)
			JSON.deserialize(JSON.serialize(PLEs), List<DependentPicklistEntryWrapper>.class);
	}

	public class DependentPicklistEntryWrapper {
		protected String active {get; set;}
		protected String defaultValue {get; set;}
		protected String label {get; set;}
		protected String value {get; set;}
		protected String validFor {get; set;}
	}
	public class PicklistEntryWrapper {
		public String label {get; set;}
		public String value {get; set;}
		public Map<String, String> states {get; set;}
	}
	
	public static Set<String> getAllAvailableCurrencyCodes() {
		Set<String> result = new Set<String>();

		if (UserInfo.isMultiCurrencyOrganization()) {
			Schema.DescribeSObjectResult describeCurrencyTypeResult = Schema.getGlobalDescribe().get('CurrencyType').getDescribe();
			Schema.DescribeFieldResult isoCodeFieldResult = describeCurrencyTypeResult.Fields.getMap().get('IsoCode').getDescribe();
			List<Schema.PicklistEntry> isoCodePickVals = isoCodeFieldResult.getPicklistValues();

			for (Schema.PicklistEntry f : isoCodePickVals) {
				if (f.isActive()) {
					result.add(f.getValue());
				}
			}
		}
		else {
			result.add(UserInfo.getDefaultCurrency());
		}

		return result;
	}

	public static String getUserAvailableCurrencyCode() {
		return UserInfo.getDefaultCurrency();
	}

	// Method returns the available CurrencyIsoCode from SObject
	public static String getCurrencyIsoCode(SObject aObject) {
		// tmp solution, before all soqls are dynamic
		if (userInfo.isMultiCurrencyOrganization() && aObject.getPopulatedFieldsAsMap().containsKey('CurrencyIsoCode')) {
			return validateAndFixCurrencyIsoCode((String) aObject.get('CurrencyIsoCode'));
		}
		else {
			return getUserAvailableCurrencyCode();
		}
	}

	public static SObject setCurrencyIsoCode(SObject aObject, String currencyCode) {
		if (userInfo.isMultiCurrencyOrganization()) {
			aObject.put('CurrencyIsoCode', validateAndFixCurrencyIsoCode(currencyCode));
		}
		return aObject;
	}

	// Method returns the available CurrencyIsoCode from String
	public static String validateAndFixCurrencyIsoCode(String currencyCodeString) {
		String result = getUserAvailableCurrencyCode();
		if (String.isNotBlank(currencyCodeString)) {
			currencyCodeString = currencyCodeString.toUpperCase();
			if (getAllAvailableCurrencyCodes().contains(currencyCodeString)) {
				result = currencyCodeString;
			}
		}
		return result;
	}

	// Method returns the available Currency for the active user
	public static String getCurrencyLabel(SObject aObject) {
		String result = getCurrencyIsoCode(aObject);
		if (UserInfo.isMultiCurrencyOrganization()) {
			Schema.DescribeSObjectResult describeCurrencyTypeResult = Schema.getGlobalDescribe().get('CurrencyType').getDescribe();
			Schema.DescribeFieldResult isoCodeFieldResult = describeCurrencyTypeResult.Fields.getMap().get('IsoCode').getDescribe();
			List<Schema.PicklistEntry> isoCodePickVals = isoCodeFieldResult.getPicklistValues();
			for (Schema.PicklistEntry f : isoCodePickVals) {
				if (result == f.getValue()) {
					result = String.valueOf(f.getLabel().substring(6));
				}
			}
		}
		return result;
	}

	// Returns currencycode string if MC is enabled
	public static String getOrderDefaultSoqlQueryString() {
		List<String> orderFieldNames = new List<String>{
			'Account__c',
			'Account__r.Name',
			'Account__r.LastName',
			'Account__r.FirstName',
			'Account__r.PersonEmail',
			'Account__r.Phone',
			'Amount_To_Charge__c',
			'Billing_Address__c',
			'Billing_City__c',
			'Billing_Country__c',
			'Billing_State__c',
			'Billing_Zip_Postal__c',
			'Billing_Address_Line_2__c',
			'Billing_State_Province__c',
			'Billing_Company__c',
			'Billing_Fax__c',
			'Id',
			'Named_Agent__c',
			'Shipping_Address__c',
			'Shipping_City__c',
			'Shipping_Country__c',
			'Shipping_State__c',
			'Shipping_Zip_Postal__c',
			'Subscription__c',
			'Subscription_Remains_Amount__c',
			'Customer_IP__c'
		};
		String result = 'SELECT ' + String.join(orderFieldNames, ',');
		result += (UserInfo.isMultiCurrencyOrganization()) ? ',CurrencyIsoCode,' : ',';
		return result;
	}

	/**
	 * Schedules batch in the base package
	 *
	 * @param batchToSchedule map with keys 'Name', 'CronString', 'BatchName' and values
	 * @return                true if batch was scheduled, otherwise false
	 */
	global static Boolean scheduleBatch(Map<String, String> batchToSchedule) {
		String name = batchToSchedule.get('Name');
		String cronString = batchToSchedule.get('CronString');
		String batchName = batchToSchedule.get('BatchName');
		try {
			Type newScheduler = Type.forName('', batchName);
			System.schedule(name , cronString, (Schedulable)newScheduler.newInstance());
			return true;
		}
		catch (Exception e) {
			return false;
		}
	}

	/**
	 * Gets the existing custom settings in the base package
	 *
	 * Use {@link #setCustomSettings(String settingsName, List<Map<String, String>> newSettings)} to set custom settings.
	 *
	 * @param settingsName the existing custom settings name
	 * @return             settings list with maps where key in Map is name of Field, and value in Map is Value for current setting
	 */
	global static List<Map<String, String>> getCustomSettings(String settingsName) {
		String query = 'SELECT ';

		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(settingsName).getDescribe().fields.getMap();

		for(String s : objectFields.keySet()) {
		   query += objectFields.get(s) + ', ';
		}

		query = query.subString(0,query.Length()-2) + ' FROM ' + settingsName;

		List<sObject> settings = new List<sObject>();

		try {
			settings = database.query(query);
		} catch (QueryException e) {
			return null;
		}

		List<Map<String, String>> ret = new List<Map<String, String>>();
		Map<String, String> curSetting;
		for (Integer i = 0; i < settings.size(); i++) {
			curSetting = new Map<String, String>();
			for(String s : objectFields.keySet()) {
			   curSetting.put(String.valueOf(objectFields.get(s)), String.valueOf(settings.get(i).get(s)));
			}
			ret.add(curSetting);
		}

		return ret;
	}

	/**
	 * Sets the existing custom settings in the base package
	 *
	 * Use {@link #getCustomSettings(String settingsName)} to get custom settings.
	 *
	 * @param settingsName the existing custom settings name
	 * @param newSettings  settings list with maps where key in Map is name of Field, and value in Map is Value for current setting
	 */
	public static void setCustomSettings(String settingsName, List<Map<String, String>> newSettings) {

		List<sObject> settingsToInsert = new List<sObject>();
		List<sObject> settingsToUpdate = new List<sObject>();

		List<Schema.DescribeFieldResult> fieldsToUpsert = new List<Schema.DescribeFieldResult>();
		List<Map<String, String>> allSettings = getCustomSettings(settingsName);

		Boolean needToInsert = true;

		sObject item;
		for (Map<String, String> itemSettings : newSettings) {
			item = Schema.getGlobalDescribe().get(settingsName).newSObject() ;
			for(String key : itemSettings.keySet()) {
				fieldsToUpsert.add(Schema.getGlobalDescribe().get(settingsName).getDescribe().fields.getMap().get(key).getDescribe());
				if (String.valueOf(Schema.getGlobalDescribe().get(settingsName).getDescribe().fields.getMap().get(key).getDescribe().getType()) == 'Boolean') {
					item.put(key, Boolean.valueOf(itemSettings.get(key)));
				} else {
					item.put(key, itemSettings.get(key));
				}
			}
			for (Map<String, String> setting : allSettings) {
				if (setting.get('Name') == item.get('Name')) {
					item.put('Id', setting.get('Id'));
					settingsToUpdate.add(item);
					needToInsert = false;
				}
			}
			if (needToInsert) {
				settingsToInsert.add(item);
				needToInsert = true;
			}
		}
		if (!settingsToUpdate.isEmpty()) {
			try {
				SFDCAccessController.UpdateWithoutSharing (
					settingsToUpdate,
					'TouchCRHelper.cls [setCustomSettings]',
					fieldsToUpsert
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}
		if (!settingsToInsert.isEmpty()) {
			try {
				SFDCAccessController.InsertWithoutSharing (
					settingsToInsert,
					'TouchCRHelper.cls [setCustomSettings]',
					fieldsToUpsert
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}
	}

	// Update Okta API token if it has been invalid or expired
	global static void setAuthCredentinals(String access_token) {

		List<TouchCR_Settings__c> settingsToUpsert = new List<TouchCR_Settings__c>();

		Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();

		TouchCR_Settings__c tokenPart1Setting = settingsMap.get('Endpoint.TokenPart1');
		TouchCR_Settings__c tokenPart2Setting = settingsMap.get('Endpoint.TokenPart2');
		
		if (tokenPart1Setting == null || 
			tokenPart2Setting == null) {
			return;
		}

		if (access_token.length() > 253) {
			tokenPart1Setting.Value__c = access_token.substring(0, 254);
			tokenPart2Setting.Value__c = access_token.substring(254);
		}
		else {
			tokenPart1Setting.Value__c = access_token;
			tokenPart2Setting.Value__c = '';
		}
		settingsToUpsert.add(tokenPart1Setting);
		settingsToUpsert.add(tokenPart2Setting);
		try {
			SFDCAccessController.UpsertWithoutSharing (
				settingsToUpsert,
				'TowerDataApi.cls [callApi]',
				new List<Schema.DescribeFieldResult> {
					TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
				}
			);
		}
		catch (Exception e) { throw new SFDCAccessControlException(); }
	}

	/**
	 * Check "Affiliate Extension" installed
	 */
	public static Boolean isAffiliateEnabled() {
		return Schema.getGlobalDescribe().containsKey('TouchCRBase__Affiliate_Offer__c');
	}

	/**
	 * Check "Franchisee Extension" installed
	 */
	public static Boolean isFranchiseeEnabled() { 
		return Schema.getGlobalDescribe().containsKey('TouchCRBase__Territory__c');
	}

	/**
	 * Check "Lightning Extension" installed
	 */
	public static Boolean isLightningEnabled() {
		return false;
	}

	public static Map<String, List<String> > getPicklistsValues(Map<String, String> generalData) {
		Map<String, List<String> > result = new Map<String, List<String> >();
		
		String obj = new List<String> (generalData.keySet()).get(0);
		DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(obj).getDescribe();
		for(String field : generalData.get(obj).split(';')){
			DescribeFieldResult fieldResult = objResult.fields.getMap().get(field).getDescribe();
			List<String> pickListValuesList = new List<String>();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry pickListVal : ple){
				pickListValuesList.add(pickListVal.getLabel());
			}
			result.put(field, pickListValuesList);
		}
		
		return result;
	}
}