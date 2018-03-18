global with sharing class PaymentProcessor {
/*
	This method takes the Id of the Order or Transaction and performs payment operation on this order/transaction.
	As result of that method new Transaction record is created.

	Input keys:
	Method => (String) 'Authorize', 'Charge', 'Refund', 'Void', 'Profile'
	Upsell => (Boolean) 'true', 'false'
	PaymentOptionId => Id of TouchCR__Payment_Option__c
	OrderId => (String) Id of TouchCR__Order__c, used for 'Authorize', 'Charge', 'Profile' methods
	Transaction => (String) Id of TouchCR__Transaction__c for 'Refund', 'Void' methods
	CreditCard => Map<String,Object>
		CardType => (String)
		CardNumber => (String)
		CardCCV => (String)
		CardExpirationMonth => (String)
		CardExpirationYear => (String)

	Return keys:
	Status => (String) 'Approved', 'Declined', 'Error'
	TransactionId => (String) Id of new created transaction
	Message => (String) Response string from payment agent
*/

	global static Map<String, Object> doPayment(Map<String, Object> params) {
		Map<String, Object> data = new Map<String, Object>{
			'Method' => params.get('Method')
		};
		if (params.containsKey('Method')) {
			if (params.get('Method') == 'Refund') {
				//Search Order for Transaction
				List<Order__c> singleOrder = getOrderForVoidAndRefund((Id) params.get('Transaction'));

				params.put('CorrectCondition', singleOrder.isEmpty() ? false : true);
				if (singleOrder.isEmpty()) { return params; }

				Boolean refundApplicationFee = params.containsKey('refundApplicationFee') ? Boolean.valueOf(params.get('refundApplicationFee')) : false;
				data.put('refundApplicationFee', refundApplicationFee);
			
				Boolean reverseTransfer = params.containsKey('reverseTransfer') ? Boolean.valueOf(params.get('reverseTransfer')) : false;
				data.put('reverseTransfer', reverseTransfer);

				//get basic information
				data.putAll(getFormOfData(singleOrder[0]));
				//get data for Refund
				data.putAll(getDataFromOrderForVoidAndRefund(singleOrder[0]));
				//add Type and Key for Agent
				data.putAll(getDataForPaymentAgent(singleOrder[0].Named_Agent__c));
				//add Amount for Refund
				data.put('Amount', params.containsKey('Amount') ? params.get('Amount') : singleOrder[0].Transactions__r[0].Amount__c);

				//call PaymentGateway
				data.putAll(Test.isRunningTest() ? TEST_RESULT : new Map<String, Object>());
				params.putAll(Test.isRunningTest() ? data : PaymentGateway.doPayment(data));
			}
			if (params.get('Method') == 'Void') {
				data.put('TransactionIdForUpdate', (Id) params.get('Transaction'));
				//Search Order for Transaction
				List<Order__c> singleOrder = getOrderForVoidAndRefund((Id) params.get('Transaction'));

				params.put('CorrectCondition', singleOrder.isEmpty() ? false : true);
				if (singleOrder.isEmpty()) { return params; }

				//get basic information
				data.putAll(getFormOfData(singleOrder[0]));
				//get data for Void
				data.putAll(getDataFromOrderForVoidAndRefund(singleOrder[0]));
				//add Type and Key for Agent
				data.putAll(getDataForPaymentAgent(singleOrder[0].Named_Agent__c));
				//add Amount for Void
				data.put('Amount', params.containsKey('Amount') ? params.get('Amount') : singleOrder[0].Transactions__r[0].Amount__c);

				//call PaymentGateway
				data.putAll(Test.isRunningTest() ? TEST_RESULT : new Map<String, Object>());
				params.putAll(Test.isRunningTest() ? data : PaymentGateway.doPayment(data));
			}
			if (params.get('Method') == 'Authorization') {
				data.put('Transaction', params.get('OrderId'));
				data.put('Amount', params.get('Amount'));
				//Search Order for Transaction
				Id orderId = (Id) params.get('OrderId');
				String singleOrderQueryString = TouchCRHelper.getOrderDefaultSoqlQueryString();
				singleOrderQueryString += '(SELECT Id, Payment_Entity_Id__c, Payment_Profile__c ' +
					'FROM Order__c.Transactions__r WHERE Response_Status__c LIKE \'%Approved%\' ORDER BY Payment_Date__c DESC ), ' +
					'(SELECT Id, Amount__c FROM Order__c.Payment_Attempts__r ) ' +
					'FROM Order__c WHERE Id =: orderId LIMIT 1';
				List<Order__c> singleOrder = Database.query(singleOrderQueryString);
				
				if (singleOrder.isEmpty()) { return params; }

				//get basic information
				data.putAll(getFormOfData(singleOrder[0]));
				//add Type and Key for Agent
				data.putAll(getDataForPaymentAgent(singleOrder[0].Named_Agent__c));

				//getting card data
				Map<String, Object> creditCard = (Map<String, Object>) params.get('CreditCard');
				//if customer already exists on Gateway, then use its Id
				creditCard.put('Profile', singleOrder[0].Transactions__r.isEmpty() ? null : singleOrder[0].Transactions__r[0].Payment_Profile__c);
				data.put('CreditCard', creditCard);

				//call PaymentGateway
				data.putAll(Test.isRunningTest() ? TEST_RESULT : new Map<String, Object>());

				params.put('CorrectCondition', (Decimal) data.get('Amount') > 0 ? true : false);
				
				if ((Decimal) data.get('Amount') < 1) { return params; }
				params.putAll(Test.isRunningTest() ? data : PaymentGateway.doPayment(data));
			}
			if (params.get('Method') == 'Charge') {
				List<Order__c> singleOrder;
				//For 'Pay Now' Button from Payment Attempt
				if (params.containsKey('PaymentAttempt')) {
					Id payAttemptId = (Id) params.get('PaymentAttempt');
					String singleOrderQueryString = TouchCRHelper.getOrderDefaultSoqlQueryString();
					singleOrderQueryString += '(SELECT Id, Date__c, Amount__c ' +
						'FROM Order__c.Payment_Attempts__r ' +
						'WHERE Id =: payAttemptId AND Status__c IN (\'Scheduled\', \'Retry\') ORDER BY Date__c DESC ), ' +
						'(SELECT Id, Payment_Date__c, Payment_Entity_Id__c, Payment_Profile__c, Type__c, Amount__c ' +
						'FROM Order__c.Transactions__r WHERE Response_Status__c LIKE \'%Approved%\' ORDER BY Payment_Date__c DESC ) ' +
						'FROM Order__c WHERE Id IN (SELECT Order__c FROM Payment_Attempt__c WHERE Id =: payAttemptId ) LIMIT 1';
					singleOrder = Database.query(singleOrderQueryString);

					if (singleOrder.isEmpty() || singleOrder[0].Payment_Attempts__r.isEmpty()) { return params; }
					data.put('Amount', singleOrder[0].Payment_Attempts__r[0].Amount__c);

					//get last credit card dateil for payment from Account
					Map<String, Object> creditDataOfTransaction = (Map<String, Object>) getPaymentOptionInfoFromAccount(singleOrder[0].Account__c, singleOrder[0].Named_Agent__c);
					//get basic information
					data.putAll(getFormOfData(singleOrder[0]));
					//add Type and Key for Agent
					data.putAll(getDataForPaymentAgent(singleOrder[0].Named_Agent__c));
					//getting card data
					data.put('CreditCard', params.containsKey('CreditCard') ? (Map<String, Object>) params.get('CreditCard') : creditDataOfTransaction);		
				}
				else if (params.containsKey('Transaction')) {
					//Search Order for Transaction
					Id transactionId = (Id) params.get('Transaction');
					String singleOrderQueryString = TouchCRHelper.getOrderDefaultSoqlQueryString();
					singleOrderQueryString += '' +
						'(SELECT Id, Amount__c, Named_Agent__c, Payment_Date__c, Payment_Attempt__c, Response_Status__c, ' +
						'Type__c, Payment_Profile__c, Payment_Entity_Id__c, Payment_Transaction__c ' +
						'FROM Order__c.Transactions__r ' +
						'WHERE Id = :transactionId ) ' +
						'FROM Order__c WHERE Id IN ' +
						'(SELECT Order__c FROM Order_Transaction__c WHERE Id = :transactionId AND Response_Status__c LIKE \'%Approved%\') LIMIT 1';

					singleOrder = Database.query(singleOrderQueryString);

					if (singleOrder.isEmpty()) { return params; }

					//If Charge Tranaction (with status Authorization)
					if (singleOrder[0].Transactions__r.isEmpty() && singleOrder[0].Transactions__r[0].Type__c != 'Authorization') { return params; }
					
					data.put('TransactionIdForUpdate', singleOrder[0].Transactions__r[0].Id);
					data.put('PaymentTransaction', singleOrder[0].Transactions__r[0].Payment_Transaction__c);
					data.put('Amount', singleOrder[0].Transactions__r[0].Amount__c);
					//get basic information
					data.putAll(getFormOfData(singleOrder[0]));
					//add Type and Key for Agent
					data.putAll(getDataForPaymentAgent(singleOrder[0].Named_Agent__c));
					//getting card data
					Map<String, Object> creditCard = params.containsKey('CreditCard') ? (Map<String, Object>) params.get('CreditCard') : (Map<String, Object>) getCreditData(singleOrder[0].Transactions__r);
					data.put('CreditCard', creditCard);			
				}
				else if (params.containsKey('OrderId')) {
					//Search Order for Transaction
					Id orderId = (Id) params.get('OrderId');
					String singleOrderQueryString = TouchCRHelper.getOrderDefaultSoqlQueryString();
					singleOrderQueryString += '' +
						'(SELECT Id, Payment_Attempt__c, Payment_Entity_Id__c, Payment_Transaction__c, Payment_Profile__c, Type__c, Amount__c ' +
						'FROM Order__c.Transactions__r ' +
						'WHERE Response_Status__c LIKE \'%Approved%\' ORDER BY Payment_Date__c DESC ), ' +
						'(SELECT Id, Amount__c FROM Order__c.Payment_Attempts__r ' +
						'WHERE Status__c = \'Scheduled\' ORDER BY Date__c DESC ) ' +
						'FROM Order__c WHERE Id = : orderId LIMIT 1';
					singleOrder = Database.query(singleOrderQueryString);

					if (singleOrder.isEmpty()) { return params; }

					params.put('Transaction', params.get('OrderId'));
					//If the last Transaction was Authorization
					if (!singleOrder[0].Transactions__r.isEmpty() && singleOrder[0].Transactions__r[0].Type__c == 'Authorization') {
						data.put('TransactionIdForUpdate', singleOrder[0].Transactions__r[0].Id);
						data.put('PaymentTransaction', singleOrder[0].Transactions__r[0].Payment_Transaction__c);
						data.put('Amount', singleOrder[0].Transactions__r[0].Amount__c);
					}
					//if you have not paid Payment Attempt
					else if (singleOrder[0].Subscription__c && !singleOrder[0].Payment_Attempts__r.isEmpty()) {
						data.put('PaymentAttempt', singleOrder[0].Payment_Attempts__r[0].Id);
						data.put('Amount', singleOrder[0].Payment_Attempts__r[0].Amount__c);
					}
					else {
						data.put('Amount', params.containsKey('Amount') ? params.get('Amount') : singleOrder[0].Subscription_Remains_Amount__c);
					}

					//get basic information
					data.putAll(getFormOfData(singleOrder[0]));
					//add Type and Key for Agent
					data.putAll(getDataForPaymentAgent(singleOrder[0].Named_Agent__c));
					
					if (!data.containsKey('AgentParameters')) {
						params.put('Message', 'Payment Agent not found');
						return params;					
					}

					Map<String, String> parameters = (Map<String, String>) data.get('AgentParameters');
					if (!parameters.containsKey('gateway')) {
						params.put('Message', 'Payment Agent not found');
						return params;
					}	
					String namedAgent = parameters.get('namedAgent');

					//if contains 'Upsell' then use data from previously Order
					Boolean useUpsell = params.containsKey('Upsell') ? (Boolean) params.get('Upsell') : false;
					if (useUpsell) {
						//getting card data
						if (params.containsKey('PaymentOptionId')) {
							data.put('CreditCard', (Map<String, Object>) getPaymentOptionInfo((Id)params.get('PaymentOptionId'), namedAgent));
						} else {
							data.put('CreditCard', (Map<String, Object>) getLastPaymentProfileAndEntity(singleOrder[0].Account__c));
						}
					} else {
						//getting card data
						if (params.containsKey('PaymentOptionId')) {
							data.put('CreditCard', (Map<String, Object>) getPaymentOptionInfo((Id)params.get('PaymentOptionId'), namedAgent));
						} else {
							//if contains Credit Card details then use of the card, else use the last transaction
							data.put('CreditCard', params.containsKey('CreditCard') ? (Map<String, Object>) params.get('CreditCard') : (Map<String, Object>) getCreditData(singleOrder[0].Transactions__r));
						}
					}
				}

				//call PaymentGatewayy
				data.putAll(Test.isRunningTest() ? TEST_RESULT : new Map<String, Object>());

				params.put('CorrectCondition', (Decimal) data.get('Amount') > 0 ? true : false);

				if (params.containsKey('applicationFee') && params.containsKey('destination')) {
					data.put('applicationFee', params.get('applicationFee'));
					data.put('destination', params.get('destination'));
				}

				if ((Decimal) data.get('Amount') > 0) {
					params.putAll(Test.isRunningTest() ? data : PaymentGateway.doPayment(data));
				}
			}
		}

		try {
			if ((Boolean) params.get('CorrectCondition')) {
				if (params.get('Status') == 'Error') {
					//Create Error Log for an unsuccessful Transaction
					Log__c logRecord = new Log__c();
					logRecord.Event_Type__c = params.containsKey('Method') ? (String) params.get('Method') : null;
					logRecord.Event_Status__c = params.containsKey('Status') ? (String) params.get('Status') : null;
					logRecord.Type__c = params.containsKey('StatusCode') ? (String) params.get('StatusCode') : null;
					logRecord.Event_Description__c = params.containsKey('Endpoint') ? (String) params.get('Endpoint') : null;
					logRecord.Description__c = params.containsKey('Body') ? (String) params.get('Body') : null;
					logRecord.Action__c = params.containsKey('Message') ? (String) params.get('Message') : null;

					SFDCAccessController.InsertWithoutSharing (
						logRecord,
						'PaymentProcessor.cls [doPayment]',
						new List<Schema.DescribeFieldResult> {
							Log__c.Event_Type__c.getDescribe(), Log__c.Event_Status__c.getDescribe(),
							Log__c.Type__c.getDescribe(), Log__c.Event_Description__c.getDescribe(),
							Log__c.Description__c.getDescribe(), Log__c.Action__c.getDescribe()
						}
					);

				}

				Order_Transaction__c transactionForAll = new Order_Transaction__c();
				//For void and charge transaction (with status Authorization), we need to update an existing transaction.
				transactionForAll.Id = params.containsKey('TransactionIdForUpdate') ? (Id) params.get('TransactionIdForUpdate') : null;
				transactionForAll.Order__c = params.containsKey('OrderId') ? (Id) params.get('OrderId') : null;
				transactionForAll.Type__c = params.containsKey('Method') ? (String) params.get('Method') : null;
				transactionForAll.Currency__c = params.containsKey('CurrencyLabel') ? (String) params.get('CurrencyLabel') : null;
				transactionForAll.Amount__c = params.containsKey('Amount') ? (Decimal) params.get('Amount') : null;
				transactionForAll.Payment_Date__c = Datetime.now();
				transactionForAll.Named_Agent__c = params.containsKey('PaymentAgent') ? (String) params.get('PaymentAgent') : null;
				transactionForAll.Payment_Profile__c = params.containsKey('Customer') ? (String) params.get('Customer') : null;
				if (params.containsKey('CardId') && String.isNotEmpty(String.valueOf(params.get('CardId')))) {
					transactionForAll.Payment_Entity_Id__c = (String) params.get('CardId');
				}
				transactionForAll.Payment_Transaction__c = params.containsKey('PaymentTransaction') ? (String) params.get('PaymentTransaction') : null;
				transactionForAll.Card_Type__c = params.containsKey('Funding') ? (String) params.get('Funding') : null;
				transactionForAll.Card_Last_4__c = params.containsKey('Last4') ? (String) params.get('Last4') : null;
				transactionForAll.Payment_Response_Body__c = params.containsKey('Original') ? (String) params.get('Original') : null;
				transactionForAll.Payment_Attempt__c = params.containsKey('PaymentAttempt') ? (Id) params.get('PaymentAttempt') : null;
				transactionForAll.Subscription__c = params.containsKey('Subscription') ? (Boolean) params.get('Subscription') : false;
				transactionForAll.Response_Status__c = params.containsKey('Status') ? (String) params.get('Status') : null;
				transactionForAll.Response_Message__c = params.containsKey('Message') ? (String) params.get('Message') : null;
				transactionForAll.Payment_Method__c = 'Credit Card';

				Map<String, String> address = params.containsKey('Address') ? (Map<String, String>)params.get('Address') : new Map<String, String>();
					transactionForAll.Billing_Address__c = address.containsKey('billingAddress1') ? (String) address.get('billingAddress1') : null;
					transactionForAll.Billing_City__c = address.containsKey('billingCity') ? (String) address.get('billingCity') : null;
					transactionForAll.Billing_State__c = address.containsKey('billingState') ? (String) address.get('billingState') : null;
					transactionForAll.Billing_Country__c = address.containsKey('billingCountry') ? (String) address.get('billingCountry') : null;
					transactionForAll.Billing_Postal_Code__c = address.containsKey('billingPostalCode') ? (String) address.get('billingPostalCode') : null;
					transactionForAll.Billing_Email__c = address.containsKey('billingEmailAddress') ? (String) address.get('billingEmailAddress') : null;
					transactionForAll.Billing_First__c = address.containsKey('billingFirst') ? (String) address.get('billingFirst') : null;
					transactionForAll.Billing_Last__c = address.containsKey('billingLast') ? (String) address.get('billingLast') : null;
					transactionForAll.Billing_Phone__c = address.containsKey('billingPhone') ? (String) address.get('billingPhone') : null;
					transactionForAll.Billing_Address_Line_2__c = address.containsKey('billingAddress2') ? (String) address.get('billingAddress2') : null;
					transactionForAll.Billing_Province__c = address.containsKey('billingStateProvince') ? (String) address.get('billingStateProvince') : null;
					transactionForAll.Billing_Company__c = address.containsKey('billingCompany') ? (String) address.get('billingCompany') : null;
					transactionForAll.Billing_Fax__c = address.containsKey('billingFax') ? (String) address.get('billingFax') : null;

				//if payment failed set error value to Description
				transactionForAll.Description__c = params.containsKey('Description') ? (String) params.get('Description') : null;

				transactionForAll = (Order_Transaction__c) TouchCRHelper.setCurrencyIsoCode(transactionForAll, (String) params.get('CurrencyIso'));

				SFDCAccessController.UpsertWithoutSharing (
					transactionForAll,
					'PaymentProcessor.cls [doPayment]',
					new List<Schema.DescribeFieldResult>{
						Order_Transaction__c.Order__c.getDescribe(), Order_Transaction__c.Type__c.getDescribe(),
						Order_Transaction__c.Card_Type__c.getDescribe(), Order_Transaction__c.Response_Message__c.getDescribe(),
						Order_Transaction__c.Payment_Profile__c.getDescribe(), Order_Transaction__c.Payment_Response_Body__c.getDescribe(),
						Order_Transaction__c.Card_Last_4__c.getDescribe(), Order_Transaction__c.Payment_Date__c.getDescribe(),
						Order_Transaction__c.Named_Agent__c.getDescribe(), Order_Transaction__c.Response_Status__c.getDescribe(),
						Order_Transaction__c.Payment_Entity_Id__c.getDescribe(), Order_Transaction__c.Payment_Method__c.getDescribe(),
						Order_Transaction__c.Currency__c.getDescribe(), Order_Transaction__c.Amount__c.getDescribe(),
						Order_Transaction__c.Billing_Address__c.getDescribe(), Order_Transaction__c.Billing_City__c.getDescribe(),
						Order_Transaction__c.Billing_State__c.getDescribe(), Order_Transaction__c.Billing_Postal_Code__c.getDescribe(),
						Order_Transaction__c.Billing_Country__c.getDescribe(), Order_Transaction__c.Billing_Email__c.getDescribe(),
						Order_Transaction__c.Billing_First__c.getDescribe(), Order_Transaction__c.Billing_Last__c.getDescribe(),
						Order_Transaction__c.Payment_Attempt__c.getDescribe(), Order_Transaction__c.Payment_Transaction__c.getDescribe(),
						Order_Transaction__c.Subscription__c.getDescribe(), Order_Transaction__c.Description__c.getDescribe(),
						Order_Transaction__c.Billing_Phone__c.getDescribe()
					}
				);
				params.put('Transaction', transactionForAll.Id);
			}
		} catch (SFDCAccessControlException e) { return new Map<String, Object>{'Exception' => e.ExceptionMessage}; }
		return params;
	}

	public static Map<String, Object> getFormOfData(Order__c singleOrder) {
		return new Map<String, Object>{
			'OrderId' => singleOrder.Id,
			'Subscription' => singleOrder.Subscription__c,
			'PaymentAgent' => singleOrder.Named_Agent__c,
			'CurrencyIso' => TouchCRHelper.getCurrencyIsoCode(singleOrder),
			'CurrencyLabel' => TouchCRHelper.getCurrencyLabel(singleOrder),
			'customerIp' => singleOrder.Customer_IP__c,
			'Address' => new Map<String, String>{
				//Billing
				'billingAddress1' => singleOrder.Billing_Address__c,
				'billingAddress2' => singleOrder.Billing_Address_Line_2__c,
				'billingCity' => singleOrder.Billing_City__c,
				'billingState' => singleOrder.Billing_State__c,
				'billingStateProvince' => singleOrder.Billing_State_Province__c,
				'billingCompany' => singleOrder.Billing_Company__c,
				'billingCountry' => singleOrder.Billing_Country__c,
				'billingPostalCode' => singleOrder.Billing_Zip_Postal__c,
				'billingEmailAddress' => singleOrder.Account__r.PersonEmail,
				'email' => singleOrder.Account__r.PersonEmail,
				'billingFirst' => singleOrder.Account__r.FirstName,
				'billingLast' => singleOrder.Account__r.LastName,
				'billingPhone' => singleOrder.Account__r.Phone,
				'billingFax' => singleOrder.Billing_Fax__c,
				//Shipping
				'shippingAddress1' => singleOrder.Shipping_Address__c,
				'shippingCity' => singleOrder.Shipping_City__c,
				'shippingState' => singleOrder.Shipping_State__c,
				'shippingCountry' => singleOrder.Shipping_Country__c,
				'shippingPostalCode' => singleOrder.Shipping_Zip_Postal__c,
				'shippingFirstName' => singleOrder.Account__r.FirstName,
				'shippingLastName' => singleOrder.Account__r.LastName,
				'shippingPhone' => singleOrder.Account__r.Phone
			}
		};
	}

	//getting the CardId and Profile of the last Transaction
	public static Map<String, Object> getCreditData(List<Order_Transaction__c> orderTransactions) {
		return orderTransactions.isEmpty() ? new Map<String, Object>() : new Map<String, Object>{
			'CardId' => orderTransactions[0].Payment_Entity_Id__c,
			'Profile' => orderTransactions[0].Payment_Profile__c
		};
	}

	//getting data for Void and Refund
	public static Map<String, Object> getDataFromOrderForVoidAndRefund(Order__c singleOrder) {
		return new Map<String, Object>{
			'PaymentTransaction' => singleOrder.Transactions__r[0].Payment_Transaction__c,
			'PaymentAttempt' => singleOrder.Transactions__r[0].Payment_Attempt__c,
			'CreditCard' => getCreditData(singleOrder.Transactions__r)
		};
	}

	//finding information from PaymentAgent
	public static Map<String, Object> getDataForPaymentAgent(String namedAgent) {
		Payment_Agents__c usedPaymentAgent = PaymentAgentController.getPaymentAgent(namedAgent);
		if (usedPaymentAgent == null) {
			return new Map<String, Object>();
		}
		else {
			return new Map<String, Object>{
				'AgentParameters' => new Map<String, String>{
					'gateway' => usedPaymentAgent.Type__c,
					'namedAgent' => usedPaymentAgent.Name,
					'securityKeySecret' => String.valueOf(usedPaymentAgent.Security_Key__c),
					'securityKeyId' => String.valueOf(usedPaymentAgent.Merchant_ID__c),
					'testMode' => String.valueOf(usedPaymentAgent.Test_Endpoint__c)
				}
			};
		}
	}

	//for upsell
	public static Map<String, Object> getLastPaymentProfileAndEntity(String idAccount) {
		List<Order_Transaction__c> transactions = [
			SELECT Id, Payment_Profile__c, Payment_Entity_Id__c, Payment_Transaction__c
			FROM Order_Transaction__c
			WHERE Order__r.Account__c = :idAccount
			AND Response_Status__c LIKE '%Approved%'
			AND Type__c = 'Charge' 
			ORDER BY CreatedDate DESC
		];
		return transactions.isEmpty() ? new Map<String, Object>() : getCreditData(transactions);
	}

	//use Payment Options for upsell
	public static Map<String, Object> getPaymentOptionInfo(Id paymentOptionId, String namedAgent) {
		List<Payment_Option__c> paymentOptions = [
			SELECT Id, Profile_Id__c, Option_Id__c
			FROM Payment_Option__c
			WHERE Status__c = 'Active'
			AND Id =: paymentOptionId
			AND Named_Agent__c =: namedAgent
		];

		return paymentOptions.isEmpty() ? new Map<String, Object>() : new Map<String, Object>{
			'CardId' => paymentOptions[0].Option_Id__c,
			'Profile' => paymentOptions[0].Profile_Id__c
		};
	}

	public static Map<String, Object> getPaymentOptionInfoFromAccount(String accId, String namedAgent) {
		List<Payment_Option__c> paymentOptions = [
			SELECT Id, Profile_Id__c, Option_Id__c
			FROM Payment_Option__c
			WHERE Status__c = 'Active'
			AND Account__c =: accId
			AND Named_Agent__c =: namedAgent
			ORDER BY CreatedDate DESC
		];

		return paymentOptions.isEmpty() ? new Map<String, Object>() : new Map<String, Object>{
			'CardId' => paymentOptions[0].Option_Id__c,
			'Profile' => paymentOptions[0].Profile_Id__c
		};
	}

	public static List<Order__c> getOrderForVoidAndRefund(Id idTransaction) {
		Set<String> availableTypes = new Set<String>{'Charge', 'Authorization'};
		String singleOrderQueryString = TouchCRHelper.getOrderDefaultSoqlQueryString();
		singleOrderQueryString += '' +
			'(SELECT Id, Amount__c, Named_Agent__c, Payment_Date__c, Payment_Attempt__c, Response_Status__c, Type__c, ' +
			'Payment_Profile__c, Payment_Entity_Id__c, Payment_Transaction__c ' +
			'FROM Order__c.Transactions__r WHERE Id = :idTransaction ) ' +
			'FROM Order__c WHERE Id IN ' +
			'(SELECT Order__c FROM Order_Transaction__c ' +
			'WHERE Id = :idTransaction AND Response_Status__c LIKE \'%Approved%\' AND Type__c IN: availableTypes) LIMIT 1';
		return Database.query(singleOrderQueryString);
	}

	public static Map<String, Object> TEST_RESULT = new Map<String, Object>{
		'Status' => 'Approved', 'Message' => 'Your transaction has been approved.', 'Original' => '',
		'Last4' => '4242', 'Brand' => 'Visa', 'CardId' => 'card_19hzHQCF2TV51fDnRorIVCi8',
		'Customer' => 'cus_A23OutzDURWZii', 'Funding' => 'credit', 'PaymentAgent' => 'TouchCR Agent'
	};

	//use token
	public static final Map<String, Boolean> PAYMENT_AGENTS_USE_TOKEN = new Map<String, Boolean>{
		'Stripe' => true,
		'Authorize.Net' => true,
		'Moneris' => true
	};

}