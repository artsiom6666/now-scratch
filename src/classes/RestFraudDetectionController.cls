public with sharing class RestFraudDetectionController {

	public Decimal get_Fraud_Detection(String orderId){
		HttpRequest request = new HttpRequest();
		request.setMethod('POST');
		request.setEndPoint('callout:TouchCRBase__MinFraud');
		request.setHeader('X-OrgID', UserInfo.getOrganizationId());

		return get_Fraud_Detection(orderId, request);
	}
	public Decimal get_Fraud_Detection(String orderId, String endpoint){
		HttpRequest request = new HttpRequest();
		request.setMethod('POST');
		request.setEndPoint(endpoint);
		request.setHeader('X-OrgID', UserInfo.getOrganizationId());

		return get_Fraud_Detection(orderId, request);
	}

	private String rawRequest;
	private String rawResponse;
	private Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();

	public List<String> getApiCallInfo() {
		return new List<String> {'Request Body:', rawRequest, 'Response Body:', rawResponse};
	}

	/* This method will check fraud detection against the User billeing address, shipping address, email and phone number.
	* Parm: @orderId - this parm contain order id
	* Return: Return type is Decimal
	*/
	public Decimal get_Fraud_Detection(String orderId, HttpRequest req){

		List<Order__c> Orders = [
			SELECT Id, Billing_Address__c, Billing_City__c,
				Billing_State__c, Billing_Country__c,
				Billing_Zip_Postal__c, Shipping_City__c, Shipping_State__c,
				Shipping_Zip_Postal__c, Shipping_Country__c, Shipping_Address__c,
				Billing_Email__c, Billing_First_Name__c, Billing_Phone__c
			FROM Order__c
			WHERE Id =:orderId
		];


		Decimal score = 0;

		if(Orders.size()>0){

			/* Preparing data for fraud detection check */
			Order__c Order = Orders[0];

			TouchCR_Settings__c obj = TouchCR_Settings__c.getValues('MinFraud.ApiKey');
			if(obj == NULL) {
				RestAddressVerificationControllerV2.setLog('Fraud Detection', 'MinFraud.ApiKey can not be Null.', null);
				return NULL;
			}

			String APIKey = obj.Value__c;

			Map<String, String> data = new Map<String, String>();
			data.put('license_key', APIKey);
			data.put('i', 'customer_ip');
			data.put('city', Order.Billing_City__c);
			data.put('region', Order.Billing_State__c);
			data.put('postal', Order.Billing_Zip_Postal__c);

			//removed urlEncode because field can be null
//			data.put('country', EncodingUtil.urlEncode(Order.Billing_Country__c, 'UTF-8'));
			data.put('country', Order.Billing_Country__c);

//			String shippingAddress = EncodingUtil.urlEncode(Order.Shipping_Address__c, 'UTF-8');
			String shippingAddress = Order.Shipping_Address__c;

			data.put('shipAddr', shippingAddress);
			data.put('shipCity', Order.Shipping_City__c);
			data.put('shipRegion', Order.Shipping_State__c);
			data.put('shipPostal', Order.Shipping_Zip_Postal__c);

//			data.put('shipCountry', EncodingUtil.urlEncode(Order.Shipping_Country__c, 'UTF-8'));
			data.put('shipCountry', Order.Shipping_Country__c);

			data.put('domain', '');

//			data.put('custPhone', EncodingUtil.urlEncode(Order.Billing_Phone__c, 'UTF-8'));
			data.put('custPhone', Order.Billing_Phone__c);


			Blob email = Blob.valueOf(Order.Billing_Email__c);
			String email_md5 = EncodingUtil.base64Encode(email);
			Blob username = Blob.valueOf(Order.Billing_First_Name__c);
			String usernameMD5 = EncodingUtil.base64Encode(username);
			data.put('emailMD5', email_md5);
			data.put('usernameMD5', usernameMD5);
			/*Put version of request into params
				with v=1 or without v param makes request without checking stormpath credentials
				with v=2 param makes request with checking stormpath credentials
			 */
			data.put('v', '2');
			/*If v=2 it is required to set ClientId and ClientSecret params or/and set auth token on header*/

			if (this.settingsMap.containsKey('Endpoint.ClientId') && this.settingsMap.containsKey('Endpoint.ClientSecret')) {
				TouchCR_Settings__c clientId = this.settingsMap.get('Endpoint.ClientId');
				TouchCR_Settings__c clientSecret = this.settingsMap.get('Endpoint.ClientSecret');
				data.put('spApiKeyId', clientId.Value__c);
				data.put('spApiKeySecret', ClientSecret.Value__c);
			}

			if (this.settingsMap.containsKey('Endpoint.TokenType') && this.settingsMap.containsKey('Endpoint.TokenPart1') && this.settingsMap.containsKey('Endpoint.TokenPart2')) {
				TouchCR_Settings__c tokenType = this.settingsMap.get('Endpoint.TokenType');
				TouchCR_Settings__c tokenPart1 = this.settingsMap.get('Endpoint.TokenPart1');
				TouchCR_Settings__c tokenPart2 = this.settingsMap.get('Endpoint.TokenPart2');
				req.setHeader('Authorization', tokenType.Value__c.capitalize() + ' ' + tokenPart1.Value__c + tokenPart2.Value__c);
			}

			/* Preparing data for Http Request */
			String query = '';
			for (String getkey : data.keySet()) {
				String toaddvalue = data.get(getkey);
				if(query == null){
					query = getkey + '=' + toaddvalue;
				}else{
					query += '&' + getkey + '=' + toaddvalue;
				}
			}
			/* Execute Http request to minfraud */

			String result;
			try{
				Http h = new Http();
				//HttpRequest req = new HttpRequest();
				//req.setMethod('POST');
				//req.setEndPoint(endpoint);
				req.setBody(query);
				HttpResponse res = h.send(req);
				result = res.getBody();

				//for Proxy Tester
				rawRequest = req.getEndpoint();
				rawResponse = result;
				//update token
				if (res.getHeader('Access-Token') != null) {
					TouchCRHelper.setAuthCredentinals(res.getHeader('Access-Token'));
				}

			}catch(Exception e){

				RestAddressVerificationControllerV2.setLog('Fraud Detection', 'Error on line # '+e.getLineNumber()+'. '+e.getMessage()+'. '+e.getCause(), null);
			}

			/* Parsing data to get minfraud response */
			if (result != null && result != '') {

				String[] firstSplit = result.split(';');
				for(String singleVar : firstSplit){

					String[] secondSplit = singleVar.split('=');
					String tmp = secondSplit[0];
					tmp = tmp.trim();

					if(secondSplit.size()>1 && tmp == 'riskScore'){

						score =  Decimal.valueOf(secondSplit[1]);
					}
				}
			}
		}
		return score;
	}
}