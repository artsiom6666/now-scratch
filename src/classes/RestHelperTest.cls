@isTest
private class RestHelperTest {

	static testMethod void RestHelperTest() {

		RestHelper.AddressproInfo addressInfo = new RestHelper.AddressproInfo();
		addressInfo.suburb = 'SYDENHAM';
		addressInfo.numberFirst = '1';
		addressInfo.state = 'NSW';
		addressInfo.street = 'GEORGE';
		addressInfo.streetLine = '1 GEORGE ST';
		addressInfo.streetType = 'ST';
		addressInfo.streetTypeFull = 'STREET';
		addressInfo.postcode = '2044';
		addressInfo.longitude = 151.17056839;
		addressInfo.latitude = -33.91759949;
		addressInfo.meshblock = '10516310000';
		addressInfo.gnaf_ID = 'GANSW706417964';
		addressInfo.valid = true;
		addressInfo.delivery = false;
		addressInfo.nonService = false;

		RestHelper.ProductsInformationWrapperVariant variant = new RestHelper.ProductsInformationWrapperVariant();
		variant.variantId = 'GANSW706417964';
		variant.count = '1';

		RestHelper.ProductsInformationWrapperCoupon coupon = new RestHelper.ProductsInformationWrapperCoupon();
		coupon.productId = 'GANSW706417964';
		coupon.productVariantId = 'a060l000000LmAE';
		coupon.count = '1';
		coupon.price = '10';
		coupon.couponId = 'GANSW706417964';

		RestHelper.ProductsInformationWrapperBumpOffer bumpOffer = new RestHelper.ProductsInformationWrapperBumpOffer();
		bumpOffer.orderFormId = 'GANSW706417964';
		bumpOffer.count = '1';

		RestHelper.ProductsInformationWrapperUpsells upsell = new RestHelper.ProductsInformationWrapperUpsells();
		upsell.orderFormId = 'GANSW706417964';
		upsell.count = '1';

		RestHelper.ProductsInformationWrapper productsInformation = new RestHelper.ProductsInformationWrapper();
		productsInformation.count = '1';
		productsInformation.productId = 'a060l000000LmAE';

		RestHelper.DataForOrderItems dataForOrderItems = new RestHelper.DataForOrderItems();
		dataForOrderItems.products = new List<RestHelper.ProductsInformationWrapper>{productsInformation};
		dataForOrderItems.bumpOffers = new List<RestHelper.ProductsInformationWrapperBumpOffer>{bumpOffer};
		dataForOrderItems.upsells = new List<RestHelper.ProductsInformationWrapperUpsells>{upsell};
		dataForOrderItems.coupons = new List<RestHelper.ProductsInformationWrapperCoupon>{coupon};
		dataForOrderItems.variants = new List<RestHelper.ProductsInformationWrapperVariant>{variant};

		RestHelper.RestCallsWrapper restCalls = new RestHelper.RestCallsWrapper();
		restCalls.creditCard = new Map<String, String>();
		restCalls.generalData = new Map<String, String>();
		restCalls.method = 'void';
		restCalls.dataForOrderItems = dataForOrderItems;

		System.assertEquals('1', productsInformation.count);
	}


	static testMethod void setOrderTest() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account acc = new Account(
			RecordTypeId = customerRecordType.Id, LastName = 'TestLast', FirstName = 'TestFirst',
			PersonEmail = 'test@gmail.com', Phone = '1234567890', BillingStreet = 'Vulture St, Woolloongabba', BillingCity = 'Brisbane',
			BillingState = 'Alaska', BillingPostalCode = '4102', BillingCountry = 'United States', ShippingStreet = 'Vulture St, Woolloongabba',
			ShippingCity = 'Brisbane', ShippingState = 'Alaska', ShippingPostalCode = '4102', ShippingCountry = 'United States'
		);
		insert acc;

		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pricebook2 = new Pricebook2(
//			Name = 'QLD',					//Ready for use not Standard Price Book
			Name = 'Standard Price Book',
			IsActive = true
		);
		insert pricebook2;

