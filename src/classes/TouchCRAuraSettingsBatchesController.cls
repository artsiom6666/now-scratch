public class TouchCRAuraSettingsBatchesController {

// RfmScoreBrandBatch

	// THE BATCHES NAMES TO CHECK THEIR WORK
	public static final Map<String, Set<String>> RFM_BRAND_NAME_TO_CLASSES = new Map<String, Set<String>> {
		'ScoreBrandCounter' => new Set<String>{'ScoreBrandCounterBatch', 'ScoreBrandCalculationBatch'}
	};

	// BATCH SCORE BRAND COUNTER settings
	public static final Map<String, String> RFM_BRAND_BATCH_SETTING = new Map<String, String> {
		'Batch.RFMScoreBrandStatus' => '',
		'Batch.RFMScoreBrandTime' => '',
		'Batch.RFMScoreBrandDay' => ''
	};

	public static Map<String, String> getRfmBrandSettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}

	@auraEnabled
	public static String getRfmBrandSettingsApex() {

		return JSON.serialize(getRfmBrandSettings(RFM_BRAND_BATCH_SETTING.keySet()));
	}

	@auraEnabled
	public static String executeNowRFMScoreBrand() {
		String cronString = '' + DateTime.now().second() + ' ' +
				DateTime.now().addMinutes(1).minute() + ' ' + DateTime.now().hour() + ' ' +
				DateTime.now().day() + ' ' + DateTime.now().month() + ' ? ' +
				DateTime.now().year();
		if (searcRfmBrandActiveBatches(RFM_BRAND_NAME_TO_CLASSES.get('ScoreBrandCounter')) == false) {
			stopRfmBrandMonitor('ScoreBrandCounter');
			Map<String, String> batchToSchedule = new Map<String, String>();
			batchToSchedule.put('Name', 'ScoreBrandCounter');
			batchToSchedule.put('CronString', cronString);
			batchToSchedule.put('BatchName', 'ScoreBrandCounterScheduler');
			TouchCRHelper.scheduleBatch(batchToSchedule);
			return 'Success! RFM Score Brand Batch will be initiated in 1 minute!';
		}
		else {
			return 'RFM Score Brand Batch cannot be started, please try again later!';
		}
	}


	@auraEnabled
	public static String saveRfmBrand(String settings) {

		RfmBrandSettingsWrapper settingsDeserialized = (RfmBrandSettingsWrapper)JSON.deserialize(settings, RfmBrandSettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();

		Map<String, String> batchSettings = getRfmBrandSettings(RFM_BRAND_BATCH_SETTING.keySet());

		Boolean isRFMScoreBrandChanged = (
			settingsDeserialized.selectedStateRFMScoreBrand != batchSettings.get('Batch.RFMScoreBrandStatus') ||
			settingsDeserialized.selectedExecuteAtRFMScoreBrandDay != batchSettings.get('Batch.RFMScoreBrandDay') ||
			settingsDeserialized.selectedExecuteAtRFMScoreBrand != batchSettings.get('Batch.RFMScoreBrandTime')
		);

		String settingRFMScoreBrandStatus = batchSettings.get('Batch.RFMScoreBrandStatus');
		settingRFMScoreBrandStatus = settingsDeserialized.selectedStateRFMScoreBrand;
		settingsToUpsert.put('Batch.RFMScoreBrandStatus', settingRFMScoreBrandStatus);

		String settingRFMScoreBrandDay = batchSettings.get('Batch.RFMScoreBrandDay');
		settingRFMScoreBrandDay = settingsDeserialized.selectedExecuteAtRFMScoreBrandDay;
		settingsToUpsert.put('Batch.RFMScoreBrandDay', settingRFMScoreBrandDay);

		String settingRFMScoreBrandTime = batchSettings.get('Batch.RFMScoreBrandTime');
		settingRFMScoreBrandTime = settingsDeserialized.selectedExecuteAtRFMScoreBrand;
		settingsToUpsert.put('Batch.RFMScoreBrandTime', settingRFMScoreBrandTime);

		if (settingsDeserialized.selectedStateRFMScoreBrand == 'Off') {
			stopRfmBrandMonitor('ScoreBrandCounter');
		}
		else if (settingsDeserialized.selectedStateRFMScoreBrand == 'On' && isRFMScoreBrandChanged) {
			stopRfmBrandMonitor('ScoreBrandCounter');
			startRfmBrandMonitor('ScoreBrandCounter', settingsDeserialized);
		}

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'RFM Score Brand Batch has been successfully scheduled!';
		} else {
			return 'Error! ';
		}
	}

	@auraEnabled
	public static String getRfmBrandTimeScheduleJobs() {
		Map<String, DateTime> scheduleJobsMap = new Map<String, DateTime>();
		Set<String> nameScheduleJobs = new Set<String>{'ScoreBrandCounter'};

		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'CronJobDetail',
					'RfmScoreBrandBatchController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronJobDetail.Name.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'CronTrigger',
					'RfmScoreBrandBatchController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronTrigger.NextFireTime.getDescribe()
							}
			);

			List<CronTrigger> scheduleInProgress = [
					SELECT Id, NextFireTime, CronJobDetail.Name
					FROM CronTrigger
					WHERE CronJobDetail.Name IN :nameScheduleJobs
			LIMIT 10
			];
			for (CronTrigger item : scheduleInProgress) {
				scheduleJobsMap.put(item.CronJobDetail.Name, item.NextFireTime);
			}
			RfmBrandTimeScheduleJobsWrapper timeScheduleJobs = new RfmBrandTimeScheduleJobsWrapper();
			timeScheduleJobs.nextRunTime = (scheduleJobsMap.containsKey('ScoreBrandCounter')) ? scheduleJobsMap.get('ScoreBrandCounter') : NULL;
			return JSON.serialize(timeScheduleJobs);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

	}

	// if there is active batches then true
	private static Boolean searcRfmBrandActiveBatches(Set<String> namesBatches) {
		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'AsyncApexJob',
					'RfmScoreBrandBatchController.cls [init]',
					new List<Schema.DescribeFieldResult> {
							AsyncApexJob.ApexClassId.getDescribe(), AsyncApexJob.Status.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'ApexClass',
					'RfmScoreBrandBatchController.cls [init]',
					new List<Schema.DescribeFieldResult> {
							ApexClass.Name.getDescribe()
							}
			);
			List<AsyncApexJob> jobs = [
					SELECT Id, Status, ApexClassId, ApexClass.Name
					FROM AsyncApexJob
					WHERE ApexClass.Name IN : namesBatches
			AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
			];
			if (jobs.isEmpty()) {
				return false;
			}
			else {
				return true;
			}
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	private static Id getRfmBrandScheduleJobs(String nameCronTrigger) {
		Id result = null;
		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'CronJobDetail',
					'RfmScoreBrandBatchController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronJobDetail.Name.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'CronTrigger',
					'RfmScoreBrandBatchController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronTrigger.NextFireTime.getDescribe()
							}
			);
			List<CronTrigger> scheduleInProgress = [
					SELECT Id, NextFireTime
					FROM CronTrigger
					WHERE CronJobDetail.Name =: nameCronTrigger
			];
			result = (scheduleInProgress.isEmpty()) ? NULL : scheduleInProgress.get(0).Id;
			return result;
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	private static void stopRfmBrandMonitor(String nameCronTrigger) {
		Id schJobId = getRfmBrandScheduleJobs(nameCronTrigger);
		if (schJobId != null) {
			System.abortJob(schJobId);
		}
	}

	private static void startRfmBrandMonitor(String nameCronTrigger, RfmBrandSettingsWrapper settingsDeserialized) {
		Id schJobId = getRfmBrandScheduleJobs(nameCronTrigger);
		if (schJobId == null) {
			String cronStr = '0 0 ' + settingsDeserialized.selectedExecuteAtRFMScoreBrand + ' 1/1 * ? *';
			Map<String, String> batchToSchedule = new Map<String, String>();
			batchToSchedule.put('Name', nameCronTrigger);
			batchToSchedule.put('CronString', cronStr);
			batchToSchedule.put('BatchName', 'ScoreBrandCounterScheduler');
			TouchCRHelper.scheduleBatch(batchToSchedule);
		}
	}

	public class RfmBrandSettingsWrapper {
		public String selectedStateRFMScoreBrand { get; set; }
		public String selectedExecuteAtRFMScoreBrandDay { get; set; }
		public String selectedExecuteAtRFMScoreBrand { get; set; }
	}

	public class RfmBrandTimeScheduleJobsWrapper {
		public Datetime nextRunTime { get; set; }
	}

