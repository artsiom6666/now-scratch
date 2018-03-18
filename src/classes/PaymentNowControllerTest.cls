@isTest
private class PaymentNowControllerTest {

    @isTest
    static void paymentTest() {
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        Account testAcc = new Account(
            RecordTypeId = customerRecordType.Id,
            FirstName = 'Test FName', LastName = 'Test LName',
            PersonEmail = 'test@example.com'
        );
        insert testAcc;

        Order__c order = new Order__c(
            Account__c = testAcc.Id, Subtotal__c = 100, Named_Agent__c = 'Test Agent Name',
            Subscription__c = true, Subscription_Charge_Amount__c = 1,
            Subscription_Frequency__c = 'Daily', Subscription_Start_Date__c = Date.today(),
            Subscription_Stop_On__c = 'Never', Status__c = 'Initiated',
            Subscription_Stop_Date__c = Date.today().addDays(5)
        );
        insert order;

        Order_Transaction__c transection = new Order_Transaction__c(
            Order__c = order.Id, Type__c = 'Charge',
            Response_Status__c = 'Approved', Response_Message__c = 'Message',
            Payment_Response_Body__c = 'original', Payment_Profile__c = 'cus_7cBFHD6iiBaTUU',
            Named_Agent__c = 'Test Agent Name', Card_Last_4__c = '4242',
            Payment_Entity_Id__c = 'ch_19dfhSCF2TV51fDnaXu3lB1J', Payment_Date__c = Datetime.now().addDays(-1),
            Payment_Method__c = 'Credit Card', Currency__c = 'US Dollars',
            Amount__c = 11
        );
        insert transection;

        Payment_Attempt__c paymentAttempt = new Payment_Attempt__c(
            Order__c = order.Id, Date__c = Date.today(),
            Remaining_Retries__c = 3, Amount__c = 1
        );
        insert paymentAttempt;

        ApexPages.StandardController sc = new ApexPages.standardController(paymentAttempt);

        Test.startTest();
            PaymentNowController pnc = new PaymentNowController(sc);
            pnc.payNow();
        Test.stopTest();

        List<Order_Transaction__c> resultTransactions = [
            SELECT Id, Response_Status__c, Payment_Attempt__c
            FROM Order_Transaction__c
            WHERE Payment_Attempt__c =: paymentAttempt.Id
        ];
        System.assertEquals(1, resultTransactions.size());
        System.assertEquals('Approved', resultTransactions[0].Response_Status__c);
    }

    @isTest
    static void paymentNotTest() {
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        Account testAcc = new Account(
            RecordTypeId = customerRecordType.Id,
            FirstName = 'Test FName', LastName = 'Test LName',
            PersonEmail = 'test@example.com'
        );
        insert testAcc;

        Order__c order = new Order__c(
            Account__c = testAcc.Id, Subtotal__c = 100, Named_Agent__c = 'Test Agent Name',
            Subscription__c = true, Subscription_Charge_Amount__c = 1,
            Subscription_Frequency__c = 'Daily', Subscription_Start_Date__c = Date.today(),
            Subscription_Stop_On__c = 'Never', Status__c = 'Initiated',
            Subscription_Stop_Date__c = Date.today().addDays(5)
        );
        insert order;

        Payment_Attempt__c paymentAttempt = new Payment_Attempt__c(
            Order__c = order.Id, Date__c = Date.today(), Status__c = 'Completed',
            Remaining_Retries__c = 3, Amount__c = 1
        );
        insert paymentAttempt;

        Order_Transaction__c transection = new Order_Transaction__c(
            Order__c = order.Id, Type__c = 'Charge', Payment_Attempt__c = paymentAttempt.Id,
            Response_Status__c = 'Approved', Response_Message__c = 'Message',
            Payment_Response_Body__c = 'original', Payment_Profile__c = 'cus_7cBFHD6iiBaTUU',
            Named_Agent__c = 'Test Agent Name', Card_Last_4__c = '4242',
            Payment_Entity_Id__c = 'ch_19dfhSCF2TV51fDnaXu3lB1J', Payment_Date__c = Datetime.now().addDays(-1),
            Payment_Method__c = 'Credit Card', Currency__c = 'US Dollars',
            Amount__c = 11
        );
        insert transection;

        ApexPages.StandardController sc = new ApexPages.standardController(paymentAttempt);

        Test.startTest();
            PaymentNowController pnc = new PaymentNowController(sc);
            pnc.payNow();
        Test.stopTest();

        List<Order_Transaction__c> resultTransactions = [
            SELECT Id, Response_Status__c, Payment_Attempt__c
            FROM Order_Transaction__c
            WHERE Payment_Attempt__c =: paymentAttempt.Id
        ];

        System.assertEquals(1, resultTransactions.size());
    }
}