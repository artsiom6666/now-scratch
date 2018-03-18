@isTest
private class RestCallsV2Test {

	static testMethod void RestCallsPostTest() {

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"setCase","generalData":{"Status":"New","Origin":"Web"}}');

		RestContext.request = req;
		RestContext.response = res;

		RestCallsV2.doPost();
		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"setPersonAccount","generalData":{"Id":"0010l000002Q1PoAAK","LastName":"test","FirstName":"test","PersonEmail":"test.test@gmail.com","Phone":"1234567890","BillingStreet":"Vulture St, Woolloongabba","BillingCity":"Brisbane","BillingState":"Queensland","BillingPostalCode":"4102","BillingCountry":"Australia","ShippingStreet":"Vulture St, Woolloongabba","ShippingCity":"Brisbane","ShippingState":"Queensland","ShippingPostalCode":"4102","ShippingCountry":"Australia","Geolocation__Longitude__s":"153.062496","Geolocation__Latitude__s":"-27.579233","CurrencyIsoCode":"AUD"}}');
		RestCallsV2.doPost();
		System.assertEquals(true, res.responseBody.toString().contains('error'));

		req.requestURI = '/services/apexrest/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"setLead","generalData":{"id":"0010l000002Q1PoAAK","lastName":"test","firstName":"Eugene","personEmail":"test@gmail.com","phone":"1234567890","street":"Vulture St, Woolloongabba","city":"Brisbane","state":"Queensland","postalCode":"4102","country":"Australia","longitude":153.062496,"latitude":-27.579233}}');
		RestCallsV2.doPost();
		System.assertEquals(true, res.responseBody.toString().contains('success'));

		req.requestURI = '/services/apexrest/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"setCase","generalData":{"status":"New","origin":"Web","ownerId":"0050l000000EfUV","orderId":"a080l00000071m2","currencyIsoCode":"AUD","subject":"","description":"123"}}');
		RestCallsV2.doPost();
		System.assertEquals(true, res.responseBody.toString().contains('error'));

		req.requestURI = '/services/apexrest/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"setUser","generalData":{"contactId":"0010l000002lXziAAE","accountId":"0010l000003ovrLAAQ","lastName":"Beam","firstName":"Tou ","alias":"jTou","username":"Beam.Tou.home.ice.cream@gmail.com","timeZoneSidKey":"Australia/Sydney","languageLocaleKey":"en_US","emailEncodingKey":"ISO-8859-1","localeSidKey":"en_AU","currencyIsoCode":"AUD"}}');
		RestCallsV2.doPost();
		System.assertEquals(true, res.responseBody.toString().contains('error'));

		req.requestURI = '/services/apexrest/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"chargeOrder","generalData":{"orderId":"0050l000000EfUV"},"creditCard":{"CardCCV":"242","CardExpirationYear":"19","CardExpirationMonth":"12","CardNumber":"4242424242424242"}}');
		RestCallsV2.doPost();
		System.assertEquals(true, res.responseBody.toString().contains('error'));

		req.requestURI = '/services/apexrest/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"setOrder","generalData":{"accountId":"0010l000002Qwjx","ownerId":"0050l000000EGU1","deliveryDate":"2017-07-25","deliveryType":"","longitude":0,"latitude":0,"countEskyCube":2,"countCoolboxesCube":0},"products":[{"productId":"01t0l000000DJAmAAO","price":"1","count":"2"}]}');
		RestCallsV2.doPost();
		System.assertEquals(true, res.responseBody.toString().contains('error'));

		req.requestURI = '/services/apexrest/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"chargeUpsell","generalData":{"orderId":"0050l000000EfUV"}}');
		RestCallsV2.doPost();
		System.assertEquals(true, res.responseBody.toString().contains('success'));

		req.requestURI = '/services/apexrest/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"refundTransaction","generalData":{"transactionId":"InvalidId"}}');
		RestCallsV2.doPost();
		System.assertEquals(true, res.responseBody.toString().contains('error'));

		req.requestURI = '/services/apexrest/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"setGuest","generalData":{"LastName":"test","FirstName":"test"}}');
		RestCallsV2.doPost();
		System.assertEquals(true, res.responseBody.toString().contains('error'));

		req.requestURI = '/services/apexrest/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"authorizePaymentOption","generalData":{"orderId":"InvalidId"}}');
		RestCallsV2.doPost();
		System.assertEquals(true, res.responseBody.toString().contains('error'));

		req.requestURI = '/services/apexrest/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"setAuthorizeOrder","generalData":{"accountId":"InvalidId"}}');
		RestCallsV2.doPost();
		System.assertEquals(true, res.responseBody.toString().contains('error'));

		req.requestURI = '/services/apexrest/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"setAffiliateOffer","generalData":{"accountId":"InvalidId"}}');
		RestCallsV2.doPost();
		System.assertEquals(true, res.responseBody.toString().contains('error'));

		req.requestURI = '/services/apexrest/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"setAffiliatePayout","generalData":{"accountId":"InvalidId"}}');
		RestCallsV2.doPost();
		System.assertEquals(true, res.responseBody.toString().contains('error'));

		req.requestURI = '/services/apexrest/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"setAffiliatePixel","generalData":{"accountId":"InvalidId"}}');
		RestCallsV2.doPost();
		System.assertEquals(true, res.responseBody.toString().contains('error'));

		req.requestURI = '/services/apexrest/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"setAffiliateOfferLink","generalData":{"accountId":"InvalidId"}}');
		RestCallsV2.doPost();
		System.assertEquals(true, res.responseBody.toString().contains('error'));

		req.requestURI = '/services/apexrest/V2/TouchCRRest/'; //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueOf('{"method":"setAccountWithUser","generalData":{"accountId":"InvalidId"}}');
		RestCallsV2.doPost();
		System.assertEquals(true, res.responseBody.toString().contains('error'));

	}

	static testMethod void RestCallsGetTest() {
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/V2/TouchCRRest/getPersonAccount';
		req.httpMethod = 'GET';

		RestContext.request = req;
		RestContext.response = res;

		RestCallsV2.doGet();

		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/getOrderItems';
		req.httpMethod = 'GET';
		RestCallsV2.doGet();
		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/getCardInfo';
		req.httpMethod = 'GET';
		RestCallsV2.doGet();
		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/getOrders';
		req.httpMethod = 'GET';
		RestCallsV2.doGet();
		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/getOrder';
		req.httpMethod = 'GET';
		RestCallsV2.doGet();
		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/getOrdersTransactions';
		req.httpMethod = 'GET';
		RestCallsV2.doGet();
		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/getscp';
		req.httpMethod = 'GET';
		RestCallsV2.doGet();
		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/getAffiliateOffers';
		req.httpMethod = 'GET';
		RestCallsV2.doGet();
		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/getAffiliateOffer';
		req.httpMethod = 'GET';
		RestCallsV2.doGet();
		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/getPixels';
		req.httpMethod = 'GET';
		RestCallsV2.doGet();
		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/getPixel';
		req.httpMethod = 'GET';
		RestCallsV2.doGet();
		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/getPayouts';
		req.httpMethod = 'GET';
		RestCallsV2.doGet();
		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/getPayout';
		req.httpMethod = 'GET';
		RestCallsV2.doGet();
		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/getAffiliateOfferLink';
		req.httpMethod = 'GET';
		RestCallsV2.doGet();
		System.assertNotEquals(null, res.responseBody);



	}

	static testMethod void RestCallsDeleteTest() {
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/V2/TouchCRRest/deletePersonAccount';
		req.httpMethod = 'DELETE';

		RestContext.request = req;
		RestContext.response = res;

		RestCallsV2.doDelete();

		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/removePaymentOption';
		req.httpMethod = 'DELETE';
		RestCallsV2.doDelete();
		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/deleteOrder';
		req.httpMethod = 'DELETE';
		RestCallsV2.doDelete();
		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/deleteAffiliateOfferLink';
		req.httpMethod = 'DELETE';
		RestCallsV2.doDelete();
		System.assertNotEquals(null, res.responseBody);

		req.requestURI = '/services/apexrest/V2/TouchCRRest/deletePixel';
		req.httpMethod = 'DELETE';
		RestCallsV2.doDelete();
		System.assertNotEquals(null, res.responseBody);

	}
}