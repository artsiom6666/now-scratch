@isTest
private class CustomerReceiptControllerTest {

	@isTest static void test_transaction_orderitems() {
		// CUSTOMER
		List<RecordType> rec = [
			SELECT Id, Name
			FROM RecordType
			WHERE SObjectType = 'Account'
			AND DeveloperName = 'Customer_Account'
			AND isActive = true
			LIMIT 1
		];
		Id personRTId;
		if (!rec.isEmpty()) {
			personRTId = rec[0].Id;
		}

		Account testCustomer = new Account(
			FirstName = 'Test FName',
			LastName = 'Test LName',
			Average_Order_Value__c = 0,
			RecordTypeId = personRTId,
			PersonEmail = 'test@example.com'
		);
		insert testCustomer;

		Id pricebookId = Test.getStandardPricebookId();

		Order__c testOrd = new Order__c(
			Account__c = testCustomer.Id
		);
		insert testOrd;

		Order_Transaction__c testTrans = new Order_Transaction__c(
			Order__c = testOrd.Id,
			Named_Agent__c = 'Test Agent Name',
			Type__c = 'Charge',
			Response_Status__c = 'Approved',
			Payment_Date__c = Datetime.now(),
			Amount__c = testOrd.Subtotal__c
		);
		insert testTrans;

		// PRODUCT & PRODUCT VARIANT
		// SCENARIO 1 - get image form PV
		// YES variant YES image in variant
		Product2 testProduct1 = new Product2(
			Name = 'testProduct1',
			ProductCode = 'testProductCode',
			IsActive = true
		);
		insert testProduct1;

		PricebookEntry pricebookEntryItem1 = new PricebookEntry(
			Product2Id = testProduct1.Id,
			Pricebook2Id = pricebookId,
			UnitPrice = 5,
			IsActive = true
		);
		insert pricebookEntryItem1;

		Product_Variant__c testVariant1 = new Product_Variant__c(
			Name = 'testVariant1',
			Product__c = testProduct1.Id,
			Price__c = 10
		);
		insert testVariant1;

		Product_Image__c testImage1 = new Product_Image__c(
			Name = 'testImage1',
			Image_URL__c = 'product_variant_image',
			Product_Variant_Lookup__c = testVariant1.Id // variant
		);
		insert testImage1;

		OrderItem__c testItem1 = new OrderItem__c(
			Order__c = testOrd.Id,
			Product_Price__c = 200,
			Quantity__c = 1,
			Product__c = testProduct1.Id,
			Product_Variant__c = testVariant1.Id,
			Use_Standard_Price__c = false
		);
		insert testItem1;
		// SCENARIO 2 - get image from PR
		// YES variant NO image in variant YES image on product
		Product2 testProduct2 = new Product2(
			Name = 'testProduct2',
			ProductCode = 'testProductCode',
			IsActive = true
		);
		insert testProduct2;

		PricebookEntry pricebookEntryItem2 = new PricebookEntry(
			Product2Id = testProduct2.Id,
			Pricebook2Id = pricebookId,
			UnitPrice = 5,
			IsActive = true
		);
		insert pricebookEntryItem2;

		Product_Variant__c testVariant2 = new Product_Variant__c(
			Name = 'testVariant2',
			Product__c = testProduct2.Id,
			Price__c = 10
		);
		insert testVariant2;

		Product_Image__c testImage2 = new Product_Image__c(
			Name = 'testImage2',
			Image_URL__c = 'product_image',
			Product_Lookup__c = testProduct2.Id //product
		);
		insert testImage2;

		OrderItem__c testItem2 = new OrderItem__c(
			Order__c = testOrd.Id,
			Product_Price__c = 200,
			Quantity__c = 1,
			Product__c = testProduct2.Id,
			Product_Variant__c = testVariant2.Id,
			Use_Standard_Price__c = false
		);
		insert testItem2;

		// SCENARIO 3 - get default image
		// NO variant NO image on product
		Product2 testProduct3 = new Product2(
			Name = 'testProduct3',
			ProductCode = 'testProductCode',
			IsActive = true
		);
		insert testProduct3;

		PricebookEntry pricebookEntryItem3 = new PricebookEntry(
			Product2Id = testProduct3.Id,
			Pricebook2Id = pricebookId,
			UnitPrice = 5,
			IsActive = true
		);
		insert pricebookEntryItem3;

		OrderItem__c testItem3 = new OrderItem__c(
			Order__c = testOrd.Id,
			Product_Price__c = 200,
			Quantity__c = 1,
			Product__c = testProduct3.Id,
			Use_Standard_Price__c = false
		);
		insert testItem3;

		Test.startTest();
			CustomerReceiptController ctrl = new CustomerReceiptController();
			ctrl.transId = testTrans.Id;
			ctrl.getPrepareData();
		Test.stopTest();

		List<CustomerReceiptController.OrderItemWr> testObjs = ctrl.paidOrderItemsWr;

		System.assertEquals(3, testObjs.size());
		System.assertEquals('product_variant_image', testObjs[0].imgUrl);
		System.assertEquals('product_image', testObjs[1].imgUrl);
		System.assertEquals(null, testObjs[2].imgUrl);


	}

	@isTest static void test_no_transaction() {
		CustomerReceiptController ctrl = new CustomerReceiptController();
		ctrl.getPrepareData();
		System.assertEquals(ctrl.paidOrderItemsWr, NULL);
		ctrl.transId = 'not an id';
		ctrl.getPrepareData();
		System.assertEquals(ctrl.paidOrderItemsWr, NULL);
	}

}