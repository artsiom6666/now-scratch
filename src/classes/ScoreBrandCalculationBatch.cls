public with sharing class ScoreBrandCalculationBatch implements Database.Batchable<sObject> {

	private final static Map<Integer, String> SCORE_FIELDNAMES =
		new Map<Integer, String> {
			1 => Account.Recency_Score_Brand__c.getDescribe().getName(),
			2 => Account.Frequency_Score_Brand__c.getDescribe().getName(),
			3 => Account.Monetary_Score_Brand__c.getDescribe().getName()
		};
	// order fields will be the same as for global scores
	private final static Map<Integer, String> ORDER_FIELDNAMES = ScoreCalculationBatch.ORDER_FIELDNAMES;
	private final static Map<Integer, Integer> SECTION_TO_SCORES = ScoreCalculationBatch.SECTION_TO_SCORES;

	private final static String APEX_JOB_ID_FIELD = Account.Apex_Brand_Job_Id__c.getDescribe().getName();
	private final static String BRAND_FIELD = ScoreBrandCounterBatch.BRAND_FIELD;

	private final static Integer NUMBER_OF_SECTIONS = ScoreCalculationBatch.NUMBER_OF_SECTIONS;

	//allowed values for batchStep 1,2,3
	private Integer batchStep;
	private String scoreFieldName;
	private String orderFieldName;
	private Integer sectionLimit;
	private String currentBrand;
	private Set<String> processedBrands;
	private Set<Id> previousJobIds;

	/**
	 * default constructor invoked from scheduler
	 * sets apex jobs ids to empty, so calculations begins for each score separatly
	 * @param  step            score RFM which will be calculated
	 * @param  soqllimit       number of records for the current brand for the each score/section
	 * @param  currentBrand    brand to process
	 * @param  processedBrands already processed brands
	 */
	public ScoreBrandCalculationBatch(Integer step, Integer soqllimit, String currentBrand, Set<String> processedBrands) {
		this(step, soqllimit, currentBrand, processedBrands, new Set<Id>());
	}

	/**
	 * constructor which has apex jobs ids from previous execution
	 * records processed by theses jobs will be ignored
	 * @param  step            score RFM which will be calculated
	 * @param  soqllimit       number of records for the current brand for the each score/section
	 * @param  currentBrand    brand to process
	 * @param  processedBrands already processed brands
	 * @param  apexJobIds      previous jobs ids
	 */
	public ScoreBrandCalculationBatch(Integer step, Integer soqllimit, String currentBrand, Set<String> processedBrands, Set<Id> apexJobIds) {
		this.batchStep = (step > 0 && step <= 3) ? step : 1;
		this.scoreFieldName = SCORE_FIELDNAMES.get(this.batchStep);
		this.orderFieldName = ORDER_FIELDNAMES.get(this.batchStep);
		this.sectionLimit = soqllimit;
		this.currentBrand = currentBrand;
		this.processedBrands = new Set<String>(processedBrands);
		this.previousJobIds = new Set<Id>(apexJobIds);
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {

		String soqlStr = 'SELECT Id, ' + this.scoreFieldName
			+ ' FROM Account '
			+ ' WHERE IsPersonAccount = true '
			+ ' AND ' + APEX_JOB_ID_FIELD + ' NOT IN :previousJobIds '
			+ ' AND ' + BRAND_FIELD + ' = :currentBrand '
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

		if (!accountsToUpdate.isEmpty()) {
			try {
				SFDCAccessController.AccessibleWithoutSharing (
					'Order__c',
					'ScoreBrandCalculationBatch.cls [execute]',
					new List<Schema.DescribeFieldResult> {
						Account.IsPersonAccount.getDescribe(), Account.Brand_Assortment__c.getDescribe(),
						Account.Last_order_date__c.getDescribe(), Account.Number_Of_Zero_Balance_Orders__c.getDescribe(),
						Account.Subtotal_From_Zero_Balance_Orders__c.getDescribe()
					}
				);
				SFDCAccessController.UpdateWithoutSharing (
					accountsToUpdate,
					'ScoreBrandCalculationBatch.cls [execute]',
					new List<Schema.DescribeFieldResult> {
						Account.Recency_Score_Brand__c.getDescribe(), Account.Monetary_Score_Brand__c.getDescribe(),
						Account.Frequency_Score_Brand__c.getDescribe(), Account.Apex_Brand_Job_Id__c.getDescribe()
					}
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}
	}

	/**
	 * execute itself for each score for each calculation
	 * 1. 5 times for each score => 5,4,3,2,1
	 * 2. changes the step, it means next score will be calculated, Recency, Frequency, Monetary
	 * 3. start brand counter which tries to find next unprocessed brand and start this batch again for next brand
	 */
	public void finish(Database.BatchableContext BC) {
		Set<Id> jobsIds = new Set<Id>();
		jobsIds.addAll(this.previousJobIds);
		jobsIds.add(BC.getJobId());

		//size = 0, section = 1 {}
		//size = 1, section = 2 {'0'}
		//size = 2, section = 3 {'0', '1'}
		//size = 3, section = 4 {'0', '1', '2'}
		//size = 4, section = 5 {'0', '1', '2', '3'}

		// first check if all scores set, 5-4-3-2-1
		if (jobsIds.size() < NUMBER_OF_SECTIONS) {
			ScoreBrandCalculationBatch job = new ScoreBrandCalculationBatch(this.batchStep, this.sectionLimit, this.currentBrand, this.processedBrands, jobsIds);
			Database.executeBatch(job, 200);
		}
		// then check if RFM params set
		else if (this.batchStep < 3) {
			ScoreBrandCalculationBatch job = new ScoreBrandCalculationBatch(++this.batchStep, this.sectionLimit, this.currentBrand, this.processedBrands, new Set<Id>());
			Database.executeBatch(job, 200);
		}
		// then start counter to find next unprocessed brand passing set of already processed brands there
		// exit will be in counter batch
		else {
			Set<String> processedBrands = new Set<String>();
			processedBrands.addAll(this.processedBrands);
			processedBrands.add(this.currentBrand);

			ScoreBrandCounterBatch b = new ScoreBrandCounterBatch(processedBrands);
			database.executebatch(b, 2000);
		}
	}
}