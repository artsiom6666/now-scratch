public class TouchCRAuraSettingsDAppendController {

// DataAppendGlobalSettings

    // GLOBAL settings 
	public static final Map<String, String> GLOBAL_SETTING_KEYS = new Map<String, String> {
		'Global.EmailOn' => 'Append Email On',
		'Global.AppendOnNewAccount' => 'Append on new Accounts',
		'Global.AppendOnNewLead' => 'Append on new Leads',
		'Global.ReappendOnDays' => 'Re-append on Days',
		'Global.IgnoreOlderThan' => 'Ignore data older than',
		'Global.License' => 'Tower Data License Key',
		'Global.APIKey' => 'Tower Data Demographics Key'
	};

    public static Map<String, String> getGlobalSettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}

	@auraEnabled
	public static String getGlobalSettingsApex() {

		return JSON.serialize(getGlobalSettings(GLOBAL_SETTING_KEYS.keySet()));
	}


	@auraEnabled
	public static String saveGlobal(String settings) {

		GlobalSettingsWrapper settingsDeserialized = (GlobalSettingsWrapper)JSON.deserialize(settings, GlobalSettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();

		Map<String, String> globalSettings = getGlobalSettings(GLOBAL_SETTING_KEYS.keySet());


		String emailOn = globalSettings.get('Global.EmailOn');
		emailOn = String.valueOf(settingsDeserialized.EmailOn);
		settingsToUpsert.put('Global.EmailOn', emailOn);

		String appendOnNewAccount = globalSettings.get('Global.AppendOnNewAccount');
		appendOnNewAccount = String.valueOf(settingsDeserialized.AppendOnNewAccount);
		settingsToUpsert.put('Global.AppendOnNewAccount', appendOnNewAccount);

		String appendOnNewLead = globalSettings.get('Global.AppendOnNewLead');
		appendOnNewLead = String.valueOf(settingsDeserialized.AppendOnNewLead);
		settingsToUpsert.put('Global.AppendOnNewLead', appendOnNewLead);
		
		String reappendOnDays = globalSettings.get('Global.ReappendOnDays');
		reappendOnDays = settingsDeserialized.ReappendOnDays;
		settingsToUpsert.put('Global.ReappendOnDays', reappendOnDays);

		String ignoreOlderThan = globalSettings.get('Global.IgnoreOlderThan');
		ignoreOlderThan = String.valueOf(settingsDeserialized.IgnoreOlderThan);
		settingsToUpsert.put('Global.IgnoreOlderThan', ignoreOlderThan);

		String license = globalSettings.get('Global.License');
		license = settingsDeserialized.License;
		settingsToUpsert.put('Global.License', license);

		String apiKey = globalSettings.get('Global.APIKey');
		apiKey = settingsDeserialized.APIKey;
		settingsToUpsert.put('Global.APIKey', apiKey);

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'Global Settings have been successfully saved!';
		} else {
			return 'Error! ';
		}
	}

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

	// GLOBAL settings 
	// LC settings BOOLEAN
	public static final Map<String, String> LC_SETTING_KEYS = new Map<String, String> {
		'Global.LeadConvert' => 'Re-append on Lead to Account Convert',
		'Global.LeadAccountAged' => 'Re-append on Lead to Account Aged'
	};

	public static Map<String, String> getLeadConversionSettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}

	@auraEnabled
	public static String getLeadConversionSettingsApex() {

		return JSON.serialize(getLeadConversionSettings(LC_SETTING_KEYS.keySet()));
	}


	@auraEnabled
	public static String saveLeadConversion(String settings) {

		LeadConversionSettingsWrapper settingsDeserialized = (LeadConversionSettingsWrapper)JSON.deserialize(settings, LeadConversionSettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();

		Map<String, String> globalSettings = getLeadConversionSettings(LC_SETTING_KEYS.keySet());

		String leadConvert = globalSettings.get('Global.LeadConvert');
		leadConvert = String.valueOf(settingsDeserialized.LeadConvert);
		settingsToUpsert.put('Global.LeadConvert', leadConvert);

		String leadAccountAged = globalSettings.get('Global.LeadAccountAged');
		leadAccountAged = String.valueOf(settingsDeserialized.LeadAccountAged);
		settingsToUpsert.put('Global.LeadAccountAged', leadAccountAged);

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'Lead Conversion Settings have been successfully saved!';
		} else {
			return 'Error! ';
		}
	}

	public class LeadConversionSettingsWrapper {
		protected Boolean LeadConvert { get; set; }
		protected Integer LeadAccountAged { get; set; }
	}

