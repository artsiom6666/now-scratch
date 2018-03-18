public with sharing class AuthorizeController {

	public Order__c order { get; set; }

	public String cardType { get; set; }
	public String cardNumber { get; set; }
	public String cardExpirationYear { get; set; }
	public String cardExpirationMonth { get; set; }
	public String ccv { get; set; }

	/*
	
	 */
	public AuthorizeController (ApexPages.StandardController stdController) {

		if (Schema.sObjectType.Order__c.isAccessible()) {
			order = [
				SELECT Id, Amount_To_Charge__c
				FROM Order__c
				WHERE Id =: (Id)stdController.getId()
				LIMIT 1
			];
		}
	}

	public PageReference authorizeOrderNow() {
		if (String.isBlank(cardNumber) || String.isBlank(ccv)) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You must enter a values in required fields'));
			return null;
		}
		else if (order.Amount_To_Charge__c < 1) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'The Amount must not be less than 1 Dollar'));
			return null;
		} else {
			Map<String,Object> creditCard = new Map<String,Object>{
				'CardNumber' => cardNumber,
				'CardCCV' => ccv,
				'CardExpirationMonth' => cardExpirationMonth,
				'CardExpirationYear' => cardExpirationYear
			};
			Map<String,Object> result = PaymentProcessor.doPayment(
				new Map<String,Object>{
					'Method' => 'Authorization',
					'OrderId' => order.Id,
					'Amount' => order.Amount_To_Charge__c,
					'CreditCard' => creditCard
				}
			);
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, (String)result.get('Status')));
			return cancel((Id)result.get('Transaction'));
		}
	}

	public PageReference cancel(Id transactionId) {
		PageReference redirectPage = new PageReference('/' + transactionId);
		redirectPage.setRedirect(true);
		return redirectPage;
	}

	@AuraEnabled
	public static Decimal getAmount(String orderId) {
		List<Order__c> order = [
			SELECT Id, Amount_To_Charge__c
			FROM Order__c
			WHERE Id =: orderId
			LIMIT 1
		];
		return order.isEmpty() ? 0 : order[0].Amount_To_Charge__c;
	}

	//added for Lighting Component
	@AuraEnabled
	public static String authorizeOrderNow(String authorizeData) {
		try {
			Map<String, String> allAuthorizeData = (Map<String, String>)JSON.deserialize(authorizeData, Map<String, String>.class);

			if (allAuthorizeData.containsKey('cardExpirationMonth') && allAuthorizeData.containsKey('cardExpirationYear')
				&& allAuthorizeData.containsKey('ccv') && allAuthorizeData.containsKey('cardNumber')
				&& allAuthorizeData.containsKey('recordId') && allAuthorizeData.containsKey('amount')) {

				String cardExpirationMonth = allAuthorizeData.get('cardExpirationMonth');
				String cardExpirationYear = allAuthorizeData.get('cardExpirationYear');
				String ccv = allAuthorizeData.get('ccv');
				String cardNumber = allAuthorizeData.get('cardNumber');
				String recordId = allAuthorizeData.get('recordId');
				String amount = allAuthorizeData.get('amount');

				Map<String,Object> creditCard = new Map<String,Object>{
					'CardNumber' => cardNumber,
					'CardCCV' => ccv,
					'CardExpirationMonth' => cardExpirationMonth,
					'CardExpirationYear' => cardExpirationYear
				};

				Map<String,Object> result = PaymentProcessor.doPayment(
					new Map<String,Object>{
						'Method' => 'Authorization',
						'OrderId' => recordId,
						'Amount' => Decimal.valueOf(amount),
						'CreditCard' => creditCard
					}
				);

				//default value
				String transactionId = '';
				
				if (result.containsKey('Transaction')) { transactionId = String.valueOf(result.get('Transaction')); }
				if (!result.containsKey('Status')) { return '{"status":"error","error":"Error Transaction Service Unavailable", "transaction":"' + transactionId + '"}'; }
				if ((String)result.get('Status') == 'Error') { return '{"status":"error","error":"' + result.get('Message') + '","transaction":"' + transactionId + '"}'; }
				if ((String)result.get('Status') == 'Approved') { return '{"status":"success","transaction":"' + transactionId + '"}'; }
			}
			return '{"status":"error","error":"Data is not valid","transaction":""}'; 
		} catch (Exception e) { return '{"status":"error","error":"' + e.getMessage() + '","transaction":""}'; }    
	}

}