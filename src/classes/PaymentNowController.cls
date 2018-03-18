public with sharing class PaymentNowController {

    public Payment_Attempt__c paymentAttempt { get; set; }

    public PaymentNowController(ApexPages.StandardController stdController) {
        if (Schema.sObjectType.Payment_Attempt__c.isAccessible()) {
            paymentAttempt = (Payment_Attempt__c)stdController.getRecord();
        }
    }

    public PageReference payNow() {
        Map<String,Object> result = PaymentProcessor.doPayment(
            new Map<String,Object>{
                'Method' => 'Charge',
                'PaymentAttempt' => paymentAttempt.Id
            }
        );

        PageReference redirectPage = new PageReference('/' + result.get('Transaction'));
        redirectPage.setRedirect(true);
        return redirectPage;
    }
}