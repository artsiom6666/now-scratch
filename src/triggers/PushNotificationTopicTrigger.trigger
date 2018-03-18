trigger PushNotificationTopicTrigger on Push_Notification_Topic__c (before delete) {
	Set<Id> removedTopics = new Set<Id>();

	for (Push_Notification_Topic__c topic : Trigger.old) {
		//add Id of deleted topics
		removedTopics.add(topic.Id);
	}

	//search for all dependent items
	List<Push_Notification_Topic_Junction__c> topicJunctions = [
		SELECT Id
		FROM Push_Notification_Topic_Junction__c
		WHERE Push_Notification_Topic__c IN: removedTopics
	];

	delete topicJunctions;

}