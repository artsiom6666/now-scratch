@isTest
private class AccountToBlackListControllerTest {
    
    @isTest
    static void testValidPermissions_noaccess() {
        Account acc = new Account (Name = 'Test Account');
        insert acc;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User u = new User(Alias = 'sysadm', Email='sysadmin@test.com',
                          EmailEncodingKey='UTF-8', LastName='TestSys', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='123touchcrsysadmintest@123test.com');
        
        ApexPages.StandardController sc = new ApexPages.standardController(acc);
        
        System.runAs(u) {
            AccountToBlackListController ext = new AccountToBlackListController(sc);
            try {
                ext.addToBlackList();   
            }
            catch (SFDCAccessControlException e) {
                        System.assertNotEquals(e, null);
            }
        }
    }
    
    @isTest
    static void testValidPermissions() {
        Account acc = new Account (Name = 'Test Account');
        insert acc;
        
        ApexPages.StandardController sc = new ApexPages.standardController(acc);
            AccountToBlackListController ext = new AccountToBlackListController(sc);
        ext.addToBlackList();
        
        Account resAcc = [SELECT BlackList__c FROM Account WHERE Id = :acc.Id LIMIT 1];
        System.assertEquals(resAcc.BlackList__c, 'True');
    }
    
}