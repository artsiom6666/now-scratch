public with sharing class RefundController {

	public Id orderTransactionId { get; set; }

	public RefundController(ApexPages.StandardController stdController) {
		if (Schema.sObjectType.Order_Transaction__c.isAccessible()) {
			orderTransactionId = (Id)stdController.getId();
		}
	}

	public PageReference refundNow() {
		Map<String,Object> result = PaymentProcessor.doPayment(
			new Map<String,Object>{
				'Method' => 'Refund',
				'Transaction' => orderTransactionId
			}
		);
		Id transactionId = (Id)result.get('Transaction');

		List<Order_Transaction__c> currentTransaction = [
			SELECT Id, Order__c, Response_Status__c, Type__c
			FROM Order_Transaction__c
			WHERE Id = :transactionId
		];


		if (!currentTransaction.isEmpty() && currentTransaction[0].Response_Status__c == 'Approved' && currentTransaction[0].Type__c == 'Refund') {
			ExtensionsHelperDummy.createRefundCommissionsEarned(currentTransaction[0].Order__c);
		}



		PageReference redirectPage = new PageReference('/' + result.get('Transaction'));
		redirectPage.setRedirect(true);
		return redirectPage;
	}

	//added for Lighting Component
	@AuraEnabled
	public static Decimal getAmount(String transactionId) {
		Set<String> availableTypes = new Set<String>{'Charge', 'Authorization'};
		List<Order_Transaction__c> orderTransaction = [
			SELECT Id, Amount__c, Response_Status__c
			FROM Order_Transaction__c
			WHERE Type__c IN: availableTypes
			AND Response_Status__c = 'Approved'
			AND Id =: transactionId
			LIMIT 1
		];

		return orderTransaction.isEmpty() ? 0 : orderTransaction[0].Amount__c;
	}

	@AuraEnabled
	public static String refund(String recordId, Decimal amount) {
		Order_Transaction__c orderTransaction = [
			SELECT Id, Order__c
			FROM Order_Transaction__c
			WHERE Id =: recordId
			LIMIT 1
		];

		Map<String,Object> result = PaymentProcessor.doPayment(
			new Map<String,Object>{
				'Method' => 'Refund',
				'Amount' => amount,
				'Transaction' => recordId
			}
		);

		if (result.containsKey('Status')) {
			if (result.get('Status') == 'Approved') {
				result.put('parentId', orderTransaction.Order__c);
			}
		}
		return JSON.serialize(result);
	}


}