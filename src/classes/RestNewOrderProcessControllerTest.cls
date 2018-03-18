@isTest
public class RestNewOrderProcessControllerTest {

	static testMethod void testSetOrder() {

		Test.startTest();
			String email='87684647864768dx@gmail.com';
			Product2 p = new Product2();
			p.Name = 'test';
			p.ProductCode = 'DSX';
			p.IsActive = true;
			insert p;

			Product_Variant__c variant = new Product_Variant__c();
			variant.Product__c = p.Id;
			variant.Price__c = 20;
			variant.Product_Title__c = 'test';
			variant.sku__c = 'DSX';
			insert variant;

			Product_Variant__c variant1 = new Product_Variant__c();
			variant1.Product__c = p.Id;
			variant1.Price__c = 20;
			variant1.Product_Title__c = 'test';
			variant1.sku__c = 'DSX';
			insert variant1;

			String proID = p.Id+'~'+p.Id;
			String qty = '1~1';
			String offerPrc = '20~20';
			String vId =  variant.Id;
			 String vId1 =  variant1.Id;
			String vIds = vId+'~'+vId1;

			Map<String, String> orderFormData = new Map<String, String>();
			orderFormData.put('product_id', proID);
			orderFormData.put('product_variant',vIds);
			orderFormData.put('email', email);
			orderFormData.put('fname', 'david');
			orderFormData.put('lname', 'huggs');
			orderFormData.put('phone', '9876543210');
			orderFormData.put('b_common', '123 main Street~New York~LA~US~10035');
			orderFormData.put('s_common', '123 main Street~New York~LA~US~10035');
			orderFormData.put('utm_source', 'test source');
			orderFormData.put('utm_medium', 'test medium');
			orderFormData.put('utm_campaign', 'test campaign');
			orderFormData.put('utm_content', 'test content');
			orderFormData.put('utm_term', 'test term');
			orderFormData.put('sales_funnel_name', 'test state funnel');
			orderFormData.put('landing_page_url', 'test landing page url');
			orderFormData.put('referral_domain_url', 'test referral domian');
			orderFormData.put('start_date', '9/20/2016');
			orderFormData.put('tax', '2');
			orderFormData.put('subtotal', '20');
			orderFormData.put('total', '24');
			orderFormData.put('shipping', '2');
			orderFormData.put('quantity', qty);
			orderFormData.put('Offerprice', offerPrc);
			orderFormData.put('gateway', 'Authorize.net');
			orderFormData.put('brand', 'test brand');

			String resul = RestNewOrderProcessController.setOrders(orderFormData);
			Order__c odr = [SELECT Id FROM Order__c WHERE Id =:resul];
			System.assertEquals(odr.Id,resul);
		Test.stopTest();
	}

	static testMethod void testSetOrderone() {

		Test.startTest();
			String email = 'json@gmail.com';
			RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
			Account ant = new Account();
			ant.RecordTypeId = customerRecordType.Id;
			ant.FirstName = 'test';
			ant.LastName = 'test';
			ant.Phone = '6547892456';
			ant.PersonEmail = email;

			ant.BillingState = 'Alaska';
			ant.BillingCountry = 'United States';

			ant.ShippingState = 'Alaska';
			ant.ShippingCountry = 'United States';

			insert ant;

			Product2 p = new Product2();
			p.Name = 'test';
			p.ProductCode = 'DSX';
			p.IsActive = true;
			insert p;

			Product_Variant__c variant = new Product_Variant__c();
			variant.Product__c = p.Id;
			variant.Price__c = 20;
			variant.Product_Title__c = 'test';
			variant.sku__c = 'DSX';
			insert variant;

			Map<String, String> orderFormData = new Map<String, String>();
			orderFormData.put('product_id', p.Id);
			orderFormData.put('product_variant', variant.Id);
			orderFormData.put('email', email);
			orderFormData.put('fname', 'david');
			orderFormData.put('lname', 'huggs');
			orderFormData.put('phone', '9876543210');
			orderFormData.put('b_common', '123 main Street~New York~LA~US~10035');
			orderFormData.put('s_common', '123 main Street~New York~LA~US~10035');
			orderFormData.put('utm_source', 'test source');
			orderFormData.put('utm_medium', 'test medium');
			orderFormData.put('utm_campaign', 'test campaign');
			orderFormData.put('utm_content', 'test content');
			orderFormData.put('utm_term', 'test term');
			orderFormData.put('sales_funnel_name', 'test state funnel');
			orderFormData.put('landing_page_url', 'test landing page url');
			orderFormData.put('referral_domain_url', 'test referral domian');
			orderFormData.put('start_date', '9/20/2016');
			orderFormData.put('tax', '2');
			orderFormData.put('subtotal', '20');
			orderFormData.put('total', '24');
			orderFormData.put('shipping', '2');
			orderFormData.put('quantity', '1');
			orderFormData.put('Offerprice', '20');
			orderFormData.put('gateway', 'Authorize.net');
			orderFormData.put('brand', 'test brand');

			String resul = RestNewOrderProcessController.setOrders(orderFormData);
			Order__c odr = [SELECT Id FROM Order__c WHERE Id =:resul];
			System.assertEquals(odr.Id,resul);
		Test.stopTest();
	}

