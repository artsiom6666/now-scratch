public with sharing class RestOrderController {

	//Call the setOrders method from the core package
	public static String setOrder(Map<String, String> generalData,  RestHelper.DataForOrderItems dataForOrderItems) {

		try {
			Id accountId = generalData.containsKey('accountId') ? Id.valueOf(generalData.get('accountId')) : null;
			//verification of input data
			if (accountId == null) {
				return '{"error":"Account Id was not found","message":"error"}';
			}

			String shippingPostalCode = generalData.containsKey('shippingPostalCode') ? generalData.get('shippingPostalCode') : null;
			String shippingStreet = generalData.containsKey('shippingStreet') ? generalData.get('shippingStreet') : null;
			String shippingCity = generalData.containsKey('shippingCity') ? generalData.get('shippingCity') : null;
			String shippingState = generalData.containsKey('shippingState') ? generalData.get('shippingState') : null;
			String shippingStateCode = generalData.containsKey('shippingStateCode') ? generalData.get('shippingStateCode') : null;
			String shippingCountry = generalData.containsKey('shippingCountry') ? generalData.get('shippingCountry') : null;
			String shippingCountryCode = generalData.containsKey('shippingCountryCode') ? generalData.get('shippingCountryCode') : null;

			//Getting information from an existing Account
			String codeFields = TouchCRHelper.isSCPEnabled() == TRUE ? ' BillingStateCode, ShippingStateCode, BillingCountryCode, ShippingCountryCode, ' : '';

			String query = 'SELECT Id, LastName, FirstName, BillingStreet, BillingCity, ' + codeFields +
					'BillingPostalCode, BillingCountry, BillingState, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ' +
					'Phone, Fax, PersonContactId, RecordTypeId, PersonEmail, Brand_Assortment__c, Blacklist__c ' +
				'FROM Account ' +
				'WHERE Id =: accountId ';
			List<Account> accounts = Database.query(query);

			//stop work if account is not found
			if (accounts.isEmpty()) { return '{"error":"Account was not found","message":"error"}'; }
			if (accounts[0].Blacklist__c == 'TRUE') { return '{"error":"This Email Address is in black list","message":"error"}'; }

			if (TouchCRHelper.isSCPEnabled()) {
				shippingCountryCode = String.isNotEmpty(shippingCountryCode) ? shippingCountryCode : (String)accounts[0].get('ShippingCountryCode');
				shippingStateCode = String.isNotEmpty(shippingStateCode) ? shippingStateCode : (String)accounts[0].get('ShippingStateCode');
			}

			//added default phone number
			String phone = generalData.containsKey('phone') ? generalData.get('phone') : '0000000000';
			String phoneAccount = String.isNotBlank(accounts[0].Phone) ? accounts[0].Phone : phone;
			//added default value 'Winter' to Brand
			String brand = String.isNotBlank(accounts[0].Brand_Assortment__c) ? accounts[0].Brand_Assortment__c : 'Winter';

			//save the actual account value for rollback
			Savepoint sp = Database.setSavepoint();

			//update account information
			accounts[0].ShippingPostalCode = String.isNotEmpty(shippingPostalCode) ? shippingPostalCode : accounts[0].ShippingPostalCode;
			accounts[0].ShippingStreet = String.isNotEmpty(shippingStreet) ? shippingStreet : accounts[0].ShippingStreet;
			accounts[0].ShippingCity = String.isNotEmpty(shippingCity) ? shippingCity : accounts[0].ShippingCity;
			accounts[0].ShippingState = String.isNotEmpty(shippingState) ? shippingState : accounts[0].ShippingState;
			accounts[0].ShippingCountry = String.isNotEmpty(shippingCountry) ? shippingCountry : accounts[0].ShippingCountry;
			accounts[0].Phone = phoneAccount;
			accounts[0].Brand_Assortment__c = brand;

				if (TouchCRHelper.isSCPEnabled()) {
					accounts[0].put('ShippingStateCode', String.isNotEmpty(shippingStateCode) ? shippingStateCode : (String)accounts[0].get('ShippingStateCode'));
					accounts[0].put('ShippingCountryCode', String.isNotEmpty(shippingCountryCode) ? shippingCountryCode : (String)accounts[0].get('ShippingCountryCode'));
				}

				try {
					SFDCAccessController.UpdateWithoutSharing (
						accounts[0],
						'RestOrderController.cls [setOrder]',
						new List<Schema.DescribeFieldResult> {
							Account.ShippingPostalCode.getDescribe(), Account.ShippingStreet.getDescribe(),
							Account.ShippingCity.getDescribe(), Account.ShippingState.getDescribe(),
							Account.ShippingCountry.getDescribe(), Account.Phone.getDescribe(),
							Account.Brand_Assortment__c.getDescribe()
						}
					);
				} catch (SFDCAccessControlException e) { return  '{"error":"' + e.ExceptionMessage + '","message":"error"}'; }
				
				String billingStateCode = TouchCRHelper.isSCPEnabled() == TRUE ? (String)accounts[0].get('BillingStateCode') : null;
				String billingCountryCode = TouchCRHelper.isSCPEnabled() == TRUE ? (String)accounts[0].get('BillingCountryCode') : null;

				generalData.put('email', accounts[0].PersonEmail);
				generalData.put('fname', accounts[0].FirstName);
				generalData.put('lname', accounts[0].LastName);
				generalData.put('phone', phoneAccount);
				generalData.put('brand', brand);

				generalData.put('billingStreet', accounts[0].BillingStreet);
				generalData.put('billingCity', accounts[0].BillingCity);
				generalData.put('billingPostalCode', accounts[0].BillingPostalCode);
				generalData.put('billingState', accounts[0].BillingState);
				generalData.put('billingStateCode', billingStateCode);
				generalData.put('billingCountry', accounts[0].BillingCountry);
				generalData.put('billingCountryCode', billingCountryCode);

				generalData.put('shippingStreet', accounts[0].ShippingStreet);
				generalData.put('shippingCity', accounts[0].ShippingCity );
				generalData.put('shippingPostalCode', accounts[0].ShippingPostalCode);
				generalData.put('shippingState', accounts[0].ShippingState);
				generalData.put('shippingStateCode', shippingStateCode);
				generalData.put('shippingCountry', accounts[0].ShippingCountry);
				generalData.put('shippingCountryCode', shippingCountryCode);

				String orderResult = RestHelper.createOrder(generalData, dataForOrderItems);

				if (orderResult.containsIgnoreCase('error')) {
					//if failure - return the actual value for account
					Database.rollback(sp);
					return orderResult;
				} else {

					String result = getOrder(new Map<String, String> {'orderId' => orderResult}); 
					return result;
				}

		} catch (Exception e) {
			return '{"error":"' + e.getMessage() + '","message":"error"}'; }
	}


	//Call the getCharged method from the core package
	public static String chargeOrder(Map<String, String> generalData, Map<String, String> creditCard) {
		try {
			Id orderId = generalData.containsKey('orderId') ? Id.valueOf(generalData.get('orderId')) : null;
			//verification of input data
			if (orderId == null) { return '{"error":"Order Id was not found","message":"error"}'; }

			Id paymentOptionId = generalData.containsKey('paymentOptionId') ? Id.valueOf(generalData.get('paymentOptionId')) : null;
			String last4 = generalData.containsKey('last4') ? String.valueOf(generalData.get('last4')) : null;
			Map<String, Object> chargData = new Map<String, Object>{
				'method' => 'getCharged',
				'payment_frequency' => '',
				'payment_status' => 'Once',
				'payment_start' => String.valueOf(Date.today().day()) + '/' + String.valueOf(Date.today().month()) + '/'+ String.valueOf(Date.today().year()),
				'chargeDate' => '',
				'orderId' => orderId
			};
			if (paymentOptionId != null) {
				List<Payment_Option__c> paymentOption = [
					SELECT Id, Status__c, Profile_Id__c, Option_Id__c,
						Named_Agent__c, Last_4__c, Account__c, Name
					FROM Payment_Option__c
					WHERE Id =: paymentOptionId
				];

				if (!paymentOption.isEmpty()) {
					Map<String,Object> infoOfPaymentOption = new Map<String,Object>{
						'CardId' => paymentOption[0].Option_Id__c,
						'Profile' => paymentOption[0].Profile_Id__c

					};

					chargData.put('creditCard', infoOfPaymentOption);
				}
			} else {
				chargData.put('creditCard', (Map<String, String>)creditCard);
			}

			String resultOfChargeOrder = RestCalls.doPost(JSON.serialize(chargData));

			if (resultOfChargeOrder == 'true') {

				String affiliateFields = TouchCRHelper.isAffiliateEnabled() ? ' Affiliate_Id__c, ' : '';
				String query = 'SELECT Id, Account__c, ' + affiliateFields + ' Balance_Due__c, Subtotal__c, Order_Source__c  FROM Order__c WHERE Id =: orderId';
				List<Order__c> orderItem = Database.query(query);

				if (String.isNotBlank(last4) && !orderItem.isEmpty()) {
					update new Account(Id = orderItem[0].Account__c, Last4__c = last4);
				}

				//Check coupons, increase Coupon Uses and create coupon customer records
				if (orderItem[0].Id != NULL && orderItem[0].Account__c != NULL) {
					CouponHelper.addCouponData(orderItem[0].Id, orderItem[0].Account__c);
				}

				//When In Order we have Affiliate Id
				String affiliateResult = 'true';
				if (TouchCRHelper.isAffiliateEnabled() && String.isNotEmpty((Id)orderItem[0].get('Affiliate_Id__c')) && orderItem[0].Balance_Due__c == 0) {
					affiliateResult = ExtensionsHelperDummy.createCommissionsEarned(orderItem[0]);
				}

				String result = '{"result":"' + resultOfChargeOrder + '","message":"success"}';
				result += (affiliateResult == 'true') ? '' : affiliateResult;					//if we have error in createCommissionsEarnedForAffiliate
				return result;

			} else {
				List<Order_Transaction__c> ordersTransactions = [
					SELECT Id, Name, Description__c
					FROM Order_Transaction__c
					WHERE Order__c =: orderId
					ORDER BY Payment_Date__c DESC
					LIMIT 1
				];
				return '{"error":"' + ordersTransactions[0].Description__c + '","message":"error"}';
			}
		} catch (Exception e) {
			return '{"error":"' + e.getMessage() + '","message":"error"}';
		}
	}

	//Call the chargeUpsell method from the core package
	public static String chargeUpsell(Map<String, String> generalData) {
		try {
			Id orderId = generalData.containsKey('orderId') ? Id.valueOf(generalData.get('orderId')) : null;
			//verification of input data
			if (orderId == null) { return '{"error":"Order Id was not found","message":"error"}'; }

			Map<String, Object> chargData = new Map<String, Object>{
				'method' => 'chargeUpsell',
				'payment_frequency' => '',
				'payment_status' => 'Once',
				'payment_start' => String.valueOf(Date.today().day()) + '/' + String.valueOf(Date.today().month()) + '/'+ String.valueOf(Date.today().year()),
				'chargeDate' => '',
				'orderId' => orderId
			};
			String resultOfChargeUpsell = RestCalls.doPost(JSON.serialize(chargData));

			if (resultOfChargeUpsell == 'true') {
				return '{"result":"' + resultOfChargeUpsell + '","message":"success"}';
			} else {
				List<Order_Transaction__c> ordersTransactions = [
					SELECT Id, Name, Description__c
					FROM Order_Transaction__c
					WHERE Order__c =: orderId
					ORDER BY Payment_Date__c DESC
					LIMIT 1
				];
				String statusError = ordersTransactions.isEmpty() ? resultOfChargeUpsell : ordersTransactions[0].Description__c;
				return '{"error":"' + statusError + '","message":"error"}';
			}
		} catch (Exception e) { return '{"error":"' + e.getMessage() + '","message":"error"}'; }
	}

	public static String getOrders(Map<String, String> generalData) {
		try {
			Id accountId = generalData.containsKey('accountId') ? Id.valueOf(generalData.get('accountId')) : null;
			//verification of input data
			if (accountId == null) { return '{"error":"Account Id was not found","message":"error"}'; }

			List<Order__c> orders = [
				SELECT Id, Name, Date__c, Status__c, Account__c, Total__c, Geolocation__Longitude__s, Geolocation__Latitude__s,
					Shipping_Country__c, Shipping_City__c, Shipping_State__c, Shipping_Address__c, Shipping_Zip_Postal__c,
					Order_Source__c, Order_Type__c, Parrent_Upsell_Order__c,
					(
						SELECT Id, Name, Order__c, Quantity__c, Total_Price__c,
							Product__c, Product_Price__c, Product__r.Name, Is_Bump_Offer__c,
							Product_Variant__c, Product_Variant__r.Name, Product_Variant__r.Color__c, Product_Variant__r.Size__c, Product_Variant__r.Price__c
						FROM Order_Items__r
						WHERE Product_Price__c != 0
					)
				FROM Order__c
				WHERE Account__c =: accountId
				AND Balance_Due__c = 0
				ORDER BY Date__c DESC
			];
			//stop work if orders are not found
			if (orders.isEmpty()) { return '{"error":"Orders were not found","message":"error"}'; }

			//Get Images of Products
			Set<Id> productsId = new Set<Id>();
			for (Order__c order : orders) {
				for (OrderItem__c orderItem : order.Order_Items__r) {
					productsId.add(orderItem.Product__c);
				}
			}
			Map<Id, String> productIdImage = mapImagesOfProducts (productsId);

			List<Map<String, Object>> result = new List<Map<String, Object>>();
			for (Order__c order : orders) {

				List<Map<String, Object>> orderItems = new List<Map<String, Object>>();
				for (OrderItem__c orderItem : order.Order_Items__r) {

					orderItems.add(new Map<String, Object>{
						'id' => orderItem.Id,
						'orderId' => orderItem.Order__c,
						'quantity' => orderItem.Quantity__c,
						'totalPrice' => orderItem.Total_Price__c,
						'productId' => orderItem.Product__c,
						'productName' => orderItem.Product__r.Name,
						'productPrice' => orderItem.Product_Price__c,
						'productVariantId' => orderItem.Product_Variant__c,
						'productVariantPrice' => orderItem.Product_Variant__r.Price__c,
						'productVariantName' => orderItem.Product_Variant__r.Name,
						'productVariantColor' => orderItem.Product_Variant__r.Color__c,
						'productVariantSize' => orderItem.Product_Variant__r.Size__c,
						'isBumpOffer' => orderItem.Is_Bump_Offer__c,
						'productImage' => productIdImage.containsKey(orderItem.Product__c) ? productIdImage.get(orderItem.Product__c) : null
					});
				}

				//if the franchisee is found return the information about it
				//TODO
				Map<String, Object> informationOfOrder = new Map<String, Object>{
					'id' => order.Id,
					'accountId' => order.Account__c,
					'name' => order.Name,
					'date' => order.Date__c != null ? String.valueOf(order.Date__c.format('EEE dd/MM/yyyy HH:mm')) : '',
					'status' => order.Status__c,
					'total' => order.Total__c,
					'longitude' => order.Geolocation__Longitude__s,
					'latitude' => order.Geolocation__Latitude__s,
					'orderType' => order.Order_Type__c,
					'parrentUpsellOrderId' => order.Parrent_Upsell_Order__c,
					'orderSource' => order.Order_Source__c,
					'shippingCountry' => order.Shipping_Country__c,
					'shippingCity' => order.Shipping_City__c,
					'shippingState' => order.Shipping_State__c,
					'shippingAddress' => order.Shipping_Address__c,
					'shippingZipPostal' => order.Shipping_Zip_Postal__c,
					'orderItems' => orderItems
				};

				result.add(informationOfOrder);
			}
			return JSON.serialize(new Map<String, Object>{
				'order' => result,
				'message' => 'success'
			});
		} catch (Exception e) { return '{"error":"' + e.getMessage() + '","message":"error"}'; }
	}

	public static String getOrder(Map<String, String> generalData) {
		try {
			Id orderId = generalData.containsKey('orderId') ? Id.valueOf(generalData.get('orderId')) : null;
			//verification of input data
			if (orderId == null) { return '{"error":"Order Id was not found","message":"error"}'; }

			List<Order__c> order = [
				SELECT Id, Name, Date__c, Status__c, Account__c,
					Total__c, Geolocation__Longitude__s, Geolocation__Latitude__s,
					Shipping_Address__c, Shipping_City__c, Shipping_State__c, Shipping_Country__c, Shipping_Zip_Postal__c,
					Order_Source__c, Order_Type__c, Parrent_Upsell_Order__c,
					(
						SELECT Id, Name, Order__c, Quantity__c, Total_Price__c,
							Product__c, Product_Price__c, Product__r.Name, Is_Bump_Offer__c,
							Product_Variant__c, Product_Variant__r.Name, Product_Variant__r.Color__c, Product_Variant__r.Size__c, Product_Variant__r.Price__c
						FROM Order_Items__r
						WHERE Product_Price__c != 0
					)
				FROM Order__c
				WHERE Id =: orderId
			];

			//stop work if order is not found
			if (order.isEmpty()) { return '{"error":"Order was not found","message":"error"}'; }

			//Get Images of Products
			Set<Id> productsId = new Set<Id>();

			for (OrderItem__c orderItem : order[0].Order_Items__r) {
				productsId.add(orderItem.Product__c);
			}
			Map<Id, String> productIdImage = mapImagesOfProducts (productsId);

			List<Map<String, Object>> orderItems = new List<Map<String, Object>>();
			for (OrderItem__c orderItem : order[0].Order_Items__r) {
				orderItems.add(new Map<String, Object>{
					'id' => orderItem.Id,
					'orderId' => orderItem.Order__c,
					'quantity' => orderItem.Quantity__c,
					'totalPrice' => orderItem.Total_Price__c,
					'productId' => orderItem.Product__c,
					'productPrice' => orderItem.Product_Price__c,
					'productName' => orderItem.Product__r.Name,
					'productVariantId' => orderItem.Product_Variant__c,
					'productVariantPrice' => orderItem.Product_Variant__r.Price__c,
					'productVariantName' => orderItem.Product_Variant__r.Name,
					'productVariantColor' => orderItem.Product_Variant__r.Color__c,
					'productVariantSize' => orderItem.Product_Variant__r.Size__c,
					'isBumpOffer' => orderItem.Is_Bump_Offer__c,
					'productImage' => productIdImage.containsKey(orderItem.Product__c) ? productIdImage.get(orderItem.Product__c) : null
				});
			}

			Map<String, Object> result = new Map<String, Object>{
				'accountId' => order[0].Account__c,
				'id' => order[0].Id,
				'name' => order[0].Name,
				'date' => order[0].Date__c != null ? String.valueOf(order[0].Date__c.format('EEE dd/MM/yyyy HH:mm')) : '',
				'status' => order[0].Status__c,
				'total' => order[0].Total__c,
				'longitude' => order[0].Geolocation__Longitude__s,
				'latitude' => order[0].Geolocation__Latitude__s,
				'orderType' => order[0].Order_Type__c,
				'parrentUpsellOrderId' => order[0].Parrent_Upsell_Order__c,
				'orderSource' => order[0].Order_Source__c,
				'shippingCountry' => order[0].Shipping_Country__c,
				'shippingCity' => order[0].Shipping_City__c,
				'shippingState' => order[0].Shipping_State__c,
				'shippingAddress' => order[0].Shipping_Address__c,
				'shippingZipPostal' => order[0].Shipping_Zip_Postal__c,
				'orderItems' => orderItems
			};

			//Return OrderItems for received order
			return JSON.serialize(new Map<String, Object>{
				'order' => result,
				'message' => 'success',
				'orderId' => order[0].Id 
			});

		} catch (Exception e) { return '{"error":"' + e.getMessage() + '","message":"error"}'; }
	}

	public static String getCardInfo(Map<String, String> generalData) {
		try {
			Id accountId = generalData.containsKey('accountId') ? Id.valueOf(generalData.get('accountId')) : null;
			//verification of input data
			if (accountId == null) { return '{"error":"Account Id was not found","message":"error"}'; }

			//Upsell value of default
			Map<String, String> transactionData = new Map<String, String>{'isUpsell' => 'false'};

			List<Order__c> ordersTransactions = [
				SELECT Id, (
					SELECT Id, Card_Last_4__c, Type__c, Card_Type__c
					FROM Order__c.Transactions__r
					WHERE Response_Status__c LIKE '%Approved%'
				)
				FROM Order__c
				WHERE Account__c = :accountId
				ORDER BY CreatedDate DESC
			];

			if (!ordersTransactions.isEmpty()) {
				List<Order_Transaction__c> transactions = ordersTransactions[0].Transactions__r;
				if (!transactions.isEmpty()) {
					transactionData.put('isUpsell', 'true');
					transactionData.put('last4', transactions[0].Card_Last_4__c);
					transactionData.put('cardType', transactions[0].Card_Type__c);
				}
			}
			return JSON.serialize(new Map<String, Object>{
				'infoOfTransaction' => transactionData,
				'message' => 'success'
			});
		} catch (Exception e) { return '{"error":"' + e.getMessage() + '","message":"error"}'; }
	}

	//Get info from all orders transactions
	public static String getOrdersTransactions(Map<String, String> generalData) {
		try {
			Id accountId = generalData.containsKey('accountId') ? Id.valueOf(generalData.get('accountId')) : null;
			//verification of input data
			if (accountId == null) { return '{"error":"Account Id was not found","message":"error"}'; }


			List<Order_Transaction__c> ordersTransactions = [
				SELECT Id, Name, Card_Last_4__c, Payment_Response_Body__c
				FROM Order_Transaction__c
				WHERE Order__r.Account__c =: accountId
				AND Response_Status__c = 'Approved'
				ORDER BY Payment_Date__c DESC
			];

			Map<String, Map<String, String>> resultMap = new Map<String, Map<String, String>>();
			for (Order_Transaction__c ordersTransaction: ordersTransactions) {
				if (ordersTransaction.Card_Last_4__c != null) {

					String rBody = ordersTransaction.Payment_Response_Body__c;

					String addressCity;
					String addressLine1;
					String addressState;
					String expMonth;
					String expYear;
					String last4;

					if (rBody.indexOf('address_city') != -1) {
						addressCity = rBody.substring(rBody.indexOf('address_city') + 16, rBody.indexOf(',', rBody.indexOf('address_city')) - 1);
					}
					if (rBody.indexOf('address_line1') != -1) {
						addressLine1 = rBody.substring(rBody.indexOf('address_line1') + 17, rBody.indexOf(',', rBody.indexOf('address_line1')) - 1);
					}
					if (rBody.indexOf('address_state') != -1) {
						addressState = rBody.substring(rBody.indexOf('address_state') + 17, rBody.indexOf(',', rBody.indexOf('address_state')) - 1);
					}
					if (rBody.indexOf('exp_month') != -1) {
						expMonth = rBody.substring(rBody.indexOf('exp_month') + 12, rBody.indexOf(',', rBody.indexOf('exp_month')));
					}
					if (rBody.indexOf('exp_year') != -1) {
						expYear = rBody.substring(rBody.indexOf('exp_year') + 11, rBody.indexOf(',', rBody.indexOf('exp_year')));
					}
					if (rBody.indexOf('last4') != -1) {
						last4 = rBody.substring(rBody.indexOf('last4') + 9, rBody.indexOf(',', rBody.indexOf('last4')) - 1);
					}

					resultMap.put(last4, new Map<String, String>{
						'address_city' => addressCity,
						'address_line1' => addressLine1,
						'address_state' => addressState,
						'exp_month' => expMonth,
						'exp_year' => expYear,
						'last4' => last4
					});
				}
			}

			List<Map<String, String>> result = new List<Map<String, String>>();
			for (String key: resultMap.keySet()) {
				result.add(resultMap.get(key));
			}
			if (result.isEmpty()) {
				return '{"error":"Transactions are not found","message":"error"}';
			}

			return JSON.serialize(new Map<String, Object>{
				'transactions' => result,
				'message' => 'success'
			});

		} catch (Exception e) { return '{"error":"' + e.getMessage() + '","message":"error"}'; }
	}


	public static String setAuthorizeOrder(Map<String, String> generalData) {
		try {
			Id accountId = generalData.containsKey('accountId') ? Id.valueOf(generalData.get('accountId')) : null;
			Id ownerId = generalData.containsKey('ownerId') ? Id.valueOf(generalData.get('ownerId')) : null;
			String last4 = generalData.containsKey('last4') ? generalData.get('last4') : null;
			String customerIp = generalData.containsKey('customerIp') ? generalData.get('customerIp') : null;
			if (accountId == null && ownerId == null) { return '{"error":"Account Id or Owner Id are incorrect","message":"error"}'; }

			//Getting information from an existing Account

			String codeFields = TouchCRHelper.isSCPEnabled() == TRUE ? ' BillingStateCode, ShippingStateCode, BillingCountryCode, ShippingCountryCode, ' : '';

			String query = 'SELECT Id, LastName, FirstName, BillingStreet, BillingCity, ' + codeFields +
					'BillingPostalCode, BillingCountry, BillingState, ' +
					'ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ' +
					'Phone, PersonEmail, Brand_Assortment__c ' +
				'FROM Account ' +
				'WHERE Id =: accountId ';
			List<Account> accounts = Database.query(query);

			//stop work if account is not found
			if (accounts.isEmpty()) { return '{"error":"Account was not found","message":"error"}'; }

			// Multi Currency
			String currency_code = generalData.containsKey('currency_code') ? generalData.get('currency_code') : null;
			currency_code = TouchCRHelper.validateAndFixCurrencyIsoCode(currency_code);

			Order__c cOrder = new Order__c();
			if (ownerId != null) { cOrder.OwnerId = ownerId; }
			cOrder.Account__c = accountId;
			cOrder.Customer_IP__c = customerIp;

			/* -------- Billing Info -------- */
			cOrder.Billing_Last_Name__c = accounts[0].LastName;
			cOrder.Date__c = System.now();

			cOrder.Billing_Address__c = accounts[0].BillingStreet;
			cOrder.Billing_City__c = accounts[0].BillingCity;
			cOrder.Billing_State__c = TouchCRHelper.isSCPEnabled() == TRUE ? (String)accounts[0].get('BillingStateCode') : accounts[0].BillingState;
			cOrder.Billing_Zip_Postal__c = accounts[0].BillingPostalCode;

			/* -------- CC information -------- */
			cOrder.Payment_Method__c = 'Credit Card';
			/* -------- Order Amount Infromation -------- */
			//defalt value for authorize
			cOrder.Subtotal__c = 1;

			cOrder.Currency__c = currency_code;
			cOrder = (Order__c) TouchCRHelper.setCurrencyIsoCode(cOrder, currency_code);

			/* -------- Shipping Info -------- */
			cOrder.Shipping_First_Name__c = accounts[0].FirstName;
			cOrder.Shipping_Name__c = accounts[0].LastName;
			cOrder.Shipping_Phone__c = accounts[0].Phone;
			cOrder.Shipping_City__c = accounts[0].ShippingCity;
			cOrder.Shipping_State__c =  TouchCRHelper.isSCPEnabled() == TRUE ? (String)accounts[0].get('ShippingStateCode') : accounts[0].ShippingState;
			cOrder.Shipping_Zip_Postal__c = accounts[0].ShippingPostalCode;
			/* -------- Payment Gateway Info -------- */
			cOrder.Named_Agent__c = RestHelper.getNamePaymentAgent(accounts[0].Brand_Assortment__c);
			/* -------- Required fields for MinFraud -------- */
			cOrder.Billing_Email__c = String.isNotEmpty(accounts[0].PersonEmail) ? accounts[0].PersonEmail : 'Billing_Email_MinFraud@gmail.com';
			cOrder.Billing_First_Name__c = String.isNotEmpty(accounts[0].FirstName) ? accounts[0].FirstName : 'MinFraudFirstName';
			cOrder.Billing_Phone__c = String.isNotEmpty(accounts[0].Phone) ? accounts[0].Phone : '0000-000-000';
			cOrder.Billing_Country__c = String.isNotEmpty(accounts[0].BillingCountry) ? accounts[0].BillingCountry : 'Canada';
			cOrder.Shipping_Address__c = String.isNotEmpty(accounts[0].ShippingStreet) ? accounts[0].ShippingStreet : 'Shipping Street';
			cOrder.Shipping_Country__c = String.isNotEmpty(accounts[0].ShippingCountry) ? accounts[0].ShippingCountry : 'Canada';

			try {
				SFDCAccessController.InsertWithoutSharing (
					cOrder,
					'RestOrderController.cls [setAuthorizeOrder]',
					new List<Schema.DescribeFieldResult> {
						Order__c.Account__c.getDescribe(), Order__c.Billing_Last_Name__c.getDescribe(), Order__c.Date__c.getDescribe(),
						Order__c.Billing_Address__c.getDescribe(), Order__c.Billing_City__c.getDescribe(), Order__c.Billing_State__c.getDescribe(),
						Order__c.Billing_Zip_Postal__c.getDescribe(), Order__c.Payment_Method__c.getDescribe(), Order__c.Subtotal__c.getDescribe(),
						Order__c.Currency__c.getDescribe(), Order__c.Shipping_First_Name__c.getDescribe(), Order__c.Shipping_Name__c.getDescribe(),
						Order__c.Shipping_Phone__c.getDescribe(), Order__c.Shipping_City__c.getDescribe(), Order__c.Shipping_State__c.getDescribe(),
						Order__c.Shipping_Zip_Postal__c.getDescribe(), Order__c.Named_Agent__c.getDescribe(), Order__c.Billing_Email__c.getDescribe(),
						Order__c.Billing_First_Name__c.getDescribe(), Order__c.Billing_Phone__c.getDescribe(), Order__c.Billing_Country__c.getDescribe(), 
						Order__c.Shipping_Address__c.getDescribe(), Order__c.Shipping_Country__c.getDescribe()
					}
				);

				if (last4 != null) {
					accounts[0].Last4__c = last4;
					SFDCAccessController.UpdateWithoutSharing (
						accounts[0],
						'RestOrderController.cls [setAuthorizeOrder]',
						new List<Schema.DescribeFieldResult> {
							Account.Last4__c.getDescribe()
						}
					);
				}
			} catch (SFDCAccessControlException e) { return  '{"error":"' + e.ExceptionMessage + '","message":"error"}'; }


			return '{"message":"success", "orderId":"' + cOrder.Id + '"}';
		} catch (Exception e) { return '{"message":"error","error":"' + e.getMessage() + '"}'; }

	}

	public static String authorizePaymentOption(Map<String, String> generalData, Map<String, String> creditCard) {
		try {
			Id orderId = generalData.containsKey('orderId') ? generalData.get('orderId') : null;
			if (orderId == null) { return '{"error":"Order Id was not found","message":"error"}'; }
			if (creditCard.isEmpty()) { return '{"error":"Credit Card information was not found","message":"error"}'; }

			Map<String,Object> result = PaymentProcessor.doPayment(
				new Map<String,Object>{
					'Method' => 'Authorization',
					'OrderId' => orderId,
					'Amount' => 1,
					'CreditCard' => (Map<String, String>)creditCard
				}
			);
			String description = result.containsKey('Description') ? String.valueOf(result.get('Description')) : null;
			if (result.get('Status') != 'Approved') { return '{"message":"error","error":"' + description + '"}';}

			String last4 = String.valueOf(result.get('Last4'));
			String paymentAgent = String.valueOf(result.get('PaymentAgent'));
			String transactionId = String.valueOf(result.get('Transaction'));
		
			List<Account> accountToPaymentOption = [
				SELECT Id, Last4__c, 
				(
					SELECT Id, Account__c, Status__c, Last_4__c
					FROM Payment_Options__r
					WHERE Last_4__c =: last4
					AND Named_Agent__c =: paymentAgent
					AND Status__c = 'Active'
				)
				FROM Account
				WHERE Id IN
				(
					SELECT Account__c
					FROM Payment_Option__c
					WHERE Last_4__c =: last4
					AND Named_Agent__c =: paymentAgent
					AND Status__c = 'Active'
				)
				AND Id IN
				(
					SELECT Account__c
					FROM Order__c
					WHERE Id =: orderId
				)
			];
			if (accountToPaymentOption.isEmpty() || accountToPaymentOption[0].Payment_Options__r.isEmpty()) { return '{"message":"error","error":"Account or Payment Option were not found"}';}
			
			Map<String, Object> paymentOption = new Map<String, Object>{
				'id' => accountToPaymentOption[0].Payment_Options__r[0].Id,
				'last4' => accountToPaymentOption[0].Payment_Options__r[0].Last_4__c,
				'defaultCard' => accountToPaymentOption[0].Payment_Options__r[0].Last_4__c == accountToPaymentOption[0].Last4__c ? true : false
			};

			return JSON.serialize(new Map<String, Object>{
				'paymentOption' => paymentOption,
				'transactionId' => transactionId,
				'message' => 'success'
			});
		} catch (Exception e) { return '{"message":"error","error":"' + e.getMessage() + '"}'; }
	}

	public static String removePaymentOption(Map<String, String> generalData) {
		try {
			Id paymentOptionId = generalData.containsKey('paymentOptionId') ? generalData.get('paymentOptionId') : null;
			if (paymentOptionId == null) { return '{"error":"Payment Option Id was not found","message":"error"}'; }
		
			List<Payment_Option__c> paymentOption = [
				SELECT Id, Status__c, Profile_Id__c, Option_Id__c,
					Named_Agent__c, Last_4__c, Account__c, Account__r.Last4__c
				FROM Payment_Option__c
				WHERE Id =: paymentOptionId
			];

			if (paymentOption.isEmpty()) { return '{"message":"error","error":"Payment Option was not found"}';}
			paymentOption[0].Status__c = 'Inactive';

			try {
				SFDCAccessController.UpdateWithoutSharing (
					paymentOption[0],
					'RestOrderController.cls [removePaymentOption]',
					new List<Schema.DescribeFieldResult> {
						Payment_Option__c.Status__c.getDescribe()
					}
				);
			} catch (SFDCAccessControlException e) { return  '{"error":"' + e.ExceptionMessage + '","message":"error"}'; }

			if (paymentOption[0].Last_4__c == paymentOption[0].Account__r.Last4__c) {
				Account updateAccount = new Account (Id = paymentOption[0].Account__c, Last4__c = '');
				SFDCAccessController.UpdateWithoutSharing (
					updateAccount,
					'RestOrderController.cls [removePaymentOption]',
					new List<Schema.DescribeFieldResult> {
						Account.Last4__c.getDescribe()
					}
				);
			}

			return JSON.serialize(new Map<String, Object>{
				'paymentOptionId' => paymentOption[0].Id,
				'message' => 'success'
			});
		} catch (Exception e) { return '{"message":"error","error":"' + e.getMessage() + '"}'; }

	}

	public static String refundTransaction(Map<String, String> generalData) {
		try {
			Id transactionId = generalData.containsKey('transactionId') ? Id.valueOf(generalData.get('transactionId')) : null;
			//verification of input data
			if (transactionId == null) { return '{"error":"Transaction Id was not found","message":"error"}'; }

			Map<String,Object> result = PaymentProcessor.doPayment(
				new Map<String,Object>{
					'Method' => 'Refund',
					'Transaction' => transactionId
				}
			);

			if (!result.containsKey('Status')) { return '{"message":"error","error":"Error Transaction Service Unavailable"}'; }
			if ((String)result.get('Status') == 'Error') { return '{"message":"error","error":"' + result.get('Message') + '}'; }
			if ((String)result.get('Status') == 'Approved') {

				Boolean deleteOrder = generalData.containsKey('deleteOrder') ? Boolean.valueOf(generalData.get('deleteOrder')) : false;
				if (deleteOrder) {
					Id orderId = generalData.containsKey('orderId') ? Id.valueOf(generalData.get('orderId')) : null;
					if (orderId == null) { return '{"error":"Order Id was not found","message":"error"}'; }

					String deleteResult = deleteOrder(new Map<String, String>{ 'orderId' => String.valueOf(orderId) });

					return deleteResult;
				}

				return '{"message":"success"}';
			}
			return '{"message":"error","error":"Error Transaction Service Unavailable"}';
		} catch (Exception e) { return '{"message":"error","error":"' + e.getMessage() + '"}'; }
	}

	public static String deleteOrder(Map<String, String> generalData) {
		try {
			Id orderId = generalData.containsKey('orderId') ? Id.valueOf(generalData.get('orderId')) : null;

			Order__c deleteOrder = new Order__c (Id = orderId);

			try {
				SFDCAccessController.DeleteWithoutSharing (
					deleteOrder,
					'RestPersonAccountController.cls [deletePersonAccount]'
				);
			} catch (SFDCAccessControlException e) { return  '{"error":"' + e.ExceptionMessage + '","message":"error"}'; }

			return '{"message":"success"}';

		} catch (Exception e) { return '{"error":"' +  e.getMessage() + '","message":"error"}'; }
	}

	/* -------- Create Map of Images ---------- */
	public static Map<Id, String> mapImagesOfProducts(Set<Id> productsId) {	
		Map<Id, String> productIdImage = new Map<Id, String>();
		Map<Id, Decimal> productIdImageDisplayOrder = new Map<Id, Decimal>();
		for (Product_Image__c prodImage : [SELECT Id, Product_Lookup__c, Image_URL__c, Display_Order__c FROM Product_Image__c WHERE Product_Lookup__c IN : productsId]) {
			if (productIdImageDisplayOrder.containsKey(prodImage.Product_Lookup__c)) {
				if (productIdImageDisplayOrder.get(prodImage.Product_Lookup__c) > prodImage.Display_Order__c) {
					productIdImageDisplayOrder.put(prodImage.Product_Lookup__c, prodImage.Display_Order__c);
					productIdImage.put(prodImage.Product_Lookup__c, String.valueOf(prodImage.Image_URL__c));
				}    
			} else {
				productIdImageDisplayOrder.put(prodImage.Product_Lookup__c, prodImage.Display_Order__c);
				productIdImage.put(prodImage.Product_Lookup__c, String.valueOf(prodImage.Image_URL__c));
			}
		}
		return productIdImage;
	}

	public static String setGuest(Map<String, String> orderFormData, RestHelper.DataForOrderItems dataForOrderItems) {
		try{
			String email = orderFormData.containsKey('email') ? orderFormData.get('email') : null;
			if (email == null) { return '{"error":"Email can not be empty","message":"error"}'; }

			String fname = orderFormData.containsKey('fname') ? orderFormData.get('fname') : null;
			String lname = orderFormData.containsKey('lname') ? orderFormData.get('lname') : null;
			String accountId;

			List<Account> anct = [SELECT Id, Type FROM Account WHERE PersonEmail =: email LIMIT 1];

			orderFormData.put('firstName', fname);
			orderFormData.put('lastName', lname);
			orderFormData.put('personEmail', email);

			if (!anct.isEmpty()) {
				orderFormData.put('id',anct[0].id);
			}
			String resultSetAccount = RestPersonAccountController.setPersonAccount(orderFormData);

			if (resultSetAccount.contains('error')) { return resultSetAccount; }
			Map<String, String> workData = (Map<String, String>)JSON.deserialize(resultSetAccount, Map<String, String>.class);
			accountId = (workData.get('accountId'));

			if (anct.isEmpty()) {
				List<Lead> lead = [SELECT Id from Lead WHERE Email =: email LIMIT 1];

				if (lead.size() > 0) {
					try {
						Database.LeadConvert lc = new Database.LeadConvert();
						lc.setLeadId(lead[0].Id);
						lc.setAccountId(accountId);
						LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
						lc.setConvertedStatus(convertStatus.MasterLabel);
						lc.setDoNotCreateOpportunity(true);
						Database.LeadConvertResult lcr = Database.convertLead(lc);
					}
					catch (Exception e) { return '{"error":"' + e.getMessage() + '","message":"error"}'; }
				}
			} else {
				String response = RestNewOrderProcessController.getCustomerHistory(accountId);
				// -------- Black list or fraud founded --------
				if (response != 'true') { return response; }
			}

			orderFormData.put('accountId', accountId);

			return RestOrderController.setOrder(orderFormData, dataForOrderItems);


		} catch (Exception e) { return '{"error":"' + e.getMessage() + '","message":"error"}'; }
	}

}