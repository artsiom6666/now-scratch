@isTest
public class NOWControllerTest {
	//method creates the order charges
	//where ItemId - Account ID, token - used Tokenization__c
	private static Order__c insertChargentOrder(Id itemId, String token) {
		Order__c order = new Order__c(
			Account__c = itemId, Billing_Email__c = 'test@yahoo.com', Billing_First_Name__c = 'test',
			Billing_Last_Name__c = 'dx', Billing_Phone__c = '9876543210', Billing_Address__c = '123 main Street', Billing_City__c =  'New York', Billing_State__c = 'LA',
			Billing_Country__c = 'United States', Billing_Zip_Postal__c = '10035', Shipping_Address__c = '123 main Street', Shipping_City__c = 'New York',
			Shipping_State__c = 'LA', Shipping_Country__c = 'United States', Shipping_Zip_Postal__c = '10035', Charge_Date__c = '10/28/2015', Subtotal__c = 10,
			Shipping__c = 2, Tax__c= 2, Currency__c = 'US Dollar', Payment_Method__c = 'Credit Card'
		);
		insert order;
		return order;
	}

	//method creates the Person Account
	//where recencyScore the value used for the calculation of Pricebook Eligibility
	private static Account insertPersonAccount(Integer recencyScore) {
		RecordType PersonAccount = [
			SELECT Id, Name
			FROM RecordType
			WHERE DeveloperName = 'Customer_Account'
			LIMIT 1
		];

		Account accountPerson = new Account(
			FirstName = 'Test FName', LastName = 'Test LName',
			Average_Order_Value__c = 0,
			RecordTypeId = PersonAccount.Id, PersonEmail = 'test@yahoo.com',
			BillingStreet = 'test', BillingCity = 'New York',
			BillingCountry = 'Australia',
			BillingPostalCode = '10035', ShippingStreet = 'test',
			ShippingCity = 'New York',
			ShippingCountry = 'Australia',
			ShippingPostalCode = '10035',
			Phone = '22-22-22', Recency_Score__c = recencyScore,
			Frequency_Score__c = 1, Monetary_Score__c = 1
		);
		insert accountPerson;
		return accountPerson;
	}

	//method creates the Category__c
	private static Category__c createCategory(String name, String parentId, Integer position, String brand) {
		if (parentId != null) {
			return new Category__c(
				Category_Name__c = name,
				ParentCategory__c = Id.valueOf(parentId),
				Position__c = position,
				Brand__c = brand
			);
		}
		else {
			return new Category__c(
				Category_Name__c = name,
				Position__c = position,
				Brand__c = brand
			);
		}
	}

	//method creates the Product2
	private static Product2 createProduct(String name, String productCode, String family) {
		return new Product2(
			Name = name,
			ProductCode = productCode,
			IsActive = true,
			Family = family
		);
	}

	//method creates the PricebookEntry
	private static PricebookEntry createPricebookEntry(Id productId, Id pricebookId, Integer price) {
		return new PricebookEntry(
			Product2Id = productId,
			Pricebook2Id = pricebookId,
			UnitPrice = price,
			IsActive = true
		);
	}

	//method creates the Product_Variant__c
	private static Product_Variant__c createProductVariant(Id productId, Integer price) {
		return new Product_Variant__c(
			Product__c = productId,
			Price__c = price
		);
	}

	//method creates the Product_Category__c
	private static Product_Category__c createProductCategory(Id categoryId, Id productId) {
		return new Product_Category__c(
			Category__c = categoryId,
			Product__c = productId
		);
	}

	static testMethod void NewOrderWizardFindAcc() {
		Test.startTest();
		Account accountPerson = insertPersonAccount(1);
		Account existingAcc = NOWController.getAccount('test@yahoo.com');
		Account newEmailAcc = NOWController.getAccount('test@gmail.com');
		Account emptyStringAcc = NOWController.getAccount('');
		Test.stopTest();

		System.assertEquals(existingAcc.BillingPostalCode, '10035');
		System.assertEquals(emptyStringAcc.BillingPostalCode, null);
		System.assertEquals(newEmailAcc.BillingPostalCode, null);
	}

