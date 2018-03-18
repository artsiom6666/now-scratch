@isTest
private class TowerDataApiDemoTest {

	public static final String NO_INTERESTS = '{"gender":"Male"}';
	public static final String ALL_RESPONSE = '{"age":"45-54","gender":"Female","zip":"60614","education":"Completed College","net_worth":"500k-750k","household_income":"150k-175k","home_market_value":"350k-500k","home_owner_status":"Own","length_of_residence":"3 Years","marital_status":"Single","occupation":"Professional","presence_of_children":"No","eam":{"month_last_open":"2016-04","velocity":10,"date_first_seen":"2010-04-17","popularity":9},"interests":{"arts_and_crafts":true,"blogging":true,"books":true,"business":true,"health_and_wellness":true,"news_and_current_events":true,"automotive":true,"baby_product_buyer":true,"beauty":true,"charitable_donors":true,"cooking":true,"discount_shopper":true,"high_end_brand_buyer":true,"home_and_garden":true,"home_improvement":true,"luxury_goods":true,"magazine_buyer":true,"outdoor_and_adventure":true,"pets":true,"sports":true,"technology":true,"travel":true}}';
	public static final String BAD_RESPONSE = 'API Key is not the correct length. Please make sure you are passing the correct value.';
	public static final String BAD_RESPONSE2 = '{"eam":{"velocity":0,"date_first_seen":"now","popularity":0},"gender":"Female"}';