		Product2 iceCreamProduct = new Product2(
			Name = 'iceCreamProduct',
			ProductCode = 'iceCreamProductCode',
			IsActive = true
		);
		insert iceCreamProduct;

		insert new List<PricebookEntry> {
			new PricebookEntry(Product2Id = iceCreamProduct.Id,
				Pricebook2Id = pricebookId,
				UnitPrice = 50, IsActive = true
			),
			new PricebookEntry(Product2Id = iceCreamProduct.Id,
				Pricebook2Id = pricebook2.Id,
				UnitPrice = 50, IsActive = true
			)
		};

		RestHelper.DataForOrderItems dataForOrderItems = new RestHelper.DataForOrderItems();
		String result;

		Map<String, String> orderFormData = new Map<String, String> {
				'accountId' => String.valueOf(acc.id),
				'fname' => 'TestFirst',
				'lname' => 'TestLast',
				'email' => 'test@gmail.com',
				'billingState' => 'Alaska',
				'billingCountry' => 'United States',
				'shippingState' => 'Alaska',
				'shippingCountry' => 'United States',
				'phone' => '9876543210',
				'brand' => 'test brand'
		};

		//error Products information not found
		result = RestHelper.createOrder(orderFormData, dataForOrderItems);
		System.assertEquals(true, result.contains('Products information not found'));


		//add Product
		List<RestHelper.ProductsInformationWrapper> products = new List<RestHelper.ProductsInformationWrapper>();
		RestHelper.ProductsInformationWrapper product = new RestHelper.ProductsInformationWrapper();
		product.productId = String.valueOf(iceCreamProduct.Id);
		product.count = '20';
		products.add(product);
		dataForOrderItems.products = products;

		//add BumpOffer
		OrderForm__c orderFormBump = new OrderForm__c();
		orderFormBump.Offer_Price__c = 40;
		orderFormBump.ProductTobeSold__c = iceCreamProduct.Id;
		insert orderFormBump;
		List<RestHelper.ProductsInformationWrapperBumpOffer> bumpOffers = new List<RestHelper.ProductsInformationWrapperBumpOffer>();
		RestHelper.ProductsInformationWrapperBumpOffer bumpOffer = new RestHelper.ProductsInformationWrapperBumpOffer();
		bumpOffer.orderFormId = String.valueOf(orderFormBump.id);
		bumpOffer.count = '30';
		bumpOffers.add(bumpOffer);
		dataForOrderItems.bumpOffers = bumpOffers;

		//add Coupon
		Coupon__c productCoupon = new Coupon__c (Discount_Amount__c = 1, Start_Date__c = Date.today(), End_Date__c = Date.today().addDays(3), Status__c = 'Active', Uses_Limit_Value__c = 4);
		insert productCoupon;
		List<RestHelper.ProductsInformationWrapperCoupon> coupons = new List<RestHelper.ProductsInformationWrapperCoupon>();
		RestHelper.ProductsInformationWrapperCoupon coupon = new RestHelper.ProductsInformationWrapperCoupon();
		coupon.couponId = String.valueOf(productCoupon.id);
		coupon.count = '1';
		coupon.price = '-1';
		coupon.productId = String.valueOf(iceCreamProduct.Id);
		coupons.add(coupon);
		dataForOrderItems.coupons = coupons;

		//add Product Variants
		Product_Variant__c productVariant = new Product_Variant__c(Name = 'Test', Price__c = 30, Product__c = iceCreamProduct.Id);
		insert productVariant;

		List<RestHelper.ProductsInformationWrapperVariant> variants = new List<RestHelper.ProductsInformationWrapperVariant>();
		RestHelper.ProductsInformationWrapperVariant variant = new RestHelper.ProductsInformationWrapperVariant();
		variant.variantId = String.valueOf(productVariant.Id);
		variant.count = '5';
		variants.add(variant);
		dataForOrderItems.variants = variants;

		result = RestHelper.createOrder(orderFormData, dataForOrderItems);
		System.assertEquals(false, result.contains('error'));

