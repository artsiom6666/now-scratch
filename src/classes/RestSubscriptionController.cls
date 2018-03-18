public with sharing class RestSubscriptionController {

    public static String getSubscriptions(Map<String, String> generalData) {
		try {
			Id accountId = generalData.containsKey('accountId') ? Id.valueOf(generalData.get('accountId')) : null;
			//verification of input data
			if (accountId == null) { return '{"error":"Account Id was not found","message":"error"}'; }

			List<Subscription__c> subscriptions = [
				SELECT Id, Name, Active__c, Order_Repeat__c, Frequency__c, Start_Date__c, Stop_Date__c, 
					   Count__c, Stop_On__c, Account__c, Charge_Amount__c, Paused__c, Unpause_Date__c, 
					(
						SELECT Id, Subtotal__c, Subscription_Approved_Charges_Count__c, Total__c, Subscription_Remains_Amount__c,
            			Amount_To_Charge__c, Date__c FROM Orders__r
            			WHERE Status__c != 'Error' ORDER BY Date__c DESC LIMIT 1
					)
				FROM Subscription__c
				WHERE Account__c =: accountId AND Id IN 
					(
						SELECT Subscription_To__c FROM Order__c
            			WHERE Status__c != 'Error'
					)
				ORDER BY Start_Date__c DESC
			];

			//stop work if subscriptions are not found
			if (subscriptions.isEmpty()) { return '{"error":"Subscriptions were not found","message":"error"}'; }

			Set<Id> lastOrdersIds = new Set<Id>();
			for (Integer i = 0; i < subscriptions.size(); i++) {
				lastOrdersIds.add(subscriptions[i].Orders__r[0].Id);
			}

			List<OrderItem__c> orderItems = [
				SELECT Id, Name, Order__c, Quantity__c, Total_Price__c,
					Product__c, Product_Price__c, Product__r.Name, Is_Bump_Offer__c,
					Product_Variant__c, Product_Variant__r.Name, Product_Variant__r.Color__c, Product_Variant__r.Size__c, Product_Variant__r.Price__c
				FROM OrderItem__c
				WHERE Order__c IN :lastOrdersIds AND Product_Price__c != 0
			];

			//Get Images of Products
			Set<Id> productsId = new Set<Id>();
			for (OrderItem__c orderItem : orderItems) {
				productsId.add(orderItem.Product__c);
			}
			Map<Id, String> productIdImage = RestOrderController.mapImagesOfProducts(productsId);

			List<Map<String, Object>> result = new List<Map<String, Object>>();
			for (Subscription__c subscription : subscriptions) {

				List<Map<String, Object>> subscriptionOrderItems = new List<Map<String, Object>>();
				for (OrderItem__c orderItem : orderItems) {

					if (orderItem.Order__c == subscription.Orders__r[0].Id) {
						subscriptionOrderItems.add(new Map<String, Object>{
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
				}

				Date nextOrderDate;
				if (subscription.Frequency__c == 'Daily') {
					nextOrderDate = subscription.Orders__r[0].Date__c.addDays(1).date();
				} else if (subscription.Frequency__c == 'Weekly') {
					nextOrderDate = subscription.Orders__r[0].Date__c.addDays(7).date();
				} else if (subscription.Frequency__c == 'Monthly') {
					nextOrderDate = subscription.Orders__r[0].Date__c.addMonths(1).date();
				} else if (subscription.Frequency__c == 'Quarterly') {
					nextOrderDate = subscription.Orders__r[0].Date__c.addMonths(3).date();
				} else if (subscription.Frequency__c == 'Annual') {
					nextOrderDate = subscription.Orders__r[0].Date__c.addYears(1).date();
				}

				if (Date.today() >= nextOrderDate) {
					nextOrderDate = Date.today();
				}

				Map<String, Object> informationOfSubscription = new Map<String, Object>{
					'id' => subscription.Id,
                    'name' => subscription.Name,
					'active' => subscription.Active__c,
                    'orderRepeat' => subscription.Order_Repeat__c,
                    'frequency' => subscription.Frequency__c,
                    'startDate' => subscription.Start_Date__c != null ? String.valueOf(subscription.Start_Date__c.format()) : '',
                    'stopDate' => subscription.Stop_Date__c != null ? String.valueOf(subscription.Stop_Date__c.format()) : '',
                    'сount' => subscription.Count__c,
                    'stopOn' => subscription.Stop_On__c,
                    'accountId' => subscription.Account__c,
                    'chargeAmount' => subscription.Charge_Amount__c,
					'paused' => subscription.Paused__c,
					'unpauseDate' => subscription.Unpause_Date__c != null ? String.valueOf(subscription.Unpause_Date__c.format()) : '',
					'nextOrderDate' => String.valueOf(nextOrderDate.format()),
					'orderItems' => subscriptionOrderItems
				};

				result.add(informationOfSubscription);
			}
			return JSON.serialize(new Map<String, Object>{
				'subscription' => result,
				'message' => 'success'
			});
		} catch (Exception e) { return '{"error":"' + e.getMessage() + '","message":"error"}'; }
	}

	public static String setSubscription(Map<String, String> generalData) {
		try {
			Id accountId = generalData.containsKey('accountId') ? Id.valueOf(generalData.get('accountId')) : null;
			Id subscriptionId = generalData.containsKey('subscriptionId') ? Id.valueOf(generalData.get('subscriptionId')) : null;
			String status = generalData.containsKey('status') ? generalData.get('status') : null;
			// Date unpaseDate = generalData.containsKey('status') ? Date.valueOf(generalData.get('unpaseDate')) : null;

			if (accountId == null) { return '{"error":"Account Id was not found","message":"error"}'; }
			if (subscriptionId == null) { return '{"error":"Subscription Id was not found","message":"error"}'; }
			if (status == null) { return '{"error":"Status was not found","message":"error"}'; }

			List<Subscription__c> subscriptions = [
				SELECT Id
				FROM Subscription__c
				WHERE Id =: subscriptionId
			];

			if (subscriptions.isEmpty()) { return '{"error":"Subscriptions were not found","message":"error"}'; }

			if (status == 'pause') {
				subscriptions[0].Paused__c = true;
				// subscriptions[0].Unpause_Date__c = unpaseDate;
			} else if (status == 'unpause') {
				subscriptions[0].Paused__c = false;
				subscriptions[0].Unpause_Date__c = null;
			} else if (status == 'cancel') {
				subscriptions[0].Active__c = false;
			}

			update subscriptions;

			return '{"message":"success"}';
		} catch (Exception e) { return '{"error":"' + e.getMessage() + '","message":"error"}'; }
	}
}