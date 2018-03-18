public with sharing class RestHerokuAddressVerification {

	public static String getValidateHerokuData(String data) {
		Map<String, String> address = new  Map<String, String>();
		try{

			String[] addressData =  data.split('~');
			address.put('address', addressData[0]);
			address.put('city', addressData[1]);
			address.put('state', addressData[2]);
			address.put('zip', addressData[3]);

		}catch(Exception e){

			RestAddressVerificationControllerV2.setLog('Address Varification', 'Error on line # '+e.getLineNumber()+'. '+e.getMessage()+'. '+e.getCause(), null);
			return 'invalid';
		}
		// Proxy
		TouchCR_Settings__c proxySettings = TouchCR_Settings__c.getValues('Proxy.isEnabled');
		Boolean isProxyEnabled = false;
		if (proxySettings != null) {
			isProxyEnabled = Boolean.valueOf(proxySettings.Value__c);
		}
		if (isProxyEnabled) {
			RestAddressVerificationControllerV2.isProxy = true;
		}
		String response = RestAddressVerificationControllerV2.getValidate(address);
		return response;
	}
}