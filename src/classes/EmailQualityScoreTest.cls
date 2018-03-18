@isTest
public class EmailQualityScoreTest {

@isTest static void scoreEmailQualityTestFourPoorList() {

        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        List<Account> accountsToMap = new List<Account>();
        List<Case> caseToMap = new List<Case>();
        List<Log__c> logsToMap = new List<Log__c>();

        Account accItem;
        Date today = System.today();
        Date dateFirstSeenGen = today.addMonths(-1);
        dateFirstSeenGen = dateFirstSeenGen.addDays(-5);
        String dateFirstSeen = string.valueof(DateFirstSeenGen.year()) + '-' + string.valueof(DateFirstSeenGen.month()) + '-' + string.valueof(DateFirstSeenGen.day());
        Date monthLastOpenedGen = today.addMonths(-5);
        String monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());
        for(Integer i = 0; i < 200; i++){
            accItem = new Account(Name = 'Account ' + i, EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = true,
                                Email_Box_Valid__c = true, EAM_Velocity__c = 1, EAM_Popularity__c = 1, EAM_Month_Last_Opened__c = monthLastOpened);
            accountsToMap.add(accItem);
        }
        result.put(TowerDataAPIClient.OBJECT_SECTION, accountsToMap);
        result.put(TowerDataAPIClient.LOGS_SECTION, logsToMap);
        result.put(TowerDataAPIClient.CASE_SECTION, caseToMap);

        Test.startTest();
            Map<String, List<SObject>> scopeEmail = EmailQualityScore.scoreEmailQuality(result);
        Test.stopTest();

        System.assertEquals(0, result.get(TowerDataAPIClient.LOGS_SECTION).size());
        System.assertEquals(0, result.get(TowerDataAPIClient.CASE_SECTION).size());
        System.assertEquals(200, result.get(TowerDataAPIClient.OBJECT_SECTION).size());

        accountsToMap = result.get(TowerDataAPIClient.OBJECT_SECTION);

        for(Integer i = 0; i < accountsToMap.size(); i++){
            System.assertEquals('*', accountsToMap[i].Email_Quality__c);
        }
    }


