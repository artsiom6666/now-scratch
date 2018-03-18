public with sharing class RestDataSerializedController {

	public static String setSerializedData( String data ){


		String check ='';
		String innerPair;
		String[] innerList;
		Map<String, String> orderData = new Map<String, String>();
		String[] values = data.split('--');
		for(Integer i = 0; i< values.size() ; i++){

			innerPair = values[i];
			innerList =  innerPair.split('__');

			if(innerList.size() == 2){

				orderData.put(innerList[0], innerList[1]);
			}else{

				orderData.put(innerList[0], '');
			}
		}
		/* Insert Order into Chargent Custom object */
		String result;
		try{

			result = RestNewOrderProcessController.setOrders(orderData);
		}catch(Exception e){

			RestAddressVerificationControllerV2.setLog('Rest Call from Heroku', 'Error on line # '+e.getLineNumber()+'. '+e.getMessage()+'. '+e.getCause(), null);
			result = 'insertFail';
		}
		return result;
	}
}