@isTest
private class SFDCAccessControllerTests {

	public static testMethod void SFDCAccessController_GetDescribeTest() {
		Map<String,Schema.SObjectType> GlobalDescribe = SFDCAccessController.getGlobalDescribe();
		System.assert(GlobalDescribe != NULL);

		Schema.DescribeSObjectResult Describe = SFDCAccessController.getDescribe(Contact.SObjectType);
		System.assert(Describe != NULL);

		Schema.SObjectType S1 = SFDCAccessController.getSObjectType(NULL);
		System.assert(S1 == NULL);
		Schema.SObjectType S2 = SFDCAccessController.getSObjectType(UserInfo.getUserId());
		System.assert(S2 != NULL);
	}

	public static testMethod void SFDCAccessController_Admin_DML1WithoutSharingTest() {
		User usr = [SELECT Id FROM User WHERE isActive = true AND Profile.Name='System Administrator' LIMIT 1];
		System.runAs(usr) {
			Account account_item1 = new Account(Name = 'test1SFDC' + System.currentTimeMillis());
			insert account_item1;
			Contact contact_item1 = new Contact(AccountId = account_item1.Id, FirstName = 'sfdc-test1', LastName = 'sfdc-test1', Email = 'tc1@gmail.com');

			SFDCAccessController.InsertWithoutSharing(
				contact_item1,
				'SFDCAccessControllerTests.cls [SFDCAccessController_DML1WithoutSharingTest]',
				new List<Schema.DescribeFieldResult> {
					Contact.FirstName.getDescribe(),
					Contact.LastName.getDescribe(),
					Contact.Email.getDescribe(),
					Contact.AccountId.getDescribe()
				}
			);

			contact_item1.FirstName = contact_item1.FirstName + '1';
			SFDCAccessController.UpdateWithoutSharing(
				contact_item1,
				'SFDCAccessControllerTests.cls [SFDCAccessController_DML1WithoutSharingTest]',
				new List<Schema.DescribeFieldResult> {
					Contact.FirstName.getDescribe(),
					Contact.LastName.getDescribe(),
					Contact.Email.getDescribe(),
					Contact.AccountId.getDescribe()
				}
			);

			contact_item1.FirstName = contact_item1.FirstName + '2';
			SFDCAccessController.UpsertWithoutSharing(
				contact_item1,
				'SFDCAccessControllerTests.cls [SFDCAccessController_DML1WithoutSharingTest]',
				new List<Schema.DescribeFieldResult> {
					Contact.FirstName.getDescribe(),
					Contact.LastName.getDescribe(),
					Contact.Email.getDescribe(),
					Contact.AccountId.getDescribe()
				}
			);

			SFDCAccessController.DeleteWithoutSharing(
				contact_item1,
				'SFDCAccessControllerTests.cls [SFDCAccessController_DML1WithoutSharingTest]'
			);

			Account account_item2 = new Account(Name = 'test2SF' + System.currentTimeMillis());
			insert account_item2;
			SFDCAccessController.DeleteWithoutSharing(
				account_item2,
				'SFDCAccessControllerTests.cls [SFDCAccessController_DML1WithoutSharingTest]'
			);

			Integer counter = [SELECT COUNT() FROM Account WHERE Id = :account_item2.Id];
			System.assertEquals(counter, 0);
		}
	}

