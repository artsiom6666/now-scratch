@isTest
private class TouchCRConfigurationControllerTest {

	@isTest static void test_paypalsettings() {
		TouchCRConfigurationController obj = new TouchCRConfigurationController();
		obj.initPaypalSettings();
		obj.savePaypalSettings();

		//NEW
		Map<String, TouchCR_Settings__c> allSettings = TouchCR_Settings__c.getAll();
		for (String settingKey : allSettings.keySet()) {
			TouchCR_Settings__c setting = allSettings.get(settingKey);
			System.assertNotEquals(null, setting.Value__c);
		}
		// SAVE
		for (TouchCRConfigurationController.SettingsWr setting : obj.ppSettingsWrS) {
			setting.valueS = 'paypal';
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.ppSettingsWrB) {
			setting.valueB = true;
		}
		obj.savePaypalSettings();

		for (TouchCRConfigurationController.SettingsWr setting : obj.ppSettingsWrS) {
			System.assertEquals('paypal', setting.valueS);
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.ppSettingsWrB) {
			System.assertEquals(true, setting.valueB);
		}
	}

	@isTest static void test_configuration_save_cancel() {
		TouchCRConfigurationController obj = new TouchCRConfigurationController();
		obj.saveDASettings();

		//assert values inserted
		Map<String, TouchCR_Settings__c> allSettings = TouchCR_Settings__c.getAll();
		for (String settingKey : allSettings.keySet()) {
			TouchCR_Settings__c setting = allSettings.get(settingKey);
			System.assertNotEquals(null, setting.Value__c);
		}

		//set all values, then save them
		for (TouchCRConfigurationController.SettingsWr setting : obj.accountSettingsBWr) {
			setting.valueB = true;
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.leadSettingsBWr) {
			setting.valueB = true;
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.globalSettingsBWr) {
			setting.valueB = true;
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.globalSettingsNWr) {
			setting.valueN = '10';
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.globalSettingsSWr) {
			setting.valueS = 'apikey';
		}
		//SAVE
		obj.saveDASettings();

		for (TouchCRConfigurationController.SettingsWr setting : obj.accountSettingsBWr) {
			System.assertEquals(true, setting.valueB);
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.leadSettingsBWr) {
			System.assertEquals(true, setting.valueB);
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.globalSettingsBWr) {
			System.assertEquals(true, setting.valueB);
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.globalSettingsNWr) {
			System.assertEquals('10', setting.valueN);
		}
		for (TouchCRConfigurationController.SettingsWr setting : obj.globalSettingsSWr) {
			System.assertEquals('apikey', setting.valueS);
		}

		//check cancel revert all changes
		obj.accountSettingsBWr[0].valueB = false;
		obj.leadSettingsBWr[0].valueB = false;
		obj.globalSettingsBWr[0].valueB = false;
		obj.globalSettingsNWr[0].valueN = '500';
		obj.globalSettingsSWr[0].valueS = 'newkey';

		//CANCEL
		obj.cancelDASettings();

		System.assertEquals(true, obj.accountSettingsBWr[0].valueB);
		System.assertEquals(true, obj.leadSettingsBWr[0].valueB);
		System.assertEquals(true, obj.globalSettingsBWr[0].valueB);
		System.assertEquals('10', obj.globalSettingsNWr[0].valueN);
		System.assertEquals('apikey', obj.globalSettingsSWr[0].valueS);

		//Approve
		obj.confirmWork();
	}


	@isTest static void test_configuration_save_cancelFC() {
		TouchCRConfigurationController obj = new TouchCRConfigurationController();
		obj.saveFCSettings();

		//assert values inserted
		Map<String, TouchCR_Settings__c> allSettings = TouchCR_Settings__c.getAll();
		for (String settingKey : allSettings.keySet()) {
			TouchCR_Settings__c setting = allSettings.get(settingKey);
			System.assertNotEquals(null, setting.Value__c);
		}

		for (TouchCRConfigurationController.SettingsWr setting : obj.fcSettingsSWr) {
			setting.valueS = 'apikey';
		}
		//SAVE
		obj.saveFCSettings();

		for (TouchCRConfigurationController.SettingsWr setting : obj.fcSettingsSWr) {
			System.assertEquals('apikey', setting.valueS);
		}

		//check cancel revert all changes
		obj.fcSettingsSWr[0].valueS = 'newkey';

		//CANCEL
		obj.cancelFCSettings();
		System.assertEquals('apikey', obj.fcSettingsSWr[0].valueS);

		//Approve
		obj.confirmWorkFC();
	}



