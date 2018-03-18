@isTest 
public class RestSaleTaxControllerTest {

    static testMethod void testSalesTax(){
  
        Decimal strResponse = RestSaleTaxController.getSalesTax();
        System.assertEquals(0,strResponse);
    }
}