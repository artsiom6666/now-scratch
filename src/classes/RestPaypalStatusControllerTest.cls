@istest
public class RestPaypalStatusControllerTest {

	@istest public static void updatePaypalStatusTest() {

		TouchCR_Settings__c obj_APIKey = new TouchCR_Settings__c();
		obj_APIKey.Name = 'MinFraud.ApiKey';
		obj_APIKey.value__c = 'd4yoixUX1g1U';
		insert obj_APIKey;

		TouchCR_Settings__c obj_firstRating = new TouchCR_Settings__c();
		obj_firstRating.Name = 'MinFraud.RatingFirst';
		obj_firstRating.value__c = '30';
		insert obj_firstRating;

		TouchCR_Settings__c obj_secondRating = new TouchCR_Settings__c();
		obj_secondRating.Name = 'MinFraud.RatingSecond';
		obj_secondRating.value__c = '75';
		insert obj_secondRating;

		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];

		String email = 'json@gmail.com';
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

		Test.setMock(HttpCalloutMock.class, new RestFraudDetectionTwoMockResponse());
		Test.setMock(HttpCalloutMock.class, new RestPaymentProcessOneMockResponse());

		String resul = RestNewOrderProcessController.setOrders(orderFormData);

		Test.startTest();
		RestPaypalStatusController.updatePaypalStatus(resul, 'paid', null);
		Test.stopTest();
		Order__c order = [SELECT Id, Payment_Received__c, Status__c FROM Order__c WHERE Id = :resul];
		System.assertEquals('Full', order.Payment_Received__c);
		System.assertEquals('Initiated', order.Status__c);

	}

	@istest public static void updatePaypalStatus2Test() {

		TouchCR_Settings__c obj_APIKey = new TouchCR_Settings__c();
		obj_APIKey.Name = 'MinFraud.ApiKey';
		obj_APIKey.value__c = 'd4yoixUX1g1U';
		insert obj_APIKey;

		TouchCR_Settings__c obj_firstRating = new TouchCR_Settings__c();
		obj_firstRating.Name = 'MinFraud.RatingFirst';
		obj_firstRating.value__c = '30';
		insert obj_firstRating;

		TouchCR_Settings__c obj_secondRating = new TouchCR_Settings__c();
		obj_secondRating.Name = 'MinFraud.RatingSecond';
		obj_secondRating.value__c = '75';
		insert obj_secondRating;

		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		String email = 'json@gmail.com';
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

		Test.setMock(HttpCalloutMock.class, new RestFraudDetectionThreeMockResponse());
		String resul = RestNewOrderProcessController.setOrders(orderFormData);
		Order__c order = [SELECT Id, Account__c FROM Order__c WHERE Id = :resul];
		String idChargentOrdersAccount = order.Account__c;
		Test.startTest();
		RestPaypalStatusController.updatePaypalStatus(resul, 'unpaid', null);
		Test.stopTest();

		Account acc = [SELECT Id, Blacklist__c FROM Account WHERE Id = :idChargentOrdersAccount];
		System.assertEquals('True', acc.Blacklist__c);

	}
}