public with sharing class RestChargeUpsellController {

	public static String chargeUpsell(String payment_frequency, String payment_status, String payment_start, String chargeDate, String orderId){
		if(Test.isRunningTest()){
			return 'true';
		} else {
			Map<String,Object> result = PaymentProcessor.doPayment(
				new Map<String,Object>{
					'Method' => 'Charge',
					'OrderId' => orderId,
					'Upsell' => true
				}
			);
			if (result.get('Status') != 'Approved') {
				return 'false';
			}else {
				return updateOrder(orderId);
			}
		}
	}

	public static String chargeUpsellV2(Map<String, String> inputDataMap) {
		try{
			//The map where all returned values are stored
			Map<String, Object> resultMap = new Map<String, Object>();
			System.debug('rest chargeUpsellV2 map');

			if (!inputDataMap.containsKey('orderId')) { 
				return JSON.serialize(new Map<String, String>{
					'Status' => 'Error',
					'Result' => 'Order Id was not found'
				});
			}

			Id orderId = Id.valueOf(inputDataMap.get('orderId'));

			Map<String, Object> chargeUpsellData = new Map<String, Object>{
					'Method' => 'Charge',
					'Upsell' => true,
				'OrderId' => orderId
			};

			Id paymentOptionId = inputDataMap.containsKey('PaymentOptionId') ? Id.valueOf(inputDataMap.get('PaymentOptionId')) : null;
			if (paymentOptionId != null) { chargeUpsellData.put('PaymentOptionId', paymentOptionId); }

			String applicationFee = inputDataMap.containsKey('applicationFee') ? inputDataMap.get('applicationFee') : null;
			if (applicationFee != null) { chargeUpsellData.put('applicationFee', applicationFee); }

			String destination = inputDataMap.containsKey('destination') ? inputDataMap.get('destination') : null;
			if (destination != null) { chargeUpsellData.put('destination', destination); }

			Map<String, Object> result = PaymentProcessor.doPayment(chargeUpsellData);

			if (result.get('Status') == 'Approved') { 
				resultMap.put('Status', 'Success');
				resultMap.put('Result', updateOrder(orderId));
			} else {
				resultMap.put('Status', 'Error');
				resultMap.put('Result', false);
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
				'RestChargeUpsellController.cls [updateOrder]',
				new List<Schema.DescribeFieldResult> {
					Order__c.Id.getDescribe(), Order__c.Account__c.getDescribe()
				}
			);

			Order__c order = [SELECT Id, Account__c FROM Order__c WHERE Id =:orderId];
			order.Payment_Received__c = 'Full';
			order.Status__c = 'Initiated';
			String accountId = order.Account__c;

			SFDCAccessController.UpdateWithoutSharing (
				order,
				'RestChargeUpsellController.cls [updateOrder]',
				new List<Schema.DescribeFieldResult> {
					Order__c.Account__c.getDescribe(), Order__c.Payment_Received__c.getDescribe(),
					Order__c.Status__c.getDescribe()
				}
			);
		} catch (SFDCAccessControlException e) { return e.ExceptionMessage; }
		makeautoship(orderId);
		return 'true';
	}


	/**
	* Create New Unpaid case
	*/
	public static String unpaidCase(String orderId){
		String accountId;
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Order__c',
				'RestChargeUpsellController.cls [unpaidCase]',
				new List<Schema.DescribeFieldResult> {
					Order__c.Id.getDescribe(), Order__c.Account__c.getDescribe()
				}
			);

			Order__c order = [SELECT Id, Account__c FROM  Order__c  WHERE Id =:orderId];
			accountId = order.Account__c;

			order.Payment_Received__c = 'None';
			order.Status__c = 'Error';

			SFDCAccessController.UpdateWithoutSharing (
				order,
				'RestChargeUpsellController.cls [unpaidCase]',
				new List<Schema.DescribeFieldResult> {
					Order__c.Account__c.getDescribe(), Order__c.Payment_Received__c.getDescribe(),
					Order__c.Status__c.getDescribe()
				}
			);
		} catch (SFDCAccessControlException e) { return e.ExceptionMessage; }

		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Contact',
				'RestChargeUpsellController.cls [unpaidCase]',
				new List<Schema.DescribeFieldResult> {
					Contact.Id.getDescribe()
				}
			);

			List<Contact> contacts = [SELECT Id from Contact WHERE AccountId =:accountId];

			Case cs = new Case();
			cs.AccountId = accountId;
			cs.Order__c = orderId;
			cs.Subject = 'Card was declined.';

			if(!contacts.isEmpty()){
				cs.ContactId = contacts[0].Id;
			}

			cs.Status = 'New';
			cs.Origin = 'Phone';
			cs.Type = 'Payment';
			cs.Reason = 'Unpaid Order';

			SFDCAccessController.InsertWithoutSharing (
				cs,
				'RestChargeUpsellController.cls [unpaidCase]',
				new List<Schema.DescribeFieldResult> {
					Case.AccountId.getDescribe(), Case.Order__c.getDescribe(),
					Case.Subject.getDescribe(), Case.ContactId.getDescribe(),
					Case.Status.getDescribe(), Case.Origin.getDescribe(),
					Case.Type.getDescribe(), Case.Reason.getDescribe()
				}
			);
		} catch (SFDCAccessControlException e) { return e.ExceptionMessage; }

		/* ------------------- Update Fail order count ------------------- */
		// CRUD and FLS Enforcement
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Account',
				'RestChargeUpsellController.cls [unpaidCase]',
				new List<Schema.DescribeFieldResult> {
					Account.Id.getDescribe(), Account.Orders_Failed__c.getDescribe()
				}
			);

			Account acc = [SELECT Id, Orders_Failed__c FROM Account WHERE Id =:accountId ];
			if (acc.Orders_Failed__c == null) {
				acc.Orders_Failed__c = 1;
			} else {
				acc.Orders_Failed__c = acc.Orders_Failed__c + 1;
			}

			SFDCAccessController.UpdateWithoutSharing (
				acc,
				'RestChargeUpsellController.cls [unpaidCase]',
				new List<Schema.DescribeFieldResult> {
					Account.Orders_Failed__c.getDescribe()
				}
			);
		} catch (SFDCAccessControlException e) { return e.ExceptionMessage; }
		return 'false';
	}


	public static void makeautoship(String orderId) {
		String accountId;
		/* ------------------- Make autoshit and Update Order ------------------- */
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Order__c',
				'RestChargeUpsellController.cls [makeautoship]',
				new List<Schema.DescribeFieldResult> {
					Order__c.Id.getDescribe(), Order__c.Account__c.getDescribe()
				}
			);

			Order__c order = [SELECT Id, Account__c FROM Order__c WHERE Id =:orderId];
			accountId = order.Account__c;

			SFDCAccessController.UpdateWithoutSharing (
				order,
				'RestChargeUpsellController.cls [makeautoship]',
				new List<Schema.DescribeFieldResult> {
					Order__c.Account__c.getDescribe()
				}
			);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

		/* ------------------- Get and update Account detail with type as Customer and update fail order as 0 ------------------- */
		// CRUD and FLS Enforcement
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Account',
				'RestChargeUpsellController.cls [makeautoship]',
				new List<Schema.DescribeFieldResult> {
					Account.Id.getDescribe(), Account.Type.getDescribe()
				}
			);

			Account acc = [SELECT Id, Type FROM Account WHERE Id =:accountId];
			acc.Type = 'Customer';
			acc.Orders_Failed__c = 0;

			SFDCAccessController.UpdateWithoutSharing (
				acc,
				'RestChargeUpsellController.cls [makeautoship]',
				new List<Schema.DescribeFieldResult> {
					Account.Orders_Failed__c.getDescribe(), Account.Type.getDescribe()
				}
			);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

}