// RfmScoreBatchSettings

	// THE BATCHES NAMES TO CHECK THEIR WORK
	public static final Map<String, Set<String>> RFM_NAME_TO_CLASSES = new Map<String, Set<String>> {
		'ScoreCalculation' => new Set<String>{ 'ScoreCalculationBatch', 'ScoreCalculationCounterBatch' }
	};

	// BATCH SCORE  COUNTER settings
	public static final Map<String, String> RFM_BATCH_SETTING = new Map<String, String> {
		'Batch.RFMScoreStatus' => '',
		'Batch.RFMScoreTime' => '',
		'Batch.RFMScoreDay' => ''
	};

	public static Map<String, String> getRfmSettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}

	@auraEnabled
	public static String getRfmSettingsApex() {

		return JSON.serialize(getRfmSettings(RFM_BATCH_SETTING.keySet()));
	}

	@auraEnabled
	public static String executeNowRFMScore() {
		String cronString = '' + DateTime.now().second() + ' ' +
				DateTime.now().addMinutes(1).minute() + ' ' + DateTime.now().hour() + ' ' +
				DateTime.now().day() + ' ' + DateTime.now().month() + ' ? ' +
				DateTime.now().year();
		if (searchRfmActiveBatches(RFM_NAME_TO_CLASSES.get('ScoreCalculation')) == false) {
			stopRfmMonitor('ScoreCalculation');
			Map<String, String> batchToSchedule = new Map<String, String>();
			batchToSchedule.put('Name', 'ScoreCalculation');
			batchToSchedule.put('CronString', cronString);
			batchToSchedule.put('BatchName', 'ScoreCalculationScheduler');
			TouchCRHelper.scheduleBatch(batchToSchedule);
			return 'Success! RFM Score Batch will be initiated in 1 minute!';
		}
		else {
			return 'RFM Score Batch cannot be started, please try again later!';
		}
	}


	@auraEnabled
	public static String saveRfm(String settings) {

		RfmSettingsWrapper settingsDeserialized = (RfmSettingsWrapper)JSON.deserialize(settings, RfmSettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();

		Map<String, String> batchSettings = getRfmSettings(RFM_BATCH_SETTING.keySet());

		Boolean isRFMScoreChanged = (
			settingsDeserialized.selectedStateRFMScore != batchSettings.get('Batch.RFMScoreStatus') ||
			settingsDeserialized.selectedExecuteAtRFMScoreDay != batchSettings.get('Batch.RFMScoreDay') ||
			settingsDeserialized.selectedExecuteAtRFMScore != batchSettings.get('Batch.RFMScoreTime')
		);

		String settingRFMScoreStatus = batchSettings.get('Batch.RFMScoreStatus');
		settingRFMScoreStatus = settingsDeserialized.selectedStateRFMScore;
		settingsToUpsert.put('Batch.RFMScoreStatus', settingRFMScoreStatus);

		String settingRFMScoreDay = batchSettings.get('Batch.RFMScoreDay');
		settingRFMScoreDay = settingsDeserialized.selectedExecuteAtRFMScoreDay;
		settingsToUpsert.put('Batch.RFMScoreDay', settingRFMScoreDay);

		String settingRFMScoreTime = batchSettings.get('Batch.RFMScoreTime');
		settingRFMScoreTime = settingsDeserialized.selectedExecuteAtRFMScore;
		settingsToUpsert.put('Batch.RFMScoreTime', settingRFMScoreTime);

		if (settingsDeserialized.selectedStateRFMScore == 'Off') {
			stopRfmMonitor('ScoreCalculation');
		}
		else if (settingsDeserialized.selectedStateRFMScore == 'On' && isRFMScoreChanged) {
			stopRfmMonitor('ScoreCalculation');
			startRfmMonitor('ScoreCalculation', settingsDeserialized);
		}

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'RFM Score  Batch has been successfully scheduled!';

		} else {
			return 'Error! ';
		}
	}

	@auraEnabled
	public static String getRfmTimeScheduleJobs() {
		Map<String, DateTime> scheduleJobsMap = new Map<String, DateTime>();
		Set<String> nameScheduleJobs = new Set<String>{'ScoreCalculation'};

		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'CronJobDetail',
					'RfmScoreBatchController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronJobDetail.Name.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'CronTrigger',
					'RfmScoreBatchController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronTrigger.NextFireTime.getDescribe()
							}
			);

			List<CronTrigger> scheduleInProgress = [
					SELECT Id, NextFireTime, CronJobDetail.Name
					FROM CronTrigger
					WHERE CronJobDetail.Name IN :nameScheduleJobs
			LIMIT 10
			];
			for (CronTrigger item : scheduleInProgress) {
				scheduleJobsMap.put(item.CronJobDetail.Name, item.NextFireTime);
			}
			RfmTimeScheduleJobsWrapper timeScheduleJobs = new RfmTimeScheduleJobsWrapper();
			timeScheduleJobs.nextRunTime = (scheduleJobsMap.containsKey('ScoreCalculation')) ? scheduleJobsMap.get('ScoreCalculation') : NULL;
			return JSON.serialize(timeScheduleJobs);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

	}

	// if there is active batches then true
	private static Boolean searchRfmActiveBatches(Set<String> namesBatches) {
		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'AsyncApexJob',
					'RfmScoreBatchController.cls [init]',
					new List<Schema.DescribeFieldResult> {
							AsyncApexJob.ApexClassId.getDescribe(), AsyncApexJob.Status.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'ApexClass',
					'RfmScoreBatchController.cls [init]',
					new List<Schema.DescribeFieldResult> {
							ApexClass.Name.getDescribe()
							}
			);
			List<AsyncApexJob> jobs = [
					SELECT Id, Status, ApexClassId, ApexClass.Name
					FROM AsyncApexJob
					WHERE ApexClass.Name IN : namesBatches
			AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
			];
			if (jobs.isEmpty()) {
				return false;
			}
			else {
				return true;
			}
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	private static Id getRfmScheduleJobs(String nameCronTrigger) {
		Id result = null;
		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'CronJobDetail',
					'RfmScoreBatchController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronJobDetail.Name.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'CronTrigger',
					'RfmScoreBatchController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronTrigger.NextFireTime.getDescribe()
							}
			);
			List<CronTrigger> scheduleInProgress = [
					SELECT Id, NextFireTime
					FROM CronTrigger
					WHERE CronJobDetail.Name =: nameCronTrigger
			];
			result = (scheduleInProgress.isEmpty()) ? NULL : scheduleInProgress.get(0).Id;
			return result;
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	private static void stopRfmMonitor(String nameCronTrigger) {
		Id schJobId = getRfmScheduleJobs(nameCronTrigger);
		if (schJobId != null) {
			System.abortJob(schJobId);
		}
	}

	private static void startRfmMonitor(String nameCronTrigger, RfmSettingsWrapper settingsDeserialized) {
		Id schJobId = getRfmScheduleJobs(nameCronTrigger);
		if (schJobId == null) {
			String cronStr = '0 0 ' + settingsDeserialized.selectedExecuteAtRFMScore + ' 1/1 * ? *';
			Map<String, String> batchToSchedule = new Map<String, String>();
			batchToSchedule.put('Name', nameCronTrigger);
			batchToSchedule.put('CronString', cronStr);
			batchToSchedule.put('BatchName', 'ScoreCalculationScheduler');
			TouchCRHelper.scheduleBatch(batchToSchedule);
		}
	}

	public class RfmSettingsWrapper {
		public String selectedStateRFMScore { get; set; }
		public String selectedExecuteAtRFMScoreDay { get; set; }
		public String selectedExecuteAtRFMScore { get; set; }
	}

	public class RfmTimeScheduleJobsWrapper {
		public Datetime nextRunTime { get; set; }
	}