	@isTest static void test_initstatic() {
		TowerDataDTO.TowerDataSettings settings = TouchCRConfigurationController.initSettings();
		//all values by default is false
		//test virtual settings
		System.assertEquals(false, settings.accountAppendEmailOn);
		System.assertEquals(false, settings.leadAppendEmailOn);

		FullContactDTO.FullContactSettings settingsFC = TouchCRConfigurationController.initSettingsFC();
		//all values by default is false
		//test virtual settings
		System.assertEquals('', settingsFC.apiKey);


	}

	@isTest static void test_touchcrsettings() {
		Payment_Agents__c newPaymentAgents = new Payment_Agents__c(
			Name = 'Test Agent Name', Security_Key__c = 'test',
			Active__c = true, Type__c = 'Stripe', Merchant_ID__c = 'test'
		);
		insert newPaymentAgents;

		Map<String, String> settingsBrand = TouchCRConfigurationController.collectionBrandToGateway();
		Map<String, TouchCR_Settings__c> testObjPrefix = TouchCRConfigurationController.getBrandSettings();

		System.assertNotEquals(null, testObjPrefix);
		System.assertNotEquals(0, testObjPrefix.values().size());

		//enable brand
		List<String> brandTest = new List<String> {'brand1', 'brand2'};
		TouchCRConfigurationController.setActiveBrandsTest(new Set<String>(brandTest));

		Set<String> testObjSet = TouchCRConfigurationController.getActiveBrandValuesWithOutPrefix();

		TouchCRConfigurationController ctrl = new TouchCRConfigurationController();

		ctrl.saveTouchCRSettings();

		List<Profile> profUser = [SELECT Id, Name FROM Profile WHERE Name ='Customer Community Login User' LIMIT 5];
		Map<String, String> brandToProfileTest = new Map<String, String>();
		for (Integer idx = 0; idx < profUser.size(); idx++) {
			brandToProfileTest.put('brand' + idx, String.valueOf(profUser[idx].Id));
		}

		TouchCRConfigurationController.setAvailableBrandsToProfileTest(new Map<String, String>(brandToProfileTest));
		Map<String, String> testMapBrandToProfile = TouchCRConfigurationController.getBrandToProfileId();
		Map<String, String> activeBrandMap = TouchCRConfigurationController.activeBrandsNamesMap();

		System.assertEquals(2, testObjSet.size());
		System.assertEquals(profUser.size(), testMapBrandToProfile.size());
		System.assertEquals(0, activeBrandMap.size());
		System.assertEquals('', ctrl.apiKey);
		System.assertEquals(NULL, ctrl.firstRating);
		System.assertEquals(NULL, ctrl.secondRating);

		//Only works if there are active brands
		if (ctrl.wrappers.size() > 0) {
			ctrl.wrappers[0].gatewayId = 'test';
			ctrl.wrappers[0].commValue = 'test';
			ctrl.wrappers[0].googleValue = 'test';
		}

		ctrl.apiKey = 'testApiKey';
		ctrl.firstRating = 30;
		ctrl.secondRating = 75;
		ctrl.uspsValue = 'test';
		ctrl.isUserCreation = true;

		ctrl.selectedExecuteAtRFMScoreBrand = '1';
		ctrl.selectedExecuteAtRFMScore = '1';
		ctrl.selectedExecuteCampaignMember = '1';
		ctrl.selectedExecuteDataAppend = '1';
		ctrl.selectedExecuteHouseCleaner = '1';
		ctrl.selectedExecuteAtSubscription = '1';

		ctrl.selectedExecuteAtRFMScoreDay = '1';
		ctrl.selectedExecuteAtRFMScoreBrandDay = '1';
		ctrl.selectedExecuteCampaignMemberDay = '1';
		ctrl.selectedExecuteHouseCleanerDay = '1';
		ctrl.selectedRecordAgeHouseCleaner = '1';
		ctrl.selectedExecuteAtSubscriptionDay = '1';
		ctrl.selectedObjectHouseCleaner = 'Object';

		ctrl.selectedStateRFMScoreBrand = 'On';
		ctrl.selectedStateRFMScore = 'On';
		ctrl.selectedStateCampaignMember = 'On';
		ctrl.selectedStateDataAppend = 'On';
		ctrl.selectedStateHouseCleaner = 'On';
		ctrl.selectedStateSubscription = 'On';

		ctrl.saveTouchCRSettings();
		ctrl.cancelTouchCRSettings();

		System.assertNotEquals(NULL, ctrl.nextRunTimeRFMScoreBrand);
		System.assertNotEquals(NULL, ctrl.nextRunTimeRFMScore);
		System.assertNotEquals(NULL, ctrl.nextRunTimeCampaignMember);
		System.assertNotEquals(NULL, ctrl.nextRunTimeDataAppend);
		System.assertNotEquals(NULL, ctrl.nextRunTimeSubscription);
		System.assertNotEquals(NULL, ctrl.nextRunTimeHouseCleaner);

		ctrl.executeNowRFMScore();
		ctrl.executeNowRFMScoreBrand();
		ctrl.executeNowCampaignMember();
		ctrl.executeNowDataAppend();
		ctrl.executeNowHouseCleaner();
		ctrl.executeNowSubscription();

		ctrl.selectedStateRFMScoreBrand = 'Off';
		ctrl.selectedStateRFMScore = 'Off';
		ctrl.selectedStateCampaignMember = 'Off';
		ctrl.selectedStateDataAppend = 'Off';
		ctrl.selectedStateHouseCleaner = 'Off';
		ctrl.selectedStateSubscription = 'Off';

		ctrl.saveTouchCRSettings();

		System.assertEquals(NULL, ctrl.nextRunTimeRFMScoreBrand);
		System.assertEquals(NULL, ctrl.nextRunTimeRFMScore);
		System.assertEquals(NULL, ctrl.nextRunTimeCampaignMember);
		System.assertEquals(NULL, ctrl.nextRunTimeDataAppend);
		System.assertEquals(NULL, ctrl.nextRunTimeHouseCleaner);
		System.assertEquals(NULL, ctrl.nextRunTimeSubscription);

		System.assertEquals('testApiKey', ctrl.apiKey);
		System.assertEquals('30', String.valueOf(ctrl.firstRating));
		System.assertEquals('75', String.valueOf(ctrl.secondRating));
		System.assertEquals('test', ctrl.uspsValue);
		System.assertEquals('true', String.valueOf(ctrl.isUserCreation));
	}