	public static testMethod void SFDCAccessController_Admin_FutureDML1WithoutSharingTest() {
		User usr = [SELECT Id FROM User WHERE isActive = true AND Profile.Name='System Administrator' LIMIT 1];
		System.runAs(usr) {
			Account account_item1 = new Account(Name = 'test1SFDC' + System.currentTimeMillis());
			insert account_item1;
			Contact contact_item1 = new Contact(AccountId = account_item1.Id, FirstName = 'sfdc-test1', LastName = 'sfdc-test1', Email = 'tc1@gmail.com');

			SFDCAccessController.InsertWithoutSharing(
				contact_item1,
				'SFDCAccessControllerTests.cls [SFDCAccessController_DML1WithoutSharingTest]',
				new List<Schema.DescribeFieldResult> {
					Contact.FirstName.getDescribe(),
					Contact.LastName.getDescribe(),
					Contact.Email.getDescribe(),
					Contact.AccountId.getDescribe()
				}
			);

			contact_item1.FirstName = contact_item1.FirstName + '1';
			SFDCAccessController.UpdateWithoutSharing(
				contact_item1,
				'SFDCAccessControllerTests.cls [SFDCAccessController_DML1WithoutSharingTest]',
				new List<Schema.DescribeFieldResult> {
					Contact.FirstName.getDescribe(),
					Contact.LastName.getDescribe(),
					Contact.Email.getDescribe(),
					Contact.AccountId.getDescribe()
				}
			);

			contact_item1.FirstName = contact_item1.FirstName + '2';
			SFDCAccessController.UpsertWithoutSharing(
				contact_item1,
				'SFDCAccessControllerTests.cls [SFDCAccessController_DML1WithoutSharingTest]',
				new List<Schema.DescribeFieldResult> {
					Contact.FirstName.getDescribe(),
					Contact.LastName.getDescribe(),
					Contact.Email.getDescribe(),
					Contact.AccountId.getDescribe()
				}
			);

			SFDCAccessController.DeleteWithoutSharing(
				contact_item1,
				'SFDCAccessControllerTests.cls [SFDCAccessController_DML1WithoutSharingTest]'
			);

			Account account_item2 = new Account(Name = 'test2SF' + System.currentTimeMillis());
			insert account_item2;
			SFDCAccessController.DeleteWithoutSharing(
				account_item2,
				'SFDCAccessControllerTests.cls [SFDCAccessController_DML1WithoutSharingTest]'
			);

			Integer counter = [SELECT COUNT() FROM Account WHERE Id = :account_item2.Id];
			System.assertEquals(counter, 0);
		}
	}

