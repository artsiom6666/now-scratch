@isTest
private class ScoreBrandCalculationBatchTest {

    @isTest static void test_batch_LOD_Step_1_Brand() {
        List<String> brandTest = new List<String> {'brand1'};
        TouchCRConfigurationController.setActiveBrandsTest(new Set<String>(brandTest));

		Integer numRepeats = 5;
        List<Account> testObjList = new List<Account>();
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];

        for (Integer idx = 1; idx <= numRepeats; idx++) {
            Account testObj = new Account();
            testObj.put('RecordTypeId', customerRecordType.Id);
            testObj.put('FirstName', 'John' + idx);
            testObj.put('LastName', 'Doe' + idx);
            testObj.put('PersonEmail', 'john_' + idx + '@example.com');

            testObj.put('Brand_Assortment__c', brandTest[0]);

            testObj.put('Number_Of_Zero_Balance_Orders__c', idx);
            testObj.put('Subtotal_From_Zero_Balance_Orders__c', idx);
            //score measurement
            testObj.put('Recency_Score_Brand__c', 0);
            //order measurement
            testObj.put('Last_order_date__c', Date.today().addDays(-idx*2));

            testObjList.add(testObj);
        }
        insert testObjList;
		List<Order__c> orders = new List<Order__c>();
		for (Account acc : testObjList) {
			orders.add(new Order__c(Account__c = acc.Id));
		}
		insert orders;

        Test.startTest();
            ScoreBrandCounterBatch b = new ScoreBrandCounterBatch(new Set<String>());
		Id batchInstanceId = Database.executebatch(b, 5);
        Test.stopTest();

        List<Account> testRScore = [SELECT Recency_Score_Brand__c FROM Account WHERE IsPersonAccount = true ORDER BY Last_order_date__c DESC NULLS LAST LIMIT 200];

