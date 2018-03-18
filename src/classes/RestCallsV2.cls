@RestResource(urlMapping='/V2/TouchCRRest/*')
global with sharing class RestCallsV2 {

	@HttpGet
	global static void doGet() {
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

		Map<String, Object> requestMap = new Map<String,Object>();
		requestMap.put('method', req.requestURI);
		requestMap.put('generalData', req.params);
		String resultJson = JSON.serialize(requestMap);

		res.addHeader('Content-Type', 'application/json');
		res.responseBody = Blob.valueOf(doGet(resultJson));
	}

	global static String doGet(String reqUriString) {
		String result = '{"status":"error","error":"method name required"}';

		RestHelper.RestCallsWrapper wrappObj = (RestHelper.RestCallsWrapper)JSON.deserialize(reqUriString, RestHelper.RestCallsWrapper.class);
		try {
			if (wrappObj.method.endsWith('getscp')) {
				result = JSON.serialize(TouchCRHelper.getAvailableStatesAndCountries());
			}
			else if (wrappObj.method.endsWith('getPersonAccount')) {
				result = RestPersonAccountController.getPersonAccount(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getOrders')) {
				result = RestOrderController.getOrders(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getOrder')) {
				result = RestOrderController.getOrder(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getCardInfo')) {
				result = RestOrderController.getCardInfo(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getOrdersTransactions')) {
				result = RestOrderController.getOrdersTransactions(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getAffiliateOffers')) {
				result = ExtensionsHelperDummy.getAffiliateOffers(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getAffiliateOffer')) {
				result = ExtensionsHelperDummy.getAffiliateOffer(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getPixels')) {
				result = ExtensionsHelperDummy.getPixels(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getPixel')) {
				result = ExtensionsHelperDummy.getPixel(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getPayouts')) {
				result = ExtensionsHelperDummy.getPayouts(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getPayout')) {
				result = ExtensionsHelperDummy.getPayout(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getAffiliateOfferLink')) {
				result = ExtensionsHelperDummy.getAffiliateOfferLink(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getCommissionsEarned')) {
				result = ExtensionsHelperDummy.getCommissionsEarned(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getCoupon')) {
				result = RestCouponController.getCoupon(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getFranchisee')) {
				result = ExtensionsHelperDummy.getFranchisee(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getFranchiseeInfo')) {
				result = ExtensionsHelperDummy.getFranchiseeInfo(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getFranchiseeForTerritory')) {
				result = ExtensionsHelperDummy.getFranchiseeForTerritory(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getSubscriptions')) {
				result = RestSubscriptionController.getSubscriptions(wrappObj.generalData);
			}
		}
		catch (Exception e) {
			result = '{"status":"error","error":"' + e.getMessage() + '"}';
		}
		return result;
	}

	@HttpPost
	global static void doPost() {
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

		res.addHeader('Content-Type', 'application/json');
		res.responseBody = Blob.valueOf(RestCallsV2.doPost(req.requestBody.toString()));
	}

	global static String doPost(String strJSON) {
		String result = '{"status":"error","error":"method name required"}';
		try {
			//package TouchCRBase
			JSONWrapper wrapperObj = (JSONWrapper) JSON.deserialize(strJSON, JSONWrapper.class);
			if (wrapperObj.method == 'chargeUpsellV2') {
				result = RestChargeUpsellController.chargeUpsellV2(wrapperObj.inputDataMap);
			}
			if (wrapperObj.method == 'getChargedV2') {
				result = RestPaymentProcessController.processPaymentV2(wrapperObj.inputDataMap, (Map<String, Object>) wrapperObj.creditCard);
			}

			//customization WishList
			RestHelper.RestCallsWrapper wrappObj = (RestHelper.RestCallsWrapper)JSON.deserialize(strJSON, RestHelper.RestCallsWrapper.class);
			if (wrappObj.method == 'setCase') {
				result = RestCaseController.setCase(wrappObj.generalData);
			}
			else if (wrappObj.method == 'setUser') {
				result = RestUserController.setUser(wrappObj.generalData);
			}
			else if (wrappObj.method == 'setPersonAccount') {
				result = RestPersonAccountController.setPersonAccount(wrappObj.generalData);
			}
			else if (wrappObj.method == 'setLead') {
				result = RestLeadController.setLead(wrappObj.generalData);
			}
			else if (wrappObj.method == 'setGuest') {
				result = RestOrderController.setGuest(wrappObj.generalData, wrappObj.dataForOrderItems);
			}
			else if (wrappObj.method == 'setOrder') {			
				result = RestOrderController.setOrder(wrappObj.generalData, wrappObj.dataForOrderItems);
			}
			else if (wrappObj.method == 'chargeOrder') {
				result = RestOrderController.chargeOrder(wrappObj.generalData, wrappObj.creditCard);
			}
			else if (wrappObj.method == 'chargeUpsell') {
				result = RestOrderController.chargeUpsell(wrappObj.generalData);
			}
			else if (wrappObj.method == 'refundTransaction') {
				result = RestOrderController.refundTransaction(wrappObj.generalData);
			}
			else if (wrappObj.method == 'authorizePaymentOption') {
				result = RestOrderController.authorizePaymentOption(wrappObj.generalData, wrappObj.creditCard);
			}
			else if (wrappObj.method == 'setAuthorizeOrder') {
				result = RestOrderController.setAuthorizeOrder(wrappObj.generalData);
			}
			else if (wrappObj.method == 'setAffiliateOffer') {
				result = ExtensionsHelperDummy.setAffiliateOffer(wrappObj.generalData);
			}
			else if (wrappObj.method == 'setAffiliatePayout') {
				result = ExtensionsHelperDummy.setAffiliatePayout(wrappObj.generalData);
			}
			else if (wrappObj.method == 'setAffiliatePixel') {
				result = ExtensionsHelperDummy.setAffiliatePixel(wrappObj.generalData);
			}
			else if (wrappObj.method == 'setAffiliateOfferLink') {
				result = ExtensionsHelperDummy.setAffiliateOfferLink(wrappObj.generalData);
			}
			else if (wrappObj.method == 'setAccountWithUser') {
				result = RestPersonAccountController.setAccountWithUser(wrappObj.generalData);
			}
			else if (wrapperObj.method == 'setFranchisee') {
				result = ExtensionsHelperDummy.setFranchisee(wrappObj.generalData);
			}
			else if (wrappObj.method == 'setSubscription') {
				result = RestSubscriptionController.setSubscription(wrappObj.generalData);
			}
			else if (wrappObj.method.endsWith('getPickListsValues')) {
				result = JSON.serialize(TouchCRHelper.getPickListsValues(wrappObj.generalData));
			}
			else if (wrapperObj.method == 'updatePaypalStatus') {
				result = RestPaypalStatusController.updatePaypalStatus(wrappObj.generalData);
			}
		}
		catch (Exception e) { result = '{"status":"error","error":"' + e.getMessage() + '"}'; }
		return result;
	}

	@HttpDelete
	global static void doDelete() {
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

		res.addHeader('Content-Type', 'application/json');
		res.responseBody = Blob.valueOf(doDelete(req.requestURI, req.params));
	}

	global static String doDelete(String reqUriString, Map<String, String> params) {
		String result = '{"status":"error","error":"method name required"}';
		try {
			if (reqUriString.endsWith('deletePersonAccount')) {
				result = RestPersonAccountController.deletePersonAccount(params);
			}
			if (reqUriString.endsWith('removePaymentOption')) {
				result = RestOrderController.removePaymentOption(params);
			}
			if (reqUriString.endsWith('deleteOrder')) {
				result = RestOrderController.deleteOrder(params);
			}
			if (reqUriString.endsWith('deleteAffiliateOfferLink')) {
				result = ExtensionsHelperDummy.deleteAffiliateOfferLink(params);
			}
			if (reqUriString.endsWith('deletePixel')) {
				result = ExtensionsHelperDummy.deletePixel(params);
			}
		}
		catch (Exception e) {
			result = '{"status":"error","error":"' + e.getMessage() + '"}';
		}
		return result;
	}

	public class JSONWrapper {
		public String method { get; set; }

		public Map<String, String> creditCard { get; set; }
		public Map<String, String> inputDataMap { get; set; }
	}

}