@isTest
private class SubscriptionOrderBatchTest {

    @isTest static void AllVariantsSubscription() {
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        Account testAcc = new Account(
            RecordTypeId = customerRecordType.Id,
            FirstName = 'Test FName', LastName = 'Test LName',
            PersonEmail = 'test@example.com'
        );
        insert testAcc;

        List<Subscription__c> subscriptions = new List<Subscription__c>{
            new Subscription__c(
                Account__c = testAcc.Id,
                Active__c = true,
                Charge_Amount__c = 1,
                Frequency__c = 'Daily',
                Start_Date__c = Date.today().addDays(1),
                Stop_On__c = 'Never',
                Stop_Date__c = Date.today().addDays(1)
            ),
            new Subscription__c(
                Account__c = testAcc.Id,
                Active__c = true,
                Charge_Amount__c = 2,
                Frequency__c = 'Weekly',
                Start_Date__c = Date.today().addDays(1),
                Stop_On__c = 'First',
                Stop_Date__c = Date.today().addDays(1)
            ),
            new Subscription__c(
                Account__c = testAcc.Id,
                Count__c = 2, 
                Active__c = true,
                Charge_Amount__c = 3,
                Frequency__c = 'Monthly',
                Start_Date__c = Date.today().addDays(1),
                Stop_On__c = 'Count',
                Stop_Date__c = Date.today().addDays(1)
            ),
            new Subscription__c(
                Account__c = testAcc.Id,
                Active__c = true,
                Charge_Amount__c = 4,
                Frequency__c = 'Quarterly',
                Start_Date__c = Date.today().addDays(1),
                Stop_On__c = 'Date',
                Stop_Date__c = Date.today().addDays(1)
            ),
            new Subscription__c(
                Account__c = testAcc.Id,
                Active__c = true,
                Charge_Amount__c = 5,
                Frequency__c = 'Annual',
                Start_Date__c = Date.today().addDays(1),
                Stop_On__c = 'Full Payment',
                Stop_Date__c = Date.today().addDays(1)
            )
        };
        insert subscriptions;

        List<Order__c> orders = new List<Order__c>{
            new Order__c(
                Account__c = testAcc.Id,
                Subtotal__c = 100,
                Status__c = 'Initiated',
                Subscription_To__c = subscriptions[0].Id
            ),
            new Order__c(
                Account__c = testAcc.Id,
                Subtotal__c = 100,
                Status__c = 'Initiated',
                Subscription_To__c = subscriptions[1].Id
            ),
            new Order__c(
                Account__c = testAcc.Id,
                Subtotal__c = 100,
                Status__c = 'Initiated',
                Subscription_To__c = subscriptions[2].Id
            ),
            new Order__c(
                Account__c = testAcc.Id,
                Subtotal__c = 100,
                Status__c = 'Initiated',
                Subscription_To__c = subscriptions[3].Id
            ),
            new Order__c(
                Account__c = testAcc.Id,
                Subtotal__c = 100,
                Status__c = 'Initiated',
                Subscription_To__c = subscriptions[4].Id
            )
        };
        insert orders;

        Test.startTest();
            SubscriptionOrderBatch b = new SubscriptionOrderBatch();
            database.executebatch(b, 200);
        Test.stopTest();

        List<Payment_Attempt__c> resultPaymentAttempts = [
            SELECT Id, Amount__c, Date__c, Order__c, Remaining_Retries__c, Status__c
            FROM Payment_Attempt__c
        ];
        System.assertEquals(5, resultPaymentAttempts.size());

        List<Order_Transaction__c> resultTransactions = [
            SELECT Id, Name, Order__c, Payment_Attempt__c
            FROM Order_Transaction__c
        ];
        System.assertEquals(0, resultTransactions.size());
    }

    @isTest static void BulkSubscription() {
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        Account testAcc = new Account(
            RecordTypeId = customerRecordType.Id,
            FirstName = 'Test FName', LastName = 'Test LName',
            PersonEmail = 'test@example.com'
        );
        insert testAcc;

        List<Subscription__c> subscriptions = new List<Subscription__c>();
        for (Integer i = 0; i < 200; i++) {
            subscriptions.add(new Subscription__c(
                Account__c = testAcc.Id,
                Active__c = true,
                Charge_Amount__c = 1,
                Frequency__c = 'Daily',
                Start_Date__c = Date.today().addDays(1),
                Stop_On__c = 'Never',
                Stop_Date__c = Date.today().addDays(1)
            ));
        }
        insert subscriptions;

        List<Order__c> orders = new List<Order__c>();
        for (Integer i = 0; i < 200; i++) {
            orders.add(new Order__c(
                Account__c = testAcc.Id,
                Subtotal__c = 100,
                Status__c = 'Initiated',
                Subscription_To__c = subscriptions[i].Id
            ));
        }
        insert orders;

        Test.startTest();
            SubscriptionOrderBatch b = new SubscriptionOrderBatch();
            database.executebatch(b, 200);
        Test.stopTest();

        List<Payment_Attempt__c> resultPaymentAttempts = [
            SELECT Id, Amount__c, Date__c, Order__c, Remaining_Retries__c
            FROM Payment_Attempt__c
        ];
        System.assertEquals(200, resultPaymentAttempts.size());

        List<Order_Transaction__c> resultTransactions = [
            SELECT Id, Name, Order__c, Payment_Attempt__c
            FROM Order_Transaction__c
        ];
        System.assertEquals(0, resultTransactions.size());
    }

