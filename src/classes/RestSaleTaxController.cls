public with sharing class RestSaleTaxController {

	public static Decimal getSalesTax(){

		Decimal response;
		Map<String,Object> result;
		RestSaleTaxDummyController.TaxCalculationInnerClass TaxCalculationInstance;
		Map<String,Object> saleTaxMap;


		String calculateTaxClassNameExternal = 'touchCrAvConn.AvalaraTaxCalculationClass';
		String calculateTaxClassNameInternal = 'RestSaleTaxDummyController.TaxCalculationInnerClass';

		try{

			/* Try actual SaleTax API*/
			Type invokeClassType = Type.forName(calculateTaxClassNameExternal);
			TaxCalculationInstance = (RestSaleTaxDummyController.TaxCalculationInnerClass) invokeClassType.newInstance();
			saleTaxMap = new Map<String,Object>();
			result = TaxCalculationInstance.InvokeMethod(saleTaxMap);
			return (Integer) result.get('Tax');

		}catch(Exception e) {


			/* Call Dummy Class to get Sale Tax*/
			Type invokeDummyClassType = Type.forName(calculateTaxClassNameInternal);
			TaxCalculationInstance = (RestSaleTaxDummyController.TaxCalculationInnerClass) invokeDummyClassType.newInstance();
			saleTaxMap = new Map<String,Object>();
			result = TaxCalculationInstance.InvokeMethod(saleTaxMap);

			if (TaxCalculationInstance == NULL) {

				return response;
			}else{

				return (Integer) result.get('Tax');
			}
		}
	}
}