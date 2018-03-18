@isTest
private class CaseUpdateTriggerTest{

    static testMethod void CaseTest(){

        RecordType PersonAccount = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Customer_Account' LIMIT 1];
        RecordType BusinessAccount = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Business_Account' LIMIT 1];

        Account accountBusiness = new Account(Name = 'accountBusiness', Average_Order_Value__c = 0, RecordTypeId = BusinessAccount.Id);
        insert accountBusiness;

        Account accountPerson = new Account(FirstName = 'Test FName', LastName = 'Test LName', Average_Order_Value__c = 0, RecordTypeId = PersonAccount.Id, PersonEmail = 'test@yahoo.com');
        insert accountPerson;

        Order__c chargentItem1 = new Order__c(Billing_First_Name__c = 'TestF2', Billing_Last_Name__c = 'TestLastName2',
        Billing_Email__c = 'test2@gmail.com', Billing_City__c = 'Chicago', Account__c = accountBusiness.Id);
        insert chargentItem1;

        Order__c chargentItem2 = new Order__c(Billing_First_Name__c = 'TestF2', Billing_Last_Name__c = 'TestLastName2',
        Billing_Email__c = 'test2@gmail.com', Billing_City__c = 'Chicago', Account__c = accountPerson.Id);
        insert chargentItem2;

        Case cs1 = new Case(Type = 'Autoship', Status = 'New', Origin = 'Email', Reason_Case__c = 'Cancel of Autoship');
        Case cs2 = new Case(Order__c = chargentItem1.Id, Type = 'Shipment ', Status = 'New', Origin = 'Email', Reason_Case__c = 'Request Reshipment');
        Case cs3 = new Case(Order__c = chargentItem2.Id, Type = 'Shipment ', Status = 'New', Origin = 'Email', Reason_Case__c = 'Request Reshipment');

        Test.startTest();
            insert cs1;
            insert cs2;
            insert cs3;
        Test.stopTest();

        Case caseItem1 = [SELECT Id, AccountId, ContactId, Order__c FROM Case WHERE Id =: cs1.Id];
        System.assertEquals(NULL, caseItem1.AccountId);
        System.assertEquals(NULL, caseItem1.ContactId);
        System.assertEquals(NULL, caseItem1.Order__c);

        Case caseItem2 = [SELECT Id, AccountId, ContactId, Order__c FROM Case WHERE Id =: cs2.Id];
        System.assertEquals(NULL, caseItem2.ContactId);
        System.assertEquals(NULL, caseItem2.ContactId);
        System.assertEquals(chargentItem1.Id, caseItem2.Order__c);

        Case caseItem3 = [SELECT Id, AccountId, Contact.Email, Order__c FROM Case WHERE Id =: cs3.Id];
        System.assertEquals(accountPerson.Id, caseItem3.AccountId);
        System.assertEquals('test@yahoo.com', caseItem3.Contact.Email);
        System.assertEquals(chargentItem2.Id, caseItem3.Order__c);
    }

    static testMethod void ListInsertDifferentCaseTest() {

        RecordType PersonAccount = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Customer_Account' LIMIT 1];
        Account account = new Account(FirstName = 'Test FName', LastName = 'Test LName', Average_Order_Value__c = 0, RecordTypeId = PersonAccount.Id, PersonEmail = 'test@yahoo.com');
        insert account;

        Order__c chargentItem = new Order__c(Billing_First_Name__c = 'TestF2', Billing_Last_Name__c = 'TestLastName2',
        Billing_Email__c = 'test2@gmail.com', Billing_City__c = 'Chicago', Account__c = account.Id);
        insert chargentItem;

        List<Case> caseList = new List<Case>();

        Case cs1 = new Case(AccountId = account.Id, Order__c = chargentItem.Id, Type = 'Shipment', Status = 'New', Origin = 'Email', Reason_Case__c = 'Request Reshipment');
        caseList.add(cs1);

        Case cs2 = new Case(AccountId = account.Id, Order__c = chargentItem.Id, Type = 'Shipment', Status = 'New', Origin = 'Email', Reason_Case__c = 'Request Reshipment');
        caseList.add(cs2);

        Case cs3 = new Case(AccountId = account.Id, Order__c = chargentItem.Id, Type = 'Shipment', Status = 'New', Origin = 'Phone', Reason_Case__c = 'Hold Shipment: Incorrect Order');
        caseList.add(cs3);

        Case cs4 = new Case(AccountId = account.Id, Order__c = chargentItem.Id, Type = 'Shipment', Status = 'New', Origin = 'Email', Reason_Case__c = 'Not Shipping');
        caseList.add(cs4);

        Case cs5 = new Case(AccountId = account.Id, Order__c = chargentItem.Id, Type = 'Shipment', Status = 'New', Origin = 'Email', Reason_Case__c = 'Not Shipping');
        caseList.add(cs5);

        /*      Cases with no Order     */
        Case cs6 = new Case(Type = 'Shipment', Status = 'New', Origin = 'Email', Reason_Case__c = 'Not Shipping');
        caseList.add(cs6);

        Test.startTest();
            insert caseList;
        Test.stopTest();

        Map<Id, Decimal> mapCase = new Map<Id, Decimal>();
        for (Case cs : [SELECT Id, Case_Sequence__c FROM Case]) {
            mapCase.put(cs.Id, cs.Case_Sequence__c);
        }

        System.assertEquals(2, mapCase.get(caseList[0].Id));
        System.assertEquals(1, mapCase.get(caseList[1].Id));

        System.assertEquals(1, mapCase.get(caseList[2].Id));

        System.assertEquals(2, mapCase.get(caseList[3].Id));
        System.assertEquals(1, mapCase.get(caseList[4].Id));

        /*  Test Cases with no Order    */
        System.assertEquals(NULL, mapCase.get(caseList[5].Id));
    }

