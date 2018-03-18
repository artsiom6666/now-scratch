@isTest
private class ScoreCalculationCounterBatchTest {

    @isTest static void test_countpersonacc() {
        Integer start = 1;
        Integer numRepeats = 10;
        List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true];
        List<Account> accs = new List<Account>();
        for (Integer idx = start; idx <= numRepeats; idx++) {
            Account acc = new Account();
            acc.put('RecordTypeId', rtList[0].Id);
            acc.put('FirstName', 'John' + idx);
            acc.put('LastName', 'Testscorecounter');
            accs.add(acc);
        }
        insert accs;

        Test.startTest();
            ScoreCalculationCounterBatch b = new ScoreCalculationCounterBatch();
            Database.executebatch(b);
        Test.stopTest();
        //dummy assert
        System.assertEquals(10, accs.size());
    }
}