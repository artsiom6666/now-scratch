public with sharing class RestPersonAccountController {

	public static String setPersonAccount(Map<String, String> generalData) {
		try {
			Id customerId = generalData.containsKey('id') ? Id.valueOf(generalData.get('id')) : null;
			String lastName = generalData.containsKey('lastName') ? generalData.get('lastName') : null;
			String firstName = generalData.containsKey('firstName') ? generalData.get('firstName') : null;
			String email = generalData.containsKey('personEmail') ? generalData.get('personEmail') : null;
			String phone = generalData.containsKey('phone') ? generalData.get('phone') : null;
			String personMobilePhone = generalData.containsKey('personMobilePhone') ? generalData.get('personMobilePhone') : null;

			String brand = generalData.containsKey('brand') ? generalData.get('brand') : 'Winter';

			String billingStreet = generalData.containsKey('billingStreet') ? generalData.get('billingStreet') : null;
			String billingCity = generalData.containsKey('billingCity') ? generalData.get('billingCity') : null;
			String billingPostalCode = generalData.containsKey('billingPostalCode') ? generalData.get('billingPostalCode') : null;
			String billingStateCode = generalData.containsKey('billingStateCode') ? generalData.get('billingStateCode') : null;
			String billingState = generalData.containsKey('billingState') ? generalData.get('billingState') : null;
			String billingCountryCode = generalData.containsKey('billingCountryCode') ? generalData.get('billingCountryCode') : null;
			String billingCountry = generalData.containsKey('billingCountry') ? generalData.get('billingCountry') : null;

			String shippingStreet = generalData.containsKey('shippingStreet') ? generalData.get('shippingStreet') : null;
			String shippingCity = generalData.containsKey('shippingCity') ? generalData.get('shippingCity') : null;
			String shippingPostalCode = generalData.containsKey('shippingPostalCode') ? generalData.get('shippingPostalCode') : null;
			String shippingStateCode = generalData.containsKey('shippingStateCode') ? generalData.get('shippingStateCode') : null;
			String shippingState = generalData.containsKey('shippingState') ? generalData.get('shippingState') : null;
			String shippingCountryCode = generalData.containsKey('shippingCountryCode') ? generalData.get('shippingCountryCode') : null;
			String shippingCountry = generalData.containsKey('shippingCountry') ? generalData.get('shippingCountry') : null;

			String notificationToken = generalData.containsKey('notificationToken') ? generalData.get('notificationToken') : null;
			String last4 = generalData.containsKey('last4') ? generalData.get('last4') : null;

			String utmCampaign = generalData.containsKey('utmCampaign') ? generalData.get('utmCampaign') : null;
			String utmContent = generalData.containsKey('utmContent') ? generalData.get('utmContent') : null;
			String utmMedium = generalData.containsKey('utmMedium') ? generalData.get('utmMedium') : null;
			String utmSource = generalData.containsKey('utmSource') ? generalData.get('utmSource') : null;
			String utmTerm = generalData.containsKey('utmTerm') ? generalData.get('utmTerm') : null;

			String affiliateApproval = generalData.containsKey('affiliateApproval') ? generalData.get('affiliateApproval') : null;
			String companyName = generalData.containsKey('companyName') ? generalData.get('companyName') : null;

			List<RecordType> personRtList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true AND IsActive = true LIMIT 1];

			//getting information from an existing Account
			String codeFields = TouchCRHelper.isSCPEnabled() == TRUE ? ' BillingStateCode, ShippingStateCode, BillingCountryCode, ShippingCountryCode, ' : '';
			String affiliateFields = TouchCRHelper.isAffiliateEnabled() == TRUE ? ' Affiliate_Approval__c, Company_Name__c, ' : '';
			
			String accountQueryString = 'SELECT Id, LastName, FirstName, BillingStreet, BillingCity, BillingState, ' + codeFields + 
					'BillingPostalCode, BillingCountry, ' + affiliateFields +
					'ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ' +
					'Phone, Fax, PersonContactId, RecordTypeId, ' +
					'PersonEmail, Brand_Assortment__c, Last4__c, PersonMobilePhone, Type, ' +
					'Utm_Campaign__c, Utm_Content__c, Utm_Medium__c, Utm_Source__c, Utm_Term__c ' +
					'FROM Account ';

			//if customerId exists we search for Account with Id, otherwise we use email
			accountQueryString += String.isBlank(customerId) ? ' WHERE PersonEmail =: email' : ' WHERE Id =: customerId';
			List<Account> accountToCustomer = Database.query(accountQueryString);

			Account accountItem = accountToCustomer.isEmpty() ? new Account() : accountToCustomer[0];

			accountItem.RecordTypeId = accountItem.RecordTypeId != null ? accountItem.RecordTypeId : personRtList[0].Id;
			accountItem.LastName = String.isNotBlank(lastName) ? lastName : accountItem.LastName;
			accountItem.FirstName = String.isNotBlank(firstName) ? firstName : accountItem.FirstName;
			accountItem.PersonEmail  = String.isNotBlank(email) ? email : accountItem.PersonEmail;
			accountItem.Phone = String.isNotBlank(phone) ? phone : accountItem.Phone;
			accountItem.PersonMobilePhone = String.isNotBlank(personMobilePhone) ? personMobilePhone : accountItem.PersonMobilePhone;
			accountItem.Brand_Assortment__c = String.isNotBlank(brand) ? brand : accountItem.Brand_Assortment__c;

			accountItem.ShippingStreet = String.isNotBlank(shippingStreet) ? shippingStreet : accountItem.ShippingStreet;
			accountItem.ShippingCity = String.isNotBlank(shippingCity) ? shippingCity : accountItem.ShippingCity;
			accountItem.ShippingPostalCode = String.isNotBlank(shippingPostalCode) ? shippingPostalCode : accountItem.ShippingPostalCode;
			//if Billing Address is Blank, we use Shipping Address
			accountItem.BillingStreet = String.isNotBlank(billingStreet) ? billingStreet : (String.isNotBlank(accountItem.BillingStreet) ? accountItem.BillingStreet : accountItem.ShippingStreet);
			accountItem.BillingCity = String.isNotBlank(billingCity) ? billingCity : (String.isNotBlank(accountItem.BillingCity) ? accountItem.BillingCity : accountItem.ShippingCity);
			accountItem.BillingPostalCode = String.isNotBlank(billingPostalCode) ? billingPostalCode : (String.isNotBlank(accountItem.BillingPostalCode) ? accountItem.BillingPostalCode : accountItem.ShippingPostalCode);

			accountItem.ShippingState = String.isNotBlank(shippingState) ? shippingState : accountItem.ShippingState;
			accountItem.ShippingCountry = String.isNotBlank(shippingCountry) ? shippingCountry : accountItem.ShippingCountry;
			
			if (TouchCRHelper.isSCPEnabled()) {
				accountItem.put('ShippingStateCode', String.isNotBlank(shippingStateCode) ? shippingStateCode : (String)accountItem.get('ShippingStateCode'));
				accountItem.put('ShippingCountryCode', String.isNotBlank(shippingCountryCode) ? shippingCountryCode : (String)accountItem.get('ShippingCountryCode'));
			}

			if (TouchCRHelper.isSCPEnabled()) {
				accountItem.put('BillingStateCode', String.isNotBlank(billingStateCode) ? billingStateCode : (String)accountItem.get('BillingStateCode'));
			}
			accountItem.BillingState = (String.isNotBlank(billingState)) ? billingState : (String.isNotBlank(accountItem.BillingState) ? accountItem.BillingState : accountItem.ShippingState);
			if (TouchCRHelper.isSCPEnabled()) {
				accountItem.put('BillingCountryCode', String.isNotBlank(billingCountryCode) ? billingCountryCode : (String)accountItem.get('BillingCountryCode'));
			}
			accountItem.BillingCountry = (String.isNotBlank(billingCountry)) ? billingCountry : (String.isNotBlank(accountItem.BillingCountry) ? accountItem.BillingCountry : accountItem.ShippingCountry);

			accountItem.Notification_Token__c = notificationToken != null ? notificationToken : accountItem.Notification_Token__c;
			accountItem.Last4__c = last4 != null ? last4 : accountItem.Last4__c;

			accountItem.Utm_Campaign__c = String.isNotBlank(utmCampaign) ? utmCampaign : accountItem.Utm_Campaign__c;
			accountItem.Utm_Content__c = String.isNotBlank(utmContent) ? utmContent : accountItem.Utm_Content__c;
			accountItem.Utm_Medium__c = String.isNotBlank(utmMedium) ? utmMedium : accountItem.Utm_Medium__c;
			accountItem.Utm_Source__c = String.isNotBlank(utmSource) ? utmSource : accountItem.Utm_Source__c;
			accountItem.Utm_Term__c = String.isNotBlank(utmTerm) ? utmTerm : accountItem.Utm_Term__c;

			if (TouchCRHelper.isAffiliateEnabled()) {
				accountItem.put('Affiliate_Approval__c', String.isNotBlank(affiliateApproval) ? affiliateApproval : (String)accountItem.get('Affiliate_Approval__c'));
				accountItem.put('Company_Name__c', String.isNotBlank(companyName) ? companyName : (String)accountItem.get('Company_Name__c'));
			}

			try {
				SFDCAccessController.UpsertWithoutSharing (
					accountItem,
					'RestPersonAccountController.cls [setPersonAccount]',
					new List<Schema.DescribeFieldResult>{
						Account.RecordTypeId.getDescribe(), Account.LastName.getDescribe(),
						Account.FirstName.getDescribe(), Account.PersonEmail.getDescribe(),
						Account.Phone.getDescribe(), Account.PersonMobilePhone.getDescribe(),
						Account.Brand_Assortment__c.getDescribe(), Account.Last4__c.getDescribe(),
						Account.ShippingCity.getDescribe(), Account.ShippingPostalCode.getDescribe(),
						Account.ShippingState.getDescribe(), Account.ShippingCountry.getDescribe(),
						Account.BillingStreet.getDescribe(), Account.BillingCity.getDescribe(),
						Account.BillingPostalCode.getDescribe(), Account.BillingState.getDescribe(),
						Account.BillingCountry.getDescribe(), Account.Notification_Token__c.getDescribe(),
						Account.Utm_Campaign__c.getDescribe(), Account.Utm_Content__c.getDescribe(),
						Account.Utm_Medium__c.getDescribe(), Account.Utm_Source__c.getDescribe(),
						Account.Utm_Term__c.getDescribe()
					}
				);
			} catch (SFDCAccessControlException e) { return  '{"error":"' + e.ExceptionMessage + '","message":"error"}'; }

			return '{"accountId":"' + accountItem.Id + '","message":"success"}';

			} catch (Exception e) { return '{"error":"' + e.getMessage() + '","message":"error"}';}
	}

	public static String getPersonAccount(Map<String, String> generalData) {
		try {
			Id userId = generalData.containsKey('userId') ? generalData.get('userId') : null;
			String email = generalData.containsKey('personEmail') ? generalData.get('personEmail') : null;
			//verification of input data
			if (userId == null && email == null) { return '{"error":"User Id or Person Email was not found","message":"error"}'; }

			Id accountId;
			String queryFilter, userPhoto;

			if (userId != null) {
			List<User> userToAccount = [SELECT Id, Account.Id, MediumPhotoUrl FROM User WHERE Id =: userId AND AccountId != null];

				if (userToAccount.isEmpty()) { return '{"error":"Account not found","message":"error"}'; }
				accountId = userToAccount[0].Account.Id;
				userPhoto = userToAccount[0].MediumPhotoUrl;
				queryFilter = 'WHERE Id=:accountId';
			} else {
				queryFilter = 'WHERE PersonEmail=:email';
			}

			String codeFields = TouchCRHelper.isSCPEnabled() == TRUE ? ' BillingStateCode, BillingCountryCode, ShippingStateCode, ShippingCountryCode, ' : '';
			String affiliateFields = TouchCRHelper.isAffiliateEnabled() == TRUE ? ' Affiliate_Approval__c, Company_Name__c, Available_Balance_for_Withdrawal__c, Commission_Earned__c, Commission_Paid_Out__c, Commission_Waiting_for_Approval__c, Balance_Due__c, ' : '';

			String accountQueryString = 'SELECT Id, Name, FirstName, LastName, Phone, PersonEmail, BillingCountry, BillingStreet, BillingCity, BillingState, ' + codeFields + 
							'RecordType.DeveloperName, BillingPostalCode ,ShippingCountry, ShippingStreet, ShippingCity, ShippingState, ' + affiliateFields + 
							'ShippingPostalCode, Notification_Token__c, Last4__c, PersonMobilePhone, Blacklist__c, NewEmail__c ' +
							'FROM Account ' +
							queryFilter;

			List<Account> selectedAccounts = Database.query(accountQueryString);

			if (selectedAccounts.isEmpty()) { return '{"error":"Account not found","message":"error"}'; }

			List<Payment_Option__c> allPaymentOptions = [
				SELECT Id, Status__c, Profile_Id__c, Option_Id__c, Named_Agent__c, Last_4__c
				FROM Payment_Option__c
				WHERE Account__c =: selectedAccounts[0].Id
				AND Status__c = 'Active'
			];

			List<Map<String, String>> paymentOptions = new List<Map<String, String>>();
			for (Payment_Option__c paymentOption : allPaymentOptions) {
				paymentOptions.add(new Map<String, String>{
					'last4' => paymentOption.Last_4__c,
					'id' => paymentOption.Id
				});
			}

			String billingStateCode = TouchCRHelper.isSCPEnabled() == TRUE ? (String)selectedAccounts[0].get('BillingStateCode') : '';
			String billingCountryCode = TouchCRHelper.isSCPEnabled() == TRUE ? (String)selectedAccounts[0].get('BillingCountryCode') : '';
			String shippingStateCode = TouchCRHelper.isSCPEnabled() == TRUE ? (String)selectedAccounts[0].get('ShippingStateCode') : '';
			String shippingCountryCode = TouchCRHelper.isSCPEnabled() == TRUE ? (String)selectedAccounts[0].get('ShippingCountryCode') : '';
			String affiliateApproval = TouchCRHelper.isAffiliateEnabled() == TRUE ? (String)selectedAccounts[0].get('Affiliate_Approval__c') : '';
			String companyName = TouchCRHelper.isAffiliateEnabled() == TRUE ? (String)selectedAccounts[0].get('Company_Name__c') : '';

			Map<String, Object> accountDetail = new Map<String, Object>{
				'id' => selectedAccounts[0].Id,
				'name' => selectedAccounts[0].Name,
				'firstName' => selectedAccounts[0].FirstName,
				'lastName' => selectedAccounts[0].LastName,
				'phone' => selectedAccounts[0].Phone,
				'personMobilePhone' => selectedAccounts[0].PersonMobilePhone,
				'personEmail' => selectedAccounts[0].PersonEmail,
				'newEmail' => selectedAccounts[0].NewEmail__c,
				'billingStreet' => selectedAccounts[0].BillingStreet,
				'billingCity' => selectedAccounts[0].BillingCity,
				'billingState' => selectedAccounts[0].BillingState,
				'billingStateCode' => billingStateCode,
				'billingCountry' => selectedAccounts[0].BillingCountry,
				'billingCountryCode' => billingCountryCode,
				'billingPostalCode' => selectedAccounts[0].BillingPostalCode,
				'shippingStreet' => selectedAccounts[0].ShippingStreet,
				'shippingCity' => selectedAccounts[0].ShippingCity,
				'shippingState' => selectedAccounts[0].ShippingState,
				'shippingStateCode' => shippingStateCode,
				'shippingCountry' => selectedAccounts[0].ShippingCountry,
				'shippingCountryCode' => shippingCountryCode,
				'shippingPostalCode' => selectedAccounts[0].ShippingPostalCode,
				'affiliateApproval' => affiliateApproval,
				'companyName' => companyName,
				'url' => userPhoto,
				'paymentOptions' => paymentOptions,
				'notificationToken' => String.valueOf(selectedAccounts[0].Notification_Token__c),
				//value 'PersonAccount'  of 'Affiliate_Account'
				'recordType' => selectedAccounts[0].RecordType.DeveloperName,
				'last4' => String.valueOf(selectedAccounts[0].Last4__c)
			};

			//for Affiliate Account
			if (TouchCRHelper.isAffiliateEnabled() && selectedAccounts[0].RecordType.DeveloperName == 'Affiliate_Account') {
				accountDetail.put('blacklist',selectedAccounts[0].get('Blacklist__c'));
				accountDetail.put('commissionEarned',selectedAccounts[0].get('Commission_Earned__c'));
				accountDetail.put('commissionPaidOut',selectedAccounts[0].get('Commission_Paid_Out__c'));
				accountDetail.put('commissionWaitingForApproval',selectedAccounts[0].get('Commission_Waiting_for_Approval__c'));
				accountDetail.put('balanceDue',selectedAccounts[0].get('Balance_Due__c'));
				accountDetail.put('availableBalanceForWithdrawal',selectedAccounts[0].get('Available_Balance_for_Withdrawal__c'));

				List<Map<String, Object>> payoutMechanisms = new List<Map<String, Object>>();
				payoutMechanisms = ExtensionsHelperDummy.getPayoutsMechanisms(selectedAccounts[0].Id);
				accountDetail.put('payoutMechanisms',payoutMechanisms);

			}

			Map<String, Object> result = new Map<String, Object>{
				'message' => 'success',
				'account' => accountDetail
			};

			return JSON.serialize(result);

		} catch (Exception e) { return '{"error":"' +  e.getMessage() + '","message":"error"}'; }
	}

	public static String deletePersonAccount(Map<String, String> generalData) {
		try {
			Id customerId = generalData.containsKey('id') ? Id.valueOf(generalData.get('id')) : null;
			Account deleteAccount = new Account(Id = customerId);
			try {
				SFDCAccessController.DeleteWithoutSharing (
					deleteAccount,
					'RestPersonAccountController.cls [deletePersonAccount]'
				);
			} catch (SFDCAccessControlException e) { return  '{"error":"' + e.ExceptionMessage + '","message":"error"}'; }

			return '{"message":"success"}';

		} catch (Exception e) { return '{"error":"' + e.getMessage() + '","message":"error"}';}
	}

	public static String setAccountWithUser(Map<String, String> generalData) {
		try {
			Id accountId = generalData.containsKey('id') ? Id.valueOf(generalData.get('id')) : null;
			String email = generalData.containsKey('personEmail') ? generalData.get('personEmail') : null;
			if (email == null) { return '{"error":"Email was not found","message":"error"}'; }

			generalData.put ('email', email);

			String result = '{"message":"error"}';
			Map<String, String> workData = new Map<String, String>();
			if (String.isEmpty(accountId)) {
				List<User> existingUsers = [SELECT Id, Email FROM User WHERE Email =:email AND IsActive = true];
				if (!existingUsers.isEmpty()) { return '{"error":"User with this email already exists","message":"error"}'; }

				result = setPersonAccount(generalData);
				if (result.contains('error')) { return result; }

				workData = (Map<String, String>)JSON.deserialize(result, Map<String, String>.class);
				accountId = Id.valueOf(workData.get('accountId'));
				generalData.put ('accountId', workData.get('accountId'));
				result = RestUserController.setUser(generalData);

				//error creating user, but account was created
				if (result.contains('error')) {

					result = result.removeEnd('}');
					result += ' ,"accountId":"' + accountId + '"}';
					return result;
				}
				workData = (Map<String, String>)JSON.deserialize(result, Map<String, String>.class);
				return JSON.serialize(new Map<String, Object>{
					'accountId' => accountId,
					'userId' => workData.get('userId'),
					'message' => 'success'
				});

			}

			return setPersonAccount(generalData);

		} catch (Exception e) { return '{"error":"' + e.getMessage() + '","message":"error"}';}
	}


}