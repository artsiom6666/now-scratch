@isTest
public class NewOrderProcessControllerTest {

	//method creates the Custom Settings needed to pay for the order
	private static void insertCustomSetting() {
		TouchCR_Settings__c apiSettings = new TouchCR_Settings__c(
			Name = 'MinFraud.ApiKey',
			Value__c = 'hello'
		);

		TouchCR_Settings__c firstSettings = new TouchCR_Settings__c(
			Name = 'MinFraud.RatingFirst',
			Value__c = '30'
		);

		TouchCR_Settings__c secondSettings = new TouchCR_Settings__c(
			Name = 'MinFraud.RatingSecond',
			Value__c = '75'
		);

		insert new List<TouchCR_Settings__c>{apiSettings, firstSettings, secondSettings};
	}

	//method creates the Payment Agents
	private static String insertPaymentAgent() {
		Payment_Agents__c paymentAgent = new Payment_Agents__c(
			Name = 'Test Agent Name',
			Security_Key__c = 'test',
			Type__c = 'Stripe',
			Active__c = true
		);
		insert paymentAgent;
		return paymentAgent.Id;
	}

	private static Order__c insertOrder(Id itemId, String token, String cardId) {
		Order__c order = new Order__c(
			Account__c = itemId, Billing_Email__c = 'test@yahoo.com', Billing_First_Name__c = 'test', Status__c = 'Initiated',
			Billing_Last_Name__c = 'dx', Billing_Phone__c = '9876543210', Billing_Address__c = '123 main Street', Billing_City__c =  'New York', Billing_State__c = 'LA',
			Billing_Country__c = 'US', Billing_Zip_Postal__c = '10035', Shipping_Address__c = '123 main Street', Shipping_City__c = 'New York',
			Shipping_State__c = 'LA', Shipping_Country__c = 'US', Shipping_Zip_Postal__c = '10035', Subtotal__c = 10,
			Shipping__c = 2, Tax__c= 2, Currency__c = 'US Dollar', Payment_Method__c = 'Credit Card'
		);
		insert order;
		Order_Transaction__c transactionLast = new Order_Transaction__c(
			Named_Agent__c = 'Stripe', Type__c = 'Charge', Payment_Profile__c = token, Payment_Entity_Id__c = cardId, Order__c = order.Id, Payment_Date__c = Datetime.now(), Card_Last_4__c = '4242'
		);
		insert transactionLast;
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
			BillingStreet = 'test', 
			BillingCity = 'New York',
			BillingState = 'New York',
			BillingCountry = 'United States',
			BillingPostalCode = '10035', 
			ShippingStreet = 'test',
			ShippingCity = 'New York',
			ShippingState = 'Indiana',
			ShippingCountry = 'United States', 
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

	//method creates the Product Category
	private static Product_Category__c createProductCategory(Id productId, Id categoryId) {
		return new Product_Category__c(
			Product__c = productId,
			Category__c = categoryId
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

	static testMethod void NewOrderProcessControllerTestAccount() {

		insertCustomSetting();

		Account accountPerson = insertPersonAccount(500);

		Order__c order = insertOrder(accountPerson.Id, 'cus_7cBFHD6iiBaTUU', 'ch_19dfhSCF2TV51fDnaXu3lB1J');

		Category__c category0 = createCategory('category0', null, 1, 'testFamily');
		Category__c category1 = createCategory('category1', category0.Id, 1, 'testFamily');
		insert new List<Category__c>{category0, category1};

		Product2 product = createProduct('testProduct', 'testProductCode','testFamily');
		insert product;

		Product_Category__c productCategory = createProductCategory(product.Id, category1.Id);
		insert productCategory;

		//get standard pb id
		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pricebook2 = new Pricebook2(
			Name = 'Gold',
			IsActive = true
		);
		insert pricebook2;

		PricebookEntry pricebookEntryItem1 = createPricebookEntry(product.Id, pricebookId, 5);
		PricebookEntry pricebookEntryItem2 = createPricebookEntry(product.Id, pricebook2.Id, 5);
		insert new List<PricebookEntry> {pricebookEntryItem1, pricebookEntryItem2};

		Test.startTest();
			ApexPages.StandardController controller = new ApexPages.StandardController(accountPerson);
			NewOrderProcessController processController = new NewOrderProcessController(controller);
			processController.brandToGateway = new Map<String, String>{
				'testFamily' => insertPaymentAgent()
			};
			processController.brandSelect.Brand_Assortment__c = 'testFamily';
			processController.address = false;
			processController.checkAccount();
			processController.nextStep2();
			//2 categories
			//1 product
			//1 pricebookEntry
			System.assertEquals(3, processController.nodes.size());
			for(Integer i = 0; i < processController.nodes.size(); i++) {
				if (processController.nodes[i].isCategory != true && processController.nodes[i].isProduct != true) {
					processController.nodes[i].count = 1;
				}
			}
			processController.nodes[2].count = 1;
			processController.nextStep3();
			processController.nextStep4();
			processController.nextStep5();
			processController.nextStep6();
			processController.nextStep8();
			processController.finishPage();

		Test.stopTest();

		List<Order__c> orderlist = [SELECT Id FROM Order__c];

		System.assertEquals(1, orderlist.size());
	}

	static testMethod void NewOrderProcessControllerTestButtons() {

		insertCustomSetting();

		Account accountPerson = insertPersonAccount(500);

		Order__c order = insertOrder(accountPerson.Id, 'cus_7cBFHD6iiBaTUU', 'ch_19dfhSCF2TV51fDnaXu3lB1J');

		Category__c category0 = createCategory('category0', null, 1, 'testFamily');
		Category__c category1 = createCategory('category1', category0.Id, 1, 'testFamily');
		insert new List<Category__c>{category0, category1};

		Product2 product = createProduct('testProduct', 'testProductCode','testFamily');
		insert product;

		Product_Category__c productCategory = createProductCategory(product.Id, category1.Id);
		insert productCategory;


		//get standard pb id
		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pricebook2 = new Pricebook2(
			Name = 'Gold',
			IsActive = true
		);
		insert pricebook2;

		PricebookEntry pricebookEntryItem1 = createPricebookEntry(product.Id, pricebookId, 5);
		PricebookEntry pricebookEntryItem2 = createPricebookEntry(product.Id, pricebook2.Id, 5);
		insert new List<PricebookEntry> {pricebookEntryItem1, pricebookEntryItem2};

		Test.startTest();
			ApexPages.StandardController controller = new ApexPages.StandardController(accountPerson);
			NewOrderProcessController processController = new NewOrderProcessController(controller);
			processController.brandToGateway = new Map<String, String>{
				'testFamily' => insertPaymentAgent()
			};
			processController.brandSelect.Brand_Assortment__c = 'testFamily';
			processController.address = false;
			processController.getAllContriesAndStates();
			processController.checkAccount();
			processController.nextStep2();
			processController.backToStep1();
			processController.nextStep2();
			//2 categories
			//1 product
			//1 pricebookEntry
			System.assertEquals(3, processController.nodes.size());
			for(Integer i = 0; i < processController.nodes.size(); i++) {
				if (processController.nodes[i].isCategory != true && processController.nodes[i].isProduct != true) {
					processController.nodes[i].count = 1;
				}
			}
			processController.nodes[2].count = 1;
			processController.nextStep3();
			processController.backToStep2();
			processController.nextStep3();
			processController.nextStep4();
			processController.backToStep3();
			processController.nextStep4();
			processController.nextStep5();
			processController.backToStep4();
			processController.nextStep5();
			processController.nextStep6();
			processController.nextStep8();
			processController.cancel();

		Test.stopTest();

		List<Order__c> orderlist = [SELECT Id FROM Order__c];

		System.assertEquals(1, orderlist.size());
	}	

	static testMethod void NewOrderProcessControllerTestErrorAccount() {

		Contact contactItem = new Contact(LastName = 'TestContact');
		insert contactItem;

		Test.startTest();
			ApexPages.StandardController controller = new ApexPages.StandardController(contactItem);
			NewOrderProcessController processController = new NewOrderProcessController(controller);
			processController.strEmail = 'test@mail.com';
			processController.nextStep1();
			processController.checkAccount();

		Test.stopTest();

		List<Order__c> orderlist = [SELECT Id FROM Order__c];

		System.assertEquals(0, orderlist.size());
	}

	static testMethod void NewOrderProcessControllerTestNotFoundAccount () {

		Contact contactItem = new Contact(LastName = 'TestContact');
		insert contactItem;

		Account accountPerson = insertPersonAccount(1);

		Test.startTest();
			ApexPages.StandardController controller = new ApexPages.StandardController(contactItem);
			NewOrderProcessController processController = new NewOrderProcessController(controller);
			processController.strEmail = 'test@yahoo.com';
			processController.nextStep1();

			processController.checkAccount();

			System.assertEquals(NULL, processController.nodes);

			processController.nextStep3();

			processController.choiceCheckout = false;

			processController.nextStep4();

		Test.stopTest();

		List<Order__c> orderlist = [SELECT Id FROM Order__c];

		System.assertEquals(0, orderlist.size());
	}

	static testMethod void NewOrderProcessControllerTestRecursionCategory() {

		Account accountPerson = insertPersonAccount(1);

		Category__c category0 = createCategory('category0', null, 1, 'testFamily');
		Category__c category1 = createCategory('category1', category0.Id, 1, 'testFamily');
		insert new List<Category__c>{category0, category1};

		Product2 product = createProduct('testProduct', 'testProductCode','testFamily');
		insert product;

		Product_Category__c productCategory = createProductCategory(product.Id, category1.Id);
		insert productCategory;

		//get standard pb id
		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pricebook2 = new Pricebook2(
			Name = 'Standard',
			IsActive = true
		);
		insert pricebook2;

		PricebookEntry pricebookEntryItem1 = createPricebookEntry(product.Id, pricebookId, 5);
		PricebookEntry pricebookEntryItem2 = createPricebookEntry(product.Id, pricebook2.Id, 5);
		insert new List<PricebookEntry> {pricebookEntryItem1, pricebookEntryItem2};

		Product_Variant__c variant1 = createProductVariant(product.Id, 100);
		insert variant1;

		category0.ParentCategory__c = category1.Id;
		update category0;

		Test.startTest();
			ApexPages.StandardController controller = new ApexPages.StandardController(accountPerson);
			NewOrderProcessController processController = new NewOrderProcessController(controller);
			processController.brandSelect.Brand_Assortment__c = 'testFamily';
			processController.nextStep2();
			System.assertNotEquals(0, processController.nodes.size());
		Test.stopTest();

		List<Order__c> orderlist = [SELECT Id FROM Order__c];
		System.assertEquals(0, orderlist.size());
	}

	static testMethod void NewOrderProcessControllerTestPayment() {

		insertCustomSetting();

		Account accountPerson = insertPersonAccount(1);

		Order__c order = insertOrder(accountPerson.Id, 'cus_7cBFHD6iiBaTUU', 'ch_19dfhSCF2TV51fDnaXu3lB1J');

		Category__c category0 = createCategory('3', null, null, 'testFamily');
		Category__c category1 = createCategory('2', category0.Id, null, 'testFamily');
		Category__c category2 = createCategory('1', category0.Id, null, 'testFamily');
		insert new List<Category__c>{category0, category1, category2};

		Product2 product = createProduct('testProduct', 'testProductCode','testFamily');
		Product2 product1 = createProduct('testProduct', 'testProductCode','testFamily');
		insert new List<Product2>{product, product1};

		Product_Category__c productCategory1 = createProductCategory(product.Id, category1.Id);
		Product_Category__c productCategory2 = createProductCategory(product1.Id, category2.Id);
		insert  new List<Product_Category__c>{productCategory1, productCategory2};

		//get standard pb id
		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pricebook2 = new Pricebook2(
			Name = 'Standard',
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

		Test.startTest();
			ApexPages.StandardController controller = new ApexPages.StandardController(accountPerson);
			NewOrderProcessController processController = new NewOrderProcessController(controller);
			processController.brandToGateway = new Map<String, String>{
				'testFamily' => insertPaymentAgent()
			};
			processController.brandSelect.Brand_Assortment__c = 'testFamily';
			processController.checkAccount();
			processController.nextStep2();

			System.assertEquals(6, processController.nodes.size());
			processController.nodes[2].count = 1;

			processController.nextStep3();
			processController.nextStep4();
			processController.choiceCard = false;
			processController.nextStep6();

			processController.cardType = 'Visa';
			processController.firstName = 'Test';
			processController.lastName = 'Test';
			processController.cardNamber = '4242424242424242';
			processController.cardExpirationYear = '2018';
			processController.cardExpirationMonth = '01';
			processController.ccv = '123';

			processController.nextStep5();
			processController.nextStep8();
			processController.finishPage();

		Test.stopTest();

		List<Order__c> orderlist = [SELECT Id FROM Order__c];

		System.assertEquals(1, orderlist.size());
	}

	static testMethod void NewOrderProcessControllerTestOldCardPayment() {

		insertCustomSetting();

		Account accountPerson = insertPersonAccount(1);

		Order__c order = insertOrder(accountPerson.Id, 'cus_7cBFHD6iiBaTUU', 'ch_19dfhSCF2TV51fDnaXu3lB1J');

		Category__c category1 = createCategory('1', null, 1, 'testFamily');
		Category__c category2 = createCategory('2', null, 2, 'testFamily');
		Category__c category3 = createCategory('3', null, 1, 'testFamily');
		Category__c category4 = createCategory('4', category3.Id, 3, 'testFamily');
		insert new List<Category__c>{category1, category2, category3, category4};

		Product2 product = createProduct('testProduct', 'testProductCode','testFamily');
		Product2 product1 = createProduct('testProduct1', 'testProductCode1','testFamily');
		Product2 product3 = createProduct('testProduct', 'testProductCode','testFamily');
		Product2 product4 = createProduct('testProduct', 'testProductCode','testFamily');
		Product2 product5 = createProduct('testProduct', 'testProductCode','testFamily');
		insert new List<Product2>{product, product1, product3, product4, product5};

		Product_Category__c productCategory1 = createProductCategory(product.Id, category1.Id);
		Product_Category__c productCategory2 = createProductCategory(product1.Id, category1.Id);
		Product_Category__c productCategory3 = createProductCategory(product3.Id, category2.Id);
		Product_Category__c productCategory4 = createProductCategory(product4.Id, category3.Id);
		Product_Category__c productCategory5 = createProductCategory(product5.Id, category4.Id);
		insert new List<Product_Category__c>{productCategory1, productCategory2, productCategory3, productCategory4, productCategory5};

		//get standard pb id
		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pricebook2 = new Pricebook2(
			Name = 'Standard',
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

		Test.startTest();
			ApexPages.StandardController controller = new ApexPages.StandardController(accountPerson);
			NewOrderProcessController processController = new NewOrderProcessController(controller);
			processController.brandToGateway = new Map<String, String>{
				'testFamily' => insertPaymentAgent()
			};
			processController.brandSelect.Brand_Assortment__c = 'testFamily';
			processController.checkAccount();
			processController.nextStep2();
			System.assertEquals(15, processController.nodes.size());
			processController.nodes[2].count = 1;

			processController.nextStep3();
			processController.nextStep4();
			processController.choiceCard = true;
			processController.nextStep6();
			processController.nextStep5();
			processController.nextStep8();
			processController.finishPage();

		Test.stopTest();

		List<Order__c> orderlist = [SELECT Id FROM Order__c];

		System.assertEquals(1, orderlist.size());
	}

	static testMethod void NewOrderProcessControllerTestPayment2() {

		insertCustomSetting();

		Account accountPerson = insertPersonAccount(1);

		Order__c order = insertOrder(accountPerson.Id, '', '');

		Category__c category0 = createCategory('1', null, null, 'testFamily');
		insert category0;
		Category__c category1 = createCategory('2', category0.Id, null, 'testFamily');
		insert category1;
		Category__c category2 = createCategory('3', category0.Id, null, 'testFamily');
		insert category2;

		Product2 product = createProduct('testProduct', 'testProductCode','testFamily');
		Product2 product1 = createProduct('testProduct', 'testProductCode','testFamily');
		insert new List<Product2>{product, product1};

		Product_Category__c productCategory1 = createProductCategory(product.Id, category1.Id);
		Product_Category__c productCategory2 = createProductCategory(product1.Id, category2.Id);
		insert new List<Product_Category__c>{productCategory1, productCategory2};

		//get standard pb id
		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pricebook2 = new Pricebook2(
			Name = 'Standard',
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

		Test.startTest();
			ApexPages.StandardController controller = new ApexPages.StandardController(accountPerson);
			NewOrderProcessController processController = new NewOrderProcessController(controller);
			processController.brandToGateway = new Map<String, String>{
				'testFamily' => insertPaymentAgent()
			};
			processController.brandSelect.Brand_Assortment__c = 'testFamily';
			processController.checkAccount();
			processController.nextStep2();

			System.assertEquals(7, processController.nodes.size());
			processController.nodes[3].count = 1;

			processController.nextStep3();
			processController.nextStep4();
			processController.choiceCard = false;
			processController.nextStep6();

			processController.cardType = 'Visa';
			processController.firstName = 'Test FName';
			processController.lastName = 'Test LName';
			processController.cardNamber = '4242424242424242';
			processController.cardExpirationYear = '2018';
			processController.cardExpirationMonth = '01';
			processController.ccv = '123';

			processController.nextStep5();
			processController.nextStep8();
			processController.finishPage();

		Test.stopTest();

		List<Order__c> orderlist = [SELECT Id FROM Order__c];

		System.assertEquals(1, orderlist.size());
	}

	static testMethod void NewOrderProcessControllerTestPayment3() {

		Account accountPerson = insertPersonAccount(1);

		Category__c category0 = createCategory('1', null, null, 'testFamily');
		Category__c category1 = createCategory('2', category0.Id, null, 'testFamily');
		Category__c category2 = createCategory('3', category0.Id, null, 'testFamily');
		insert new List<Category__c>{category0, category1, category2};

		Product2 product = createProduct('testProduct', 'testProductCode','testFamily');
		Product2 product1 = createProduct('testProduct', 'testProductCode','testFamily');
		insert new List<Product2>{product, product1};

		Product_Category__c productCategory1 = createProductCategory(product.Id, category1.Id);
		Product_Category__c productCategory2 = createProductCategory(product1.Id, category2.Id);
		insert new List<Product_Category__c>{productCategory1, productCategory2};

		//get standard pb id
		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pricebook2 = new Pricebook2(
			Name = 'Standard',
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

		Product_Variant__c PV = createProductVariant(product.Id, 100);
		insert PV;

		List<Product_Variant__c> listProductVariant = new List<Product_Variant__c>();
		while (listProductVariant.size() < 1000) {
			listProductVariant.add(createProductVariant(product1.Id, 100));
		}
		insert listProductVariant;

		Test.startTest();
			ApexPages.StandardController controller = new ApexPages.StandardController(accountPerson);
			NewOrderProcessController processController = new NewOrderProcessController(controller);
			processController.brandSelect.Brand_Assortment__c = 'testFamily';
			processController.checkAccount();
//			NewOrderProcessController.getAccountPicklistValueToLabel('BillingCountry', 'testValue');
			processController.nextStep2();
			System.assertEquals(0, processController.nodes.size());
			processController.nextStep3();
			processController.nextStep4();
			processController.choiceCard = true;

		Test.stopTest();

		List<Order__c> orderlist = [SELECT Id FROM Order__c];

		System.assertEquals(0, orderlist.size());
	}

}