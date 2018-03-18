@isTest
private class TouchCRMultiConfigurationControllerTest {

	@isTest static void test_configuration_new_setting() {
		Test.startTest();
			TouchCRMultiConfigurationController obj = new TouchCRMultiConfigurationController();
			obj.addNew();

			obj.newNameForSetting = 'newName';
			obj.selectedBrand = 'newBrand';
			obj.selectedFeature = 'Woo';
			obj.createNewNameSetting();
			Test.stopTest();

		List<TouchCRConnectionSetting__c> newList = [SELECT Id FROM TouchCRConnectionSetting__c];
		System.assertNotEquals(0, newList.size());
	}

	@isTest static void amazon_test_configuration_edit_setting() {
		TouchCRConnection__c newConnection = new TouchCRConnection__c(
			Brand__c = 'test',
			Feature__c = 'Amazon',
			Name = 'testName'
		);
		insert newConnection;

		Map<String, String> AMAZON_SETTING_S = new Map<String, String> {
			'Amazon.ApiKey' => 'API Key',
			'Amazon.ApiSecret' => 'API Secret',
			'Amazon.MerchantId' => 'Merchant Id',
			'Amazon.MarketPlaceId' => 'Amazon MarketPlace Id',
			'Amazon.SalesFunnel' => 'Sales Funnel'
		};
		Map<String, String> AMAZON_SETTING_P = new Map<String, String> {
			'Amazon.Credential' => 'Named Credential'
		};
		Map<String, String> AMAZON_SETTING_B = new Map<String, String> {};


		//Map<String, String> WOO_SETTING_S = new Map<String, String> {
		//	'Endpoint' => 'Connection Endpoint',
		//	'HashAlgorithm' => 'Hash Algorithm',
		//	'StoreURL' => 'API URL(Store URL)',
		//	'ConsumerKey' => 'Consumer Key',
		//	'ConsumerSecret' => 'Consumer Secret',
		//	'CheckFrequency' => 'Check Frequency in Minutes',
		//	'SalesFunnel' => 'Sales Funnel'
		//};

		//Map<String, String> WOO_SETTING_B = new Map<String, String> {
		//	'IsSSL' => 'Is SSL',
		//	'HandleShipping' => 'Handle Shipping',
		//	'SalesforceMaster' => 'Salesforce Master',
		//	'ReturnObject' => 'Return As Object',
		//	'HandleEmail' => 'Handle Email'
		//};

		//Map<String, String> WOO_SETTING_P = new Map<String, String> {
		//	'Credential' => 'NamedCredential'
		//};

		List<TouchCRConnectionSetting__c> connectionSettings = new List<TouchCRConnectionSetting__c>();
		for (String item : AMAZON_SETTING_S.keySet()) {
			connectionSettings.add(new TouchCRConnectionSetting__c(
				Name = item, TouchCRConnection__c = newConnection.Id, Value__c = AMAZON_SETTING_S.get(item)
			));
		}
		for (String item : AMAZON_SETTING_B.keySet()) {
			connectionSettings.add(new TouchCRConnectionSetting__c(
				Name = item, TouchCRConnection__c = newConnection.Id, Value__c = 'false'
			));
		}
		for (String item : AMAZON_SETTING_P.keySet()) {
			connectionSettings.add(new TouchCRConnectionSetting__c(
				Name = item, TouchCRConnection__c = newConnection.Id, Value__c = AMAZON_SETTING_P.get(item)
			));
		}
		insert connectionSettings;

		Test.startTest();
			TouchCRMultiConfigurationController obj = new TouchCRMultiConfigurationController();
			obj.selectedFeature = newConnection.Feature__c;
			obj.namePersonSetting = newConnection.Id;
			obj.editSetting();
			if (obj.settingsStringWr.size() > 0) {
				obj.settingsStringWr[0].valueS = 'test';
			}

			if (obj.settingsBooleanWr.size() > 0) {
				obj.settingsBooleanWr[0].valueB = true;
			}

			if (obj.settingsSelectListWr.size() > 0) {
				obj.settingsSelectListWr[0].valueS = 'test';
			}
			obj.saveSettings();

		Test.stopTest();

		List<TouchCRConnectionSetting__c> connectionSettingsList = [
			SELECT Id, Value__c
			FROM TouchCRConnectionSetting__c
			WHERE Name IN: AMAZON_SETTING_P.keySet()
		];
		System.assertEquals('test', connectionSettingsList[0].Value__c);
	}

	@isTest static void test_configuration_edit_cancel_delete() {
		TouchCRConnection__c newConnection = new TouchCRConnection__c(
			Brand__c = 'test',
			Feature__c = 'Woo',
			Name = 'testName'
		);
		insert newConnection;

		Test.startTest();
			TouchCRMultiConfigurationController obj = new TouchCRMultiConfigurationController();
			obj.namePersonSetting = newConnection.Id;
			obj.selectedFeature = newConnection.Feature__c;

			obj.editSetting();
			obj.cancelSettings();

			obj.namePersonSetting = newConnection.Id;
			obj.selectedFeature = newConnection.Feature__c;
			obj.deletedSettings();

		Test.stopTest();

		List<TouchCRConnection__c> connections = [SELECT Id FROM TouchCRConnection__c];
		System.assertEquals(0, connections.size());

		List<TouchCRConnectionSetting__c> connectionSettings = [SELECT Id FROM TouchCRConnectionSetting__c];
		System.assertEquals(0, connectionSettings.size());
	}

