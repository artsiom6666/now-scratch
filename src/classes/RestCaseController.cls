public with sharing class RestCaseController {

	public static String setCase(Map<String, String> generalData) {
		try {
			Id orderId = generalData.containsKey('orderId') ? generalData.get('orderId') : null;
			Id customerId = generalData.containsKey('customerId') ? generalData.get('customerId') : null;
			String priority = generalData.containsKey('priority') ? generalData.get('priority') : null;
			String recordTypeName = generalData.containsKey('recordTypeName') ? generalData.get('recordTypeName') : null;
			String caseType = generalData.containsKey('type') ? generalData.get('type') : null;

			Case newCase = new Case();

			newCase.Order__c = orderId;
			newCase.AccountId = customerId;
			newCase.Priority = priority;
			newCase.Type = caseType;
		
			try {
				SFDCAccessController.InsertWithoutSharing (
					newCase,
					'RestCaseController.cls [setCase]',
					new List<Schema.DescribeFieldResult> {
						Case.Order__c.getDescribe(), Case.AccountId.getDescribe(),
						Case.Priority.getDescribe(), Case.Type.getDescribe()
					}
				);

			} catch (SFDCAccessControlException e) { return  '{"error":"' + e.ExceptionMessage + '","message":"error"}'; }


			return  '{"caseId":"' + newCase.Id + '","message":"success"}';
		} catch (Exception e) {
			return  '{"error":"' + e.getMessage() + '","message":"error"}';
		}
	}
}