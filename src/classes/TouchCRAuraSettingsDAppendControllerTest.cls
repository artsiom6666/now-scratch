@isTest
public class TouchCRAuraSettingsDAppendControllerTest {

// DataAppendGlobalSettings

	static testMethod void test_DataAppendGlobalSettings() {
		String settings = TouchCRAuraSettingsDAppendController.getGlobalSettingsApex();
		Map<String, String> settingsDesirialized = (Map<String, String>)System.JSON.deserialize(settings, Map<String, String>.class);

		System.assertEquals(settingsDesirialized.get('Global.APIKey'), '');
		System.assertEquals(settingsDesirialized.get('Global.AppendOnNewAccount'), '');
		System.assertEquals(settingsDesirialized.get('Global.AppendOnNewLead'), '');
		System.assertEquals(settingsDesirialized.get('Global.EmailOn'), '');
		System.assertEquals(settingsDesirialized.get('Global.IgnoreOlderThan'), '');
		System.assertEquals(settingsDesirialized.get('Global.License'), '');
		System.assertEquals(settingsDesirialized.get('Global.ReappendOnDays'), '');
		
		GlobalSettingsWrapper settingsWrap = new GlobalSettingsWrapper();
		settingsWrap.APIKey = 'test';
		settingsWrap.AppendOnNewAccount = true;
		settingsWrap.AppendOnNewLead = true;
		settingsWrap.EmailOn = true;
		settingsWrap.IgnoreOlderThan = '2014-01-06';
		settingsWrap.License = 'test';
		settingsWrap.ReappendOnDays = '2014-01-06';

		TouchCRAuraSettingsDAppendController.saveGlobal(JSON.serialize(settingsWrap));

		String savedSettings = TouchCRAuraSettingsDAppendController.getGlobalSettingsApex();

		Map<String, String> savedSettingsDesirialized = (Map<String, String>)System.JSON.deserialize(savedSettings, Map<String, String>.class);
		
		System.assertEquals(savedSettingsDesirialized.get('Global.APIKey'), 'test');
		System.assertEquals(savedSettingsDesirialized.get('Global.AppendOnNewAccount'), 'true');
		System.assertEquals(savedSettingsDesirialized.get('Global.AppendOnNewLead'), 'true');
		System.assertEquals(savedSettingsDesirialized.get('Global.EmailOn'), 'true');
		System.assertEquals(savedSettingsDesirialized.get('Global.IgnoreOlderThan'), '2014-01-06');
		System.assertEquals(savedSettingsDesirialized.get('Global.License'), 'test');
		System.assertEquals(savedSettingsDesirialized.get('Global.ReappendOnDays'), '2014-01-06');	}

	public class GlobalSettingsWrapper {
		protected String APIKey { get; set; }
		protected Boolean AppendOnNewAccount { get; set; }
		protected Boolean AppendOnNewLead { get; set; }
		protected Boolean EmailOn { get; set; }
		protected String IgnoreOlderThan { get; set; }
		protected String License { get; set; }
		protected String ReappendOnDays { get; set; }
	}

// DALeadConversionSettings

	@isTest static void test_DALeadConversionSettings() {
		String settings = TouchCRAuraSettingsDAppendController.getLeadConversionSettingsApex();
		Map<String, String> settingsDesirialized = (Map<String, String>)System.JSON.deserialize(settings, Map<String, String>.class);
		
		System.assertEquals(settingsDesirialized.get('Global.LeadAccountAged'), '');
		System.assertEquals(settingsDesirialized.get('Global.LeadConvert'), '');
		
		LeadConversionSettingsWrapper settingsWrap = new LeadConversionSettingsWrapper();
		settingsWrap.LeadConvert = true;
		settingsWrap.LeadAccountAged = 1;
		TouchCRAuraSettingsDAppendController.saveLeadConversion(JSON.serialize(settingsWrap));
		String savedSettings = TouchCRAuraSettingsDAppendController.getLeadConversionSettingsApex();
		Map<String, String> savedSettingsDesirialized = (Map<String, String>)System.JSON.deserialize(savedSettings, Map<String, String>.class);
		
		System.assertEquals(savedSettingsDesirialized.get('Global.LeadAccountAged'), '1');
		System.assertEquals(savedSettingsDesirialized.get('Global.LeadConvert'), 'true');
	}

