public with sharing class SubscriptionPaymentAttemptBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    private Date daySubscription;

    public SubscriptionPaymentAttemptBatch(Date daySubscription) {
        this.daySubscription = daySubscription;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Order__c, Order__r.Account__c, Date__c, Retries_Interval__c, Status__c, Amount__c, (SELECT Id, Response_Status__c, Payment_Date__c FROM Payment_Attempt__c.Transactions__r ORDER BY Payment_Date__c DESC) ' +
                        'FROM Payment_Attempt__c ' +
                        'WHERE Status__c = \'Retry\' OR Date__c = ' + String.valueOf(this.daySubscription);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        if (scope.size() > 0) {
            Payment_Attempt__c paymentAttempt = (Payment_Attempt__c)scope[0];
            List<Order_Transaction__c> existingTransactions = paymentAttempt.Transactions__r;

            Date paymentDate;

            if (!existingTransactions.isEmpty()) {
                if (paymentAttempt.Status__c == 'Retry') {
                    Date dateLastTransaction = Date.valueOf(existingTransactions[0].Payment_Date__c);
                    paymentDate = dateLastTransaction.addDays(Integer.valueOf(paymentAttempt.Retries_Interval__c));
                }
                else if (paymentAttempt.Status__c == 'Scheduled') {
                    paymentDate = null;
                }
            } else {
                paymentDate = paymentAttempt.Date__c;
            }

            if (paymentDate == this.daySubscription) {
                Map<String,Object> result = PaymentProcessor.doPayment(
                    new Map<String,Object>{
                        'Method' => 'Charge',
                        'Account' => Id.valueOf(paymentAttempt.Order__r.Account__c),
                        'PaymentAttempt' => Id.valueOf(paymentAttempt.Id)
                    }
                );
            }

        }
    }

    public void finish(Database.BatchableContext BC) {
    }
}