	static testMethod void NewOrderWizardSaveAcc() {
		Account accountPerson = insertPersonAccount(1);

		Order__c order = insertChargentOrder(accountPerson.Id, 'cus_7cBFHD6iiBaTUU');

		Category__c category1 = createCategory('1', null, 1, 'Cate Mcnabb');
		Category__c category2 = createCategory('2', null, 2, 'Cate Mcnabb');
		Category__c category3 = createCategory('3', null, 1, 'Cate Mcnabb');
		Category__c category4 = createCategory('4', category3.Id, 3, 'Cate Mcnabb');
		insert new List<Category__c>{category1, category2, category3, category4};

		Product2 product = createProduct('testProduct', 'testProductCode','Cate Mcnabb');
		Product2 product1 = createProduct('testProduct1', 'testProductCode1','Cate Mcnabb');
		Product2 product3 = createProduct('testProduct', 'testProductCode','Cate Mcnabb');
		Product2 product4 = createProduct('testProduct', 'testProductCode','Cate Mcnabb');
		Product2 product5 = createProduct('testProduct', 'testProductCode','Cate Mcnabb');
		insert new List<Product2>{product, product1, product3, product4, product5};

		Product_Category__c prodCat1 = createProductCategory(category1.Id, product.Id);
		Product_Category__c prodCat2 = createProductCategory(category1.Id, product1.Id);
		Product_Category__c prodCat3 = createProductCategory(category2.Id, product3.Id);
		Product_Category__c prodCat4 = createProductCategory(category3.Id, product4.Id);
		Product_Category__c prodCat5 = createProductCategory(category4.Id, product5.Id);
		insert new List<Product_Category__c>{prodCat1, prodCat2, prodCat3, prodCat4, prodCat5};

		//get standard pb id
		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pricebook2 = new Pricebook2(
			Name = 'Standard Price Book',
			IsActive = true
		);
		insert pricebook2;

		List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>{
			createPricebookEntry(product.Id, pricebookId, 5),
			createPricebookEntry(product.Id, pricebook2.Id, 5),
			createPricebookEntry(product1.Id, pricebookId, 5),
			createPricebookEntry(product1.Id, pricebook2.Id, 5),
			createPricebookEntry(product3.Id, pricebookId, 5),
			createPricebookEntry(product3.Id, pricebook2.Id, 5),
			createPricebookEntry(product4.Id, pricebookId, 5),
			createPricebookEntry(product4.Id, pricebook2.Id, 5),
			createPricebookEntry(product5.Id, pricebookId, 5),
			createPricebookEntry(product5.Id, pricebook2.Id, 5)
		};
		insert pricebookEntryList;

		List<Product_Variant__c> listProductVariant = new List<Product_Variant__c>{
			createProductVariant(product.Id, 100),
			createProductVariant(product1.Id, 100),
			createProductVariant(product3.Id, 100),
			createProductVariant(product4.Id, 100),
			createProductVariant(product5.Id, 100),
			createProductVariant(product5.Id, 100)
		};
		insert listProductVariant;

		Account newEmailAcc = NOWController.getAccount('test@gmail.com');
		List<String> brandPicklist = NOWController.getAccountBrandPicklist();
		if (TouchCRHelper.isSCPEnabled()) {
			Map<String, String> countryCode = NOWController.getAccountBillingCountryCodePicklist();
		}

		Map<String, String> newAccountMap = new Map<String, String>();
		newAccountMap.put('FirstName', 'Test FName');
		newAccountMap.put('LastName', 'Test LName');
		newAccountMap.put('PersonEmail', 'test@gmail.com');
		newAccountMap.put('Phone', '33-33-33');
		newAccountMap.put('BillingStreet', 'test2');
		newAccountMap.put('BillingCity', 'New York');
		newAccountMap.put('BillingPostalCode', '10035');
		newAccountMap.put('ShippingStreet', 'test2');
		newAccountMap.put('ShippingCity', 'New York');
		newAccountMap.put('ShippingPostalCode', '10035');
		newAccountMap.put('Brand', 'Cate Mcnabb');
		newAccountMap.put('BillingCountryCode', 'US');
		newAccountMap.put('BillingCountry', 'United States');
		newAccountMap.put('ShippingCountryCode', 'US');
		newAccountMap.put('ShippingCountry', 'United States');

		// new acc
		Test.startTest();
		Account newAcc = NOWController.saveAccount(newAccountMap);
		Account newAcc2 = [SELECT Id, PersonEmail FROM Account WHERE PersonEmail = 'test@gmail.com'];

		// same acc
		newAccountMap.put('FirstName', 'Test FName Test 2');
		newAccountMap.put('Id', newAcc2.Id);
		newAcc = NOWController.saveAccount(newAccountMap);
		Account newAcc3 = [SELECT Id, FirstName, LastName FROM Account WHERE PersonEmail = 'test@gmail.com'];
		Test.stopTest();

		System.assertEquals(newAccountMap.get('PersonEmail'), newAcc2.PersonEmail);
		System.assertEquals(newAccountMap.get('FirstName'), newAcc3.FirstName);
		System.assertEquals(newAccountMap.get('LastName'), newAcc3.LastName);
	}

