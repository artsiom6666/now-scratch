public with sharing class NewOrderProcessController {

	public Account itemAccount { get; set; }
	public List<Order_Transaction__c> chargentOrdersList { get; set; }
	public List<Order__c> orderlist { get; set; }
	public Map<String, String> brandToGateway { get; set; }
	public String orderId { get; set; }
	public String nameOrder { get; set; }
	public String statusTransaction { get; set; }

	public Integer step { get; set; }
	public String finishUrl { get; set; }

	/* string items for page */
	public String strEmail { get; set; }
	public String fName { get; set; }
	public String lName { get; set; }
	public String last4 { get; set; }
	public String cardId { get; set; }
	public String errorStatus { get; set; }

	/*  checkbox */
	public Boolean address { get; set; }
	public Boolean choiceCheckout { get; set; }
	public Boolean choiceCard { get; set; }

	/*  count   */
	public Decimal itemCount { get; set; }
	public Decimal totalCount {get;set;}
	public Decimal saleTax { get; set; }
	public Decimal shippingCost { get; set; }
	public String token { get; set; }

	/* Credit Card info */
	public String cardType { get; set; }
	public String firstName { get; set; }
	public String lastName { get; set; }
	public String cardNamber { get; set; }
	public String cardExpirationYear { get; set; }
	public String cardExpirationMonth { get; set; }
	public String ccv { get; set; }

	public List<Integer> countList = new List<Integer>();
	public List<String> productIdList = new List<String>();
	public List<String> productVarianIdList = new List<String>();
	public List<Decimal> unitPriceList = new List<Decimal>();

	public String couponCode {get;set;}
	public Decimal couponDiscount {get;set;}
	public Id couponId {get;set;}

	public List<Map<String,String>> coupons {get;set;}

	public List<SelectOption> countries {get;set;}
	public List<SelectOption> billingStates {get;set;}
	public List<SelectOption> shippingStates {get;set;}

	private ApexPages.StandardController stdController {get;set;}

	public NewOrderProcessController(ApexPages.StandardController stdController) {
		this.coupons = new List<Map<String,String>>();
		this.step = 1;
		this.address = true;
		this.stdController = stdController;

		brandToGateway = TouchCRConfigurationController.collectionBrandToGateway();
		this.brandSelect = new Account();

		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Account',
				'NewOrderProcessController.cls [NewOrderProcessController]',
				new List<Schema.DescribeFieldResult> {
					Account.LastName.getDescribe(), Account.FirstName.getDescribe(),
					Account.BillingStreet.getDescribe(), Account.BillingCity.getDescribe(),
					Account.BillingPostalCode.getDescribe(), Account.BillingState.getDescribe(),
					Account.BillingCountry.getDescribe(), Account.ShippingState.getDescribe(),
					Account.ShippingStreet.getDescribe(), Account.ShippingCity.getDescribe(),
					Account.ShippingPostalCode.getDescribe(), Account.ShippingCountry.getDescribe(),
					Account.Phone.getDescribe(), Account.PersonEmail.getDescribe(),
					Account.Brand_Assortment__c.getDescribe(), Account.IsPersonAccount.getDescribe(),
					Account.Pricebook_Eligibility__c.getDescribe(), Account.utm_campaign__c.getDescribe(),
					Account.utm_content__c.getDescribe(), Account.utm_medium__c.getDescribe(),
					Account.utm_source__c.getDescribe(), Account.utm_term__c.getDescribe(),
					Account.sales_funnel_name__c.getDescribe(), Account.landing_page_url__c.getDescribe(),
					Account.referral_domain_url__c.getDescribe()
				}
			);
			List<Account> accountList = [
				SELECT Id, LastName, FirstName, BillingStreet, BillingCity, BillingPostalCode,
					BillingCountry, ShippingStreet, ShippingCity, BillingState, 
					ShippingPostalCode, ShippingCountry, Phone, ShippingState, 
					PersonEmail, Brand_Assortment__c, IsPersonAccount, Pricebook_Eligibility__c,
					utm_campaign__c, utm_content__c, utm_medium__c, utm_source__c, utm_term__c,
					sales_funnel_name__c, landing_page_url__c, referral_domain_url__c
				FROM Account
				WHERE Id =: stdController.getId()
			];

			if (!accountList.isEmpty()) {
				this.itemAccount = accountList[0];
				this.fName = this.itemAccount.FirstName;
				this.lName = this.itemAccount.LastName;
				this.finishUrl = '/' + itemAccount.Id;
				this.step = 2;
				this.getAllContriesAndStates();

				try {
					SFDCAccessController.CreateableWithoutSharing (
						'Account',
						'NewOrderProcessController.cls [checkAccount]',
						new List<Schema.DescribeFieldResult> {
							Account.Brand_Assortment__c.getDescribe()
						}
					);
					this.brandSelect.Brand_Assortment__c = this.itemAccount.Brand_Assortment__c;
				}
				catch (Exception e) {throw new SFDCAccessControlException();}
			}
			else {
				this.itemAccount = new Account();
				finishUrl = ApexPages.currentPage().getParameters().get('retURL');
			}
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	public Account brandSelect { get; set; }

	public void nextStep1() {
		
		this.strEmail = this.itemAccount.PersonEmail;
		RecordType PersonAccount;

		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'RecordType',
				'NewOrderProcessController.cls [nextStep1]',
				new List<Schema.DescribeFieldResult> {
					RecordType.Name.getDescribe(), RecordType.Id.getDescribe()
				}
			);
			PersonAccount = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Customer_Account' LIMIT 1];
			this.step = 2;
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

		if (String.isBlank(this.strEmail)) {
			this.itemAccount = new Account(RecordTypeId = PersonAccount.Id);
		}
		else {
			try {
				SFDCAccessController.AccessibleWithoutSharing (
					'Account',
					'NewOrderProcessController.cls [nextStep1]',
					new List<Schema.DescribeFieldResult> {
						Account.LastName.getDescribe(), Account.FirstName.getDescribe(),
						Account.BillingStreet.getDescribe(), Account.BillingCity.getDescribe(),
						Account.BillingPostalCode.getDescribe(), Account.BillingState.getDescribe(),
						Account.BillingCountry.getDescribe(), Account.ShippingState.getDescribe(),
						Account.ShippingStreet.getDescribe(), Account.ShippingCity.getDescribe(),
						Account.ShippingPostalCode.getDescribe(), Account.ShippingCountry.getDescribe(),
						Account.Phone.getDescribe(), Account.PersonEmail.getDescribe(),
						Account.Brand_Assortment__c.getDescribe(), Account.IsPersonAccount.getDescribe(),
						Account.Pricebook_Eligibility__c.getDescribe(), Account.utm_campaign__c.getDescribe(),
						Account.utm_content__c.getDescribe(), Account.utm_medium__c.getDescribe(),
						Account.utm_source__c.getDescribe(), Account.utm_term__c.getDescribe(),
						Account.sales_funnel_name__c.getDescribe(), Account.landing_page_url__c.getDescribe(),
						Account.referral_domain_url__c.getDescribe(), Account.Blacklist__c.getDescribe()
					}
				);
				List<Account> accountList = [
					SELECT Id, LastName, FirstName, BillingStreet, BillingCity, BillingPostalCode,
						BillingCountry, ShippingStreet, ShippingCity, ShippingState, Blacklist__c,
						ShippingPostalCode, ShippingCountry, Phone, BillingState,
						PersonEmail, Brand_Assortment__c, IsPersonAccount, Pricebook_Eligibility__c,
						utm_campaign__c, utm_content__c, utm_medium__c, utm_source__c, utm_term__c,
						sales_funnel_name__c, landing_page_url__c, referral_domain_url__c
					FROM Account
					WHERE PersonEmail =: this.strEmail
					LIMIT 1
				];

				if (accountList.isEmpty()) {
					this.itemAccount = new Account(RecordTypeId = PersonAccount.Id, PersonEmail = this.strEmail);
				}
				else {
					this.itemAccount = accountList[0];
					this.fName = this.itemAccount.FirstName;
					this.lName = this.itemAccount.LastName;

					if (this.itemAccount.Blacklist__c == 'True') {
						ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'This Email Address is in black list'));
						this.step = 1;
						return;
					}

					try {
						SFDCAccessController.CreateableWithoutSharing (
							'Account',
							'NewOrderProcessController.cls [checkAccount]',
							new List<Schema.DescribeFieldResult> {
								Account.Brand_Assortment__c.getDescribe()
							}
						);
						this.brandSelect.Brand_Assortment__c = this.itemAccount.Brand_Assortment__c;
					}
					catch (Exception e) {throw new SFDCAccessControlException();}
				}
				this.getAllContriesAndStates();
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}
	}

	/**
	 * PRODUCT VARIANTS SECTION
	 */
	public List<Node> nodes { get; set; }

	private Map<Id, Id> categoryIdToParentCategoryIdMap;
	private Map<Id, Set<Id>> categoryIdToChildCategoryIdsMap;
	private Map<Id, Set<Id>> categoryIdToChildProductsIdsMap;
	private Map<Id, List<Id>> productIdToChildVariantsIdsMap;

	private Map<Integer, Set<Id>> level2categoryIdsList;

	private Map<Id, Category__c> categoryIdToCategoryMap;
	private Map<Id, Product2> productIdToProductMap;
	private Map<Id, Product_Variant__c> variantIdToVariantMap;

	private Map<Id, Pricebook2> pricebook2IdMap;
	private Map<Id, PricebookEntry> pricebookEntryIdMap;

	private List<Node> getVariants(String brand) {
		List<Node> result = new List<Node>();

		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Pricebook2',
				'NewOrderProcessController.cls [getVariants]',
				new List<Schema.DescribeFieldResult> {
					Pricebook2.IsActive.getDescribe(), Pricebook2.Name.getDescribe()
				}
			);
			pricebook2IdMap = new Map<Id, Pricebook2>([
				SELECT Id, Name
				FROM Pricebook2
				WHERE IsActive = true
			]);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

		Id pricebookId;
		if(itemAccount.Pricebook_Eligibility__c == null) {
			try {
				SFDCAccessController.AccessibleWithoutSharing (
					'Account',
					'NewOrderProcessController.cls [getVariants]',
					new List<Schema.DescribeFieldResult> {
						Account.LastName.getDescribe(), Account.FirstName.getDescribe(),
						Account.BillingStreet.getDescribe(), Account.BillingCity.getDescribe(),
						Account.BillingPostalCode.getDescribe(),
						Account.BillingCountry.getDescribe(),
						Account.ShippingStreet.getDescribe(), Account.ShippingCity.getDescribe(),
						Account.ShippingPostalCode.getDescribe(),
						Account.ShippingCountry.getDescribe(),
						Account.Phone.getDescribe(), Account.PersonEmail.getDescribe(),
						Account.Brand_Assortment__c.getDescribe(), Account.IsPersonAccount.getDescribe(),
						Account.Pricebook_Eligibility__c.getDescribe(), Account.utm_campaign__c.getDescribe(),
						Account.utm_content__c.getDescribe(), Account.utm_medium__c.getDescribe(),
						Account.utm_source__c.getDescribe(), Account.utm_term__c.getDescribe(),
						Account.sales_funnel_name__c.getDescribe(), Account.landing_page_url__c.getDescribe(),
						Account.referral_domain_url__c.getDescribe()
					}
				);
				this.itemAccount = [
					SELECT Id, LastName, FirstName, BillingStreet, BillingCity, BillingPostalCode,
						BillingCountry, ShippingStreet, ShippingCity, BillingState, ShippingState,
						ShippingPostalCode, ShippingCountry, Phone,
						PersonEmail, Brand_Assortment__c, IsPersonAccount, Pricebook_Eligibility__c,
						utm_campaign__c, utm_content__c, utm_medium__c, utm_source__c, utm_term__c,
						sales_funnel_name__c, landing_page_url__c, referral_domain_url__c
					FROM Account
					WHERE Id =: this.itemAccount.Id
					LIMIT 1
				];
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}

		for (Pricebook2 itemPricebook : pricebook2IdMap.values()) {
			if (itemAccount.Pricebook_Eligibility__c == 'Normal' && itemPricebook.Name.contains('Standard')) {
				pricebookId = itemPricebook.Id;
			}
			else if (itemPricebook.Name.contains(itemAccount.Pricebook_Eligibility__c)) {
				pricebookId = itemPricebook.Id;
			}
			else if (itemPricebook.Name.contains('Standard')) {
				pricebookId = itemPricebook.Id;
			}
		}

		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'PricebookEntry',
				'NewOrderProcessController.cls [getVariants]',
				new List<Schema.DescribeFieldResult> {
					PricebookEntry.Pricebook2Id.getDescribe(), PricebookEntry.Product2Id.getDescribe(),
					PricebookEntry.UnitPrice.getDescribe(), PricebookEntry.Name.getDescribe(),
					PricebookEntry.IsActive.getDescribe()
				}
			);
			SFDCAccessController.AccessibleWithoutSharing (
				'Pricebook2',
				'NewOrderProcessController.cls [getVariants]',
				new List<Schema.DescribeFieldResult> {
					Pricebook2.Name.getDescribe()
				}
			);
			SFDCAccessController.AccessibleWithoutSharing (
				'Product2',
				'NewOrderProcessController.cls [getVariants]',
				new List<Schema.DescribeFieldResult> {
					Product2.Name.getDescribe(), Product2.Category__c.getDescribe(),
					Product2.Family.getDescribe(), Product2.isActive.getDescribe()
				}
			);
			pricebookEntryIdMap = new Map<Id, PricebookEntry>([
				SELECT Id, Name, Pricebook2Id, Pricebook2.Name, Product2Id, Product2.Name,
					Product2.Category__c, UnitPrice
				FROM PricebookEntry
				WHERE IsActive = true
				AND Product2Id != null
				AND Product2.Family = :brand
				AND Product2.isActive = true
				AND Pricebook2Id = : pricebookId
			]);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

		List<Product_Variant__c> pvList = new List<Product_Variant__c>();

		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Product_Variant__c',
				'NewOrderProcessController.cls [getVariants]',
				new List<Schema.DescribeFieldResult> {
					Product_Variant__c.Name.getDescribe(), Product_Variant__c.Price__c.getDescribe(),
					Product_Variant__c.Product_Title__c.getDescribe(), Product_Variant__c.Option__c.getDescribe(),
					Product_Variant__c.Product__c.getDescribe(), Product_Variant__c.Position__c.getDescribe()
				}
			);
			SFDCAccessController.AccessibleWithoutSharing (
				'Product2',
				'NewOrderProcessController.cls [getVariants]',
				new List<Schema.DescribeFieldResult> {
					Product2.Name.getDescribe(), Product2.Category__c.getDescribe(),
					Product2.Family.getDescribe(), Product2.isActive.getDescribe()
				}
			);
			SFDCAccessController.AccessibleWithoutSharing (
				'Category__c',
				'NewOrderProcessController.cls [getVariants]',
				new List<Schema.DescribeFieldResult> {
					Category__c.Category_Name__c.getDescribe(),
					Category__c.ParentCategory__c.getDescribe()
				}
			);
			pvList = [
				SELECT Id, Name, Price__c, Product_Title__c, Option__c, Product__c,
					Product__r.Name, Product__r.Category__r.Category_Name__c,
					Product__r.Category__r.ParentCategory__c
				FROM Product_Variant__c
				WHERE Product__c != null
				AND Product__r.Family = :brand
				AND Product__r.isActive = true
				ORDER BY Position__c ASC NULLS LAST, Name ASC
			];
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

		//Filling Map productToPVMap and variantIdToVariantMap
		Map<Id, List<Product_Variant__c>> productToPVMap = new Map<Id, List<Product_Variant__c>>();
		for (Product_Variant__c item : pvList) {
			if (productToPVMap.containsKey(item.Product__c)) {
				List<Product_Variant__c> variants = productToPVMap.get(item.Product__c);
				variants.add(item);
				productToPVMap.put(item.Product__c, variants);
			}
			else {
				productToPVMap.put(item.Product__c, new List<Product_Variant__c> {item});
			}
			variantIdToVariantMap.put(item.Id, item);
		}

		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Category__c',
				'NewOrderProcessController.cls [getVariants]',
				new List<Schema.DescribeFieldResult> {
					Category__c.Category_Name__c.getDescribe(), Category__c.ParentCategory__c.getDescribe(),
					Category__c.Position__c.getDescribe(), Category__c.Brand__c.getDescribe(),
					Category__c.Name.getDescribe()
				}
			);
			//CATEGORIES
			categoryIdToCategoryMap = new Map<Id, Category__c> ([
				SELECT Id, Category_Name__c, ParentCategory__c, Position__c
				FROM Category__c
				WHERE Brand__c = :brand
				ORDER BY Position__c ASC NULLS LAST, Name ASC
			]);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

		//no variants inside category
		if (pricebookEntryIdMap.isEmpty() || categoryIdToCategoryMap.isEmpty()) {
			return result;
		}

		for (Id aCategoryId : categoryIdToCategoryMap.keySet()) {
			Category__c aCategory = categoryIdToCategoryMap.get(aCategoryId);
			//category to category
			//if top lelvel cat
			categoryIdToParentCategoryIdMap.put(aCategory.Id, aCategory.ParentCategory__c);
		}

		Map<Id, Set<Id>> productCategoryMap = new Map<Id, Set<Id>> ();
		List<Product_Category__c> productCategoryList = [
			SELECT Id, Category__c, Product__c
			FROM Product_Category__c
			WHERE Product__r.Family = :brand
			AND Category__r.Brand__c = :brand
		];

		if (!productCategoryList.isEmpty()) {
			for (Product_Category__c item : productCategoryList) {
				Set<Id> categorySet = productCategoryMap.get(item.Product__c) != NULL ? productCategoryMap.get(item.Product__c) : new Set<Id>();
				categorySet.add(item.Category__c);
				productCategoryMap.put(item.Product__c, categorySet);
			}
		}

		//getting here we have all posible pricebookEntry
		//now need to create a tree of categories,
		for (Id pricebookEntryId : pricebookEntryIdMap.keySet()) {

			PricebookEntry pbEntry = pricebookEntryIdMap.get(pricebookEntryId);

			if (productCategoryMap.get(pbEntry.Product2Id) != NULL) {

				for (Id item : productCategoryMap.get(pbEntry.Product2Id)) {

					Id varCategoryId = item;

			//product id to product map
			productIdToProductMap.put(pbEntry.Product2Id, pbEntry.Product2);
			//Product_Variant__c and PricebookEntry to productIdToChildVariantsIdsMap map
			if (!productIdToChildVariantsIdsMap.containsKey(pbEntry.Product2Id)) {
				List<Id> variants = new List<Id> {pbEntry.Id};
				if (productToPVMap.containsKey(pbEntry.Product2Id)) {
					List<Product_Variant__c> pbList = productToPVMap.get(pbEntry.Product2Id);
					for (Product_Variant__c aPV : pbList) {
						variants.add(aPV.Id);
					}
				}
				productIdToChildVariantsIdsMap.put(pbEntry.Product2Id, variants);
			}

			//category to products map
			if (categoryIdToChildProductsIdsMap.containsKey(varCategoryId)) {
				Set<Id> products = categoryIdToChildProductsIdsMap.get(varCategoryId);
				products.add(pbEntry.Product2Id);
					categoryIdToChildProductsIdsMap.put(varCategoryId, products);
			}
			else {
				categoryIdToChildProductsIdsMap.put(varCategoryId, new Set<Id> {pbEntry.Product2Id});
			}

			List<Id> categories = getParentCategoriesList(varCategoryId);

			//categoryIdToChildCategoryIdsMap
			//level2categoryIdsList
			Integer startBound = (categories.size() > 0) ? categories.size() - 1 : 0;
			for (Integer idx = startBound, level = 0; idx >= 0; idx--) {
				//returned list is the list of all categories for this variant
				//from bottom to top, iterate through list in reverse order
				//first cat will be topmost
				Id catId = categories.get(idx);
				//fill only used categories map
				//categoryIdToChildCategoryIdsMap
				Integer bottomElement = idx - 1;
				if (categoryIdToChildCategoryIdsMap.containsKey(catId)) {
					Set<Id> childCategories = categoryIdToChildCategoryIdsMap.get(catId);
					//next element present?
					if (bottomElement >= 0) {
						childCategories.add(categories.get(bottomElement));
						categoryIdToChildCategoryIdsMap.put(catId, childCategories);
					}
				}
				else {
					//next element present?
					if (bottomElement >= 0) {
						categoryIdToChildCategoryIdsMap.put(catId, new Set<Id>{categories.get(bottomElement)});
					}
					else {
						categoryIdToChildCategoryIdsMap.put(catId, new Set<Id>());
					}
				}
				//level2categoryIdsList
				if (level2categoryIdsList.containsKey(level)) {
					Set<Id> categoryIds = level2categoryIdsList.get(level);
					categoryIds.add(catId);
					level2categoryIdsList.put(level, categoryIds);
				}
				else {
					level2categoryIdsList.put(level, new Set<Id>{catId});
				}
				level++;
					}
				}
			}
		}

		//get only top categories, as we recursively walk through all hierarchy of categories
		Set<Id> topCategories = level2categoryIdsList.get(0);

		//sort them
		List<Id> topCategoriesSorted = sortCategoriesByPosition(topCategories);
		for (Id catId : topCategoriesSorted) {
			result.addAll(createNodes(catId, 0));
		}
		//check for size, no more that 1k records
		if (result.size() > 1000) {
			result = new List<Node>();
		}
		return result;
	}
	private List<Id> getParentCategoriesList(Id catId) {
		//set for Id to avoid recursion
		Set<Id> catigoriesInHierarchySetId = new Set<Id>();
		Integer repeats = 0;
		Id tmpCatId = catId;
		Boolean isTopLevel = false;
		List<Id> result = new List<Id>();
		result.add(tmpCatId);
		while (!isTopLevel && catigoriesInHierarchySetId.add(tmpCatId)) {
			repeats++;
			if (categoryIdToParentCategoryIdMap.containsKey(tmpCatId)) {
				Id parentId = categoryIdToParentCategoryIdMap.get(tmpCatId);
				if (parentId != null) {
					tmpCatId = parentId;
					result.add(tmpCatId);
				}
				else {
					isTopLevel = true;
				}
			}
		}
		return result;
	}
	private List<Node> createNodes(Id categoryId, Integer level) {
		List<Node> result = new List<Node>();
		//is this cat has child cats
		if (categoryIdToChildCategoryIdsMap.containsKey(categoryId)) {
			//Category node
			Node aCatNode = new Node();
			aCatNode.name = categoryIdToCategoryMap.get(categoryId).Category_Name__c;
			aCatNode.id = categoryIdToCategoryMap.get(categoryId).Id;
			aCatNode.parentid = categoryIdToCategoryMap.get(categoryId).ParentCategory__c;
			aCatNode.level = level;
			aCatNode.toplevel = (level == 0) ? 'top' : '';
			aCatNode.isCategory = true;
			result.add(aCatNode);

			//if this category has products
			if (categoryIdToChildProductsIdsMap.containsKey(categoryId)) {
				Set<Id> productIds = categoryIdToChildProductsIdsMap.get(categoryId);
				List<Product2> products = new List<Product2>();
				for (Id productId : productIds) {
					if (productIdToProductMap.containsKey(productId)) {
						Product2 aProduct = productIdToProductMap.get(productId);
						products.add(aProduct);
					}
				}
				products.sort();
				for (Product2 aProduct : products) {
					Node aProdNode = new Node();
					aProdNode.name = aProduct.Name;
					aProdNode.parentid = aProduct.Category__c;
					aProdNode.id = aProduct.Id;
					aProdNode.level = level;
					aProdNode.isProduct = true;
					result.add(aProdNode);

					if (productIdToChildVariantsIdsMap.containsKey(aProduct.Id)) {
						List<Id> variantIds = productIdToChildVariantsIdsMap.get(aProduct.Id);
						//is this product has variants?
						if (variantIds.size() > 1) {
							for (Integer i = 1; i < variantIds.size(); i++) {
								Node aVarNode = new Node();
								aVarNode.name = variantIdToVariantMap.get(variantIds[i]).Name;
								aVarNode.id = variantIds[i];
								aVarNode.price = pricebookEntryIdMap.get(variantIds[0]).UnitPrice;
								aVarNode.productid = variantIdToVariantMap.get(variantIds[i]).Product__c;
								aVarNode.parentid = variantIdToVariantMap.get(variantIds[i]).Product__c;
								aVarNode.level = level;
								aVarNode.isCategory = false;
								aVarNode.isProduct = false;
								result.add(aVarNode);
							}
						}
						//is this product has pricebookEntry
						else if (variantIds.size() == 1) {
							Node aPriceBookNode = new Node();
							aPriceBookNode.name = pricebookEntryIdMap.get(variantIds[0]).Name;
							aPriceBookNode.id = variantIds[0];
							aPriceBookNode.price = pricebookEntryIdMap.get(variantIds[0]).UnitPrice;
							aPriceBookNode.productid = pricebookEntryIdMap.get(variantIds[0]).Product2Id;
							aPriceBookNode.parentid = pricebookEntryIdMap.get(variantIds[0]).Product2Id;
							aPriceBookNode.level = level;
							aPriceBookNode.isCategory = false;
							aPriceBookNode.isProduct = false;
							result.add(aPriceBookNode);
						}
					}
				}
			}
			//go recursively to the bottom level cat
			Set<Id> childCatIds = categoryIdToChildCategoryIdsMap.get(categoryId);
			List<Id> childCatIdsSorted = sortCategoriesByPosition(childCatIds);
			for (Id childCatId : childCatIdsSorted) {
				if(level < 10 ) {
					result.addAll(createNodes(childCatId, level + 1));
				}
			}
		}
		return result;
	}
	private class Node {
		public Boolean isCategory {
			get {
				return (isCategory == null) ? false : isCategory;
				}
			set; }
		public Boolean isProduct {
			get {
				return (isProduct == null) ? false : isProduct;
				}
			set; }
		public String toplevel { get; set; }
		public String name { get; set; }
		public String id { get; set; }
		public String productid { get; set; }
		public String parentid { get; set; }
		public Integer level { get; set; }
		public Decimal price { get; set; }
		public Integer count {
			get {
				return (count != null) ? count : 0;
			}
			set; }
		public Node() {}
	}

	//this methods sort categories Ids by Position__c number
	//if Position__c not set, then by Category_Name__c
	//and relies on categoryIdToCategoryMap where Categories are held
	private List<Id> sortCategoriesByPosition(Set<Id> unorderedIdsSet) {
		List<Id> result = new List<Id>();
		List<CategorySortWrapper> sortedCategories = new List<CategorySortWrapper>();
		for (Id categoryId : unorderedIdsSet) {
			if (categoryIdToCategoryMap.containsKey(categoryId)) {
				Category__c aCategory = categoryIdToCategoryMap.get(categoryId);
				CategorySortWrapper aCategoryWr = new CategorySortWrapper(aCategory);
				sortedCategories.add(aCategoryWr);
			}
		}
		sortedCategories.sort();
		for (CategorySortWrapper aCategoryWr : sortedCategories) {
			result.add(aCategoryWr.category.Id);
		}
		return result;
	}

	public class CategorySortWrapper implements Comparable {
		public Category__c category;
		public CategorySortWrapper(Category__c obj) {
			category = obj;
		}
		public Integer compareTo(Object obj) {
			CategorySortWrapper compareToObj = (CategorySortWrapper) obj;
			Integer result = 0;
			if (category.Position__c != null && compareToObj.category.Position__c != null) {
				if (category.Position__c > compareToObj.category.Position__c) {
					result = 1;
				}
				else if (category.Position__c < compareToObj.category.Position__c) {
					result = -1;
				}
			}
			else {
				if (category.Category_Name__c > compareToObj.category.Category_Name__c) {
					result = 1;
				}
				else if (category.Category_Name__c < compareToObj.category.Category_Name__c) {
					result = -1;
				}
			}
			return result;
		}
	}

	public void nextStep2() {
		this.choiceCheckout = true;

		categoryIdToParentCategoryIdMap = new Map<Id, Id>();
		categoryIdToChildCategoryIdsMap = new Map<Id, Set<Id>>();
		categoryIdToChildProductsIdsMap = new Map<Id, Set<Id>>();
		productIdToChildVariantsIdsMap = new Map<Id, List<Id>>();

		pricebook2IdMap = new Map<Id, Pricebook2>();
		pricebookEntryIdMap = new Map<Id, PricebookEntry>();

		level2categoryIdsList = new Map<Integer, Set<Id>>();

		categoryIdToCategoryMap = new Map<Id, Category__c>();
		productIdToProductMap = new Map<Id, Product2>();
		variantIdToVariantMap = new Map<Id, Product_Variant__c>();

		nodes = getVariants(this.brandSelect.Brand_Assortment__c);

		this.step = 3;
	}

	/**
	 * END PRODUCT VARIANTS SECTION
	 */

	public void nextStep3() {
		this.totalCount = 0;
		this.itemCount = 0;
		this.couponDiscount = 0;
		this.coupons = new List<Map<String,String>>();
		this.choiceCard = true;
		this.shippingCost = RestShippingController.getValidate(this.itemAccount.Id);
		this.saleTax = RestSaleTaxController.getSalesTax();

		if (nodes != NULL && !nodes.isEmpty()) {
			for (Node aNode : nodes) {
				if (aNode.count > 0) {
					this.itemCount += aNode.count * aNode.price;
					countList.add(aNode.count);
					productIdList.add(aNode.productid);
					productVarianIdList.add(aNode.id);
					unitPriceList.add(aNode.price);
				}
			}
		}

		if (this.itemCount == 0) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You don\'t selected any product'));
			return;
		}

		Map<String, String> couponParam = new Map<String,String>();
