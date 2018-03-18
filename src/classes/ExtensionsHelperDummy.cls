global with sharing class ExtensionsHelperDummy {

    //AffiliateHelperDummy
    global interface AffiliateInterface {
        String createCommissionsEarnedForAffiliate (TouchCRBase__Order__c order);
        String createRefundCommissions (Id orderId);

        String setAffiliateOfferRest (Map<String, String> generalData);
        String getAffiliateOffersRest (Map<String, String> params);
        String getAffiliateOfferRest (Map<String, String> params);
        String setAffiliatePayoutRest (Map<String, String> generalData);
        String setAffiliatePixelRest (Map<String, String> generalData);
        String setAffiliateOfferLinkRest (Map<String, String> generalData);
        String deleteAffiliateOfferLinkRest (Map<String, String> generalData);
        String deletePixelRest (Map<String, String> generalData);
        String getPixelsRest (Map<String, String> generalData);
        String getPixelRest (Map<String, String> generalData);
        String getPayoutsRest (Map<String, String> generalData);
        String getPayoutRest (Map<String, String> generalData);
        String getAffiliateOfferLinkRest (Map<String, String> generalData);
        String getCommissionsEarnedRest (Map<String, String> generalData);

        List<Map<String, Object>> getPayoutsMechanismsForAccount (Id accountId);
    }

    public class AffiliateHelperInnerClass implements AffiliateInterface {

        public String createCommissionsEarnedForAffiliate (Order__c order) {
            return 'error';
        }

        public String createRefundCommissions (Id orderId) {
            return 'error';
        }

        public String setAffiliateOfferRest(Map<String, String> generalData) {
            return 'error';
        }

        public String getAffiliateOffersRest(Map<String, String> params) {
            return 'error';
        }

        public String getAffiliateOfferRest(Map<String, String> params) {
            return 'error';
        }

        public String setAffiliatePayoutRest(Map<String, String> generalData) {
            return 'error';
        }

        public String setAffiliatePixelRest(Map<String, String> generalData) {
            return 'error';
        }

        public String setAffiliateOfferLinkRest(Map<String, String> generalData) {
            return 'error';
        }

        public String deleteAffiliateOfferLinkRest(Map<String, String> generalData) {
            return 'error';
        }

        public String deletePixelRest(Map<String, String> generalData) {
            return 'error';
        }

        public String getPixelsRest(Map<String, String> generalData) {
            return 'error';
        }

        public String getPixelRest(Map<String, String> generalData) {
            return 'error';
        }

        public String getPayoutsRest(Map<String, String> generalData) {
            return 'error';
        }

        public String getPayoutRest(Map<String, String> generalData) {
            return 'error';
        }

        public String getAffiliateOfferLinkRest(Map<String, String> generalData) {
            return 'error';
        }

        public String getCommissionsEarnedRest(Map<String, String> generalData) {
            return 'error';
        }

        public List<Map<String, Object>> getPayoutsMechanismsForAccount (Id accountId) {
            return new List<Map<String, Object>>();
        }

    }

    public static String classExternalAf = 'AffiliateHelper.AffiliateHelperInnerClass';
    public static String classInternalAf = 'ExtensionsHelperDummy.AffiliateHelperInnerClass';
    public static Type invokeClassTypeAf = TouchCRHelper.isAffiliateEnabled() ? Type.forName(ExtensionsHelperDummy.classExternalAf) : Type.forName(ExtensionsHelperDummy.classInternalAf);

    public static String createCommissionsEarned (Order__c order){
        AffiliateInterface AffiliateHelperInstance = (AffiliateInterface) ExtensionsHelperDummy.invokeClassTypeAf.newInstance();
        return AffiliateHelperInstance.createCommissionsEarnedForAffiliate(order);
    }

    public static String createRefundCommissionsEarned (Id orderId) {
        AffiliateInterface AffiliateHelperInstance = (AffiliateInterface) ExtensionsHelperDummy.invokeClassTypeAf.newInstance();
        return AffiliateHelperInstance.createRefundCommissions(orderId);
    }

    public static String setAffiliateOffer(Map<String, String> generalData) {
        AffiliateInterface AffiliateHelperInstance = (AffiliateInterface) ExtensionsHelperDummy.invokeClassTypeAf.newInstance();
        return AffiliateHelperInstance.setAffiliateOfferRest(generalData);
    }

    public static String getAffiliateOffers(Map<String, String> params) {
        AffiliateInterface AffiliateHelperInstance = (AffiliateInterface) ExtensionsHelperDummy.invokeClassTypeAf.newInstance();
        return AffiliateHelperInstance.getAffiliateOffersRest(params);
    }

    public static String getAffiliateOffer(Map<String, String> params) {
        AffiliateInterface AffiliateHelperInstance = (AffiliateInterface) ExtensionsHelperDummy.invokeClassTypeAf.newInstance();
        return AffiliateHelperInstance.getAffiliateOfferRest(params);
    }

    public static String setAffiliatePayout(Map<String, String> generalData) {
        AffiliateInterface AffiliateHelperInstance = (AffiliateInterface) ExtensionsHelperDummy.invokeClassTypeAf.newInstance();
        return AffiliateHelperInstance.setAffiliatePayoutRest(generalData);
    }

    public static String setAffiliatePixel(Map<String, String> generalData) {
        AffiliateInterface AffiliateHelperInstance = (AffiliateInterface) ExtensionsHelperDummy.invokeClassTypeAf.newInstance();
        return AffiliateHelperInstance.setAffiliatePixelRest(generalData);
    }

    public static String setAffiliateOfferLink(Map<String, String> generalData) {
        AffiliateInterface AffiliateHelperInstance = (AffiliateInterface) ExtensionsHelperDummy.invokeClassTypeAf.newInstance();
        return AffiliateHelperInstance.setAffiliateOfferLinkRest(generalData);
    }

    public static String deleteAffiliateOfferLink(Map<String, String> generalData) {
        AffiliateInterface AffiliateHelperInstance = (AffiliateInterface) ExtensionsHelperDummy.invokeClassTypeAf.newInstance();
        return AffiliateHelperInstance.deleteAffiliateOfferLinkRest(generalData);
    }

    public static String deletePixel(Map<String, String> generalData) {
        AffiliateInterface AffiliateHelperInstance = (AffiliateInterface) ExtensionsHelperDummy.invokeClassTypeAf.newInstance();
        return AffiliateHelperInstance.deletePixelRest(generalData);
    }

    public static String getPixels(Map<String, String> generalData) {
        AffiliateInterface AffiliateHelperInstance = (AffiliateInterface) ExtensionsHelperDummy.invokeClassTypeAf.newInstance();
        return AffiliateHelperInstance.getPixelsRest(generalData);
    }

    public static String getPixel(Map<String, String> generalData) {
        AffiliateInterface AffiliateHelperInstance = (AffiliateInterface) ExtensionsHelperDummy.invokeClassTypeAf.newInstance();
        return AffiliateHelperInstance.getPixelRest(generalData);
    }

    public static String getPayouts(Map<String, String> generalData) {
        AffiliateInterface AffiliateHelperInstance = (AffiliateInterface) ExtensionsHelperDummy.invokeClassTypeAf.newInstance();
        return AffiliateHelperInstance.getPayoutsRest(generalData);
    }

    public static String getPayout(Map<String, String> generalData) {
        AffiliateInterface AffiliateHelperInstance = (AffiliateInterface) ExtensionsHelperDummy.invokeClassTypeAf.newInstance();
        return AffiliateHelperInstance.getPayoutRest(generalData);
    }

    public static String getAffiliateOfferLink(Map<String, String> generalData) {
        AffiliateInterface AffiliateHelperInstance = (AffiliateInterface) ExtensionsHelperDummy.invokeClassTypeAf.newInstance();
        return AffiliateHelperInstance.getAffiliateOfferLinkRest(generalData);
    }

    public static String getCommissionsEarned(Map<String, String> generalData) {
        AffiliateInterface AffiliateHelperInstance = (AffiliateInterface) ExtensionsHelperDummy.invokeClassTypeAf.newInstance();
        return AffiliateHelperInstance.getCommissionsEarnedRest(generalData);
    }

    public static List<Map<String, Object>> getPayoutsMechanisms(Id accountId) {
        AffiliateInterface AffiliateHelperInstance = (AffiliateInterface) ExtensionsHelperDummy.invokeClassTypeAf.newInstance();
        return AffiliateHelperInstance.getPayoutsMechanismsForAccount(accountId);
    }



    //FranchiseeHelperDummy
    global interface FranchiseeInterface {
        String setFranchiseeRest (Map<String, String> generalData);
        String getFranchiseeRest (Map<String, String> generalData);
        String getFranchiseeInfoRest (Map<String, String> generalData);
        String getFranchiseeForTerritoryRest (Map<String, String> generalData);

        String getPaymentConnectSettingsExt ();
        String saveStripeConnectExt (String settings);

    }
    public class FranchiseeHelperInnerClass implements FranchiseeInterface {

        public String setFranchiseeRest(Map<String, String> generalData) {
            return '';
        }

        public String getFranchiseeRest(Map<String, String> generalData) {
            return '';
        }

        public String getFranchiseeInfoRest(Map<String, String> generalData) {
            return '';
        }

        public String getFranchiseeForTerritoryRest(Map<String, String> generalData) {
            return '';
        }

        public String getPaymentConnectSettingsExt() {
            return '{"paymentAgentId":null}';
        }

        public String saveStripeConnectExt(String settings) {
            return 'Organization has been successfully saved!';
        }

    }

    public static String classExternalFr = 'FranchiseeHelper.FranchiseeHelperInnerClass';
    public static String classInternalFr = 'ExtensionsHelperDummy.FranchiseeHelperInnerClass';
    public static Type invokeClassTypeFr = TouchCRHelper.isFranchiseeEnabled() ? Type.forName(ExtensionsHelperDummy.classExternalFr) : Type.forName(ExtensionsHelperDummy.classInternalFr);

    public static String setFranchisee(Map<String, String> generalData) {
        FranchiseeInterface FranchiseeHelperInstance = (FranchiseeInterface) ExtensionsHelperDummy.invokeClassTypeFr.newInstance();
        return FranchiseeHelperInstance.setFranchiseeRest(generalData);
    }

    public static String getFranchisee(Map<String, String> generalData) {
        FranchiseeInterface FranchiseeHelperInstance = (FranchiseeInterface) ExtensionsHelperDummy.invokeClassTypeFr.newInstance();
        return FranchiseeHelperInstance.getFranchiseeRest(generalData);
    }

    public static String getFranchiseeInfo(Map<String, String> generalData) {
        FranchiseeInterface FranchiseeHelperInstance = (FranchiseeInterface) ExtensionsHelperDummy.invokeClassTypeFr.newInstance();
        return FranchiseeHelperInstance.getFranchiseeInfoRest(generalData);
    }

    public static String getFranchiseeForTerritory(Map<String, String> generalData) {
        FranchiseeInterface FranchiseeHelperInstance = (FranchiseeInterface) ExtensionsHelperDummy.invokeClassTypeFr.newInstance();
        return FranchiseeHelperInstance.getFranchiseeForTerritoryRest(generalData);
    }

    global static String getPaymentConnectSettings() {
        FranchiseeInterface FranchiseeHelperInstance = (FranchiseeInterface) ExtensionsHelperDummy.invokeClassTypeFr.newInstance();
        return FranchiseeHelperInstance.getPaymentConnectSettingsExt();
    }

    global static String saveStripeConnect(String settings) {
        FranchiseeInterface FranchiseeHelperInstance = (FranchiseeInterface) ExtensionsHelperDummy.invokeClassTypeFr.newInstance();
        return FranchiseeHelperInstance.saveStripeConnectExt(settings);
    }
}