@isTest
public class RestUpsellControllerTest {

    static testMethod void testCreateNewUpsell(){
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        Account account = new Account();
        account.RecordTypeId = customerRecordType.Id;
        account.FirstName = 'XXX';
        account.LastName = 'YYY';
        account.Phone = '9876543210';
        account.PersonEmail = 'xxx007@ymail.com';
        insert account;

        Order__c order = new Order__c();
        order.Account__c = account.Id;
        order.Billing_Email__c = 'test@gmail.com';
        order.Billing_First_Name__c = 'test';
        order.Billing_Last_Name__c = 'dx';
        order.Billing_Phone__c = '9876543210';
        order.Billing_Address__c = '123 main Street';
        order.Billing_City__c =  'New York';
        order.Billing_State__c = 'LA';
        order.Billing_Country__c = 'United States';
        order.Billing_Zip_Postal__c = '10035';
        order.Shipping_Address__c = '123 main Street';
        order.Shipping_City__c = 'New York';
        order.Shipping_State__c = 'LA';
        order.Shipping_Country__c = 'United States';
        order.Shipping_Zip_Postal__c = '10035';
        order.Subtotal__c = 10;
        order.Shipping__c = 2;
        order.Tax__c= 2;
        order.Currency__c = 'US Dollar';
        order.Payment_Method__c = 'Credit Card';
        insert order;
        String orderId = order.Id;
        Decimal price = 30.00;  Decimal shipping = 20.55;  Decimal tax = 12.22;

        Product2 product = new Product2();
        product.Name = 'test';
        product.ProductCode = 'DSX';
        product.IsActive = true;
        insert product;

        String strResponse = RestUpsellController.processUpsell(orderId,30.00,20.55,12.22, product.Id, 1);
        Order__c odr = [SELECT Id FROM Order__c WHERE Id =:strResponse];
        System.assertEquals(odr.Id,strResponse);
    }

    static testMethod void testsetOrderItem(){
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        Account account = new Account();
        account.RecordTypeId = customerRecordType.Id;
        account.FirstName = 'test';
        account.LastName = 'test';
        account.Phone = '6547892456';
        account.PersonEmail = 'test@gmail.com';
        insert account;

        Order__c cOrder = new Order__c();
        cOrder.Account__c = account.Id;
        cOrder.Billing_Address__c = 'test';
        insert cOrder;

        Product2 product = new Product2();
        product.Name = 'test';
        product.ProductCode = 'DSX';
        product.IsActive = true;
        insert product;

        RestUpsellController.setOrderItem(cOrder.Id,product.Id, 20, 1);
        System.assert(true);
    }
}