		//remove all and Set Upsell
		dataForOrderItems.products = null;
		dataForOrderItems.bumpOffers = null;
		dataForOrderItems.coupons = null;
		dataForOrderItems.variants = null;
		orderFormData.put('orderType', 'upsell');

		//add Upsell
		OrderForm__c orderFormUpsell = new OrderForm__c();
		orderFormUpsell.Offer_Price__c = 20;
		orderFormUpsell.ProductTobeSold__c = iceCreamProduct.Id;
		insert orderFormUpsell;
		List<RestHelper.ProductsInformationWrapperUpsells> upsells = new List<RestHelper.ProductsInformationWrapperUpsells>();
		RestHelper.ProductsInformationWrapperUpsells upsell = new RestHelper.ProductsInformationWrapperUpsells();
		upsell.orderFormId = String.valueOf(orderFormUpsell.id);
		upsell.count = '30';
		upsells.add(upsell);
		dataForOrderItems.upsells = upsells;

		//no Parrent Order = error
		result = RestHelper.createOrder(orderFormData, dataForOrderItems);
		System.assertEquals(true, result.contains('error'));

		//add Parrent Order
		Order__c parrentOrder = new Order__c(Account__c = acc.Id, Charge_Amount__c = 1, Date__c = Datetime.now().addMinutes(-1));
		insert parrentOrder;
		orderFormData.put('parrentUpsellOrderId', String.valueOf(parrentOrder.id));
		result = RestHelper.createOrder(orderFormData, dataForOrderItems);
		System.assertEquals(false, result.contains('error'));