@isTest static void scoreEmailQualityTestNineDifferentValue() {

        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        List<Account> accountsToMap = new List<Account>();
        List<Case> caseToMap = new List<Case>();
        List<Log__c> logsToMap = new List<Log__c>();

        Account accItem;
        Date today = System.today();
        Date dateFirstSeenGen = today.addMonths(-1);
        dateFirstSeenGen = dateFirstSeenGen.addDays(-5);
        String dateFirstSeen = string.valueof(DateFirstSeenGen.year()) + '-' + string.valueof(DateFirstSeenGen.month()) + '-' + string.valueof(DateFirstSeenGen.day());
        Date monthLastOpenedGen = today.addMonths(-5);
        String monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());

        accItem = new Account(Name = 'Account 0', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = true,
                                Email_Box_Valid__c = true, EAM_Velocity__c = 1, EAM_Popularity__c = 1, EAM_Month_Last_Opened__c = monthLastOpened);
        accountsToMap.add(accItem);

        accItem = new Account(Name = 'Account 1', EAM_Date_First_Seen__c = '2016-19-05', Email_Valid__c = true, Email_Box_Valid__c = true,
                            EAM_Velocity__c = 1, EAM_Popularity__c = 1, EAM_Month_Last_Opened__c = monthLastOpened);
        accountsToMap.add(accItem);

        dateFirstSeenGen = today.addMonths(-4);
        dateFirstSeenGen = dateFirstSeenGen.addDays(-5);
        dateFirstSeen = string.valueof(DateFirstSeenGen.year()) + '-' + string.valueof(DateFirstSeenGen.month()) + '-' + string.valueof(DateFirstSeenGen.day());
        monthLastOpenedGen = today.addMonths(-1);
        monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());

        accItem = new Account(Name = 'Account 2', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = true, Email_Box_Valid__c = true,
                            EAM_Velocity__c = 1, EAM_Popularity__c = 1, EAM_Month_Last_Opened__c = monthLastOpened);
        accountsToMap.add(accItem);

        monthLastOpenedGen = today.addMonths(-3);
        monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());

        accItem = new Account(Name = 'Account 3', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = true, Email_Box_Valid__c = true,
                            EAM_Velocity__c = 3, EAM_Popularity__c = 3, EAM_Month_Last_Opened__c = monthLastOpened);
        accountsToMap.add(accItem);

        dateFirstSeenGen = today.addMonths(-4);
        dateFirstSeenGen = dateFirstSeenGen.addYears(-2);
        dateFirstSeenGen = dateFirstSeenGen.addDays(-5);
        dateFirstSeen = string.valueof(DateFirstSeenGen.year()) + '-' + string.valueof(DateFirstSeenGen.month()) + '-' + string.valueof(DateFirstSeenGen.day());
        monthLastOpenedGen = today.addMonths(-1);
        monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());

        accItem = new Account(Name = 'Account 4', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = true, Email_Box_Valid__c = true,
                            EAM_Velocity__c = 6, EAM_Month_Last_Opened__c = monthLastOpened);
        accountsToMap.add(accItem);


        accItem = new Account(Name = 'Account 5', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = true, Email_Box_Valid__c = true,
                            EAM_Velocity__c = 6, EAM_Popularity__c = 9, EAM_Month_Last_Opened__c = monthLastOpened);
        accountsToMap.add(accItem);

        dateFirstSeenGen = today.addMonths(-1);
        dateFirstSeenGen = dateFirstSeenGen.addDays(-5);
        dateFirstSeen = string.valueof(DateFirstSeenGen.year()) + '-' + string.valueof(DateFirstSeenGen.month()) + '-' + string.valueof(DateFirstSeenGen.day());
        monthLastOpenedGen = today.addMonths(-8);
        monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());

        accItem = new Account(Name = 'Account 6', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = true, Email_Box_Valid__c = true,
                            EAM_Popularity__c = 10, EAM_Month_Last_Opened__c = monthLastOpened);
        accountsToMap.add(accItem);
        dateFirstSeenGen = today.addMonths(-4);
        dateFirstSeenGen = dateFirstSeenGen.addDays(-5);
        dateFirstSeen = string.valueof(DateFirstSeenGen.year()) + '-' + string.valueof(DateFirstSeenGen.month()) + '-' + string.valueof(DateFirstSeenGen.day());

        accItem = new Account(Name = 'Account 7', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = true, Email_Box_Valid__c = true,
                            EAM_Velocity__c = 9, EAM_Popularity__c = 10, EAM_Month_Last_Opened__c = monthLastOpened);
        accountsToMap.add(accItem);

        dateFirstSeenGen = today.addMonths(-4);
        dateFirstSeenGen = dateFirstSeenGen.addYears(-2);
        dateFirstSeenGen = dateFirstSeenGen.addDays(-5);
        dateFirstSeen = string.valueof(DateFirstSeenGen.year()) + '-' + string.valueof(DateFirstSeenGen.month()) + '-' + string.valueof(DateFirstSeenGen.day());
        monthLastOpenedGen = today.addMonths(-1);
        monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());
        accItem = new Account(Name = 'Account 8', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = true, Email_Box_Valid__c = false,
                            EAM_Velocity__c = 6, EAM_Popularity__c = 9, EAM_Month_Last_Opened__c = monthLastOpened);
        accountsToMap.add(accItem);
        accItem = new Account(Name = 'Account 9', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = false, Email_Box_Valid__c = true,
                            EAM_Velocity__c = 6, EAM_Month_Last_Opened__c = monthLastOpened);
        accountsToMap.add(accItem);

        result.put(TowerDataAPIClient.OBJECT_SECTION, accountsToMap);
        result.put(TowerDataAPIClient.LOGS_SECTION, logsToMap);
        result.put(TowerDataAPIClient.CASE_SECTION, caseToMap);

        Test.startTest();
            Map<String, List<SObject>> scopeEmail = EmailQualityScore.scoreEmailQuality(result);
        Test.stopTest();

        System.assertEquals(0, result.get(TowerDataAPIClient.LOGS_SECTION).size());
        System.assertEquals(4, result.get(TowerDataAPIClient.CASE_SECTION).size());
        System.assertEquals(10, result.get(TowerDataAPIClient.OBJECT_SECTION).size());

        accountsToMap = result.get(TowerDataAPIClient.OBJECT_SECTION);
        caseToMap = result.get(TowerDataAPIClient.CASE_SECTION);

        System.assertEquals('*', accountsToMap[0].Email_Quality__c);
        System.assertEquals('', accountsToMap[1].Email_Quality__c);
        System.assertEquals('**', accountsToMap[2].Email_Quality__c);
        System.assertEquals('***', accountsToMap[3].Email_Quality__c);
        System.assertEquals('****', accountsToMap[4].Email_Quality__c);
        System.assertEquals('*****', accountsToMap[5].Email_Quality__c);
        System.assertEquals('FW', accountsToMap[6].Email_Quality__c);
        System.assertEquals('ST', accountsToMap[7].Email_Quality__c);
        System.assertEquals('BA', accountsToMap[8].Email_Quality__c);
        System.assertEquals('HB', accountsToMap[9].Email_Quality__c);

        System.assertEquals('Fraud Investigate', caseToMap[0].Subject);
        System.assertEquals('Opt Out Email Address', caseToMap[1].Subject);
        System.assertEquals('Opt Out Email Address', caseToMap[2].Subject);
        System.assertEquals('Correct Email Address', caseToMap[3].Subject);
    }

    @isTest static void scoreEmailQualityTestFourPoorNow() {

        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        List<Account> accountsToInsert = new List<Account>();
        List<Case> caseToMap = new List<Case>();
        List<Log__c> logsToMap = new List<Log__c>();

        Account acc;
        Case caseItem;
        Date today = System.today();
        Date monthLastOpenedGen = today.addMonths(-5);
        String monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());

        acc = new Account(Name = 'Account 0', EAM_Date_First_Seen__c = 'now', Email_Valid__c = true, Email_Box_Valid__c = true,
                            EAM_Velocity__c = 1, EAM_Popularity__c = 1, EAM_Month_Last_Opened__c = monthLastOpened);
        accountsToInsert.add(acc);

        caseItem = new Case(
                    Subject = 'TestSubject', AccountId = acc.Id,
                    Status = 'TestStatus', Origin = 'TestOrigin'
                );

        caseToMap.add(caseItem);

        result.put(TowerDataAPIClient.OBJECT_SECTION, accountsToInsert);
        result.put(TowerDataAPIClient.LOGS_SECTION, logsToMap);
        result.put(TowerDataAPIClient.CASE_SECTION, caseToMap);

        Test.startTest();
            Map<String, List<SObject>> scopeEmail = EmailQualityScore.scoreEmailQuality(result);
        Test.stopTest();

        accountsToInsert = result.get(TowerDataAPIClient.OBJECT_SECTION);

        System.assertEquals(1, result.get(TowerDataAPIClient.CASE_SECTION).size());
        System.assertEquals('*', accountsToInsert[0].Email_Quality__c);
    }


    @isTest static void scoreEmailQualityTestMonthLastOpenedExeption() {

        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        List<Account> accountsToInsert = new List<Account>();
        List<Case> caseToMap = new List<Case>();
        List<Log__c> logsToMap = new List<Log__c>();

        Account acc;
        Case caseItem;

        Date today = System.today();
        Date dateFirstSeenGen = today.addMonths(-1);
        dateFirstSeenGen = dateFirstSeenGen.addDays(-5);
        String dateFirstSeen = string.valueof(DateFirstSeenGen.year()) + '-' + string.valueof(DateFirstSeenGen.month()) + '-' + string.valueof(DateFirstSeenGen.day());

        acc = new Account(Name = 'Account 0', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = true, Email_Box_Valid__c = true,
                            EAM_Velocity__c = 1, EAM_Popularity__c = 1, EAM_Month_Last_Opened__c = '2016-15');
        accountsToInsert.add(acc);

        caseItem = new Case(
                    Subject = 'TestSubject', AccountId = acc.Id,
                    Status = 'TestStatus', Origin = 'TestOrigin'
                );

        caseToMap.add(caseItem);

        result.put(TowerDataAPIClient.OBJECT_SECTION, accountsToInsert);
        result.put(TowerDataAPIClient.LOGS_SECTION, logsToMap);
        result.put(TowerDataAPIClient.CASE_SECTION, caseToMap);

        Test.startTest();
            Map<String, List<SObject>> scopeEmail = EmailQualityScore.scoreEmailQuality(result);
        Test.stopTest();

        accountsToInsert = result.get(TowerDataAPIClient.OBJECT_SECTION);

        System.assertEquals(1, result.get(TowerDataAPIClient.CASE_SECTION).size());
        System.assertEquals('', accountsToInsert[0].Email_Quality__c);
    }


    @isTest static void scoreEmailQualityTestLeadFourPoor() {

        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        List<Lead> leadsToInsert = new List<Lead>();
        List<Case> caseToMap = new List<Case>();
        List<Log__c> logsToMap = new List<Log__c>();

        Lead testLead;
        Case caseItem;

        Date today = System.today();
        Date dateFirstSeenGen = today.addMonths(-1);
        dateFirstSeenGen = dateFirstSeenGen.addDays(-5);
        String dateFirstSeen = string.valueof(DateFirstSeenGen.year()) + '-' + string.valueof(DateFirstSeenGen.month()) + '-' + string.valueof(DateFirstSeenGen.day());
        Date monthLastOpenedGen = today.addMonths(-5);
        String monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());

        testLead = new Lead(LastName = 'Lead 0', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = true, Email_Box_Valid__c = true,
                                EAM_Velocity__c = 1, EAM_Popularity__c = 1, EAM_Month_Last_Opened__c = monthLastOpened);
        leadsToInsert.add(testLead);

        caseItem = new Case(
                    Subject = 'TestSubject', AccountId = testLead.Id,
                    Status = 'TestStatus', Origin = 'TestOrigin'
                );

        caseToMap.add(caseItem);

        result.put(TowerDataAPIClient.OBJECT_SECTION, leadsToInsert);
        result.put(TowerDataAPIClient.LOGS_SECTION, logsToMap);
        result.put(TowerDataAPIClient.CASE_SECTION, caseToMap);

        Test.startTest();
            Map<String, List<SObject>> scopeEmail = EmailQualityScore.scoreEmailQuality(result);
        Test.stopTest();

        leadsToInsert = result.get(TowerDataAPIClient.OBJECT_SECTION);

        System.assertEquals(1, result.get(TowerDataAPIClient.CASE_SECTION).size());
        System.assertEquals('*', leadsToInsert[0].Email_Quality__c);
    }


    @isTest static void scoreEmailQualityTestDateFirstSeenExept() {

        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        List<Lead> leadsToInsert = new List<Lead>();
        List<Case> caseToMap = new List<Case>();
        List<Log__c> logsToMap = new List<Log__c>();

        Lead testLead;
        Case caseItem;
        Date today = System.today();
        Date monthLastOpenedGen = today.addMonths(-5);
        String monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());

        testLead = new Lead(LastName = 'Lead 0', EAM_Date_First_Seen__c = '2016-29-05', Email_Valid__c = true, Email_Box_Valid__c = true,
                                EAM_Velocity__c = 1, EAM_Popularity__c = 1, EAM_Month_Last_Opened__c = monthLastOpened);
        leadsToInsert.add(testLead);

        caseItem = new Case(
                    Subject = 'TestSubject', AccountId = testLead.Id,
                    Status = 'TestStatus', Origin = 'TestOrigin'
                );

        caseToMap.add(caseItem);

        result.put(TowerDataAPIClient.OBJECT_SECTION, leadsToInsert);
        result.put(TowerDataAPIClient.LOGS_SECTION, logsToMap);
        result.put(TowerDataAPIClient.CASE_SECTION, caseToMap);

        Test.startTest();
            Map<String, List<SObject>> scopeEmail = EmailQualityScore.scoreEmailQuality(result);
        Test.stopTest();

        leadsToInsert = result.get(TowerDataAPIClient.OBJECT_SECTION);

        System.assertEquals(1, result.get(TowerDataAPIClient.CASE_SECTION).size());
        System.assertEquals('', leadsToInsert[0].Email_Quality__c);
    }


    @isTest static void scoreEmailQualityTestMonthLastOpenedExept() {

        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        List<Lead> leadsToInsert = new List<Lead>();
        List<Case> caseToMap = new List<Case>();
        List<Log__c> logsToMap = new List<Log__c>();

        Lead testLead;
        Case caseItem;
        Date today = System.today();
        Date dateFirstSeenGen = today.addMonths(-1);
        dateFirstSeenGen = dateFirstSeenGen.addDays(-5);
        String dateFirstSeen = string.valueof(DateFirstSeenGen.year()) + '-' + string.valueof(DateFirstSeenGen.month()) + '-' + string.valueof(DateFirstSeenGen.day());

        testLead = new Lead(LastName = 'Lead 0', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = true, Email_Box_Valid__c = true,
                                EAM_Velocity__c = 1, EAM_Popularity__c = 1, EAM_Month_Last_Opened__c = '2016-75');
        leadsToInsert.add(testLead);

        caseItem = new Case(
                    Subject = 'TestSubject', AccountId = testLead.Id,
                    Status = 'TestStatus', Origin = 'TestOrigin'
                );

        caseToMap.add(caseItem);

        result.put(TowerDataAPIClient.OBJECT_SECTION, leadsToInsert);
        result.put(TowerDataAPIClient.LOGS_SECTION, logsToMap);
        result.put(TowerDataAPIClient.CASE_SECTION, caseToMap);

        Test.startTest();
            Map<String, List<SObject>> scopeEmail = EmailQualityScore.scoreEmailQuality(result);
        Test.stopTest();

        leadsToInsert = result.get(TowerDataAPIClient.OBJECT_SECTION);

        System.assertEquals(1, result.get(TowerDataAPIClient.CASE_SECTION).size());
        System.assertEquals('', leadsToInsert[0].Email_Quality__c);
    }


    @isTest static void scoreEmailQualityTestLeadFourPoorNow() {

        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        List<Lead> leadsToInsert = new List<Lead>();
        List<Case> caseToMap = new List<Case>();
        List<Log__c> logsToMap = new List<Log__c>();

        Lead testLead;
        Case caseItem;

        Date today = System.today();
        Date monthLastOpenedGen = today.addMonths(-5);
        String monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());

        testLead = new Lead(LastName = 'Lead 11', EAM_Date_First_Seen__c = 'now', Email_Valid__c = true, Email_Box_Valid__c = true,
                                    EAM_Velocity__c = 1, EAM_Popularity__c = 1, EAM_Month_Last_Opened__c = monthLastOpened);
        leadsToInsert.add(testLead);

        caseItem = new Case(
                    Subject = 'TestSubject', AccountId = testLead.Id,
                    Status = 'TestStatus', Origin = 'TestOrigin'
                );

        caseToMap.add(caseItem);

        result.put(TowerDataAPIClient.OBJECT_SECTION, leadsToInsert);
        result.put(TowerDataAPIClient.LOGS_SECTION, logsToMap);
        result.put(TowerDataAPIClient.CASE_SECTION, caseToMap);

        Test.startTest();
            Map<String, List<SObject>> scopeEmail = EmailQualityScore.scoreEmailQuality(result);
        Test.stopTest();

        leadsToInsert = result.get(TowerDataAPIClient.OBJECT_SECTION);

        System.assertEquals(1, result.get(TowerDataAPIClient.CASE_SECTION).size());
        System.assertEquals('*', leadsToInsert[0].Email_Quality__c);
    }


    @isTest static void scoreEmailQualityTestLeadClearFourField() {

        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        List<Lead> leadsToInsert = new List<Lead>();
        List<Case> caseToMap = new List<Case>();
        List<Log__c> logsToMap = new List<Log__c>();

        Lead testLead;
        Case caseItem;

        testLead = new Lead(LastName = 'Lead 12', Email_Valid__c = true, Email_Box_Valid__c = true);
        leadsToInsert.add(testLead);

        caseItem = new Case(
                    Subject = 'TestSubject', AccountId = testLead.Id,
                    Status = 'TestStatus', Origin = 'TestOrigin'
                );

        caseToMap.add(caseItem);

        result.put(TowerDataAPIClient.OBJECT_SECTION, leadsToInsert);
        result.put(TowerDataAPIClient.LOGS_SECTION, logsToMap);
        result.put(TowerDataAPIClient.CASE_SECTION, caseToMap);

        Test.startTest();
            Map<String, List<SObject>> scopeEmail = EmailQualityScore.scoreEmailQuality(result);
        Test.stopTest();

        leadsToInsert = result.get(TowerDataAPIClient.OBJECT_SECTION);

        System.assertEquals(1, result.get(TowerDataAPIClient.CASE_SECTION).size());
        System.assertEquals('', leadsToInsert[0].Email_Quality__c);
    }


    @isTest static void scoreEmailQualityTestLeadFourPoorList() {

        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        List<Lead> leadsToInsert = new List<Lead>();
        List<Case> caseToMap = new List<Case>();
        List<Log__c> logsToMap = new List<Log__c>();

        Lead testLead;
        Case caseItem;

        Date today = System.today();
        Date dateFirstSeenGen = today.addMonths(-1);
        dateFirstSeenGen = dateFirstSeenGen.addDays(-5);
        String dateFirstSeen = string.valueof(DateFirstSeenGen.year()) + '-' + string.valueof(DateFirstSeenGen.month()) + '-' + string.valueof(DateFirstSeenGen.day());
        Date monthLastOpenedGen = today.addMonths(-5);
        String monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());

        for(Integer i = 0; i < 200; i++){
            testLead = new Lead(LastName = 'Lead ' + i, EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = true, Email_Box_Valid__c = true,
                                    EAM_Velocity__c = 1, EAM_Popularity__c = 1, EAM_Month_Last_Opened__c = monthLastOpened);
            leadsToInsert.add(testLead);
        }

        result.put(TowerDataAPIClient.OBJECT_SECTION, leadsToInsert);
        result.put(TowerDataAPIClient.LOGS_SECTION, logsToMap);
        result.put(TowerDataAPIClient.CASE_SECTION, caseToMap);

        Test.startTest();
            Map<String, List<SObject>> scopeEmail = EmailQualityScore.scoreEmailQuality(result);
        Test.stopTest();

        System.assertEquals(0, result.get(TowerDataAPIClient.LOGS_SECTION).size());
        System.assertEquals(0, result.get(TowerDataAPIClient.CASE_SECTION).size());
        System.assertEquals(200, result.get(TowerDataAPIClient.OBJECT_SECTION).size());

        leadsToInsert = result.get(TowerDataAPIClient.OBJECT_SECTION);

        for(Integer i = 0; i < leadsToInsert.size(); i++){
            System.assertEquals('*', leadsToInsert[i].Email_Quality__c);
        }
    }

    // Valid sintax = NOK
    @isTest static void scoreEmailQualityTestLeadFourPoorF() {

        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        List<Lead> leadsToInsert = new List<Lead>();
        List<Case> caseToMap = new List<Case>();
        List<Log__c> logsToMap = new List<Log__c>();

        Lead testLead;
        Case caseItem;

        Date today = System.today();
        Date dateFirstSeenGen = today.addMonths(-1);
        dateFirstSeenGen = dateFirstSeenGen.addDays(-5);
        String dateFirstSeen = string.valueof(DateFirstSeenGen.year()) + '-' + string.valueof(DateFirstSeenGen.month()) + '-' + string.valueof(DateFirstSeenGen.day());
        Date monthLastOpenedGen = today.addMonths(-5);
        String monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());

        testLead = new Lead(LastName = 'Lead 0', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = false, Email_Box_Valid__c = true,
                                EAM_Velocity__c = 1, EAM_Popularity__c = 1, EAM_Month_Last_Opened__c = monthLastOpened);
        leadsToInsert.add(testLead);

        caseItem = new Case(
                    Subject = 'TestSubject', AccountId = testLead.Id,
                    Status = 'TestStatus', Origin = 'TestOrigin'
                );

        caseToMap.add(caseItem);

        result.put(TowerDataAPIClient.OBJECT_SECTION, leadsToInsert);
        result.put(TowerDataAPIClient.LOGS_SECTION, logsToMap);
        result.put(TowerDataAPIClient.CASE_SECTION, caseToMap);

        Test.startTest();
            Map<String, List<SObject>> scopeEmail = EmailQualityScore.scoreEmailQuality(result);
        Test.stopTest();

        leadsToInsert = result.get(TowerDataAPIClient.OBJECT_SECTION);
        caseToMap = result.get(TowerDataAPIClient.CASE_SECTION);

        System.assertEquals('Correct Email Address', caseToMap[1].Subject);
        System.assertEquals('HB', leadsToInsert[0].Email_Quality__c);
    }


    // Valid sintax = NOK
    @isTest static void scoreEmailQualityTestLeadFourOkF() {

        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        List<Lead> leadsToInsert = new List<Lead>();
        List<Case> caseToMap = new List<Case>();
        List<Log__c> logsToMap = new List<Log__c>();

        Lead testLead;
        Case caseItem;

        Date today = System.today();
        Date dateFirstSeenGen = today.addMonths(-4);
        dateFirstSeenGen = dateFirstSeenGen.addDays(-5);
        String dateFirstSeen = string.valueof(DateFirstSeenGen.year()) + '-' + string.valueof(DateFirstSeenGen.month()) + '-' + string.valueof(DateFirstSeenGen.day());
        Date monthLastOpenedGen = today.addMonths(-3);
        String monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());

        testLead = new Lead(LastName = 'Lead 3', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = false, Email_Box_Valid__c = true,
                                EAM_Velocity__c = 3, EAM_Popularity__c = 3, EAM_Month_Last_Opened__c = monthLastOpened);
        leadsToInsert.add(testLead);

        caseItem = new Case(
                    Subject = 'TestSubject', AccountId = testLead.Id,
                    Status = 'TestStatus', Origin = 'TestOrigin'
                );

        caseToMap.add(caseItem);

        result.put(TowerDataAPIClient.OBJECT_SECTION, leadsToInsert);
        result.put(TowerDataAPIClient.LOGS_SECTION, logsToMap);
        result.put(TowerDataAPIClient.CASE_SECTION, caseToMap);

        Test.startTest();
            Map<String, List<SObject>> scopeEmail = EmailQualityScore.scoreEmailQuality(result);
        Test.stopTest();

        leadsToInsert = result.get(TowerDataAPIClient.OBJECT_SECTION);
        caseToMap = result.get(TowerDataAPIClient.CASE_SECTION);

        System.assertEquals('Correct Email Address', caseToMap[1].Subject);
        System.assertEquals('HB', leadsToInsert[0].Email_Quality__c);
    }


    // Age email adress from today < 2m and Velocity = null
    @isTest static void scoreEmailQualityTestLeadFraudWarning() {

        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        List<Lead> leadsToInsert = new List<Lead>();
        List<Case> caseToMap = new List<Case>();
        List<Log__c> logsToMap = new List<Log__c>();

        Lead testLead;
        Case caseItem;

        Date today = System.today();
        Date dateFirstSeenGen = today.addMonths(-1);
        dateFirstSeenGen = dateFirstSeenGen.addDays(-5);
        String dateFirstSeen = string.valueof(DateFirstSeenGen.year()) + '-' + string.valueof(DateFirstSeenGen.month()) + '-' + string.valueof(DateFirstSeenGen.day());
        Date monthLastOpenedGen = today.addMonths(-8);
        String monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());

        testLead = new Lead(LastName = 'Lead 6', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = true, Email_Box_Valid__c = true,
                                EAM_Popularity__c = 10, EAM_Month_Last_Opened__c = monthLastOpened);
        leadsToInsert.add(testLead);

        caseItem = new Case(
                    Subject = 'TestSubject', AccountId = testLead.Id,
                    Status = 'TestStatus', Origin = 'TestOrigin'
                );

        caseToMap.add(caseItem);

        result.put(TowerDataAPIClient.OBJECT_SECTION, leadsToInsert);
        result.put(TowerDataAPIClient.LOGS_SECTION, logsToMap);
        result.put(TowerDataAPIClient.CASE_SECTION, caseToMap);

        Test.startTest();
            Map<String, List<SObject>> scopeEmail = EmailQualityScore.scoreEmailQuality(result);
        Test.stopTest();

        leadsToInsert = result.get(TowerDataAPIClient.OBJECT_SECTION);
        caseToMap = result.get(TowerDataAPIClient.CASE_SECTION);

        System.assertEquals('Fraud Investigate', caseToMap[1].Subject);
        System.assertEquals('FW', leadsToInsert[0].Email_Quality__c);
    }

    //Velocity > 8 AND Popularity > 8 AND difference between last opened and append date >6 month
    @isTest static void scoreEmailQualityTestLeadPossibleSpamTrap() {

        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        List<Lead> leadsToInsert = new List<Lead>();
        List<Case> caseToMap = new List<Case>();
        List<Log__c> logsToMap = new List<Log__c>();

        Lead testLead;
        Case caseItem;

        Date today = System.today();
        Date dateFirstSeenGen = today.addMonths(-1);
        dateFirstSeenGen = dateFirstSeenGen.addDays(-4);
        String dateFirstSeen = string.valueof(DateFirstSeenGen.year()) + '-' + string.valueof(DateFirstSeenGen.month()) + '-' + string.valueof(DateFirstSeenGen.day());
        Date monthLastOpenedGen = today.addMonths(-8);
        String monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());


        testLead = new Lead(LastName = 'Lead 7', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = true, Email_Box_Valid__c = true,
                                EAM_Velocity__c = 9, EAM_Popularity__c = 10, EAM_Month_Last_Opened__c = monthLastOpened);
        leadsToInsert.add(testLead);

        caseItem = new Case(
                    Subject = 'TestSubject', AccountId = testLead.Id,
                    Status = 'TestStatus', Origin = 'TestOrigin'
                );

        caseToMap.add(caseItem);

        result.put(TowerDataAPIClient.OBJECT_SECTION, leadsToInsert);
        result.put(TowerDataAPIClient.LOGS_SECTION, logsToMap);
        result.put(TowerDataAPIClient.CASE_SECTION, caseToMap);

        Test.startTest();
            Map<String, List<SObject>> scopeEmail = EmailQualityScore.scoreEmailQuality(result);
        Test.stopTest();

        leadsToInsert = result.get(TowerDataAPIClient.OBJECT_SECTION);
        caseToMap = result.get(TowerDataAPIClient.CASE_SECTION);

        System.assertEquals('Opt Out Email Address', caseToMap[1].Subject);
        System.assertEquals('ST', leadsToInsert[0].Email_Quality__c);
    }

    // Inbox receiving - NOK
    @isTest static void scoreEmailQualityTestLeadPossibleBounceAlert() {

        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        List<Lead> leadsToInsert = new List<Lead>();
        List<Case> caseToMap = new List<Case>();
        List<Log__c> logsToMap = new List<Log__c>();

        Lead testLead;
        Case caseItem;

        Date today = System.today();
        Date dateFirstSeenGen = today.addMonths(-4);
        dateFirstSeenGen = dateFirstSeenGen.addYears(-2);
        dateFirstSeenGen = dateFirstSeenGen.addDays(-5);
        String dateFirstSeen = string.valueof(DateFirstSeenGen.year()) + '-' + string.valueof(DateFirstSeenGen.month()) + '-' + string.valueof(DateFirstSeenGen.day());
        Date monthLastOpenedGen = today.addMonths(-1);
        String monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());

        testLead = new Lead(LastName = 'Lead 8', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = true, Email_Box_Valid__c = false,
                                    EAM_Velocity__c = 6, EAM_Popularity__c = 9, EAM_Month_Last_Opened__c = monthLastOpened);
        leadsToInsert.add(testLead);

        caseItem = new Case(
                    Subject = 'TestSubject', AccountId = testLead.Id,
                    Status = 'TestStatus', Origin = 'TestOrigin'
                );

        caseToMap.add(caseItem);

        result.put(TowerDataAPIClient.OBJECT_SECTION, leadsToInsert);
        result.put(TowerDataAPIClient.LOGS_SECTION, logsToMap);
        result.put(TowerDataAPIClient.CASE_SECTION, caseToMap);

        Test.startTest();
            Map<String, List<SObject>> scopeEmail = EmailQualityScore.scoreEmailQuality(result);
        Test.stopTest();

        leadsToInsert = result.get(TowerDataAPIClient.OBJECT_SECTION);
        caseToMap = result.get(TowerDataAPIClient.CASE_SECTION);

        System.assertEquals('Opt Out Email Address', caseToMap[1].Subject);
        System.assertEquals('BA', leadsToInsert[0].Email_Quality__c);
    }

    // Valid syntax = NOK
    @isTest static void scoreEmailQualityTestLeadHardBounceAlert() {

        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        List<Lead> leadsToInsert = new List<Lead>();
        List<Case> caseToMap = new List<Case>();
        List<Log__c> logsToMap = new List<Log__c>();

        Lead testLead;
        Case caseItem;

        Date today = System.today();
        Date dateFirstSeenGen = today.addMonths(-4);
        dateFirstSeenGen = dateFirstSeenGen.addYears(-2);
        dateFirstSeenGen = dateFirstSeenGen.addDays(-5);
        String dateFirstSeen = string.valueof(DateFirstSeenGen.year()) + '-' + string.valueof(DateFirstSeenGen.month()) + '-' + string.valueof(DateFirstSeenGen.day());
        Date monthLastOpenedGen = today.addMonths(-1);
        String monthLastOpened = string.valueof(MonthLastOpenedGen.year()) + '-' + string.valueof(MonthLastOpenedGen.month());

        testLead = new Lead(LastName = 'Lead 9', EAM_Date_First_Seen__c = dateFirstSeen, Email_Valid__c = false, Email_Box_Valid__c = true,
                                EAM_Velocity__c = 6, EAM_Month_Last_Opened__c = monthLastOpened);
        leadsToInsert.add(testLead);

        caseItem = new Case(
                    Subject = 'TestSubject', AccountId = testLead.Id,
                    Status = 'TestStatus', Origin = 'TestOrigin'
                );

        caseToMap.add(caseItem);

        result.put(TowerDataAPIClient.OBJECT_SECTION, leadsToInsert);
        result.put(TowerDataAPIClient.LOGS_SECTION, logsToMap);
        result.put(TowerDataAPIClient.CASE_SECTION, caseToMap);

        Test.startTest();
            Map<String, List<SObject>> scopeEmail = EmailQualityScore.scoreEmailQuality(result);
        Test.stopTest();

        leadsToInsert = result.get(TowerDataAPIClient.OBJECT_SECTION);
        caseToMap = result.get(TowerDataAPIClient.CASE_SECTION);

        System.assertEquals('Correct Email Address', caseToMap[1].Subject);
        System.assertEquals('HB', leadsToInsert[0].Email_Quality__c);
    }

}