	static testMethod void NewOrderWizardNodeCreationNewCardDirectToDoor() {
		Account accountPerson = insertPersonAccount(1);

		Order__c order = insertChargentOrder(accountPerson.Id, 'cus_7cBFHD6iiBaTUU');

		Category__c category0 = createCategory('3', null, null, 'Cate Mcnabb');
		Category__c category1 = createCategory('2', category0.Id, null, 'Cate Mcnabb');
		Category__c category2 = createCategory('1', category0.Id, null, 'Cate Mcnabb');
		insert new List<Category__c>{category0, category1, category2};

		Product2 product = createProduct('testProduct', 'testProductCode','Cate Mcnabb');
		Product2 product1 = createProduct('testProduct', 'testProductCode','Cate Mcnabb');
		insert new List<Product2>{product, product1};

		Product_Category__c prodCat1 = createProductCategory(category1.Id, product.Id);
		Product_Category__c prodCat2 = createProductCategory(category2.Id, product1.Id);
		insert new List<Product_Category__c>{prodCat1, prodCat2};

		//get standard pb id
		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pricebook2 = new Pricebook2(
			Name = 'Standard Price Book',
			IsActive = true
		);
		insert pricebook2;

		List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>{
			createPricebookEntry(product.Id, pricebookId, 5),
			createPricebookEntry(product.Id, pricebook2.Id, 5),
			createPricebookEntry(product1.Id, pricebookId, 5),
			createPricebookEntry(product1.Id, pricebook2.Id, 5)
		};
		insert pricebookEntryList;


		List<Product_Variant__c> listProductVariant = new List<Product_Variant__c>{
			createProductVariant(product.Id, 100),
			createProductVariant(product1.Id, 100)
		};
		insert listProductVariant;

		Product_Variant__c productId = [SELECT Id FROM Product_Variant__c LIMIT 1];

		NOWController.StandardWrapper wrapper = new NOWController.StandardWrapper();
		wrapper.id = productId.Id;
		wrapper.value = '2';
		List<NOWController.StandardWrapper> wrappers = new List<NOWController.StandardWrapper>();
		wrappers.add(wrapper);
		String StandardInfoJSON = JSON.serialize(wrappers);

		NOWNode node = new NOWNode();
		node.id = productId.Id;
		node.price = 3;
		node.gst = 0.3;
		node.productPrice = 0.5;
		List<NOWNode> nodes = NOWController.getVariants(accountPerson);
		nodes.add(node);
		String NodeJSON = JSON.serialize(nodes);


		List<String> inputElementAmount = new List<String>();

		inputElementAmount = NOWController.getInputElementAmount(StandardInfoJSON , NodeJSON);

		String accountId = accountPerson.Id;
		List<Decimal> getValidateAccount = NOWController.getValidateAccount(accountId);

		List<String> checkOldCreditCard = NOWController.checkOldCreditCard(accountId);

		NOWController.orderFormData newForm = new NOWController.orderFormData();

		newForm.product_id = inputElementAmount[1];
		newForm.email = accountPerson.PersonEmail;
		newForm.fname = accountPerson.FirstName;
		newForm.lname = accountPerson.LastName;
		newForm.phone = accountPerson.Phone;
		newForm.cc_number = '4242424242424242';
		newForm.security_code = '123';
		newForm.cc_exp_month = '02';
		newForm.cc_exp_year = '2017';
		newForm.cc_type = 'Visa';
		newForm.tax = String.valueOf(getValidateAccount[1]);
		newForm.subtotal = inputElementAmount[0];
		newForm.total = '';
		newForm.shipping = String.valueOf(getValidateAccount[0]);
		newForm.quantity = inputElementAmount[3];
		newForm.Offerprice = inputElementAmount[4];
		newForm.token = '';
		newForm.brand = 'Cate Mcnabb';
		// standard delivery
		newForm.deliveryType = 'Direct To Door (DD)';

		String newOrderForm = JSON.serialize(newForm);

		// new card
		List<String> payment = NOWController.payment(newOrderForm, accountPerson);
		List<Order__c> orderlist = [SELECT Id FROM Order__c];

		String lastStep = NOWController.lastStep(payment, 'test@yahoo.com', newOrderForm);


		System.assertEquals(5, nodes.size());
		System.assertEquals(0, getValidateAccount[0]);
	}

