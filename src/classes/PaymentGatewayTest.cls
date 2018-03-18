@isTest
public class PaymentGatewayTest {

    static testMethod void paymentGatewayCorrectRequest() {

        Test.setMock(HttpCalloutMock.class, new RestPaymentMockResponse());

        insert new List<TouchCR_Settings__c>{
            new TouchCR_Settings__c(Name = 'Endpoint.ClientId', Value__c = 'ClientId'),
            new TouchCR_Settings__c(Name = 'Endpoint.ClientSecret', Value__c = 'ClientSecret'),
            new TouchCR_Settings__c(Name = 'Endpoint.TokenPart1', Value__c = 'TokenPart1'),
            new TouchCR_Settings__c(Name = 'Endpoint.TokenPart2', Value__c = 'TokenPart2'),
            new TouchCR_Settings__c(Name = 'Endpoint.TokenType', Value__c = 'TokenType')
        };

        Payment_Agents__c newPaymentAgents = new Payment_Agents__c(
            Name = 'Test Agent Name', Security_Key__c = 'test',
            Active__c = true, Type__c = 'Stripe', Merchant_ID__c = 'test'
        );
        insert newPaymentAgents;

        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        Account testAcc = new Account(
            RecordTypeId = customerRecordType.Id,
            FirstName = 'FirstName', LastName = 'LastName',
            Phone = '9876543210', PersonEmail = 'testUsr@mail.ru'
        );
        insert testAcc;

        Order__c order = new Order__c(
            Account__c = testAcc.Id, Billing_Email__c = 'test@gmail.com',
            Billing_First_Name__c = 'test', Billing_Last_Name__c = 'dx',
            Billing_Phone__c = '9876543210', Billing_Address__c = '123 main Street',
            Billing_City__c =  'New York', Billing_State__c = 'LA',
            Billing_Country__c = 'United States', Billing_Zip_Postal__c = '10035',
            Shipping_Address__c = '123 main Street', Shipping_City__c = 'New York',
            Shipping_State__c = 'LA', Shipping_Country__c = 'United States',
            Shipping_Zip_Postal__c = '10035',
            Subtotal__c = 10, Shipping__c = 2, Tax__c= 2, Named_Agent__c = 'Test Agent Name',
            Currency__c = 'US Dollar', Payment_Method__c = 'Credit Card'
        );
        insert order;

        Test.startTest();
        Map<String, Object> result = PaymentGateway.doPayment(
            new Map<String,Object>{
                'Method' => 'Charge',
                'PaymentAgent' => order.Named_Agent__c,
                'Amount' => 1,
                'CreditCard' => new Map<String, Object>{
                    'CardNumber' => '4242424242424242',
                    'CardExpirationMonth' => '01',
                    'CardExpirationYear' => '01',
                    'CardCCV' => '123'
                }
            }
        );
        Test.stopTest();

        System.assertEquals('Approved', result.get('Status'));
    }
}