// DataAppendAccountSettings

	// ACCOUNT settings
	public static final Map<String, String> ACCOUNT_SETTING_KEYS = new Map<String, String> {
		'Account.ValidateEmail' => 'Validate Email on Account',
		'Account.CorrectEmail' => 'Correct Email on Account',
		'Account.AppendNameAddress' => 'Append Name & Address on Account',
		'Account.EnableDemographics' => 'Enable Demographics on Account',
		'Account.EmailActivityMetrics' => 'Email Activity Metrics on Account',
		'Account.AppendDemographicBasics' => 'Append Demographic Basics on Account',
		'Account.AppendHousing' => 'Append Housing on Account',
		'Account.AppendInterest' => 'Append Interest on Account',
		'Account.AppendPurchase' => 'Append Purchase on Account'
	};

	public static Map<String, String> getAccountSettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}

	@auraEnabled
	public static String getAccountSettingsApex() {

		return JSON.serialize(getAccountSettings(ACCOUNT_SETTING_KEYS.keySet()));
	}


	@auraEnabled
	public static String saveAccount(String settings) {

		AccountSettingsWrapper settingsDeserialized = (AccountSettingsWrapper)JSON.deserialize(settings, AccountSettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();

		Map<String, String> accountSettings = getAccountSettings(ACCOUNT_SETTING_KEYS.keySet());

		String validateEmail = accountSettings.get('Account.ValidateEmail');
		validateEmail = String.valueOf(settingsDeserialized.ValidateEmail);
		settingsToUpsert.put('Account.ValidateEmail', validateEmail);

		String correctEmail = accountSettings.get('Account.CorrectEmail');
		correctEmail = String.valueOf(settingsDeserialized.CorrectEmail);
		settingsToUpsert.put('Account.CorrectEmail', correctEmail);

		String appendNameAddress = accountSettings.get('Account.AppendNameAddress');
		appendNameAddress = String.valueOf(settingsDeserialized.AppendNameAddress);
		settingsToUpsert.put('Account.AppendNameAddress', appendNameAddress);

		String enableDemographics = accountSettings.get('Account.EnableDemographics');
		enableDemographics = String.valueOf(settingsDeserialized.EnableDemographics);
		settingsToUpsert.put('Account.EnableDemographics', enableDemographics);

		String emailActivityMetrics = accountSettings.get('Account.EmailActivityMetrics');
		emailActivityMetrics = String.valueOf(settingsDeserialized.EmailActivityMetrics);
		settingsToUpsert.put('Account.EmailActivityMetrics', emailActivityMetrics);

		String appendDemographicBasics = accountSettings.get('Account.AppendDemographicBasics');
		appendDemographicBasics = String.valueOf(settingsDeserialized.AppendDemographicBasics);
		settingsToUpsert.put('Account.AppendDemographicBasics', appendDemographicBasics);

		String appendHousing = accountSettings.get('Account.AppendHousing');
		appendHousing = String.valueOf(settingsDeserialized.AppendHousing);
		settingsToUpsert.put('Account.AppendHousing', appendHousing);

		String appendInterest = accountSettings.get('Account.AppendInterest');
		appendInterest = String.valueOf(settingsDeserialized.AppendInterest);
		settingsToUpsert.put('Account.AppendInterest', appendInterest);

		String appendPurchase = accountSettings.get('Account.AppendPurchase');
		appendPurchase = String.valueOf(settingsDeserialized.AppendPurchase);
		settingsToUpsert.put('Account.AppendPurchase', appendPurchase);

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'Account Settings have been successfully saved!';
		} else {
			return 'Error! ';
		}
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

	// Lead settings
    public static final Map<String, String> Lead_SETTING_KEYS = new Map<String, String> {
        'Lead.ValidateEmail' => 'Validate Email on Lead',
        'Lead.CorrectEmail' => 'Correct Email on Lead',
        'Lead.AppendNameAddress' => 'Append Name & Address on Lead',
        'Lead.EnableDemographics' => 'Enable Demographics on Lead',
        'Lead.EmailActivityMetrics' => 'Email Activity Metrics on Lead',
        'Lead.AppendDemographicBasics' => 'Append Demographic Basics on Lead',
        'Lead.AppendHousing' => 'Append Housing on Lead',
        'Lead.AppendInterest' => 'Append Interest on Lead',
        'Lead.AppendPurchase' => 'Append Purchase on Lead'
    };

    public static Map<String, String> getLeadSettings(Set<String> keys) {
        Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
        Map<String, String> result = new Map<String, String>();
        for (String settingKey : keys) {
            if (settingsMap.containsKey(settingKey)) {
                result.put(settingKey, settingsMap.get(settingKey));
            }
            else {
                result.put(settingKey, '');
            }
        }
        return result;
    }

    @auraEnabled
    public static String getLeadSettingsApex() {

        return JSON.serialize(getLeadSettings(Lead_SETTING_KEYS.keySet()));
    }


    @auraEnabled
    public static String saveLead(String settings) {

        LeadSettingsWrapper settingsDeserialized = (LeadSettingsWrapper)JSON.deserialize(settings, LeadSettingsWrapper.class);
        Map<String, String> settingsToUpsert = new Map<String, String>();

        Map<String, String> leadSettings = getLeadSettings(Lead_SETTING_KEYS.keySet());

        String validateEmail = leadSettings.get('Lead.ValidateEmail');
        validateEmail = String.valueOf(settingsDeserialized.ValidateEmail);
        settingsToUpsert.put('Lead.ValidateEmail', validateEmail);

        String correctEmail = leadSettings.get('Lead.CorrectEmail');
        correctEmail = String.valueOf(settingsDeserialized.CorrectEmail);
        settingsToUpsert.put('Lead.CorrectEmail', correctEmail);

        String appendNameAddress = leadSettings.get('Lead.AppendNameAddress');
        appendNameAddress = String.valueOf(settingsDeserialized.AppendNameAddress);
        settingsToUpsert.put('Lead.AppendNameAddress', appendNameAddress);

        String enableDemographics = leadSettings.get('Lead.EnableDemographics');
        enableDemographics = String.valueOf(settingsDeserialized.EnableDemographics);
        settingsToUpsert.put('Lead.EnableDemographics', enableDemographics);

        String emailActivityMetrics = leadSettings.get('Lead.EmailActivityMetrics');
        emailActivityMetrics = String.valueOf(settingsDeserialized.EmailActivityMetrics);
        settingsToUpsert.put('Lead.EmailActivityMetrics', emailActivityMetrics);

        String appendDemographicBasics = leadSettings.get('Lead.AppendDemographicBasics');
        appendDemographicBasics = String.valueOf(settingsDeserialized.AppendDemographicBasics);
        settingsToUpsert.put('Lead.AppendDemographicBasics', appendDemographicBasics);

        String appendHousing = leadSettings.get('Lead.AppendHousing');
        appendHousing = String.valueOf(settingsDeserialized.AppendHousing);
        settingsToUpsert.put('Lead.AppendHousing', appendHousing);

        String appendInterest = leadSettings.get('Lead.AppendInterest');
        appendInterest = String.valueOf(settingsDeserialized.AppendInterest);
        settingsToUpsert.put('Lead.AppendInterest', appendInterest);

        String appendPurchase = leadSettings.get('Lead.AppendPurchase');
        appendPurchase = String.valueOf(settingsDeserialized.AppendPurchase);
        settingsToUpsert.put('Lead.AppendPurchase', appendPurchase);

        if (!settingsToUpsert.isEmpty()) {
            TouchCRHelper.setSettings(settingsToUpsert);
            return 'Lead Settings have been successfully saved!';
        } else {
            return 'Error! ';
        }
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

	// APPROVED settings
	public static final Map<String, String> APPROVED_SETTING = new Map<String, String> {
		'DataAppend.Limit' => '0',
		'DataAppend.Excess' => '0',
		'DataAppend.Confirmed' => 'false',
		'DataAppend.Approver1' => 'null',
		'DataAppend.Approver2' => 'null',
		'DataAppend.Approver3' => 'null',
		'DataAppend.ApproverEmail1' => 'null',
		'DataAppend.ApproverEmail2' => 'null',
		'DataAppend.ApproverEmail3' => 'null',
		'DataAppend.DateTimeApprove' => ''
	};

	public static Map<String, String> getApprovedSettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}

	@auraEnabled
	public static String getApprovedSettingsApex() {
		Map<String, String> personApprovedSettings = getApprovedSettings(APPROVED_SETTING.keySet());

		List<String> personApprovedIds = new List<String>();

		ApprovedSettingsWrapper sw = new ApprovedSettingsWrapper();


		String daLimit = personApprovedSettings.get('DataAppend.Limit');
		if (String.isNotBlank(daLimit)) {
			sw.DaLimit = Integer.valueOf(daLimit);
		}

		String excess = personApprovedSettings.get('DataAppend.Excess');
		if (String.isNotBlank(excess)) {
			sw.Excess = Integer.valueOf(excess);
		}



		String newDataAppendApprover1Setting = personApprovedSettings.get('DataAppend.Approver1');
		if (String.isNotBlank(newDataAppendApprover1Setting)) {
			personApprovedIds.add(newDataAppendApprover1Setting);
		}

		String newDataAppendApprover2Setting = personApprovedSettings.get('DataAppend.Approver2');
		if (String.isNotBlank(newDataAppendApprover2Setting)) {
			personApprovedIds.add(newDataAppendApprover2Setting);
		}

		String newDataAppendApprover3Setting = personApprovedSettings.get('DataAppend.Approver3');
		if (String.isNotBlank(newDataAppendApprover3Setting)) {
			personApprovedIds.add(newDataAppendApprover3Setting);
		}


		List<User> personApprovedUsers = [SELECT Id, Name FROM User WHERE Id IN: personApprovedIds];

		for (User personApprovedUser : personApprovedUsers) {
			Approver approverW = new Approver();
			approverW.Id = personApprovedUser.Id;
			approverW.Name = personApprovedUser.Name;
			if (String.isNotEmpty(personApprovedSettings.get('DataAppend.Approver1')) && personApprovedUser.Id == personApprovedSettings.get('DataAppend.Approver1')) {
				sw.Approver1 = approverW;
			}
			if (String.isNotEmpty(personApprovedSettings.get('DataAppend.Approver2')) && personApprovedUser.Id == personApprovedSettings.get('DataAppend.Approver2')) {
				sw.Approver2 = approverW;
			}
			if (String.isNotEmpty(personApprovedSettings.get('DataAppend.Approver3')) && personApprovedUser.Id == personApprovedSettings.get('DataAppend.Approver3')) {
				sw.Approver3 = approverW;
			}
		}

		return JSON.serialize(sw);
	}

	@auraEnabled
	public static List<User> getApprovedUsersApex() {
		List<User> users = [SELECT Id, Name, Email FROM User ORDER BY Name LIMIT 50000];

		return users;
	}


	@auraEnabled
	public static String saveApproved(String settings) {

		ApprovedSettingsWrapper settingsDeserialized = (ApprovedSettingsWrapper)JSON.deserialize(settings, ApprovedSettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();
		Map<String, String> personApprovedSettings = getApprovedSettings(APPROVED_SETTING.keySet());
		
		//Accounts for standard lookup fields
		Account approverId1 = new Account();
		Account approverId2 = new Account();
		Account approverId3 = new Account();

		if (String.isNotBlank(settingsDeserialized.Approver1.Id)) {
			approverId1.OwnerId = settingsDeserialized.Approver1.Id;
		}
		if (String.isNotBlank(settingsDeserialized.Approver2.Id)) {
			approverId2.OwnerId = settingsDeserialized.Approver2.Id;
		}
		if (String.isNotBlank(settingsDeserialized.Approver3.Id)) {
			approverId3.OwnerId = settingsDeserialized.Approver3.Id;
		}

		//Setting DATAAPPEND
		if (String.isBlank(approverId1.OwnerId)) {
			if (personApprovedSettings.get('DataAppend.Approver1') != '') {
				String newDataAppendApprover1Setting = personApprovedSettings.get('DataAppend.Approver1');
				newDataAppendApprover1Setting = '';
				settingsToUpsert.put('DataAppend.Approver1', newDataAppendApprover1Setting);
			}
		}
		else if (personApprovedSettings.get('DataAppend.Approver1') != String.valueOf(approverId1.OwnerId)) {
			String newDataAppendApprover1Setting = personApprovedSettings.get('DataAppend.Approver1');
			newDataAppendApprover1Setting = String.valueOf(approverId1.OwnerId);
			settingsToUpsert.put('DataAppend.Approver1', newDataAppendApprover1Setting);
		}

		if (String.isBlank(approverId2.OwnerId)) {
			if (personApprovedSettings.get('DataAppend.Approver2') != '') {
				String newDataAppendApprover2Setting = personApprovedSettings.get('DataAppend.Approver2');
				newDataAppendApprover2Setting = '';
				settingsToUpsert.put('DataAppend.Approver2', newDataAppendApprover2Setting);
			}
		}
		else if (personApprovedSettings.get('DataAppend.Approver2') != String.valueOf(approverId2.OwnerId)) {
			String newDataAppendApprover2Setting = personApprovedSettings.get('DataAppend.Approver2');
			newDataAppendApprover2Setting = String.valueOf(approverId2.OwnerId);
			settingsToUpsert.put('DataAppend.Approver2', newDataAppendApprover2Setting);
		}

		if (String.isBlank(approverId3.OwnerId)) {
			if (personApprovedSettings.get('DataAppend.Approver3') != '') {
				String newDataAppendApprover3Setting = personApprovedSettings.get('DataAppend.Approver3');
				newDataAppendApprover3Setting = '';
				settingsToUpsert.put('DataAppend.Approver3', newDataAppendApprover3Setting);
			}
		}
		else if (personApprovedSettings.get('DataAppend.Approver3') != String.valueOf(approverId3.OwnerId)) {
			String newDataAppendApprover3Setting = personApprovedSettings.get('DataAppend.Approver3');
			newDataAppendApprover3Setting = String.valueOf(approverId3.OwnerId);
			settingsToUpsert.put('DataAppend.Approver3', newDataAppendApprover3Setting);
		}

		//Collect Id approver for finding Emails
		Set<Id> userApproverIds = new Set<Id>();
		if (String.isNotBlank(approverId1.OwnerId)) {
			userApproverIds.add(approverId1.OwnerId);
		}
		if (String.isNotBlank(approverId2.OwnerId)) {
			userApproverIds.add(approverId2.OwnerId);
		}
		if (String.isNotBlank(approverId3.OwnerId)) {
			userApproverIds.add(approverId3.OwnerId);
		}

		Map<Id, User> approverUsers = new Map<Id, User>();
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'User',
				'DataAppendApprovedSettingsController.cls [save]',
				new List<Schema.DescribeFieldResult> {
					User.Email.getDescribe()
				}
			);
			//Search mail for users
			approverUsers = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN: userApproverIds]);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

		if (approverUsers.containsKey(approverId1.OwnerId)) {
			String newDataAppendApproverEmail1Setting = personApprovedSettings.get('DataAppend.ApproverEmail1');
			newDataAppendApproverEmail1Setting = approverUsers.get(approverId1.OwnerId).Email;
			settingsToUpsert.put('DataAppend.ApproverEmail1', newDataAppendApproverEmail1Setting);
		}

		if (approverUsers.containsKey(approverId2.OwnerId)) {
			String newDataAppendApproverEmail2Setting = personApprovedSettings.get('DataAppend.ApproverEmail2');
			newDataAppendApproverEmail2Setting = approverUsers.get(approverId2.OwnerId).Email;
			settingsToUpsert.put('DataAppend.ApproverEmail2', newDataAppendApproverEmail2Setting);
		}

		if (approverUsers.containsKey(approverId3.OwnerId)) {
			String newDataAppendApproverEmail3Setting = personApprovedSettings.get('DataAppend.ApproverEmail3');
			newDataAppendApproverEmail3Setting = approverUsers.get(approverId3.OwnerId).Email;
			settingsToUpsert.put('DataAppend.ApproverEmail3', newDataAppendApproverEmail3Setting);
		}

		if (personApprovedSettings.get('DataAppend.Limit') != String.valueOf(settingsDeserialized.DALimit)) {
			String newDataAppendLimitSetting = personApprovedSettings.get('DataAppend.Limit');
			newDataAppendLimitSetting = String.valueOf(settingsDeserialized.DALimit);
			settingsToUpsert.put('DataAppend.Limit', newDataAppendLimitSetting);
		}
		if (personApprovedSettings.get('DataAppend.Excess') != String.valueOf(settingsDeserialized.Excess)) {
			String newDataAppendExcessSetting = personApprovedSettings.get('DataAppend.Excess');
			newDataAppendExcessSetting = String.valueOf(settingsDeserialized.Excess);
			settingsToUpsert.put('DataAppend.Excess', newDataAppendExcessSetting);
		}

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'Data Append Approved Settings have been successfully saved!';
		} else {
			return 'Error! ';
		}
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

