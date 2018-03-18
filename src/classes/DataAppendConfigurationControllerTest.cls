@isTest
private class DataAppendConfigurationControllerTest{

    @isTest static void test_account() {
        Account acc = new Account (Name = 'Test Account');
        insert acc;

        Test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(acc);
            DataAppendConfigurationController processController = new DataAppendConfigurationController(controller);
            processController.startDataAppend();

            System.assert(processController.result.contains('true'));
        Test.stopTest();

    }


    @isTest static void test_Lead() {
        Lead testObj = new Lead(LastName = 'Doe');
        insert testObj;

        Test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(testObj);
            DataAppendConfigurationController processController = new DataAppendConfigurationController(controller);
            processController.startDataAppend();

            System.assert(processController.result.contains('true'));
        Test.stopTest();
    }

}