// DaBatchSettings

	// THE BATCHES NAMES TO CHECK THEIR WORK
	public static final Map<String, Set<String>> DA_NAME_TO_CLASSES = new Map<String, Set<String>> {
		'DataAppend' => new Set<String>{ 'DataAppendBatch' }
	};

	// BATCH SCORE  COUNTER settings
	public static final Map<String, String> DA_BATCH_SETTING = new Map<String, String> {
		'Batch.DataAppendTime' => '',
		'Batch.DataAppendState' => ''
	};

	public static Map<String, String> getDaSettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}

	@auraEnabled
	public static String getDaSettingsApex() {

		return JSON.serialize(getDaSettings(DA_BATCH_SETTING.keySet()));
	}

	@auraEnabled
	public static String executeNowDataAppend() {
		String cronString = '' + DateTime.now().second() + ' ' +
				DateTime.now().addMinutes(1).minute() + ' ' + DateTime.now().hour() + ' ' +
				DateTime.now().day() + ' ' + DateTime.now().month() + ' ? ' +
				DateTime.now().year();
		if (searchDaActiveBatches(DA_NAME_TO_CLASSES.get('DataAppend')) == false) {
			stopDaMonitor('DataAppend');
			Map<String, String> batchToSchedule = new Map<String, String>();
			batchToSchedule.put('Name', 'DataAppend');
			batchToSchedule.put('CronString', cronString);
			batchToSchedule.put('BatchName', 'DataAppendScheduler');
			TouchCRHelper.scheduleBatch(batchToSchedule);
			return 'Success! Data Append Batch will be initiated in 1 minute!';
		}
		else {
			return 'Data Append Batch cannot be started, please try again later!';
		}
	}


	@auraEnabled
	public static String saveDa(String settings) {

		DaSettingsWrapper settingsDeserialized = (DaSettingsWrapper)JSON.deserialize(settings, DaSettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();

		Map<String, String> batchSettings = getDaSettings(DA_BATCH_SETTING.keySet());

		Boolean isDaChanged = (
			settingsDeserialized.selectedStateDa != batchSettings.get('Batch.DataAppendState') ||
			settingsDeserialized.selectedExecuteAtDa != batchSettings.get('Batch.DataAppendTime')
		);

		String settingDaStatus = batchSettings.get('Batch.DataAppendState');
		settingDaStatus = settingsDeserialized.selectedStateDa;
		settingsToUpsert.put('Batch.DataAppendState', settingDaStatus);

		String settingDaTime = batchSettings.get('Batch.DataAppendTime');
		settingDaTime = settingsDeserialized.selectedExecuteAtDa;
		settingsToUpsert.put('Batch.DataAppendTime', settingDaTime);

		if (settingsDeserialized.selectedStateDa == 'Off') {
			stopDaMonitor('DataAppend');
		}
		else if (settingsDeserialized.selectedStateDa == 'On' && isDaChanged) {
			stopDaMonitor('DataAppend');
			startDaMonitor('DataAppend', settingsDeserialized);
		}

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'Data Append has been successfully scheduled!';
		} else {
			return 'Error! ';
		}
	}

	@auraEnabled
	public static String getDaTimeScheduleJobs() {
		Map<String, DateTime> scheduleJobsMap = new Map<String, DateTime>();
		Set<String> nameScheduleJobs = new Set<String>{'DataAppend'};

		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'CronJobDetail',
					'DaBatchController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronJobDetail.Name.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'CronTrigger',
					'DaBatchController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronTrigger.NextFireTime.getDescribe()
							}
			);

			List<CronTrigger> scheduleInProgress = [
					SELECT Id, NextFireTime, CronJobDetail.Name
					FROM CronTrigger
					WHERE CronJobDetail.Name IN :nameScheduleJobs
			LIMIT 10
			];
			for (CronTrigger item : scheduleInProgress) {
				scheduleJobsMap.put(item.CronJobDetail.Name, item.NextFireTime);
			}
			DaTimeScheduleJobsWrapper timeScheduleJobs = new DaTimeScheduleJobsWrapper();
			timeScheduleJobs.nextRunTime = (scheduleJobsMap.containsKey('DataAppend')) ? scheduleJobsMap.get('DataAppend') : NULL;
			return JSON.serialize(timeScheduleJobs);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

	}

	// if there is active batches then true
	private static Boolean searchDaActiveBatches(Set<String> namesBatches) {
		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'AsyncApexJob',
					'DaBatchController.cls [init]',
					new List<Schema.DescribeFieldResult> {
							AsyncApexJob.ApexClassId.getDescribe(), AsyncApexJob.Status.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'ApexClass',
					'DaBatchController.cls [init]',
					new List<Schema.DescribeFieldResult> {
							ApexClass.Name.getDescribe()
							}
			);
			List<AsyncApexJob> jobs = [
					SELECT Id, Status, ApexClassId, ApexClass.Name
					FROM AsyncApexJob
					WHERE ApexClass.Name IN : namesBatches
			AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
			];
			if (jobs.isEmpty()) {
				return false;
			}
			else {
				return true;
			}
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	private static Id getDaScheduleJobs(String nameCronTrigger) {
		Id result = null;
		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'CronJobDetail',
					'DaBatchController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronJobDetail.Name.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'CronTrigger',
					'DaBatchController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronTrigger.NextFireTime.getDescribe()
							}
			);
			List<CronTrigger> scheduleInProgress = [
					SELECT Id, NextFireTime
					FROM CronTrigger
					WHERE CronJobDetail.Name =: nameCronTrigger
			];
			result = (scheduleInProgress.isEmpty()) ? NULL : scheduleInProgress.get(0).Id;
			return result;
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	private static void stopDaMonitor(String nameCronTrigger) {
		Id schJobId = getDaScheduleJobs(nameCronTrigger);
		if (schJobId != null) {
			System.abortJob(schJobId);
		}
	}

	private static void startDaMonitor(String nameCronTrigger, DaSettingsWrapper settingsDeserialized) {
		Id schJobId = getDaScheduleJobs(nameCronTrigger);
		if (schJobId == null) {
			String cronStr = '0 0 ' + settingsDeserialized.selectedExecuteAtDa + ' 1/1 * ? *';
			Map<String, String> batchToSchedule = new Map<String, String>();
			batchToSchedule.put('Name', nameCronTrigger);
			batchToSchedule.put('CronString', cronStr);
			batchToSchedule.put('BatchName', 'DataAppendScheduler');
			TouchCRHelper.scheduleBatch(batchToSchedule);
		}
	}

	public class DaSettingsWrapper {
		public String selectedStateDa { get; set; }
		public String selectedExecuteAtDa { get; set; }
	}

	public class DaTimeScheduleJobsWrapper {
		public Datetime nextRunTime { get; set; }
	}