	static testMethod void NewOrderWizardNodeCreationOldCardDirectToCoolCube() {
		Account accountPerson = insertPersonAccount(1);

		Order__c order = insertChargentOrder(accountPerson.Id, 'cus_7cBFHD6iiBaTUU');

		Category__c category0 = createCategory('3', null, null, 'Cate Mcnabb');
		Category__c category1 = createCategory('2', category0.Id, null, 'Cate Mcnabb');
		Category__c category2 = createCategory('1', category0.Id, null, 'Cate Mcnabb');
		insert new List<Category__c>{category0, category1, category2};

		Product2 product = createProduct('testProduct', 'testProductCode','Cate Mcnabb');
		Product2 product1 = createProduct('testProduct', 'testProductCode','Cate Mcnabb');
		insert new List<Product2>{product, product1};

		Product_Category__c prodCat1 = createProductCategory(category1.Id, product.Id);
		Product_Category__c prodCat2 = createProductCategory(category2.Id, product1.Id);
		insert new List<Product_Category__c>{prodCat1, prodCat2};

		//get standard pb id
		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pricebook2 = new Pricebook2(
			Name = 'Standard Price Book',
			IsActive = true
		);
		insert pricebook2;

		List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>{
			createPricebookEntry(product.Id, pricebookId, 5),
			createPricebookEntry(product.Id, pricebook2.Id, 5),
			createPricebookEntry(product1.Id, pricebookId, 5),
			createPricebookEntry(product1.Id, pricebook2.Id, 5)
		};
		insert pricebookEntryList;


		List<Product_Variant__c> listProductVariant = new List<Product_Variant__c>{
			createProductVariant(product.Id, 100),
			createProductVariant(product1.Id, 100)
		};
		insert listProductVariant;

		Product_Variant__c productId = [SELECT Id FROM Product_Variant__c LIMIT 1];

		NOWController.StandardWrapper wrapper = new NOWController.StandardWrapper();
		wrapper.id = productId.Id;
		wrapper.value = '2';
		List<NOWController.StandardWrapper> wrappers = new List<NOWController.StandardWrapper>();
		wrappers.add(wrapper);
		String StandardInfoJSON = JSON.serialize(wrappers);

		NOWNode node = new NOWNode();
		node.id = productId.Id;
		node.price = 3;
		node.gst = 0.3;
		node.productPrice = 0.5;
		List<NOWNode> nodes = NOWController.getVariants(accountPerson);
		nodes.add(node);
		String NodeJSON = JSON.serialize(nodes);


		List<String> inputElementAmount = new List<String>();

		inputElementAmount = NOWController.getInputElementAmount(StandardInfoJSON , NodeJSON);

		String accountId = accountPerson.Id;
		List<Decimal> getValidateAccount = NOWController.getValidateAccount(accountId);

		List<String> checkOldCreditCard = NOWController.checkOldCreditCard(accountId);

		NOWController.orderFormData newForm = new NOWController.orderFormData();

		newForm.product_id = inputElementAmount[1];
		newForm.email = accountPerson.PersonEmail;
		newForm.fname = accountPerson.FirstName;
		newForm.lname = accountPerson.LastName;
		newForm.phone = accountPerson.Phone;
		newForm.token = 'cus_7cBFHD6iiBaTUU';
		newForm.cc_id = 'card_1AzgvlBeCpPJC8JSn7V0TBeY';
		newForm.tax = String.valueOf(getValidateAccount[1]);
		newForm.subtotal = inputElementAmount[0];
		newForm.total = '';
		newForm.shipping = String.valueOf(getValidateAccount[0]);
		newForm.quantity = inputElementAmount[3];
		newForm.offerprice = inputElementAmount[4];
		newForm.token = '';
		newForm.brand = 'Cate Mcnabb';
		// direct to door delivery
		newForm.deliveryType = 'Cool Cube (CC)';

		String newOrderForm = JSON.serialize(newForm);

		// old card
		List<String> payment = NOWController.payment(newOrderForm, accountPerson);
		List<Order__c> orderlist = [SELECT Id FROM Order__c];

		String lastStep = NOWController.lastStep(payment, 'test@yahoo.com', newOrderForm);


		System.assertEquals(5, nodes.size());
		System.assertEquals(0, getValidateAccount[0]);
	}