	@isTest static void test_woosettings() {
		TouchCRConfigurationController ctrl = new TouchCRConfigurationController();

		ctrl.initWooSettings();
		ctrl.saveWooSettings();

		System.assertEquals('0', ctrl.selectedExecuteWoo);
		System.assertEquals('1', ctrl.selectedExecuteWooDay);
		System.assertEquals('1', ctrl.selectedExecuteHoursWoo);
		System.assertEquals('Days', ctrl.selectedFrequencyParameterWoo);

		ctrl.selectedExecuteWoo = '1';
		ctrl.selectedExecuteWooDay = '1';

		ctrl.saveWooSettings();
		ctrl.cancelWooSettings();
	}


	@isTest static void test_shopify() {
		TouchCRConfigurationController ctrl = new TouchCRConfigurationController();
		//insert settings
		if (ctrl.touchCRShopify) {
			ctrl.executeNowShopify();
		}

		ctrl.initShopifySettings();

		System.assertEquals('', ctrl.shopifyCallouts);


		ctrl.selectedStateShopify = 'On';
		ctrl.selectedExecuteShopify = '1';
		ctrl.selectedExecuteShopifyDay = '1';

		ctrl.shopifyCallouts = '1';


		ctrl.saveShopifySettings();
		ctrl.cancelShopifySettings();
		ctrl.executeNowShopify();

		System.assertEquals('1', TouchCR_Settings__c.getValues('Shopify.callOut').Value__c);
	}

