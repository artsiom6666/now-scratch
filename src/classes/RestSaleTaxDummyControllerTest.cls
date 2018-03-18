@isTest 
public class RestSaleTaxDummyControllerTest {

    static testMethod void testTax(){

        String calculateTaxClassNameInternal = 'RestSaleTaxDummyController.TaxCalculationInnerClass';        
        Type invokeClassType = Type.forName(calculateTaxClassNameInternal);        
        RestSaleTaxDummyController.TaxCalculationInnerClass TaxCalculationInstance = (RestSaleTaxDummyController.TaxCalculationInnerClass) invokeClassType.newInstance();

        Map<String,Object> mp = new Map<String,Object>();
        mp.put('Tax', 0);
        Map<String,Object> result = new Map<String,Object>();
        result = TaxCalculationInstance.InvokeMethod(mp);
        Integer tmp = (Integer) result.get('Tax');
        System.assertEquals(0, tmp);
    }
}