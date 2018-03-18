public with sharing class AccountToBlackListController {

	public Account acc {get; set;}

	public AccountToBlackListController(ApexPages.StandardController stdController) {
		if (Schema.sObjectType.Account.isAccessible()) {
			acc = (Account)stdController.getRecord();
		}
		else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficient priveleges.'));
		}
	}

	public PageReference addToBlackList() {
		acc.BlackList__c = 'True';
		try {
			SFDCAccessController.UpdateWithoutSharing (
				acc,
				'AccountToBlackListController.cls [addToBlackList]',
				new List<Schema.DescribeFieldResult> {
					Account.BlackList__c.getDescribe()
				}
			);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

		PageReference redirectPage = new PageReference('/'+acc.Id);
		redirectPage.setRedirect(true);
		return redirectPage;
	}

}