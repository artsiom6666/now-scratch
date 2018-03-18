public with sharing class RestShippingController {

	public static Decimal getValidate(String country){

		Decimal response;
		Map<String,Object> result;
		RestShippingDummyController.shippingInnerClass shippingInstance;
		Map<String,Object> shippingMap;


		String shippingClassNameExternal = 'touchCrAvConn.AvalaraShippingCalculationClass';
		String shippingClassNameInternal = 'RestShippingDummyController.shippingInnerClass';

		try{

			/* Try actual Shipping API*/
			Type invokeClassType = Type.forName(shippingClassNameExternal);
			shippingInstance = (RestShippingDummyController.shippingInnerClass) invokeClassType.newInstance();
			shippingMap = new Map<String,Object>();
			result = shippingInstance.InvokeMethod(shippingMap);
			return (Integer) result.get('Shipping');

		}catch(Exception e) {


			/* Call Dummy Class to get  Shipping */
			Type invokeDummyClassType = Type.forName(shippingClassNameInternal);
			shippingInstance = (RestShippingDummyController.shippingInnerClass) invokeDummyClassType.newInstance();
			shippingMap = new Map<String,Object>();
			result = shippingInstance.InvokeMethod(shippingMap);

			if (shippingInstance == NULL) {

				return response;
			}else{

				return (Integer) result.get('Shipping');
			}
		}
	}
}