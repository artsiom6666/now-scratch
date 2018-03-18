public with sharing class RestPaypalStatusController {

	public static void updatePaypalStatus(String orderId, String status, String data) {

		/* Check for any fraud history with maxmind API */
		// Proxy
		TouchCR_Settings__c proxySettings = TouchCR_Settings__c.getValues('Proxy.isEnabled');
		Boolean isProxyEnabled = false;
		if (proxySettings != null) {
			isProxyEnabled = Boolean.valueOf(proxySettings.Value__c);
		}
		RestFraudDetectionController fraudDetection = new RestFraudDetectionController();
		Decimal fraudStatus = fraudDetection.get_Fraud_Detection(orderId);

		/* Get Fraud detection settings */
		Integer firstRating = Integer.valueOf(TouchCR_Settings__c.getValues('MinFraud.RatingFirst').value__c);
		Integer secondRating = Integer.valueOf(TouchCR_Settings__c.getValues('MinFraud.RatingSecond').value__c);

		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Order__c',
				'RestPaypalStatusController.cls [updatePaypalStatus]',
				new List<Schema.DescribeFieldResult>{
					Order__c.Id.getDescribe(), Order__c.Account__c.getDescribe(),
					Order__c.Minfraud_Score__c.getDescribe()
				}
			);
			Order__c order = [SELECT Id, Account__c, Minfraud_Score__c, Account__r.Brand_Assortment__c FROM Order__c WHERE Id = :orderId];
			order.Minfraud_Score__c = fraudStatus;

			String accountId = order.Account__c;
			String accountBrand = order.Account__r.Brand_Assortment__c;

			SFDCAccessController.UpdateWithoutSharing (
				order,
				'RestPaypalStatusController.cls [updatePaypalStatus]',
				new List<Schema.DescribeFieldResult>{
					Order__c.Account__c.getDescribe(), Order__c.Minfraud_Score__c.getDescribe()
				}
			);
			/* if paypal payment successfully processed */
			if (status == 'paid') {

				/* create a case if user's fraud score greater  than 30 */
				if (fraudStatus > firstRating) {//change here

					Case caseRecord = new Case(
						Priority = 'Medium',
						Order__c = orderId,
						Status = 'New',
						Origin = 'Web',
						Type = 'Payment',
						Reason_Case__c = 'Fraud Review'
					);
				}

				SFDCAccessController.AccessibleWithoutSharing (
					'Order__c',
					'RestPaypalStatusController.cls [updatePaypalStatus]',
					new List<Schema.DescribeFieldResult>{
						Order__c.Id.getDescribe(), Order__c.Total__c.getDescribe(),
						Order__c.Billing_Address__c.getDescribe(), Order__c.Billing_City__c.getDescribe(),
						Order__c.Paypal_Token__c.getDescribe(),
						Order__c.Billing_State__c.getDescribe(), Order__c.Billing_Zip_Postal__c.getDescribe()
					}
				);

				/* Update Order status */
				List<Order__c> orders = [
					SELECT Id, Total__c,
						Billing_Address__c, Billing_City__c, Billing_State__c,
						Billing_Zip_Postal__c, Paypal_Token__c
					FROM Order__c
					WHERE Id = :orderId
				];

				if (orders.size() > 0) {
					Order__c singleOrder = orders[0];
					singleOrder.Payment_Received__c = 'Full';
					singleOrder.Status__c = 'Initiated';

					SFDCAccessController.UpdateWithoutSharing (
						singleOrder,
						'RestPaypalStatusController.cls [updatePaypalStatus]',
						new List<Schema.DescribeFieldResult>{
							Order__c.Payment_Received__c.getDescribe(), Order__c.Status__c.getDescribe()
						}
					);

					/* Add transection for paypal order */
					Order_Transaction__c transection = new Order_Transaction__c(
						Order__c = singleOrder.Id, Type__c = 'Charge', Response_Status__c = 'Approved',
						Amount__c = singleOrder.Total__c, Billing_Address__c = singleOrder.Billing_Address__c,
						Billing_City__c = singleOrder.Billing_City__c, Payment_Date__c = Datetime.now(),
						Billing_State__c = singleOrder.Billing_State__c,
						Billing_Postal_Code__c = singleOrder.Billing_Zip_Postal__c
					);
					Boolean isPaypalOrder = (String.isNotBlank(singleOrder.Paypal_Token__c));

					//Payment_Method__c = 'Credit Card', Currency__c = 'US Dollars',
					transection.Payment_Method__c = (isPaypalOrder) ? 'Paypal' : 'Credit Card';
					transection.Currency__c = (isPaypalOrder) ? TouchCRHelper.getSettings('Paypal.currencyCodeType').get('Paypal.currencyCodeType') : 'US Dollars';
					transection.Named_Agent__c = (isPaypalOrder) ? 'Paypal' : null;

					SFDCAccessController.InsertWithoutSharing (
						transection,
						'RestPaypalStatusController.cls [updatePaypalStatus]',
						new List<Schema.DescribeFieldResult>{
							Order_Transaction__c.Order__c.getDescribe(), Order_Transaction__c.Type__c.getDescribe(),
							Order_Transaction__c.Response_Status__c.getDescribe(), Order_Transaction__c.Payment_Method__c.getDescribe(),
							Order_Transaction__c.Currency__c.getDescribe(), Order_Transaction__c.Amount__c.getDescribe(),
							Order_Transaction__c.Billing_Address__c.getDescribe(), Order_Transaction__c.Billing_City__c.getDescribe(),
							Order_Transaction__c.Billing_State__c.getDescribe(), Order_Transaction__c.Billing_Postal_Code__c.getDescribe()
						}
					);
				}
			}
			else if (status == 'pp2cc') {
				// if brand does not set in data var, which is coming from apex rest, use account brand
				String brandToSet = (data == null) ? accountBrand : data;
				updateOrderAgentAccordingToBrandSettings(orderId, brandToSet);
			}
			else {
				/* if paypal payment not processed */
				SFDCAccessController.AccessibleWithoutSharing (
					'Order__c',
					'RestPaypalStatusController.cls [updatePaypalStatus]',
					new List<Schema.DescribeFieldResult>{
						Order__c.Id.getDescribe()
					}
				);
				Order__c cOrder = [SELECT Id FROM Order__c WHERE Id = :orderId];

				SFDCAccessController.DeleteWithoutSharing (
					cOrder,
					'RestPaypalStatusController.cls [updatePaypalStatus]'
				);

				/* fraudStatus is greater than 75 */
				if (fraudStatus > secondRating) {
					SFDCAccessController.AccessibleWithoutSharing (
						'Order__c',
						'RestPaypalStatusController.cls [updatePaypalStatus]',
						new List<Schema.DescribeFieldResult>{
							Account.Id.getDescribe(), Account.Blacklist__c.getDescribe()
						}
					);
					Account accToUpd = [SELECT Id, Blacklist__c FROM Account WHERE Id = :accountId];
					accToUpd.Blacklist__c = 'True';

					SFDCAccessController.UpdateWithoutSharing (
						accToUpd,
						'RestPaypalStatusController.cls [updatePaypalStatus]',
						new List<Schema.DescribeFieldResult>{
							Account.Blacklist__c.getDescribe()
						}
					);
				}
			}
		}
		catch (Exception e) {
			throw new SFDCAccessControlException(e.getMessage());
		}
	}

	private static void updateOrderAgentAccordingToBrandSettings(String aOrderId, String aBrand) {
		Map<String, String> brandToGateway = TouchCRConfigurationController.collectionBrandToGateway();
		String newAgentForOrder = PaymentAgentController.idToNameParamAgents(brandToGateway.get(aBrand));
		Database.update(new Order__c(
			Id = aOrderId,
			Named_Agent__c = newAgentForOrder,
			Payment_Method__c = 'Credit Card'
		), false);
	}

	//call from RestCallsV2
	public static String updatePaypalStatus(Map<String, String> generalData) {
		try {
			String orderId = generalData.containsKey('orderId') ? generalData.get('orderId') : null;
			String status = generalData.containsKey('status') ? generalData.get('status') : null;
			String data = generalData.containsKey('data') ? generalData.get('data') : null;
			updatePaypalStatus (orderId, status, data);
		} catch (Exception e) { return '{"error":"' + e.getMessage() + '","message":"error"}'; }
		return '{"message":"success"}';

	}

}