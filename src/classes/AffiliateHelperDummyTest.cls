@isTest
private class AffiliateHelperDummyTest {

    @isTest
    static void test_affiliate_one() {
        String classInternalAf = 'ExtensionsHelperDummy.AffiliateHelperInnerClass';
        Type invokeClassTypeAf = Type.forName(ExtensionsHelperDummy.classInternalAf);
        ExtensionsHelperDummy.AffiliateHelperInnerClass affiliateInstance = (ExtensionsHelperDummy.AffiliateHelperInnerClass) invokeClassTypeAf.newInstance();

        Map<String, String> test = new Map<String, String> ();
        String result;
        result = (ExtensionsHelperDummy.setAffiliateOffer(test));
        result = (ExtensionsHelperDummy.getAffiliateOffers(test));
        result = (ExtensionsHelperDummy.getAffiliateOffer(test));
        result = (ExtensionsHelperDummy.setAffiliatePayout(test));
        result = (ExtensionsHelperDummy.setAffiliatePixel(test));
        result = (ExtensionsHelperDummy.setAffiliateOfferLink(test));
        result = (ExtensionsHelperDummy.deleteAffiliateOfferLink(test));
        result = (ExtensionsHelperDummy.deletePixel(test));
        result = (ExtensionsHelperDummy.getPixels(test));
        result = (ExtensionsHelperDummy.getPixel(test));
        result = (ExtensionsHelperDummy.getPayouts(test));
        result = (ExtensionsHelperDummy.getPayout(test));
        result = (ExtensionsHelperDummy.getAffiliateOfferLink(test));
        result = (ExtensionsHelperDummy.getCommissionsEarned(test));
        System.assertNotEquals(null, result);

        RecordType accRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer_Account' AND SobjectType = 'Account' AND IsPersonType = true AND IsActive = true LIMIT 1];
        Account accA = new Account(RecordTypeId = accRT.Id, LastName = 'AAccount', FirstName = 'First', PersonEmail = 'testA@gmail.com', Phone = '1234567890');
        insert accA;
        List<Map<String, Object>> testPayouts = ExtensionsHelperDummy.getPayoutsMechanisms(accA.id);
        System.assertNotEquals(null, testPayouts);

        Order__c order = new Order__c(Account__c = accA.Id, Charge_Amount__c = 1, Order_Source__c = 'Cart' );
        insert order;

        result = ExtensionsHelperDummy.createRefundCommissionsEarned(order.id);
        System.assertNotEquals(null, result);

        result = ExtensionsHelperDummy.createCommissionsEarned(order);
        System.assertNotEquals(null, result);

    }
    
    @isTest
    static void test_affiliate_two() {
        ExtensionsHelperDummy.AffiliateHelperInnerClass controller = new ExtensionsHelperDummy.AffiliateHelperInnerClass();
        String result;
        Map<String, String> test = new Map<String, String> ();

        result = controller.setAffiliateOfferRest(test);
        result = controller.getAffiliateOffersRest(test);
        result = controller.getAffiliateOfferRest(test);
        result = controller.setAffiliatePayoutRest(test);
        result = controller.setAffiliatePixelRest(test);
        result = controller.setAffiliateOfferLinkRest(test);
        result = controller.deleteAffiliateOfferLinkRest(test);
        result = controller.deletePixelRest(test);
        result = controller.getPixelsRest(test);
        result = controller.getPixelRest(test);
        result = controller.getPayoutsRest(test);
        result = controller.getPayoutRest(test);
        result = controller.getAffiliateOfferLinkRest(test);
        result = controller.getCommissionsEarnedRest(test);
        System.assertNotEquals(null, result);

        RecordType accRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer_Account' AND SobjectType = 'Account' AND IsPersonType = true AND IsActive = true LIMIT 1];
        Account accA = new Account(RecordTypeId = accRT.Id, LastName = 'AAccount', FirstName = 'First', PersonEmail = 'testA@gmail.com', Phone = '1234567890');
        insert accA;

        List<Map<String, Object>> testPayouts = controller.getPayoutsMechanismsForAccount(accA.Id);
        System.assertNotEquals(null, result);

        Order__c order = new Order__c(Account__c = accA.Id, Charge_Amount__c = 1, Order_Source__c = 'Cart' );
        insert order;

        result = controller.createRefundCommissions(order.id);
        System.assertNotEquals(null, result);

        result = controller.createCommissionsEarnedForAffiliate(order);
        System.assertNotEquals(null, result);

    } 

}