	public class LeadConversionSettingsWrapper {
		protected Boolean LeadConvert { get; set; }
		protected Integer LeadAccountAged { get; set; }
	}

// DataAppendAccountSettings

	static testMethod void test_DataAppendAccountSettings() {
		String settings = TouchCRAuraSettingsDAppendController.getAccountSettingsApex();
		Map<String, String> settingsDesirialized = (Map<String, String>)System.JSON.deserialize(settings, Map<String, String>.class);
		
		System.assertEquals('', settingsDesirialized.get('Account.ValidateEmail'));
		System.assertEquals('', settingsDesirialized.get('Account.CorrectEmail'));
		System.assertEquals('', settingsDesirialized.get('Account.AppendNameAddress'));
		System.assertEquals('', settingsDesirialized.get('Account.EnableDemographics'));
		System.assertEquals('', settingsDesirialized.get('Account.EmailActivityMetrics'));
		System.assertEquals('', settingsDesirialized.get('Account.AppendDemographicBasics'));
		System.assertEquals('', settingsDesirialized.get('Account.AppendHousing'));
		System.assertEquals('', settingsDesirialized.get('Account.AppendInterest'));
		System.assertEquals('', settingsDesirialized.get('Account.AppendPurchase'));

		AccountSettingsWrapper settingsWrap = new AccountSettingsWrapper();

		settingsWrap.ValidateEmail = true;
		settingsWrap.CorrectEmail = true;
		settingsWrap.AppendNameAddress = true;
		settingsWrap.EnableDemographics = true;
		settingsWrap.EmailActivityMetrics = true;
		settingsWrap.AppendDemographicBasics = true;
		settingsWrap.AppendHousing = true;
		settingsWrap.AppendInterest = true;
		settingsWrap.AppendPurchase = true;

		TouchCRAuraSettingsDAppendController.saveAccount(JSON.serialize(settingsWrap));
		String savedSettings = TouchCRAuraSettingsDAppendController.getAccountSettingsApex();
		Map<String, String> savedSettingsDesirialized = (Map<String, String>)System.JSON.deserialize(savedSettings, Map<String, String>.class);

		System.assertEquals('true', savedSettingsDesirialized.get('Account.ValidateEmail'));
		System.assertEquals('true', savedSettingsDesirialized.get('Account.CorrectEmail'));
		System.assertEquals('true', savedSettingsDesirialized.get('Account.AppendNameAddress'));
		System.assertEquals('true', savedSettingsDesirialized.get('Account.EnableDemographics'));
		System.assertEquals('true', savedSettingsDesirialized.get('Account.EmailActivityMetrics'));
		System.assertEquals('true', savedSettingsDesirialized.get('Account.AppendDemographicBasics'));
		System.assertEquals('true', savedSettingsDesirialized.get('Account.AppendHousing'));
		System.assertEquals('true', savedSettingsDesirialized.get('Account.AppendInterest'));
		System.assertEquals('true', savedSettingsDesirialized.get('Account.AppendPurchase'));
	}

	public class AccountSettingsWrapper {
		protected Boolean ValidateEmail { get; set; }
		protected Boolean CorrectEmail { get; set; }
		protected Boolean AppendNameAddress { get; set; }
		protected Boolean EnableDemographics { get; set; }
		protected Boolean EmailActivityMetrics { get; set; }
		protected Boolean AppendDemographicBasics { get; set; }
		protected Boolean AppendHousing { get; set; }
		protected Boolean AppendInterest { get; set; }
		protected Boolean AppendPurchase { get; set; }
	}

// DataAppendLeadSettings