// FULLCONTACT settings

	// FullContact settings 
	public static final Map<String, String> FULLCONTACT_SETTING_KEYS = new Map<String, String> {
		'FullContact.APIKey' => 'FullContact APIKey',
		'FullContact.ReappendOnDays' => 'Re-append on Days',
		'FullContact.IgnoreOlderThan' => 'Ignore data older than',
		'FullContact.LeadAppendOnNew' => 'Append On New Lead',
		'FullContact.AccountAppendOnNew' => 'Append On New Account'
		/*'FullContact.LeadAppendContactInfo' => 'Lead: Append Contact Info',
		'FullContact.LeadAppendLocation' => 'Lead: Append Location',
		'FullContact.LeadAppendOrganizations' => 'Lead: Append Organizations',
		'FullContact.AccountAppendContactInfo' => 'Account: Append Contact Info',
		'FullContact.AccountAppendLocation' => 'Account: Append Location',
		'FullContact.AccountAppendOrganizations' => 'Account: Append Organizations'*/
	};

	public static Map<String, String> getFullContactSettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}

	@auraEnabled
	public static String getFullContactSettingsApex() {

		return JSON.serialize(getFullContactSettings(FULLCONTACT_SETTING_KEYS.keySet()));
	}


	@auraEnabled
	public static String saveFullContact(String settings) {

		FullContactSettingsWrapper settingsDeserialized = (FullContactSettingsWrapper)JSON.deserialize(settings, FullContactSettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();

		Map<String, String> globalSettings = getGlobalSettings(FULLCONTACT_SETTING_KEYS.keySet());

		String apiKey = globalSettings.get('FullContact.APIKey');
		apiKey = String.valueOf(settingsDeserialized.APIKey);
		settingsToUpsert.put('FullContact.APIKey', apiKey);

		String reappendOnDays = globalSettings.get('FullContact.ReappendOnDays');
		reappendOnDays = String.valueOf(settingsDeserialized.ReappendOnDays);
		settingsToUpsert.put('FullContact.ReappendOnDays', reappendOnDays);

		String ignoreOlderThan = globalSettings.get('FullContact.IgnoreOlderThan');
		ignoreOlderThan = String.valueOf(settingsDeserialized.IgnoreOlderThan);
		settingsToUpsert.put('FullContact.IgnoreOlderThan', ignoreOlderThan);

		String leadAppendOnNew = globalSettings.get('FullContact.LeadAppendOnNew');
		leadAppendOnNew = String.valueOf(settingsDeserialized.LeadAppendOnNew);
		settingsToUpsert.put('FullContact.LeadAppendOnNew', leadAppendOnNew);

		String accountAppendOnNew = globalSettings.get('FullContact.AccountAppendOnNew');
		accountAppendOnNew = String.valueOf(settingsDeserialized.AccountAppendOnNew);
		settingsToUpsert.put('FullContact.AccountAppendOnNew', accountAppendOnNew);

		/*String leadAppendContactInfo = globalSettings.get('FullContact.LeadAppendContactInfo');
		leadAppendContactInfo = String.valueOf(settingsDeserialized.LeadAppendContactInfo);
		settingsToUpsert.put('FullContact.LeadAppendContactInfo', leadAppendContactInfo);

		String leadAppendLocation = globalSettings.get('FullContact.LeadAppendLocation');
		leadAppendLocation = String.valueOf(settingsDeserialized.LeadAppendLocation);
		settingsToUpsert.put('FullContact.LeadAppendLocation', leadAppendLocation);

		String leadAppendOrganizations = globalSettings.get('FullContact.LeadAppendOrganizations');
		leadAppendOrganizations = String.valueOf(settingsDeserialized.LeadAppendOrganizations);
		settingsToUpsert.put('FullContact.LeadAppendOrganizations', leadAppendOrganizations);

		String accountAppendContactInfo = globalSettings.get('FullContact.AccountAppendContactInfo');
		accountAppendContactInfo = String.valueOf(settingsDeserialized.AccountAppendContactInfo);
		settingsToUpsert.put('FullContact.AccountAppendContactInfo', accountAppendContactInfo);

		String accountAppendLocation = globalSettings.get('FullContact.AccountAppendLocation');
		accountAppendLocation = String.valueOf(settingsDeserialized.AccountAppendLocation);
		settingsToUpsert.put('FullContact.AccountAppendLocation', accountAppendLocation);

		String accountAppendOrganizations = globalSettings.get('FullContact.AccountAppendOrganizations');
		accountAppendOrganizations = String.valueOf(settingsDeserialized.AccountAppendOrganizations);
		settingsToUpsert.put('FullContact.AccountAppendOrganizations', accountAppendOrganizations);*/

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'FullContact Settings have been successfully saved!';
		} else {
			return 'Error! ';
		}
	}

	public class FullContactSettingsWrapper {
		protected String APIKey { get; set; }
		protected String ReappendOnDays { get; set; }
		protected String IgnoreOlderThan { get; set; }
		protected Boolean LeadAppendOnNew { get; set; }
		protected Boolean AccountAppendOnNew { get; set; }
		/*protected Boolean LeadAppendContactInfo { get; set; }
		protected Boolean LeadAppendLocation { get; set; }
		protected Boolean LeadAppendOrganizations { get; set; }
		protected Boolean AccountAppendContactInfo { get; set; }
		protected Boolean AccountAppendLocation { get; set; }
		protected Boolean AccountAppendOrganizations { get; set; }*/
	}

	// Approved settings
	public static final Map<String, String> FC_APPROVED_SETTING = new Map<String, String> {
		'FullContact.Limit' => '0',
		'FullContact.Excess' => '0',
		'FullContact.Confirmed' => 'false',
		'FullContact.Approver1' => 'null',
		'FullContact.Approver2' => 'null',
		'FullContact.Approver3' => 'null',
		'FullContact.ApproverEmail1' => 'null',
		'FullContact.ApproverEmail2' => 'null',
		'FullContact.ApproverEmail3' => 'null',
		'FullContact.DateTimeApprove' => ''
	};

	public static Map<String, String> getFcApprovedSettings(Set<String> keys) {
		Map<String, String> settingsMap = TouchCRHelper.getSettings('allSettings');
		Map<String, String> result = new Map<String, String>();
		for (String settingKey : keys) {
			if (settingsMap.containsKey(settingKey)) {
				result.put(settingKey, settingsMap.get(settingKey));
			}
			else {
				result.put(settingKey, '');
			}
		}
		return result;
	}

	@auraEnabled
	public static String getFcApprovedSettingsApex() {
		Map<String, String> personApprovedSettings = getFcApprovedSettings(FC_APPROVED_SETTING.keySet());

		List<String> personApprovedIds = new List<String>();

		FcApprovedSettingsWrapper sw = new FcApprovedSettingsWrapper();


		String fcLimit = personApprovedSettings.get('FullContact.Limit');
		if (String.isNotBlank(fcLimit)) {
			sw.FCLimit = Integer.valueOf(fcLimit);
		}

		String excess = personApprovedSettings.get('FullContact.Excess');
		if (String.isNotBlank(excess)) {
			sw.Excess = Integer.valueOf(excess);
		}



		String newDataAppendApprover1Setting = personApprovedSettings.get('FullContact.Approver1');
		if (String.isNotBlank(newDataAppendApprover1Setting)) {
			personApprovedIds.add(newDataAppendApprover1Setting);
		}

		String newDataAppendApprover2Setting = personApprovedSettings.get('FullContact.Approver2');
		if (String.isNotBlank(newDataAppendApprover2Setting)) {
			personApprovedIds.add(newDataAppendApprover2Setting);
		}

		String newDataAppendApprover3Setting = personApprovedSettings.get('FullContact.Approver3');
		if (String.isNotBlank(newDataAppendApprover3Setting)) {
			personApprovedIds.add(newDataAppendApprover3Setting);
		}

		List<User> personApprovedUsers = [SELECT Id, Name FROM User WHERE Id IN: personApprovedIds];

		for (User personApprovedUser : personApprovedUsers) {
			FcApprover approverW = new FcApprover();
			approverW.Id = personApprovedUser.Id;
			approverW.Name = personApprovedUser.Name;

			if (String.isNotEmpty(personApprovedSettings.get('FullContact.Approver1')) && personApprovedUser.Id == personApprovedSettings.get('FullContact.Approver1')) {
				sw.Approver1 = approverW;
			}
			if (String.isNotEmpty(personApprovedSettings.get('FullContact.Approver2')) && personApprovedUser.Id == personApprovedSettings.get('FullContact.Approver2')) {
				sw.Approver2 = approverW;
			}
			if (String.isNotEmpty(personApprovedSettings.get('FullContact.Approver3')) && personApprovedUser.Id == personApprovedSettings.get('FullContact.Approver3')) {
				sw.Approver3 = approverW;
			}

		}
		return JSON.serialize(sw);
	}

	@auraEnabled
	public static List<User> getFcApprovedUsersApex() {
		List<User> users = [SELECT Id, Name, Email FROM User ORDER BY Name LIMIT 50000];
		
		return users;
	}


	@auraEnabled
	public static String saveFcApproved(String settings) {

		FcApprovedSettingsWrapper settingsDeserialized = (FcApprovedSettingsWrapper)JSON.deserialize(settings, FcApprovedSettingsWrapper.class);
		Map<String, String> settingsToUpsert = new Map<String, String>();
		Map<String, String> personApprovedSettings = getApprovedSettings(FC_APPROVED_SETTING.keySet());
		
		//Accounts for standard lookup fields
		Account approverId1 = new Account();
		Account approverId2 = new Account();
		Account approverId3 = new Account();

		if (String.isNotBlank(settingsDeserialized.Approver1.Id)) {
			approverId1.OwnerId = settingsDeserialized.Approver1.Id;
		}
		if (String.isNotBlank(settingsDeserialized.Approver2.Id)) {
			approverId2.OwnerId = settingsDeserialized.Approver2.Id;
		}
		if (String.isNotBlank(settingsDeserialized.Approver3.Id)) {
			approverId3.OwnerId = settingsDeserialized.Approver3.Id;
		}

		//Setting DATAAPPEND
		if (String.isBlank(approverId1.OwnerId)) {
			if (personApprovedSettings.get('FullContact.Approver1') != '') {
				String newFullContactdApprover1Setting = personApprovedSettings.get('FullContact.Approver1');
				newFullContactdApprover1Setting = '';
				settingsToUpsert.put('FullContact.Approver1', newFullContactdApprover1Setting);
			}
		}
		else if (personApprovedSettings.get('FullContact.Approver1') != String.valueOf(approverId1.OwnerId)) {
			String newFullContactdApprover1Setting = personApprovedSettings.get('FullContact.Approver1');
			newFullContactdApprover1Setting = String.valueOf(approverId1.OwnerId);
			settingsToUpsert.put('FullContact.Approver1', newFullContactdApprover1Setting);
		}

		if (String.isBlank(approverId2.OwnerId)) {
			if (personApprovedSettings.get('FullContact.Approver2') != '') {
				String newFullContactApprover2Setting = personApprovedSettings.get('FullContact.Approver2');
				newFullContactApprover2Setting = '';
				settingsToUpsert.put('FullContact.Approver2', newFullContactApprover2Setting);
			}
		}
		else if (personApprovedSettings.get('FullContact.Approver2') != String.valueOf(approverId2.OwnerId)) {
			String newFullContactApprover2Setting = personApprovedSettings.get('FullContact.Approver2');
			newFullContactApprover2Setting = String.valueOf(approverId2.OwnerId);
			settingsToUpsert.put('FullContact.Approver2', newFullContactApprover2Setting);
		}

		if (String.isBlank(approverId3.OwnerId)) {
			if (personApprovedSettings.get('FullContact.Approver3') != '') {
				String newFullContactApprover3Setting = personApprovedSettings.get('FullContact.Approver3');
				newFullContactApprover3Setting = '';
				settingsToUpsert.put('FullContact.Approver3', newFullContactApprover3Setting);
			}
		}
		else if (personApprovedSettings.get('FullContact.Approver3') != String.valueOf(approverId3.OwnerId)) {
			String newFullContactApprover3Setting = personApprovedSettings.get('FullContact.Approver3');
			newFullContactApprover3Setting = String.valueOf(approverId3.OwnerId);
			settingsToUpsert.put('FullContact.Approver3', newFullContactApprover3Setting);
		}

		//Collect Id approver for finding Emails
		Set<Id> userApproverIds = new Set<Id>();
		if (String.isNotBlank(approverId1.OwnerId)) {
			userApproverIds.add(approverId1.OwnerId);
		}
		if (String.isNotBlank(approverId2.OwnerId)) {
			userApproverIds.add(approverId2.OwnerId);
		}
		if (String.isNotBlank(approverId3.OwnerId)) {
			userApproverIds.add(approverId3.OwnerId);
		}

		Map<Id, User> approverUsers = new Map<Id, User>();
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'User',
				'DataAppendApprovedSettingsController.cls [save]',
				new List<Schema.DescribeFieldResult> {
					User.Email.getDescribe()
				}
			);
			//Search mail for users
			approverUsers = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN: userApproverIds]);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

		if (approverUsers.containsKey(approverId1.OwnerId)) {
			String newFullContactApproverEmail1Setting = personApprovedSettings.get('FullContact.ApproverEmail1');
			newFullContactApproverEmail1Setting = approverUsers.get(approverId1.OwnerId).Email;
			settingsToUpsert.put('FullContact.ApproverEmail1', newFullContactApproverEmail1Setting);
		}

		if (approverUsers.containsKey(approverId2.OwnerId)) {
			String newFullContactApproverEmail2Setting = personApprovedSettings.get('FullContact.ApproverEmail2');
			newFullContactApproverEmail2Setting = approverUsers.get(approverId2.OwnerId).Email;
			settingsToUpsert.put('FullContact.ApproverEmail2', newFullContactApproverEmail2Setting);
		}

		if (approverUsers.containsKey(approverId3.OwnerId)) {
			String newFullContactApproverEmail3Setting = personApprovedSettings.get('FullContact.ApproverEmail3');
			newFullContactApproverEmail3Setting = approverUsers.get(approverId3.OwnerId).Email;
			settingsToUpsert.put('FullContact.ApproverEmail3', newFullContactApproverEmail3Setting);
		}

		if (personApprovedSettings.get('FullContact.Limit') != String.valueOf(settingsDeserialized.FCLimit)) {
			String newFullContactLimitSetting = personApprovedSettings.get('FullContact.Limit');
			newFullContactLimitSetting = String.valueOf(settingsDeserialized.FCLimit);
			settingsToUpsert.put('FullContact.Limit', newFullContactLimitSetting);
		}
		if (personApprovedSettings.get('FullContact.Excess') != String.valueOf(settingsDeserialized.Excess)) {
			String newFullContactExcessSetting = personApprovedSettings.get('FullContact.Excess');
			newFullContactExcessSetting = String.valueOf(settingsDeserialized.Excess);
			settingsToUpsert.put('FullContact.Excess', newFullContactExcessSetting);
		}

		if (!settingsToUpsert.isEmpty()) {
			TouchCRHelper.setSettings(settingsToUpsert);
			return 'FullContact Approved Settings have been successfully saved!';
		} else {
			return 'Error! ';
		}
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