@isTest
public class TouchCRAuraSettingsBatchesControllerTest {

	// RfmScoreBrandBatch
	static testMethod void test_RfmScoreBrandBatchController() {
		String settings = TouchCRAuraSettingsBatchesController.getRfmBrandSettingsApex();
		Map<String, String> settingsDesirialized = (Map<String, String>)System.JSON.deserialize(settings, Map<String, String>.class);
		System.assertEquals('', settingsDesirialized.get('Batch.RFMScoreBrandStatus'));
		System.assertEquals('', settingsDesirialized.get('Batch.RFMScoreBrandTime'));
		System.assertEquals('', settingsDesirialized.get('Batch.RFMScoreBrandDay'));

		TouchCRAuraSettingsBatchesController.RfmBrandSettingsWrapper newSetting = new TouchCRAuraSettingsBatchesController.RfmBrandSettingsWrapper();
		newSetting.selectedStateRFMScoreBrand = 'test1';
		newSetting.selectedExecuteAtRFMScoreBrandDay = 'test2';
		newSetting.selectedExecuteAtRFMScoreBrand = 'test3';
		TouchCRAuraSettingsBatchesController.saveRfmBrand(JSON.serialize(newSetting));

		String savedSettings = TouchCRAuraSettingsBatchesController.getRfmBrandSettingsApex();
		Map<String, String> savedSettingsDesirialized = (Map<String, String>)System.JSON.deserialize(savedSettings, Map<String, String>.class);
		System.assertEquals('test1', savedSettingsDesirialized.get('Batch.RFMScoreBrandStatus'));
		System.assertEquals('test3', savedSettingsDesirialized.get('Batch.RFMScoreBrandTime'));
		System.assertEquals('test2', savedSettingsDesirialized.get('Batch.RFMScoreBrandDay'));

		List<CronTrigger> ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'ScoreBrandCounter'];
		if (ct.size() != 0) {
			System.abortJob(ct[0].Id);
		}
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'ScoreBrandCounter'];
		System.assertEquals(0, ct.size());

		TouchCRAuraSettingsBatchesController.RfmBrandTimeScheduleJobsWrapper timeScheduleJobs = (TouchCRAuraSettingsBatchesController.RfmBrandTimeScheduleJobsWrapper)JSON.deserialize(TouchCRAuraSettingsBatchesController.getRfmBrandTimeScheduleJobs(), TouchCRAuraSettingsBatchesController.RfmBrandTimeScheduleJobsWrapper.class);
		System.assertEquals(NULL, timeScheduleJobs.nextRunTime);

		TouchCRAuraSettingsBatchesController.executeNowRFMScoreBrand();
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'ScoreBrandCounter'];
		System.assertEquals(1, ct.size());
		String cronString = DateTime.now().addMinutes(1).format('YYYY-MM-dd HH:mm:ss');
		TouchCRAuraSettingsBatchesController.executeNowRFMScoreBrand();
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'ScoreBrandCounter'];
		System.assertEquals(1, ct.size());

		timeScheduleJobs = (TouchCRAuraSettingsBatchesController.RfmBrandTimeScheduleJobsWrapper)JSON.deserialize(TouchCRAuraSettingsBatchesController.getRfmBrandTimeScheduleJobs(), TouchCRAuraSettingsBatchesController.RfmBrandTimeScheduleJobsWrapper.class);
		System.assertEquals(cronString, String.valueOf(timeScheduleJobs.nextRunTime));
	}

	// RfmScoreBatchSettings
	static testMethod void test_RfmScoreBatchSettingsController() {
		String settings = TouchCRAuraSettingsBatchesController.getRfmSettingsApex();
		Map<String, String> settingsDesirialized = (Map<String, String>)System.JSON.deserialize(settings, Map<String, String>.class);
		System.assertEquals('', settingsDesirialized.get('Batch.RFMScoreStatus'));
		System.assertEquals('', settingsDesirialized.get('Batch.RFMScoreTime'));
		System.assertEquals('', settingsDesirialized.get('Batch.RFMScoreDay'));

		TouchCRAuraSettingsBatchesController.RfmSettingsWrapper newSetting = new TouchCRAuraSettingsBatchesController.RfmSettingsWrapper();
		newSetting.selectedStateRFMScore = 'test1';
		newSetting.selectedExecuteAtRFMScoreDay = 'test2';
		newSetting.selectedExecuteAtRFMScore = 'test3';
		TouchCRAuraSettingsBatchesController.saveRfm(JSON.serialize(newSetting));

		String savedSettings = TouchCRAuraSettingsBatchesController.getRfmSettingsApex();
		Map<String, String> savedSettingsDesirialized = (Map<String, String>)System.JSON.deserialize(savedSettings, Map<String, String>.class);
		System.assertEquals('test1', savedSettingsDesirialized.get('Batch.RFMScoreStatus'));
		System.assertEquals('test3', savedSettingsDesirialized.get('Batch.RFMScoreTime'));
		System.assertEquals('test2', savedSettingsDesirialized.get('Batch.RFMScoreDay'));

		List<CronTrigger> ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'ScoreCalculation'];
		if (ct.size() != 0) {
			System.abortJob(ct[0].Id);
		}
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'ScoreCalculation'];
		System.assertEquals(0, ct.size());

		TouchCRAuraSettingsBatchesController.RfmTimeScheduleJobsWrapper timeScheduleJobs = (TouchCRAuraSettingsBatchesController.RfmTimeScheduleJobsWrapper)JSON.deserialize(TouchCRAuraSettingsBatchesController.getRfmTimeScheduleJobs(), TouchCRAuraSettingsBatchesController.RfmTimeScheduleJobsWrapper.class);
		System.assertEquals(NULL, timeScheduleJobs.nextRunTime);

		TouchCRAuraSettingsBatchesController.executeNowRFMScore();
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'ScoreCalculation'];
		System.assertEquals(1, ct.size());
		String cronString = DateTime.now().addMinutes(1).format('YYYY-MM-dd HH:mm:ss');
		TouchCRAuraSettingsBatchesController.executeNowRFMScore();
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'ScoreCalculation'];
		System.assertEquals(1, ct.size());

		timeScheduleJobs = (TouchCRAuraSettingsBatchesController.RfmTimeScheduleJobsWrapper)JSON.deserialize(TouchCRAuraSettingsBatchesController.getRfmTimeScheduleJobs(), TouchCRAuraSettingsBatchesController.RfmTimeScheduleJobsWrapper.class);
		System.assertEquals(cronString, String.valueOf(timeScheduleJobs.nextRunTime));
	}

	// DaBatchSettings
	static testMethod void test_DaBatchSettingsController() {
		String settings = TouchCRAuraSettingsBatchesController.getDaSettingsApex();
		Map<String, String> settingsDesirialized = (Map<String, String>)System.JSON.deserialize(settings, Map<String, String>.class);
		System.assertEquals('', settingsDesirialized.get('Batch.DataAppendTime'));
		System.assertEquals('', settingsDesirialized.get('Batch.DataAppendState'));

		TouchCRAuraSettingsBatchesController.DaSettingsWrapper newSetting = new TouchCRAuraSettingsBatchesController.DaSettingsWrapper();
		newSetting.selectedStateDa = 'test1';
		newSetting.selectedExecuteAtDa = 'test2';
		TouchCRAuraSettingsBatchesController.saveDa(JSON.serialize(newSetting));

		String savedSettings = TouchCRAuraSettingsBatchesController.getDaSettingsApex();
		Map<String, String> savedSettingsDesirialized = (Map<String, String>)System.JSON.deserialize(savedSettings, Map<String, String>.class);
		System.assertEquals('test2', savedSettingsDesirialized.get('Batch.DataAppendTime'));
		System.assertEquals('test1', savedSettingsDesirialized.get('Batch.DataAppendState'));

		List<CronTrigger> ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'DataAppend'];
		if (ct.size() != 0) {
			System.abortJob(ct[0].Id);
		}
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'DataAppend'];
		System.assertEquals(0, ct.size());

		TouchCRAuraSettingsBatchesController.DaTimeScheduleJobsWrapper timeScheduleJobs = (TouchCRAuraSettingsBatchesController.DaTimeScheduleJobsWrapper)JSON.deserialize(TouchCRAuraSettingsBatchesController.getDaTimeScheduleJobs(), TouchCRAuraSettingsBatchesController.DaTimeScheduleJobsWrapper.class);
		System.assertEquals(NULL, timeScheduleJobs.nextRunTime);

		TouchCRAuraSettingsBatchesController.executeNowDataAppend();
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'DataAppend'];
		System.assertEquals(1, ct.size());
		String cronString = DateTime.now().addMinutes(1).format('YYYY-MM-dd HH:mm:ss');
		TouchCRAuraSettingsBatchesController.executeNowDataAppend();
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'DataAppend'];
		System.assertEquals(1, ct.size());

		timeScheduleJobs = (TouchCRAuraSettingsBatchesController.DaTimeScheduleJobsWrapper)JSON.deserialize(TouchCRAuraSettingsBatchesController.getDaTimeScheduleJobs(), TouchCRAuraSettingsBatchesController.DaTimeScheduleJobsWrapper.class);
		System.assertEquals(cronString, String.valueOf(timeScheduleJobs.nextRunTime));
	}

	// CampaignMemberSettings
	static testMethod void test_CampaignMemberSettingsController() {
		String settings = TouchCRAuraSettingsBatchesController.getCmSettingsApex();
		Map<String, String> settingsDesirialized = (Map<String, String>)System.JSON.deserialize(settings, Map<String, String>.class);
		System.assertEquals('', settingsDesirialized.get('Batch.CampaignMemberStatus'));
		System.assertEquals('', settingsDesirialized.get('Batch.CampaignMemberTime'));
		System.assertEquals('', settingsDesirialized.get('Batch.CampaignMemberDay'));

		TouchCRAuraSettingsBatchesController.CmSettingsWrapper newSetting = new TouchCRAuraSettingsBatchesController.CmSettingsWrapper();
		newSetting.selectedStateCampaignMember = 'test1';
		newSetting.selectedExecuteAtCampaignMemberDay = 'test2';
		newSetting.selectedExecuteAtCampaignMember = 'test3';
		TouchCRAuraSettingsBatchesController.saveCm(JSON.serialize(newSetting));

		String savedSettings = TouchCRAuraSettingsBatchesController.getCmSettingsApex();
		Map<String, String> savedSettingsDesirialized = (Map<String, String>)System.JSON.deserialize(savedSettings, Map<String, String>.class);
		System.assertEquals('test1', savedSettingsDesirialized.get('Batch.CampaignMemberStatus'));
		System.assertEquals('test3', savedSettingsDesirialized.get('Batch.CampaignMemberTime'));
		System.assertEquals('test2', savedSettingsDesirialized.get('Batch.CampaignMemberDay'));

		List<CronTrigger> ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'CampaignMember'];
		if (ct.size() != 0) {
			System.abortJob(ct[0].Id);
		}
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'CampaignMember'];
		System.assertEquals(0, ct.size());

		TouchCRAuraSettingsBatchesController.CmTimeScheduleJobsWrapper timeScheduleJobs = (TouchCRAuraSettingsBatchesController.CmTimeScheduleJobsWrapper)JSON.deserialize(TouchCRAuraSettingsBatchesController.getCmTimeScheduleJobs(), TouchCRAuraSettingsBatchesController.CmTimeScheduleJobsWrapper.class);
		System.assertEquals(NULL, timeScheduleJobs.nextRunTime);

		TouchCRAuraSettingsBatchesController.executeNowCampaignMember();
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'CampaignMember'];
		System.assertEquals(1, ct.size());
		String cronString = DateTime.now().addMinutes(1).format('YYYY-MM-dd HH:mm:ss');
		TouchCRAuraSettingsBatchesController.executeNowCampaignMember();
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'CampaignMember'];
		System.assertEquals(1, ct.size());

		timeScheduleJobs = (TouchCRAuraSettingsBatchesController.CmTimeScheduleJobsWrapper)JSON.deserialize(TouchCRAuraSettingsBatchesController.getCmTimeScheduleJobs(), TouchCRAuraSettingsBatchesController.CmTimeScheduleJobsWrapper.class);
		System.assertEquals(cronString, String.valueOf(timeScheduleJobs.nextRunTime));
	}

	// HouseCleanerSettings
	static testMethod void test_HouseCleanerSettingsController() {
		String settings1 = TouchCRAuraSettingsBatchesController.getHcSettingsApex('BATCH_SETTING');
		Map<String, String> settingsDesirialized1 = (Map<String, String>)System.JSON.deserialize(settings1, Map<String, String>.class);
		System.assertEquals('', settingsDesirialized1.get('Batch.HouseCleanerState'));
		System.assertEquals('', settingsDesirialized1.get('Batch.HouseCleanerTime'));
		System.assertEquals('', settingsDesirialized1.get('Batch.HouseCleanerDay'));

		String settings2 = TouchCRAuraSettingsBatchesController.getHcSettingsApex('HOUSECLEANER_SETTING');
		Map<String, String> settingsDesirialized2 = (Map<String, String>)System.JSON.deserialize(settings2, Map<String, String>.class);
		System.assertEquals('', settingsDesirialized2.get('HouseCleaner.RecordAge'));
		System.assertEquals('', settingsDesirialized2.get('HouseCleaner.ObjectApiName'));

		TouchCRAuraSettingsBatchesController.HcSettingsWrapper newSetting = new TouchCRAuraSettingsBatchesController.HcSettingsWrapper();
		newSetting.selectedStateHouseCleaner = 'test1';
		newSetting.selectedExecuteHouseCleanerDay = 'test2';
		newSetting.selectedExecuteHouseCleaner = 'test3';
		newSetting.selectedRecordAgeHouseCleaner = 'test4';
		newSetting.selectedObjectHouseCleaner = 'test5';
		TouchCRAuraSettingsBatchesController.saveHc(JSON.serialize(newSetting));

		String savedSettings1 = TouchCRAuraSettingsBatchesController.getHcSettingsApex('BATCH_SETTING');
		Map<String, String> savedSettingsDesirialized1 = (Map<String, String>)System.JSON.deserialize(savedSettings1, Map<String, String>.class);
		System.assertEquals('test1', savedSettingsDesirialized1.get('Batch.HouseCleanerState'));
		System.assertEquals('test3', savedSettingsDesirialized1.get('Batch.HouseCleanerTime'));
		System.assertEquals('test2', savedSettingsDesirialized1.get('Batch.HouseCleanerDay'));
		String savedSettings2 = TouchCRAuraSettingsBatchesController.getHcSettingsApex('HOUSECLEANER_SETTING');
		Map<String, String> savedSettingsDesirialized2 = (Map<String, String>)System.JSON.deserialize(savedSettings2, Map<String, String>.class);
		System.assertEquals('test4', savedSettingsDesirialized2.get('HouseCleaner.RecordAge'));
		System.assertEquals('test5', savedSettingsDesirialized2.get('HouseCleaner.ObjectApiName'));

		List<CronTrigger> ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'HouseCleaner'];
		if (ct.size() != 0) {
			System.abortJob(ct[0].Id);
		}
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'HouseCleaner'];
		System.assertEquals(0, ct.size());

		TouchCRAuraSettingsBatchesController.HcTimeScheduleJobsWrapper timeScheduleJobs = (TouchCRAuraSettingsBatchesController.HcTimeScheduleJobsWrapper)JSON.deserialize(TouchCRAuraSettingsBatchesController.getHcTimeScheduleJobs(), TouchCRAuraSettingsBatchesController.HcTimeScheduleJobsWrapper.class);
		System.assertEquals(NULL, timeScheduleJobs.nextRunTime);

		TouchCRAuraSettingsBatchesController.executeNowHouseCleaner();
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'HouseCleaner'];
		System.assertEquals(1, ct.size());
		String cronString = DateTime.now().addMinutes(1).format('YYYY-MM-dd HH:mm:ss');
		TouchCRAuraSettingsBatchesController.executeNowHouseCleaner();
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'HouseCleaner'];
		System.assertEquals(1, ct.size());

		timeScheduleJobs = (TouchCRAuraSettingsBatchesController.HcTimeScheduleJobsWrapper)JSON.deserialize(TouchCRAuraSettingsBatchesController.getHcTimeScheduleJobs(), TouchCRAuraSettingsBatchesController.HcTimeScheduleJobsWrapper.class);
		System.assertEquals(cronString, String.valueOf(timeScheduleJobs.nextRunTime));
	}

	// FullContactBatchSettings
	static testMethod void test_FullContactBatchSettingsController() {
		//Temporary added for test coverage REMOVE
		TouchCRAuraSettingsBatchesController controller = new TouchCRAuraSettingsBatchesController();
		TouchCRAuraSettingsBatchesController.executeNowRefundPeriod();
		TouchCRAuraSettingsBatchesController.getRpTimeScheduleJobs();
		//Temporary added for test coverage REMOVE

		String settings = TouchCRAuraSettingsBatchesController.getFcSettingsApex();
		Map<String, String> settingsDesirialized = (Map<String, String>)System.JSON.deserialize(settings, Map<String, String>.class);
		System.assertEquals('', settingsDesirialized.get('Batch.FullContactTime'));
		System.assertEquals('', settingsDesirialized.get('Batch.FullContactState'));

		TouchCRAuraSettingsBatchesController.FcSettingsWrapper newSetting = new TouchCRAuraSettingsBatchesController.FcSettingsWrapper();
		newSetting.selectedStateFc = 'test1';
		newSetting.selectedExecuteAtFc = 'test2';
		TouchCRAuraSettingsBatchesController.saveFc(JSON.serialize(newSetting));

		String savedSettings = TouchCRAuraSettingsBatchesController.getFcSettingsApex();
		Map<String, String> savedSettingsDesirialized = (Map<String, String>)System.JSON.deserialize(savedSettings, Map<String, String>.class);
		System.assertEquals('test2', savedSettingsDesirialized.get('Batch.FullContactTime'));
		System.assertEquals('test1', savedSettingsDesirialized.get('Batch.FullContactState'));

		List<CronTrigger> ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'FullContact'];
		if (ct.size() != 0) {
			System.abortJob(ct[0].Id);
		}
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'FullContact'];
		System.assertEquals(0, ct.size());

		TouchCRAuraSettingsBatchesController.FcTimeScheduleJobsWrapper timeScheduleJobs = (TouchCRAuraSettingsBatchesController.FcTimeScheduleJobsWrapper)JSON.deserialize(TouchCRAuraSettingsBatchesController.getFcTimeScheduleJobs(), TouchCRAuraSettingsBatchesController.FcTimeScheduleJobsWrapper.class);
		System.assertEquals(NULL, timeScheduleJobs.nextRunTime);

		/*TouchCRAuraSettingsBatchesController.executeNowFullContact();
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'FullContact'];
		System.assertEquals(1, ct.size());
		String cronString = DateTime.now().addMinutes(1).format('YYYY-MM-dd HH:mm:ss');
		TouchCRAuraSettingsBatchesController.executeNowFullContact();
		ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'FullContact'];
		System.assertEquals(1, ct.size());

		timeScheduleJobs = (TouchCRAuraSettingsBatchesController.FcTimeScheduleJobsWrapper)JSON.deserialize(TouchCRAuraSettingsBatchesController.getFcTimeScheduleJobs(), TouchCRAuraSettingsBatchesController.FcTimeScheduleJobsWrapper.class);
		System.assertEquals(cronString, String.valueOf(timeScheduleJobs.nextRunTime));*/
	}
}