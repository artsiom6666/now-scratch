public with sharing class VoidController {

	public Id orderTransactionId { get; set; }

	public VoidController(ApexPages.StandardController stdController) {
		if (Schema.sObjectType.Order_Transaction__c.isAccessible()) {
			orderTransactionId = (Id)stdController.getId();
		}
	}

	public PageReference voidTransactionNow() {
		Map<String,Object> result = PaymentProcessor.doPayment(
			new Map<String,Object>{
				'Method' => 'Void',
				'Transaction' => orderTransactionId
			}
		);

		Id transactionId = (Id)result.get('Transaction');

		List<Order_Transaction__c> currentTransaction = [
			SELECT Id, Order__c, Response_Status__c, Type__c
			FROM Order_Transaction__c
			WHERE Id = :transactionId
		];

		if (!currentTransaction.isEmpty() && currentTransaction[0].Response_Status__c == 'Approved' && currentTransaction[0].Type__c == 'Void') {
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
	public static String voidNow(String recordId, Decimal amount) {
		Map<String,Object> result = PaymentProcessor.doPayment(
			new Map<String,Object>{
				'Method' => 'Void',
				'Amount' => amount,
				'Transaction' => recordId
			}
		);

		if (result.containsKey('Status')) {
			if (result.get('Status') == 'Approved') {
				String transactionId = (String)result.get('Transaction');
				List<Order_Transaction__c> orderTransaction = [
					SELECT Id, Order__c
					FROM Order_Transaction__c
					WHERE Id =: transactionId
					LIMIT 1
				];
				result.put('parentId',orderTransaction[0].Order__c);
				update new Order__c(Id = orderTransaction[0].Order__c, Status__c = 'Voided');
			}
		}
		return JSON.serialize(result);
	}

}