		//error Price mismatch
		orderFormData.put('orderTotal', '2000');
		result = RestHelper.createOrder(orderFormData, dataForOrderItems);
		System.assertEquals(true, result.contains('Price mismatch'));

	}

	static testMethod void setDuplicateOrderTest() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account acc = new Account(
			RecordTypeId = customerRecordType.Id, LastName = 'TestLast', FirstName = 'TestFirst',
			PersonEmail = 'test@gmail.com', Phone = '1234567890', BillingStreet = 'Vulture St, Woolloongabba', BillingCity = 'Brisbane',
			BillingState = 'Alaska', BillingPostalCode = '4102', BillingCountry = 'United States', ShippingStreet = 'Vulture St, Woolloongabba',
			ShippingCity = 'Brisbane', ShippingState = 'Alaska', ShippingPostalCode = '4102', ShippingCountry = 'United States'
		);
		insert acc;

		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pricebook2 = new Pricebook2(
//			Name = 'QLD',					//Ready for use not Standard Price Book
			Name = 'Standard Price Book',
			IsActive = true
		);
		insert pricebook2;

		Product2 iceCreamProduct = new Product2(Name = 'iceCreamProduct', ProductCode = 'iceCreamProductCode', IsActive = true);
		Product2 hotCreamProduct = new Product2(Name = 'hotCreamProduct', ProductCode = 'hotCreamProductCode', IsActive = true);
		insert new List<Product2> {iceCreamProduct, hotCreamProduct};

		insert new List<PricebookEntry> {
			new PricebookEntry(Product2Id = iceCreamProduct.Id,
				Pricebook2Id = pricebookId,
				UnitPrice = 1, IsActive = true
			),
			new PricebookEntry(Product2Id = iceCreamProduct.Id,
				Pricebook2Id = pricebook2.Id,
				UnitPrice = 1, IsActive = true
			),
			new PricebookEntry(Product2Id = hotCreamProduct.Id,
				Pricebook2Id = pricebookId,
				UnitPrice = 2, IsActive = true
			),
			new PricebookEntry(Product2Id = hotCreamProduct.Id,
				Pricebook2Id = pricebook2.Id,
				UnitPrice = 2, IsActive = true
			)
		};

		Order__c order1 = new Order__c(
			Account__c = acc.Id,
			Charge_Amount__c = 1,
			Date__c = Datetime.now().addMinutes(-1)
		);
		Order__c order2 = new Order__c(
			Account__c = acc.Id,
			Charge_Amount__c = 2,
			Date__c = Datetime.now().addMinutes(-1)
		);
		Order__c order3 = new Order__c(
			Account__c = acc.Id,
			Charge_Amount__c = 3,
			Date__c = Datetime.now().addMinutes(-1)
		);
		insert new List<Order__c>{order1, order2, order3};

		OrderItem__c orderItem1 = new OrderItem__c(
			Order__c = order1.Id,
			Product__c = iceCreamProduct.Id,
			Quantity__c = 1,
			Product_Price__c = 1
		);
		OrderItem__c orderItem2 = new OrderItem__c(
			Order__c = order2.Id,
			Product__c = hotCreamProduct.Id,
			Quantity__c = 1,
			Product_Price__c = 2
		);
		OrderItem__c orderItem3 = new OrderItem__c(
			Order__c = order3.Id,
			Product__c = iceCreamProduct.Id,
			Quantity__c = 1,
			Product_Price__c = 3
		);
		insert new List<OrderItem__c>{orderItem1, orderItem2, orderItem3};

		Order_Transaction__c trans = new Order_Transaction__c(
			Order__c = order1.Id,
			Amount__c = 1,
			Card_Type__c = 'credit',
			Type__c = 'Charge',
			Response_Status__c = 'Approved',
			Payment_Date__c = Datetime.now(),
			Response_Message__c = 'Message',
			Payment_Response_Body__c = 'original',
			Payment_Profile__c = 'cus_7cBFHD6iiBaTUU',
			Named_Agent__c = 'Stripe',
			Card_Last_4__c = '4242',
			Payment_Entity_Id__c = 'card_1A4lgrCF2TV51fDnD0sQWldG'
		);
		Order_Transaction__c trans2= new Order_Transaction__c(
			Order__c = order3.Id,
			Amount__c = 3,
			Card_Type__c = 'credit',
			Type__c = 'Charge',
			Response_Status__c = 'Approved',
			Payment_Date__c = Datetime.now(),
			Response_Message__c = 'Message',
			Payment_Response_Body__c = 'original',
			Payment_Profile__c = 'cus_7cBFHD6iiBaTUU',
			Named_Agent__c = 'Stripe',
			Card_Last_4__c = '4242',
			Payment_Entity_Id__c = 'card_1A4lgrCF2TV51fDnD0sQWldG'
		);
		insert new List<Order_Transaction__c>{trans, trans2};

		//error Duplicate
		RestHelper.DataForOrderItems dataForOrderItemsA = new RestHelper.DataForOrderItems();
		List<RestHelper.ProductsInformationWrapper> productsA = new List<RestHelper.ProductsInformationWrapper>();
		RestHelper.ProductsInformationWrapper productA = new RestHelper.ProductsInformationWrapper();
		productA.productId = String.valueOf(iceCreamProduct.Id);
		productA.count = '1';
		productsA.add(productA);
		dataForOrderItemsA.products = productsA;

		String result;
		Map<String, String> orderFormData = new Map<String, String>{
			'accountId' => String.valueOf(acc.id),
			'fname' => 'TestFirst',
			'lname' => 'TestLast',
			'email' => 'test@gmail.com',
			'billingState' => 'Alaska',
			'billingCountry' => 'United States',
			'shippingState' => 'Alaska',
			'shippingCountry' => 'United States',
			'phone' => '9876543210',
			'brand' => 'test brand'
		};

		result = RestHelper.createOrder(orderFormData, dataForOrderItemsA);
		System.assertEquals(true, result.contains('duplicate order'));

		//no error Duplicate
		RestHelper.DataForOrderItems dataForOrderItemsB = new RestHelper.DataForOrderItems();
		List<RestHelper.ProductsInformationWrapper> productsB = new List<RestHelper.ProductsInformationWrapper>();
		RestHelper.ProductsInformationWrapper productB = new RestHelper.ProductsInformationWrapper();
		productB.productId = String.valueOf(hotCreamProduct.Id);
		productB.count = '1';
		productsB.add(productB);
		dataForOrderItemsB.products = productsB;

		result = RestHelper.createOrder(orderFormData, dataForOrderItemsB);
		System.assertEquals(false, result.contains('error'));

	}

}