	@isTest static void magento_test_configuration_edit_setting() {
		TouchCRConnection__c newConnection = new TouchCRConnection__c(
			Brand__c = 'test',
			Feature__c = 'Magento',
			Name = 'testName'
		);
		insert newConnection;

		Map<String, String> MAGENTO_SETTING_S = new Map<String, String> {
			'Magento.ApiUser' => 'API Key',
			'Magento.ApiPassword' => 'API Secret',
			'Magento.SalesFunnel' => 'Sales Funnel'
		};
		Map<String, String> MAGENTO_SETTING_P = new Map<String, String> {
			'Magento.Credential' => 'Named Credential'
		};
		Map<String, String> MAGENTO_SETTING_B = new Map<String, String> {};

		List<TouchCRConnectionSetting__c> connectionSettings = new List<TouchCRConnectionSetting__c>();
		for (String item : MAGENTO_SETTING_S.keySet()) {
			connectionSettings.add(new TouchCRConnectionSetting__c(
				Name = item, TouchCRConnection__c = newConnection.Id, Value__c = MAGENTO_SETTING_S.get(item)
			));
		}
		for (String item : MAGENTO_SETTING_B.keySet()) {
			connectionSettings.add(new TouchCRConnectionSetting__c(
				Name = item, TouchCRConnection__c = newConnection.Id, Value__c = 'false'
			));
		}
		for (String item : MAGENTO_SETTING_P.keySet()) {
			connectionSettings.add(new TouchCRConnectionSetting__c(
				Name = item, TouchCRConnection__c = newConnection.Id, Value__c = MAGENTO_SETTING_P.get(item)
			));
		}
		insert connectionSettings;

		Test.startTest();
			TouchCRMultiConfigurationController obj = new TouchCRMultiConfigurationController();
			obj.selectedFeature = newConnection.Feature__c;
			obj.namePersonSetting = newConnection.Id;
			obj.editSetting();
			if (obj.settingsStringWr.size() > 0) {
				obj.settingsStringWr[0].valueS = 'test';
			}

			if (obj.settingsBooleanWr.size() > 0) {
				obj.settingsBooleanWr[0].valueB = true;
			}

			if (obj.settingsSelectListWr.size() > 0) {
				obj.settingsSelectListWr[0].valueS = 'test';
			}
			obj.saveSettings();

		Test.stopTest();

		List<TouchCRConnectionSetting__c> connectionSettingsList = [
			SELECT Id, Value__c
			FROM TouchCRConnectionSetting__c
			WHERE Name IN: MAGENTO_SETTING_P.keySet()
		];
		System.assertEquals('test', connectionSettingsList[0].Value__c);
	}

	@isTest static void jet_test_configuration_edit_setting() {
		TouchCRMultiConfigurationController obj = new TouchCRMultiConfigurationController();
		obj.addNew();
		obj.newNameForSetting = 'Jet_Test';
		obj.selectedBrand = 'Jet_Test_Brand';
		obj.selectedFeature = 'Jet';
		obj.createNewNameSetting();
		if (obj.settingsStringWr.size() > 0) {
			obj.settingsStringWr[0].valueS = 'test';
		}
		if (obj.settingsBooleanWr.size() > 0) {
			obj.settingsBooleanWr[0].valueB = true;
		}
		if (obj.settingsSelectListWr.size() > 0) {
			obj.settingsSelectListWr[0].valueS = 'test';
		}
		obj.currentConnection.isActive__c = true;
		obj.saveSettings();


		List<TouchCRConnection__c> testObjs = [SELECT Id, Name, Feature__c, Brand__c, isActive__c FROM TouchCRConnection__c];
		System.assertEquals(1, testObjs.size());
		System.assertEquals(true, testObjs[0].isActive__c);

		// second settings, validation check
		obj = new TouchCRMultiConfigurationController();
		obj.addNew();
		obj.newNameForSetting = 'Jet_Test';
		obj.selectedBrand = 'Jet_Test_Brand';
		obj.selectedFeature = 'Jet';
		obj.createNewNameSetting();
		if (obj.settingsStringWr.size() > 0) {
			obj.settingsStringWr[0].valueS = 'test';
		}
		if (obj.settingsBooleanWr.size() > 0) {
			obj.settingsBooleanWr[0].valueB = true;
		}
		if (obj.settingsSelectListWr.size() > 0) {
			obj.settingsSelectListWr[0].valueS = 'test';
		}
		obj.currentConnection.isActive__c = true;
		obj.saveSettings();

		testObjs = [SELECT Id, Name, Feature__c, Brand__c, isActive__c FROM TouchCRConnection__c];
		System.assertEquals(2, testObjs.size());
		System.assertEquals(true, testObjs[0].isActive__c);
		System.assertEquals(false, testObjs[1].isActive__c);
	}
}