	@isTest static void test_jet() {
		TouchCRConfigurationController ctrl = new TouchCRConfigurationController();
		//insert settings
		if (ctrl.touchCRJet) {
			ctrl.executeNowJet();
		}

		ctrl.initJetSettings();

		ctrl.selectedStateJet = 'On';
		ctrl.selectedExecuteJet = '1';
		ctrl.selectedExecuteJetDay = '1';

		ctrl.saveJetSettings();
		ctrl.cancelJetSettings();
		ctrl.executeNowJet();
	}

	@isTest static void test_magento() {
		TouchCRConfigurationController ctrl = new TouchCRConfigurationController();
		//insert settings
		if (ctrl.touchCRMagento) {
			ctrl.executeNowMagento();
		}
		ctrl.initMagentoSettings();
		ctrl.saveMagentoSettings();

		System.assertEquals(false, ctrl.magentoSalesforceMaster);

		ctrl.selectedStateMagento = 'On';
		ctrl.selectedExecuteMagento = '1';
		ctrl.selectedExecuteMagentoDay = '1';

		ctrl.magentoSalesforceMaster = true;

		ctrl.saveMagentoSettings();
		ctrl.cancelMagentoSettings();
		ctrl.executeNowMagento();

		System.assertEquals('true', TouchCR_Settings__c.getValues('Magento.SalesforceMaster').Value__c);
	}

	@isTest static void test_amazon() {
		TouchCRConfigurationController ctrl = new TouchCRConfigurationController();
		//insert settings
		if (ctrl.touchCRAmazon) {
			ctrl.executeNowAmazon();
		}

		ctrl.initAmazonSettings();

		System.assertEquals(false, ctrl.amazonSalesforceMaster);

		ctrl.selectedStateAmazon = 'On';
		ctrl.selectedExecuteAmazon = '1';
		ctrl.selectedExecuteAmazonDay = '1';
		ctrl.selectedStateAmazonMerge = 'On';
		ctrl.selectedExecuteAmazonMerge = '1';
		ctrl.selectedExecuteAmazonMergeDay = '1';

		ctrl.amazonSalesforceMaster = true;

		ctrl.saveAmazonSettings();
		ctrl.cancelAmazonSettings();
		ctrl.executeNowAmazon();
		ctrl.executeNowAmazonMergeSearch();

		System.assertEquals('true', TouchCR_Settings__c.getValues('Amazon.SalesforceMaster').Value__c);
	}

	@isTest static void test_scSettings() {
		TouchCRConfigurationController ctrl = new TouchCRConfigurationController();
		ctrl.initScSettings();

		System.assertEquals('', ctrl.scStoreLogo);
		System.assertEquals('', ctrl.scBrand);

		ctrl.scStoreLogo = '1';
		ctrl.scBrand = '7';

		ctrl.saveScSettings();
		ctrl.cancelScSettings();

		System.assertEquals('1/', TouchCR_Settings__c.getValues('SC.StoreLogo').Value__c);
		System.assertEquals('7', TouchCR_Settings__c.getValues('SC.Brand').Value__c);
	}

	@isTest static void test_getServices() {
		String resp = '{"collect": "Collect", "datafinder": "Datafinder"}';
		Test.setMock(HttpCalloutMock.class, new TouchCRConfigurationMock(resp));

		Test.startTest();

		TouchCRConfigurationController controller = new TouchCRConfigurationController();

		System.assertEquals(false, controller.isAbleMinfraud);
		System.assertEquals(false, controller.isAbleUsps);
		System.assertEquals(false, controller.isAbleDataAppend);

		resp = '{"fraudDetect": "Fraud Detect", "shipping": "Shipping", "person": "Person", "emailCheck": "Email Check", "collect": "Collect", "datafinder": "Datafinder"}';
		Test.setMock(HttpCalloutMock.class, new TouchCRConfigurationMock(resp));

		controller = new TouchCRConfigurationController();

		Test.stopTest();

		System.assertEquals(true, controller.isAbleMinfraud);
		System.assertEquals(true, controller.isAbleUsps);
		System.assertEquals(true, controller.isAbleDataAppend);
	}
}