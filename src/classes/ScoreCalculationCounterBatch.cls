public with sharing class ScoreCalculationCounterBatch implements Database.Batchable<sObject>, Database.Stateful {

	@TestVisible private Integer total = 0;
	public final static Integer NUMBER_OF_SECTIONS = 5;

	public ScoreCalculationCounterBatch() {
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('' +
			'SELECT Id FROM Account WHERE ' +
			'IsPersonAccount = true ' +
			'AND Id IN (SELECT Account__c FROM Order__c)'
		);
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		this.total += scope.size();
	}

	public void finish(Database.BatchableContext BC) {
		ScoreCalculationBatch b = new ScoreCalculationBatch(1, adjustUp(this.total, NUMBER_OF_SECTIONS));
		Database.executebatch(b, 200);
	}

	public static Integer adjustUp(Integer value, Integer base) {
		Integer adjustmentValue = Math.mod(value, base);
		Integer result = (value + adjustmentValue) / base;
		return result;
	}
}