trigger OrderTrigger on Order__c (before delete, before insert, before update, after delete, after insert, after undelete, after update) {

	TouchCR_Settings__c settings = TouchCR_Settings__c.getValues('Chargent.OrderUserCreation');
	Boolean isUserCreationEnabled = false;
	if (settings != null) {
		isUserCreationEnabled = Boolean.valueOf(settings.Value__c);
	}

	Set<Id> accountsToRecalculateIds = new Set<Id>();

	if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {
		for (Order__c order : Trigger.new) {
			if (order.Account__c != null) {
				accountsToRecalculateIds.add(order.Account__c);
			}
		}
	}

	if (Trigger.isAfter && Trigger.isDelete) {
		for (Order__c order : Trigger.old) {
			if (order.Account__c != null)
				accountsToRecalculateIds.add(order.Account__c);
		}
	}

	if (Trigger.isBefore && Trigger.isDelete) {
		List<OrderItem__c> orderItems = [SELECT Id FROM OrderItem__c WHERE Order__c IN :Trigger.old];
		delete orderItems;
	}

	if (accountsToRecalculateIds.size() > 0) {
		List<Order__c> allRelatedOrders = [
			SELECT Id, OwnerId, CreatedDate, Account__c, Balance_Due__c, Total__c, Date__c
			FROM Order__c
			WHERE Account__c IN :accountsToRecalculateIds
			LIMIT 50000
		];

		Map<Id, Account> accountsToRecalculateMap = new Map<Id, Account>([
			SELECT Id, PersonContactId, PersonEmail, FirstName, LastName, RecordTypeId, Subtotal_From_Zero_Balance_Orders__c, Brand_Assortment__c
			FROM Account
			WHERE Id IN :accountsToRecalculateIds
			LIMIT 50000
		]);

		Map<Id, List<Order__c>> accountOrdersMap = new Map<Id, List<Order__c>>();

		for (Order__c order : allRelatedOrders) {
			if (accountOrdersMap.containsKey(order.Account__c)) {
				accountOrdersMap.get(order.Account__c).add(order);
			}
			else {
				accountOrdersMap.put(order.Account__c, new List<Order__c>());
				accountOrdersMap.get(order.Account__c).add(order);
			}
		}

		//AddOrderUsersOpt create a new user
		if (Trigger.isAfter && Trigger.isInsert && isUserCreationEnabled) {
			List<User> usersList = new List<User>([
				SELECT id, Username, FirstName, LastName
				FROM User
				WHERE AccountId IN :accountsToRecalculateIds
			]
			);
			List<User> usersToinsert = new List<User>();

			RecordType rec = [SELECT Id, Name FROM RecordType WHERE Name = 'Customer Account' LIMIT 1];
			User owner = [SELECT Id, Email, Username, Lastname FROM User WHERE Id = :UserInfo.getUserId()];
			Map<String, String> brandToProfileIdMap = TouchCRConfigurationController.getBrandToProfileId();
			String accinfo;

			for (Id acc : accountOrdersMap.keySet()) {
				Account currentAccount = accountsToRecalculateMap.get(acc);
				if (currentAccount != Null && currentAccount.RecordTypeId == rec.Id &&
					brandToProfileIdMap.size() != 0) {
					// Amazon customers without right email cause an exception with Community User creation mechanism
					if (String.isBlank(currentAccount.PersonEmail)) {
						continue;
					}

					accinfo = currentAccount.FirstName + ' ' + currentAccount.LastName + ' ';
					Database.DMLOptions dmo = new Database.DMLOptions();
					dmo.EmailHeader.triggerUserEmail = true;
					dmo.EmailHeader.triggerOtherEmail = false;
					dmo.EmailHeader.triggerAutoResponseEmail = true;
					dmo.optAllOrNone = true;

					User newUser = new User();
					newUser.Email = currentAccount.PersonEmail;
					newUser.contactId = currentAccount.PersonContactId;
					if (brandToProfileIdMap.containsKey(currentAccount.Brand_Assortment__c) && brandToProfileIdMap.get(currentAccount.Brand_Assortment__c) != null) {
						newUser.ProfileId = Id.valueOf(brandToProfileIdMap.get(currentAccount.Brand_Assortment__c));
					}
					else {
						newUser.ProfileId = Id.valueOf(brandToProfileIdMap.get('default'));
					}
					newUser.FirstName = currentAccount.FirstName;
					newUser.LastName = currentAccount.LastName;
					newUser.Username = currentAccount.PersonEmail;
					newUser.Alias = (currentAccount.LastName != null) ? currentAccount.LastName : '';
					if (newUser.alias.length() > 8) {
						newUser.alias = newUser.alias.substring(0, 8);
					}
					// Developer Documentation: It can often be more convenient to manually set one User time zone in the user interface,
					// and then use that value for creating or updating other User records via the API.
					//
					// In that case we'll use current user settigns
					newUser.emailencodingkey = 'UTF-8';
					newUser.languagelocalekey = UserInfo.getLanguage();
					newUser.localesidkey = UserInfo.getLocale();
					newUser.timezonesidkey = UserInfo.getTimeZone().toString();
					newUser.setOptions(dmo);

					if (usersList.size() == 0) {
						usersToinsert.add(newUser);
					}
				}
			}

			try {

				insert usersToinsert;
			}
			catch (Exception e) {
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				List<String> sendToOwner = new List<String>();
				sendToOwner.add(owner.Email);
				mail.setToAddresses(sendToOwner);
				mail.setReplyTo('noreply@salesforce.com');
				mail.setSenderDisplayName('Apex error message');
				mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
				String body = 'Dear ' + owner.LastName + '. ' + '<br/>';
				body += 'For Customer Account ' + accinfo + ' New Authenticated User was not created' + '<br/>';
				body += e.getMessage();
				mail.setHtmlBody(body);
				Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
					mail
				});
			}
		}

		//RollupsChargentOrderTrigger
		for (Id acc : accountOrdersMap.keySet()) {
			Double sumOfOrderValues = 0;
			Integer ordersCount = 0;
			Datetime lastOrderDate = Datetime.newInstance(1970, 1, 1);
			Datetime firstOrderDate = Datetime.now();
			Double largeOrderValue = 0;
			Integer refundsAndFailsTotal = 0;
			for (Order__c order : accountOrdersMap.get(acc)) {
				if (order.Balance_Due__c == 0) {
					sumOfOrderValues += order.Total__c;
					ordersCount++;
					if (order.Total__c > largeOrderValue)
						largeOrderValue = order.Total__c;
				}
				else {
					refundsAndFailsTotal++;
				}

				if (order.Date__c > lastOrderDate)
					lastOrderDate = order.Date__c;
				if (order.Date__c < firstOrderDate)
					firstOrderDate = order.Date__c;
			}

			Account currentAccount = accountsToRecalculateMap.get(acc);

			if (ordersCount != 0) {
				currentAccount.Average_Order_Value__c = sumOfOrderValues / ordersCount;
			}
			else {
				currentAccount.Average_Order_Value__c = 0;
			}

			if (lastOrderDate != Datetime.newInstance(1970, 1, 1))
				currentAccount.Last_order_date__c = lastOrderDate;
			if (lastOrderDate != Datetime.now())
				currentAccount.First_order_date__c = firstOrderDate;

			currentAccount.Large_Order_Value__c = largeOrderValue;
			currentAccount.Number_of_Orders__c = accountOrdersMap.get(acc).size();
			currentAccount.Refunds_and_Fails_Total__c = refundsAndFailsTotal;
			currentAccount.Subtotal_From_Zero_Balance_Orders__c = sumOfOrderValues;
			currentAccount.Number_Of_Zero_Balance_Orders__c = ordersCount;
		}
		update accountsToRecalculateMap.values();
	}
}