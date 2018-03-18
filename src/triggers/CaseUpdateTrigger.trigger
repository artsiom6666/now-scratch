trigger CaseUpdateTrigger on Case (before insert) {

    /* fill the case Account/Contact info from order*/
    Set<Id> orderIds = new Set<Id>();
    for (Case caseItem : Trigger.new) {
        if (caseItem.Order__c != NULL) {
            orderIds.add(caseItem.Order__c);
        }
    }

    Map<Id, Order__c> ordersMap = new Map <Id, Order__c>([
        SELECT Id, Account__c, Account__r.PersonContactId
        FROM Order__c
        WHERE Id IN :orderIds
        AND Account__c != NULL
        AND Account__r.IsPersonAccount = true
    ]);

    for (Case caseItem : Trigger.new) {
        if (caseItem.Order__c != NULL) {
            Order__c relatedOrder = ordersMap.get(caseItem.Order__c);
            if (relatedOrder != NULL) {
                if (caseItem.AccountId == NULL) {
                    caseItem.AccountId = relatedOrder.Account__c;
                }
                if (caseItem.ContactId == NULL) {
                    caseItem.ContactId = relatedOrder.Account__r.PersonContactId;
                }
            }
        }
    }

    /* fill the case sequence by the number of previous created cases with the same reson */

    Map<Id,Map<String,Integer>> mapCasesByOrder = new Map<Id,Map<String,Integer>>();
    for (Case caseItem : Trigger.new) {
        if (caseItem.Order__c != NULL) {
            if (mapCasesByOrder.containsKey(caseItem.Order__c) == false) {
                mapCasesByOrder.put(caseItem.Order__c, new Map<String,Integer>());
            }
            Map<String,Integer> mapCasesByTypeReson = mapCasesByOrder.get(caseItem.Order__c);
            String key = caseItem.Type + caseItem.Reason_Case__c;
            Integer casesCount = (mapCasesByTypeReson.containsKey(key)) ? mapCasesByTypeReson.get(key) + 1 : 1;
            mapCasesByTypeReson.put(key, casesCount);
        }
    }

    List<Case> casesList = [
        SELECT Id, Order__c, Type, Reason_Case__c
        FROM Case
        WHERE Order__c IN :mapCasesByOrder.keySet()
    ];

    for (Case caseItem : casesList) {
        if (mapCasesByOrder.containsKey(caseItem.Order__c) == false) {
            mapCasesByOrder.put(caseItem.Order__c, new Map<String,Integer>());
        }
        Map<String,Integer> mapCasesByTypeReson = mapCasesByOrder.get(caseItem.Order__c);
        String key = caseItem.Type + caseItem.Reason_Case__c;
        Integer casesCount = (mapCasesByTypeReson.containsKey(key)) ? mapCasesByTypeReson.get(key) + 1 : 1;
        mapCasesByTypeReson.put(key, casesCount);
    }

    for (Case caseItem : Trigger.new) {
        if (caseItem.Order__c != NULL) {
            Map<String,Integer> mapCasesByTypeReson = mapCasesByOrder.get(caseItem.Order__c);
            String key = caseItem.Type + caseItem.Reason_Case__c;
            Integer casesCount = mapCasesByTypeReson.get(key);
            caseItem.Case_Sequence__c = casesCount;
            mapCasesByTypeReson.put(key, casesCount - 1);
        }
    }

}