@isTest
private class RestCallsTest {

	static testMethod void RestCallsGetTest() {
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/TouchCRBase/V1/TouchCRRest/';
		req.httpMethod = 'GET';

		RestContext.request = req;
		RestContext.response = res;

		RestCalls.doGet();

		System.assertEquals(null, res.responseBody);
	}

	static testMethod void RestCallsPostTest() {
		TouchCR_Settings__c objFirst = new TouchCR_Settings__c(
			Name = 'MinFraud.RatingFirst',
			Value__c = '30'
		);

		TouchCR_Settings__c objSecond = new TouchCR_Settings__c(
			Name = 'MinFraud.RatingSecond',
			Value__c = '75'
		);
		insert new List<TouchCR_Settings__c>{objFirst, objSecond};

		Map<String, String> minFraudSetting = new Map<String, String>();
			minFraudSetting.put('MinFraud.ApiKey', 'testAPIkey');
		TouchCRHelper.setSettings(minFraudSetting);
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];

		Account ant = new Account(RecordTypeId = customerRecordType.Id, FirstName = 'test', LastName = 'test', Phone = '6547892456', PersonEmail = 'test@gmail.com');
		insert ant;

		Order__c orderItem = new Order__c(
			Account__c = ant.Id, Billing_Email__c = 'test@gmail.com', Status__c = 'Initiated', Billing_First_Name__c = 'test',
			Billing_Last_Name__c = 'dx', Billing_Phone__c = '9876543210', Billing_Address__c = '123 main Street',
			Billing_City__c =  'New York', Billing_State__c = 'LA', Billing_Country__c = 'United States',
			Billing_Zip_Postal__c = '10035', Shipping_Address__c = '123 main Street', Shipping_City__c = 'New York',
			Shipping_State__c = 'LA', Shipping_Country__c = 'United States', Shipping_Zip_Postal__c = '10035',
			Subtotal__c = 10, Shipping__c = 2, Tax__c= 2, Named_Agent__c = 'TouchCR Agent',
			Currency__c = 'US Dollar', Payment_Method__c = 'Credit Card'
		);
		insert orderItem;

		Payment_Agents__c newPaymentAgents = new Payment_Agents__c(
			Name = 'TouchCR Agent', Security_Key__c = 'test',
			Active__c = true, Type__c = 'Stripe', Merchant_ID__c = 'test'
		);
		insert newPaymentAgents;

		Product2 product = new Product2(
			Name = 'test', IsActive = true
		);

		Product2 product1 = new Product2(
			Name = 'test', ProductCode = 'DSX', IsActive = true
		);
		insert new List<Product2>{product, product1};

		Product_Variant__c variant = new Product_Variant__c(
			Product__c = product1.Id, Price__c = 20,
			Product_Title__c = 'test', sku__c = 'DSX'
		);

