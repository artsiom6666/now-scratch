public with sharing class ScoreBrandCounterBatch implements Database.Batchable<sObject>, Database.Stateful {

	public final static Integer NUMBER_OF_SECTIONS = ScoreCalculationCounterBatch.NUMBER_OF_SECTIONS;
	public final static String BRAND_FIELD = Account.Brand_Assortment__c.getDescribe().getName();

	private Integer totalRecords = 0; // total records for the brand
	private String currentBrand;
	private Set<String> processedBrands;
	private Boolean isFinished = true;

	public ScoreBrandCounterBatch(Set<String> processedBrands) {
		// hold already processed brands
		this.processedBrands = new Set<String>(processedBrands);
		// check if any of brands are enabled by settings
		Set<String> enabledBrands = TouchCRConfigurationController.getActiveBrandValuesWithOutPrefix();
		// get first unprocessed brand
		for (String brand : enabledBrands) {
			if (!processedBrands.contains(brand)) {
				this.currentBrand = brand;
				// if unprocessed brand found, tick the compleation flag
				this.isFinished = false;
				// exit when 1st unprocessed brand found
				break;
			}
		}
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		// select all customers with current brand
		String soqlString = 'SELECT Id, ' + BRAND_FIELD
			+ ' FROM Account'
			+ ' WHERE IsPersonAccount = TRUE'
			+ ' AND Id IN (SELECT Account__c FROM Order__c)'
			+ ' AND ' + BRAND_FIELD + ' = :currentBrand';
		return Database.getQueryLocator(soqlString);
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		this.totalRecords += scope.size();
	}

	public void finish(Database.BatchableContext BC) {
		// start calculator, provide step => start with the 1st step
		// soqllimit => number of records for the current brand for the each score/section
		// current brand => brand to process
		// already processed brands
		if (!isFinished) {
			Integer soqllimit = adjustUp(this.totalRecords, NUMBER_OF_SECTIONS);
			ScoreBrandCalculationBatch b = new ScoreBrandCalculationBatch(1, soqllimit, this.currentBrand, this.processedBrands);
			database.executebatch(b, 200);
		}
		else {
			Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();

			if (settingsMap.containsKey('Batch.RFMScoreBrandStatus') && settingsMap.containsKey('Batch.RFMScoreBrandTime') && settingsMap.containsKey('Batch.RFMScoreBrandDay')) {
				TouchCR_Settings__c settingRFMScoreBrandStatus = settingsMap.get('Batch.RFMScoreBrandStatus');
				TouchCR_Settings__c settingRFMScoreBrandTime = settingsMap.get('Batch.RFMScoreBrandTime');
				TouchCR_Settings__c settingRFMScoreBrandDay = settingsMap.get('Batch.RFMScoreBrandDay');

				if (settingRFMScoreBrandStatus.Value__c == 'On' && settingRFMScoreBrandTime.Value__c != '' && settingRFMScoreBrandDay.Value__c != '') {
					List<CronTrigger> scheduleInProgress = [
						SELECT Id, NextFireTime
						FROM CronTrigger
						WHERE CronJobDetail.Name = :'ScoreBrandCounter'
						LIMIT 1
					];
					if (!scheduleInProgress.isEmpty()) {
						System.abortJob(scheduleInProgress.get(0).Id);
					}
					ScoreBrandCounterScheduler scheduler = new ScoreBrandCounterScheduler();
					String cronStr = '0 0 ' + settingRFMScoreBrandTime.Value__c + ' 1/' + settingRFMScoreBrandDay.Value__c + ' * ? *';
					System.schedule('ScoreBrandCounter', cronStr, scheduler);
				}
			}
		}
	}

	public static Integer adjustUp(Integer value, Integer base) {
		Integer adjustmentValue = Math.mod(value, base);
		Integer result = (value + adjustmentValue) / base;
		return result;
	}

}