	public static testMethod void SFDCAccessController_Admin_DML2WithoutSharingTest() {
		User usr = [SELECT Id FROM User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
		System.runAs(usr) {
			Account account_item1 = new Account(Name = 'test1SFDC' + System.currentTimeMillis());
			insert account_item1;
			Contact contact_item1 = new Contact(AccountId = account_item1.Id, FirstName = 'sfdc-test1', LastName = 'sfdc-test1', Email = 'tc1@gmail.com');
			Contact contact_item2 = new Contact(AccountId = account_item1.Id, FirstName = 'sfdc-test2', LastName = 'sfdc-test2', Email = 'tc2@gmail.com');
			List<Contact> contact_list = new List<Contact> {contact_item1,contact_item2};

			SFDCAccessController.InsertWithoutSharing(
				contact_list,
				'SFDCAccessControllerTests.cls [SFDCAccessController_DML2WithoutSharingTest]',
				new List<Schema.DescribeFieldResult> {
					Contact.FirstName.getDescribe(),
					Contact.LastName.getDescribe(),
					Contact.Email.getDescribe(),
					Contact.AccountId.getDescribe()
				}
			);

			contact_item1.FirstName = contact_item1.FirstName + '1';
			contact_item2.FirstName = contact_item2.FirstName + '1';
			SFDCAccessController.UpdateWithoutSharing(
				contact_list,
				'SFDCAccessControllerTests.cls [SFDCAccessController_DML2WithoutSharingTest]',
				new List<Schema.DescribeFieldResult> {
					Contact.FirstName.getDescribe(),
					Contact.LastName.getDescribe(),
					Contact.Email.getDescribe(),
					Contact.AccountId.getDescribe()
				}
			);

			contact_item1.FirstName = contact_item1.FirstName + '2';
			contact_item2.FirstName = contact_item2.FirstName + '2';
			SFDCAccessController.UpsertWithoutSharing(
				contact_list,
				'SFDCAccessControllerTests.cls [SFDCAccessController_DML2WithoutSharingTest]',
				new List<Schema.DescribeFieldResult> {
					Contact.FirstName.getDescribe(),
					Contact.LastName.getDescribe(),
					Contact.Email.getDescribe(),
					Contact.AccountId.getDescribe()
				}
			);

			SFDCAccessController.DeleteWithoutSharing(
				contact_list,
				'SFDCAccessControllerTests.cls [SFDCAccessController_DML2WithoutSharingTest]'
			);

			Account account_item2 = new Account(Name = 'test2SF' + System.currentTimeMillis());
			insert account_item2;
			Account account_item3 = new Account(Name = 'test3SF' + System.currentTimeMillis());
			insert account_item3;

			SFDCAccessController.DeleteWithoutSharing(
				new List<Account> {account_item2,account_item3},
				'SFDCAccessControllerTests.cls [SFDCAccessController_DML2WithoutSharingTest]'
			);

			Integer counter = [SELECT COUNT() FROM Account WHERE Id IN (:account_item2.Id, :account_item3.Id)];
			System.assertEquals(counter, 0);
		}
	}

	public static testMethod void SFDCAccessController_Exception_DML1WithoutSharingTest() {
		Integer exception_count = 0;
		User usr = [SELECT Id FROM User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
		System.runAs(usr) {
			Account account_item1 = new Account(Name = 'test1SFDC' + System.currentTimeMillis());
			insert account_item1;
			Contact contact_item1 = new Contact(AccountId = account_item1.Id, FirstName = 'sfdc-test1', LastName = 'sfdc-test1', Email = 'tc1@gmail.com');

			try {
				SFDCAccessController.InsertWithoutSharing(
					contact_item1,
					'SFDCAccessControllerTests.cls [SFDCAccessController_DML1WithoutSharingTest]',
					new List<Schema.DescribeFieldResult> {
						Contact.Id.getDescribe(),
						Contact.AccountId.getDescribe()
					}
				);
			}
			catch (SFDCAccessControlException e) {
				exception_count ++;
			}

			contact_item1.FirstName = contact_item1.FirstName + '1';
			try {
				SFDCAccessController.UpdateWithoutSharing(
					contact_item1,
					'SFDCAccessControllerTests.cls [SFDCAccessController_DML1WithoutSharingTest]',
					new List<Schema.DescribeFieldResult> {
						Contact.Id.getDescribe(),
						Contact.AccountId.getDescribe()
					}
				);
			}
			catch (SFDCAccessControlException e) {
				exception_count ++;
			}

			contact_item1.FirstName = contact_item1.FirstName + '2';
			try {
				SFDCAccessController.UpsertWithoutSharing(
					contact_item1,
					'SFDCAccessControllerTests.cls [SFDCAccessController_DML1WithoutSharingTest]',
					new List<Schema.DescribeFieldResult> {
						Contact.Id.getDescribe(),
						Contact.AccountId.getDescribe()
					}
				);
			}
			catch (SFDCAccessControlException e) {
				exception_count ++;
			}

			ApexClass apexclass_item1 = [SELECT Id FROM ApexClass LIMIT 1];
			try {
				SFDCAccessController.DeleteWithoutSharing(
					apexclass_item1,
					'SFDCAccessControllerTests.cls [SFDCAccessController_DML1WithoutSharingTest]'
				);
			}
			catch (SFDCAccessControlException e) {
				exception_count ++;
			}
		}
		System.AssertEquals(exception_count, 4);
	}

	public static testMethod void SFDCAccessController_Exception_DML2WithoutSharingTest() {
		Integer exception_count = 0;
		User usr = [SELECT Id FROM User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
		System.runAs(usr) {
			Account account_item1 = new Account(Name = 'test1SFDC' + System.currentTimeMillis());
			insert account_item1;
			Contact contact_item1 = new Contact(AccountId = account_item1.Id, FirstName = 'sfdc-test1', LastName = 'sfdc-test1', Email = 'tc1@gmail.com');
			Contact contact_item2 = new Contact(AccountId = account_item1.Id, FirstName = 'sfdc-test2', LastName = 'sfdc-test2', Email = 'tc2@gmail.com');
			List<Contact> contact_list = new List<Contact> {contact_item1,contact_item2};

			try {
				SFDCAccessController.InsertWithoutSharing(
					contact_list,
					'SFDCAccessControllerTests.cls [SFDCAccessController_DML2WithoutSharingTest]',
					new List<Schema.DescribeFieldResult> {
						Contact.Id.getDescribe(),
						Contact.AccountId.getDescribe()
					}
				);
			}
			catch (SFDCAccessControlException e) {
				exception_count ++;
			}

			contact_item1.FirstName = contact_item1.FirstName + '1';
			try {
				SFDCAccessController.UpdateWithoutSharing(
					contact_list,
					'SFDCAccessControllerTests.cls [SFDCAccessController_DML2WithoutSharingTest]',
					new List<Schema.DescribeFieldResult> {
						Contact.Id.getDescribe(),
						Contact.AccountId.getDescribe()
					}
				);
			}
			catch (SFDCAccessControlException e) {
				exception_count ++;
			}

			contact_item1.FirstName = contact_item1.FirstName + '2';
			try {
				SFDCAccessController.UpsertWithoutSharing(
					contact_list,
					'SFDCAccessControllerTests.cls [SFDCAccessController_DML2WithoutSharingTest]',
					new List<Schema.DescribeFieldResult> {
						Contact.Id.getDescribe(),
						Contact.AccountId.getDescribe()
					}
				);
			}
			catch (SFDCAccessControlException e) {
				exception_count ++;
			}

			List<ApexClass> apexclass_list = [SELECT Id FROM ApexClass LIMIT 2];
			try {
				SFDCAccessController.DeleteWithoutSharing(
					apexclass_list,
					'SFDCAccessControllerTests.cls [SFDCAccessController_DML2WithoutSharingTest]'
				);
			}
			catch (SFDCAccessControlException e) {
				exception_count ++;
			}
		}
		System.AssertEquals(exception_count, 4);
	}

	public static testMethod void SFDCAccessControlExceptionTest() {
		String eText = 'Access Violation';
		SFDCAccessControlException.ExceptionType eType = SFDCAccessControlException.ExceptionType.GENERIC;
		SFDCAccessControlException.ExceptionReason eReason = SFDCAccessControlException.ExceptionReason.NO_UPDATE;
		String eObject = Contact.sObjectType.getDescribe().getName();
		String eField = 'test';

		SFDCAccessControlException ex = new SFDCAccessControlException(eText, eType, eReason, eObject, eField);

		System.assertEquals(ex.ExceptionMessage, eText + ' : ' + eType + ' - ' + eReason + ' : ' + eObject + '.' + eField);

		System.assertEquals(ex.getText(), eText);
		System.assertEquals(ex.getExceptionField(), eField);
		System.assertEquals(ex.getExceptionObject(), eObject);
		System.assertEquals(ex.getExceptionType(), eType);
		System.assertEquals(ex.getExceptionReason(), eReason);
	}

	public static testMethod void SFDCValidationExceptionTest() {
		SFDCValidationException ex = new SFDCValidationException('test', SFDCValidationException.ValidationType.INPUT_VALIDATION);
		system.assertEquals(ex.eText, 'test');
		system.assertEquals(ex.eType, SFDCValidationException.ValidationType.INPUT_VALIDATION);
		system.assertEquals(ex.ExceptionMessage, ex.eText);
	}

	public static testMethod void SFDCErrorExceptionTest() {
		SFDCErrorException ex = new SFDCErrorException('test', SFDCErrorException.ErrorType.GENERIC);
		system.assertEquals(ex.eText, 'test');
		system.assertEquals(ex.eType, SFDCErrorException.ErrorType.GENERIC);
		system.assertEquals(ex.ExceptionMessage, ex.eText);
	}
}