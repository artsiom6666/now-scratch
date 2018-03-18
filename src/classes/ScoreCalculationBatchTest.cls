@isTest
private class ScoreCalculationBatchTest {

	@isTest static void test_batch_LOD_Step_1() {

		List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Integer numRepeats = 5;
		Integer sections = 5;
		List<Account> accs = new List<Account>();
		for (Integer idx = 1; idx <= numRepeats; idx++) {
			Account acc = new Account();
			acc.put('RecordTypeId', rtList[0].Id);
			acc.put('FirstName', 'John' + idx);
			acc.put('LastName', 'Doe' + idx);
			acc.put('PersonEmail', 'john_' + idx + '@example.com');
			acc.put('Number_Of_Zero_Balance_Orders__c', idx);
			acc.put('Subtotal_From_Zero_Balance_Orders__c', idx);
			//score measurement
			acc.put('Recency_Score__c', 0);
			//order measurement
			acc.put('Last_order_date__c', Date.today().addDays(-idx * 2));
			accs.add(acc);
		}
		insert accs;
		List<Order__c> orders = new List<Order__c>();
		for (Account acc : accs) {
			orders.add(new Order__c(Account__c = acc.Id));
		}
		insert orders;
		Test.startTest();
		ScoreCalculationBatch job = new ScoreCalculationBatch(1, numRepeats / sections);
		ID batchprocessid = Database.executeBatch(job);
		Test.stopTest();
		List<Account> lodAccs = [SELECT Recency_Score__c FROM Account WHERE IsPersonAccount = true ORDER BY Last_order_date__c DESC NULLS LAST LIMIT 200];

		//total 200 accs, 40 in each chunk
		//0-39      Recency_Score__c = 5
		//40-79     Recency_Score__c = 4
		//80-119    Recency_Score__c = 3
		//120-159   Recency_Score__c = 2
		//160-199   Recency_Score__c = 1
		for (Integer idx = 0; idx < 1; idx++) {
			System.assertEquals(5, lodAccs.get(idx).Recency_Score__c);
		}
		for (Integer idx = 1; idx < 2; idx++) {
			System.assertEquals(4, lodAccs.get(idx).Recency_Score__c);
		}
		for (Integer idx = 2; idx < 3; idx++) {
			System.assertEquals(3, lodAccs.get(idx).Recency_Score__c);
		}
		for (Integer idx = 3; idx < 4; idx++) {
			System.assertEquals(2, lodAccs.get(idx).Recency_Score__c);
		}
		for (Integer idx = 4; idx < 5; idx++) {
			System.assertEquals(1, lodAccs.get(idx).Recency_Score__c);
		}
	}

	@isTest static void test_batch_NZBO_Step_2() {

		List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Integer numRepeats = 5;
		List<Account> accs = new List<Account>();
		for (Integer idx = 1; idx <= numRepeats; idx++) {
			Account acc = new Account();
			acc.put('RecordTypeId', rtList[0].Id);
			acc.put('FirstName', 'John' + idx);
			acc.put('LastName', 'Doe' + idx);
			acc.put('PersonEmail', 'john_' + idx + '@example.com');
			acc.put('Last_order_date__c', Date.today().addDays(+idx));
			acc.put('Subtotal_From_Zero_Balance_Orders__c', idx);
			//score measurement
			acc.put('Frequency_Score__c', 0);
			//order measurement
			acc.put('Number_Of_Zero_Balance_Orders__c', idx);
			accs.add(acc);
		}
		insert accs;
		// adding orders will recalculate measurement field, to control caluclation, set the field directly
		List<Order__c> orders = new List<Order__c>();
		for (Account acc : accs) {
			orders.add(new Order__c(Account__c = acc.Id));
		}
		insert orders;
		Integer idInteger = 1;
		for (Account acc : accs) {
			acc.put('Number_Of_Zero_Balance_Orders__c', idInteger);
			idInteger++;
		}
		update accs;
		Test.startTest();
		ScoreCalculationBatch job = new ScoreCalculationBatch(1, 1);
		ID batchprocessid = Database.executeBatch(job);
		Test.stopTest();
		List<Account> lodAccs = [SELECT Frequency_Score__c FROM Account WHERE IsPersonAccount = true ORDER BY Number_Of_Zero_Balance_Orders__c DESC NULLS LAST LIMIT 200];

		//total 200 accs, 40 in each chunk
		//0-39      Frequency_Score__c = 5
		//40-79     Frequency_Score__c = 4
		//80-119    Frequency_Score__c = 3
		//120-159   Frequency_Score__c = 2
		//160-199   Frequency_Score__c = 1
		for (Integer idx = 0; idx < 1; idx++) {
			System.assertEquals(5, lodAccs.get(idx).Frequency_Score__c);
		}
		for (Integer idx = 1; idx < 2; idx++) {
			System.assertEquals(4, lodAccs.get(idx).Frequency_Score__c);
		}
		for (Integer idx = 2; idx < 3; idx++) {
			System.assertEquals(3, lodAccs.get(idx).Frequency_Score__c);
		}
		for (Integer idx = 3; idx < 4; idx++) {
			System.assertEquals(2, lodAccs.get(idx).Frequency_Score__c);
		}
		for (Integer idx = 4; idx < 5; idx++) {
			System.assertEquals(1, lodAccs.get(idx).Frequency_Score__c);
		}
	}