		Product_Variant__c variant1 = new Product_Variant__c(
			Product__c = product1.Id, Price__c = 20,
			Product_Title__c = 'test', Sku__c = 'DSX'
		);
		insert new List<Product_Variant__c>{variant, variant1};

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/TouchCRBase/V1/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"chargeUpsell","payment_frequency":"Once","payment_status":"","payment_start":"12/02/2016","chargeDate":"02","orderId":"a05550000063tQD"}');

		RestContext.request = req;
		RestContext.response = res;

		String resultChargeUpsell = RestCalls.doPost();
		System.assertEquals('true', resultChargeUpsell);

		req.requestURI = '/services/apexrest/TouchCRBase/V1/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"addUpsell","orderId":"' + orderItem.Id + '","price":20,"shipping":0,"tax":0,"product_id":"01t550000017EgQ","quantity":1}');

		String resultAddUpsell = RestCalls.doPost();
		System.assertEquals(30, resultAddUpsell.length());

		req.requestURI = '/services/apexrest/TouchCRBase/V1/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"setSerializedData","data":""}');

		String resultSetSerializedData = RestCalls.doPost();
		System.assertEquals(null, resultSetSerializedData);

		req.requestURI = '/services/apexrest/TouchCRBase/V1/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"setLead","email":"json_data@test.com","phone":"9876543210","fname":"JSON","lname":"DATA","utm_medium":"NA","utm_campaign":"NA","utm_content":"NA","utm_term":"NA","sales_funnel_name":"0","referral_domain_url":"dashboard_heroku_com","landing_page_url":"https://of-commoncode-test-stagin-pr-7_herokuapp_com/","utm_source":"NA"}');

		String resultSetLead = RestCalls.doPost();
		System.assertEquals('Added', resultSetLead);

		req.requestURI = '/services/apexrest/TouchCRBase/V1/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"getCharged","payment_frequency":"Once","payment_status":"","payment_start":"12/02/2016","chargeDate":"02","orderId":"' + orderItem.Id + '"}');

		String resultGetCharged = RestCalls.doPost();
		System.assertEquals('true', resultGetCharged);

		req.requestURI = '/services/apexrest/TouchCRBase/V1/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"getCouponDiscount","couponCode":"ABC","orederDate":"12/02/2016","productId":"' + product.Id + '"}');

		String resultGetCouponDiscount = RestCalls.doPost();
		System.assertEquals('invalid Coupon', resultGetCouponDiscount);

		req.requestURI = '/services/apexrest/TouchCRBase/V1/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"getSaleTax"}');

		String resultGetSaleTax = RestCalls.doPost();

		req.requestURI = '/services/apexrest/TouchCRBase/V1/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"updatePaypalStatus","orderId":"' + orderItem.Id + '","status":"inpaid"}');

		String resultUpdatePaypalStatus = RestCalls.doPost();

		req.requestURI = '/services/apexrest/TouchCRBase/V1/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"getShipping","country":"United_States"}');

		String resultGetShipping = RestCalls.doPost();
		System.assertEquals('0', resultGetShipping);

		req.requestURI = '/services/apexrest/TouchCRBase/V1/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"setOrders","orderFormData":{"product_id":"' + product1.Id + '~' + product1.Id + '","product_variant":"' + variant.Id + '~' + variant1.Id + '","email":"87684647864768dx@gmail.com","fname":"david","lname":"huggs","phone":"9876543210","b_common":"123mainStreet~NewYork~LA~UnitedStates~10035","s_common":"123mainStreet~NewYork~LA~UnitedStates~10035","utm_source":"testsource","utm_medium":"testmedium","utm_campaign":"testcampaign","utm_content":"testcontent","utm_term":"testterm","sales_funnel_name":"teststatefunnel","landing_page_url":"testlandingpageurl","referral_domain_url":"testreferraldomian","start_date":"9/20/2016","tax":"2","subtotal":"20","total":"24","shipping":"2","quantity":"1~1","Offerprice":"20~20","gateway":"Authorize.net","brand":"testbrand"}}');

		String resultSetOrders = RestCalls.doPost();
	}

	static testMethod void RestCallsV2GetTest() {
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/TouchCRBase/V2/TouchCRRest/getscp';
		req.httpMethod = 'GET';

		RestContext.request = req;
		RestContext.response = res;

		RestCallsV2.doGet();

		System.assertNotEquals(null, res.responseBody);
		if (TouchCRHelper.isSCPEnabled()) {
			System.assert(res.responseBody.toString().contains('US'));
		}
	}

	static testMethod void RestCallsdoPostTest() {
		Map<String, String> minFraudSetting = new Map<String, String>();
			minFraudSetting.put('MinFraud.ApiKey', 'testAPIkey');
		TouchCRHelper.setSettings(minFraudSetting);

		String resultChargeUpsell = RestCalls.doPost('{"method":"chargeUpsell","payment_frequency":"Once","payment_status":"","payment_start":"12/02/2016","chargeDate":"02","orderId":"a05550000063tQD"}');
		System.assertEquals('true', resultChargeUpsell);

		String resultGetShipping = RestCalls.doPost('{"method":"getShipping","country":"United_States"}');
		System.assertEquals('0', resultGetShipping);

		String resultSetSerializedData = RestCalls.doPost('{"method":"setSerializedData","data":""}');
		System.assertEquals(null, resultSetSerializedData);	
	}

	static testMethod void RestCallsV2PostTest() {
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account ant = new Account(RecordTypeId = customerRecordType.Id, FirstName = 'test', LastName = 'test', Phone = '6547892456', PersonEmail = 'test@gmail.com');
		insert ant;

		Order__c orderItem = new Order__c(
			Account__c = ant.Id, Billing_Email__c = 'test@gmail.com', Status__c = 'Initiated', Billing_First_Name__c = 'test',
			Billing_Last_Name__c = 'dx', Billing_Phone__c = '9876543210', Billing_Address__c = '123 main Street',
			Billing_City__c =  'New York', Billing_State__c = 'LA', Billing_Country__c = 'United States',
			Billing_Zip_Postal__c = '10035', Shipping_Address__c = '123 main Street', Shipping_City__c = 'New York',
			Shipping_State__c = 'LA', Shipping_Country__c = 'United States', Shipping_Zip_Postal__c = '10035',
			Subtotal__c = 10, Shipping__c = 2, Tax__c= 2, Named_Agent__c = 'TouchCR Agent',
			Currency__c = 'US Dollar', Payment_Method__c = 'Credit Card'
		);
		insert orderItem;

		Payment_Agents__c newPaymentAgents = new Payment_Agents__c(
			Name = 'TouchCR Agent', Security_Key__c = 'test',
			Active__c = true, Type__c = 'Stripe', Merchant_ID__c = 'test'
		);
		insert newPaymentAgents;

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/TouchCRBase/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"chargeUpsellV2","inputDataMap":{"":""}}');

		RestContext.request = req;
		RestContext.response = res;

		RestCallsV2.doPost();
		System.assertNotEquals(null, res.responseBody);
		System.assert(res.responseBody.toString().contains('Order Id was not found'));

		req.requestURI = '/services/apexrest/TouchCRBase/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"getChargedV2","inputDataMap":{"orderId":"' + orderItem.Id + '"},"creditCard":{"CardNumber":"4242424242424242","CardExpirationMonth":"01","CardExpirationYear":"01","CardCCV":"123"}}');

		RestCallsV2.doPost();
		System.assertNotEquals(null, res.responseBody);
		System.assert(res.responseBody.toString().contains('true'));

	}
}