trigger CampaignMemberTrigger on CampaignMember (before insert) {

    /**
     * CPA transfer to Person Account
     * When somebody is added to the campaign as a customer (Person Account) we have a calculated CPA (Total CPA)
     * that is calculated at that time. Can we grab that CPA figure and put is on the Person Account record.
     * This field should be calculated once, either when they become a customer on a campaign or are added to a campaign
     * as a customer.
     * It should grab the Toal CPA calculated at that point in time and push it over to the Person Account customer field.
     * This will need a custom field to be created, this field is only updated once, i.e. when the person becomes a customer.
     */

    //if customer related to more than one campaign in one transaction/insert
    //in map campign id will be replaced with latest
    Map<Id, Id> customerIdToCampaignIdMap = new Map<Id, Id>();
    for (CampaignMember aCamapignMember : Trigger.new) {
        //added to a campaign as a customer.
        if (aCamapignMember.ContactId != null) {
            customerIdToCampaignIdMap.put(aCamapignMember.ContactId, aCamapignMember.CampaignId);
        }
    }

    //get Campaign cpa values
    Map<Id, Decimal> campaignIDToCPAMap = new Map<Id, Decimal>();
    List<Campaign> campaignsCPA = [SELECT Id, Total_CPA__c FROM Campaign WHERE Id IN :customerIdToCampaignIdMap.values()];
    for (Campaign aCampaign : campaignsCPA) {
        campaignIDToCPAMap.put(aCampaign.Id, aCampaign.Total_CPA__c);
    }

    //get customer which is not a campaign members already
    //this will work only in before insert context
    //in after there will be one CM for the customer

    List<Account> newCustomers = [
        SELECT Id, PersonContactId, Total_CPA__c
        FROM Account
        WHERE PersonContactId IN :customerIdToCampaignIdMap.keySet()
        AND PersonContactId NOT IN (
            SELECT ContactId
            FROM CampaignMember
            WHERE CampaignId IN :customerIdToCampaignIdMap.values())
    ];

    List<Account> customersToUpdate = new List<Account>();

    //transfer cpa value from campaign to account
    for (Account aNewCustomer : newCustomers) {
        if (customerIdToCampaignIdMap.containsKey(aNewCustomer.PersonContactId)) {
            Id campaignId = customerIdToCampaignIdMap.get(aNewCustomer.PersonContactId);
            if (campaignIDToCPAMap.containsKey(campaignId)) {
                Decimal cpaValue = campaignIDToCPAMap.get(campaignId);
                aNewCustomer.Total_CPA__c = cpaValue;
                customersToUpdate.add(aNewCustomer);
            }
        }
    }

    //dml
    if (!customersToUpdate.isEmpty()) {
        Database.update(customersToUpdate, false);
    }
}