// FullContactSettings

	// THE BATCHES NAMES TO CHECK THEIR WORK
	public static final Map<String, Set<String>> FC_NAME_TO_CLASSES = new Map<String, Set<String>> {
		'FullContact' => new Set<String>{ 'FullContactBatch' }
	};

	// BATCH SCORE  COUNTER settings
	public static final Map<String, String> FC_BATCH_SETTING = new Map<String, String> {
		'Batch.FullContactTime' => '',
		'Batch.FullContactState' => ''
	};

	public static Map<String, String> getFcSettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}

	@auraEnabled
	public static String getFcSettingsApex() {

		return JSON.serialize(getFcSettings(FC_BATCH_SETTING.keySet()));
	}

	@auraEnabled
	public static String executeNowFullContact() {
		/*	String cronString = '' + DateTime.now().second() + ' ' +
				DateTime.now().addMinutes(1).minute() + ' ' + DateTime.now().hour() + ' ' +
				DateTime.now().day() + ' ' + DateTime.now().month() + ' ? ' +
				DateTime.now().year();
		if (searchFcActiveBatches(FC_NAME_TO_CLASSES.get('FullContact')) == false) {
			stopFcMonitor('FullContact');
			Map<String, String> batchToSchedule = new Map<String, String>();
			batchToSchedule.put('Name', 'FullContact');
			batchToSchedule.put('CronString', cronString);
			batchToSchedule.put('BatchName', 'FullContactScheduler');
			TouchCRHelper.scheduleBatch(batchToSchedule);
			return 'Success! FullContact Batch will be initiated in 1 minute!';
		}
		else {
			return 'FullContact Batch cannot be started, please try again later!';
		}*/
		return 'FullContact Batch cannot be started, please try again later!';
	}


	@auraEnabled
	public static String saveFc(String settings) {

		FcSettingsWrapper settingsDeserialized = (FcSettingsWrapper)JSON.deserialize(settings, FcSettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();

		Map<String, String> batchSettings = getDaSettings(FC_BATCH_SETTING.keySet());

		Boolean isFcChanged = (
			settingsDeserialized.selectedStateFc != batchSettings.get('Batch.FullContactState') ||
			settingsDeserialized.selectedExecuteAtFc != batchSettings.get('Batch.FullContactTime')
		);

		String settingFcStatus = batchSettings.get('Batch.FullContactState');
		settingFcStatus = settingsDeserialized.selectedStateFc;
		settingsToUpsert.put('Batch.FullContactState', settingFcStatus);

		String settingFcTime = batchSettings.get('Batch.FullContactTime');
		settingFcTime = settingsDeserialized.selectedExecuteAtFc;
		settingsToUpsert.put('Batch.FullContactTime', settingFcTime);

		if (settingsDeserialized.selectedStateFc == 'Off') {
			//		stopDaMonitor('FullContact');
		}
		else if (settingsDeserialized.selectedStateFc == 'On' && isFcChanged) {
			//		stopFcMonitor('FullContact');
			//		startFcMonitor('FullContact', settingsDeserialized);
		}

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'FullContact has been successfully scheduled!';
		} else {
			return 'Error! ';
		}
	}

	@auraEnabled
	public static String getFcTimeScheduleJobs() {
		Map<String, DateTime> scheduleJobsMap = new Map<String, DateTime>();
		Set<String> nameScheduleJobs = new Set<String>{'FullContact'};

		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'CronJobDetail',
					'FullContactBatchController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronJobDetail.Name.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'CronTrigger',
					'FullContactBatchController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronTrigger.NextFireTime.getDescribe()
							}
			);

			List<CronTrigger> scheduleInProgress = [
					SELECT Id, NextFireTime, CronJobDetail.Name
					FROM CronTrigger
					WHERE CronJobDetail.Name IN :nameScheduleJobs
			LIMIT 10
			];
			for (CronTrigger item : scheduleInProgress) {
				scheduleJobsMap.put(item.CronJobDetail.Name, item.NextFireTime);
			}
			FcTimeScheduleJobsWrapper timeScheduleJobs = new FcTimeScheduleJobsWrapper();
			timeScheduleJobs.nextRunTime = (scheduleJobsMap.containsKey('FullContact')) ? scheduleJobsMap.get('FullContact') : NULL;
			return JSON.serialize(timeScheduleJobs);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

	}

	// if there is active batches then true
	private static Boolean searchFcActiveBatches(Set<String> namesBatches) {
		try {
		/*			SFDCAccessController.AccessibleWithoutSharing (
					'AsyncApexJob',
					'FullContactBatchController.cls [init]',
					new List<Schema.DescribeFieldResult> {
							AsyncApexJob.ApexClassId.getDescribe(), AsyncApexJob.Status.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'ApexClass',
					'FullContactBatchController.cls [init]',
					new List<Schema.DescribeFieldResult> {
							ApexClass.Name.getDescribe()
							}
			);
			List<AsyncApexJob> jobs = [
					SELECT Id, Status, ApexClassId, ApexClass.Name
					FROM AsyncApexJob
					WHERE ApexClass.Name IN : namesBatches
			AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
			];
			if (jobs.isEmpty()) {
				return false;
			}
			else {
				return true;
			}*/
			return true;
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	private static Id getFcScheduleJobs(String nameCronTrigger) {
		Id result = null;
		try {
		/*			SFDCAccessController.AccessibleWithoutSharing (
					'CronJobDetail',
					'FullContactBatchController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronJobDetail.Name.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'CronTrigger',
					'FullContactBatchController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronTrigger.NextFireTime.getDescribe()
							}
			);
			List<CronTrigger> scheduleInProgress = [
					SELECT Id, NextFireTime
					FROM CronTrigger
					WHERE CronJobDetail.Name =: nameCronTrigger
			];
			result = (scheduleInProgress.isEmpty()) ? NULL : scheduleInProgress.get(0).Id;*/
			return result;
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	private static void stopFcMonitor(String nameCronTrigger) {
		/*	Id schJobId = getFcScheduleJobs(nameCronTrigger);
		if (schJobId != null) {
			System.abortJob(schJobId);
		}*/
	}

	private static void startFcMonitor(String nameCronTrigger, FcSettingsWrapper settingsDeserialized) {
		Id schJobId = getFcScheduleJobs(nameCronTrigger);
		/*		if (schJobId == null) {
			String cronStr = '0 0 0/' + settingsDeserialized.selectedExecuteAtFc + ' 1/1 * ? *';
			Map<String, String> batchToSchedule = new Map<String, String>();
			batchToSchedule.put('Name', nameCronTrigger);
			batchToSchedule.put('CronString', cronStr);
			batchToSchedule.put('BatchName', 'FullContactScheduler');
			TouchCRHelper.scheduleBatch(batchToSchedule);
		}*/
	}

	public class FcSettingsWrapper {
		public String selectedStateFc { get; set; }
		public String selectedExecuteAtFc { get; set; }
	}

	public class FcTimeScheduleJobsWrapper {
		public Datetime nextRunTime { get; set; }
	}

// CampaignMemberSettings

	// THE BATCHES NAMES TO CHECK THEIR WORK
	public static final Map<String, Set<String>> CM_NAME_TO_CLASSES = new Map<String, Set<String>> {
		'CampaignMember' => new Set<String>{ 'CampaignMemberBatch', 'CampaignMemberSummaryBatch', 'CampaignHierarchyBatch', 'CampaignHierarchySummaryBatch' }
	};

	// BATCH SCORE BRAND COUNTER settings
	public static final Map<String, String> CM_BATCH_SETTING = new Map<String, String> {
		'Batch.CampaignMemberStatus' => '',
		'Batch.CampaignMemberTime' => '',
		'Batch.CampaignMemberDay' => ''
	};

	public static Map<String, String> getCmSettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}

	@auraEnabled
	public static String getCmSettingsApex() {

		return JSON.serialize(getCmSettings(CM_BATCH_SETTING.keySet()));
	}

	@auraEnabled
	public static String executeNowCampaignMember() {
		String cronString = '' + DateTime.now().second() + ' ' +
				DateTime.now().addMinutes(1).minute() + ' ' + DateTime.now().hour() + ' ' +
				DateTime.now().day() + ' ' + DateTime.now().month() + ' ? ' +
				DateTime.now().year();
		if (searchCmActiveBatches(CM_NAME_TO_CLASSES.get('CampaignMember')) == false) {
			stopCmMonitor('CampaignMember');
			Map<String, String> batchToSchedule = new Map<String, String>();
			batchToSchedule.put('Name', 'CampaignMember');
			batchToSchedule.put('CronString', cronString);
			batchToSchedule.put('BatchName', 'CampaignMemberScheduler');
			TouchCRHelper.scheduleBatch(batchToSchedule);
			return 'Success! Campaign Member Batch will be initiated in 1 minute!';
		}
		else {
			return 'Campaign Member Batch cannot be started, please try again later!';
		}
	}


	@auraEnabled
	public static String saveCm(String settings) {

		CmSettingsWrapper settingsDeserialized = (CmSettingsWrapper)JSON.deserialize(settings, CmSettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();

		Map<String, String> batchSettings = getCmSettings(CM_BATCH_SETTING.keySet());

		Boolean isRFMScoreBrandChanged = (
			settingsDeserialized.selectedStateCampaignMember != batchSettings.get('Batch.CampaignMemberStatus') ||
			settingsDeserialized.selectedExecuteAtCampaignMemberDay != batchSettings.get('Batch.CampaignMemberDay') ||
			settingsDeserialized.selectedExecuteAtCampaignMember != batchSettings.get('Batch.CampaignMemberTime')
		);

		String settingRFMScoreBrandStatus = batchSettings.get('Batch.CampaignMemberStatus');
		settingRFMScoreBrandStatus = settingsDeserialized.selectedStateCampaignMember;
		settingsToUpsert.put('Batch.CampaignMemberStatus', settingRFMScoreBrandStatus);

		String settingRFMScoreBrandDay = batchSettings.get('Batch.CampaignMemberDay');
		settingRFMScoreBrandDay = settingsDeserialized.selectedExecuteAtCampaignMemberDay;
		settingsToUpsert.put('Batch.CampaignMemberDay', settingRFMScoreBrandDay);

		String settingRFMScoreBrandTime = batchSettings.get('Batch.CampaignMemberTime');
		settingRFMScoreBrandTime = settingsDeserialized.selectedExecuteAtCampaignMember;
		settingsToUpsert.put('Batch.CampaignMemberTime', settingRFMScoreBrandTime);

		if (settingsDeserialized.selectedStateCampaignMember == 'Off') {
			stopCmMonitor('CampaignMember');
		}
		else if (settingsDeserialized.selectedStateCampaignMember == 'On' && isRFMScoreBrandChanged) {
			stopCmMonitor('CampaignMember');
			startCmMonitor('CampaignMember', settingsDeserialized);
		}

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'Campaign Member Batch has been successfully scheduled!';

		} else {
			return 'Error! ';
		}
	}

	@auraEnabled
	public static String getCmTimeScheduleJobs() {
		Map<String, DateTime> scheduleJobsMap = new Map<String, DateTime>();
		Set<String> nameScheduleJobs = new Set<String>{'CampaignMember'};

		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'CronJobDetail',
					'CampaignMemberSettingsController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronJobDetail.Name.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'CronTrigger',
					'CampaignMemberSettingsController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronTrigger.NextFireTime.getDescribe()
							}
			);

			List<CronTrigger> scheduleInProgress = [
					SELECT Id, NextFireTime, CronJobDetail.Name
					FROM CronTrigger
					WHERE CronJobDetail.Name IN :nameScheduleJobs
			LIMIT 10
			];
			for (CronTrigger item : scheduleInProgress) {
				scheduleJobsMap.put(item.CronJobDetail.Name, item.NextFireTime);
			}
			CmTimeScheduleJobsWrapper timeScheduleJobs = new CmTimeScheduleJobsWrapper();
			timeScheduleJobs.nextRunTime = (scheduleJobsMap.containsKey('CampaignMember')) ? scheduleJobsMap.get('CampaignMember') : NULL;
			return JSON.serialize(timeScheduleJobs);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

	}

	// if there is active batches then true
	private static Boolean searchCmActiveBatches(Set<String> namesBatches) {
		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'AsyncApexJob',
					'CampaignMemberSettingsController.cls [init]',
					new List<Schema.DescribeFieldResult> {
							AsyncApexJob.ApexClassId.getDescribe(), AsyncApexJob.Status.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'ApexClass',
					'CampaignMemberSettingsController.cls [init]',
					new List<Schema.DescribeFieldResult> {
							ApexClass.Name.getDescribe()
							}
			);
			List<AsyncApexJob> jobs = [
					SELECT Id, Status, ApexClassId, ApexClass.Name
					FROM AsyncApexJob
					WHERE ApexClass.Name IN : namesBatches
			AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
			];
			if (jobs.isEmpty()) {
				return false;
			}
			else {
				return true;
			}
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	private static Id getCmScheduleJobs(String nameCronTrigger) {
		Id result = null;
		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'CronJobDetail',
					'CampaignMemberSettingsController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronJobDetail.Name.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'CronTrigger',
					'CampaignMemberSettingsController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronTrigger.NextFireTime.getDescribe()
							}
			);
			List<CronTrigger> scheduleInProgress = [
					SELECT Id, NextFireTime
					FROM CronTrigger
					WHERE CronJobDetail.Name =: nameCronTrigger
			];
			result = (scheduleInProgress.isEmpty()) ? NULL : scheduleInProgress.get(0).Id;
			return result;
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	private static void stopCmMonitor(String nameCronTrigger) {
		Id schJobId = getCmScheduleJobs(nameCronTrigger);
		if (schJobId != null) {
			System.abortJob(schJobId);
		}
	}

	private static void startCmMonitor(String nameCronTrigger, CmSettingsWrapper settingsDeserialized) {
		Id schJobId = getCmScheduleJobs(nameCronTrigger);
		if (schJobId == null) {
			String cronStr = '0 0 ' + settingsDeserialized.selectedExecuteAtCampaignMember + ' 1/1 * ? *';
			Map<String, String> batchToSchedule = new Map<String, String>();
			batchToSchedule.put('Name', nameCronTrigger);
			batchToSchedule.put('CronString', cronStr);
			batchToSchedule.put('BatchName', 'CampaignMemberScheduler');
			TouchCRHelper.scheduleBatch(batchToSchedule);
		}
	}

	public class CmSettingsWrapper {
		public String selectedStateCampaignMember { get; set; }
		public String selectedExecuteAtCampaignMemberDay { get; set; }
		public String selectedExecuteAtCampaignMember { get; set; }
	}

	public class CmTimeScheduleJobsWrapper {
		public Datetime nextRunTime { get; set; }
	}

// HouseCleanerSettings

	// THE BATCHES NAMES TO CHECK THEIR WORK
	public static final Map<String, Set<String>> HC_NAME_TO_CLASSES = new Map<String, Set<String>> {
		'HouseCleaner' => new Set<String>{ 'TouchCRHouseCleanerBatch' }
	};

	// BATCH SCORE BRAND COUNTER settings
	public static final Map<String, String> HC_BATCH_SETTING = new Map<String, String> {
		'Batch.HouseCleanerState' => '',
		'Batch.HouseCleanerTime' => '',
		'Batch.HouseCleanerDay' => ''
	};

	public static final Map<String, String> HC_HOUSECLEANER_SETTING = new Map<String, String> {
		'HouseCleaner.RecordAge' => 'RecordAge',
		'HouseCleaner.ObjectApiName' => 'ObjectApiName'
	};

	public static Map<String, String> getHcSettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}

	@auraEnabled
	public static String getHcSettingsApex(String settingsType) {

		if (settingsType == 'BATCH_SETTING') {
			return JSON.serialize(getHcSettings(HC_BATCH_SETTING.keySet()));
		}
		else {
			return JSON.serialize(getHcSettings(HC_HOUSECLEANER_SETTING.keySet()));
		}
	}

	@auraEnabled
	public static String executeNowHouseCleaner() {
		String cronString = '' + DateTime.now().second() + ' ' +
				DateTime.now().addMinutes(1).minute() + ' ' + DateTime.now().hour() + ' ' +
				DateTime.now().day() + ' ' + DateTime.now().month() + ' ? ' +
				DateTime.now().year();
		if (searchHcActiveBatches(HC_NAME_TO_CLASSES.get('HouseCleaner')) == false) {
			stopHcMonitor('HouseCleaner');
			Map<String, String> batchToSchedule = new Map<String, String>();
			batchToSchedule.put('Name', 'HouseCleaner');
			batchToSchedule.put('CronString', cronString);
			batchToSchedule.put('BatchName', 'TouchCRHouseCleanerBatchScheduler');
			TouchCRHelper.scheduleBatch(batchToSchedule);
			return 'Success! House Cleaner Batch will be initiated in 1 minute!';
		}
		else {
			return 'House Cleaner Batch cannot be started, please try again later!';
		}
	}


	@auraEnabled
	public static String saveHc(String settings) {

		HcSettingsWrapper settingsDeserialized = (HcSettingsWrapper)JSON.deserialize(settings, HcSettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();

		Map<String, String> batchSettings = getHcSettings(HC_BATCH_SETTING.keySet());
		Map<String, String> houseCleanerSettings = getHcSettings(HC_HOUSECLEANER_SETTING.keySet());

		Boolean isHouseCleanerChanged = (
			settingsDeserialized.selectedStateHouseCleaner != batchSettings.get('Batch.HouseCleanerState') ||
			settingsDeserialized.selectedExecuteHouseCleanerDay != batchSettings.get('Batch.HouseCleanerDay') ||
			settingsDeserialized.selectedExecuteHouseCleaner != batchSettings.get('Batch.HouseCleanerTime')
		);

		String settingHouseCleanerState = batchSettings.get('Batch.HouseCleanerState');
		settingHouseCleanerState = settingsDeserialized.selectedStateHouseCleaner;
		settingsToUpsert.put('Batch.HouseCleanerState', settingHouseCleanerState);

		String settingHouseCleanerDay = batchSettings.get('Batch.HouseCleanerDay');
		settingHouseCleanerDay = settingsDeserialized.selectedExecuteHouseCleanerDay;
		settingsToUpsert.put('Batch.HouseCleanerDay', settingHouseCleanerDay);

		String settingHouseCleanerTime = batchSettings.get('Batch.HouseCleanerTime');
		settingHouseCleanerTime = settingsDeserialized.selectedExecuteHouseCleaner;
		settingsToUpsert.put('Batch.HouseCleanerTime', settingHouseCleanerTime);

		//Settings for HOUSE_CLEANER
		String recordAgeSetting = houseCleanerSettings.get('HouseCleaner.RecordAge');
		recordAgeSetting = settingsDeserialized.selectedRecordAgeHouseCleaner;
		settingsToUpsert.put('HouseCleaner.RecordAge', recordAgeSetting);

		String objectSetting = houseCleanerSettings.get('HouseCleaner.ObjectApiName');
		objectSetting = settingsDeserialized.selectedObjectHouseCleaner;
		settingsToUpsert.put('HouseCleaner.ObjectApiName', objectSetting);

		if (settingsDeserialized.selectedStateHouseCleaner == 'Off') {
			stopHcMonitor('HouseCleaner');
		}
		else if (settingsDeserialized.selectedStateHouseCleaner == 'On' && isHouseCleanerChanged) {
			stopHcMonitor('HouseCleaner');
			startHcMonitor('HouseCleaner', settingsDeserialized);
		}

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'House Cleaner Batch has been successfully scheduled!';
		} else {
			return 'Error! ';
		}
	}

	@auraEnabled
	public static String getHcTimeScheduleJobs() {
		Map<String, DateTime> scheduleJobsMap = new Map<String, DateTime>();
		Set<String> nameScheduleJobs = new Set<String>{'HouseCleaner'};

		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'CronJobDetail',
					'HouseCleanerSettingsController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronJobDetail.Name.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'CronTrigger',
					'HouseCleanerSettingsController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronTrigger.NextFireTime.getDescribe()
							}
			);

			List<CronTrigger> scheduleInProgress = [
					SELECT Id, NextFireTime, CronJobDetail.Name
					FROM CronTrigger
					WHERE CronJobDetail.Name IN :nameScheduleJobs
			LIMIT 10
			];
			for (CronTrigger item : scheduleInProgress) {
				scheduleJobsMap.put(item.CronJobDetail.Name, item.NextFireTime);
			}
			HcTimeScheduleJobsWrapper timeScheduleJobs = new HcTimeScheduleJobsWrapper();
			timeScheduleJobs.nextRunTime = (scheduleJobsMap.containsKey('HouseCleaner')) ? scheduleJobsMap.get('HouseCleaner') : NULL;
			return JSON.serialize(timeScheduleJobs);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

	}

	// if there is active batches then true
	private static Boolean searchHcActiveBatches(Set<String> namesBatches) {
		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'AsyncApexJob',
					'HouseCleanerSettingsController.cls [init]',
					new List<Schema.DescribeFieldResult> {
							AsyncApexJob.ApexClassId.getDescribe(), AsyncApexJob.Status.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'ApexClass',
					'HouseCleanerSettingsController.cls [init]',
					new List<Schema.DescribeFieldResult> {
							ApexClass.Name.getDescribe()
							}
			);
			List<AsyncApexJob> jobs = [
					SELECT Id, Status, ApexClassId, ApexClass.Name
					FROM AsyncApexJob
					WHERE ApexClass.Name IN : namesBatches
			AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
			];
			if (jobs.isEmpty()) {
				return false;
			}
			else {
				return true;
			}
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	private static Id getHcScheduleJobs(String nameCronTrigger) {
		Id result = null;
		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'CronJobDetail',
					'HouseCleanerSettingsController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronJobDetail.Name.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'CronTrigger',
					'HouseCleanerSettingsController.cls [getScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronTrigger.NextFireTime.getDescribe()
							}
			);
			List<CronTrigger> scheduleInProgress = [
					SELECT Id, NextFireTime
					FROM CronTrigger
					WHERE CronJobDetail.Name =: nameCronTrigger
			];
			result = (scheduleInProgress.isEmpty()) ? NULL : scheduleInProgress.get(0).Id;
			return result;
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	private static void stopHcMonitor(String nameCronTrigger) {
		Id schJobId = getHcScheduleJobs(nameCronTrigger);
		if (schJobId != null) {
			System.abortJob(schJobId);
		}
	}

	private static void startHcMonitor(String nameCronTrigger, HcSettingsWrapper settingsDeserialized) {
		Id schJobId = getHcScheduleJobs(nameCronTrigger);
		if (schJobId == null) {
			String cronStr = '0 0 ' + settingsDeserialized.selectedExecuteHouseCleaner + ' 1/1 * ? *';
			Map<String, String> batchToSchedule = new Map<String, String>();
			batchToSchedule.put('Name', nameCronTrigger);
			batchToSchedule.put('CronString', cronStr);
			batchToSchedule.put('BatchName', 'TouchCRHouseCleanerBatchScheduler');
			TouchCRHelper.scheduleBatch(batchToSchedule);
		}
	}

	public class HcSettingsWrapper {
		public String selectedStateHouseCleaner { get; set; }
		public String selectedExecuteHouseCleanerDay { get; set; }
		public String selectedExecuteHouseCleaner { get; set; }
		public String selectedRecordAgeHouseCleaner { get; set; }
		public String selectedObjectHouseCleaner { get; set; }
	}

	public class HcTimeScheduleJobsWrapper {
		public Datetime nextRunTime { get; set; }
	}