	@isTest static void test_account_allsection() {
		//set all custom settings to true
		TouchCRConfigurationController obj = new TouchCRConfigurationController();
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

		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock(ALL_RESPONSE));

		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testObj = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'johndoe@example.com');
		insert testObj;

		String access_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyU0xZMU9FU1VHMzZDVFBIUlhMS1lLQ0EzIiwiaXNzIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hcHBsaWNhdGlvbnMvVWJlVU9WYlNVM1dCMVlCR05QaVl5IiwiaWF0IjoxNDg4MjgyNjA4LCJleHAiOjE0ODkxNDY2MDgsInNjb3BlIjoiIn0.5oTNt5CmE80imx4DvyZtgz8hOsaH22iePiDhT7Xpeqw';

		Map<String, String> touchCrSettingsToUpsert = new Map<String, String>();
	            touchCrSettingsToUpsert.put('Endpoint.TokenPart1', access_token.substring(0, 254));
	            touchCrSettingsToUpsert.put('Endpoint.TokenPart2', access_token.substring(254));
	            touchCrSettingsToUpsert.put('Endpoint.TokenType', 'Bearer');
	            touchCrSettingsToUpsert.put('Endpoint.ClientId', 'Test');
	            touchCrSettingsToUpsert.put('Endpoint.ClientSecret', 'Test');

	        TouchCRHelper.setSettings(touchCrSettingsToUpsert);

		Test.startTest();
			TowerDataApiDemo api = new TowerDataApiDemo();
			api.setObject(testObj);
			api.callApi();
			api.logCall();
			testObj = (Account) api.appendData();
			Log__c aLog = api.logCall();
		Test.stopTest();

		Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();
	        TouchCR_Settings__c tokenPart1 = settingsMap.get('Endpoint.TokenPart1');
	        TouchCR_Settings__c tokenPart2 = settingsMap.get('Endpoint.TokenPart2');

		String updated_access_token = 'updatedToken' + access_token;

		//AUTH
		System.assertEquals(updated_access_token, tokenPart1.Value__c + tokenPart2.Value__c);

		//LOG
		System.assertNotEquals(null, aLog);
		System.assertEquals(TowerDataApi.SUCCESS_MESSAGE, aLog.Event_Status__c);
		System.assertEquals(testObj.Id, aLog.Account__c);

		//DEMO
		System.assertEquals('45-54', testObj.Append_Demo_Age__c);
		System.assertEquals('Female', testObj.Append_Demo_Gender__c);
		System.assertEquals('60614', testObj.Append_Demo_Zip__c);
		System.assertEquals('Completed College', testObj.Append_Demo_Education__c);
		System.assertEquals('500k-750k', testObj.Append_Demo_Net_Worth__c);
		//HOUSING
		System.assertEquals('150k-175k', testObj.Append_House_Income__c);
		System.assertEquals('350k-500k', testObj.Append_House_Value__c);
		System.assertEquals('Own', testObj.Append_House_Owner_Status__c);
		System.assertEquals('3 Years', testObj.Append_House_Length_of_Residence__c);
		System.assertEquals('Single', testObj.Append_House_Marital_Status__c);
		System.assertEquals('Professional', testObj.Append_House_Occupation__c);
		System.assertEquals('No', testObj.Append_House_Children__c);
		//INTERESTS
		System.assertEquals(true, testObj.Append_Interest_Arts_Craft__c);
		System.assertEquals(true, testObj.Append_Interest_Blogging__c);
		System.assertEquals(true, testObj.Append_Interest_Books__c);
		System.assertEquals(true, testObj.Append_Interest_Business__c);
		System.assertEquals(true, testObj.Append_Interest_Health_Wellness__c);
		System.assertEquals(true, testObj.Append_Interest_News_Current_Affairs__c);
		//PURCHASE
		System.assertEquals(true, testObj.Append_Purchase_Automotive__c);
		System.assertEquals(true, testObj.Append_Purchase_Baby_Product_Buyer__c);
		System.assertEquals(true, testObj.Append_Purchase_Beauty__c);
		System.assertEquals(true, testObj.Append_Purchase_Charitable_Doner__c);
		System.assertEquals(true, testObj.Append_Purchase_Cooking__c);
		System.assertEquals(true, testObj.Append_Purchase_High_End_Brand_Buyer__c);
		System.assertEquals(true, testObj.Append_Purchase_Home_Garden__c);
		System.assertEquals(true, testObj.Append_Purchase_Home_Improvement__c);
		System.assertEquals(true, testObj.Append_Purchase_Luxury_Goods_Jewelry__c);
		System.assertEquals(true, testObj.Append_Purchase_Magazine_Buyer__c);
		System.assertEquals(true, testObj.Append_Purchase_Outdoor_Adventure__c);
		System.assertEquals(true, testObj.Append_Purchase_Pets__c);
		System.assertEquals(true, testObj.Append_Purchase_Sports__c);
		System.assertEquals(true, testObj.Append_Purchase_Technology__c);
		System.assertEquals(true, testObj.Append_Purchase_Travel__c);
		//EAM
		System.assertEquals('2016-04', testObj.EAM_Month_Last_Opened__c);
		System.assertEquals(10, testObj.EAM_Velocity__c);
		System.assertEquals('2010-04-17', testObj.EAM_Date_First_Seen__c);
		System.assertEquals(9, testObj.EAM_Popularity__c);
	}

	@isTest static void test_lead_allsections() {
		//set all custom settings to true
		TouchCRConfigurationController obj = new TouchCRConfigurationController();
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

		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock(ALL_RESPONSE));

		Lead testObj = new Lead(
			FirstName = 'John',
			LastName = 'Doe',
			Email = 'johndoe@example.com');
		insert testObj;

		String access_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyU0xZMU9FU1VHMzZDVFBIUlhMS1lLQ0EzIiwiaXNzIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hcHBsaWNhdGlvbnMvVWJlVU9WYlNVM1dCMVlCR05QaVl5IiwiaWF0IjoxNDg4MjgyNjA4LCJleHAiOjE0ODkxNDY2MDgsInNjb3BlIjoiIn0.5oTNt5CmE80imx4DvyZtgz8hOsaH22iePiDhT7Xpeqw';

		Map<String, String> touchCrSettingsToUpsert = new Map<String, String>();
	            touchCrSettingsToUpsert.put('Endpoint.TokenPart1', access_token.substring(0, 254));
	            touchCrSettingsToUpsert.put('Endpoint.TokenPart2', access_token.substring(254));
	            touchCrSettingsToUpsert.put('Endpoint.TokenType', 'Bearer');
	            touchCrSettingsToUpsert.put('Endpoint.ClientId', 'Test');
	            touchCrSettingsToUpsert.put('Endpoint.ClientSecret', 'Test');

	        TouchCRHelper.setSettings(touchCrSettingsToUpsert);

		Test.startTest();
			TowerDataApiDemo api = new TowerDataApiDemo();
			api.setObject(testObj);
			api.callApi();
			api.logCall();
			testObj = (Lead) api.appendData();
			Log__c aLog = api.logCall();
		Test.stopTest();

		Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();
        TouchCR_Settings__c tokenPart1 = settingsMap.get('Endpoint.TokenPart1');
        TouchCR_Settings__c tokenPart2 = settingsMap.get('Endpoint.TokenPart2');

		String updated_access_token = 'updatedToken' + access_token;

		//AUTH
		System.assertEquals(updated_access_token, tokenPart1.Value__c + tokenPart2.Value__c);

		//LOG
		System.assertNotEquals(null, aLog);
		System.assertEquals(TowerDataApi.SUCCESS_MESSAGE, aLog.Event_Status__c);
		System.assertEquals(testObj.Id, aLog.Lead__c);

		//DEMO
		System.assertEquals('45-54', testObj.Append_Demo_Age__c);
		System.assertEquals('Female', testObj.Append_Demo_Gender__c);
		System.assertEquals('60614', testObj.Append_Demo_Zip__c);
		System.assertEquals('Completed College', testObj.Append_Demo_Education__c);
		System.assertEquals('500k-750k', testObj.Append_Demo_Net_Worth__c);
		//HOUSING
		System.assertEquals('150k-175k', testObj.Append_House_Income__c);
		System.assertEquals('350k-500k', testObj.Append_House_Value__c);
		System.assertEquals('Own', testObj.Append_House_Owner_Status__c);
		System.assertEquals('3 Years', testObj.Append_House_Length_of_Residence__c);
		System.assertEquals('Single', testObj.Append_House_Marital_Status__c);
		System.assertEquals('Professional', testObj.Append_House_Occupation__c);
		System.assertEquals('No', testObj.Append_House_Children__c);
		//INTERESTS
		System.assertEquals(true, testObj.Append_Interest_Arts_Craft__c);
		System.assertEquals(true, testObj.Append_Interest_Blogging__c);
		System.assertEquals(true, testObj.Append_Interest_Books__c);
		System.assertEquals(true, testObj.Append_Interest_Business__c);
		System.assertEquals(true, testObj.Append_Interest_Health_Wellness__c);
		System.assertEquals(true, testObj.Append_Interest_News_Current_Affairs__c);
		//PURCHASE
		System.assertEquals(true, testObj.Append_Purchase_Automotive__c);
		System.assertEquals(true, testObj.Append_Purchase_Baby_Product_Buyer__c);
		System.assertEquals(true, testObj.Append_Purchase_Beauty__c);
		System.assertEquals(true, testObj.Append_Purchase_Charitable_Doner__c);
		System.assertEquals(true, testObj.Append_Purchase_Cooking__c);
		System.assertEquals(true, testObj.Append_Purchase_High_End_Brand_Buyer__c);
		System.assertEquals(true, testObj.Append_Purchase_Home_Garden__c);
		System.assertEquals(true, testObj.Append_Purchase_Home_Improvement__c);
		System.assertEquals(true, testObj.Append_Purchase_Luxury_Goods_Jewelry__c);
		System.assertEquals(true, testObj.Append_Purchase_Magazine_Buyer__c);
		System.assertEquals(true, testObj.Append_Purchase_Outdoor_Adventure__c);
		System.assertEquals(true, testObj.Append_Purchase_Pets__c);
		System.assertEquals(true, testObj.Append_Purchase_Sports__c);
		System.assertEquals(true, testObj.Append_Purchase_Technology__c);
		System.assertEquals(true, testObj.Append_Purchase_Travel__c);
		//EAM
		System.assertEquals('2016-04', testObj.EAM_Month_Last_Opened__c);
		System.assertEquals(10, testObj.EAM_Velocity__c);
		System.assertEquals('2010-04-17', testObj.EAM_Date_First_Seen__c);
		System.assertEquals(9, testObj.EAM_Popularity__c);
	}

	@isTest static void test_account_badresponse() {
		//set all custom settings to true
		TouchCRConfigurationController obj = new TouchCRConfigurationController();
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

		Test.setMock(HttpCalloutMock.class, new TowerDataApiMock(BAD_RESPONSE));
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testObj = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'John',
			LastName = 'Doe',
			PersonEmail = 'johndoe@example.com');
		insert testObj;

		Test.startTest();
			TowerDataApiDemo api = new TowerDataApiDemo();
			api.setObject(testObj);
			api.callApi();
			api.logCall();
			testObj = (Account) api.appendData();
			Log__c aLog = api.logCall();
		Test.stopTest();

		//LOG
		System.assertNotEquals(null, aLog);
		System.assertEquals(TowerDataApi.ERROR_MESSAGE, aLog.Event_Status__c);
		System.assertEquals(testObj.Id, aLog.Account__c);

		//DEMO
		System.assertEquals(null, testObj.Append_Demo_Age__c);
		System.assertEquals(null, testObj.Append_Demo_Gender__c);
		System.assertEquals(null, testObj.Append_Demo_Zip__c);
		System.assertEquals(null, testObj.Append_Demo_Education__c);
		System.assertEquals(null, testObj.Append_Demo_Net_Worth__c);
		//HOUSING
		System.assertEquals(null, testObj.Append_House_Income__c);
		System.assertEquals(null, testObj.Append_House_Value__c);
		System.assertEquals(null, testObj.Append_House_Owner_Status__c);
		System.assertEquals(null, testObj.Append_House_Length_of_Residence__c);
		System.assertEquals(null, testObj.Append_House_Marital_Status__c);
		System.assertEquals(null, testObj.Append_House_Occupation__c);
		System.assertEquals(null, testObj.Append_House_Children__c);
		//INTERESTS
		System.assertEquals(false, testObj.Append_Interest_Arts_Craft__c);
		System.assertEquals(false, testObj.Append_Interest_Blogging__c);
		System.assertEquals(false, testObj.Append_Interest_Books__c);
		System.assertEquals(false, testObj.Append_Interest_Business__c);
		System.assertEquals(false, testObj.Append_Interest_Health_Wellness__c);
		System.assertEquals(false, testObj.Append_Interest_News_Current_Affairs__c);
		//PURCHASE
		System.assertEquals(false, testObj.Append_Purchase_Automotive__c);
		System.assertEquals(false, testObj.Append_Purchase_Baby_Product_Buyer__c);
		System.assertEquals(false, testObj.Append_Purchase_Beauty__c);
		System.assertEquals(false, testObj.Append_Purchase_Charitable_Doner__c);
		System.assertEquals(false, testObj.Append_Purchase_Cooking__c);
		System.assertEquals(false, testObj.Append_Purchase_High_End_Brand_Buyer__c);
		System.assertEquals(false, testObj.Append_Purchase_Home_Garden__c);
		System.assertEquals(false, testObj.Append_Purchase_Home_Improvement__c);
		System.assertEquals(false, testObj.Append_Purchase_Luxury_Goods_Jewelry__c);
		System.assertEquals(false, testObj.Append_Purchase_Magazine_Buyer__c);
		System.assertEquals(false, testObj.Append_Purchase_Outdoor_Adventure__c);
		System.assertEquals(false, testObj.Append_Purchase_Pets__c);
		System.assertEquals(false, testObj.Append_Purchase_Sports__c);
		System.assertEquals(false, testObj.Append_Purchase_Technology__c);
		System.assertEquals(false, testObj.Append_Purchase_Travel__c);
		//EAM
		System.assertEquals(null, testObj.EAM_Month_Last_Opened__c);
		System.assertEquals(null, testObj.EAM_Velocity__c);
		System.assertEquals(null, testObj.EAM_Date_First_Seen__c);
		System.assertEquals(null, testObj.EAM_Popularity__c);
	}

}