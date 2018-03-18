@isTest
private class TouchCRHelperTest {

	@isTest static void test_globalmethod() {
		TouchCR_Settings__c old = new TouchCR_Settings__c(
			Name = 'testTouchC1',
			Value__c = 'test'
		);
		insert old;

		Map<String,String> newTouchCRSettings = new Map<String, String> {
			'testTouchC1' => 'testTouchC1',
			'testTouchC2' => 'testTouchC2',
			'testTouchC3' => 'testTouchC3'
		};
		Set<String> setNameSettings = newTouchCRSettings.keySet();

		TouchCRHelper.setSettings(newTouchCRSettings);

		Map<String, TouchCR_Settings__c> allSettings = TouchCR_Settings__c.getAll();
		for (String settingKey : allSettings.keySet()) {
			if (setNameSettings.contains(settingKey)) {
				TouchCR_Settings__c setting = allSettings.get(settingKey);
				System.assertEquals(settingKey, setting.Value__c);
			}
		}

		Map<String, String> getSettings = TouchCRHelper.getSettings('testTouch');

		for (String settingKey : getSettings.keySet()) {
			System.assertEquals(settingKey, getSettings.get(settingKey));
		}
	}

	@isTest static void test_globalmethod_null_setting() {
		Map<String,String> newTouchCRSettings = new Map<String, String> {
			'' => 'testTouchC1',
			'null' => 'testTouchC2'
		};
		TouchCRHelper.setSettings(newTouchCRSettings);

		List<String> countSettings = new List<String>();
		Map<String, TouchCR_Settings__c> allSettings = TouchCR_Settings__c.getAll();

		for (String settingName : newTouchCRSettings.keySet()) {
			if(allSettings.containsKey(settingName)) {
				countSettings.add(settingName);
			}
		}
		System.assertEquals(0, countSettings.size());

		Map<String, String> getSettings = TouchCRHelper.getSettings('');
		System.assertEquals(0, getSettings.size());
	}

	@isTest static void test_globalmethod_allsettings() {
		TouchCR_Settings__c oldSetting = new TouchCR_Settings__c(
			Name = 'testTouchC1',
			Value__c = 'test'
		);
		insert oldSetting;

		Map<String, String> getSettings = TouchCRHelper.getSettings('allSettings');

		for (String settingKey : getSettings.keySet()) {
			System.assertEquals('testTouchC1', settingKey);
			System.assertEquals('test', getSettings.get(settingKey));
		}
	}

	@isTest static void test_getscp() {
		String resultGet = JSON.serialize(TouchCRHelper.getAvailableStatesAndCountries());
		System.assertNotEquals(null, resultGet);
		if (TouchCRHelper.isSCPEnabled()) {
			System.assert(resultGet.contains('US'));
		}
	}

	@isTest static void test_getisocode() {
		String isoCode = TouchCRHelper.getCurrencyIsoCode(new Order__c());
		System.assertEquals(3, isoCode.length());
	}

	@isTest static void test_getcurrency() {
		String resultCurrency = TouchCRHelper.getCurrencyLabel(new Order__c());
		System.assertNotEquals(null, resultCurrency);
	}

