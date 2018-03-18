@isTest
public class RestShippingDummyControllerTest {

    static testMethod void Shipping(){
        String calculateShippingClassNameInternal = 'RestShippingDummyController.shippingInnerClass';        
        Type invokeClassType = Type.forName(calculateShippingClassNameInternal);        
        RestShippingDummyController.shippingInnerClass shippingCalculationInstance = (RestShippingDummyController.shippingInnerClass) invokeClassType.newInstance();

        Map<String,Object> mp = new Map<String,Object>();

        Map<String,Object> result = shippingCalculationInstance.InvokeMethod(mp);
        Integer tmp = (Integer) result.get('Shipping');
        System.assertEquals(0, tmp);
        
    }    
}