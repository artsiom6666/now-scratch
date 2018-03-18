public with sharing class TouchCRMultiConfigurationController {

	public String selectedBrand { get; set; }
	public String selectedFeature { get; set; }
	public String newNameForSetting { get; set; }
	public String namePersonSetting { get; set; } // connection id

	public List<SelectOption> valueBrandList { get; set; }
	public List<SelectOption> valueFeatureList { get; set; }
	public List<SelectOption> namedCredentials { get; set; }

	public List<SettingsWr> settingsStringWr { get; set; }
	public List<SettingsWr> settingsBooleanWr { get; set; }
	public List<SettingsWr> settingsSelectListWr { get; set; }

	public List<TouchCRConnection__c> connect { get; set; }
	public List<TouchCRConnectionSetting__c> connectionSettings { get; set; }
	public TouchCRConnection__c currentConnection { get; set; }

	public Map<String, TouchCRConnectionSetting__c> nameToValue { get; set; }

	public Map<String, String> usedSettingsString { get; set; }
	public Map<String, String> usedSettingsBoolean { get; set; }
	public Map<String, String> usedSettingsSelectList { get; set; }

	public Boolean panelTable { get; set; }
	public Boolean panelCreateNew { get; set; }
	public Boolean panelEdit { get; set; }

	public TouchCRMultiConfigurationController() {
		init();
	}

	public void init() {
		this.panelTable = true;
		this.panelCreateNew = false;
		this.panelEdit = false;

		this.usedSettingsString = new Map<String, String>();
		this.usedSettingsBoolean = new Map<String, String>();
		this.usedSettingsSelectList = new Map<String, String>();

		//Search for available Credential
		this.namedCredentials = getNamedCredential();

		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'TouchCRConnection__c',
				'TouchCRMultiConfigurationController.cls [init]',
				new List<Schema.DescribeFieldResult> {
					TouchCRConnection__c.Name.getDescribe(), TouchCRConnection__c.Brand__c.getDescribe(),
					TouchCRConnection__c.Feature__c.getDescribe(), TouchCRConnection__c.isActive__c.getDescribe(),
					TouchCRConnection__c.Id.getDescribe(), TouchCRConnection__c.Order__c.getDescribe()
				}
			);
			this.connect = [
				SELECT Id, Name, Brand__c, Feature__c, Order__c, isActive__c
				FROM TouchCRConnection__c
				ORDER BY Order__c ASC NULLS LAST, Brand__c ASC
				LIMIT 100
			];
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	public void addNew() {
		this.panelTable = false;
		this.panelCreateNew = true;
		this.panelEdit = false;
		this.newNameForSetting = null;

		//Search for available Brands and Features
		this.valueBrandList = new List<SelectOption>();
		for (String item : getAllBrandValues()) {
			 this.valueBrandList.add(new SelectOption(item, item));
		}

		this.valueFeatureList = new List<SelectOption>();
		for (String item : getAllFeature().keySet()) {
			this.valueFeatureList.add(new SelectOption(item, item));
		}
	}

	public void createNewNameSetting() {
		if (String.isNotBlank(newNameForSetting)) {
			this.panelTable = false;
			this.panelCreateNew = false;
			this.panelEdit = true;

			List<TouchCRConnectionSetting__c> connectionSettingToInsert = new List<TouchCRConnectionSetting__c>();
			this.nameToValue = new Map<String, TouchCRConnectionSetting__c>();

			TouchCRConnection__c newConnection = new TouchCRConnection__c(
				Brand__c = this.selectedBrand,
				Feature__c = this.selectedFeature,
				Name = this.newNameForSetting,
				isActive__c = false
			);

			try {
				SFDCAccessController.InsertWithoutSharing (
					newConnection,
					'TouchCRMultiConfigurationController.cls [createNewNameSetting]',
					new List<Schema.DescribeFieldResult> {
						TouchCRConnection__c.Name.getDescribe(), TouchCRConnection__c.Brand__c.getDescribe(),
						TouchCRConnection__c.Feature__c.getDescribe(), TouchCRConnection__c.isActive__c.getDescribe()
					}
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}

			this.currentConnection = newConnection;

			this.usedSettingsString = getAllFeature().get(this.selectedFeature)[0];
			this.usedSettingsBoolean = getAllFeature().get(this.selectedFeature)[1];
			this.usedSettingsSelectList = getAllFeature().get(this.selectedFeature)[2];

			//The formation of String, Boolean and Picklist ConnectionSetting
			for (String item : this.usedSettingsString.keySet()) {
				if (!nameToValue.containsKey(item)) {
					TouchCRConnectionSetting__c connectionSetting = new TouchCRConnectionSetting__c(
						Name = item, TouchCRConnection__c = newConnection.Id, Value__c = ''
					);
					connectionSettingToInsert.add(connectionSetting);

					nameToValue.put(item, connectionSetting);
				}
			}

			for (String item : this.usedSettingsBoolean.keySet()) {
				if (!nameToValue.containsKey(item)) {
					TouchCRConnectionSetting__c connectionSetting = new TouchCRConnectionSetting__c(
						Name = item, TouchCRConnection__c = newConnection.Id, Value__c = 'false'
					);
					connectionSettingToInsert.add(connectionSetting);

					nameToValue.put(item, connectionSetting);
				}
			}

			for (String item : this.usedSettingsSelectList.keySet()) {
				if (!nameToValue.containsKey(item)) {
					TouchCRConnectionSetting__c connectionSetting = new TouchCRConnectionSetting__c(
						Name = item, TouchCRConnection__c = newConnection.Id, Value__c = ''
					);
					connectionSettingToInsert.add(connectionSetting);

					nameToValue.put(item, connectionSetting);
				}
			}

			try {
				SFDCAccessController.UpsertWithoutSharing (
					connectionSettingToInsert,
					'TouchCRMultiConfigurationController.cls [createNewNameSetting]',
					new List<Schema.DescribeFieldResult> {
						TouchCRConnectionSetting__c.Name.getDescribe(), TouchCRConnectionSetting__c.Value__c.getDescribe()
					}
				);

			}
			catch (Exception e) {throw new SFDCAccessControlException();}

			//Recording String setting
			this.settingsStringWr = new List<SettingsWr>();
			for (String item : this.usedSettingsString.keySet()) {
				TouchCRConnectionSetting__c connectionSetting = nameToValue.get(item);
				SettingsWr settingWr = new SettingsWr();
				settingWr.name = connectionSetting.Name;
				settingWr.label = this.usedSettingsString.get(item);
				settingWr.valueS = connectionSetting.Value__c;

				this.settingsStringWr.add(settingWr);
			}

			//Recording Boolean setting
			this.settingsBooleanWr = new List<SettingsWr>();
			for (String item : this.usedSettingsBoolean.keySet()) {
				TouchCRConnectionSetting__c connectionSetting = nameToValue.get(item);
				SettingsWr settingWr = new SettingsWr();
				settingWr.name = connectionSetting.Name;
				settingWr.label = this.usedSettingsBoolean.get(item);
				settingWr.valueB = Boolean.valueOf(connectionSetting.Value__c);

				this.settingsBooleanWr.add(settingWr);
			}

			//Recording Picklist setting
			this.settingsSelectListWr = new List<SettingsWr>();
			for (String item : this.usedSettingsSelectList.keySet()) {
				TouchCRConnectionSetting__c connectionSetting = nameToValue.get(item);
				SettingsWr settingWr = new SettingsWr();
				settingWr.name = connectionSetting.Name;
				settingWr.label = this.usedSettingsSelectList.get(item);
				settingWr.valueS = connectionSetting.Value__c;

				this.settingsSelectListWr.add(settingWr);
			}
		}
		else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You must enter a values in required fields'));
		}
	}

	public PageReference editSetting() {
		this.panelTable = false;
		this.panelCreateNew = false;
		this.panelEdit = true;

		List<TouchCRConnectionSetting__c> connectionSettingToInsert = new List<TouchCRConnectionSetting__c>();
		this.nameToValue = new Map<String, TouchCRConnectionSetting__c>();

		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'TouchCRConnection__c',
				'TouchCRMultiConfigurationController.cls [editSetting]',
				new List<Schema.DescribeFieldResult> {
					TouchCRConnection__c.Name.getDescribe(), TouchCRConnection__c.Brand__c.getDescribe(),
					TouchCRConnection__c.Order__c.getDescribe(), TouchCRConnection__c.isActive__c.getDescribe()
				}
			);
			this.currentConnection = [SELECT Id, Name, Brand__c, Order__c, isActive__c FROM TouchCRConnection__c WHERE Id = :namePersonSetting LIMIT 1];
			//Search for available Brands and Features
			this.valueBrandList = new List<SelectOption>();
			for (String item : getAllBrandValues()) {
				this.valueBrandList.add(new SelectOption(item, item));
			}

			SFDCAccessController.AccessibleWithoutSharing (
				'TouchCRConnectionSetting__c',
				'TouchCRMultiConfigurationController.cls [editSetting]',
				new List<Schema.DescribeFieldResult> {
					TouchCRConnectionSetting__c.Name.getDescribe(), TouchCRConnectionSetting__c.Value__c.getDescribe(),
					TouchCRConnectionSetting__c.Name.getDescribe(), TouchCRConnectionSetting__c.Value__c.getDescribe()
				}
			);
			SFDCAccessController.AccessibleWithoutSharing (
				'TouchCRConnection__c',
				'TouchCRMultiConfigurationController.cls [editSetting]',
				new List<Schema.DescribeFieldResult> {
					TouchCRConnection__c.Feature__c.getDescribe()
				}
			);
			this.connectionSettings = [
				SELECT Id, Name, Value__c, TouchCRConnection__c, TouchCRConnection__r.Feature__c
				FROM TouchCRConnectionSetting__c
				WHERE TouchCRConnection__c =: currentConnection.Id
			];
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

		for (TouchCRConnectionSetting__c connectionSetting : this.connectionSettings) {
			nameToValue.put(connectionSetting.Name, connectionSetting);
		}

		if (getAllFeature().containsKey(this.selectedFeature)) {
			this.usedSettingsString = getAllFeature().get(this.selectedFeature)[0];
			this.usedSettingsBoolean = getAllFeature().get(this.selectedFeature)[1];
			this.usedSettingsSelectList = getAllFeature().get(this.selectedFeature)[2];
		}
		else {
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.WARNING, 'Settings for this Feature cannot be displayed!')
			);
		}

		for (String item : this.usedSettingsString.keySet()) {
			if (!nameToValue.containsKey(item)) {
				TouchCRConnectionSetting__c connectionSetting = new TouchCRConnectionSetting__c(
					Name = item, TouchCRConnection__c = currentConnection.Id
				);
				connectionSettingToInsert.add(connectionSetting);

				nameToValue.put(item, connectionSetting);
			}
		}

		for (String item : this.usedSettingsBoolean.keySet()) {
			if (!nameToValue.containsKey(item)) {
				TouchCRConnectionSetting__c connectionSetting = new TouchCRConnectionSetting__c(
					Name = item, TouchCRConnection__c = currentConnection.Id, Value__c = 'false'
				);
				connectionSettingToInsert.add(connectionSetting);

				nameToValue.put(item, connectionSetting);
			}
		}

		for (String item : this.usedSettingsSelectList.keySet()) {
			if (!nameToValue.containsKey(item)) {
				TouchCRConnectionSetting__c connectionSetting = new TouchCRConnectionSetting__c(
					Name = item, TouchCRConnection__c = currentConnection.Id, Value__c = ''
				);
				connectionSettingToInsert.add(connectionSetting);

				nameToValue.put(item, connectionSetting);
			}
		}
		if (!connectionSettingToInsert.isEmpty()) {
			try {
				SFDCAccessController.UpsertWithoutSharing (
					connectionSettingToInsert,
					'TouchCRMultiConfigurationController.cls [editSetting]',
					new List<Schema.DescribeFieldResult> {
						TouchCRConnectionSetting__c.Name.getDescribe(), TouchCRConnectionSetting__c.Value__c.getDescribe()
					}
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}

		//Recording String setting
		this.settingsStringWr = new List<SettingsWr>();
		for (String item : this.usedSettingsString.keySet()) {
			TouchCRConnectionSetting__c connectionSetting = nameToValue.get(item);
			SettingsWr settingWr = new SettingsWr();
			settingWr.name = connectionSetting.Name;
			settingWr.label = this.usedSettingsString.get(item);
			settingWr.valueS = connectionSetting.Value__c;

			this.settingsStringWr.add(settingWr);
		}

		//Recording Boolean setting
		this.settingsBooleanWr = new List<SettingsWr>();
		for (String item : this.usedSettingsBoolean.keySet()) {
			TouchCRConnectionSetting__c connectionSetting = nameToValue.get(item);
			SettingsWr settingWr = new SettingsWr();
			settingWr.name = connectionSetting.Name;
			settingWr.label = this.usedSettingsBoolean.get(item);
			settingWr.valueB = Boolean.valueOf(connectionSetting.Value__c);

			this.settingsBooleanWr.add(settingWr);
		}

		//Recording Picklist setting
		this.settingsSelectListWr = new List<SettingsWr>();
		for (String item : this.usedSettingsSelectList.keySet()) {
			TouchCRConnectionSetting__c connectionSetting = nameToValue.get(item);
			SettingsWr settingWr = new SettingsWr();
			settingWr.name = connectionSetting.Name;
			settingWr.label = this.usedSettingsSelectList.get(item);
			settingWr.valueS = connectionSetting.Value__c;

			this.settingsSelectListWr.add(settingWr);
		}
		return null;
	}

	public void saveSettings() {

		if (!validateSettings(settingsStringWr, settingsBooleanWr, settingsSelectListWr)) {
			return;
		}

		List<TouchCRConnectionSetting__c> settingsToUpsert = new List<TouchCRConnectionSetting__c>();

		//Check whether you have made changes
		for (SettingsWr newSetting : settingsStringWr) {
			TouchCRConnectionSetting__c oldSetting = nameToValue.get(newSetting.name);
			String valueToUpdate = newSetting.valueS;
			if (oldSetting.Value__c != valueToUpdate) {
				oldSetting.Value__c = valueToUpdate;
				settingsToUpsert.add(oldSetting);
			}
		}

		for (SettingsWr newSetting : settingsBooleanWr) {
			TouchCRConnectionSetting__c oldSetting = nameToValue.get(newSetting.name);
			String valueToUpdate = String.valueOf(newSetting.valueB);
			if (oldSetting.Value__c != valueToUpdate) {
				oldSetting.Value__c = valueToUpdate;
				settingsToUpsert.add(oldSetting);
			}
		}

		for (SettingsWr newSetting : settingsSelectListWr) {
			TouchCRConnectionSetting__c oldSetting = nameToValue.get(newSetting.name);
			String valueToUpdate = newSetting.valueS;
			if (oldSetting.Value__c != valueToUpdate) {
				oldSetting.Value__c = valueToUpdate;
				settingsToUpsert.add(oldSetting);
			}
		}

		try {
			if (!settingsToUpsert.isEmpty()) {
				SFDCAccessController.UpsertWithoutSharing (
					settingsToUpsert,
					'TouchCRMultiConfigurationController.cls [saveSettings]',
					new List<Schema.DescribeFieldResult> {
						TouchCRConnectionSetting__c.Name.getDescribe(), TouchCRConnectionSetting__c.Value__c.getDescribe()
					}
				);
			}
			SFDCAccessController.UpsertWithoutSharing (
				currentConnection,
				'TouchCRMultiConfigurationController.cls [saveSettings]',
				new List<Schema.DescribeFieldResult> {
					TouchCRConnection__c.Name.getDescribe(), TouchCRConnection__c.Brand__c.getDescribe(),
					TouchCRConnection__c.Feature__c.getDescribe(), TouchCRConnection__c.isActive__c.getDescribe()
				}
			);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

		this.panelTable = true;
		this.panelCreateNew = false;
		this.panelEdit = false;

		ApexPages.addmessage(
			new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Changes saved successfully!')
		);
		init();
	}

	public Boolean validateSettings(List<SettingsWr> stringSettings, List<SettingsWr> booleanSettings, List<SettingsWr> picklistSettings) {

		if (this.selectedFeature == 'Amazon') {
			Boolean isValid = amazonMakeApiCall(stringSettings, booleanSettings, picklistSettings);

			if (!isValid) {
				ApexPages.addmessage(
					new ApexPages.message(ApexPages.severity.WARNING,'Amazon\'s new Credential is wrong. Please update remote site settings and named credentials first and try again!')
				);
			}
			return isValid;
		}

		if (this.selectedFeature == 'Magento') {

			Boolean isValid = magentoMakeApiCall(stringSettings, booleanSettings, picklistSettings);

			if (!isValid) {
				ApexPages.addmessage(
					new ApexPages.message(ApexPages.severity.WARNING,'Magento\'s new Credential is wrong. Please update named credentials first and try again!')
				);
			}
			return isValid;
		}

		if (this.selectedFeature == 'Shopify') {
			// actually this allows to create Inactive connection with the same name and creds
			if (currentConnection.isActive__c == true) {
				Boolean isValidName = shopifyValidateSettings(stringSettings, booleanSettings, picklistSettings);
				Boolean isConnectionAvailable = shopifyMakeApiCall(stringSettings, booleanSettings, picklistSettings);
				return (isValidName && isConnectionAvailable);
			}
			else {
				// inactive connection always valid
				return true;
			}
		}

		if (this.selectedFeature == 'Woo') {
			// TODO add check for credentials entered
			return true;
		}

		if (this.selectedFeature == 'Jet') {
			if (currentConnection.isActive__c == true) {
				Boolean isValidName = jetValidateSettings(stringSettings, booleanSettings, picklistSettings);
				Boolean isConnectionAvailable = jetMakeApiCall(stringSettings, booleanSettings, picklistSettings);
				return (isValidName && isConnectionAvailable);
			}
			else {
				// inactive connection always valid
				return true;
			}
		}

		return false;
	}

	public void cancelSettings() {
		init();
		ApexPages.addmessage(
			new ApexPages.Message(ApexPages.Severity.WARNING, 'Your changes were cancelled.')
		);
	}

	public PageReference deletedSettings() {
		try {
			SFDCAccessController.DeleteWithoutSharing (
				new TouchCRConnection__c(Id = this.namePersonSetting),
				'TouchCRMultiConfigurationController.cls [deletedSettings]'
			);

		}
		catch (Exception e) {throw new SFDCAccessControlException();}

		ApexPages.addmessage(
			new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Settings removed')
		);
		init();
		return null;
	}

	//Find the active brands
	private static Set<String> getAllBrandValues() {
		Set<String> result = new Set<String>();
		Schema.DescribeFieldResult fieldResult = Account.Brand_Assortment__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		for (Schema.PicklistEntry f : ple) {
			if (f.isActive()) {
				String value = f.getValue().abbreviate(33);
				result.add(value);
			}
		}
		return result;
	}

	private static Map<String, List<Map<String, String>>> getAllFeature() {
		Map<String, List<Map<String, String>>> result = new Map<String, List<Map<String, String>>> {
			'Woo' => new List<Map<String, String>> {WOO_SETTING_S, WOO_SETTING_B, WOO_SETTING_P},
			'Shopify' => new List<Map<String, String>> {SHOPIFY_SETTING_S, SHOPIFY_SETTING_B, SHOPIFY_SETTING_P},
			'Amazon' =>  new List<Map<String, String>> {AMAZON_SETTING_S, AMAZON_SETTING_B, AMAZON_SETTING_P},
			'Magento' =>  new List<Map<String, String>> {MAGENTO_SETTING_S, MAGENTO_SETTING_B, MAGENTO_SETTING_P},
			'Jet' =>  new List<Map<String, String>> {JET_SETTING_S, JET_SETTING_B, JET_SETTING_P}
		};
		return result;
	}

	public List<SelectOption> getNamedCredential() {
		List<SelectOption> namedCredentials = new List<SelectOption>();
		// PACKAGING ORGS
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Organization',
				'TouchCRMultiConfigurationController.cls [getNamedCredential]',
				new List<Schema.DescribeFieldResult> {
					Organization.NamespacePrefix.getDescribe()
				}
			);
			List<Organization> orgsNamespace = [SELECT Id, NamespacePrefix FROM Organization LIMIT 1];

			if (!orgsNamespace.isEmpty()) {
				String currentNS = orgsNamespace[0].NamespacePrefix;
				SFDCAccessController.AccessibleWithoutSharing (
					'NamedCredential',
					'TouchCRMultiConfigurationController.cls [getNamedCredential]',
					new List<Schema.DescribeFieldResult> {
						NamedCredential.NamespacePrefix.getDescribe(), NamedCredential.MasterLabel.getDescribe(),
						NamedCredential.DeveloperName.getDescribe()
					}
				);
				for (NamedCredential item : [SELECT Id, DeveloperName, NamespacePrefix, MasterLabel FROM NamedCredential WHERE NamespacePrefix = :currentNS]) {
					namedCredentials.add(new SelectOption(item.DeveloperName, item.MasterLabel));
				}
			}
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
		return namedCredentials;
	}

	public class SettingsWr {
		public SettingsWr() {}
		public String name { get; set; }
		public String label { get; set; }
		public String valueS { get; set; }
		public Boolean valueB { get; set; }
	}
	/* ----- WOO multiple connection section ----- */

	// WOO settings STRING
	static final Map<String, String> WOO_SETTING_S = new Map<String, String> {
		'Woo.Endpoint' => 'Connection Endpoint',
		'Woo.HashAlgorithm' => 'Hash Algorithm',
		'Woo.StoreURL' => 'API URL(Store URL)',
		'Woo.ConsumerKey' => 'Consumer Key',
		'Woo.ConsumerSecret' => 'Consumer Secret',
		'Woo.CheckFrequency' => 'Check Frequency in Minutes',
		'Woo.SalesFunnel' => 'Sales Funnel'
	};
	// WOO settings PICKLIST
	static final Map<String, String> WOO_SETTING_P = new Map<String, String> {
		'Woo.Credential' => 'NamedCredential'
	};
	// WOO settings BOOLEAN
	static final Map<String, String> WOO_SETTING_B = new Map<String, String> {
		'Woo.IsSSL' => 'Is SSL',
		'Woo.HandleShipping' => 'Handle Shipping',
		'Woo.SalesforceMaster' => 'Salesforce Master',
		'Woo.ReturnObject' => 'Return As Object',
		'Woo.HandleEmail' => 'Handle Email'
	};
	/* ----- SHOPIFY multiple connection section ----- */

	// SHOPIFY settings STRING
	static final Map<String, String> SHOPIFY_SETTING_S = new Map<String, String> {
		'Shopify.ApiKey' => 'ApiKey',
		'Shopify.Password' => 'Password',
		'Shopify.SalesFunnel' => 'SalesFunnel',
		'Shopify.lastCustomerExternalID' => 'Last Customer External ID',
		'Shopify.lastOrderExternalID' => 'Last Order External ID',
		'Shopify.lastProductExternalID' => 'Last Product External ID',
		'Shopify.discountedProductId' => 'Discounted Product SF Id'

	};
	// SHOPIFY settings PICKLIST
	static final Map<String, String> SHOPIFY_SETTING_P = new Map<String, String> {
		'Shopify.Credential' => 'Named Credential'
	};
	// SHOPIFY settings BOOLEAN
	static final Map<String, String> SHOPIFY_SETTING_B = new Map<String, String> {
		'Shopify.HandleShipping' => 'Handle Shipping'
	};

	public Boolean shopifyValidateSettings(List<SettingsWr> stringSettings, List<SettingsWr> booleanSettings, List<SettingsWr> picklistSettings) {
		Boolean isValid = true;
		// get ACTIVE shopify exisiting connections settings
		List<TouchCRConnection__c> exisitngConnections = [
			SELECT Id, Name, Brand__c, Feature__c, isActive__c,
				(SELECT Id, Name, Value__c FROM TouchCRConnectionSettings__r)
			FROM TouchCRConnection__c
			WHERE Feature__c = : this.selectedFeature
			AND isActive__c = true
			AND Id != : currentConnection.Id
		];
		Set<String> existingActiveNames = new Set<String>();
		Set<String> existingKeys = new Set<String>();
		Set<String> existingSecrets = new Set<String>();

		// collect Name, ApiKey and Secret for exisiting conections
		for (TouchCRConnection__c exConn : exisitngConnections) {
			existingActiveNames.add(exConn.Name.toLowerCase());
			for (TouchCRConnectionSetting__c exConnSetting : exConn.TouchCRConnectionSettings__r) {
				if (exConnSetting.Name == 'Shopify.ApiKey') {
					existingKeys.add(exConnSetting.Value__c);
				}
				if (exConnSetting.Name == 'Shopify.Password') {
					existingSecrets.add(exConnSetting.Value__c);
				}
			}
		}
		// check for name
		if (existingActiveNames.contains(currentConnection.Name.toLowerCase())) {
			isValid = false;
			ApexPages.addmessage(
				new ApexPages.message(ApexPages.severity.WARNING,'Shopify\'s new Connection Name already exists and active. Please choose different name and try again!')
			);
		}
		// check for api key/secret
		String apikey;
		String password;
		// collect key/secret for settings which are saved
		for (SettingsWr setting : stringSettings) {
			apikey = (setting.name == 'Shopify.ApiKey') ? setting.valueS : apikey;
			password = (setting.name == 'Shopify.Password') ? setting.valueS : password;
		}
		Boolean isStoreAlreadyConnected = (
			(String.isNotBlank(apikey)
			&& existingKeys.contains(apikey))
			||
			(String.isNotBlank(password)
			&& existingSecrets.contains(password))
		);
		if (isStoreAlreadyConnected) {
			isValid = false;
			ApexPages.addmessage(
				new ApexPages.message(ApexPages.severity.WARNING,'Shopify\'s new Connection ApiKey and/or Password already exists and active. Please check store credentials and try again!')
			);
		}
		return isValid;
	}

	public Boolean shopifyMakeApiCall(List<SettingsWr> stringSettings, List<SettingsWr> booleanSettings, List<SettingsWr> picklistSettings) {
		Integer status;
		String apikey;
		String password;
		String namedCredential;

		String url = '/admin/shop.json';

		for (SettingsWr setting : stringSettings) {
			apikey = setting.name == 'Shopify.ApiKey' ? setting.valueS : apikey;
			password = setting.name == 'Shopify.Password' ? setting.valueS : password;
		}

		for (SettingsWr setting : booleanSettings) {}

		for (SettingsWr setting : picklistSettings) {
			namedCredential = setting.name == 'Shopify.Credential' ? setting.valueS : namedCredential;
		}

		if (Test.isRunningTest()) {
			status = 200;
		}
		else {
			try{
				HttpRequest SFRequest = new HttpRequest();
				Http api = new Http();
				Blob headerValue = Blob.valueOf(apikey + ':' + password);
				String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
				SFRequest.setHeader('Authorization', authorizationHeader);
				SFRequest.setMethod('GET');
				SFRequest.setEndpoint('callout:' + namedCredential + url);
				SFRequest.setHeader('Content-Type', 'application/json');
				SFRequest.setTimeout(60000);
				HttpResponse res = api.send(SFRequest);
				status = res.getStatusCode();
			}
			catch (System.CalloutException e) { status = 999; }
		}
		if (status != 200) {
			ApexPages.addmessage(
				new ApexPages.message(ApexPages.severity.WARNING,'Shopify\'s credentials are wrong. Please update credentials first and try again!')
			);
			return false;
		}
		else {
			return true;
		}
	}

	/* ----- JET multiple connection section ----- */

	// JET settings STRING
	static final Map<String, String> JET_SETTING_S = new Map<String, String> {
		'Jet.user' => 'ApiKey',
		'Jet.pass' => 'Password',
		'Jet.salesfunnel' => 'SalesFunnel'
	};
	// JET settings BOOLEAN
	static final Map<String, String> JET_SETTING_B = new Map<String, String> {
		'Jet.HandleShipping' => 'Handle Shipping'
	};

	// JET settings PICKLIST
	static final Map<String, String> JET_SETTING_P = new Map<String, String> {
		'Jet.Credential' => 'Named Credential'
	};

	public Boolean jetValidateSettings(List<SettingsWr> stringSettings, List<SettingsWr> booleanSettings, List<SettingsWr> picklistSettings) {
		Boolean isValid = true;
		// get ACTIVE jet exisiting connections settings
		List<TouchCRConnection__c> exisitngConnections = [
			SELECT Id, Name, Brand__c, Feature__c, isActive__c,
				(SELECT Id, Name, Value__c FROM TouchCRConnectionSettings__r)
			FROM TouchCRConnection__c
			WHERE Feature__c = : this.selectedFeature
			AND isActive__c = true
			AND Id != : currentConnection.Id
		];
		Set<String> existingActiveNames = new Set<String>();
		Set<String> existingKeys = new Set<String>();
		Set<String> existingSecrets = new Set<String>();

		// collect Name, ApiKey and Secret for exisiting conections
		for (TouchCRConnection__c exConn : exisitngConnections) {
			existingActiveNames.add(exConn.Name.toLowerCase());
			for (TouchCRConnectionSetting__c exConnSetting : exConn.TouchCRConnectionSettings__r) {
				if (exConnSetting.Name == 'Jet.user') {
					existingKeys.add(exConnSetting.Value__c);
				}
				if (exConnSetting.Name == 'Jet.pass') {
					existingSecrets.add(exConnSetting.Value__c);
				}
			}
		}
		// check for name
		if (existingActiveNames.contains(currentConnection.Name.toLowerCase())) {
			isValid = false;
			ApexPages.addmessage(
				new ApexPages.message(ApexPages.severity.WARNING,'Jet\'s new Connection Name already exists and active. Please choose different name and try again!')
			);
		}
		// check for api key/secret
		String apikey;
		String password;
		// collect key/secret for settings which are saved
		for (SettingsWr setting : stringSettings) {
			apikey = (setting.name == 'Jet.user') ? setting.valueS : apikey;
			password = (setting.name == 'Jet.pass') ? setting.valueS : password;
		}
		Boolean isStoreAlreadyConnected = (
			(String.isNotBlank(apikey)
			&& existingKeys.contains(apikey))
			||
			(String.isNotBlank(password)
			&& existingSecrets.contains(password))
		);
		if (isStoreAlreadyConnected) {
			isValid = false;
			ApexPages.addmessage(
				new ApexPages.message(ApexPages.severity.WARNING,'Jet\'s new Connection User and/or Password already exists and active. Please check store credentials and try again!')
			);
		}
		return isValid;
	}

	public Boolean jetMakeApiCall(List<SettingsWr> stringSettings, List<SettingsWr> booleanSettings, List<SettingsWr> picklistSettings) {
		Integer status;
		String apikey;
		String password;
		String namedCredential;

		String url = '/token';

		for (SettingsWr setting : stringSettings) {
			apikey = setting.name == 'Jet.user' ? setting.valueS : apikey;
			password = setting.name == 'Jet.pass' ? setting.valueS : password;
		}

		for (SettingsWr setting : booleanSettings) {}

		for (SettingsWr setting : picklistSettings) {
			namedCredential = setting.name == 'Jet.Credential' ? setting.valueS : namedCredential;
		}

		if (Test.isRunningTest()) {
			status = 200;
		}
		else {
			try{
				HttpRequest SFRequest = new HttpRequest();
				Http api = new Http();
				SFRequest.setMethod('POST');
				SFRequest.setEndpoint('callout:' + namedCredential + url);
				SFRequest.setHeader('Content-Type', 'application/json');
				SFRequest.setBody(JSON.serialize(new Map<String, String> {
					'user' => apikey,
					'pass' => password
				}));
				SFRequest.setTimeout(60000);
				HttpResponse res = api.send(SFRequest);
				status = res.getStatusCode();
			}
			catch (System.CalloutException e) { status = 999; }
		}
		if (status != 200) {
			ApexPages.addmessage(
				new ApexPages.message(ApexPages.severity.WARNING,'Jet\'s credentials are wrong. Please update credentials first and try again!')
			);
			return false;
		}
		else {
			return true;
		}
	}

	/* ----- AMAZON multiple connection section ----- */

	// AMAZON settings STRING
	static final Map<String, String> AMAZON_SETTING_S = new Map<String, String> {
		'Amazon.ApiKey' => 'API Key',
		'Amazon.ApiSecret' => 'API Secret',
		'Amazon.MerchantId' => 'Merchant Id',
		'Amazon.MarketPlaceId' => 'Amazon MarketPlace Id',
		'Amazon.SalesFunnel' => 'Sales Funnel'
	};
	// AMAZON settings PICKLIST
	static final Map<String, String> AMAZON_SETTING_P = new Map<String, String> {
		'Amazon.Credential' => 'Named Credential'
	};
	// AMAZON settings BOOLEAN
	static final Map<String, String> AMAZON_SETTING_B = new Map<String, String> {};

	public Boolean amazonMakeApiCall(List<SettingsWr> stringSettings, List<SettingsWr> booleanSettings, List<SettingsWr> picklistSettings) {

		String apiKey;
		String apiSectet;
		String merchantId;
		String marketplaceId;
		String salesfunnel;
		String credential;

		for (SettingsWr setting : stringSettings) {
			apiKey = setting.name == 'Amazon.ApiKey' ? setting.valueS : apiKey;
			apiSectet = setting.name == 'Amazon.ApiSecret' ? setting.valueS : apiSectet;
			merchantId = setting.name == 'Amazon.MerchantId' ? setting.valueS : merchantId;
			marketplaceId = setting.name == 'Amazon.MarketPlaceId' ? setting.valueS : marketplaceId;
			salesfunnel = setting.name == 'Amazon.SalesFunnel' ? setting.valueS : salesfunnel;
		}
		for (SettingsWr setting : booleanSettings) {}
		for (SettingsWr setting : picklistSettings) {
			credential = setting.name == 'Amazon.Credential' ? setting.valueS : salesfunnel;
		}

		String amazonEndpoint = 'callout:' + credential + '/Products/2011-10-01';

		List<String> parameters = new List<String>();
		parameters.add('AWSAccessKeyId=' + apiKey);
		parameters.add('MarketplaceId=' + marketplaceId);
		parameters.add('SellerId=' + merchantId);
		parameters.add('Action=ListMatchingProducts');
		parameters.add('Query=validate');
		parameters.add('SignatureMethod=HmacSHA256');
		parameters.add('SignatureVersion=2');

		DateTime now = Datetime.now();
		String timestamp = now.formatGMT('yyyy-MM-dd') + 'T' + now.formatGmt('HH:mm:ss') + 'Z';
		timestamp = timestamp.replace(':', '%3A');

		parameters.add('LastUpdatedAfter='+now.formatGMT('yyyy-MM-dd') + 'T00%3A00%3A00Z');

		parameters.add('Timestamp=' + timestamp);

		parameters.add('Version=2011-10-01');

		parameters.sort();

		String canonicalString = 'POST\nmws.amazonservices.com\n/Products/2011-10-01\n';
		for (String param : parameters) {
			canonicalString += param + '&';

		}
		canonicalString = canonicalString.removeEnd('&');

		try {
			Blob blobSignature = Crypto.generateMac('HmacSHA256', Blob.valueOf(canonicalString), Blob.valueOf(apiSectet));
			String signature = 'Signature=' + EncodingUtil.urlEncode(EncodingUtil.base64Encode(blobSignature), 'UTF-8') ;
			parameters.add(signature);
		}
		catch(Exception ex) {
			return false;
		}

		String requestURL = amazonEndpoint + '?';
		for (String param : parameters) {
			requestURL += param + '&';
		}
		requestURL = requestURL.removeEnd('&');

		Integer status;

		HttpRequest amazonReq = new HttpRequest();
		amazonReq.setMethod('POST');
		amazonReq.setEndpoint(requestURL);
		Http sendhttp = new Http();

		if (Test.isRunningTest()) {
			status = 200;
		}
		else {
			try{
				HttpResponse res = sendhttp.send(amazonReq);
				status = res.getStatusCode();
			}
			catch (System.CalloutException e) {
				return false;
			}
		}
		return (status == 200) ? true : false;
	}

	/* ----- MAGENTO multiple connection section ----- */

	// MAGENTO settings STRING
	static final Map<String, String> MAGENTO_SETTING_S = new Map<String, String> {
		'Magento.ApiUser' => 'API User',
		'Magento.ApiPassword' => 'API Password',
		'Magento.SalesFunnel' => 'Sales Funnel'
	};
	// MAGENTO settings PICKLIST
	static final Map<String, String> MAGENTO_SETTING_P = new Map<String, String> {
		'Magento.Credential' => 'Named Credential'
	};
	// MAGENTO settings BOOLEAN
	static final Map<String, String> MAGENTO_SETTING_B = new Map<String, String> {};

	public Boolean magentoMakeApiCall(List<SettingsWr> stringSettings, List<SettingsWr> booleanSettings, List<SettingsWr> picklistSettings) {

		String apiUser;
		String apiPassword;
		String salesfunnel;
		String namedCredential;

		for (SettingsWr setting : stringSettings) {
			apiUser = setting.name == 'Magento.ApiUser' ? setting.valueS : apiUser;
			apiPassword = setting.name == 'Magento.ApiPassword' ? setting.valueS : apiPassword;
			salesfunnel = setting.name == 'Magento.SalesFunnel' ? setting.valueS : salesfunnel;
		}

		for (SettingsWr setting : booleanSettings) {}

		for (SettingsWr setting : picklistSettings) {
			namedCredential = setting.name == 'Magento.Credential' ? setting.valueS : namedCredential;
		}

		String login = '{"username":"'+ apiUser +'","password":"'+ apiPassword +'"}';
		String magentoUrl = 'callout:' + namedCredential + '/integration/admin/token';
		Integer status;

		HttpRequest magentoRequest = new HttpRequest();
		Http magHttp = new Http();
		magentoRequest.setBody(login);
		magentoRequest.setHeader('content-type', 'application/json');
		magentoRequest.setMethod('POST');
		magentoRequest.setEndpoint(magentoUrl);
		magentoRequest.setTimeout(60000);

		if (Test.isRunningTest()) {
			status = 200;
		}
		else {
			try{
				HttpResponse res = magHttp.send(magentoRequest);
				status = res.getStatusCode();
			}
			catch (System.CalloutException e) {
				return false;
			}
		}
		return (status == 200) ? true : false;
	}
}