	static testMethod void test_DataAppendLeadSettings() {
		String settings = TouchCRAuraSettingsDAppendController.getLeadSettingsApex();
		Map<String, String> settingsDesirialized = (Map<String, String>)System.JSON.deserialize(settings, Map<String, String>.class);
		System.debug(settingsDesirialized);
		System.assertEquals(settingsDesirialized.get('Lead.ValidateEmail'), '');
		System.assertEquals(settingsDesirialized.get('Lead.CorrectEmail'), '');
		System.assertEquals(settingsDesirialized.get('Lead.AppendNameAddress'), '');
		System.assertEquals(settingsDesirialized.get('Lead.EnableDemographics'), '');
		System.assertEquals(settingsDesirialized.get('Lead.EmailActivityMetrics'), '');
		System.assertEquals(settingsDesirialized.get('Lead.AppendDemographicBasics'), '');
		System.assertEquals(settingsDesirialized.get('Lead.AppendHousing'), '');
		System.assertEquals(settingsDesirialized.get('Lead.AppendInterest'), '');
		System.assertEquals(settingsDesirialized.get('Lead.AppendPurchase'), '');
		
		LeadSettingsWrapper settingsWrap = new LeadSettingsWrapper();
		settingsWrap.ValidateEmail = true;
		settingsWrap.CorrectEmail = true;
		settingsWrap.AppendNameAddress = true;
		settingsWrap.EnableDemographics = true;
		settingsWrap.EmailActivityMetrics = true;
		settingsWrap.AppendDemographicBasics = true;
		settingsWrap.AppendHousing = true;
		settingsWrap.AppendInterest = true;
		settingsWrap.AppendPurchase = true;

		TouchCRAuraSettingsDAppendController.saveLead(JSON.serialize(settingsWrap));

		String savedSettings = TouchCRAuraSettingsDAppendController.getLeadSettingsApex();

		Map<String, String> savedSettingsDesirialized = (Map<String, String>)System.JSON.deserialize(savedSettings, Map<String, String>.class);
		
		System.assertEquals(savedSettingsDesirialized.get('Lead.ValidateEmail'), 'true');
		System.assertEquals(savedSettingsDesirialized.get('Lead.CorrectEmail'), 'true');
		System.assertEquals(savedSettingsDesirialized.get('Lead.AppendNameAddress'), 'true');
		System.assertEquals(savedSettingsDesirialized.get('Lead.EnableDemographics'), 'true');
		System.assertEquals(savedSettingsDesirialized.get('Lead.EmailActivityMetrics'), 'true');
		System.assertEquals(savedSettingsDesirialized.get('Lead.AppendDemographicBasics'), 'true');
		System.assertEquals(savedSettingsDesirialized.get('Lead.AppendHousing'), 'true');
		System.assertEquals(savedSettingsDesirialized.get('Lead.AppendInterest'), 'true');
		System.assertEquals(savedSettingsDesirialized.get('Lead.AppendPurchase'), 'true');	
	}

	public class LeadSettingsWrapper {
		protected Boolean ValidateEmail { get; set; }
		protected Boolean CorrectEmail { get; set; }
		protected Boolean AppendNameAddress { get; set; }
		protected Boolean EnableDemographics { get; set; }
		protected Boolean EmailActivityMetrics { get; set; }
		protected Boolean AppendDemographicBasics { get; set; }
		protected Boolean AppendHousing { get; set; }
		protected Boolean AppendInterest { get; set; }
		protected Boolean AppendPurchase { get; set; }
    }

// DataAppendApprovedSettings

	static testMethod void test_DataAppendApprovedSettings() {
		String settings = TouchCRAuraSettingsDAppendController.getApprovedSettingsApex();
		ApprovedSettingsWrapper settingsDesirialized = (ApprovedSettingsWrapper)System.JSON.deserialize(settings, ApprovedSettingsWrapper.class);
		System.debug(settingsDesirialized);
		System.debug(settingsDesirialized);
		System.assertEquals(null, settingsDesirialized.DALimit);
		System.assertEquals(null, settingsDesirialized.Excess);
		System.assertEquals(null, settingsDesirialized.Approver1);
		System.assertEquals(null, settingsDesirialized.Approver2);
		System.assertEquals(null, settingsDesirialized.Approver3);

		ApprovedSettingsWrapper settingsWrap = new ApprovedSettingsWrapper();

		Profile pr = [SELECT Id FROM Profile WHERE Name = 'Chatter Free User' LIMIT 1];

		User testUser = new User (Alias = 'sysadm', Email='sysadmin@test.com',
			EmailEncodingKey='UTF-8', LastName='TestSys', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = pr.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='123touchcrsysadmintest@123test.com'
		);
		insert testUser;

		Approver testApprover = new Approver();
		testApprover.Id = testUser.Id;
		testApprover.Name = testUser.LastName;
		

		settingsWrap.DALimit = 1;
		settingsWrap.Excess = 1;
		settingsWrap.Approver1 = testApprover;
		settingsWrap.Approver2 = testApprover;
		settingsWrap.Approver3 = testApprover;


		TouchCRAuraSettingsDAppendController.saveApproved(JSON.serialize(settingsWrap));
		String savedSettings = TouchCRAuraSettingsDAppendController.getApprovedSettingsApex();
		ApprovedSettingsWrapper savedSettingsDesirialized = (ApprovedSettingsWrapper)System.JSON.deserialize(savedSettings, ApprovedSettingsWrapper.class);
		System.debug(savedSettingsDesirialized);
		System.assertEquals(1, savedSettingsDesirialized.DALimit);
		System.assertEquals(1, savedSettingsDesirialized.Excess);
		System.assertEquals(String.valueOf(testUser.Id), savedSettingsDesirialized.Approver1.Id);
		System.assertEquals(String.valueOf(testUser.Id), savedSettingsDesirialized.Approver2.Id);
		System.assertEquals(String.valueOf(testUser.Id), savedSettingsDesirialized.Approver3.Id);
	}