        //total 200 accs, 40 in each chunk
        //0-39      Recency_Score_Brand__c = 5
        //40-79     Recency_Score_Brand__c = 4
        //80-119    Recency_Score_Brand__c = 3
        //120-159   Recency_Score_Brand__c = 2
        //160-199   Recency_Score_Brand__c = 1
		for (Integer idx = 0; idx < 1; idx++) {
            System.assertEquals(5,testRScore.get(idx).Recency_Score_Brand__c);
        }
		for (Integer idx = 1; idx < 2; idx++) {
            System.assertEquals(4,testRScore.get(idx).Recency_Score_Brand__c);
        }
		for (Integer idx = 2; idx < 3; idx++) {
            System.assertEquals(3,testRScore.get(idx).Recency_Score_Brand__c);
        }
		for (Integer idx = 3; idx < 4; idx++) {
            System.assertEquals(2,testRScore.get(idx).Recency_Score_Brand__c);
        }
		for (Integer idx = 4; idx < 5; idx++) {
            System.assertEquals(1,testRScore.get(idx).Recency_Score_Brand__c);
        }
    }

    @isTest static void test_batch_NZBO_Step_2_Brand() {
        List<String> brandTest = new List<String> {'brand1'};
        TouchCRConfigurationController.setActiveBrandsTest(new Set<String>(brandTest));

		Integer numRepeats = 5;
        List<Account> testObjList = new List<Account>();
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];

        for (Integer idx = 1; idx <= numRepeats; idx++) {
            Account testObj = new Account();
            testObj.put('RecordTypeId', customerRecordType.Id);
            testObj.put('FirstName', 'John' + idx);
            testObj.put('LastName', 'Doe' + idx);
            testObj.put('PersonEmail', 'john_' + idx + '@example.com');

            testObj.put('Brand_Assortment__c', brandTest[0]);

            testObj.put('Last_order_date__c', Date.today().addDays(+idx));
            testObj.put('Subtotal_From_Zero_Balance_Orders__c', idx);
            //score measurement
            testObj.put('Frequency_Score_Brand__c', 0);
            //order measurement
            testObj.put('Number_Of_Zero_Balance_Orders__c', idx);
            testObjList.add(testObj);
        }
        insert testObjList;
		List<Order__c> orders = new List<Order__c>();
		for (Account acc : testObjList) {
			orders.add(new Order__c(Account__c = acc.Id));
		}
		insert orders;
		Integer idInteger = 1;
		for (Account acc : testObjList) {
			acc.put('Number_Of_Zero_Balance_Orders__c', idInteger);
			idInteger++;
		}
		update testObjList;
        Test.startTest();
            ScoreBrandCounterBatch b = new ScoreBrandCounterBatch(new Set<String>());
		Id batchInstanceId = Database.executebatch(b, 5);
        Test.stopTest();
        List<Account> testFScore = [SELECT Frequency_Score_Brand__c FROM Account WHERE IsPersonAccount = true ORDER BY Number_Of_Zero_Balance_Orders__c DESC NULLS LAST LIMIT 200];

        //total 200 accs, 40 in each chunk
        //0-39      Frequency_Score_Brand__c = 5
        //40-79     Frequency_Score_Brand__c = 4
        //80-119    Frequency_Score_Brand__c = 3
        //120-159   Frequency_Score_Brand__c = 2
        //160-199   Frequency_Score_Brand__c = 1
		for (Integer idx = 0; idx < 1; idx++) {
            System.assertEquals(5,testFScore.get(idx).Frequency_Score_Brand__c);
        }
		for (Integer idx = 1; idx < 2; idx++) {
            System.assertEquals(4,testFScore.get(idx).Frequency_Score_Brand__c);
        }
		for (Integer idx = 2; idx < 3; idx++) {
            System.assertEquals(3,testFScore.get(idx).Frequency_Score_Brand__c);
        }
		for (Integer idx = 3; idx < 4; idx++) {
            System.assertEquals(2,testFScore.get(idx).Frequency_Score_Brand__c);
        }
		for (Integer idx = 4; idx < 5; idx++) {
            System.assertEquals(1,testFScore.get(idx).Frequency_Score_Brand__c);
        }
    }

    @isTest static void test_batch_SZBO_Step_3_Brand() {

        List<String> brandTest = new List<String> {'brand1'};
        TouchCRConfigurationController.setActiveBrandsTest(new Set<String>(brandTest));

		Integer numRepeats = 5;
        List<Account> testObjList = new List<Account>();
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        for (Integer idx = 1; idx <= numRepeats; idx++) {
            Account testObj = new Account();
            testObj.put('RecordTypeId', customerRecordType.Id);
            testObj.put('FirstName', 'John' + idx);
            testObj.put('LastName', 'Doe' + idx);
            testObj.put('PersonEmail', 'john_' + idx + '@example.com');

            testObj.put('Brand_Assortment__c', brandTest[0]);

            testObj.put('Last_order_date__c', Date.today().addDays(+idx));
            testObj.put('Number_Of_Zero_Balance_Orders__c', idx);
            //score measurement
            testObj.put('Monetary_Score_Brand__c', 0);
            //order measurement
            testObj.put('Subtotal_From_Zero_Balance_Orders__c', idx);
            testObjList.add(testObj);
        }
        insert testObjList;
		List<Order__c> orders = new List<Order__c>();
		for (Account acc : testObjList) {
			orders.add(new Order__c(Account__c = acc.Id));
		}
		insert orders;
		Integer idInteger = 1;
		for (Account acc : testObjList) {
			acc.put('Subtotal_From_Zero_Balance_Orders__c', idInteger);
			idInteger++;
		}
		update testObjList;

        Test.startTest();
            ScoreBrandCounterBatch b = new ScoreBrandCounterBatch(new Set<String>());
		Id batchInstanceId = Database.executebatch(b, 5);
        Test.stopTest();

        List<Account> testMscore = [SELECT Monetary_Score_Brand__c FROM Account WHERE IsPersonAccount = true ORDER BY Subtotal_From_Zero_Balance_Orders__c DESC NULLS LAST LIMIT 200];

        //total 200 accs, 40 in each chunk
        //0-39      Monetary_Score_Brand__c = 5
        //40-79     Monetary_Score_Brand__c = 4
        //80-119    Monetary_Score_Brand__c = 3
        //120-159   Monetary_Score_Brand__c = 2
        //160-199   Monetary_Score_Brand__c = 1
		for (Integer idx = 0; idx < 1; idx++) {
            System.assertEquals(5,testMscore.get(idx).Monetary_Score_Brand__c);
        }
		for (Integer idx = 1; idx < 2; idx++) {
            System.assertEquals(4,testMscore.get(idx).Monetary_Score_Brand__c);
        }
		for (Integer idx = 2; idx < 3; idx++) {
            System.assertEquals(3,testMscore.get(idx).Monetary_Score_Brand__c);
        }
		for (Integer idx = 3; idx < 4; idx++) {
            System.assertEquals(2,testMscore.get(idx).Monetary_Score_Brand__c);
        }
		for (Integer idx = 4; idx < 5; idx++) {
            System.assertEquals(1,testMscore.get(idx).Monetary_Score_Brand__c);
        }
    }

}