    static testMethod void ListInsertSimilarCaseTest() {

        RecordType BusinessAccount = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Business_Account' LIMIT 1];

        Account account = new Account(Name = 'AccountTest', Average_Order_Value__c = 0, RecordTypeId = BusinessAccount.Id);
        insert account;

        Order__c chargentItem = new Order__c(Billing_First_Name__c = 'TestF2', Billing_Last_Name__c = 'TestLastName2',
        Billing_Email__c = 'test2@gmail.com', Billing_City__c = 'Chicago', Account__c = account.Id);
        insert chargentItem;

        /*      */
        Case cs6 = new Case(AccountId = account.Id, Order__c = chargentItem.Id, Type = 'Inventory', Status = 'New', Origin = 'Email', Reason_Case__c = 'Back Order');
        insert cs6;

        List<Case> caseList = new List<Case>();

        Case cs1 = new Case(AccountId = account.Id, Order__c = chargentItem.Id, Type = 'Shipment', Status = 'New', Origin = 'Email', Reason_Case__c = 'Request Reshipment');
        caseList.add(cs1);

        Case cs2 = new Case(AccountId = account.Id, Order__c = chargentItem.Id, Type = 'Shipment', Status = 'New', Origin = 'Email', Reason_Case__c = 'Request Reshipment');
        caseList.add(cs2);

        Case cs3 = new Case(AccountId = account.Id, Order__c = chargentItem.Id, Type = 'Shipment', Status = 'New', Origin = 'Phone', Reason_Case__c = 'Request Reshipment');
        caseList.add(cs3);

        Case cs4 = new Case(AccountId = account.Id, Order__c = chargentItem.Id, Type = 'Shipment', Status = 'New', Origin = 'Email', Reason_Case__c = 'Request Reshipment');
        caseList.add(cs4);


        Test.startTest();
            insert caseList;
        Test.stopTest();

        Map<Id, Decimal> mapCase = new Map<Id, Decimal>();
        for (Case cs : [SELECT Id, Case_Sequence__c FROM Case]) {
            mapCase.put(cs.Id, cs.Case_Sequence__c);
        }

        System.assertEquals(4, mapCase.get(caseList[0].Id));
        System.assertEquals(3, mapCase.get(caseList[1].Id));
        System.assertEquals(2, mapCase.get(caseList[2].Id));
        System.assertEquals(1, mapCase.get(caseList[3].Id));
    }

    static testMethod void OneCase(){

        RecordType PersonAccount = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Customer_Account' LIMIT 1];
        Account account = new Account(FirstName = 'Test FName', LastName = 'Test LName', Average_Order_Value__c = 0, RecordTypeId = PersonAccount.Id, PersonEmail = 'test@yahoo.com');
        insert account;

        Order__c chargentItem = new Order__c(Billing_First_Name__c = 'TestF2', Billing_Last_Name__c = 'TestLastName2',
        Billing_Email__c = 'test2@gmail.com', Billing_City__c = 'Chicago', Account__c = account.Id);
        insert chargentItem;

        Case cs1 = new Case(
            Order__c = chargentItem.Id,
            Type = 'Autoship',
            Status = 'New',
            Origin = 'Email',
            Reason_Case__c = 'Cancel of Autoship'
        );

        Test.startTest();
            insert cs1;
        Test.stopTest();

        Case caseItem1 = [SELECT Id, Case_Sequence__c FROM Case WHERE Id =: cs1.Id];
        System.assertEquals(1, caseItem1.Case_Sequence__c);
    }

}