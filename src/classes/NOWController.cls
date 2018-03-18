public with sharing class NOWController {

	//Step 1 method. Find existing e-mail adress bellow, or prepare data for new account.
	@AuraEnabled
	public static Account getAccount(String strEmail) {
		Account newAccount = new Account();
		RecordType PersonAccount = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Customer_Account' LIMIT 1];

		//CRUD and FLS checking start
		Boolean isAccessableAccount = (
			Schema.sObjectType.Account.fields.Id.isAccessible() &&
			Schema.sObjectType.Account.fields.LastName.isAccessible() &&
			Schema.sObjectType.Account.fields.FirstName.isAccessible() &&
			Schema.sObjectType.Account.fields.BillingStreet.isAccessible() &&
			Schema.sObjectType.Account.fields.BillingCity.isAccessible() &&
			Schema.sObjectType.Account.fields.BillingPostalCode.isAccessible() &&
			Schema.sObjectType.Account.fields.BillingCountry.isAccessible() &&
			Schema.sObjectType.Account.fields.BillingState.isAccessible() &&
			Schema.sObjectType.Account.fields.ShippingStreet.isAccessible() &&
			Schema.sObjectType.Account.fields.ShippingCity.isAccessible() &&
			Schema.sObjectType.Account.fields.ShippingPostalCode.isAccessible() &&
			Schema.sObjectType.Account.fields.ShippingCountry.isAccessible() &&
			Schema.sObjectType.Account.fields.ShippingState.isAccessible() &&
			Schema.sObjectType.Account.fields.Phone.isAccessible() &&
			Schema.sObjectType.Account.fields.PersonEmail.isAccessible() &&
			Schema.sObjectType.Account.fields.Brand_Assortment__c.isAccessible() &&
			Schema.sObjectType.Account.fields.Blacklist__c.isAccessible()
		);
		//CRUD and FLS checking end

		if (isAccessableAccount) {
			if (String.isBlank(strEmail)) {
				newAccount.RecordTypeId = PersonAccount.Id;
				return newAccount;
			}

			if (strEmail != '') {
				String codeFields = TouchCRHelper.isSCPEnabled() == TRUE ? ' BillingStateCode, ShippingStateCode, BillingCountryCode, ShippingCountryCode, ' : '';

				String query = 
					'SELECT Id, LastName, FirstName, BillingStreet, BillingCity, BillingPostalCode, ' + codeFields + 
						'BillingCountry, ShippingStreet, ShippingCity,ShippingState, BillingState, Blacklist__c, ' +
						'ShippingPostalCode, ShippingCountry, Phone,' +
						'PersonEmail, Brand_Assortment__c, IsPersonAccount, Pricebook_Eligibility__c, ' +
						'ShippingLatitude, ShippingLongitude ' +
					'FROM Account ' +
					'WHERE PersonEmail =: strEmail ' +
					'LIMIT 1 ';

				 List<Account> newAccountList = Database.query(query);

				if (newAccountList.isEmpty()) {
					newAccount.RecordTypeId = PersonAccount.Id;
					newAccount.PersonEmail = strEmail;
					return newAccount;
				} else {
					newAccount = newAccountList[0];
					return newAccount;
				}
			}
			return null;
		} else {
			throw new System.NoAccessException();
		}
	}

	@AuraEnabled
	public static List<String> getAccountBrandPicklist() {
		List<PicklistEntry> ple = Schema.SObjectType.Account.fields.getMap().get('TouchCRBase__Brand_Assortment__c').getDescribe().getPicklistValues();
		List<String> brandValues= new List<String>();
		for (PicklistEntry pl : ple) {
			if (pl.isActive()) {
				brandValues.add(pl.getLabel()); 
			}
		}
		return brandValues;
	}

	@AuraEnabled
	public static Map<String, String> getAccountBillingCountryCodePicklist() {
		List<PicklistEntry> pleList = Schema.SObjectType.Account.fields.getMap().get('BillingCountryCode').getDescribe().getPicklistValues();
		Map<String, String> label2value = new Map<String, String>();
		for (PicklistEntry ple: pleList) {
			label2value.put(ple.getLabel(), ple.getValue());
		}
		return label2value;
	}

	@AuraEnabled
	public static List<String> getAccountShippingCountryPicklist() {
		List<PicklistEntry> pleList = Schema.SObjectType.Account.fields.getMap().get('ShippingCountryCode').getDescribe().getPicklistValues();
		List<String> result = new List<String>();
		for (PicklistEntry ple: pleList) {
			result.add(ple.getLabel());
		}
		return result;
	}


	@AuraEnabled
	public static List<String> getAccountShippingStatePicklist(String country) {
		
		Map<String, TouchCRHelper.PicklistEntryWrapper> response = TouchCRHelper.getAvailableStatesAndCountries();
		List<String> result = new List<String>();
		List<String> keyList = new List<String>(response.keySet());
		for(Integer i=0; i < response.size(); i++) {
			List<String> states = response.get(keyList[i]).states.values();
			List<String> newStates = new List<String>();
			String newKey = response.get(keyList[i]).label.replace('+', ' ');
			for(String st : states) {
				newStates.add(st.replace('+', ' '));
			}
			if(newKey == country){
			return newStates;
			}
		}

		return null;
	}
   

	@AuraEnabled
	public static Account saveAccount(Map<String, String> fieldsOfAccount) {
		System.debug(fieldsOfAccount);
		//CRUD and FLS checking start
		Boolean isCreateableAccount = (
			Schema.sObjectType.Account.fields.LastName.isCreateable() &&
			Schema.sObjectType.Account.fields.LastName.isUpdateable() &&
			Schema.sObjectType.Account.fields.FirstName.isCreateable() &&
			Schema.sObjectType.Account.fields.FirstName.isUpdateable() &&
			Schema.sObjectType.Account.fields.BillingStreet.isCreateable() &&
			Schema.sObjectType.Account.fields.BillingStreet.isUpdateable() &&
			Schema.sObjectType.Account.fields.BillingCity.isCreateable() &&
			Schema.sObjectType.Account.fields.BillingCity.isUpdateable() &&
			Schema.sObjectType.Account.fields.BillingPostalCode.isCreateable() &&
			Schema.sObjectType.Account.fields.BillingPostalCode.isUpdateable() &&
			Schema.sObjectType.Account.fields.BillingCountry.isCreateable() &&
			Schema.sObjectType.Account.fields.BillingCountry.isUpdateable() &&
			Schema.sObjectType.Account.fields.BillingState.isCreateable() &&
			Schema.sObjectType.Account.fields.BillingState.isUpdateable() &&
			Schema.sObjectType.Account.fields.ShippingStreet.isCreateable() &&
			Schema.sObjectType.Account.fields.ShippingCity.isCreateable() &&
			Schema.sObjectType.Account.fields.ShippingStreet.isUpdateable() &&
			Schema.sObjectType.Account.fields.ShippingPostalCode.isCreateable() &&
			Schema.sObjectType.Account.fields.ShippingCity.isUpdateable() &&
			Schema.sObjectType.Account.fields.ShippingPostalCode.isUpdateable() &&
			Schema.sObjectType.Account.fields.ShippingCountry.isCreateable() &&
			Schema.sObjectType.Account.fields.Phone.isCreateable() &&
			Schema.sObjectType.Account.fields.ShippingCountry.isUpdateable() &&
			Schema.sObjectType.Account.fields.ShippingState.isCreateable() &&
			Schema.sObjectType.Account.fields.ShippingState.isUpdateable() &&
			Schema.sObjectType.Account.fields.Phone.isUpdateable() &&
			Schema.sObjectType.Account.fields.PersonEmail.isCreateable() &&
			Schema.sObjectType.Account.fields.PersonEmail.isUpdateable() &&
			Schema.sObjectType.Account.fields.ShippingLatitude.isCreateable() &&
			Schema.sObjectType.Account.fields.ShippingLatitude.isUpdateable() &&
			Schema.sObjectType.Account.fields.ShippingLongitude.isCreateable() &&
			Schema.sObjectType.Account.fields.ShippingLongitude.isUpdateable() &&
			Schema.sObjectType.Account.fields.Brand_Assortment__c.isCreateable() &&
			Schema.sObjectType.Account.fields.Brand_Assortment__c.isUpdateable() &&
			Schema.sObjectType.Account.fields.RecordTypeId.isCreateable() &&
			Schema.sObjectType.Account.fields.RecordTypeId.isUpdateable()
		);
		System.debug(isCreateableAccount);
		//CRUD and FLS checking end
		if (isCreateableAccount) {
			RecordType accRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer_Account' AND SobjectType = 'Account' AND IsPersonType = true AND IsActive = true LIMIT 1];
			Account accountItem = fieldsOfAccount.containsKey('Id') ? new Account(Id = fieldsOfAccount.get('Id')) : new Account();
			accountItem.FirstName = fieldsOfAccount.containsKey('FirstName') ? fieldsOfAccount.get('FirstName') : null;
			accountItem.LastName = fieldsOfAccount.containsKey('LastName') ? fieldsOfAccount.get('LastName') : null;
			accountItem.PersonEmail = fieldsOfAccount.containsKey('PersonEmail') ? fieldsOfAccount.get('PersonEmail') : null;
			accountItem.Phone = fieldsOfAccount.containsKey('Phone') ? fieldsOfAccount.get('Phone') : null;
			accountItem.BillingStreet = fieldsOfAccount.containsKey('BillingStreet') ? fieldsOfAccount.get('BillingStreet') : null;
			accountItem.BillingCity = fieldsOfAccount.containsKey('BillingCity') ? fieldsOfAccount.get('BillingCity') : null;
			accountItem.BillingState = fieldsOfAccount.containsKey('BillingState') ? fieldsOfAccount.get('BillingState') : null; 
			accountItem.BillingPostalCode = fieldsOfAccount.containsKey('BillingPostalCode') ? fieldsOfAccount.get('BillingPostalCode') : null;
			accountItem.ShippingStreet = fieldsOfAccount.containsKey('ShippingStreet') ? fieldsOfAccount.get('ShippingStreet') : null;
			accountItem.ShippingCity = fieldsOfAccount.containsKey('ShippingCity') ? fieldsOfAccount.get('ShippingCity') : null;
			accountItem.ShippingState = fieldsOfAccount.containsKey('ShippingState') ? fieldsOfAccount.get('ShippingState') : null;
			accountItem.ShippingPostalCode = fieldsOfAccount.containsKey('ShippingPostalCode') ? fieldsOfAccount.get('ShippingPostalCode') : null;
			accountItem.Brand_Assortment__c = fieldsOfAccount.containsKey('Brand') ? fieldsOfAccount.get('Brand') : null;
			accountItem.BillingCountry = fieldsOfAccount.containsKey('BillingCountry') ? fieldsOfAccount.get('BillingCountry') : null;
			accountItem.ShippingCountry = fieldsOfAccount.containsKey('ShippingCountry') ? fieldsOfAccount.get('ShippingCountry') : null;
			accountItem.ShippingLatitude = fieldsOfAccount.containsKey('Latitude') ? Decimal.valueOf(fieldsOfAccount.get('Latitude')) : null;
			accountItem.ShippingLongitude = fieldsOfAccount.containsKey('Longitude') ? Decimal.valueOf(fieldsOfAccount.get('Longitude')) : null;
			accountItem.RecordTypeId = fieldsOfAccount.containsKey('RecordTypeId') ? fieldsOfAccount.get('RecordTypeId') : accRT.Id;

			if (TouchCRHelper.isSCPEnabled()) {
				accountItem.put('BillingStateCode', fieldsOfAccount.containsKey('BillingStateCode') ? fieldsOfAccount.get('BillingStateCode') : null);
				accountItem.put('ShippingStateCode', fieldsOfAccount.containsKey('ShippingStateCode') ? fieldsOfAccount.get('ShippingStateCode') : null);
			}
			System.debug(accountItem);
			upsert accountItem;
			System.debug(accountItem);
			return accountItem;
		} else {
			System.debug('error');
			throw new System.NoAccessException();
		}
	}

	@AuraEnabled
	public static List<NOWNode> getVariants(Account newAccount) {
		String accountId = newAccount.Id;

		List<NOWNode> result = new List<NOWNode>();
		Map<Id, Set<Id>> categoryIdToSetProductsId = new Map<Id, Set<Id>>();

		Map<Id, Pricebook2> pricebook2IdMap = new Map<Id, Pricebook2>();
		Map<Id, PricebookEntry> pricebookEntryIdMap = new Map<Id, PricebookEntry>();
		Map<Id, PricebookEntry> productIdToPricebookEntryIdMap = new Map<Id, PricebookEntry>();

		Map<Id, String> categoryIdToCategoryNameMap = new Map<Id, String>();
		Map<Id, Product2> productIdToProductMap = new Map<Id, Product2>();

		////CRUD and FLS checking start
		Boolean isAccessableAccount = (
			Schema.sObjectType.Pricebook2.fields.Id.isAccessible() &&
			Schema.sObjectType.Pricebook2.fields.Name.isAccessible()
		);
		////CRUD and FLS checking end
		if (!isAccessableAccount) {
			throw new System.NoAccessException();
		}

		pricebook2IdMap = new Map<Id, Pricebook2>([
			SELECT Id, Name
			FROM Pricebook2
			WHERE IsActive = true
			AND Name = 'Standard Price Book'
		]);

		Id pricebookId;
		if(newAccount.Pricebook_Eligibility__c == null) {
			//CRUD and FLS checking start
			isAccessableAccount = (
				Schema.sObjectType.Account.fields.Id.isAccessible() &&
				Schema.sObjectType.Account.fields.LastName.isAccessible() &&
				Schema.sObjectType.Account.fields.FirstName.isAccessible() &&
				Schema.sObjectType.Account.fields.BillingStreet.isAccessible() &&
				Schema.sObjectType.Account.fields.BillingCity.isAccessible() &&
				Schema.sObjectType.Account.fields.BillingPostalCode.isAccessible() &&
				Schema.sObjectType.Account.fields.BillingCountry.isAccessible() &&
				Schema.sObjectType.Account.fields.ShippingStreet.isAccessible() &&
				Schema.sObjectType.Account.fields.ShippingCity.isAccessible() &&
				Schema.sObjectType.Account.fields.ShippingPostalCode.isAccessible() &&
				Schema.sObjectType.Account.fields.ShippingCountry.isAccessible() &&
				Schema.sObjectType.Account.fields.Phone.isAccessible() &&
				Schema.sObjectType.Account.fields.PersonEmail.isAccessible() &&
				Schema.sObjectType.Account.fields.Brand_Assortment__c.isAccessible()
			);
			//CRUD and FLS checking end

			if (!isAccessableAccount) {
				throw new System.NoAccessException();
			}

			String codeFields = TouchCRHelper.isSCPEnabled() == TRUE ? ' BillingStateCode, ShippingStateCode, ShippingCountryCode, BillingCountryCode, ' : '';

			String query = 
				'SELECT Id, LastName, FirstName, BillingStreet, BillingCity, BillingPostalCode, ' + codeFields + 
					'BillingCountry, ShippingStreet, ShippingCity, ' +
					'ShippingPostalCode, ShippingCountry, Phone, ' +
					'PersonEmail, Brand_Assortment__c, IsPersonAccount, ' +
					'Pricebook_Eligibility__c ' +
				'FROM Account ' +
				'WHERE Id =: accountId ' +
				'LIMIT 1 ';
			newAccount = Database.query(query);
		}

		pricebookId = !pricebook2IdMap.isEmpty() ? pricebook2IdMap.values()[0].Id : null;
		if (pricebookId == null) {
			return result;
		}

		//CRUD and FLS checking start
		isAccessableAccount = (
			Schema.sObjectType.PricebookEntry.fields.Id.isAccessible() &&
			Schema.sObjectType.PricebookEntry.fields.Name.isAccessible() &&
			Schema.sObjectType.PricebookEntry.fields.Pricebook2Id.isAccessible() &&
			Schema.sObjectType.PricebookEntry.fields.Product2Id.isAccessible() &&
			Schema.sObjectType.PricebookEntry.fields.UnitPrice.isAccessible() //&&
		);
		//CRUD and FLS checking end

		if (!isAccessableAccount) {
			throw new System.NoAccessException();
		}

		pricebookEntryIdMap = new Map<Id, PricebookEntry>([
			SELECT Id, Name, Pricebook2Id, Pricebook2.Name, Product2Id,
				Product2.Name, UnitPrice
			FROM PricebookEntry
			WHERE IsActive = true
			AND Product2Id != null
			AND Product2.isActive = true
			AND Pricebook2Id = :pricebookId
		]);

		List<Product_Category__c> productCategories = [
			SELECT Id, Name, Category__c, Product__c, Category_Name__c
			FROM Product_Category__c
		];

		for (Product_Category__c pC : productCategories) {
			if (String.isNotBlank(pC.Product__c)) {
				if (categoryIdToSetProductsId.containsKey(pC.Category__c)) {
					Set<Id> productsToCategory = categoryIdToSetProductsId.get(pC.Category__c);
					productsToCategory.add(pC.Product__c);
				} else {
					categoryIdToSetProductsId.put(pC.Category__c, new Set<Id>{pC.Product__c});
				}
			}

			categoryIdToCategoryNameMap.put(pC.Category__c, pC.Category_Name__c);
		}

		for (Id pricebookEntryId : pricebookEntryIdMap.keySet()) {
			PricebookEntry pbEntry = pricebookEntryIdMap.get(pricebookEntryId);
			//product id to product map
			productIdToProductMap.put(pbEntry.Product2Id, pbEntry.Product2);
			productIdToPricebookEntryIdMap.put(pbEntry.Product2Id, pbEntry);
		}
		//no variants inside category
		if (categoryIdToSetProductsId.isEmpty() || categoryIdToCategoryNameMap.isEmpty()) {
			return result;
		}
		for (Id catId : categoryIdToSetProductsId.keySet()) {
			Set<Id> productsId = categoryIdToSetProductsId.get(catId);
			if (!productsId.isEmpty()) {
				result.addAll(createNodes(catId, categoryIdToSetProductsId, categoryIdToCategoryNameMap, productIdToProductMap, productIdToPricebookEntryIdMap));
			}
		}
		//check for size, no more that 1k records
		if (result.size() > 1000) {
			result = new List<NOWNode>();
		}
		return result;
	}

	private static List<NOWNode> createNodes(Id categoryId, Map<Id, Set<Id>> categoryIdToSetProductsId,
		Map<Id, String> categoryIdToCategoryNameMap, Map<Id, Product2> productIdToProductMap,
		Map<Id, PricebookEntry> productIdToPricebookEntryIdMap) {

		Integer level = 0;
		List<NOWNode> result = new List<NOWNode>();
		//is this cat has child cats
		if (categoryIdToCategoryNameMap.containsKey(categoryId)) {
			//Category node
			NOWNode aCatNode = new NOWNode();
			aCatNode.name = categoryIdToCategoryNameMap.get(categoryId);
			aCatNode.id = categoryId;
			aCatNode.level = level;
			aCatNode.toplevel = (level == 0) ? 'top' : '';
			aCatNode.isCategory = true;
			result.add(aCatNode);
			//if this category has products
			if (categoryIdToSetProductsId.containsKey(categoryId)) {
				Set<Id> productIds = categoryIdToSetProductsId.get(categoryId);
				List<Product2> products = new List<Product2>();
				for (Id productId : productIds) {
					if (productIdToProductMap.containsKey(productId)) {
						Product2 aProduct = productIdToProductMap.get(productId);
						products.add(aProduct);
					}
				}
				products.sort();
				for (Product2 aProduct : products) {
					NOWNode aProdNode = new NOWNode();
					aProdNode.name = aProduct.Name;
					aProdNode.parentid = aCatNode.id;
					aProdNode.id = aProduct.Id + aCatNode.id;
					aProdNode.level = level + 1;
					aProdNode.isCategory = false;
					aProdNode.isProduct = true;
					aProdNode.productid = aProduct.Id;
					aProdNode.price =  productIdToPricebookEntryIdMap.get(aProduct.Id).UnitPrice;
					aProdNode.productPrice = productIdToPricebookEntryIdMap.get(aProduct.Id).UnitPrice;
					result.add(aProdNode);
				}
			}
		}
		return result;
	}

	@AuraEnabled
	public static List<String> getInputElementAmount(String StandardInfoJSON, String NodeJSON) {
		Decimal resultSum = 0;
		Decimal resultSumGst = 0;
		Decimal resultSumProductPrice = 0;
		List<String> result = new List<String>();
		List<StandardWrapper> listStand = (List<StandardWrapper>)JSON.deserialize(StandardInfoJSON, List<StandardWrapper>.class);
		List<NOWNode> listNode = (List<NOWNode>)JSON.deserialize(NodeJSON, List<NOWNode>.class);
		Map<String, String> newMapIdToCount = new Map<String, String>();
		Map<String, NOWNode> newMapIdToNode = new Map<String, NOWNode>();

		List<Integer> counts = new List<Integer>();
		List<String> productIds = new List<String>();
		List<String> productVariantIds = new List<String>();
		List<Decimal> unitPrices = new List<Decimal>();
		List<Decimal> allGST = new List<Decimal>();

		for (StandardWrapper item : listStand) {
			if (!newMapIdToCount.containsKey(item.id)) {
				newMapIdToCount.put(item.id, '0');
			}
			Integer value = Integer.valueOf(newMapIdToCount.get(item.id)) + Integer.valueOf(item.value);
			newMapIdToCount.put(item.id, String.valueOf(value));
		}

		for (NOWNode item : listNode) {
			if (!newMapIdToNode.containsKey(item.id)) {
				newMapIdToNode.put(item.id, item);
			}
		}

		for (String item : newMapIdToCount.keySet()) {
			String amountStr = newMapIdToCount.get(item);
			Integer amount = Integer.valueOf(amountStr);
			NOWNode aNode = newMapIdToNode.get(item);

			if (aNode != NULL) {
				//GST + Price
				Decimal price = 0.00;
				if (aNode.price != NULL) {
					price = aNode.price;
					resultSum += price * amount;
				}

				//GST
				Decimal gst = aNode.gst;

				//Price is not inclusive of GST
				Decimal productPrice = aNode.productPrice;
				resultSumProductPrice += productPrice * amount;

				counts.add(amount);
				productIds.add(aNode.productid);
				productVariantIds.add(aNode.id);
				unitPrices.add(productPrice);
				allGST.add(aNode.gst);
			}
		}

		result.add(String.valueOf(resultSum));
		result.add(String.join(productIds, '~'));
		result.add(String.join(productVariantIds, '~'));
		result.add(String.join(counts, '~'));
		result.add(String.join(unitPrices, '~'));
		result.add(String.join(allGST, '~'));
		result.add(String.valueOf(resultSumGst));
		result.add(String.valueOf(resultSumProductPrice));
		return result;
	}

	@AuraEnabled
	public static List<Decimal> getValidateAccount(String Id) {
		List<Decimal> result = new List<Decimal>();
		//TO DO
		Decimal shippingCost = 0;
		Decimal saleTax = 0;
		result.add(shippingCost);
		result.add(saleTax);
		return result;
	}

	@AuraEnabled
	public static List<String> addCoolCube(List<String> price, Map<String, String> cubeInfo) {
		List<String> result = new List<String>();

		String resultSum = price[0];
		String[] products = price[1].split('~');
		String[] quantities = price[3].split('~');
		String[] itemsPrice = price[4].split('~');
		String[] allGST = price[5].split('~');

		String resultSumGst = price[6];
		String resultSumProductPrice = price[7];

		Id idCoolCube = Id.valueOf(cubeInfo.get('productId'));

		Boolean cubeAlreadyOrdered = false;

		for (Integer i = 0; i < products.size(); i++) {
			Id idProduct = Id.valueOf(products[i]);
			if (idCoolCube == idProduct) {
				cubeAlreadyOrdered = true;
				quantities[i] = String.valueOf(Integer.valueOf(quantities[i]) + Integer.valueOf(cubeInfo.get('offerprice')));
			}
		}

		if (!cubeAlreadyOrdered) {
			products.add(cubeInfo.get('productId'));
			quantities.add(cubeInfo.get('offerprice'));
			itemsPrice.add(cubeInfo.get('productPrice'));
			allGST.add(cubeInfo.get('gst'));
		}

		resultSum = String.valueOf(Decimal.valueOf(resultSum) + Integer.valueOf(cubeInfo.get('offerprice')) * Decimal.valueOf(cubeInfo.get('unitPrice')));
		resultSumGst = String.valueOf(Decimal.valueOf(resultSumGst) + Integer.valueOf(cubeInfo.get('offerprice')) * Decimal.valueOf(cubeInfo.get('gst')));
		resultSumProductPrice = String.valueOf(Decimal.valueOf(resultSumProductPrice) + Integer.valueOf(cubeInfo.get('offerprice')) * Decimal.valueOf(cubeInfo.get('productPrice')));

		result.add(String.valueOf(resultSum));
		result.add(String.join(products, '~'));
		result.add(price[2]);
		result.add(String.join(quantities, '~'));
		result.add(String.join(itemsPrice, '~'));
		result.add(String.join(allGST, '~'));
		result.add(String.valueOf(resultSumGst));
		result.add(String.valueOf(resultSumProductPrice));
		return result;
	}

	@AuraEnabled
	public static List<String> payment(String newOrderForm, Account accValues) {
		List<String> result = new List<String>();
		Id orderId = NULL;
		orderFormData orderForm = (orderFormData)JSON.deserialize(newOrderForm, orderFormData.class);
		Map<String, String> orderFormDataMap = new Map<String, String>();
		orderFormDataMap.put('accountId', accValues.Id);
		orderFormDataMap.put('billingStreet', accValues.BillingStreet);
		orderFormDataMap.put('billingCity', accValues.BillingCity);
		orderFormDataMap.put('billingPostalCode', accValues.BillingPostalCode);
		orderFormDataMap.put('shippingStreet', accValues.ShippingStreet);
		orderFormDataMap.put('shippingCity', accValues.ShippingCity);
		orderFormDataMap.put('shippingPostalCode', accValues.ShippingPostalCode);
		orderFormDataMap.put('shippingState', accValues.ShippingState);
		orderFormDataMap.put('shippingCountry', accValues.ShippingCountry);
		orderFormDataMap.put('orderTotal', orderForm.total);
		if(orderForm.couponDiscount != null) {orderFormDataMap.put('couponDiscount', orderForm.couponDiscount);}

		orderFormDataMap.put('orderSource', 'Now');
		if(orderForm.orderType == null) {
		orderFormDataMap.put('orderType', 'Standard');
		}
		if(orderForm.orderType != null) {
		orderFormDataMap.put('orderType', orderForm.orderType);
		}
		if (TouchCRHelper.isSCPEnabled()) {
			orderFormDataMap.put('billingStateCode', (String)accValues.get('BillingStateCode'));
			orderFormDataMap.put('billingCountryCode', (String)accValues.get('BillingCountryCode'));
			orderFormDataMap.put('shippingStateCode', (String)accValues.get('ShippingStateCode'));
			orderFormDataMap.put('shippingCountryCode', (String)accValues.get('ShippingCountryCode'));
		}
		List<Map<String,Object>> products = new List<Map<String,Object>>();
		List<String> productList = orderForm.product_id.split('~');
		List<String> quantityList = orderForm.quantity.split('~');

		for (Integer i = 0; i < productList.size(); i++) {
			if (productList[i] != NULL && quantityList[i] != NULL) {
				products.add(
					new Map<String,Object>{
						'productId' => productList[i],
						'count' => Decimal.valueOf(quantityList[i])
					}
				);
			}
		}
		List<Map<String, Object>> bumpOffers = new List<Map<String, Object>>();
		List<String> bumpOffersList = orderForm.bumpOffers_id;
		List<String> quantityBumpList = orderForm.quantityBump;

		for (Integer i = 0; i < bumpOffersList.size(); i++) {
			if ((bumpOffersList[i] != null) &&  (quantityBumpList[i] != null)) {
				bumpOffers.add(
					new Map<String, Object>{
						'orderFormId' => bumpOffersList[i],
						'count' => quantityBumpList[i]

				});
			}
		}

		List<String> couponsIds = orderForm.coupon_id;
		List<Map<String,String>> coupons = new List<Map<String,String>>();

		for(Integer i = 0; i < couponsIds.size(); i++) {
			Coupon__c coupon = CouponHelper.getCouponByCouponId(couponsIds[i]);
			Product2 prod = CouponHelper.getCouponProductByBrand(orderForm.brand);
			Product_Variant__c pv = CouponHelper.getCouponProductVariant(coupon.Product__c , coupon.Name);
			coupons.add(new Map<String, String>{
			'productId' => prod.Id,
			'productVariantId' => pv.Id,
			'count' => '1',
			'price' => String.valueOf(-coupon.Discount_Amount__c),
			'couponId' => coupon.Id
			});
			
		}

		Map<String,Object> dataForOrderItems = new Map<String,Object>();
		dataForOrderItems.put('products', products);
		dataForOrderItems.put('coupons' , coupons);
		dataForOrderItems.put('bumpOffers' , bumpOffers);

		Map<String,Object> responseMap = new Map<String,Object>();
		responseMap.put('method', 'setOrder');
		responseMap.put('generalData', orderFormDataMap);
		responseMap.put('dataForOrderItems', dataForOrderItems);

		String jsonResponce = JSON.serialize(responseMap);
		String newOrder = RestCallsV2.doPost(jsonResponce);
		Map<String,Object> orderResult = (Map<String, Object>)JSON.deserializeUntyped(newOrder);
		if (orderResult.get('message') == 'success') {
			orderId = (Id)orderResult.get('orderId');
		}
		else if (orderResult.get('message') == 'error') {
			result.add('error');
			result.add((String)orderResult.get('error'));
			return result;
		}

		//CRUD and FLS checking start
		Boolean isAccessableAccount = (
			Schema.sObjectType.Order__c.fields.Id.isAccessible() &&
			Schema.sObjectType.Order__c.fields.Name.isAccessible()
		);
		//CRUD and FLS checking end

		if (!isAccessableAccount) {
			throw new System.NoAccessException();
		}

		List<Order__c> orderlist = [SELECT Id, Name FROM Order__c WHERE Id =: orderId LIMIT 1];
		
		if (orderlist.isEmpty()) {
			result.add('error');
			result.add(orderId);
			return result;
		} else {
			result.add(String.valueOf(orderlist[0].Id));
			result.add(String.valueOf(orderlist[0].Name));
			return result;
		}
	}

	@AuraEnabled
	public static String lastStep(List<String> orderId, String accountEmail, String newOrderForm) {
		orderFormData orderForm = (orderFormData)JSON.deserialize(newOrderForm, orderFormData.class);
		Map<String,String> creditCard = new Map<String,String>{
			'CardId' => orderForm.cc_id,
			'Profile' => orderForm.token,
			'CardNumber' => orderForm.cc_number,
			'CardCCV' => orderForm.security_code,
			'CardExpirationMonth' => orderForm.cc_exp_month,
			'CardExpirationYear' => orderForm.cc_exp_year
		};
		Map<String, String> generalData = new Map<String, String> {
			'orderId' => String.valueOf(orderId[0])
		};
		Map<String, Object> chargData = new Map<String, Object>{
			'method' => 'chargeOrder',
			'generalData' => (Map<String, String>)generalData,
			'creditCard' => (Map<String, String>)creditCard
		};

		String result = RestCallsV2.doPost(JSON.serialize(chargData));
		if (result.contains('true') && result.contains('success')) {
			sendEmail(accountEmail);
			return 'Your order has been processed successfully!';
		} else {
			return 'Error Transaction Service Unavailable';
		}
	}

	@AuraEnabled
	public static void sendEmail(String accountEmail) {
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.subject = 'Order Complete';
		message.plainTextBody = 'Thank you for your order.';
		message.toAddresses = new String[] {accountEmail};
		Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
	}

	public static String getAccountPicklistValueToLabel(String pField, String pValue) {
		String result;
		List<PicklistEntry> ple = Schema.SObjectType.Account.fields.getMap().get(pField).getDescribe().getPicklistValues();
		Map<String, String> value2label = new Map<String, String>();
		for (PicklistEntry pl : ple) {
			if (pl.isActive()) {
				value2label.put(pl.getValue(), pl.getLabel());
			}
			if (pl.isDefaultValue()) {
				value2label.put('defaultValue', pl.getLabel());
			}
		}
		if (value2label.containsKey(pValue)) {
			result = value2label.get(pValue);
		}
		else {
			result = value2label.get('defaultValue');
		}
		return result;
	}

	@AuraEnabled
	public static List<String> checkOldCreditCard(String accountId) {
		List<String> result = new List<String>();
		Order_Transaction__c oldOrderTransacion = new Order_Transaction__c();

			List<Order_Transaction__c> ordersTransactionList = [
				SELECT Id, Order__c, Payment_Profile__c, Payment_Response_Body__c,
					Payment_Date__c, Type__c, Named_Agent__c, Card_Last_4__c,
					Response_Status__c, Payment_Entity_Id__c
				FROM Order_Transaction__c
				WHERE Order__r.Account__c =: accountId
				ORDER BY CreatedDate DESC
			];

			if (ordersTransactionList.isEmpty()) {
				result.add('notShowPreviousCard');
				return result;
			}

			oldOrderTransacion = ordersTransactionList[0];

			if (oldOrderTransacion.Card_Last_4__c != NULL &&
			oldOrderTransacion.Payment_Profile__c != NULL &&
			oldOrderTransacion.Payment_Entity_Id__c != NULL) {

				result.add('showPreviousCard');

				result.add(oldOrderTransacion.Card_Last_4__c);
				result.add(oldOrderTransacion.Payment_Entity_Id__c);
				result.add(oldOrderTransacion.Payment_Profile__c);

				return result;
			}
			else {
				result.add('notShowPreviousCard');
				return result;
			}
	}
	@AuraEnabled 
	public static Map<String, Object> checkCoupon(String generalData) {
		couponData cd = (couponData) JSON.deserialize(generalData, couponData.class);
		Map<String,String> couponInfo = new Map<String,String>{
			'couponCode' => cd.couponCode,
			'amount' => cd.amount,
			'accountId' => cd.accountId,
			'brand' => cd.brand,
			'autoApply' => cd.autoApply
		};
		Map<String,Object> mapForController = new Map<String,Object>{
			'method' => 'getCoupon',
			'generalData' => couponInfo
		};
		String JSONresult = RestCallsV2.doGet(JSON.serialize(mapForController));
		Map<String, Object> couponMessage = (Map<String, Object>)JSON.deserializeUntyped(JSONResult);

		return couponMessage;
	}

	@AuraEnabled
	public static List<Object> getBumpOffers() {
		List<OrderForm__c> bumpOffersList = [SELECT Id, Name, Type__c, Active__c, Brand_Assortment__c,
								Offer_Price__c, ProductTobeSold__r.Id, Product_Standard_Price__c FROM OrderForm__c WHERE Active__c = true AND Order_Form_Type__c = 'Bump_Offer'];
		return bumpOffersList;							

	} 

	@AuraEnabled
	public static List<Object> getUpsells() {
		List<OrderForm__c> upsellList = [SELECT Id, Name, Type__c, Active__c, Brand_Assortment__c,
								Offer_Price__c, ProductTobeSold__r.Id, Product_Standard_Price__c, Order__c FROM OrderForm__c WHERE Active__c = true AND Order_Form_Type__c = 'Upsell' ORDER BY Order__c ASC];
		return upsellList;	

	}
	@AuraEnabled
	public static String insertUpsellOrder(String upsellData) {
		generalUpsellData gud = (generalUpsellData) JSON.deserialize(upsellData, generalUpsellData.class);
		String orderId = gud.orderId;
		Decimal price = gud.price;
		Decimal shipping = gud.shipping;
		Decimal tax = gud.tax;
		String product_id = gud.product_id;
		Decimal quantity = gud.quantity;

		Map<String,Object> inputData = new Map<String,Object>{
			'method' => 'addUpsell',
			'orderId' => gud.orderId,
			'price' => gud.price,
			'shipping' => gud.shipping,
			'tax' => gud.tax,
			'product_id' => gud.product_id,
			'quantity' => 1
		};

		String upsellOrderId = RestCalls.doPost(JSON.serialize(inputData));

		return upsellOrderId;
	}

	@AuraEnabled
	public static String upsellPayment(String upselOrderId) {

		Map<String, Object> chargData = new Map<String, Object>{
			'method' => 'chargeUpsell',
			'orderId' => upselOrderId
			};

		String result = RestCalls.doPost(JSON.serialize(chargData));

		return result;

	}

	public class generalUpsellData {
		@AuraEnabled
		public String orderId { get; set; }
		@AuraEnabled
		public Decimal price { get; set; }
		@AuraEnabled
		public Decimal shipping { get; set; }
		@AuraEnabled
		public Decimal tax { get; set; }
		@AuraEnabled
		public String product_id { get; set; }
		@AuraEnabled
		public Decimal quantity { get; set; }

		public generalUpsellData() {}
	}

	public class couponData {
		@AuraEnabled
		public String couponCode { get; set; }
		@AuraEnabled
		public String amount { get; set; }
		@AuraEnabled
		public String accountId { get; set; }
		@AuraEnabled
		public String brand { get; set; }
		@AuraEnabled
		public String autoApply { get; set; }

		public couponData() {}
	}

	public class StandardWrapper {
		@AuraEnabled
		public String id { get; set; }
		@AuraEnabled
		public String value { get; set; }

		public StandardWrapper() {}
	}

	public class orderFormData {
		@AuraEnabled
		public String orderType { get; set; }
		@AuraEnabled
		public String parrentUpsellOrderId { get; set; }
		@AuraEnabled
		public List<String> orderFormId { get; set; }
		@AuraEnabled
		public List<String> count { get; set; }
		/*@AuraEnabled
		public List<Object> couponsObj { get; set; }*/
		@AuraEnabled
		public List<String> bumpOffers_id { get; set; }
		@AuraEnabled
		public List<String> quantityBump { get; set; }
		@AuraEnabled
		public List<String> coupon_id { get; set; }
		@AuraEnabled
		public String product_id { get; set; }
		@AuraEnabled
		public String email { get; set; }
		@AuraEnabled
		public String fname { get; set; }
		@AuraEnabled
		public String lname { get; set; }
		@AuraEnabled
		public String phone { get; set; }
		@AuraEnabled
		public String cc_id { get; set; }
		@AuraEnabled
		public String cc_number { get; set; }
		@AuraEnabled
		public String security_code { get; set; }
		@AuraEnabled
		public String cc_exp_month { get; set; }
		@AuraEnabled
		public String cc_exp_year { get; set; }
		@AuraEnabled
		public String cc_type { get; set; }
		@AuraEnabled
		public String tax { get; set; }
		@AuraEnabled
		public String subtotal { get; set; }
		@AuraEnabled
		public String total { get; set; }
		@AuraEnabled
		public String shipping { get; set; }
		@AuraEnabled
		public String quantity { get; set; }
		@AuraEnabled
		public String offerprice { get; set; }
		@AuraEnabled
		public String gst { get; set; }
		@AuraEnabled
		public String token { get; set; }
		@AuraEnabled
		public String brand { get; set; }
		@AuraEnabled
		public String deliveryDate { get; set; }
		@AuraEnabled
		public String timeStart { get; set; }
		@AuraEnabled
		public String timeEnd { get; set; }
		@AuraEnabled
		public String deliveryType { get; set; }
		@AuraEnabled
		public String longitude { get; set; }
		@AuraEnabled
		public String latitude { get; set; }
		@AuraEnabled
		public String couponDiscount { get; set; }

		public orderFormData() {}
	}
}