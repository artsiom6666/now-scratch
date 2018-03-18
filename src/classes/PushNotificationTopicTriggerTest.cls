@isTest
private class PushNotificationTopicTriggerTest {
	static testMethod void getAccountsByIdTest() {
		RecordType recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account acc = new Account(
				FirstName = 'Test',
				LastName = 'User',
				Notification_Token__c = 'Notification_Token__c',
				Mobile_Customer_Notification_Token__c = 'Mobile_Customer_Notification_Token__c',
				RecordTypeId = recType.Id
		);
		insert acc;

		Push_Notification_Topic__c topic = new Push_Notification_Topic__c(
				Title__c = 'title',
				Body__c = 'body',
				Image__c = 'icon',
				Click_Action__c = 'clickAction',
				Name = 'title'
		);
		insert topic;

		Push_Notification_Topic_Junction__c junction = new Push_Notification_Topic_Junction__c(
				Push_Notification_Topic__c = topic.Id,
				Account__c = acc.Id
		);
		insert junction;

		Test.startTest();
		delete topic;
		Test.stopTest();

		List<Push_Notification_Topic_Junction__c> junctions = [
			SELECT Id, Push_Notification_Topic__c, Account__c
			FROM Push_Notification_Topic_Junction__c
			WHERE Push_Notification_Topic__c = :topic.Id
		];

		System.assertEquals(0, junctions.size());
	}
}