	public class ApprovedSettingsWrapper {
		protected Integer DALimit { get; set; }
		protected Integer Excess { get; set; }
		protected Approver Approver1 { get; set; }
		protected Approver Approver2 { get; set; }
		protected Approver Approver3 { get; set; }
	}

	public class Approver {
		protected String Id { get; set; }
		protected String Name { get; set; }
	}

// FullContactGlobalSettings

	static testMethod void test_FullContactGlobalSettings() {
		String settings = TouchCRAuraSettingsDAppendController.getFullContactSettingsApex();
		Map<String, String> settingsDesirialized = (Map<String, String>)System.JSON.deserialize(settings, Map<String, String>.class);

		System.assertEquals(settingsDesirialized.get('FullContact.APIKey'), '');
		System.assertEquals(settingsDesirialized.get('FullContact.ReappendOnDays'), '');
		System.assertEquals(settingsDesirialized.get('FullContact.IgnoreOlderThan'), '');
		System.assertEquals(settingsDesirialized.get('FullContact.LeadAppendOnNew'), '');
		System.assertEquals(settingsDesirialized.get('FullContact.AccountAppendOnNew'), '');
		/*System.assertEquals(settingsDesirialized.get('FullContact.LeadAppendContactInfo'), '');
		System.assertEquals(settingsDesirialized.get('FullContact.LeadAppendLocation'), '');
		System.assertEquals(settingsDesirialized.get('FullContact.LeadAppendOrganizations'), '');
		System.assertEquals(settingsDesirialized.get('FullContact.AccountAppendContactInfo'), '');
		System.assertEquals(settingsDesirialized.get('FullContact.AccountAppendLocation'), '');
		System.assertEquals(settingsDesirialized.get('FullContact.AccountAppendOrganizations'), '');*/
		
		FullContactSettingsWrapper settingsWrap = new FullContactSettingsWrapper();
		settingsWrap.APIKey = 'test';
		settingsWrap.ReappendOnDays = '11';
		settingsWrap.IgnoreOlderThan = '2014-01-06';
		settingsWrap.LeadAppendOnNew = true;
		settingsWrap.AccountAppendOnNew = true;
		settingsWrap.LeadAppendContactInfo = true;
		settingsWrap.LeadAppendLocation = true;
		settingsWrap.LeadAppendOrganizations = true;
		settingsWrap.AccountAppendContactInfo = true;
		settingsWrap.AccountAppendLocation = true;
		settingsWrap.AccountAppendOrganizations = true;

		TouchCRAuraSettingsDAppendController.saveFullContact(JSON.serialize(settingsWrap));

		String savedSettings = TouchCRAuraSettingsDAppendController.getFullContactSettingsApex();

		Map<String, String> savedSettingsDesirialized = (Map<String, String>)System.JSON.deserialize(savedSettings, Map<String, String>.class);

		System.assertEquals(savedSettingsDesirialized.get('FullContact.APIKey'), 'test');
		System.assertEquals(savedSettingsDesirialized.get('FullContact.ReappendOnDays'), '11');
		System.assertEquals(savedSettingsDesirialized.get('FullContact.IgnoreOlderThan'), '2014-01-06');
		System.assertEquals(savedSettingsDesirialized.get('FullContact.LeadAppendOnNew'), 'true');
		System.assertEquals(savedSettingsDesirialized.get('FullContact.AccountAppendOnNew'), 'true');
		/*System.assertEquals(savedSettingsDesirialized.get('FullContact.LeadAppendContactInfo'), 'true');
		System.assertEquals(savedSettingsDesirialized.get('FullContact.LeadAppendLocation'), 'true');
		System.assertEquals(savedSettingsDesirialized.get('FullContact.LeadAppendOrganizations'), 'true');
		System.assertEquals(savedSettingsDesirialized.get('FullContact.AccountAppendContactInfo'), 'true');
		System.assertEquals(savedSettingsDesirialized.get('FullContact.AccountAppendLocation'), 'true');
		System.assertEquals(savedSettingsDesirialized.get('FullContact.AccountAppendOrganizations'), 'true');*/
	}

