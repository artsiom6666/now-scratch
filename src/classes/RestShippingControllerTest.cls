@isTest
public class RestShippingControllerTest {

    static testMethod void testcreateNewShippingone(){ 
        string country = 'United States';        
        Decimal strResponse = RestShippingController.getValidate(country);
        System.assertEquals(0,strResponse);
    }
}