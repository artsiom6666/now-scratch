trigger TransactionTrigger on Order_Transaction__c (after update, after insert) {

	Set<Id> TransactionsIds = new Set<Id>();
	for (Order_Transaction__c tr : Trigger.new) {
		TransactionsIds.add(tr.Order__c);
	}
	List<Order_Transaction__c> transactions = [
		SELECT Id, Order__c, Response_Status__c
		FROM Order_Transaction__c
		WHERE Order__c IN :TransactionsIds
	];
	Set<Id> orderId = new Set<Id>();
	for (Order_Transaction__c ids : transactions ) {
		orderId.add(ids.Order__c);
	}
	List<Order__c> Orders = [
		SELECT Id, Account__c
		FROM Order__c
		WHERE Id iN : orderId
	];
	Integer Alltransactions = [
		SELECT count()
		FROM Order_Transaction__c
		WHERE Order__c IN: orderId
		AND (
			Response_Status__c = 'refund'
			OR Response_Status__c = 'failed'
		)
	];
	Set<Id> accId = new Set<Id>();
	for (Order__c ids : Orders ) {
		accId.add(Ids.Account__c);
	}

	List<Account> accList = [SELECT Id, Blacklist__c FROM Account WHERE Id IN : accId];

	List<Order__c> ordersToUpdate = new List<Order__c>();

	Set<Id> setAcc = new Set<Id>();
	List<Account> ListAcc = new List<Account>();

	for (Order_Transaction__c trans: transactions) {
		if ('charge back'.equalsIgnoreCase(trans.Response_Status__c)) {
			for (Order__c orderList: Orders) {
				if (orderList.Id == trans.Order__c) {
					ordersToUpdate.add(orderList);
				}
			}
		}

		if ('refund'.equalsIgnoreCase(trans.Response_Status__c) ||
			'failed'.equalsIgnoreCase(trans.Response_Status__c)) {

			for(Order__c orderList: Orders) {
				if (orderList.Id == trans.Order__c && Alltransactions > 2) {
					ordersToUpdate.add(orderList);
				}
			}
		}
	}

	for (Order__c orderTo : ordersToUpdate) {
		for(Account a : accList) {
			if(a.Id == orderTo.Account__c) {
				a.Blacklist__c = 'True';
				if (setAcc.add(a.Id)) {
					ListAcc.add(a);
				}
			}
		}
	}

	if (!ListAcc.isEmpty()) {
		update ListAcc;
	}

	Set<Id> transactionsToPaymentAttempts = new Set<Id>();
	Set<Id> transactionsError = new Set<Id>();
	Set<Id> transactionsApproved = new Set<Id>();

	Set<Id> ordersId = new Set<Id>();
	Set<Id> accountsId = new Set<Id>();

	Map<Id, Id> orderIdToAccountId = new Map<Id, Id>();

	if (Trigger.isAfter && Trigger.isInsert) {
		for (Order_Transaction__c orderTransaction : Trigger.new) {
			if (orderTransaction.Payment_Attempt__c != null && orderTransaction.Subscription__c == true) {
				transactionsToPaymentAttempts.add(orderTransaction.Payment_Attempt__c);
				if (orderTransaction.Response_Status__c == 'Error') {
					transactionsError.add(orderTransaction.Payment_Attempt__c);
				}
				if (orderTransaction.Response_Status__c == 'Approved') {
					transactionsApproved.add(orderTransaction.Payment_Attempt__c);
				}
			}

			ordersId.add(orderTransaction.Order__c);
		}

		List<Order__c> orders = [
			SELECT Id, Account__c
			FROM Order__c
			WHERE Id IN: ordersId
		];

		for (Order__c orderItem : orders) {
			accountsId.add(orderItem.Account__c);
			orderIdToAccountId.put(orderItem.Id, orderItem.Account__c);
		}

		List<Payment_Option__c> paymentOptions = [
			SELECT Id, Name, Option_Id__c, Status__c, Last_4__c, Account__c, Named_Agent__c
			FROM Payment_Option__c
			WHERE Account__c IN: accountsId
		];

		Map<Id, Map<String, Map<String, Payment_Option__c>>> accountIdToGatewayNameOfPaymentOptions = new Map<Id, Map<String, Map<String, Payment_Option__c>>>();

		//get all the information about Payment Options, Named Agents and the Last 4
		for (Payment_Option__c paymentOption : paymentOptions) {
			if (accountIdToGatewayNameOfPaymentOptions.containsKey(paymentOption.Account__c)) {
				Map<String, Map<String, Payment_Option__c>> gatewayToLast4 = accountIdToGatewayNameOfPaymentOptions.get(paymentOption.Account__c);
				if (gatewayToLast4.containsKey(paymentOption.Named_Agent__c)) {
					Map<String, Payment_Option__c> last4ToPaymentOption = gatewayToLast4.get(paymentOption.Named_Agent__c);
					last4ToPaymentOption.put(paymentOption.Last_4__c, paymentOption);
				} else {
					gatewayToLast4.put(paymentOption.Named_Agent__c, new Map<String, Payment_Option__c>{paymentOption.Last_4__c => paymentOption});
				}
			} else {
				accountIdToGatewayNameOfPaymentOptions.put(paymentOption.Account__c, new Map<String, Map<String, Payment_Option__c>>{paymentOption.Named_Agent__c => new Map<String, Payment_Option__c>{paymentOption.Last_4__c => paymentOption}});
			}
		}

		List<Payment_Option__c> newPaymentOptions = new List<Payment_Option__c>();

		for (Order_Transaction__c orderTransaction : Trigger.new) {
			//create Payment Option only if Transactions that have Last 4 and Named Agent
			if (String.isNotEmpty(orderTransaction.Card_Last_4__c) && String.isNotEmpty(orderTransaction.Named_Agent__c)) {
				Id accountId = orderIdToAccountId.get(orderTransaction.Order__c);
				if (accountIdToGatewayNameOfPaymentOptions.containsKey(accountId)) {
					Map<String, Map<String, Payment_Option__c>> gatewayNameToLast4 = accountIdToGatewayNameOfPaymentOptions.get(accountId);
					if (gatewayNameToLast4.containsKey(orderTransaction.Named_Agent__c)) {
						Map<String, Payment_Option__c> last4ToPaymentOption = gatewayNameToLast4.get(orderTransaction.Named_Agent__c);
						if (last4ToPaymentOption.containsKey(orderTransaction.Card_Last_4__c)) {
							//if Payment Option for this Named Agent and Last 4 already exists - update it
							Payment_Option__c newPaymentOption = last4ToPaymentOption.get(orderTransaction.Card_Last_4__c);
							newPaymentOption.Option_Id__c = String.isNotEmpty(orderTransaction.Payment_Entity_Id__c) ? orderTransaction.Payment_Entity_Id__c : newPaymentOption.Option_Id__c;
							newPaymentOption.Profile_Id__c = String.isNotEmpty(orderTransaction.Payment_Profile__c) ? orderTransaction.Payment_Profile__c : newPaymentOption.Profile_Id__c;
							newPaymentOption.Status__c = (orderTransaction.Response_Status__c == 'Approved') ? 'Active' : 'Inactive';
							newPaymentOption.Named_Agent__c = orderTransaction.Named_Agent__c;
							newPaymentOptions.add(newPaymentOption);
						} else {
							//create Payment Option with the new Last 4
							Payment_Option__c newPaymentOption = new Payment_Option__c(
								Account__c = accountId,
								Option_Id__c = orderTransaction.Payment_Entity_Id__c,
								Profile_Id__c = orderTransaction.Payment_Profile__c,
								Named_Agent__c = orderTransaction.Named_Agent__c,
								Status__c = (orderTransaction.Response_Status__c == 'Approved') ? 'Active' : 'Inactive',
								Last_4__c = orderTransaction.Card_Last_4__c
							);
							newPaymentOptions.add(newPaymentOption);
						}
					} else {
						//create Payment Option with the new Named Agent and Last 4
						Payment_Option__c newPaymentOption = new Payment_Option__c(
							Account__c = accountId,
							Option_Id__c = orderTransaction.Payment_Entity_Id__c,
							Profile_Id__c = orderTransaction.Payment_Profile__c,
							Named_Agent__c = orderTransaction.Named_Agent__c,
							Status__c = (orderTransaction.Response_Status__c == 'Approved') ? 'Active' : 'Inactive',
							Last_4__c = orderTransaction.Card_Last_4__c
						);
						newPaymentOptions.add(newPaymentOption);
					}
				} else {
					//create Payment Option with the new Named Agent and Last 4
					Payment_Option__c newPaymentOption = new Payment_Option__c(
						Account__c = accountId,
						Option_Id__c = orderTransaction.Payment_Entity_Id__c,
						Profile_Id__c = orderTransaction.Payment_Profile__c,
						Named_Agent__c = orderTransaction.Named_Agent__c,
						Status__c = (orderTransaction.Response_Status__c == 'Approved') ? 'Active' : 'Inactive',
						Last_4__c = orderTransaction.Card_Last_4__c
					);
					newPaymentOptions.add(newPaymentOption);
				}
			}
		}

		if (!newPaymentOptions.isEmpty()) {
			upsert newPaymentOptions;
		}

		List<Order__c> ordersForUpdated = new List<Order__c>();
		List<Payment_Attempt__c> paymentAttemptsReadyToPayment = new List<Payment_Attempt__c>();

		for (Payment_Attempt__c pA : [SELECT Id, Order__c, Amount__c, Order__r.Shipping_On__c, Order__r.Subscription_Remains_Amount__c, Order__r.Shipping_Status__c, Ready_To_Payment__c, Status__c, Remaining_Retries__c FROM Payment_Attempt__c WHERE Id IN: transactionsToPaymentAttempts]) {
			if (transactionsError.contains(pA.Id)) {
				if (pA.Remaining_Retries__c == 0) {
					pA.Status__c = 'Error';
					ordersForUpdated.add(new Order__c(
						Id = pA.Order__c, Status__c = 'Error'
					));
				}
				else if (pA.Remaining_Retries__c >= 1) {
					pA.Status__c = 'Retry';
					pA.Remaining_Retries__c = pA.Remaining_Retries__c - 1;
				}
			}
			if (transactionsApproved.contains(pA.Id)) {
				pA.Status__c = 'Completed';
				if (pA.Order__r.Shipping_On__c == 'First') {
					if (pA.Order__r.Shipping_Status__c == 'Not Ready') {
						ordersForUpdated.add(new Order__c(
							Id = pA.Order__c, Shipping_Status__c = 'Ready for Shipping'
						));
					}
				}
				else if (pA.Order__r.Shipping_On__c == 'Full Payment') {
					if (pa.Order__r.Subscription_Remains_Amount__c - pA.Amount__c == 0) {
						ordersForUpdated.add(new Order__c(
							Id = pA.Order__c, Shipping_Status__c = 'Ready for Shipping'
						));
					}
				}
			}
			if (pA.Ready_To_Payment__c == false) {
				pA.Ready_To_Payment__c = true;
			}
			paymentAttemptsReadyToPayment.add(pA);
		}

		if (!paymentAttemptsReadyToPayment.isEmpty()) {
			update paymentAttemptsReadyToPayment;
		}
		if (!ordersForUpdated.isEmpty()) {
			update ordersForUpdated;
		}
	}

}