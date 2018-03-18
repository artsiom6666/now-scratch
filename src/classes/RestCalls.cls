@RestResource(urlMapping='/V1/TouchCRRest/*')
global with sharing class RestCalls {

	@HttpGet
	global static String doGet() {
		RestRequest req = RestContext.request;
		return 'null';
	}

	@HttpPost
	global static String doPost() {
		RestRequest req = RestContext.request;
		return RestCalls.doPost(req.requestBody.toString());
	}

	global static String doPost(String strJSON) {
		String result;
		try {
			JSONWrapper wrapperObj = (JSONWrapper) JSON.deserialize(strJSON, JSONWrapper.class);
			if (wrapperObj.method == 'chargeUpsell') {
				result = RestChargeUpsellController.chargeUpsell(wrapperObj.payment_frequency, wrapperObj.payment_status, wrapperObj.payment_start,
					wrapperObj.chargeDate, wrapperObj.orderId);
			}
			if (wrapperObj.method == 'getCouponDiscount') {
				result = RestCouponController.getCouponDiscount(wrapperObj.couponCode, wrapperObj.orederDate, wrapperObj.productId);
			}
			if (wrapperObj.method == 'setSerializedData') {
				result = RestDataSerializedController.setSerializedData(wrapperObj.data);
			}
			if (wrapperObj.method == 'addressVerificationV2') {
				result = RestHerokuAddressVerification.getValidateHerokuData(wrapperObj.data);
			}
			if (wrapperObj.method == 'setLead') {
				result = RestLeadController.createLead(wrapperObj.email, wrapperObj.phone, wrapperObj.fname, wrapperObj.lname, wrapperObj.utm_medium, wrapperObj.utm_campaign,
					wrapperObj.utm_content, wrapperObj.utm_term, wrapperObj.sales_funnel_name, wrapperObj.referral_domain_url,
					wrapperObj.landing_page_url, wrapperObj.utm_source);
			}
			if (wrapperObj.method == 'getCharged') {
				result = RestPaymentProcessController.processPayment(wrapperObj.payment_frequency, wrapperObj.payment_status, wrapperObj.payment_start,
					wrapperObj.chargeDate, wrapperObj.orderId, (Map<String, Object>) wrapperObj.creditCard);
			}
			if (wrapperObj.method == 'updatePaypalStatus') {
				RestPaypalStatusController.updatePaypalStatus(wrapperObj.orderId, wrapperObj.status, wrapperObj.data);
				result = 'Success';
			}
			if (wrapperObj.method == 'getSaleTax') {
				result = String.valueOf(RestSaleTaxController.getSalesTax());
			}
			if (wrapperObj.method == 'getShipping') {
				result = String.valueOf(RestShippingController.getValidate(wrapperObj.country));
			}
			if (wrapperObj.method == 'addUpsell') {
				result = RestUpsellController.processUpsell(wrapperObj.orderId, wrapperObj.price, wrapperObj.shipping, wrapperObj.tax, wrapperObj.product_id, wrapperObj.quantity);
			}
			if (wrapperObj.method == 'setOrders') {
				result = RestNewOrderProcessController.setOrders(wrapperObj.orderFormData);
			}
			if (wrapperObj.method == 'getValidate') {
				result = RestAddressVerificationControllerV2.getValidate(wrapperObj.addressData);
			}
		}
		catch (Exception e) {
			return e.getMessage();
		}
		return result;
	}

	public class JSONWrapper {
		public String method { get; set; }

		public String payment_frequency { get; set; }
		public String payment_status { get; set; }
		public String payment_start { get; set; }
		public String chargeDate { get; set; }
		public String orderId { get; set; }
		public Map<String, String> creditCard { get; set; }

		public String couponCode { get; set; }
		public String orederDate { get; set; }
		public String productId { get; set; }

		public String data { get; set; }

		public String email { get; set; }
		public String phone { get; set; }
		public String lname { get; set; }
		public String fname { get; set; }
		public String utm_medium { get; set; }
		public String utm_campaign { get; set; }
		public String utm_content { get; set; }
		public String utm_term { get; set; }
		public String sales_funnel_name { get; set; }
		public String referral_domain_url { get; set; }
		public String utm_source { get; set; }
		public String landing_page_url { get; set; }

		public String status { get; set; }

		public String country { get; set; }

		public String product_id { get; set; }

		public Decimal price { get; set; }
		public Decimal shipping { get; set; }
		public Decimal tax { get; set; }
		public Decimal quantity { get; set; }

		public Map<String, String> orderFormData { get; set; }
		public Map<String, String> addressData { get; set; }
	}

}