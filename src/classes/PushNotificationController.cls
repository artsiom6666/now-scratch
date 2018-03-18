public with sharing class PushNotificationController {

	static final String SEND_ENDPOINT = 'https://fcm.googleapis.com/fcm/send';
	static final String ADD_TOPIC_ENDPOINT = 'https://iid.googleapis.com/iid/v1:batchAdd';
	static final String RM_TOPIC_ENDPOINT = 'https://iid.googleapis.com/iid/v1:batchRemove';

	@auraEnabled
	public static String getAccountsApex(String topicId, String environmentName, String recordId) {
		RecordType recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		List<Account> accounts = new List<Account>();
		String query = 'SELECT Id, Name, Notification_Token__c, Mobile_Customer_Notification_Token__c FROM Account WHERE RecordTypeId = \'' + recType.Id + '\'';

		if (String.isNotBlank(recordId)) {
			query += ' AND Id = :recordId';
		}
		else {
			if (String.isBlank(environmentName)) {
				query += ' AND (Notification_Token__c != null OR Mobile_Customer_Notification_Token__c != null)';
			}
			else if (environmentName.containsIgnoreCase('site')) {
				query += ' AND Notification_Token__c != null';
			}
			else if (environmentName.containsIgnoreCase('mobile')) {
				query += ' AND Mobile_Customer_Notification_Token__c != null';
			}
		}

		if (String.isNotBlank(topicId) && topicId != 'null') {
			Set<Id> accountIds = new Set<Id>();
			
			for (Push_Notification_Topic_Junction__c junction : [
				SELECT Id, Push_Notification_Topic__c, Account__c
				FROM Push_Notification_Topic_Junction__c
				WHERE Push_Notification_Topic__c = :topicId
			]) {
				accountIds.add(junction.Account__c);
			}
			query += ' AND Id IN :accountIds';
		}

		accounts = Database.query(query);

		List<PicklistOption> accountOptions = new List<PicklistOption>();

		for (Account acc : accounts) {
			PicklistOption accOpt = new PicklistOption();
			accOpt.label = acc.Name;
			accOpt.value = acc.Id;
			accountOptions.add(accOpt);
		}

		return JSON.serialize(accountOptions);
	}

	@auraEnabled
	public static String getTopicsApex() {

		List<Push_Notification_Topic__c> topics = [
			SELECT Id, Name, Title__c, Body__c
			FROM Push_Notification_Topic__c
		];

		List<PicklistOption> topicOptions = new List<PicklistOption>();

		for (Push_Notification_Topic__c topic : topics) {
			PicklistOption option = new PicklistOption();
			option.label = topic.Title__c;
			option.value = topic.Id;
			topicOptions.add(option);
		}

		return JSON.serialize(topicOptions);
	}

	@auraEnabled
	public static String getTopicsInfoApex(String topicId) {

		Push_Notification_Topic__c topic = [
			SELECT Id, Name, Body__c, Title__c, Click_Action__c, Image__c, Device_Type__c
			FROM Push_Notification_Topic__c
			WHERE Id = :topicId
			LIMIT 1
		];

		TopicInfo topicWrap = new TopicInfo();
		topicWrap.title = topic.Title__c;
		topicWrap.body = topic.Body__c;
		topicWrap.clickAction = topic.Click_Action__c;
		topicWrap.icon = topic.Image__c;

		return JSON.serialize(topicWrap);
	}

	@auraEnabled
	public static String getEnvironmentsApex() {
		List<Map<String, String>> notificationEnvironmentSettings = TouchCRHelper.getCustomSettings('TouchCRBase__Notification_Environment__c');

		List<PicklistOption> options = new List<PicklistOption>();
		for (Map<String, String> notificationEnvironmentSetting : notificationEnvironmentSettings) {
			PicklistOption option = new PicklistOption();
			option.value = notificationEnvironmentSetting.get('Key__c');
			option.label = notificationEnvironmentSetting.get('Name');
			options.add(option);

		}

		return JSON.serialize(options);
	}

	@auraEnabled
	public static String getIconsApex() {

		List<Document> documents = [SELECT Id, Name FROM Document WHERE Folder.Name LIKE '%Push%'];
		if (Test.isRunningTest()) {
			documents = [SELECT Id, Name FROM Document WHERE Name LIKE '%Test%'];
		}

		List<PicklistOption> iconOptions = new List<PicklistOption>();

		for (Document documentItem : documents) {
			PicklistOption option = new PicklistOption();
			option.label = documentItem.Name;
			option.value = documentItem.Id;
			iconOptions.add(option);
		}

		return JSON.serialize(iconOptions);
	}

	@auraEnabled
	public static String getClickActionsApex() {

		List<Map<String, String>> clickActionSettings = TouchCRHelper.getCustomSettings('TouchCRBase__Notification_Click_Action__c');

		List<PicklistOption> options = new List<PicklistOption>();

		for (Map<String, String> clickActionSetting : clickActionSettings) {
			PicklistOption option = new PicklistOption();
			option.value = clickActionSetting.get('Link__c');
			option.label = clickActionSetting.get('Name');
			options.add(option);
		}

		return JSON.serialize(options);
	}

	@auraEnabled
	public static String saveClickActionApex(String name, String link) {

		Notification_Click_Action__c clickActionSetting = new Notification_Click_Action__c();
		clickActionSetting.Name = name;
		clickActionSetting.Link__c = link;
		insert clickActionSetting;

		return 'Click Action has been successfuly added!';
	}

	@auraEnabled
	public static String sendNotification(String recipients, String title, String icon, String clickAction, String body, String topicName, String environments) {
		String result = '';
		List<PicklistOption> environmentsDeserialized = (List<PicklistOption>)JSON.deserialize(environments, List<PicklistOption>.class);
		if (String.isBlank(topicName)) {
			List<String> recipientsDeserialized = (List<String>)JSON.deserialize(recipients, List<String>.class);
			List<Account> accounts = getRecipients(recipientsDeserialized);

			for (PicklistOption environment : environmentsDeserialized) {
				List<String> recipientsToken = getRecipientsToken(environment.label, accounts);
				String requestBody = createNotificationBody(recipientsToken, title, icon, clickAction, body);
				result = sendNotificationHandler(environment.value, requestBody);
			}
		} else {
			for (PicklistOption environment : environmentsDeserialized) {
				String requestBody = createNotificationBody(topicName.replaceAll(' ','')
						+ environment.label.replaceAll(' ',''), title, icon, clickAction, body);
				result = sendNotificationHandler(environment.value, requestBody);
			}
		}

		return result;
	}

	private static String sendNotificationHandler(String environmentKey, String requestBody) {
		try {
			HTTPResponse response = makeRequest(SEND_ENDPOINT, environmentKey, requestBody);

			if (response.getStatusCode() == 200 && !response.getBody().contains('error')) {
				return 'The push notifications have been successfully sended!';
			}
			else {
				return response.getStatus() + ': ' + response.getBody();
			}
		}
		catch (Exception e) {
			return e.getMessage();
		}
	}

	@auraEnabled
	public static String createTopic(String environmentsSerialized, List<String> recipientsIds, String topicName, String title, String icon, String clickAction, String body) {
		List<PicklistOption> environments = (List<PicklistOption>)JSON.deserialize(environmentsSerialized, List<PicklistOption>.class);
		try {
			List<Account> recipients = getRecipients(recipientsIds);

			List<Push_Notification_Topic__c> newTopics = new List<Push_Notification_Topic__c>();
			for (PicklistOption environment : environments) {
				List<String> recipientsToken = getRecipientsToken(environment.label, recipients);

				String requestBody = createTopicBody(recipientsToken,
								topicName.replaceAll(' ','') + environment.label.replaceAll(' ',''));

				HTTPResponse response = makeRequest(ADD_TOPIC_ENDPOINT, environment.value, requestBody);
			}

			Push_Notification_Topic__c topic = new Push_Notification_Topic__c(
					Title__c = title,
					Body__c = body,
					Image__c = icon,
					Click_Action__c = clickAction,
					Name = title
			);
			newTopics.add(topic);

			insert newTopics;

			List<Push_Notification_Topic_Junction__c> junctions = new List<Push_Notification_Topic_Junction__c>();

			for (Account acc : recipients) {
				Push_Notification_Topic_Junction__c junction = new Push_Notification_Topic_Junction__c(
						Push_Notification_Topic__c = topic.Id,
						Account__c = acc.Id
				);
				junctions.add(junction);
			}

			insert junctions;
			return topic.Id;
		}
		catch (Exception e) {
			return e.getMessage();
		}
	}

	@auraEnabled
	public static String deleteTopic(String environmentsSerialized, List<String> recipientsIds, String topicName, String topicId) {
		List<PicklistOption> environments = (List<PicklistOption>)JSON.deserialize(environmentsSerialized, List<PicklistOption>.class);

		try {
			List<Account> recipients = getRecipients(recipientsIds);

			for (PicklistOption environment : environments) {
				List<String> recipientsToken = getRecipientsToken(environment.label, recipients);

				String requestBody = createTopicBody(recipientsToken,
								topicName.replaceAll(' ','') + environment.label.replaceAll(' ',''));
				HTTPResponse response = makeRequest(RM_TOPIC_ENDPOINT, environment.value, requestBody);
			}

			Push_Notification_Topic__c topic = new Push_Notification_Topic__c(
					Id = topicId
			);

			delete topic;
			return 'Success';
		}
		catch (Exception e) {
			return e.getMessage();
		}
	}

	private static HTTPResponse makeRequest(String endpoint, String environmentKey, String requestBody) {

		HttpRequest request = new HttpRequest();
		request.setEndpoint(endpoint);
		request.setTimeout(120000);
		request.setMethod('POST');

		request.setBody(requestBody);

		request.setHeader('Authorization', 'key=' + environmentKey);
		request.setHeader('Content-Type', 'application/json');
		request.setHeader('Content-Length', String.valueOf(requestBody.length()));

		Http binding = new Http();

		return binding.send(request);
	}

	private static List<Account> getRecipients(List<String> recipientsIds) {
		List<Account> recipients = new List<Account>();
		if (recipientsIds.size() < 1) {
			recipients = [
				SELECT Id, Name, Notification_Token__c, Mobile_Customer_Notification_Token__c
				FROM Account
				WHERE Notification_Token__c != null OR Mobile_Customer_Notification_Token__c != null
			];
		}
		else {

			recipients = [
				SELECT Id, Name, Notification_Token__c, Mobile_Customer_Notification_Token__c
				FROM Account
				WHERE Id IN :recipientsIds
			];
		}
		return recipients;
	}

	private static List<String> getRecipientsToken(String environmentLabel, List<Account> recipients) {
		List<String> recipientsToken = new List<String>();

		for (Account acc : recipients) {
			if (environmentLabel.containsIgnoreCase('mobile')) {
				if (String.isBlank(acc.Mobile_Customer_Notification_Token__c)) {
					continue;
				}
				recipientsToken.add(acc.Mobile_Customer_Notification_Token__c);
			} else {
				if (String.isBlank(acc.Notification_Token__c)) {
					continue;
				}
				recipientsToken.add(acc.Notification_Token__c);
			}

		}
		return recipientsToken;
	}

	private static String createNotificationBody(List<String> recipients, String title, String icon, String clickAction, String body) {
		Notification requestBody = new Notification();
		requestBody.notification = new NotificationBody();
		requestBody.notification.title = title;
		requestBody.notification.body = body;
		requestBody.notification.icon =
				System.Url.getSalesforceBaseURL().toExternalForm()  + '/servlet/servlet.FileDownload?file=' + icon;
		requestBody.notification.click_action = clickAction;
		requestBody.registration_ids = recipients;

		return JSON.serialize(requestBody);
	}

	private static String createNotificationBody(String topic, String title, String icon, String clickAction, String body) {
		NotificationTopic requestBody = new NotificationTopic();
		requestBody.notification = new NotificationBody();
		requestBody.notification.title = title;
		requestBody.notification.body = body;
		requestBody.notification.icon =
				System.Url.getSalesforceBaseURL().toExternalForm()  + '/servlet/servlet.FileDownload?file=' + icon;
		requestBody.notification.click_action = clickAction;
		requestBody.to = '/topics/' + topic;

		return JSON.serialize(requestBody);
	}

	private static String createTopicBody(List<String> recipients, String topicName) {
		Topic requestBody = new Topic();
		requestBody.registration_tokens = recipients;
		requestBody.to = '/topics/' + topicName;

		return JSON.serialize(requestBody);
	}

	public class PicklistOption {
		public String label { get; set; }
		public String value { get; set; }
	}

	public class TopicInfo {
		public String title { get; set; }
		public String body { get; set; }
		public String clickAction { get; set; }
		public String icon { get; set; }
	}

	public class Notification {
		public NotificationBody notification { get; set; }
		public List<String> registration_ids { get; set; }
	}

	public class NotificationTopic {
		public NotificationBody notification { get; set; }
		public String to { get; set; }
	}

	public class NotificationBody {
		public String title { get; set; }
		public String body { get; set; }
		public String icon { get; set; }
		public String click_action { get; set; }
	}

	public class Topic {
		public String to { get; set; }
		public List<String> registration_tokens { get; set; }
	}

}