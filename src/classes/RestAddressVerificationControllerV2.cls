public with sharing class RestAddressVerificationControllerV2 {

	public static Boolean isProxy = false;

	private static String rawRequest;
	private static String rawResponse;

	private static String requestZip {get; set;}
	private static String responseZip {get; set;}

	//CONSTANTS
	private static String VALID = 'valid';
	private static String INVALID = 'invalid';

	// HELPER METHODS
	private static void setZip(String zip) {
		requestZip = zip;
		responseZip = NULL;
	}

	private static String validateZip() {
		if (String.isBlank(requestZip) || String.isBlank(responseZip)) {
			return INVALID;
		}
		return (requestZip.containsIgnoreCase(responseZip)) ? VALID : INVALID;
	}

	public static List<String> getApiCallInfo() {
		return new List<String> {'Request Body:', rawRequest, 'Response Body:', rawResponse};
	}

	public static HttpResponse makeApiCall(String payloadData) {
			Http USPSHttp = new Http();
			HttpRequest request = new HttpRequest();
			request.setMethod('GET');
			request.setHeader('X-OrgID', UserInfo.getOrganizationId());

			//Get stormpath credentials
			Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();
			if (isProxy) {
				request.setEndpoint('callout:TouchCRBase__SecureProxy/shipping/' + payloadData);
				if (settingsMap.containsKey('Endpoint.TokenType') && settingsMap.containsKey('Endpoint.TokenPart1') && settingsMap.containsKey('Endpoint.TokenPart2')) {
					TouchCR_Settings__c tokenType = settingsMap.get('Endpoint.TokenType');
					TouchCR_Settings__c tokenPart1 = settingsMap.get('Endpoint.TokenPart1');
					TouchCR_Settings__c tokenPart2 = settingsMap.get('Endpoint.TokenPart2');
					request.setHeader('Authorization', tokenType.Value__c.capitalize() + ' ' + tokenPart1.Value__c + tokenPart2.Value__c);
				}
			}
			else {
				request.setEndpoint('callout:TouchCRBase__USPSShipping/' + payloadData);
			}
			HttpResponse res = USPSHttp.send(request);

			rawRequest = request.getEndpoint();
			rawResponse = res.getBody();

			return res;
	}

	public static String getValidate(Map<String, String> addressData) {

		//Set varaibles for this validation 
		setZip(addressData.get('zip'));
		String address = addressData.get('address');
		String city  = addressData.get('city');
		String state = addressData.get('state');

		String uid = TouchCR_Settings__c.getValues('USPS.UserID').value__c;

		String data = '<AddressValidateRequest USERID="'+uid+'"><Address><Address1></Address1><Address2>'+address+'</Address2><City>'+city+'</City><State>'+state+'</State><Zip5>'+requestZip+'</Zip5><Zip4></Zip4></Address></AddressValidateRequest>';
		String URL = 'ShippingAPI.dll?API=Verify&XML=';
		data = EncodingUtil.urlEncode(data, 'UTF-8');
		URL  = URL +data;
		/*Put version of request into params
			with v=1 or without v param makes request without checking stormpath credentials
			with v=2 param makes request with checking stormpath credentials			
		*/
		URL += '&v=2';

		/*If v=2 it is required to set ClientId and ClientSecret params or/and set auth token on header*/
		Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();
		if (settingsMap.containsKey('Endpoint.ClientId') && settingsMap.containsKey('Endpoint.ClientSecret')) {
			TouchCR_Settings__c clientId = settingsMap.get('Endpoint.ClientId');
			TouchCR_Settings__c clientSecret = settingsMap.get('Endpoint.ClientSecret');
			URL += '&spApiKeyId=' + clientId.Value__c;
			URL += '&spApiKeySecret=' + ClientSecret.Value__c;
		}

		try{
			/*HttpRequest USPSRequest = new HttpRequest();
			Http USPSHttp = new Http();
			USPSRequest.setMethod('GET');
			USPSRequest.setEndpoint('callout:USPSShipping/'+URL);
			HttpResponse res = USPSHttp.send(USPSRequest);*/

			HttpResponse res = makeApiCall(URL);

			//update token
			if (res.getHeader('Access-Token') != null) {
				TouchCRHelper.setAuthCredentinals(res.getHeader('Access-Token'));
			}

			DOM.Document xmlDOC = new DOM.Document();
			String result = res.getBody();
			xmlDOC.load(result);

			DOM.XMLNode rootElement = xmlDOC.getRootElement();

			for(DOM.XMLNode xmlnodeobj:xmlDOC.getRootElement().getChildElements()) {
				loadChilds(xmlnodeobj);
			}

		}catch(Exception e){

			System.debug('The following exception has occurred: ' + e.getMessage() +' on line number: '+e.getLineNumber());
			RestAddressVerificationControllerV2.setLog('Rest AddressVarification', 'Error on line # '+e.getLineNumber()+'. '+e.getMessage()+'. '+e.getCause(), null);
		}

		return validateZip();
	}

	/* Find Zip Node from XML Object */
	public static void loadChilds(DOM.XMLNode xmlnode){

		for(Dom.XMLNode child : xmlnode.getChildElements()) {

			if(child.getText()!= null){

				if(child.getName() == 'Zip5'){
					responseZip = child.getText();
				}
			}
			loadChilds(child);
		}
	}

	public static void setLog(String title, String description, String accountId){

		Log__c errorLog = new Log__c(
			Event_Type__c = title,
			Event_Status__c = 'Error',
			Event_Endpoint__c = 'NA',
			Event_Description__c = description,
			Account__c = accountId
		);

		try {
			SFDCAccessController.InsertWithoutSharing (
				errorLog,
				'RestAddressVerificationControllerV2.cls [setLog]',
				new List<Schema.DescribeFieldResult> {
					Log__c.Event_Type__c.getDescribe(), Log__c.Event_Status__c.getDescribe(),
					Log__c.Event_Endpoint__c.getDescribe(), Log__c.Event_Description__c.getDescribe(),
					Log__c.Account__c.getDescribe()
				}
			);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}
}