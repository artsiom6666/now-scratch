public with sharing class ChargeController {

	public Order__c order { get; set; }

	public ChargeController(ApexPages.StandardController stdController) {
		if (Schema.sObjectType.Order__c.isAccessible()) {
			order = (Order__c)stdController.getRecord();
		}
	}

	public PageReference chargeOrder() {
		Map<String,Object> result = PaymentProcessor.doPayment(
			new Map<String,Object>{
				'Method' => 'Charge',
				'OrderId' => order.Id
			}
		);
		String orderId = order.Id;
		String affiliateFields = TouchCRHelper.isAffiliateEnabled() ? ' ,Affiliate_Id__c ' : '';
		String query = ' SELECT Id, Balance_Due__c, Order_Source__c ' + affiliateFields + ' FROM Order__c WHERE Id = :orderId ';
		List<Order__c> orderList = Database.query(query);

		if (TouchCRHelper.isAffiliateEnabled() && !orderList.isEmpty() && String.isNotEmpty((Id)orderList[0].get('Affiliate_Id__c')) && orderList[0].Balance_Due__c == 0) {
			String res = ExtensionsHelperDummy.createCommissionsEarned(orderList[0]);
		}
		
		PageReference redirectPage = new PageReference('/' + result.get('Transaction'));
		redirectPage.setRedirect(true);
		return redirectPage;
	}

	private Void createCommissionEarned () {
		String result = ExtensionsHelperDummy.createCommissionsEarned(order);
	}

	//added for Lighting Component
	@AuraEnabled
	public static String getCardsAndGeneralInfo(String recordId) {
		try {
			Id orderId = Id.valueOf(recordId);

			List<Account> account = [
				SELECT Id, 
				(
					SELECT Id, Profile_Id__c, Option_Id__c, 
					Named_Agent__c, Last_4__c
					FROM Payment_Options__r
					WHERE Status__c = 'Active'
				), 
				(
					SELECT Id, Amount_To_Charge__c, Named_Agent__c
					FROM Orders__r
					WHERE Id =: orderId
				) 
				FROM Account 
				WHERE Id IN 
				(
					SELECT Account__c 
					FROM Order__c 
					WHERE Id =: orderId
				)
			];

			if (account.isEmpty()) { return '{"status":"error","error":"Account was not found"}'; }
			
			List<Map<String, Object>> allPaymentOptions = new List<Map<String, Object>>();
			for (Payment_Option__c pO : account[0].Payment_Options__r) {
				//get Payment Options for a definite Named Agent
				if (pO.Named_Agent__c == account[0].Orders__r[0].Named_Agent__c) {
					allPaymentOptions.add(new Map<String, Object>{
						'isCheck' => false,
						'paymentOptionId' => pO.Id,
						'profileId' => pO.Profile_Id__c,
						'optionId' => pO.Option_Id__c,
						'namedAgent' => pO.Named_Agent__c,
						'last4' => pO.Last_4__c
					});
				}
			}

			return JSON.serialize(new Map<String, Object>{
				'status' => 'success',
				'paymentOptions' => allPaymentOptions,
				'amount' => account[0].Orders__r[0].Amount_To_Charge__c
			});
		} catch (Exception e) { return '{"status":"error","error":"' + e.getMessage() + '"}'; }
	}

	@AuraEnabled
	public static String chargeOrderNow(String chargeData) {
		try {
			Map<String, String> allChargeData = (Map<String, String>)JSON.deserialize(chargeData, Map<String, String>.class);
			
			Map<String,Object> creditCard = new Map<String,Object>();

			if (Boolean.valueOf(allChargeData.get('newCard'))) {
				String cardExpirationMonth = allChargeData.containsKey('month') ? String.valueOf(allChargeData.get('month')) : '';
				String cardExpirationYear = allChargeData.containsKey('year') ? String.valueOf(allChargeData.get('year')) : '';
				String ccv = allChargeData.containsKey('ccv') ? String.valueOf(allChargeData.get('ccv')) : '';
				String cardNumber = allChargeData.containsKey('cardNumber') ? String.valueOf(allChargeData.get('cardNumber')) : '';
	
				if (String.isBlank(cardExpirationMonth) || String.isBlank(cardExpirationYear) || String.isBlank(ccv) || String.isBlank(cardNumber)) {
					return '{"status":"error","error":"Data is not valid"}';
				}
				
				creditCard.put('CardNumber', cardNumber);
				creditCard.put('CardCCV', ccv);
				creditCard.put('CardExpirationMonth', cardExpirationMonth);
				creditCard.put('CardExpirationYear', cardExpirationYear);   
			} else {
				Id chosenPaymentOptionId = allChargeData.containsKey('chosenPaymentOptionId') ? Id.valueOf(allChargeData.get('chosenPaymentOptionId')) : '';
				
				List<Payment_Option__c> paymentOption = [
					SELECT Id, Profile_Id__c, Option_Id__c
					FROM Payment_Option__c
					WHERE Id =: chosenPaymentOptionId
					AND Status__c = 'Active'
				];

				if (paymentOption.isEmpty()) { return '{"status":"error","error":"Payment Option was not found"}'; }

				creditCard.put('CardId', paymentOption[0].Option_Id__c);   
				creditCard.put('Profile', paymentOption[0].Profile_Id__c); 
			}

			String amount = allChargeData.containsKey('amount') ? String.valueOf(allChargeData.get('amount')) : '';
			if (String.isBlank(amount)) { return '{"status":"error","error":"The Amount must not be less than 1 Dollar"}'; }
			String orderId = allChargeData.containsKey('orderId') ? String.valueOf(allChargeData.get('orderId')) : '';
			if (String.isBlank(orderId)) { return '{"status":"error","error":"Order Id was not found"}'; }
			Map<String,Object> result = PaymentProcessor.doPayment(
				new Map<String,Object>{
					'Method' => 'Charge',
					'OrderId' => orderId,
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
			return '{"status":"error","error":"Error Transaction Service Unavailable","transaction":""}'; 
		} catch (Exception e) { return '{"status":"error","error":"' + e.getMessage() + '","transaction":""}'; }
	}


}