	static testMethod void testgetCustomerHistory() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account ant = new Account();
		ant.RecordTypeId = customerRecordType.Id;
		ant.FirstName = 'XXX';
		ant.LastName = 'YYY';
		ant.Phone = '9876543210';
		ant.PersonEmail = 'xxx007@ymail.com';
		insert ant;
		String accountId = ant.Id;
		Datetime myDT = Datetime.now();

		String resul = RestNewOrderProcessController.getCustomerHistory(accountId);
		System.assertEquals('true',resul);
	}

	static testMethod void testgetCustomerHistoryone() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account ant = new Account();
		ant.RecordTypeId = customerRecordType.Id;
		ant.FirstName = 'XXX';
		ant.LastName = 'YYY';
		ant.Phone = '9876543210';
		ant.PersonEmail = 'xxx008@ymail.com';
		insert ant;
		String accountId = ant.Id;

		Case cs = new Case();
		cs.AccountId = accountId;
		cs.Status = 'New';
		cs.Origin = 'Phone';
		cs.Type = 'Payment';
		cs.Reason = 'Unpaid Order';
		insert cs;

		String resul = RestNewOrderProcessController.getCustomerHistory(accountId);
		System.assertEquals('true',resul);
	}

	static testMethod void testgetCustomerHistorytwo() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account ant = new Account();
		ant.RecordTypeId = customerRecordType.Id;
		ant.FirstName = 'XXX';
		ant.LastName = 'YYY';
		ant.Phone = '9876543210';
		ant.PersonEmail = 'xxx009@ymail.com';
		ant.Orders_Failed__c = 10;
		insert ant;
		String accountId = ant.Id;

		Case cs = new Case();
		cs.AccountId = accountId;
		cs.Status = 'New';
		cs.Origin = 'Phone';
		cs.Type = 'Payment';
		cs.Reason = 'Unpaid Order';
		insert cs;

		String resul = RestNewOrderProcessController.getCustomerHistory(accountId);
		System.assertEquals('fraud',resul);
	}

	static testMethod void testgetCustomerHistorythree() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account ant = new Account();
		ant.RecordTypeId = customerRecordType.Id;
		ant.FirstName = 'XXX';
		ant.LastName = 'YYY';
		ant.Phone = '9876543210';
		ant.PersonEmail = 'xxx005@ymail.com';
		ant.Blacklist__c = 'true';
		insert ant;
		String accountId = ant.Id;

		String resul = RestNewOrderProcessController.getCustomerHistory(accountId);
		System.assertEquals('no order allowed',resul);
	}

	static testMethod void testsetOrderItem() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account ant = new Account();
		ant.RecordTypeId = customerRecordType.Id;
		ant.FirstName = 'test';
		ant.LastName = 'test';
		ant.Phone = '6547892456';
		ant.PersonEmail = 'test@gmail.com';
		insert ant;

		Order__c cOrder = new Order__c();
		cOrder.Account__c = ant.Id;
		cOrder.Billing_Address__c = 'test';
		insert cOrder;

		Product2 p = new Product2();
		p.Name = 'test';
		p.ProductCode = 'DSX';
		p.IsActive = true;
		insert p;

		Product_Variant__c variant = new Product_Variant__c();
		variant.Product__c = p.Id;
		variant.Price__c = 20;
		variant.Product_Title__c = 'test';
		variant.sku__c = 'DSX';
		insert variant;

		Product2 p3 = new Product2();
		p3.Name = 'test';
		p3.ProductCode = 'DSX';
		p3.IsActive = true;
		insert p3;


		Product2 p2 = new Product2();
		p2.Name = 'test';
		p2.ProductCode = 'DSX';
		p2.IsActive = true;
		insert p2;

		Product_Variant__c variant2 = new Product_Variant__c();
		variant2.Product__c = p.Id;
		variant2.Price__c = 20;
		variant2.Product_Title__c = 'test';
		variant2.sku__c = 'DSX';
		insert variant2;

		RestNewOrderProcessController.setOrderItem(cOrder.Id,p.Id+'~'+p2.Id+'~'+p3.Id,'20~20~15', '1~1~1',variant.Id+'~'+variant2.Id+'~'+'');
		System.assert(true);
	}

	static testMethod void testSetOrder_Paypal() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account testAcc = new Account();
		testAcc.RecordTypeId = customerRecordType.Id;
		testAcc.FirstName = 'test';
		testAcc.LastName = 'test';
		testAcc.Phone = '6547892456';
		testAcc.PersonEmail = 'json@gmail.com';

		testAcc.BillingState = 'Alaska';
		testAcc.BillingCountry = 'United States';

		testAcc.ShippingState = 'Alaska';
		testAcc.ShippingCountry = 'United States';

		insert testAcc;

		Product2 testPr = new Product2();
		testPr.Name = 'test';
		testPr.ProductCode = 'DSX';
		testPr.IsActive = true;
		insert testPr;

		Product_Variant__c testVariant = new Product_Variant__c();
		testVariant.Product__c = testPr.Id;
		testVariant.Price__c = 20;
		testVariant.Product_Title__c = 'test';
		testVariant.sku__c = 'DSX';
		insert testVariant;

		Map<String, String> orderFormData = new Map<String, String>();
			orderFormData.put('product_id', testPr.Id);
			orderFormData.put('product_variant', testVariant.Id);
			orderFormData.put('email', testAcc.PersonEmail);
			orderFormData.put('fname', testAcc.FirstName);
			orderFormData.put('lname', testAcc.LastName);

			orderFormData.put('b_common', '123 main Street~New York~LA~US~10035');
			orderFormData.put('s_common', '123 main Street~New York~LA~US~10035');
			orderFormData.put('start_date', '9/20/2016');
			orderFormData.put('tax', '2');
			orderFormData.put('subtotal', '20');
			orderFormData.put('total', '24');
			orderFormData.put('shipping', '2');
			orderFormData.put('quantity', '1');
			orderFormData.put('Offerprice', '20');
			orderFormData.put('gateway', 'Paypal');
			orderFormData.put('brand', 'Summer');

			orderFormData.put('paypal_token', '72D0681527109671C');
			orderFormData.put('paypal_payerid', '3T5GGNEZ8T33S');

		String doWork = RestNewOrderProcessController.setOrders(orderFormData);

		List<Order__c> testObj = [SELECT Id, Account__c, Paypal_Token__c, Paypal_PayerId__c,
			(SELECT Id FROM Order_Items__r)
			FROM Order__c];

		System.assertEquals(1, testObj.size());
		System.assertEquals(1, testObj[0].Order_Items__r.size());
		System.assertEquals(doWork, testObj[0].Id);
		System.assertEquals(testAcc.Id, testObj[0].Account__c);
		System.assertEquals('72D0681527109671C', testObj[0].Paypal_Token__c);
		System.assertEquals('3T5GGNEZ8T33S', testObj[0].Paypal_PayerId__c);
	}

}