//		couponParam.put('couponCode', this.couponCode);
		couponParam.put('amount', String.valueOf(this.itemCount));
		couponParam.put('accountId', String.valueOf(this.itemAccount.Id));
		couponParam.put('autoApply', 'TRUE');
		couponParam.put('brand', String.valueOf(this.itemAccount.Brand_Assortment__c));
		String jsonCoupon = RestCouponController.getCoupon(couponParam);
		Map<String,Object> couponResult = (Map<String, Object>)JSON.deserializeUntyped(jsonCoupon);
		if (couponResult.get('message') == 'success') {
			Map<String,Object> couponMap = (Map<String,Object>)couponResult.get('coupon');
			if (String.isNotBlank((String)couponMap.get('productId'))) {
				Decimal currentDiscount = (Decimal)couponMap.get('discount');
				this.couponDiscount	+= currentDiscount;
				this.couponId = Id.valueOf((String)couponMap.get('id'));
				this.coupons.add(
					new Map<String,String>{
						'productId' => (String)couponMap.get('productId'),
						'count' => '1',
						'price' => String.valueOf(-currentDiscount),
						'productVariantId' => (String)couponMap.get('productVariantId'),
						'couponId' => (String)couponMap.get('id')
					}
				);
			}
		}
		else if (couponResult.get('message') == 'error') {
			this.couponId = NULL;
		}

		this.totalCount = this.itemCount - this.couponDiscount;