	static testMethod void NewOrderWizardAccountPicklistValueToLabel() {
		String result;

		result = NOWController.getAccountPicklistValueToLabel('AccountSource', 'Other');
		System.assertNotEquals(null, result);

		result = NOWController.getAccountPicklistValueToLabel('Type', 'Test');
		System.assertEquals(null, result);
	}

	static testMethod void NewOrderWizardSendEmail() {
		NOWController.sendEmail('test@test.test');
	}

	static testMethod void NewOrderWizardProductInDifferentCategories() {
		Account accountPerson = insertPersonAccount(1);

		Order__c order = insertChargentOrder(accountPerson.Id, 'cus_7cBFHD6iiBaTUU');

		Category__c categoryNewProducts = createCategory('1', null, null, 'Winter');
		Category__c categoryShopAll = createCategory('1', null, null, 'Winter');
		insert new List<Category__c>{categoryNewProducts, categoryShopAll};

		Product2 productVanillaBallTop = createProduct('Vanilla Ball Top', '20','Home Ice Cream');
		Product2 productCottonCandyBall = createProduct('Cotton Candy Ball', '40','Home Ice Cream');
		Product2 productChocolateChip = createProduct('Chocolate Chip', '60','Home Ice Cream');
		insert new List<Product2>{productVanillaBallTop, productCottonCandyBall, productChocolateChip};

		Product_Category__c productVanillaBallTopTocategoryNewProducts = createProductCategory(categoryNewProducts.Id, productVanillaBallTop.Id);
		Product_Category__c productCottonCandyBallTocategoryNewProducts = createProductCategory(categoryNewProducts.Id, productCottonCandyBall.Id);
		Product_Category__c productChocolateChipTocategoryNewProducts = createProductCategory(categoryNewProducts.Id, productChocolateChip.Id);
		
		Product_Category__c productVanillaBallTopTocategoryShopAll = createProductCategory(categoryShopAll.Id, productVanillaBallTop.Id);
		Product_Category__c productCottonCandyBallTocategoryShopAll = createProductCategory(categoryShopAll.Id, productCottonCandyBall.Id);
		Product_Category__c productChocolateChipTocategoryShopAll = createProductCategory(categoryShopAll.Id, productChocolateChip.Id);
		
		insert new List<Product_Category__c>{productVanillaBallTopTocategoryNewProducts, productCottonCandyBallTocategoryNewProducts, 
			productChocolateChipTocategoryNewProducts, productVanillaBallTopTocategoryShopAll, productCottonCandyBallTocategoryShopAll, 
			productChocolateChipTocategoryShopAll 
		};

		//get standard pb id
		Id pricebookId = Test.getStandardPricebookId();
		//create pricebook for QLD
		Pricebook2 pricebook2 = new Pricebook2(
			Name = 'Standard Price Book',
			IsActive = true
		);
		insert pricebook2;

		List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>{
			createPricebookEntry(productVanillaBallTop.Id, pricebookId, 5),
			createPricebookEntry(productVanillaBallTop.Id, pricebook2.Id, 10),
			createPricebookEntry(productCottonCandyBall.Id, pricebookId, 5),
			createPricebookEntry(productCottonCandyBall.Id, pricebook2.Id, 10),
			createPricebookEntry(productChocolateChip.Id, pricebookId, 5),
			createPricebookEntry(productChocolateChip.Id, pricebook2.Id, 10)
		};
		insert pricebookEntryList;

		List<NOWNode> nodes = NOWController.getVariants(accountPerson);

		String NodeJSON = JSON.serialize(nodes);

		List<NOWController.StandardWrapper> wrappers = new List<NOWController.StandardWrapper>();
		for (NOWNode item : nodes) {
			NOWController.StandardWrapper sw1 = new NOWController.StandardWrapper();
			sw1.id = item.Id+item.parentid;
			sw1.value = '1';
			wrappers.add(sw1);
		}
		
		String StandardInfoJSON = JSON.serialize(wrappers);

		List<String> inputElementAmount = new List<String>();

		inputElementAmount = NOWController.getInputElementAmount(StandardInfoJSON , NodeJSON);

		String accountId = accountPerson.Id;
		List<Decimal> getValidateAccount = NOWController.getValidateAccount(accountId);

		List<String> checkOldCreditCard = NOWController.checkOldCreditCard(accountId);

		NOWController.orderFormData newForm = new NOWController.orderFormData();

		newForm.email = accountPerson.PersonEmail;
		newForm.fname = accountPerson.FirstName;
		newForm.lname = accountPerson.LastName;
		newForm.phone = accountPerson.Phone;
		newForm.subtotal = inputElementAmount[0];
		newForm.product_id = inputElementAmount[1];
		newForm.quantity = '1';
		newForm.offerprice = inputElementAmount[4];
		newForm.brand = 'Home Ice Cream';
		// direct to door delivery
		newForm.deliveryType = 'Cool Cube (CC)';
		newForm.tax = String.valueOf(getValidateAccount[1]);
		newForm.shipping = String.valueOf(getValidateAccount[0]);

		String newOrderForm = JSON.serialize(newForm);

		// old card
		List<String> payment = NOWController.payment(newOrderForm, accountPerson);
		
		String lastStep = NOWController.lastStep(payment, 'test@yahoo.com', newOrderForm);

		List<Order__c> orderlist = [
			SELECT Id, Name, Date__c, Status__c,
				Tax__c, Total__c, Geolocation__Longitude__s, Geolocation__Latitude__s,
				Shipping_City__c, Shipping_State__c, Shipping_Address__c, Shipping_Zip_Postal__c,
				(
					SELECT Id, Name, Order__c, Quantity__c, Total_Price__c,
						Product__c,	Product_Price__c
					FROM Order_Items__r
				)
			FROM Order__c
			WHERE Account__c =: accountPerson.Id
		];

		System.assertEquals(8, nodes.size());
		
		for (OrderItem__c orItem : orderlist[0].Order_Items__r) {
			System.assertEquals(4, orItem.Quantity__c);

		} 
	}
}