	@isTest static void test_batch_SZBO_Step_3() {

		List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Integer numRepeats = 5;
		List<Account> accs = new List<Account>();
		for (Integer idx = 1; idx <= numRepeats; idx++) {
			Account acc = new Account();
			acc.put('RecordTypeId', rtList[0].Id);
			acc.put('FirstName', 'John' + idx);
			acc.put('LastName', 'Doe' + idx);
			acc.put('PersonEmail', 'john_' + idx + '@example.com');
			acc.put('Last_order_date__c', Date.today().addDays(+idx));
			acc.put('Number_Of_Zero_Balance_Orders__c', idx);
			//score measurement
			acc.put('Monetary_Score__c', 0);
			//order measurement
			acc.put('Subtotal_From_Zero_Balance_Orders__c', idx);
			accs.add(acc);
		}
		insert accs;
		List<Order__c> orders = new List<Order__c>();
		for (Account acc : accs) {
			orders.add(new Order__c(Account__c = acc.Id));
		}
		insert orders;
		Integer idInteger = 1;
		for (Account acc : accs) {
			acc.put('Subtotal_From_Zero_Balance_Orders__c', idInteger);
			idInteger++;
		}
		update accs;
		Test.startTest();
		ScoreCalculationBatch job = new ScoreCalculationBatch(1, 1);
		ID batchprocessid = Database.executeBatch(job);
		Test.stopTest();
		List<Account> lodAccs = [SELECT Monetary_Score__c FROM Account WHERE IsPersonAccount = true ORDER BY Subtotal_From_Zero_Balance_Orders__c DESC NULLS LAST LIMIT 200];

		//total 200 accs, 40 in each chunk
		//0-39      Monetary_Score__c = 5
		//40-79     Monetary_Score__c = 4
		//80-119    Monetary_Score__c = 3
		//120-159   Monetary_Score__c = 2
		//160-199   Monetary_Score__c = 1
		for (Integer idx = 0; idx < 1; idx++) {
			System.assertEquals(5, lodAccs.get(idx).Monetary_Score__c);
		}
		for (Integer idx = 1; idx < 2; idx++) {
			System.assertEquals(4, lodAccs.get(idx).Monetary_Score__c);
		}
		for (Integer idx = 2; idx < 3; idx++) {
			System.assertEquals(3, lodAccs.get(idx).Monetary_Score__c);
		}
		for (Integer idx = 3; idx < 4; idx++) {
			System.assertEquals(2, lodAccs.get(idx).Monetary_Score__c);
		}
		for (Integer idx = 4; idx < 5; idx++) {
			System.assertEquals(1, lodAccs.get(idx).Monetary_Score__c);
		}
	}

	@isTest static void test_batch_SZBO_Step_4() {

		TouchCR_Settings__c settingRFMScoreStatus = new TouchCR_Settings__c();
		settingRFMScoreStatus.Name = 'Batch.RFMScoreStatus';
		settingRFMScoreStatus.Value__c = 'On';

		TouchCR_Settings__c settingRFMScoreDay = new TouchCR_Settings__c();
		settingRFMScoreDay.Name = 'Batch.RFMScoreDay';
		settingRFMScoreDay.Value__c = '1';

		TouchCR_Settings__c settingRFMScoreTime = new TouchCR_Settings__c();
		settingRFMScoreTime.Name = 'Batch.RFMScoreTime';
		settingRFMScoreTime.Value__c = '1';

		insert new List<TouchCR_Settings__c>{
			settingRFMScoreStatus, settingRFMScoreDay, settingRFMScoreTime
		};

		List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Integer numRepeats = 5;
		List<Account> accs = new List<Account>();
		for (Integer idx = 1; idx <= numRepeats; idx++) {
			Account acc = new Account();
			acc.put('RecordTypeId', rtList[0].Id);
			acc.put('FirstName', 'John' + idx);
			acc.put('LastName', 'Doe' + idx);
			acc.put('PersonEmail', 'john_' + idx + '@example.com');
			acc.put('Last_order_date__c', Date.today().addDays(+idx));
			acc.put('Number_Of_Zero_Balance_Orders__c', idx);
			//score measurement
			acc.put('Monetary_Score__c', 0);
			//order measurement
			acc.put('Subtotal_From_Zero_Balance_Orders__c', idx);
			accs.add(acc);
		}
		insert accs;
		List<Order__c> orders = new List<Order__c>();
		for (Account acc : accs) {
			orders.add(new Order__c(Account__c = acc.Id));
		}
		insert orders;
		Integer idInteger = 1;
		for (Account acc : accs) {
			acc.put('Subtotal_From_Zero_Balance_Orders__c', idInteger);
			idInteger++;
		}
		update accs;
		Test.startTest();
		ScoreCalculationBatch job = new ScoreCalculationBatch(1, 1);
		ID batchprocessid = Database.executeBatch(job);
		Test.stopTest();
		List<Account> lodAccs = [SELECT Monetary_Score__c FROM Account WHERE IsPersonAccount = true ORDER BY Subtotal_From_Zero_Balance_Orders__c DESC NULLS LAST LIMIT 200];

		//total 200 accs, 40 in each chunk
		//0-39      Monetary_Score__c = 5
		//40-79     Monetary_Score__c = 4
		//80-119    Monetary_Score__c = 3
		//120-159   Monetary_Score__c = 2
		//160-199   Monetary_Score__c = 1
		for (Integer idx = 0; idx < 1; idx++) {
			System.assertEquals(5, lodAccs.get(idx).Monetary_Score__c);
		}
		for (Integer idx = 1; idx < 2; idx++) {
			System.assertEquals(4, lodAccs.get(idx).Monetary_Score__c);
		}
		for (Integer idx = 2; idx < 3; idx++) {
			System.assertEquals(3, lodAccs.get(idx).Monetary_Score__c);
		}
		for (Integer idx = 3; idx < 4; idx++) {
			System.assertEquals(2, lodAccs.get(idx).Monetary_Score__c);
		}
		for (Integer idx = 4; idx < 5; idx++) {
			System.assertEquals(1, lodAccs.get(idx).Monetary_Score__c);
		}
	}
}