//		this.totalCount = this.itemCount;

		this.step = 4;
	}

	public void nextStep4() {
		if (!brandToGateway.containsKey(this.brandSelect.Brand_Assortment__c)) {
			this.errorStatus = 'Not found Gateway';
			this.step = 7;
			return;
		}

		if (this.choiceCheckout == true) {
			try {
				SFDCAccessController.AccessibleWithoutSharing (
					'Order_Transaction__c',
					'NewOrderProcessController.cls [nextStep4]',
					new List<Schema.DescribeFieldResult> {
						Order_Transaction__c.Order__c.getDescribe(), Order_Transaction__c.Payment_Profile__c.getDescribe(),
						Order_Transaction__c.Payment_Response_Body__c.getDescribe(), Order_Transaction__c.Payment_Date__c.getDescribe(),
						Order_Transaction__c.Type__c.getDescribe(), Order_Transaction__c.Named_Agent__c.getDescribe(),
						Order_Transaction__c.Response_Status__c.getDescribe(), Order_Transaction__c.Card_Last_4__c.getDescribe(),
						Order_Transaction__c.Payment_Entity_Id__c.getDescribe()
					}
				);
				SFDCAccessController.AccessibleWithoutSharing (
					'Order__c',
					'NewOrderProcessController.cls [nextStep4]',
					new List<Schema.DescribeFieldResult> {
						Order__c.Account__c.getDescribe()
					}
				);
				this.chargentOrdersList = [
					SELECT Id, Order__c, Payment_Profile__c, Payment_Response_Body__c,
						Payment_Date__c, Type__c, Named_Agent__c, Card_Last_4__c,
						Response_Status__c, Payment_Entity_Id__c
					FROM Order_Transaction__c
					WHERE Order__r.Account__c =: this.itemAccount.Id
					ORDER BY CreatedDate DESC
				];

				if (!this.chargentOrdersList.isEmpty()) {
					if (this.chargentOrdersList[0].Card_Last_4__c != NULL && this.chargentOrdersList[0].Payment_Profile__c  != NULL) {
						this.last4 = this.chargentOrdersList[0].Card_Last_4__c;
						this.cardId = this.chargentOrdersList[0].Payment_Entity_Id__c;
						this.step = 6;
					}
					else {
						this.step = 5;
					}
				}
				else {
					this.step = 5;
				}
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		} else if (this.choiceCheckout == false) {
			nextStep2();
		}
	}

	public void nextStep5() {
		if (String.isBlank(this.cardNamber) || String.isBlank(this.ccv) || String.isBlank(this.cardNamber)) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You must enter a values in required fields'));
		}
		else {
			this.cardId = '';
			this.last4 = '';
			payment();
		}
	}

	public void nextStep6() {
		if (this.choiceCard == true) {
			this.cardNamber = '';
			this.ccv = '';
			this.cardExpirationYear = '';
			this.cardExpirationMonth = '';
			this.last4 = this.chargentOrdersList[0].Card_Last_4__c;
			this.token = this.chargentOrdersList[0].Payment_Profile__c;
			this.cardId = this.chargentOrdersList[0].Payment_Entity_Id__c;
			payment();
		}
		else if (this.choiceCard == false) {
			nextStep5();
			this.step = 5;
		}
	}

	public void nextStep8() {

		Map<String,String> generalData = new Map<String,String>();
		generalData.put('orderId', this.orderId);
		generalData.put('last4', this.last4);

		Map<String,String> creditCard = new Map<String,String>();
		creditCard.put('CardId', this.cardId);
		creditCard.put('Profile', this.token);
		creditCard.put('CardCCV', this.ccv);
		creditCard.put('CardExpirationYear', this.cardExpirationYear);
		creditCard.put('CardExpirationMonth', this.cardExpirationMonth);
		creditCard.put('CardNumber', this.cardNamber);

		Map<String,Object> responseMap = new Map<String,Object>();
		responseMap.put('method', 'chargeOrder');
		responseMap.put('generalData', generalData);
		responseMap.put('creditCard', creditCard);

		String jsonResponce = JSON.serialize(responseMap);
		String chargeOrder = RestCallsV2.doPost(jsonResponce);
		Map<String,Object> orderResult = (Map<String, Object>)JSON.deserializeUntyped(chargeOrder);
		this.step = orderResult.get('message') == 'success' ? 9 : 7;

		if (orderResult.get('message') == 'error') {
			this.errorStatus = (String)orderResult.get('error');
		}

		if (this.step == 9) {
			sendEmail();
		}

	}

	// method name: applyCoupon
	// created: 01/26/2018
	// Author: Stanislau Yarashchuk
	// Check coupon code and recalculate total amount
	public void applyCoupon() {

		Map<String, String> couponParam = new Map<String,String>();
		couponParam.put('couponCode', this.couponCode);
		couponParam.put('amount', String.valueOf(this.itemCount));
		couponParam.put('accountId', String.valueOf(this.itemAccount.Id));
		couponParam.put('brand', String.valueOf(this.itemAccount.Brand_Assortment__c));
		String jsonCoupon = RestCouponController.getCoupon(couponParam);
		Map<String,Object> couponResult = (Map<String, Object>)JSON.deserializeUntyped(jsonCoupon);
		if (couponResult.get('message') == 'success') {
			Map<String,Object> couponMap = (Map<String,Object>)couponResult.get('coupon');
			if (String.isNotBlank((String)couponMap.get('productId'))) {
				Decimal currentDiscount = (Decimal)couponMap.get('discount');
				this.couponDiscount	+= currentDiscount;
				this.couponId = Id.valueOf((String)couponMap.get('id'));
				this.errorStatus ='The Coupon Applied';
				this.coupons.add(
					new Map<String,String>{
						'productId' => (String)couponMap.get('productId'),
						'count' => '1',
						'price' => String.valueOf(-currentDiscount),
						'productVariantId' => (String)couponMap.get('productVariantId'),
						'couponId' => (String)couponMap.get('id')
					}
				);
				this.totalCount = this.itemCount - this.couponDiscount;
			}
		}
		else if (couponResult.get('message') == 'error') {
			this.errorStatus = (String)couponResult.get('error');
		}
	}

	public void payment() {
		Map<String,String> generalData = new Map<String,String>();
		generalData.put('accountId', this.itemAccount.Id);
		generalData.put('shippingPostalCode', this.itemAccount.ShippingPostalCode);
		generalData.put('shippingStreet', this.itemAccount.ShippingStreet);
		generalData.put('shippingCity', this.itemAccount.ShippingCity);
		generalData.put('shippingState', this.itemAccount.ShippingState);
		generalData.put('shippingCountry', this.itemAccount.ShippingCountry);
		generalData.put('orderSource', 'NOW');
		generalData.put('orderTotal', String.valueOf(this.itemCount + this.shippingCost + this.saleTax));
		generalData.put('orderType', 'Standard');
		generalData.put('utmCampaign', this.itemAccount.utm_campaign__c);
		generalData.put('utmContent', this.itemAccount.utm_content__c);
		generalData.put('utmMedium', this.itemAccount.utm_medium__c);
		generalData.put('utmSource', this.itemAccount.utm_source__c);
		generalData.put('utmTerm', this.itemAccount.utm_term__c);
		generalData.put('affiliateId', NULL);
		generalData.put('subId1', NULL);
		generalData.put('subId2', NULL);
		generalData.put('subId3', NULL);
		generalData.put('subId4', NULL);
		generalData.put('subId5', NULL);
		generalData.put('coupon', this.couponId);
		generalData.put('couponDiscount', String.valueOf(-this.couponDiscount));

		List<Map<String,Object>> products = new List<Map<String,Object>>();
		for (Node item : nodes) {
			if (item.count != 0) {
				products.add(
					new Map<String,Object>{
						'productId' => item.productid,
						'price' => item.price,
						'count' => item.count
					}
				);
			}
		}

		Map<String,Object> dataForOrderItems = new Map<String,Object>();
		dataForOrderItems.put('products', products);
		dataForOrderItems.put('coupons', this.coupons);

		Map<String,Object> responseMap = new Map<String,Object>();
		responseMap.put('method', 'setOrder');
		responseMap.put('generalData', generalData);
		responseMap.put('dataForOrderItems', dataForOrderItems);

		String jsonResponce = JSON.serialize(responseMap);

		String newOrder = RestCallsV2.doPost(jsonResponce);
		Map<String,Object> orderResult = (Map<String, Object>)JSON.deserializeUntyped(newOrder);
		if (orderResult.get('message') == 'success') {
			this.orderId = (String)orderResult.get('orderId');
		}
		else if (orderResult.get('message') == 'error') {
			this.errorStatus = (String)orderResult.get('error');
		}
		this.orderlist = [SELECT Id, Name FROM Order__c WHERE Id =: this.orderId];
		this.nameOrder = orderlist.isEmpty() ? NULL : orderlist[0].Name;
		this.errorStatus = this.errorStatus == NULL ? this.orderId : this.errorStatus;
		this.step = orderlist.isEmpty() ? 7 : 8;
	}

	public void sendEmail() {
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.subject = 'Order Complete';
			message.plainTextBody = 'Thank you for your order.';
			message.toAddresses = new String[] {itemAccount.PersonEmail};
		Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
	}

	public void checkAccount() {
		this.itemAccount.FirstName = fName;
		this.itemAccount.LastName = lName;
		if (this.address == true) {
			this.itemAccount.ShippingStreet = (String.isNotBlank(this.itemAccount.BillingStreet)) ? this.itemAccount.BillingStreet : '';
			this.itemAccount.ShippingCity = (String.isNotBlank(this.itemAccount.BillingCity)) ? this.itemAccount.BillingCity : '';
			this.itemAccount.ShippingPostalCode = (String.isNotBlank(this.itemAccount.BillingPostalCode)) ? this.itemAccount.BillingPostalCode :'';
			this.itemAccount.ShippingCountry = (String.isNotBlank(this.itemAccount.BillingCountry)) ? this.itemAccount.BillingCountry :'';
			this.itemAccount.ShippingState = (String.isNotBlank(this.itemAccount.BillingState)) ? this.itemAccount.BillingState :'';
		}

		if (this.itemAccount.Brand_Assortment__c == null || this.itemAccount.Brand_Assortment__c != this.brandSelect.Brand_Assortment__c) {
			this.itemAccount.Brand_Assortment__c = this.brandSelect.Brand_Assortment__c;
		}

		if (String.isBlank(this.lName) || String.isBlank(this.itemAccount.PersonEmail) || String.isBlank(this.itemAccount.Phone) ||
			String.isBlank(this.itemAccount.BillingStreet) || String.isBlank(this.itemAccount.BillingCity) ||
			String.isBlank(this.itemAccount.ShippingStreet) || String.isBlank(this.itemAccount.ShippingCity) ||
			String.isBlank(this.itemAccount.BillingCountry)
		) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You must enter a values in required fields'));
		}
		else {
			try {
				SFDCAccessController.UpsertWithoutSharing (
					this.itemAccount,
					'NewOrderProcessController.cls [checkAccount]',
					new List<Schema.DescribeFieldResult> {
						Account.FirstName.getDescribe(), Account.LastName.getDescribe(),
						Account.ShippingStreet.getDescribe(), Account.ShippingCity.getDescribe(),
						Account.ShippingPostalCode.getDescribe(), Account.Brand_Assortment__c.getDescribe()
					}
				);
				nextStep2();
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}
	}

	public PageReference finishPage() {
		if (this.orderId != NULL) {
			return new PageReference('/'+this.orderId);
		}
		else {
			return this.stdController.cancel();
		}
	}

	// method name: applyCoupon
	// created: 01/31/2018
	// Author: Stanislau Yarashchuk
	// PageReference
	public PageReference cancel() {
		return this.stdController.cancel();
	}

	// method name: applyCoupon
	// created: 01/31/2018
	// Author: Stanislau Yarashchuk
	// Button "Back" on the step 2
	public void backToStep1() {
		this.step = 1;
		this.address = true;
	}

	// method name: applyCoupon
	// created: 01/31/2018
	// Author: Stanislau Yarashchuk
	// Button "Back" on the step 3
	public void backToStep2() {
		this.step = 2;
		this.address = true;
	}

	// method name: applyCoupon
	// created: 01/31/2018
	// Author: Stanislau Yarashchuk
	// Button "Back" on the step 4
	public void backToStep3() {
		this.step = 3;
		this.address = true;
	}

	// method name: applyCoupon
	// created: 01/31/2018
	// Author: Stanislau Yarashchuk
	// Button "Back" on the step 5
	public void backToStep4() {
		this.step = 4;
		this.address = true;
	}

	// method name: getAllContriesAndStates
	// created: 02/05/2018
	// Author: Stanislau Yarashchuk
	// return a list available contries
	public void getAllContriesAndStates() {

		Map<String, TouchCRHelper.PicklistEntryWrapper> piclists = TouchCRHelper.getAvailableStatesAndCountries();

		if (!piclists.isEmpty() && this.countries == NULL) {
			this.countries = new List<SelectOption>();
			this.countries.add(new SelectOption('', ''));
			for (String item : piclists.keySet()) {
				String label = piclists.get(item) != NULL && piclists.get(item).label != NULL ? piclists.get(item).label : '';
				this.countries.add(
					new SelectOption(EncodingUtil.urlDecode(label, 'UTF-8'), EncodingUtil.urlDecode(label, 'UTF-8'))
				);
			}
		}

		this.billingStates = new List<SelectOption>();
		this.shippingStates = new List<SelectOption>();

		if (!piclists.isEmpty()) {
			for (String item : piclists.keySet()) {
				String label = piclists.get(item) != NULL && piclists.get(item).label != NULL ? EncodingUtil.urlDecode(piclists.get(item).label, 'UTF-8') : '';
				
				if (label == itemAccount.BillingCountry) {
					for (String itemState : piclists.get(item).states.keySet()) {
						String state = piclists.get(item).states.get(itemState);
						this.billingStates.add(
							new SelectOption(EncodingUtil.urlDecode(state, 'UTF-8'), EncodingUtil.urlDecode(state, 'UTF-8'))
						);
					}
					this.billingStates = !this.billingStates.isEmpty() ? this.billingStates : NULL;
				}
				if (label == itemAccount.ShippingCountry) {
					this.shippingStates = new List<SelectOption>();
					for (String itemState : piclists.get(item).states.keySet()) {
						String state = piclists.get(item).states.get(itemState);
						this.shippingStates.add(
							new SelectOption(EncodingUtil.urlDecode(state, 'UTF-8'), EncodingUtil.urlDecode(state, 'UTF-8'))
						);
					}
					this.shippingStates = !this.shippingStates.isEmpty() ? this.shippingStates : NULL;
				}
			}
		}

	}



}