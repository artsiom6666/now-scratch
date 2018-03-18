public with sharing class RestPaymentProcessController {

	public static Decimal fraudStatus{get; set;}

	public static String processPayment(String payment_frequency, String payment_status, String payment_start, String chargeDate, String orderId, Map<String, Object> creditCard){

		/* Check for any fraud history with maxmind API */
		//TO DO
		//RestFraudDetectionController fraudDetection = new RestFraudDetectionController();
		//fraudStatus = fraudDetection.get_Fraud_Detection(orderId);
		//System.debug('fraudStatus: ' + fraudStatus);
		fraudStatus = 10;
		//Integer firstRating = Integer.valueOf(TouchCR_Settings__c.getValues('MinFraud.RatingFirst').value__c);
		//Integer secondRating = Integer.valueOf(TouchCR_Settings__c.getValues('MinFraud.RatingSecond').value__c);
		Integer firstRating = 95;
		Integer secondRating = 98;

		String accountId;
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Order__c',
				'RestPaymentProcessController.cls [processPayment]',
				new List<Schema.DescribeFieldResult> {
					Order__c.Id.getDescribe(), Order__c.Account__c.getDescribe(),
					Order__c.Minfraud_Score__c.getDescribe()
				}
			);
			Order__c order = [SELECT Id, Account__c, Minfraud_Score__c FROM  Order__c  WHERE Id =:orderId];
			accountId = order.Account__c;
		} catch (SFDCAccessControlException e) { return e.ExceptionMessage; }

		/* if fraud status is less than second rating (75) */
		if (fraudStatus < secondRating) {

			/* create a case if user's fraud score comes under Second stage (30-75) */
			if(fraudStatus < secondRating && fraudStatus > firstRating){

				Case caseRecord = new Case(
					Priority = 'Medium',
					Order__c = orderId,
					Status = 'New',
					Origin = 'Web',
					Type = 'Payment',
					Reason_Case__c = 'Fraud Review'
				);
			}

			/* create a case if user's fraud score comes under Second stage (0-30) */
			if (fraudStatus >= 0 && fraudStatus < firstRating ) {
				if (Test.isRunningTest()) {
					return 'true';
				} else {
					Map<String,Object> result = PaymentProcessor.doPayment(
						new Map<String,Object>{
							'Method' => 'Charge',
							'OrderId' => orderId,
							'CreditCard' => creditCard
						}
					);
					if (result.get('Status') != 'Approved') {
						return 'unpaid';
					} else {
						return updateOrder(orderId);
					}
				}
			}
			return 'true';
		} else {

			try {
				SFDCAccessController.AccessibleWithoutSharing (
					'Order__c',
					'RestPaymentProcessController.cls [processPayment]',
					new List<Schema.DescribeFieldResult> {
						Order__c.Id.getDescribe()
					}
				);
				Order__c cOrder = [SELECT Id FROM Order__c WHERE Id =:orderId];
				SFDCAccessController.DeleteWithoutSharing (
					cOrder,
					'RestPaymentProcessController.cls [processPayment]'
				);
			} catch (SFDCAccessControlException e) { return e.ExceptionMessage; }

			try {
				SFDCAccessController.AccessibleWithoutSharing (
					'Order__c',
					'RestPaymentProcessController.cls [processPayment]',
					new List<Schema.DescribeFieldResult> {
						Account.Id.getDescribe(), Account.Blacklist__c.getDescribe()
					}
				);
				Account accToUpd = [SELECT Id, Blacklist__c FROM Account WHERE Id =:accountId];
				accToUpd.Blacklist__c = 'True';
				SFDCAccessController.UpdateWithoutSharing (
					accToUpd,
					'RestPaymentProcessController.cls [processPayment]',
					new List<Schema.DescribeFieldResult> {
						Account.Blacklist__c.getDescribe()
					}
				);
			} catch (SFDCAccessControlException e) { return e.ExceptionMessage; }
			return 'fraud';
		}
	}

	public static String processPaymentV2(Map<String, String> inputDataMap, Map<String, Object> creditCard){
		try{
			//The map where all returned values are stored
			Map<String, Object> resultMap = new Map<String, Object>();
			
			if (!inputDataMap.containsKey('orderId')) { 
				return JSON.serialize(new Map<String, String>{
					'Status' => 'Error',
					'Result' => 'Order Id was not found'
				});
			}
				
			Id orderId = Id.valueOf(inputDataMap.get('orderId'));

			Map<String, Object> chargeData = new Map<String, Object>{
				'Method' => 'Charge',
				'OrderId' => orderId,
				'CreditCard' => creditCard
			};

			Decimal amount = inputDataMap.containsKey('Amount') ? Decimal.valueOf(inputDataMap.get('Amount')) : null;
			if (amount != null) { chargeData.put('Amount', amount); }

			Id paymentOptionId = inputDataMap.containsKey('PaymentOptionId') ? Id.valueOf(inputDataMap.get('PaymentOptionId')) : null;
			if (paymentOptionId != null) { chargeData.put('PaymentOptionId', paymentOptionId); }

			Map<String, Object> result = PaymentProcessor.doPayment(chargeData);

			if (result.get('Status') == 'Approved') { 
				resultMap.put('Status', 'Success');
				resultMap.put('Result', updateOrder(orderId));
			} else {
				resultMap.put('Status', 'Error');
				resultMap.put('Result', 'unpaid');
			}
			return JSON.serialize(resultMap);
		} catch (Exception e) { 			
			return JSON.serialize(new Map<String, Object>{
				'Status' => 'Error',
				'Result' => e.getMessage()
			}); 	
		}
	}

	/**
	* Update order on successfull payment process
	*/
	public static String updateOrder(String orderId){
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Order__c',
				'RestPaymentProcessController.cls [updateOrder]',
				new List<Schema.DescribeFieldResult> {
					Order__c.Id.getDescribe(), Order__c.Account__c.getDescribe()
				}
			);
			Order__c order = [SELECT Id, Account__c FROM  Order__c  WHERE Id =:orderId];
			String accountId = order.Account__c;
			SFDCAccessController.AccessibleWithoutSharing (
				'Account',
				'RestPaymentProcessController.cls [updateOrder]',
				new List<Schema.DescribeFieldResult> {
					Account.Id.getDescribe(), Account.PersonEmail.getDescribe(),
					Account.Orders_Failed__c.getDescribe(), Account.FirstName.getDescribe(),
					Account.LastName.getDescribe()
				}
			);
			Account acc = [SELECT Id, PersonEmail, Orders_Failed__c, FirstName, LastName FROM Account WHERE Id =:accountId];

			order.Payment_Received__c = 'Full';
			order.Status__c = 'Initiated';
			order.Minfraud_Score__c = fraudStatus;

			SFDCAccessController.UpdateWithoutSharing (
				order,
				'RestPaymentProcessController.cls [updateOrder]',
				new List<Schema.DescribeFieldResult> {
					Order__c.Account__c.getDescribe(), Order__c.Payment_Received__c.getDescribe(),
					Order__c.Status__c.getDescribe(), Order__c.Minfraud_Score__c.getDescribe()
				}
			);
			makeautoship(orderId);
			clearCase(acc.id);
		} catch (SFDCAccessControlException e) { return e.ExceptionMessage; }
		return 'true';
	}

	/**
	* Create New Unpaid case
	*/
	public static String unpaidCase(String orderId){
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Order__c',
				'RestPaymentProcessController.cls [unpaidCase]',
				new List<Schema.DescribeFieldResult> {
					Order__c.Id.getDescribe(), Order__c.Account__c.getDescribe()
				}
			);
			Order__c order = [SELECT Id, Account__c FROM  Order__c  WHERE Id =:orderId];
			String accountId = order.Account__c;
			order.Status__c = 'Error';
			order.Minfraud_Score__c = fraudStatus;

			SFDCAccessController.UpdateWithoutSharing (
				order,
				'RestPaymentProcessController.cls [unpaidCase]',
				new List<Schema.DescribeFieldResult> {
					Order__c.Account__c.getDescribe(), Order__c.Payment_Received__c.getDescribe(),
					Order__c.Status__c.getDescribe(), Order__c.Minfraud_Score__c.getDescribe()
				}
			);

			SFDCAccessController.AccessibleWithoutSharing (
				'Order_Transaction__c',
				'RestPaymentProcessController.cls [unpaidCase]',
				new List<Schema.DescribeFieldResult> {
					Order_Transaction__c.Payment_Response_Body__c.getDescribe()
				}
			);
			List<Order_Transaction__c> error = [SELECT Payment_Response_Body__c FROM Order_Transaction__c WHERE Order__c =: orderId ORDER BY Id DESC LIMIT 1];
			String gWError = 'Unknown Error';
			if(!error.isEmpty()){
				gWError = error[0].Payment_Response_Body__c;
			}

			SFDCAccessController.AccessibleWithoutSharing (
				'Contact',
				'RestPaymentProcessController.cls [unpaidCase]',
				new List<Schema.DescribeFieldResult> {
					Contact.Id.getDescribe()
				}
			);
			List<Contact> contacts = [SELECT Id from Contact WHERE AccountId =:accountId];

			Case cs = new Case(
				AccountId = accountId, Order__c = orderId,
				Subject = 'Card was declined.', Status = 'New',
				Origin = 'Phone', Type = 'Payment',
				Reason = 'Unpaid Order', Description = gWError,
				ContactId = !contacts.isEmpty() ? contacts[0].Id : null
			);

			SFDCAccessController.InsertWithoutSharing (
				cs,
				'RestPaymentProcessController.cls [unpaidCase]',
				new List<Schema.DescribeFieldResult> {
					Case.AccountId.getDescribe(), Case.Order__c.getDescribe(),
					Case.Subject.getDescribe(), Case.ContactId.getDescribe(),
					Case.Status.getDescribe(), Case.Origin.getDescribe(),
					Case.Type.getDescribe(), Case.Reason.getDescribe(), Case.Description.getDescribe()

				}
			);
			SFDCAccessController.AccessibleWithoutSharing (
				'Account',
				'RestPaymentProcessController.cls [unpaidCase]',
				new List<Schema.DescribeFieldResult> {
					Account.Id.getDescribe(), Account.Orders_Failed__c.getDescribe()
				}
			);
			/* ------------------- Update Fail order count ------------------- */
			Account acc = [SELECT Id, Orders_Failed__c FROM Account WHERE Id =:accountId LIMIT 1];
			acc.Orders_Failed__c = acc.Orders_Failed__c == null ? 1 : acc.Orders_Failed__c + 1;

			SFDCAccessController.UpdateWithoutSharing (
				acc,
				'RestPaymentProcessController.cls [unpaidCase]',
				new List<Schema.DescribeFieldResult> {
					Account.Orders_Failed__c.getDescribe()
				}
			);
		} catch (SFDCAccessControlException e) { return e.ExceptionMessage; }
		return 'unpaid';
	}

	public static String makeautoship(String orderId){
		try {
			/* ------------------- Make autoshit and Update Order ------------------- */
			SFDCAccessController.AccessibleWithoutSharing (
				'Order__c',
				'RestPaymentProcessController.cls [makeautoship]',
				new List<Schema.DescribeFieldResult> {
					Order__c.Id.getDescribe(), Order__c.Account__c.getDescribe()
				}
			);
			Order__c order = [SELECT Id, Account__c FROM  Order__c  WHERE Id =:orderId];
			String accountId = order.Account__c;
			
			SFDCAccessController.UpdateWithoutSharing (
				order,
				'RestPaymentProcessController.cls [makeautoship]',
				new List<Schema.DescribeFieldResult> {
					Order__c.Account__c.getDescribe()
				}
			);

			/* ------------------- Get and update Account detail with type as Customer and update fail order as 0 ------------------- */
			SFDCAccessController.AccessibleWithoutSharing (
				'Order__c',
				'RestPaymentProcessController.cls [makeautoship]',
				new List<Schema.DescribeFieldResult> {
					Account.Id.getDescribe(), Account.Type.getDescribe()
				}
			);
			Account acc = [SELECT Id, Type FROM Account WHERE Id =:accountId  LIMIT 1];
			acc.Type = 'Customer';
			acc.Orders_Failed__c = 0;

			SFDCAccessController.UpdateWithoutSharing (
				acc,
				'RestPaymentProcessController.cls [makeautoship]',
				new List<Schema.DescribeFieldResult> {
					Account.Type.getDescribe(), Account.Orders_Failed__c.getDescribe()
				}
			);
		} catch (SFDCAccessControlException e) { return e.ExceptionMessage; }
		return orderId;
	}

	/**
	* Close open case within 2 hours
	* String accountId - account Id
	*/
	public static String clearCase(String accountId){

		/* --------------------- Remove Last 3 character from id --------------------- */
		String aid = accountId.substring(0,15);

		/* --------------------- Prepare 2 hours before date-time and fetch 2 hours old case related to account id --------------------- */
		Datetime myDT = Datetime.now();
		DateTime earlier = myDT.addMinutes(-120);
		String payment = 'Payment';
		String unpaid = 'Unpaid Order';
		String close = 'Closed';

		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Case',
				'NewOrderProcessController.cls [getVariants]',
				new List<Schema.DescribeFieldResult> {
					Case.Id.getDescribe(), Case.Status.getDescribe()
				}
			);
			List<Case> cs = [SELECT Id, Status from Case WHERE AccountId =: aid AND CreatedDate >=: earlier AND Type =:payment AND Reason =:unpaid AND Status !=:close ];
			List<Case> caseToUpdate = new List<Case>{};

			if (cs.size() != 0) {
				/* --------------------- if 2 hours old case founded make it close --------------------- */
				for (Case c: cs) {
					c.Status = 'Closed';
					caseToUpdate.add(c);
				}
				SFDCAccessController.UpdateWithoutSharing (
					caseToUpdate,
					'NewOrderProcessController.cls [getVariants]',
					new List<Schema.DescribeFieldResult> {
						Case.Status.getDescribe()
					}
				);
			}
		} catch (SFDCAccessControlException e) { return e.ExceptionMessage; }
		return 'true';
	}

}