	@isTest static void test_scheduleBatch() {
		List<CronTrigger> ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'ScoreBrandCounter'];
		if (ct.size() != 0) {
			System.abortJob(ct[0].Id);
		}

		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'ScoreBrandCounter'];
		System.assertEquals(0, ct.size());

		String cronString = '' + DateTime.now().second() + ' ' +
				DateTime.now().addMinutes(1).minute() + ' ' + DateTime.now().hour() + ' ' +
				DateTime.now().day() + ' ' + DateTime.now().month() + ' ? ' +
				DateTime.now().year();

		Map<String, String> batchToSchedule = new Map<String, String>();
		batchToSchedule.put('Name', 'ScoreBrandCounter');
		batchToSchedule.put('CronString', cronString);
		batchToSchedule.put('BatchName', 'ScoreBrandCounterScheduler');
		TouchCRHelper.scheduleBatch(batchToSchedule);

		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'ScoreBrandCounter'];
		System.assertEquals(1, ct.size());
		batchToSchedule.put('BatchName', 'test');
		System.assertEquals(false, TouchCRHelper.scheduleBatch(batchToSchedule));
	}

	@isTest static void test_getCustomSettings() {
		List<Map<String, String>> allPaymentAgents;
		allPaymentAgents = TouchCRHelper.getCustomSettings('TouchCRBase__Payment_Agents__c');
		System.assertEquals(0, allPaymentAgents.size());

		List<Payment_Agents__c> agentsToInsert = new List<Payment_Agents__c>();
		Payment_Agents__c paymentAgent = new Payment_Agents__c();
		paymentAgent.Name = 'test';
		agentsToInsert.add(paymentAgent);
		insert agentsToInsert;

		allPaymentAgents = TouchCRHelper.getCustomSettings('TouchCRBase__Payment_Agents__c');
		System.assertEquals(1, allPaymentAgents.size());
		System.assertEquals('test', allPaymentAgents[0].get('Name'));
	}

	@isTest static void test_setCustomSettings() {
		Map<String, Payment_Agents__c> allPaymentAgents = Payment_Agents__c.getAll();
		System.assertEquals(0, allPaymentAgents.size());

		List<Map<String, String>> agentsToInsert = new List<Map<String, String>>();
		Map<String, String> paymentAgent = new Map<String, String>();
		paymentAgent.put('Name', 'test');
		paymentAgent.put('TouchCRBase__Active__c', 'false');
		agentsToInsert.add(paymentAgent);

		TouchCRHelper.setCustomSettings('TouchCRBase__Payment_Agents__c', agentsToInsert);

		allPaymentAgents = Payment_Agents__c.getAll();
		System.assertEquals(1, allPaymentAgents.size());
		System.assertEquals('test', allPaymentAgents.get('test').Name);
		System.assertEquals(false, allPaymentAgents.get('test').Active__c);

		List<Map<String, String>> agentsToUpsert = new List<Map<String, String>>();
		paymentAgent = new Map<String, String>();
		paymentAgent.put('Name', 'test');
		paymentAgent.put('TouchCRBase__Active__c', 'true');
		agentsToUpsert.add(paymentAgent);
		TouchCRHelper.setCustomSettings('TouchCRBase__Payment_Agents__c', agentsToUpsert);
		allPaymentAgents = Payment_Agents__c.getAll();
		System.assertEquals(true, allPaymentAgents.get('test').Active__c);
	}

	@isTest static void test_getAllAvailableCurrencyCodes() {
		Set<String> res = TouchCRHelper.getAllAvailableCurrencyCodes();
		System.assertNotEquals(0, res.size());
	}

	@isTest static void test_setValidateAndFixCurrencyIsoCode() {
		Account testSObject = new Account();
		testSObject = (Account)TouchCRHelper.setCurrencyIsoCode(new Account(Name = 'test'), 'usd');
		System.assertEquals('test', testSObject.Name);
	}

	@isTest static void test_getOrderDefaultSoqlQueryString() {
		String res = TouchCRHelper.getOrderDefaultSoqlQueryString();
		List<String> orderFieldNames = res.split(',');
		System.assertEquals('Account__r.Name', orderFieldNames.get(1));
	}

	@isTest static void test_setAuthCredentinals() {

		Map<String, String> touchCrSettingsToUpsert = new Map<String, String>();
			touchCrSettingsToUpsert.put('Endpoint.TokenPart1', '');
			touchCrSettingsToUpsert.put('Endpoint.TokenPart2', '');
			touchCrSettingsToUpsert.put('Endpoint.TokenType', 'Bearer');

		TouchCRHelper.setSettings(touchCrSettingsToUpsert);

		Test.startTest();
			TouchCRHelper.setAuthCredentinals('testToken');
		Test.stopTest();

		Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();

		TouchCR_Settings__c tokenPart1Setting = settingsMap.get('Endpoint.TokenPart1');
		TouchCR_Settings__c tokenPart2Setting = settingsMap.get('Endpoint.TokenPart2');

		System.assertEquals('testToken', tokenPart1Setting.Value__c);
	}
}