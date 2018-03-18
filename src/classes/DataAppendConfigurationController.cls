public with sharing class DataAppendConfigurationController {

    public String itemId { get; set; }
    public String result{ get; set; }

    public DataAppendConfigurationController(ApexPages.StandardController stdController) {
        if (stdController.getRecord().getSObjectType() == Schema.Account.getSObjectType()) {
            if (Schema.sObjectType.Account.isAccessible()) {
                itemId = stdController.getId();
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficient priveleges.'));
            }
        }

        if (stdController.getRecord().getSObjectType() == Schema.Lead.getSObjectType()) {
            if (Schema.sObjectType.Lead.isAccessible()) {
                itemId = stdController.getId();
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficient priveleges.'));
            }
        }
    }

    public PageReference startDataAppend() {
        result = DataAppendSingle.doAppend(itemId);
        PageReference redirectPage = new PageReference('/' + itemId);
        redirectPage.setRedirect(true);
        return redirectPage;
    }
}