// RefundPeriodSettings

	// THE BATCHES NAMES TO CHECK THEIR WORK
	public static final Map<String, Set<String>> RP_NAME_TO_CLASSES = new Map<String, Set<String>> {
		'RefundPeriod' => new Set<String>{ 'CommissionEarnedBatch' }
	};

	// BATCH SCORE BRAND COUNTER settings
	public static final Map<String, String> RP_BATCH_SETTING = new Map<String, String> {
		'Batch.RefundPeriodStatus' => '',
		'Batch.RefundPeriodTime' => '',
		'Batch.RefundPeriodDay' => '',
		'Batch.RefundPeriodValue' => ''
	};

	public static Map<String, String> getRpSettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}

	@auraEnabled
	public static String getRpSettingsApex() {

		return JSON.serialize(getRpSettings(RP_BATCH_SETTING.keySet()));
	}

	@auraEnabled
	public static String executeNowRefundPeriod() {
		String cronString = '' + DateTime.now().second() + ' ' +
				DateTime.now().addMinutes(1).minute() + ' ' + DateTime.now().hour() + ' ' +
				DateTime.now().day() + ' ' + DateTime.now().month() + ' ? ' +
				DateTime.now().year();
		if (searchCmActiveBatches(RP_NAME_TO_CLASSES.get('RefundPeriod')) == false) {
			stopCmMonitor('RefundPeriod');
			Map<String, String> batchToSchedule = new Map<String, String>();
			batchToSchedule.put('Name', 'RefundPeriod');
			batchToSchedule.put('CronString', cronString);
			batchToSchedule.put('BatchName', 'CommissionEarnedScheduler');
			TouchCRHelper.scheduleBatch(batchToSchedule);
			return 'Success! Refund Period Batch will be initiated in 1 minute!';
		}
		else {
			return 'Refund Period Batch cannot be started, please try again later!';
		}
	}


	@auraEnabled
	public static String saveRp(String settings) {

		RpSettingsWrapper settingsDeserialized = (RpSettingsWrapper)JSON.deserialize(settings, RpSettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();

		Map<String, String> batchSettings = getRpSettings(RP_BATCH_SETTING.keySet());

		Boolean isRPChanged = (
			settingsDeserialized.selectedStateRefundPeriod != batchSettings.get('Batch.RefundPeriodStatus') ||
			settingsDeserialized.selectedExecuteAtRefundPeriodDay != batchSettings.get('Batch.RefundPeriodDay') ||
			settingsDeserialized.selectedExecuteAtRefundPeriod != batchSettings.get('Batch.RefundPeriodTime') ||
			settingsDeserialized.selectedRefundPeriodValue != batchSettings.get('Batch.RefundPeriodValue') 
		);

		settingsToUpsert.put('Batch.RefundPeriodStatus', settingsDeserialized.selectedStateRefundPeriod);
		settingsToUpsert.put('Batch.RefundPeriodDay', settingsDeserialized.selectedExecuteAtRefundPeriodDay);
		settingsToUpsert.put('Batch.RefundPeriodTime', settingsDeserialized.selectedExecuteAtRefundPeriod);
		settingsToUpsert.put('Batch.RefundPeriodValue', settingsDeserialized.selectedRefundPeriodValue);

		if (settingsDeserialized.selectedStateRefundPeriod == 'Off') {
			stopRpMonitor('RefundPeriod');
		}
		else if (settingsDeserialized.selectedStateRefundPeriod == 'On' && isRPChanged) {
			stopRpMonitor('RefundPeriod');
			startRpMonitor('RefundPeriod', settingsDeserialized);
		}

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'Refund Period Batch has been successfully scheduled!';

		} else {
			return 'Error! ';
		}
	}

	@auraEnabled
	public static String getRpTimeScheduleJobs() {
		Map<String, DateTime> scheduleJobsMap = new Map<String, DateTime>();
		Set<String> nameScheduleJobs = new Set<String>{'RefundPeriod'};

		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'CronJobDetail',
					'TouchCRAuraSettingsBatchesController.cls [getRpTimeScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronJobDetail.Name.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'CronTrigger',
					'TouchCRAuraSettingsBatchesController.cls [getRpTimeScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronTrigger.NextFireTime.getDescribe()
							}
			);

			List<CronTrigger> scheduleInProgress = [
					SELECT Id, NextFireTime, CronJobDetail.Name
					FROM CronTrigger
					WHERE CronJobDetail.Name IN :nameScheduleJobs
			LIMIT 10
			];
			for (CronTrigger item : scheduleInProgress) {
				scheduleJobsMap.put(item.CronJobDetail.Name, item.NextFireTime);
			}
			RpTimeScheduleJobsWrapper timeScheduleJobs = new RpTimeScheduleJobsWrapper();
			timeScheduleJobs.nextRunTime = (scheduleJobsMap.containsKey('RefundPeriod')) ? scheduleJobsMap.get('RefundPeriod') : NULL;
			return JSON.serialize(timeScheduleJobs);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

	}

	// if there is active batches then true
	private static Boolean searchRpActiveBatches(Set<String> namesBatches) {
		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'AsyncApexJob',
					'TouchCRAuraSettingsBatchesController.cls [searchRpActiveBatches]',
					new List<Schema.DescribeFieldResult> {
							AsyncApexJob.ApexClassId.getDescribe(), AsyncApexJob.Status.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'ApexClass',
					'TouchCRAuraSettingsBatchesController.cls [searchRpActiveBatches]',
					new List<Schema.DescribeFieldResult> {
							ApexClass.Name.getDescribe()
							}
			);
			List<AsyncApexJob> jobs = [
					SELECT Id, Status, ApexClassId, ApexClass.Name
					FROM AsyncApexJob
					WHERE ApexClass.Name IN : namesBatches
			AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
			];
			if (jobs.isEmpty()) {
				return false;
			}
			else {
				return true;
			}
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	private static Id getRpScheduleJobs(String nameCronTrigger) {
		Id result = null;
		try {
			SFDCAccessController.AccessibleWithoutSharing (
					'CronJobDetail',
					'TouchCRAuraSettingsBatchesController.cls [getRpScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronJobDetail.Name.getDescribe()
							}
			);
			SFDCAccessController.AccessibleWithoutSharing (
					'CronTrigger',
					'TouchCRAuraSettingsBatchesController.cls [getRpScheduleJobs]',
					new List<Schema.DescribeFieldResult> {
							CronTrigger.NextFireTime.getDescribe()
							}
			);
			List<CronTrigger> scheduleInProgress = [
					SELECT Id, NextFireTime
					FROM CronTrigger
					WHERE CronJobDetail.Name =: nameCronTrigger
			];
			result = (scheduleInProgress.isEmpty()) ? NULL : scheduleInProgress.get(0).Id;
			return result;
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	private static void stopRpMonitor(String nameCronTrigger) {
		Id schJobId = getCmScheduleJobs(nameCronTrigger);
		if (schJobId != null) {
			System.abortJob(schJobId);
		}
	}

	private static void startRpMonitor(String nameCronTrigger, RpSettingsWrapper settingsDeserialized) {
		Id schJobId = getCmScheduleJobs(nameCronTrigger);
		if (schJobId == null) {
			String cronStr = '0 0 ' + settingsDeserialized.selectedExecuteAtRefundPeriod
			 + ' 1/1 * ? *';
			Map<String, String> batchToSchedule = new Map<String, String>();
			batchToSchedule.put('Name', nameCronTrigger);
			batchToSchedule.put('CronString', cronStr);
			batchToSchedule.put('BatchName', 'CommissionEarnedScheduler');
			TouchCRHelper.scheduleBatch(batchToSchedule);
		}
	}

	public class RpSettingsWrapper {
		public String selectedStateRefundPeriod { get; set; }
		public String selectedExecuteAtRefundPeriodDay { get; set; }
		public String selectedExecuteAtRefundPeriod { get; set; }
		public String selectedRefundPeriodValue { get; set; }
	}

	public class RpTimeScheduleJobsWrapper {
		public Datetime nextRunTime { get; set; }
	}

}