	public class FullContactSettingsWrapper {
		protected String APIKey { get; set; }
		protected String ReappendOnDays { get; set; }
		protected String IgnoreOlderThan { get; set; }
		protected Boolean LeadAppendOnNew { get; set; }
		protected Boolean AccountAppendOnNew { get; set; }
		protected Boolean LeadAppendContactInfo { get; set; }
		protected Boolean LeadAppendLocation { get; set; }
		protected Boolean LeadAppendOrganizations { get; set; }
		protected Boolean AccountAppendContactInfo { get; set; }
		protected Boolean AccountAppendLocation { get; set; }
		protected Boolean AccountAppendOrganizations { get; set; }	
	}

// FullContactApprovedSettings

	static testMethod void test_FullContactApprovedSettings() {
		String settings = TouchCRAuraSettingsDAppendController.getFcApprovedSettingsApex();
		FcApprovedSettingsWrapper settingsDesirialized = (FcApprovedSettingsWrapper)System.JSON.deserialize(settings, FcApprovedSettingsWrapper.class);
		System.debug(settingsDesirialized);
		System.debug(settingsDesirialized);
		System.assertEquals(null, settingsDesirialized.FCLimit);
		System.assertEquals(null, settingsDesirialized.Excess);
		System.assertEquals(null, settingsDesirialized.Approver1);
		System.assertEquals(null, settingsDesirialized.Approver2);
		System.assertEquals(null, settingsDesirialized.Approver3);

		FcApprovedSettingsWrapper settingsWrap = new FcApprovedSettingsWrapper();

		Profile pr = [SELECT Id FROM Profile WHERE Name = 'Chatter Free User' LIMIT 1];

		User testUser = new User (Alias = 'sysadm', Email='sysadmin@test.com',
			EmailEncodingKey='UTF-8', LastName='TestSys', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = pr.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='123touchcrsysadmintest@123test.com'
		);
		insert testUser;

		FcApprover testApprover = new FcApprover();
		testApprover.Id = testUser.Id;
		testApprover.Name = testUser.LastName;
		

		settingsWrap.FCLimit = 1;
		settingsWrap.Excess = 1;
		settingsWrap.Approver1 = testApprover;
		settingsWrap.Approver2 = testApprover;
		settingsWrap.Approver3 = testApprover;


		TouchCRAuraSettingsDAppendController.saveFcApproved(JSON.serialize(settingsWrap));
		String savedSettings = TouchCRAuraSettingsDAppendController.getFcApprovedSettingsApex();
		FcApprovedSettingsWrapper savedSettingsDesirialized = (FcApprovedSettingsWrapper)System.JSON.deserialize(savedSettings, FcApprovedSettingsWrapper.class);
		System.debug(savedSettingsDesirialized);
		System.assertEquals(1, savedSettingsDesirialized.FCLimit);
		System.assertEquals(1, savedSettingsDesirialized.Excess);
		System.assertEquals(String.valueOf(testUser.Id), savedSettingsDesirialized.Approver1.Id);
		System.assertEquals(String.valueOf(testUser.Id), savedSettingsDesirialized.Approver2.Id);
		System.assertEquals(String.valueOf(testUser.Id), savedSettingsDesirialized.Approver3.Id);
	}

	public class FcApprovedSettingsWrapper {
		protected Integer FCLimit { get; set; }
		protected Integer Excess { get; set; }
		protected FcApprover Approver1 { get; set; }
		protected FcApprover Approver2 { get; set; }
		protected FcApprover Approver3 { get; set; }
	}

	public class FcApprover {
		protected String Id { get; set; }
		protected String Name { get; set; }
	}
}