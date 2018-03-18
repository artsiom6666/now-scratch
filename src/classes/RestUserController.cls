public with sharing class RestUserController {

	public static String setUser(Map<String, String> generalData) {

		try {
			List<Profile> profileId = [SELECT Id FROM Profile WHERE Name = 'Customer' LIMIT 1];
			if (Test.isRunningTest()) {profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];}

			Id accountId = generalData.containsKey('accountId') ? Id.valueOf(generalData.get('accountId')) : null;
			Id contactId = generalData.containsKey('contactId') ? Id.valueOf(generalData.get('contactId')) : null;

			String firstName = generalData.containsKey('firstName') ? generalData.get('firstName') : '';
			String lastName = generalData.containsKey('lastName') ? generalData.get('lastName') : '';
			String alias = generalData.containsKey('alias') ? generalData.get('alias') : '';
			String email = generalData.containsKey('email') ? generalData.get('email') : '';
			String username = generalData.containsKey('username') ? generalData.get('username') : email;

			String emailEncodingKey = generalData.containsKey('emailEncodingKey') ? generalData.get('emailEncodingKey') : 'ISO-8859-1';

			// Developer Documentation: It can often be more convenient to manually set one User time zone in the user interface,
			// and then use that value for creating or updating other User records via the API.
			//
			// In that case we'll use current user settigns
			String languageLocaleKey = generalData.containsKey('languageLocaleKey') ? generalData.get('languageLocaleKey') : UserInfo.getLanguage();
			String localeSidKey = generalData.containsKey('localeSidKey') ? generalData.get('localeSidKey') : UserInfo.getLocale();
			String timeZoneSidKey = generalData.containsKey('timeZoneSidKey') ? generalData.get('timeZoneSidKey') : UserInfo.getTimeZone().toString();

			if (contactId == null && accountId != null ) {
				List<Contact> cont = [SELECT Id FROM Contact WHERE AccountId = :accountId LIMIT 1];
				contactId = cont.isEmpty() ? null : cont[0].Id;
			}

			String codeFields = TouchCRHelper.isSCPEnabled() == TRUE ? ' ,CountryCode, StateCode ' : '';

			String query = 
				'SELECT Id, Username, LastName, FirstName, Name, City, State, Email, PostalCode, Country, Latitude, Longitude ' + codeFields +
				'FROM User  ' +
				'WHERE ContactId = :contactId';
			List<User> existingUser = Database.query(query);

			User newUser = existingUser.isEmpty() ? new User() : existingUser[0];

			Database.DMLOptions dmo = new Database.DMLOptions();
			dmo.EmailHeader.triggerUserEmail = true;
			dmo.EmailHeader.triggerOtherEmail = false;
			dmo.EmailHeader.triggerAutoResponseEmail = true;
			dmo.optAllOrNone = true;

			newUser.LastName = lastName;
			newUser.FirstName = firstName;
			newUser.Email = email;
			newUser.Username = username;
			newUser.Alias = lastName;
			if (newUser.Alias.length() > 8) {
				newUser.Alias = newUser.Alias.substring(0, 8);
			}

			newUser.ProfileId = profileId[0].id;
			newUser.TimeZoneSidKey = timeZoneSidKey;
			newUser.LanguageLocaleKey = languageLocaleKey;
			newUser.EmailEncodingKey = emailEncodingKey;
			newUser.LocaleSidKey = localeSidKey;
			newUser.setOptions(dmo);

			if (!existingUser.isEmpty()) { return '{"error":"DUPLICATE_USERNAME","message":"error"}'; }
			//if for current customer not found user, we create it
			List<Schema.DescribeFieldResult> listUserFields = new List<Schema.DescribeFieldResult> {
						User.LastName.getDescribe(), User.FirstName.getDescribe(),
						User.Email.getDescribe(), User.Username.getDescribe(),
						User.Alias.getDescribe(), User.ProfileId.getDescribe(),
						User.TimeZoneSidKey.getDescribe(), User.LanguageLocaleKey.getDescribe(),
						User.EmailEncodingKey.getDescribe(), User.LocaleSidKey.getDescribe()				
			};

			if (!Test.isRunningTest()) {
				newUser.ContactId = contactId;
				listUserFields.add(User.ContactId.getDescribe());
				}

			try {
				SFDCAccessController.InsertWithoutSharing (
					newUser,
					'RestUserController.cls [setUser]',
					listUserFields
				);
			} catch (SFDCAccessControlException e) { return  '{"error":"' + e.ExceptionMessage + '","message":"error"}'; }

			return '{"userId":"' + newUser.Id + '","message":"success"}';
		}
		catch (Exception e) {
			return '{"error":"' + e.getMessage() + '","message":"error"}';
		}
	}

}