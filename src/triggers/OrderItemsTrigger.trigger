trigger OrderItemsTrigger on OrderItem__c (before insert, before update, after insert, after update, before delete, after delete) {

    if (Trigger.isBefore) {
        //Changed logic to only apply only on insert to make product price editable
        if (Trigger.isInsert || Trigger.isUpdate) {
            Set<Id> productIds = new Set<Id>();
            for(OrderItem__c item : Trigger.New) {

                if (item.Product__c != NULL) {
                    productIds.add(item.Product__c);
                }
            }

            Map<Id, Decimal> productToPrice = new Map<Id, Decimal>();
            for (PriceBookEntry entry : [SELECT Product2Id, UnitPrice FROM PriceBookEntry WHERE Product2Id IN :productIds AND IsActive = TRUE]) {
                productToPrice.put(entry.Product2Id, entry.UnitPrice);
            }

            for (OrderItem__c item : Trigger.New) {
                if (item.Product__c != NULL && item.Use_Standard_Price__c == true) {
                    if (productToPrice.containsKey(item.Product__c)) {
                        item.Product_Price__c = productToPrice.get(item.Product__c);
                    }
                }
            }
        }
    }

	//Product Bundle logic

	if (Trigger.isBefore && Trigger.isInsert) {
		Map<Id, List<OrderItem__c>> mapOIsRelatedProductIds = new Map<Id, List<OrderItem__c>>();

		for (OrderItem__c item : Trigger.new) {
			//adding an product Id and dependent Order Items
			if (!mapOIsRelatedProductIds.containsKey(item.Product__c)) {
				mapOIsRelatedProductIds.put(item.Product__c, new List<OrderItem__c>());
			}
			mapOIsRelatedProductIds.get(item.Product__c).add(item);
		}

		if (!mapOIsRelatedProductIds.isEmpty()) {
			Set<Id> setIdProduct2 = new Set<Id>(mapOIsRelatedProductIds.keySet());
			if (!setIdProduct2.isEmpty()) {

				List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE DeveloperName = 'Product_Bundle' AND SobjectType = 'Product2' AND IsActive = TRUE];
				if (!recordTypes.isEmpty()) {
					List<Product2> listProduct2 = [SELECT Id, RecordTypeId FROM Product2 WHERE Id IN: setIdProduct2];
					for (Product2 itemPr2 : listProduct2){
						if (itemPr2.RecordTypeId == recordTypes[0].Id) {
							List<OrderItem__c> relatedOrderItems = mapOIsRelatedProductIds.get(itemPr2.Id);
							for (OrderItem__c oI : relatedOrderItems) {
								//created Bundle OrderItem for Product Bundle
								oI.Is_Product_Bundle__c = true;
							}
						}
					}
				}
			}
		}
	}

	//Product Bundle logic
	if (Trigger.isAfter && Trigger.isInsert) {
		List<OrderItem__c> newListOrderItem = new List<OrderItem__c>();
		Set<Id> idsProduct2 = new Set<Id>();

		for (OrderItem__c itemOI : Trigger.new) {
			if (itemOI.Is_Product_Bundle__c) {
				idsProduct2.add(itemOI.Product__c);
			}
		}

		List<Product_Bundle_Item__c> listProductBundle = [SELECT Id, Product__c, Product_Bundle__c FROM Product_Bundle_Item__c WHERE Product_Bundle__c IN:idsProduct2 ];

		//get Products Id for selected Products Bundle
		Map<Id, List<Id>> productBundleIdToSetProductId = new Map<Id, List<Id>>();
		for (Product_Bundle_Item__c pB : listProductBundle) {
			if (!productBundleIdToSetProductId.containsKey(pB.Product_Bundle__c)) {
				productBundleIdToSetProductId.put(pB.Product_Bundle__c, new List<Id>());
			}
			productBundleIdToSetProductId.get(pB.Product_Bundle__c).add(pB.Product__c);
		}

		//Created OrderItems for Bundle OrderItem
		for (OrderItem__c itemOI : Trigger.new) {
			if (itemOI.Is_Product_Bundle__c && productBundleIdToSetProductId.containsKey(itemOI.Product__c)) {
				for (Id itemPrBundProduct : productBundleIdToSetProductId.get(itemOI.Product__c)) {
					OrderItem__c newOI = new OrderItem__c();
					newOI.Order__c = itemOI.Order__c;
					newOI.Product__c = itemPrBundProduct;
					newOI.Quantity__c = itemOI.Quantity__c;
					newOI.Product_Price__c = 0;
					newOI.Is_Product_Bundle__c = false;
					newOI.Order_Item_Bundle__c = String.valueOf(itemOI.Id);
					newListOrderItem.add(newOI);
				}
			}
		}
		insert newListOrderItem;
	}

	//Product Bundle logic
	if (Trigger.isBefore && Trigger.isDelete) {
		Set<Id> setIdOIBundle = new Set<Id>();
		for (OrderItem__c itemOI : Trigger.oldMap.values()) {
			if (String.isNotBlank(itemOI.Order_Item_Bundle__c)) {
				try {
					setIdOIBundle.add(Id.valueOf(itemOI.Order_Item_Bundle__c));
				} catch (Exception e){}
			}
		}

		if (!setIdOIBundle.isEmpty()) {
			List<OrderItem__c> bundleOIs = [SELECT Id FROM OrderItem__c WHERE Id IN: setIdOIBundle];
			if (!bundleOIs.isEmpty()) {
				for (OrderItem__c itemOI : Trigger.oldMap.values()) {
					itemOI.addError('You can\'t delete or update this Order Item.');
				}
			}
		}
	}

	//Product Bundle logic
	if (Trigger.isAfter && Trigger.isDelete) {
		Set<String> setIdChildren = new Set<String>();

		Map<Id, List<OrderItem__c>> mapOIsRelatedProductIds = new Map<Id, List<OrderItem__c>>();

		for (OrderItem__c itemOI : Trigger.oldMap.values()){
			if (String.isBlank(itemOI.Order_Item_Bundle__c)){
				setIdChildren.add(String.valueOf(itemOI.Id));
			}
			//adding an produck Id and dependent Order Items
			if (!mapOIsRelatedProductIds.containsKey(itemOI.Product__c)) {
				mapOIsRelatedProductIds.put(itemOI.Product__c, new List<OrderItem__c>());
			}
			mapOIsRelatedProductIds.get(itemOI.Product__c).add(itemOI);
		}

		if (!setIdChildren.isEmpty()) {
			List<OrderItem__c> listChildrenProduct = [SELECT Id FROM OrderItem__c WHERE Order_Item_Bundle__c IN: setIdChildren];
			delete listChildrenProduct;
		}
	}



	if (Trigger.isAfter) {
		if (Trigger.isInsert || Trigger.isUpdate) {
			Set<Id> chargentOrderIds = new Set<Id>();
			for (OrderItem__c item : Trigger.New) {
				chargentOrderIds.add(item.Order__c);
			}

			Map<Id, Decimal> orderToSubtotal = new Map<Id, Decimal>();
			for (OrderItem__c item : [SELECT Id, Order__c, Total_Price__c FROM OrderItem__c WHERE Order__c IN :chargentOrderIds]) {
				if (!orderToSubtotal.containsKey(item.Order__c)) {
					orderToSubtotal.put(item.Order__c, 0);
				}
				//get Price for order
				orderToSubtotal.put(item.Order__c, orderToSubtotal.get(item.Order__c) + item.Total_Price__c);
			}

			List<Order__c> ordersToUpdate = new List<Order__c>();
			for (Id orderId : chargentOrderIds) {
				ordersToUpdate.add(
					//new subtotal for order
					new Order__c(
						Id = orderId, Subtotal__c = orderToSubtotal.get(orderId)
					)
				);
			}

			if (!ordersToUpdate.isEmpty()) {
				update ordersToUpdate;
			}
		}

		if (Trigger.isDelete){
			Set<Id> changedOrderIds = new Set<Id>();
			for (OrderItem__c item : Trigger.Old) {
				changedOrderIds.add(item.Order__c);
			}

			Map<Id, Decimal> subTotalOrder = new Map<Id, Decimal>();
			for (Id idOrder : changedOrderIds){
				subTotalOrder.put(idOrder, 0);
			}

			for (OrderItem__c orderItem : [SELECT Order__c, Total_Price__c FROM OrderItem__c WHERE Order__c IN :changedOrderIds]) {
				//get Price for order
				subTotalOrder.put(orderItem.Order__c, subTotalOrder.get(orderItem.Order__c) + orderItem.Total_Price__c);
			}

			List<Order__c> ordersToUpdate = new List<Order__c>();
			for (Id orderId : subTotalOrder.keySet()) {
				ordersToUpdate.add(
					//new subtotal for order
					new Order__c(
						Id = orderId, Subtotal__c = subTotalOrder.get(orderId)
					)
				);
			}

			if (!ordersToUpdate.isEmpty()) {
				update ordersToUpdate;
			}
		}

		// Calculate Number_of_Same_Product_Purchased__c (It is the same product on a different order)
		// Find all changed orders
		Set<Id> changedOrderIds = new Set<Id>();
		for (OrderItem__c item : Trigger.isDelete ? Trigger.Old : Trigger.New) {
			changedOrderIds.add(item.Order__c);
		}

		Set<Id> changedAccountIds = new Set<Id>();
		for (Order__c order : [SELECT Id, Account__c FROM Order__c WHERE Id IN: changedOrderIds AND Account__c != NULL]) {
			changedAccountIds.add(order.Account__c);
		}
		/*  Map<Id, Map<Id, Set<Id>>> accountProducts
			- Id - id account
			- Map<Id, Set<Id>> - map products of account
				- Id - id product
				- Set<Id> - id orders where use this product
		*/
		Map<Id, Map<Id, Set<Id>>> accountProducts = new Map<Id, Map<Id, Set<Id>>>();
		for (OrderItem__c item : [SELECT Id, Order__c, Order__r.Account__c, Product__c FROM OrderItem__c WHERE Order__r.Account__c IN: changedAccountIds]){
			if (!accountProducts.containsKey(item.Order__r.Account__c)) {
				accountProducts.put(item.Order__r.Account__c, new Map<Id, Set<Id>>());
			}
			if (!accountProducts.get(item.Order__r.Account__c).containsKey(item.Product__c)) {
				accountProducts.get(item.Order__r.Account__c).put(item.Product__c, new Set<Id>());
			}
			accountProducts.get(item.Order__r.Account__c).get(item.Product__c).add(item.Order__c);
		}

		List<Account> accounts = [SELECT Id, Number_of_Same_Product_Purchased__c FROM Account WHERE Id IN: changedAccountIds];
		for (Account account : accounts) {
			// Find Max Order count to Product
			Integer maxCount = 0;
			Map<Id, Set<Id>> products = accountProducts.get(account.Id) != null ? accountProducts.get(account.Id) : new Map<Id, Set<Id>>();
			for (Id product : products.keySet()){
				maxCount = products.get(product).size() > maxCount ? products.get(product).size() : maxCount;
			}
			account.Number_of_Same_Product_Purchased__c = maxCount == 1 ? 0 : maxCount;
		}

		update accounts;
	}
}