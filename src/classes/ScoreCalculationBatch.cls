public with sharing class ScoreCalculationBatch implements Database.Batchable<sObject>, Database.Stateful {

	public final static Map<Integer, String> SCORE_FIELDNAMES =
		new Map<Integer, String> {
			1 => Account.Recency_Score__c.getDescribe().getName(),
			2 => Account.Frequency_Score__c.getDescribe().getName(),
			3 => Account.Monetary_Score__c.getDescribe().getName()
		};
	public final static Map<Integer, String> ORDER_FIELDNAMES =
		new Map<Integer, String> {
			1 => Account.Last_order_date__c.getDescribe().getName(),
			2 => Account.Number_Of_Zero_Balance_Orders__c.getDescribe().getName(),
			3 => Account.Subtotal_From_Zero_Balance_Orders__c.getDescribe().getName()
		};
	public final static Map<Integer, Integer> SECTION_TO_SCORES =
		new Map<Integer, Integer> {
			0 => 5,
			1 => 4,
			2 => 3,
			3 => 2,
			4 => 1
		};
	public final static String APEX_JOB_ID_FIELD = Account.Apex_Job_Id__c.getDescribe().getName();
	public final static Integer NUMBER_OF_SECTIONS = 5;

	//allowed values for batchStep 1,2,3
	private Integer batchStep;
	private String scoreFieldName;
	private String orderFieldName;
	private Integer sectionLimit;
	private Set<Id> previousJobIds;


	/**
	 * Default constructor
	 */
	public ScoreCalculationBatch(Integer step, Integer soqlLimit) {
		this(step, soqlLimit, new Set<Id>());
	}

	/**
	 * Constructor with previous job ids set
	 */
	public ScoreCalculationBatch(Integer step, Integer soqlLimit, Set<Id> apexJobIds) {
		this.batchStep = (step > 0 && step <= 3) ? step : 1;
		this.sectionLimit = soqlLimit;

		this.scoreFieldName = SCORE_FIELDNAMES.get(this.batchStep);
		this.orderFieldName = ORDER_FIELDNAMES.get(this.batchStep);
		this.previousJobIds = new Set<Id>(apexJobIds);
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {

		String soqlStr = 'SELECT Id, ' + this.scoreFieldName
			+ ' FROM Account '
			+ ' WHERE IsPersonAccount = true '
			+ ' AND ' + APEX_JOB_ID_FIELD + ' NOT IN :previousJobIds '
			+ ' AND Id IN (SELECT Account__c FROM Order__c)'
			+ ' ORDER BY ' + this.orderFieldName + ' DESC NULLS LAST '
			+ ' LIMIT ' + this.sectionLimit;

		return Database.getQueryLocator(soqlStr);
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Account> accountsScope = (List<Account>) scope;
		List<Account> accountsToUpdate = new List<Account>();

		for (Account acc : accountsScope) {
			Integer score = SECTION_TO_SCORES.get(this.previousJobIds.size());
			acc.put(this.scoreFieldName, score);
			acc.put(APEX_JOB_ID_FIELD, BC.getJobId());
			accountsToUpdate.add(acc);
		}

		try {
			SFDCAccessController.UpdateWithoutSharing (
				accountsToUpdate,
				'ScoreCalculationBatch.cls [execute]',
				new List<Schema.DescribeFieldResult> {
					Account.Apex_Job_Id__c.getDescribe(), Account.Recency_Score__c.getDescribe(),
					Account.Frequency_Score__c.getDescribe(), Account.Monetary_Score__c.getDescribe()
				}
			);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

	}

	public void finish(Database.BatchableContext BC) {
		Set<Id> jobsIds = new Set<Id>();
		jobsIds.addAll(this.previousJobIds);
		jobsIds.add(BC.getJobId());


		Integer bStep = this.batchStep;

		//size = 0, section = 1 {}
		//size = 1, section = 2 {'0'}
		//size = 2, section = 3 {'0', '1'}
		//size = 3, section = 4 {'0', '1', '2'}
		//size = 4, section = 5 {'0', '1', '2', '3'}

		if (jobsIds.size() < NUMBER_OF_SECTIONS) {
			ScoreCalculationBatch job = new ScoreCalculationBatch(bStep, this.sectionLimit, jobsIds);
			Database.executeBatch(job, 200);
		}
		else if (bStep < 3) {
			bStep = bStep + 1;
			ScoreCalculationBatch job = new ScoreCalculationBatch(bStep, this.sectionLimit);
			Database.executeBatch(job, 200);
		}
		else {
			Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();

			if (settingsMap.containsKey('Batch.RFMScoreStatus') && settingsMap.containsKey('Batch.RFMScoreDay') && settingsMap.containsKey('Batch.RFMScoreTime')) {
				TouchCR_Settings__c settingRFMScoreStatus = settingsMap.get('Batch.RFMScoreStatus');
				TouchCR_Settings__c settingRFMScoreDay = settingsMap.get('Batch.RFMScoreDay');
				TouchCR_Settings__c settingRFMScoreTime = settingsMap.get('Batch.RFMScoreTime');

				if (settingRFMScoreStatus.Value__c == 'On' && settingRFMScoreDay.Value__c != '' && settingRFMScoreTime.Value__c != '') {
					List<CronTrigger> scheduleInProgress = [
						SELECT Id, NextFireTime
						FROM CronTrigger
						WHERE CronJobDetail.Name =: 'ScoreCalculation'
						LIMIT 1
					];
					if (!scheduleInProgress.isEmpty()) {
						System.abortJob(scheduleInProgress.get(0).Id);
					}

					ScoreCalculationScheduler scheduler = new ScoreCalculationScheduler();
					String cronStr = '0 0 ' + settingRFMScoreTime.Value__c + ' 1/' + settingRFMScoreDay.Value__c + ' * ? *';
					System.schedule('ScoreCalculation' , cronStr, scheduler);
				}
			}
		}
	}

}