    @isTest static void SubscriptionOrder() {
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        Account testAcc = new Account(
            RecordTypeId = customerRecordType.Id,
            FirstName = 'Test FName', LastName = 'Test LName',
            PersonEmail = 'test@example.com'
        );
        insert testAcc;

        Subscription__c subscription = new Subscription__c(
            Account__c = testAcc.Id,
            Active__c = true,
            Charge_Amount__c = 1,
            Frequency__c = 'Daily',
            Start_Date__c = Date.today(),
            Stop_On__c = 'Never',
            Stop_Date__c = Date.today().addDays(1)            
        );
        insert subscription;

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
            Currency__c = 'US Dollar', Payment_Method__c = 'Credit Card',
            Status__c = 'Initiated', Subscription_To__c = subscription.Id
        );
        insert order;

        Order_Transaction__c transection = new Order_Transaction__c(
            Order__c = order.Id, Type__c = 'Charge',
            Response_Status__c = 'Status', Response_Message__c = 'Message',
            Payment_Response_Body__c = 'original', Payment_Profile__c = 'cus_7cBFHD6iiBaTUU',
            Named_Agent__c = 'Test Agent Name', Card_Last_4__c = '4242',
            Payment_Entity_Id__c = 'ch_19dfhSCF2TV51fDnaXu3lB1J', Payment_Date__c = Datetime.now().addDays(-1),
            Payment_Method__c = 'Credit Card', Currency__c = 'US Dollars',
            Amount__c = 11
        );
        insert transection;

        Test.startTest();
            SubscriptionOrderBatch b = new SubscriptionOrderBatch();
            database.executebatch(b, 200);
        Test.stopTest();

        List<Payment_Attempt__c> resultPaymentAttempts = [
            SELECT Id, Amount__c, Date__c, Order__c, Status__c
            FROM Payment_Attempt__c
        ];
        System.assertEquals(2, resultPaymentAttempts.size());
        System.assertEquals(1, resultPaymentAttempts[0].Amount__c);
        System.assertEquals(Date.today(), resultPaymentAttempts[0].Date__c);
        System.assertEquals(order.Id, resultPaymentAttempts[0].Order__c);

        List<Order_Transaction__c> resultTransactions = [
            SELECT Id, Name, Order__c, Payment_Attempt__c
            FROM Order_Transaction__c
        ];
        System.assertEquals(2, resultTransactions.size());
        System.assertEquals(order.Id, resultTransactions[0].Order__c);
        System.assertEquals(resultPaymentAttempts[0].Id, resultTransactions[1].Payment_Attempt__c);
    }

    @isTest static void OldPaymentAttempts() {
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        Account testAcc = new Account(
            RecordTypeId = customerRecordType.Id,
            FirstName = 'Test FName', LastName = 'Test LName',
            PersonEmail = 'test@example.com'
        );
        insert testAcc;

        Subscription__c subscription = new Subscription__c(
            Account__c = testAcc.Id,
            Active__c = true,
            Charge_Amount__c = 1,
            Frequency__c = 'Daily',
            Start_Date__c = Date.today(),
            Stop_On__c = 'Never',
            Stop_Date__c = Date.today().addDays(1)            
        );
        insert subscription;

        Order__c order = new Order__c(
            Account__c = testAcc.Id,
            Subtotal__c = 10,
            Tax__c = 2,
            Named_Agent__c = 'Test Agent Name',
            Currency__c = 'US Dollar',
            Payment_Method__c = 'Credit Card',
            Status__c = 'Initiated',
            Subscription_To__c = subscription.Id
        );
        insert order;

        Order_Transaction__c transection = new Order_Transaction__c(
            Order__c = order.Id, Type__c = 'Charge',
            Response_Status__c = 'Status', Response_Message__c = 'Message',
            Payment_Response_Body__c = 'original', Payment_Profile__c = 'cus_7cBFHD6iiBaTUU',
            Named_Agent__c = 'Test Agent Name', Card_Last_4__c = '4242',
            Payment_Entity_Id__c = 'ch_19dfhSCF2TV51fDnaXu3lB1J', Payment_Date__c = Datetime.now().addDays(-1),
            Payment_Method__c = 'Credit Card', Currency__c = 'US Dollars',
            Amount__c = 11
        );
        insert transection;

        Payment_Attempt__c oldPaymentAttempt = new Payment_Attempt__c(
            Amount__c = 1,
            Date__c = Date.today(),
            Order__c = order.Id,
            Status__c = 'Scheduled',
            Remaining_Retries__c = 3,
            Subscription__c = subscription.Id
        );
        insert oldPaymentAttempt;

        Test.startTest();
            SubscriptionOrderBatch b = new SubscriptionOrderBatch();
            database.executebatch(b, 200);
        Test.stopTest();

        List<Payment_Attempt__c> resultPaymentAttempts = [
            SELECT Id, Amount__c, Date__c, Order__c, Status__c
            FROM Payment_Attempt__c
        ];
        System.assertEquals(2, resultPaymentAttempts.size());

        List<Order_Transaction__c> resultTransactions = [
            SELECT Id, Name, Order__c, Payment_Attempt__c
            FROM Order_Transaction__c
            WHERE Payment_Attempt__c =: oldPaymentAttempt.Id
        ];
        System.assertEquals(1, resultTransactions.size());
    }
}