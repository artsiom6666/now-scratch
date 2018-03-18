public with sharing class TouchCRConfigurationController {
	public Boolean touchCRWoo { get; set; }
	public Boolean touchCRPaypal { get; set; }
	public Boolean touchCRShopify { get; set; }
	public Boolean touchCRMagento { get; set; }
	public Boolean touchCRAmazon { get; set; }
	public Boolean touchCRJet { get; set; }
	public Boolean touchCRAffiliate { get; set; }

	public Boolean isAbleMinfraud { get; set; }
	public Boolean isAbleUsps { get; set; }
	public Boolean isAbleDataAppend { get; set; }

	public List<SelectOption> namedCredentials { get; set; }
	public List<SelectOption> nameBrands { get; set; }
	public List<SelectOption> shopifyCallOut { get; set; }
	public List<SelectOption> shopifySchedule { get; set; }
	public List<SelectOption> wooCallOut { get; set; }
	public List<SelectOption> wooSchedule { get; set; }

	public TouchCRConfigurationController() {
		Set<String> namespacePrefixSet = getNamespacePrefix();
		this.namedCredentials = getNamedCredential();
		this.nameBrands = getNameBrands();
		this.shopifyCallOut = getCallOut();
		this.shopifySchedule = getSchedule();
		this.wooCallOut = getCallOut();
		this.wooSchedule = getSchedule();

		this.touchCRWoo = namespacePrefixSet.contains('TouchCRWC') ? true : false;
		this.touchCRPaypal = namespacePrefixSet.contains('TouchCRLCart') ? true : false;
		this.touchCRShopify = namespacePrefixSet.contains('TouchCRShop') ? true : false;
		this.touchCRMagento = namespacePrefixSet.contains('TouchCRMag') ? true : false;
		this.touchCRAmazon = namespacePrefixSet.contains('TouchCRAmz') ? true : false;
		this.touchCRJet = namespacePrefixSet.contains('TouchCRJet') ? true : false;
		this.touchCRAffiliate = TouchCRHelper.isAffiliateEnabled();

		this.isAbleMinfraud = false;
		this.isAbleUsps = false;
		this.isAbleDataAppend = false;

		initTouchCRSettings();
		initDASettings();
		initFCSettings();
		initAuthorizeEndpointSettings();

		if (this.touchCRWoo) {
			initWooSettings();
		}
		if (this.touchCRPaypal) {
			initPaypalSettings();
			initScSettings();
		}
		if (this.touchCRShopify) {
			initShopifySettings();
		}
		if (this.touchCRMagento) {
			initMagentoSettings();
		}
		if (this.touchCRAmazon) {
			initAmazonSettings();
		}
		if (this.touchCRJet) {
			initJetSettings();
		}
		if (this.touchCRAffiliate) {
			initAffiliateSettings();
		}

		getServices();
	}

	//method returns available Services
	public void getServices() {

		Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();

		String endpoint = 'callout:TouchCRBase__SecureProxy/supportedServices?v=2';
		if (settingsMap.containsKey('Endpoint.ClientId') && settingsMap.containsKey('Endpoint.ClientSecret')) {
			endpoint += '&spApiKeyId=' + settingsMap.get('Endpoint.ClientId').Value__c;
			endpoint += '&spApiKeySecret=' + settingsMap.get('Endpoint.ClientSecret').Value__c;
		}

		HttpRequest req = new HttpRequest();

		req.setEndpoint(endpoint);
		req.setMethod('GET');
		Http http = new Http();

		try {
			HTTPResponse res = http.send(req);
			Map<String, String> availableServices = (Map<String, String>) JSON.deserialize(res.getBody(), Map<String, String>.class);

			if (availableServices.containsKey('fraudDetect')) {
				this.isAbleMinfraud = true;
			}
			if (availableServices.containsKey('shipping')) {
				this.isAbleUsps = true;
			}
			if (availableServices.containsKey('person') && availableServices.containsKey('emailCheck')) {
				this.isAbleDataAppend = true;
			}

		}
		catch(Exception ex) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Cannot get available Services.'));
		}
	}
	// New user settings BOOLEAN
	public static final Map<String, String> CHARGENT_SETTING_B = new Map<String, String> {
		'Chargent.OrderUserCreation' => 'Chargent.OrderUserCreation'
	};

	// User types for external users
	public static final List<String> portalUserLicensesTypes = new List<String> {'PID_Customer_Community_Login', 'PID_Customer_Community_Plus_Login', 'PID_Customer_Community_Plus', 'PID_Customer_Community', 'PID_External_Identity'};

	// Proxy settings BOOLEAN
	public static final Map<String, String> PROXY_SETTINGS_B = new Map<String, String> {
		'Proxy.isEnabled' => 'Proxy Enabled'
	};

	// USPS settings
	public static final Map<String, String> USPSUSER_SETTING = new Map<String, String> {
		'USPS.UserID' => 'USPSUserID'
	};

	public static final Map<String, String> PAYPAL_SETTING_S = new Map<String, String> {
		'Paypal.user' => 'Paypal User',
		'Paypal.password' => 'Paypal Password',
		'Paypal.signature' => 'Paypal Signature',
		'Paypal.checkoutUrl' => 'Paypal Checkout Url',
		'Paypal.returnUrl' => 'Return Url',
		'Paypal.cancelUrl' => 'Cancel Url',
		'Paypal.logoImgUrl' => 'Store Logo Url',
		'Paypal.endpoint' => 'Paypal NVP Endpoint',
		'Paypal.SBNCode' => 'SBN Code',
		'Paypal.APIVersion' => 'API Version',
		'Paypal.currencyCodeType' => 'Currency Code'
	};

	// PAYPAl settings
	public static final Map<String, String> PAYPAL_SETTING_B = new Map<String, String> {
		'Paypal.addressOverride' => 'Address Override',
		'Paypal.sandboxFlag' => 'Sandbox Flag'
	};

	public static final Map<String, String> HOUSECLEANER_SETTING = new Map<String, String> {
		'HouseCleaner.RecordAge' => 'RecordAge',
		'HouseCleaner.ObjectApiName' => 'ObjectApiName'
	};

	// BATCH SCORE BRAND COUNTER settings BOOLEAN
	public static final Map<String, String> WOO_SETTING_B = new Map<String, String> {
		'Woo.IsSSL' => 'Is SSL',
		'Woo.HandleShipping' => 'Woo Handle Shipping',
		'Woo.SalesforceMaster' => 'Salesforce Maste',
		'Woo.ReturnObject' => 'Return As Object',
		'Woo.HandleEmail' => 'Woo Handle Email'
	};

	// BATCH SCORE BRAND COUNTER settings STRING
	public static final Map<String, String> WOO_SETTING_S = new Map<String, String> {
		'Woo.callOut' => 'Woo.callOut',
		'Woo.Endpoint' => 'Connection Endpoint',
		'Woo.HashAlgorithm' => 'Hash Algorythm',
		'Woo.StoreURL' => 'API URL(Store URL)',
		'Woo.ConsumerKey' => 'Consumer Key',
		'Woo.ConsumerSecret' => 'Consumer Secret',
		'Woo.CheckFrequency' => 'Check Frequency in Minutes',
		'Woo.Brand' => 'Brand',
		'Woo.Credential' => 'NamedCredential',
		'Woo.SalesFunnel' => 'Sales Funnel'
	};

	// Lightning Shopping Cart Settings
	public static final Map<String, String> SC_SETTING_S = new Map<String, String> {
		'SC.Brand' => 'Brand Name',
		'SC.StoreLogo' => 'Logo URL'
	};

	// BATCH SCORE BRAND COUNTER settings
	public static final Map<String, String> BATCH_SETTING = new Map<String, String> {
		'Batch.RFMScoreBrandStatus' => '',
		'Batch.RFMScoreBrandTime' => '',
		'Batch.RFMScoreBrandDay' => '',
		'Batch.RFMScoreStatus' => '',
		'Batch.RFMScoreTime' => '',
		'Batch.RFMScoreDay' => '',
		'Batch.CampaignMemberStatus' => '',
		'Batch.CampaignMemberTime' => '',
		'Batch.CampaignMemberDay' => '',
		'Batch.DataAppendTime' => '',
		'Batch.DataAppendState' => '',
		'Batch.HouseCleanerState' => '',
		'Batch.HouseCleanerDay' => '',
		'Batch.HouseCleanerTime' => '',
		'Batch.MagentoStatus' => '',
		'Batch.MagentoTime' => '',
		'Batch.MagentoDay' => '',
		'Batch.MagentoFrequencyParameters' => '',
		'Batch.MagentoHours' => '',
		'Batch.AmazonStatus' => '',
		'Batch.AmazonTime' => '',
		'Batch.AmazonDay' => '',
		'Batch.AmazonFrequencyParameters' => '',
		'Batch.AmazonHours' => '',
		'Batch.AmazonMergeStatus' => '',
		'Batch.AmazonMergeTime' => '',
		'Batch.AmazonMergeDay' => '',
		'Batch.AmazonMergeFrequencyParameters' => '',
		'Batch.AmazonMergeHours' => '',
		'Batch.WooStatus' => '',
		'Batch.WooHours'=>'',
		'Batch.WooTime' => '',
		'Batch.WooDay'=>'',
		'Batch.WooFrequencyParameters'=>'',
		'Batch.ShopifyStatus' => '',
		'Batch.ShopifyTime' => '',
		'Batch.ShopifyDay' => '',
		'Batch.ShopifyFrequencyParameters' => '',
		'Batch.ShopifyHours' => '',
		'Batch.JetStatus' => '',
		'Batch.JetTime' => '',
		'Batch.JetDay' => '',
		'Batch.JetFrequencyParameters' => '',
		'Batch.JetHours' => '',
		'Batch.SubscriptionTime' => '',
		'Batch.SubscriptionDay' => '',
		'Batch.SubscriptionStatus' => '',
		'Batch.RefundPeriodTime' => '',
		'Batch.RefundPeriodDay' => '',
		'Batch.RefundPeriodStatus' => '',
		'Batch.RefundPeriodValue' => ''
	};

	// MINFRAUD settings
	public static final Map<String, String> MINFRAUD_SETTING = new Map<String, String> {
		'MinFraud.ApiKey' => 'ApiKey',
		'MinFraud.RatingFirst' => 'First Rating',
		'MinFraud.RatingSecond' => 'Second Rating'
	};

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
		'DataAppend.DateTimeApprove' => '',
		'DataAppend.EnableExecute' => 'false'

	};

	// LEAD settings BOOLEAN
	public static final Map<String, String> LEAD_SETTING_KEYS_B = new Map<String, String> {
		'Lead.ValidateEmail' => 'Validate Email on Lead',
		'Lead.CorrectEmail' => 'Correct Email on Lead',
		'Lead.AppendNameAddress' => 'Append Name & Address on Lead',
		'Lead.EnableDemographics' => 'Enable Demographics on Lead',
		'Lead.EmailActivityMetrics' => 'Email Activity Metric on Lead',
		'Lead.AppendDemographicBasics' => 'Append Demographic Basics on Lead',
		'Lead.AppendHousing' => 'Append Housing on Lead',
		'Lead.AppendInterest' => 'Append Interest on Lead',
		'Lead.AppendPurchase' => 'Append Purchase on Lead'
	};
	//'Lead.IPAddressLocation' => 'DO NOT USE FOR NOW - IP Address Location on Lead',

	// ACCOUNT settings BOOLEAN
	public static final Map<String, String> ACCOUNT_SETTING_KEYS_B = new Map<String, String> {
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
	//'Account.IPAddressLocation' => 'DO NOT USE FOR NOW - IP Address Location on Account',

	// GLOBAL settings BOOLEAN
	public static final Map<String, String> GLOBAL_SETTING_KEYS_B = new Map<String, String> {
		'Global.EmailOn' => 'Append Email On',
		'Global.AppendOnNewAccount' => 'Append on new Accounts',
		'Global.AppendOnNewLead' => 'Append on new Leads'
	};

	// GLOBAL settings NUMBER
	public static final Map<String, String> GLOBAL_SETTING_KEYS_N = new Map<String, String> {
		'Global.ReappendOnDays' => 'Re-append on Days'
	};

	// GLOBAL settings DATE
	public static final Map<String, String> GLOBAL_SETTING_KEYS_D = new Map<String, String> {
		'Global.IgnoreOlderThan' => 'Ignore data older than'
	};

	// GLOBAL settings STRING secret
	public static final Map<String, String> GLOBAL_SETTING_KEYS_S = new Map<String, String> {
		'Global.License' => 'Tower Data License Key',
		'Global.APIKey' => 'Tower Data Demographics Key'
	};

	// LC settings BOOLEAN
	public static final Map<String, String> LC_SETTING_KEYS_B = new Map<String, String> {
		'Global.LeadConvert' => 'Re-append on Lead to Account Convert'
	};

	// LC settings NUMBER
	public static final Map<String, String> LC_SETTING_KEYS_N = new Map<String, String> {
		'Global.LeadAccountAged' => 'Re-append on Lead to Account Aged'
	};

	// SHOPIFY settings STRING
	public static final Map<String, String> SHOPIFY_SETTING_S = new Map<String, String> {
		'Shopify.callOut' => 'Shopify.callOut'
	};

	// SHOPIFY settings BOOLEAN
	public static final Map<String, String> SHOPIFY_SETTING_B = new Map<String, String>();

	// JET settings STRING
	public static final Map<String, String> JET_SETTING_S = new Map<String, String>();

	// JET settings BOOLEAN
	public static final Map<String, String> JET_SETTING_B = new Map<String, String>();

	// MAGENTO settings STRING
	public static final Map<String, String> MAGENTO_SETTING_S = new Map<String, String> {
		'Magento.ApiUser' => 'Magento.ApiUser',
		'Magento.ApiPassword' => 'Magento.ApiPassword',
		'Magento.Brand' => 'Magento.Brand',
		'Magento.SalesFunnel' => 'Magento.SalesFunnel',
		'Magento.Credential' => 'Magento.Credential'
	};

	// MAGENTO settings BOOLEAN
	public static final Map<String, String> MAGENTO_SETTING_B = new Map<String, String> {
		'Magento.SalesforceMaster' => 'Magento.SalesforceMaster'
	};

	// AMAZON settings STRING
	public static final Map<String, String> AMAZON_SETTING_S = new Map<String, String> {
		'Amazon.StoreURL' => 'Amazon.StoreURL',
		'Amazon.ApiKey' => 'Amazon.ApiKey',
		'Amazon.MerchantId' => 'Amazon.MerchantId',
		'Amazon.MarketPlaceId' => 'Amazon.MarketPlaceId',
		'Amazon.Application' => 'Amazon.Application',
		'Amazon.AppVersion' => 'Amazon.AppVersion',
		'Amazon.ApiSecret' => 'Amazon.ApiSecret',
		'Amazon.CheckFrequency' => 'Amazon.CheckFrequency',
		'Amazon.Brand' => 'Amazon.Brand',
		'Amazon.SalesFunnel' => 'Amazon.SalesFunnel',
		'Amazon.Credential' => 'Amazon.Credential',
		'Amazon.DataFinderKey' => 'Amazon.DataFinderKey'
	};

	// AMAZON settings BOOLEAN
	public static final Map<String, String> AMAZON_SETTING_B = new Map<String, String> {
		'Amazon.IsSSL' => 'Amazon.IsSSL',
		'Amazon.HandleShipping' => 'Amazon.HandleShipping',
		'Amazon.SalesforceMaster' => 'Amazon.SalesforceMaster',
		'Amazon.ReturnObject' => 'Amazon.ReturnObject',
		'Amazon.HandleEmail' => 'Amazon.HandleEmail',
		'Amazon.ResolveEmail' => 'Amazon.ResolveEmail'
	};

	//Endpoint settings STRING
	public static final Map<String, String> AUTHORIZE_ENDPOINT_SETTING = new Map<String, String> {
		'Endpoint.ClientId' => '',
		'Endpoint.ClientSecret' => '',
		'Endpoint.TokenType' => '',
		'Endpoint.TokenPart1' => '',
		'Endpoint.TokenPart2' => '',
		'Endpoint.ExpiresIn' => ''
	};

	// FULLCONTACT settings STRING
	public static final Map<String, String> FULLCONTACT_SETTING_KEYS_S = new Map<String, String> {
		'FullContact.APIKey' => 'FullContact APIKey'
	};

	// FULLCONTACT APPROVED settings
	public static final Map<String, String> FULLCONTACT_APPROVED_SETTING = new Map<String, String> {
		'FullContact.Limit' => '0',
		'FullContact.Excess' => '0',
		'FullContact.Confirmed' => 'false',
		'FullContact.DateTimeApprove' => '',
		'FullContact.EnableExecute' => 'false',
		'FullContact.AppendSocialProfiles' => 'false'
	};

	// THE BATCHES NAMES TO CHECK THEIR WORK
	public static final Map<String, Set<String>> NAME_TO_CLASSES = new Map<String, Set<String>> {
		'ScoreBrandCounter' => new Set<String>{ 'ScoreBrandCounterBatch', 'ScoreBrandCalculationBatch' },
		'ScoreCalculation' => new Set<String>{ 'ScoreCalculationBatch', 'ScoreCalculationCounterBatch' },
		'CampaignMember' => new Set<String>{ 'CampaignMemberBatch', 'CampaignMemberSummaryBatch', 'CampaignHierarchyBatch', 'CampaignHierarchySummaryBatch' },
		'DataAppend' => new Set<String>{ 'DataAppendBatch' },
		'HouseCleaner' => new Set<String>{ 'TouchCRHouseCleanerBatch' },
		'MagentoSync' => new Set<String>{ 'MagentoGetCategoriesBatch', 'MagentoGetProductsBatch', 'MagentoGetProductVariantsBatch', 'MagentoGetCustomersBatch', 'MagentoGetOrdersBatch'},
		'MagentoSyncScheluders' => new Set<String>{ 'MagentoConnectorSync', 'Magento Get Products', 'Magento Get Customers', 'Magento Get Orders'},
		'AmazonSync' => new Set<String>{ 'AmazonGetListOrdersBatch', 'AmazonGetProductCategoriesBatch', 'AmazonGetReportBatch'},
		'AmazonSyncScheluders' => new Set<String>{ 'AmazonSyncConnector', 'Get Amazon Report Request Status', 'Amazon GetProductCategories', 'Amazon ListOrdersByNextToken'},
		'WooSync' => new Set<String>{ 'ShoppingCartCustomerBatch', 'ShoppingCartProductBatch', 'ShoppingCartOrderBatch' },
		'WooSyncScheluders' => new Set<String>{ 'WooScheluders'},
		'ShopifySyncScheduler' => new Set<String>{ 'ShopifyScheduler'},
		'SubscriptionOrder' => new Set<String>{ 'SubscriptionOrderBatch', 'SubscriptionPaymentAttemptBatch'}
	};

	// BRANDS settings
	public static final String BRAND_SETTINGS_PREFIX = 'B.';
	public static final String COMMUNITY_SETTINGS_PREFIX = 'C.';
	public static final String GATEWAYS_SETTINGS_PREFIX = 'D.';
	public static final String PAYMENT_AGENT_SETTINGS_PREFIX = 'PA.';
	public static final String GOOGLE_SETTINGS_PREFIX = 'GA.';
	public static final String DATAAPPEND_SETTINGS_PREFIX = 'DataAppend.';
	public static final String DATAAPPEND_DATE_SETTINGS_PREFIX = 'DataAppend.D.';
	public static final String FULLCONTACT_SETTINGS_PREFIX = 'FullContact.';
	public static final String FULLCONTACT_DATE_SETTINGS_PREFIX = 'FullContact.D.';

	public Set<String> getNamespacePrefix() {
		Set<String> namespacePrefixSet = new Set<String>();
		// INSTALLED PACKAGES
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'PackageLicense',
				'TouchCRConfigurationController.cls [getNamespacePrefix]',
				new List<Schema.DescribeFieldResult> {
					PackageLicense.NamespacePrefix.getDescribe()
				}
			);
			for (PackageLicense ac : [SELECT Id, NamespacePrefix FROM PackageLicense WHERE NamespacePrefix != null]) {
				namespacePrefixSet.add(ac.NamespacePrefix);
			}
			SFDCAccessController.AccessibleWithoutSharing (
				'Organization',
				'TouchCRConfigurationController.cls [getNamespacePrefix]',
				new List<Schema.DescribeFieldResult> {
					Organization.NamespacePrefix.getDescribe()
				}
			);
			List<Organization> organizationItem = [SELECT Id, NamespacePrefix FROM Organization LIMIT 1];
			if (organizationItem.size() > 0) {
				//PACKAGING ORGS
				namespacePrefixSet.add(organizationItem[0].NamespacePrefix);
				// SAAS
				//namespacePrefixSet.add('TouchCRWC');
				//namespacePrefixSet.add('TouchCRLCart');
				//namespacePrefixSet.add('TouchCRShop');
				//namespacePrefixSet.add('TouchCRMag');
				//namespacePrefixSet.add('TouchCRAmz');
				//namespacePrefixSet.add('TouchCRJet');
			}
			namespacePrefixSet.remove(null);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
		return namespacePrefixSet;
	}

	private List<SelectOption> getNamedCredential() {
		List<SelectOption> namedCredentials = new List<SelectOption>();
		// PACKAGING ORGS
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Organization',
				'TouchCRConfigurationController.cls [getNamedCredential]',
				new List<Schema.DescribeFieldResult> {
					Organization.NamespacePrefix.getDescribe()
				}
			);
			List<Organization> orgsNamespace = [SELECT Id, NamespacePrefix FROM Organization LIMIT 1];
			if (!orgsNamespace.isEmpty()) {
				String currentNS = orgsNamespace[0].NamespacePrefix;
				SFDCAccessController.AccessibleWithoutSharing (
					'NamedCredential',
					'TouchCRConfigurationController.cls [getNamedCredential]',
					new List<Schema.DescribeFieldResult> {
						NamedCredential.NamespacePrefix.getDescribe(), NamedCredential.MasterLabel.getDescribe(),
						NamedCredential.DeveloperName.getDescribe()
					}
				);
				for (NamedCredential item : [SELECT Id, DeveloperName, NamespacePrefix, MasterLabel FROM NamedCredential WHERE NamespacePrefix = :currentNS]) {
					namedCredentials.add(new SelectOption(item.DeveloperName, item.MasterLabel));
				}
			}
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
		return namedCredentials;
	}

	private static List<SelectOption> getHours() {
		List<SelectOption> result = new List<SelectOption>();
		result.add(new SelectOption('0','12:00 AM'));
		result.add(new SelectOption('1','1:00 AM'));
		result.add(new SelectOption('2','2:00 AM'));
		result.add(new SelectOption('3','3:00 AM'));
		result.add(new SelectOption('4','4:00 AM'));
		result.add(new SelectOption('5','5:00 AM'));
		result.add(new SelectOption('6','6:00 AM'));
		result.add(new SelectOption('7','7:00 AM'));
		result.add(new SelectOption('8','8:00 AM'));
		result.add(new SelectOption('9','9:00 AM'));
		result.add(new SelectOption('10','10:00 AM'));
		result.add(new SelectOption('11','11:00 AM'));
		result.add(new SelectOption('12','12:00 PM'));
		result.add(new SelectOption('13','1:00 PM'));
		result.add(new SelectOption('14','2:00 PM'));
		result.add(new SelectOption('15','3:00 PM'));
		result.add(new SelectOption('16','4:00 PM'));
		result.add(new SelectOption('17','5:00 PM'));
		result.add(new SelectOption('18','6:00 PM'));
		result.add(new SelectOption('19','7:00 PM'));
		result.add(new SelectOption('20','8:00 PM'));
		result.add(new SelectOption('21','9:00 PM'));
		result.add(new SelectOption('22','10:00 PM'));
		result.add(new SelectOption('23','11:00 PM'));
		return result;
	}

	private static List<SelectOption> getHoursFrequency() {
		List<SelectOption> result = new List<SelectOption>();
		result.add(new SelectOption('1','1 Hour'));
		result.add(new SelectOption('3','3 Hours'));
		result.add(new SelectOption('6','6 Hours'));
		result.add(new SelectOption('9','9 Hours'));
		result.add(new SelectOption('12','12 Hours'));
		result.add(new SelectOption('16','16 Hours'));
		result.add(new SelectOption('20','20 Hours'));
		return result;
	}

	private static List<SelectOption> getFrequencyParameters() {
		List<SelectOption> result = new List<SelectOption>();
		result.add(new SelectOption('Hours','Hours'));
		result.add(new SelectOption('Days','Days'));
		return result;
	}

	public static List<SelectOption> getCallOut(){
		List<SelectOption> shopifyCallOut = new List<SelectOption>();
		shopifyCallOut.add(new SelectOption('1', '1'));
		shopifyCallOut.add(new SelectOption('2', '2'));
		shopifyCallOut.add(new SelectOption('3', '3'));
		shopifyCallOut.add(new SelectOption('4', '4'));
		shopifyCallOut.add(new SelectOption('5', '5'));
		shopifyCallOut.add(new SelectOption('6', '6'));
		shopifyCallOut.add(new SelectOption('7', '7'));
		shopifyCallOut.add(new SelectOption('8', '8'));
		return shopifyCallOut;
	}

	public static List<SelectOption> getSchedule(){
		List<SelectOption> shopifySchedule = new List<SelectOption>();
		shopifySchedule.add(new SelectOption('1','01 hour'));
		shopifySchedule.add(new SelectOption('2','30 mins'));
		shopifySchedule.add(new SelectOption('4','15 mins'));
		shopifySchedule.add(new SelectOption('6','10 mins'));
		return shopifySchedule;
	}

	public List<SelectOption> getNameBrands() {
		List<SelectOption> nameBrands = new List<SelectOption>();
		Schema.DescribeFieldResult fieldResult = Account.Brand_Assortment__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry field : ple) {
			if (field.isActive()) {
				nameBrands.add(new SelectOption(field.getLabel(), field.getLabel()));
			}
		}
		return nameBrands;
	}

	public static Map<String, TouchCR_Settings__c> getSettings(Set<String> keys) {
		Map<String, TouchCR_Settings__c> allSettings = TouchCR_Settings__c.getAll();
		Map<String, TouchCR_Settings__c> result = new Map<String, TouchCR_Settings__c>();
		for (String settingKey : keys) {
			if (allSettings.containsKey(settingKey)) {
				result.put(settingKey, allSettings.get(settingKey));
			}
			else {
				result.put(settingKey, new TouchCR_Settings__c(Name = settingKey, Value__c = ''));
			}
		}
		return result;
	}

	/**
	* TOUCHCR SETTINGS
	*/

	public String selectedStateRFMScoreBrand { get; set; } // selected On/Off
	public String selectedStateRFMScore { get; set; } // selected On/Off
	public String selectedStateCampaignMember { get; set; } // selected On/Off

	public String selectedStateDataAppend { get; set; } // selected On/Off
	public String selectedStateHouseCleaner { get; set; } // selected On/Off
	public String selectedStateSubscription { get; set; } // selected On/Off


	public String selectedExecuteDataAppend { get; set; } // 0 0 selectedTimer * * ?

	public String selectedExecuteAtRFMScoreBrand { get; set; } // 0 0 selectedTimer * * ?
	public String selectedExecuteAtRFMScoreBrandDay { get; set; } // 0 0 selectedDay * * ?

	public String selectedExecuteAtRFMScore { get; set; } // 0 0 selectedTimer * * ?
	public String selectedExecuteAtRFMScoreDay { get; set; } // 0 0 selectedDay * * ?

	public String selectedExecuteCampaignMember { get; set; } // 0 0 selectedTimer * * ?
	public String selectedExecuteCampaignMemberDay { get; set; } // 0 0 selectedDay * * ?

	public String selectedExecuteHouseCleaner { get; set; } // 0 0 selectedTimer * * ?
	public String selectedExecuteHouseCleanerDay { get; set; } // 0 0 selectedDay * * ?
	public String selectedObjectHouseCleaner {get; set;}
	public String selectedRecordAgeHouseCleaner {get; set;}

	public String selectedExecuteAtSubscription { get; set; } // 0 0 selectedTimer * * ?
	public String selectedExecuteAtSubscriptionDay { get; set; } // 0 0 selectedDay * * ?



	public DateTime nextRunTimeRFMScoreBrand { get; private set; }
	public DateTime nextRunTimeRFMScore { get; private set; }
	public DateTime nextRunTimeCampaignMember { get; private set; }

	public DateTime nextRunTimeDataAppend { get; private set; }
	public DateTime nextRunTimeHouseCleaner { get; private set; }
	public DateTime nextRunTimeSubscription { get; private set; }


	public List<SelectOption> allStates { get; set; }
	public List<SelectOption> allExecuteAt { get; set; }
	public List<SelectOption> allExecuteAtHours { get; set; }
	public List<SelectOption> allExecuteAtDay { get; set; }
	public List<SelectOption> allRecordAges { get; set; }
	public List<SelectOption> allHouseCleanerObjects { get; set; }


	public String apiKey { get; set; }
	public String uspsValue { get; set; }

	public Integer firstRating { get; set; }
	public Integer secondRating { get; set; }

	public Boolean isUserCreation { get; set; }
	//Proxy
	public Boolean isProxyEnabled { get; set; }

	public List<SettingWrapper> wrappers { get; set; }
	public List<SelectOption> profOptions { get; set; }
	public List<SelectOption> paymentOptions { get; set; }

	public void initTouchCRSettings() {
		//get selected settings
		Map<String, TouchCR_Settings__c> maxmindSettings = getSettings(MINFRAUD_SETTING.keySet());
		Map<String, TouchCR_Settings__c> allTriggerSettings = getSettings(CHARGENT_SETTING_B.keySet());
		Map<String, TouchCR_Settings__c> allUspsUserSettings = getSettings(USPSUSER_SETTING.keySet());
		Map<String, TouchCR_Settings__c> batchSettings = getSettings(BATCH_SETTING.keySet());
		Map<String, TouchCR_Settings__c> houseCleanerSettings = getSettings(HOUSECLEANER_SETTING.keySet());
		Map<String, Map<String, String>> allBrandValuesMap = getAllBrandValues();
		Map<String, TouchCR_Settings__c> allBrandSettings = getBrandSettings();
		Map<String, Id> allProfileValue = getNameToProfileIdForBrand();
		// Proxy
		Map<String, TouchCR_Settings__c> allProxySettings = getSettings(PROXY_SETTINGS_B.keySet());

		//variables initialization
		this.selectedExecuteAtRFMScoreBrand = batchSettings.get('Batch.RFMScoreBrandTime').Value__c;
		this.selectedExecuteAtRFMScore = batchSettings.get('Batch.RFMScoreTime').Value__c;
		this.selectedExecuteCampaignMember = batchSettings.get('Batch.CampaignMemberTime').Value__c;

		this.selectedExecuteDataAppend = batchSettings.get('Batch.DataAppendTime').Value__c;
		this.selectedExecuteHouseCleaner = batchSettings.get('Batch.HouseCleanerTime').Value__c;
		this.selectedExecuteAtSubscription = batchSettings.get('Batch.SubscriptionTime').Value__c;

		this.selectedExecuteAtRFMScoreBrandDay = batchSettings.get('Batch.RFMScoreBrandDay').Value__c;
		this.selectedExecuteAtRFMScoreDay = batchSettings.get('Batch.RFMScoreDay').Value__c;
		this.selectedExecuteCampaignMemberDay = batchSettings.get('Batch.CampaignMemberDay').Value__c;
		this.selectedExecuteHouseCleanerDay = batchSettings.get('Batch.HouseCleanerDay').Value__c;
		this.selectedExecuteAtSubscriptionDay = batchSettings.get('Batch.SubscriptionDay').Value__c;

		this.selectedStateRFMScoreBrand = batchSettings.get('Batch.RFMScoreBrandStatus').Value__c;
		this.selectedStateRFMScore = batchSettings.get('Batch.RFMScoreStatus').Value__c;
		this.selectedStateCampaignMember = batchSettings.get('Batch.CampaignMemberStatus').Value__c;

		this.selectedStateDataAppend = batchSettings.get('Batch.DataAppendState').Value__c;
		this.selectedStateHouseCleaner = batchSettings.get('Batch.HouseCleanerState').Value__c;
		this.selectedStateSubscription = batchSettings.get('Batch.SubscriptionStatus').Value__c;

		this.apiKey = maxmindSettings.get('MinFraud.ApiKey').Value__c;
		this.firstRating = maxmindSettings.get('MinFraud.RatingFirst').Value__c != '' ? Integer.valueOf(maxmindSettings.get('MinFraud.RatingFirst').Value__c) : NULL;
		this.secondRating = maxmindSettings.get('MinFraud.RatingSecond').Value__c != '' ? Integer.valueOf(maxmindSettings.get('MinFraud.RatingSecond').Value__c) : NULL;
		this.isUserCreation = Boolean.valueOf(allTriggerSettings.get('Chargent.OrderUserCreation').Value__c);
		this.uspsValue = allUspsUserSettings.get('USPS.UserID').Value__c;
		this.selectedObjectHouseCleaner = houseCleanerSettings.get('HouseCleaner.ObjectApiName').Value__c;
		this.selectedRecordAgeHouseCleaner = houseCleanerSettings.get('HouseCleaner.RecordAge').Value__c;
		// Proxy
		this.isProxyEnabled = Boolean.valueOf(allProxySettings.get('Proxy.isEnabled').Value__c);

		this.wrappers = new List<SettingWrapper>();
		this.profOptions = new List<SelectOption>();
		this.paymentOptions = new List<SelectOption>();

		//ExecuteAt
		//0 0 selectedTimer * * ?
		this.allExecuteAt = getHours();

		this.allExecuteAtHours = new List<SelectOption>();
		this.allExecuteAtHours.add(new SelectOption('1','1 hour'));
		this.allExecuteAtHours.add(new SelectOption('3','3 hours'));
		this.allExecuteAtHours.add(new SelectOption('6','6 hours'));
		this.allExecuteAtHours.add(new SelectOption('9','9 hours'));
		this.allExecuteAtHours.add(new SelectOption('12','12 hours'));
		this.allExecuteAtHours.add(new SelectOption('24','24 hours'));

		this.allExecuteAtDay = new List<SelectOption>();
		this.allExecuteAtDay.add(new SelectOption('1','1 day'));
		this.allExecuteAtDay.add(new SelectOption('2','2 days'));
		this.allExecuteAtDay.add(new SelectOption('3','3 days'));
		this.allExecuteAtDay.add(new SelectOption('4','4 days'));
		this.allExecuteAtDay.add(new SelectOption('5','5 days'));
		this.allExecuteAtDay.add(new SelectOption('6','6 days'));
		this.allExecuteAtDay.add(new SelectOption('7','7 days'));

		//State
		this.allStates = new List<SelectOption>();
		this.allStates.add(new SelectOption('Off','Off'));
		this.allStates.add(new SelectOption('On','On'));

		this.allHouseCleanerObjects = new List<SelectOption>();
		this.allHouseCleanerObjects.add(new SelectOption('TouchCRBase__Log__c','Log'));
		this.allRecordAges = new List<SelectOption>();
		this.allRecordAges.add(new SelectOption('1','1 day'));
		this.allRecordAges.add(new SelectOption('2','2 days'));
		this.allRecordAges.add(new SelectOption('3','3 days'));
		this.allRecordAges.add(new SelectOption('4','4 days'));
		this.allRecordAges.add(new SelectOption('5','5 days'));
		this.allRecordAges.add(new SelectOption('6','6 days'));
		this.allRecordAges.add(new SelectOption('7','1 week'));
		this.allRecordAges.add(new SelectOption('14','2 weeks'));
		this.allRecordAges.add(new SelectOption('30','1 month'));
		this.allRecordAges.add(new SelectOption('60','2 months'));
		this.allRecordAges.add(new SelectOption('90','3 months'));
		this.allRecordAges.add(new SelectOption('180','6 months'));
		this.allRecordAges.add(new SelectOption('270','9 months'));
		this.allRecordAges.add(new SelectOption('365','1 year'));
		this.allRecordAges.add(new SelectOption('730','2 years'));

		this.paymentOptions.add(new SelectOption('' , 'None'));
		for (Payment_Agents__c itemPaymentAgents : [SELECT Id, Name FROM Payment_Agents__c WHERE Active__c = true]) {
			this.paymentOptions.add(new SelectOption(itemPaymentAgents.Id, itemPaymentAgents.Name));
		}

		for (String item : allProfileValue.keySet()) {
			this.profOptions.add(new SelectOption(allProfileValue.get(item), item));
		}

		for (String brandKey : allBrandValuesMap.keySet()) {
			TouchCR_Settings__c brandSetting = allBrandSettings.get(allBrandValuesMap.get(brandKey).get(BRAND_SETTINGS_PREFIX));
			TouchCR_Settings__c commSetting = allBrandSettings.get(allBrandValuesMap.get(brandKey).get(COMMUNITY_SETTINGS_PREFIX));
			TouchCR_Settings__c gatewaySetting = allBrandSettings.get(allBrandValuesMap.get(brandKey).get(GATEWAYS_SETTINGS_PREFIX));
			TouchCR_Settings__c googleSetting = allBrandSettings.get(allBrandValuesMap.get(brandKey).get(GOOGLE_SETTINGS_PREFIX));
			wrappers.add(new SettingWrapper(
				brandKey,
				brandSetting.Name, brandSetting.Value__c,
				commSetting.Name, commSetting.Value__c,
				gatewaySetting.Name, gatewaySetting.Value__c,
				googleSetting.Name, googleSetting.Value__c
			));
		}

		timeScheduleJobs();
	}

	public void saveTouchCRSettings() {
		//get selected settings
		Map<String, TouchCR_Settings__c> minFraudSettings = getSettings(MINFRAUD_SETTING.keySet());
		Map<String, TouchCR_Settings__c> allTriggerSettings = getSettings(CHARGENT_SETTING_B.keySet());
		Map<String, TouchCR_Settings__c> allUspsUserSettings = getSettings(USPSUSER_SETTING.keySet());
		Map<String, TouchCR_Settings__c> batchSettings = getSettings(BATCH_SETTING.keySet());
		Map<String, TouchCR_Settings__c> houseCleanerSettings = getSettings(HOUSECLEANER_SETTING.keySet());
		List<TouchCR_Settings__c> settingsToUpsert = new List<TouchCR_Settings__c>();
		// Proxy
		Map<String, TouchCR_Settings__c> allProxySettings = getSettings(PROXY_SETTINGS_B.keySet());

		//Checking are settings changed.
		Boolean isRFMScoreBrandChanged = (
				this.selectedStateRFMScoreBrand != batchSettings.get('Batch.RFMScoreBrandStatus').Value__c ||
				this.selectedExecuteAtRFMScoreBrandDay != batchSettings.get('Batch.RFMScoreBrandDay').Value__c ||
				this.selectedExecuteAtRFMScoreBrand != batchSettings.get('Batch.RFMScoreBrandTime').Value__c
		);

		Boolean isRFMScoreChanged = (
				this.selectedStateRFMScore != batchSettings.get('Batch.RFMScoreStatus').Value__c ||
				this.selectedExecuteAtRFMScoreDay != batchSettings.get('Batch.RFMScoreDay').Value__c ||
				this.selectedExecuteAtRFMScore != batchSettings.get('Batch.RFMScoreTime').Value__c
		);

		Boolean isCampaignMemberChanged = (
				this.selectedStateCampaignMember != batchSettings.get('Batch.CampaignMemberStatus').Value__c ||
				this.selectedExecuteCampaignMemberDay != batchSettings.get('Batch.CampaignMemberDay').Value__c ||
				this.selectedExecuteCampaignMember != batchSettings.get('Batch.CampaignMemberTime').Value__c
		);

		Boolean isDataAppendChanged = (
				this.selectedStateDataAppend != batchSettings.get('Batch.DataAppendState').Value__c ||
				this.selectedExecuteDataAppend != batchSettings.get('Batch.DataAppendTime').Value__c
		);

		Boolean isHouseCleanerChanged = (
				this.selectedStateHouseCleaner != batchSettings.get('Batch.HouseCleanerState').Value__c ||
				this.selectedExecuteHouseCleaner != batchSettings.get('Batch.HouseCleanerTime').Value__c ||
				this.selectedExecuteHouseCleanerDay != batchSettings.get('Batch.HouseCleanerDay').Value__c
		);

		Boolean isSubscriptionChanged = (
				this.selectedExecuteAtSubscriptionDay != batchSettings.get('Batch.SubscriptionDay').Value__c ||
				this.selectedExecuteAtSubscription != batchSettings.get('Batch.SubscriptionTime').Value__c ||
				this.selectedStateSubscription != batchSettings.get('Batch.SubscriptionStatus').Value__c
		);


		//Settings for BRANDS
		Map<String, TouchCR_Settings__c> allBrandSettings = getBrandSettings();
		for (SettingWrapper item : wrappers) {
			TouchCR_Settings__c newNameSetting = allBrandSettings.get(item.brandSetting);
			if (newNameSetting.Value__c != String.valueOf(item.status)) {
				newNameSetting.Value__c = String.valueOf(item.status);
				settingsToUpsert.add(newNameSetting);
			}
			TouchCR_Settings__c newCommSetting = allBrandSettings.get(item.commSetting);
			if (newCommSetting.Value__c != item.commValue) {
				newCommSetting.Value__c = item.commValue;
				settingsToUpsert.add(newCommSetting);
			}
			TouchCR_Settings__c newGatewaySetting = allBrandSettings.get(item.gatewaySetting);
			if (newGatewaySetting.Value__c != item.gatewayId) {
				newGatewaySetting.Value__c = item.gatewayId;
				settingsToUpsert.add(newGatewaySetting);
			}
			TouchCR_Settings__c newGoogleSetting = allBrandSettings.get(item.googleSetting);
			if (newGoogleSetting.Value__c != item.googleValue) {
				newGoogleSetting.Value__c = item.googleValue;
				settingsToUpsert.add(newGoogleSetting);
			}
		}

		//Settings for BATCH
		if (batchSettings.get('Batch.RFMScoreBrandStatus').Value__c != this.selectedStateRFMScoreBrand) {
			TouchCR_Settings__c settingRFMScoreBrandStatus = batchSettings.get('Batch.RFMScoreBrandStatus');
			settingRFMScoreBrandStatus.Value__c = this.selectedStateRFMScoreBrand;
			settingsToUpsert.add(settingRFMScoreBrandStatus);
		}

		if (batchSettings.get('Batch.RFMScoreBrandDay').Value__c != this.selectedExecuteAtRFMScoreBrandDay) {
			TouchCR_Settings__c settingRFMScoreBrandDay = batchSettings.get('Batch.RFMScoreBrandDay');
			settingRFMScoreBrandDay.Value__c = this.selectedExecuteAtRFMScoreBrandDay;
			settingsToUpsert.add(settingRFMScoreBrandDay);
		}

		if (batchSettings.get('Batch.RFMScoreBrandTime').Value__c != this.selectedExecuteAtRFMScoreBrand) {
			TouchCR_Settings__c settingRFMScoreBrandTime = batchSettings.get('Batch.RFMScoreBrandTime');
			settingRFMScoreBrandTime.Value__c = this.selectedExecuteAtRFMScoreBrand;
			settingsToUpsert.add(settingRFMScoreBrandTime);
		}

		if (batchSettings.get('Batch.RFMScoreStatus').Value__c != this.selectedStateRFMScore) {
			TouchCR_Settings__c settingRFMScoreStatus = batchSettings.get('Batch.RFMScoreStatus');
			settingRFMScoreStatus.Value__c = this.selectedStateRFMScore;
			settingsToUpsert.add(settingRFMScoreStatus);
		}

		if (batchSettings.get('Batch.RFMScoreDay').Value__c != this.selectedExecuteAtRFMScoreDay) {
			TouchCR_Settings__c settingRFMScoreDay = batchSettings.get('Batch.RFMScoreDay');
			settingRFMScoreDay.Value__c = this.selectedExecuteAtRFMScoreDay;
			settingsToUpsert.add(settingRFMScoreDay);
		}

		if (batchSettings.get('Batch.RFMScoreTime').Value__c != this.selectedExecuteAtRFMScore) {
			TouchCR_Settings__c settingRFMScoreTime = batchSettings.get('Batch.RFMScoreTime');
			settingRFMScoreTime.Value__c = this.selectedExecuteAtRFMScore;
			settingsToUpsert.add(settingRFMScoreTime);
		}

		if (batchSettings.get('Batch.CampaignMemberStatus').Value__c != this.selectedStateCampaignMember) {
			TouchCR_Settings__c settingCampaignMemberStatus = batchSettings.get('Batch.CampaignMemberStatus');
			settingCampaignMemberStatus.Value__c = this.selectedStateCampaignMember;
			settingsToUpsert.add(settingCampaignMemberStatus);
		}

		if (batchSettings.get('Batch.CampaignMemberDay').Value__c != this.selectedExecuteCampaignMemberDay) {
			TouchCR_Settings__c settingCampaignMemberDay = batchSettings.get('Batch.CampaignMemberDay');
			settingCampaignMemberDay.Value__c = this.selectedExecuteCampaignMemberDay;
			settingsToUpsert.add(settingCampaignMemberDay);
		}

		if (batchSettings.get('Batch.CampaignMemberTime').Value__c != this.selectedExecuteCampaignMember) {
			TouchCR_Settings__c settingCampaignMemberTime = batchSettings.get('Batch.CampaignMemberTime');
			settingCampaignMemberTime.Value__c = this.selectedExecuteCampaignMember;
			settingsToUpsert.add(settingCampaignMemberTime);
		}

		if (batchSettings.get('Batch.DataAppendState').Value__c != this.selectedStateDataAppend) {
			TouchCR_Settings__c settingDataAppendState = batchSettings.get('Batch.DataAppendState');
			settingDataAppendState.Value__c = this.selectedStateDataAppend;
			settingsToUpsert.add(settingDataAppendState);
		}

		if (batchSettings.get('Batch.DataAppendTime').Value__c != this.selectedExecuteDataAppend) {
			TouchCR_Settings__c settingDataAppendTime = batchSettings.get('Batch.DataAppendTime');
			settingDataAppendTime.Value__c = this.selectedExecuteDataAppend;
			settingsToUpsert.add(settingDataAppendTime);
		}

		if (batchSettings.get('Batch.HouseCleanerTime').Value__c != this.selectedExecuteHouseCleaner) {
			TouchCR_Settings__c settingHouseCleanerTime = batchSettings.get('Batch.HouseCleanerTime');
			settingHouseCleanerTime.Value__c = this.selectedExecuteHouseCleaner;
			settingsToUpsert.add(settingHouseCleanerTime);
		}

		if (batchSettings.get('Batch.HouseCleanerDay').Value__c != this.selectedExecuteHouseCleanerDay) {
			TouchCR_Settings__c settingHouseCleanerDay = batchSettings.get('Batch.HouseCleanerDay');
			settingHouseCleanerDay.Value__c = this.selectedExecuteHouseCleanerDay;
			settingsToUpsert.add(settingHouseCleanerDay);
		}

		if (batchSettings.get('Batch.HouseCleanerState').Value__c != this.selectedStateHouseCleaner) {
			TouchCR_Settings__c settingHouseCleanerState = batchSettings.get('Batch.HouseCleanerState');
			settingHouseCleanerState.Value__c = this.selectedStateHouseCleaner;
			settingsToUpsert.add(settingHouseCleanerState);
		}

		if (batchSettings.get('Batch.SubscriptionTime').Value__c != this.selectedExecuteAtSubscription) {
			TouchCR_Settings__c settingSubscription = batchSettings.get('Batch.SubscriptionTime');
			settingSubscription.Value__c = this.selectedExecuteAtSubscription;
			settingsToUpsert.add(settingSubscription);
		}

		if (batchSettings.get('Batch.SubscriptionDay').Value__c != this.selectedExecuteAtSubscriptionDay) {
			TouchCR_Settings__c settingSubscriptionDay = batchSettings.get('Batch.SubscriptionDay');
			settingSubscriptionDay.Value__c = this.selectedExecuteAtSubscriptionDay;
			settingsToUpsert.add(settingSubscriptionDay);
		}

		if (batchSettings.get('Batch.SubscriptionStatus').Value__c != this.selectedStateSubscription) {
			TouchCR_Settings__c settingSubscriptionState = batchSettings.get('Batch.SubscriptionStatus');
			settingSubscriptionState.Value__c = this.selectedStateSubscription;
			settingsToUpsert.add(settingSubscriptionState);
		}

		//Settings for HOUSE_CLEANER
		if (houseCleanerSettings.get('HouseCleaner.RecordAge').Value__c != this.selectedRecordAgeHouseCleaner) {
			TouchCR_Settings__c recordAgeSetting = houseCleanerSettings.get('HouseCleaner.RecordAge');
			recordAgeSetting.Value__c = this.selectedRecordAgeHouseCleaner;
			settingsToUpsert.add(recordAgeSetting);
		}

		if (houseCleanerSettings.get('HouseCleaner.ObjectApiName').Value__c != this.selectedObjectHouseCleaner) {
			TouchCR_Settings__c objectSetting = houseCleanerSettings.get('HouseCleaner.ObjectApiName');
			objectSetting.Value__c = this.selectedObjectHouseCleaner;
			settingsToUpsert.add(objectSetting);
		}

		//Settings for MINFRAUD
		if (minFraudSettings.get('MinFraud.ApiKey').Value__c != this.apiKey) {
			TouchCR_Settings__c newApiKeySetting = minFraudSettings.get('MinFraud.ApiKey');
			newApiKeySetting.Value__c = this.apiKey;
			settingsToUpsert.add(newApiKeySetting);
		}

		if (minFraudSettings.get('MinFraud.RatingFirst').Value__c != String.valueOf(this.firstRating)) {
			TouchCR_Settings__c newFirstRatingSetting = minFraudSettings.get('MinFraud.RatingFirst');
			newFirstRatingSetting.Value__c = String.valueOf(this.firstRating);
			settingsToUpsert.add(newFirstRatingSetting);
		}

		if (minFraudSettings.get('MinFraud.RatingSecond').Value__c != String.valueOf(this.secondRating)) {
			TouchCR_Settings__c newSecondRatingSetting = minFraudSettings.get('MinFraud.RatingSecond');
			newSecondRatingSetting.Value__c = String.valueOf(this.secondRating);
			settingsToUpsert.add(newSecondRatingSetting);
		}

		//Setting for CHARGENT
		if (allTriggerSettings.get('Chargent.OrderUserCreation').Value__c != String.valueOf(this.isUserCreation)) {
			TouchCR_Settings__c settingisUserCreation = allTriggerSettings.get('Chargent.OrderUserCreation');
			settingisUserCreation.Value__c = String.valueOf(this.isUserCreation);
			settingsToUpsert.add(settingisUserCreation);
		}

		//Setting for USPS
		if (allUspsUserSettings.get('USPS.UserID').Value__c != this.uspsValue) {
			TouchCR_Settings__c settingUspsValue = allUspsUserSettings.get('USPS.UserID');
			settingUspsValue.Value__c = this.uspsValue;
			settingsToUpsert.add(settingUspsValue);
		}

		//Setting for Proxy
		if (allProxySettings.get('Proxy.isEnabled').Value__c != String.valueOf(this.isProxyEnabled)) {
			TouchCR_Settings__c settingProxyValue = allProxySettings.get('Proxy.isEnabled');
			settingProxyValue.Value__c = String.valueOf(this.isProxyEnabled);
			settingsToUpsert.add(settingProxyValue);
		}

		if (!settingsToUpsert.isEmpty()) {
			try {
				SFDCAccessController.UpsertWithoutSharing (
					settingsToUpsert,
					'TouchCRConfigurationController.cls [saveTouchCRSettings]',
					new List<Schema.DescribeFieldResult> {
						TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
					}
				);
				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Changes saved successfully!')
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}

		if (this.selectedStateRFMScoreBrand == 'Off') {
			stopMonitor('ScoreBrandCounter');
		}
		else if (this.selectedStateRFMScoreBrand == 'On' && isRFMScoreBrandChanged) {
			stopMonitor('ScoreBrandCounter');
			startMonitor('ScoreBrandCounter');
		}

		if (this.selectedStateRFMScore == 'Off') {
			stopMonitor('ScoreCalculation');
		}
		else if (this.selectedStateRFMScore == 'On'  && isRFMScoreChanged) {
			stopMonitor('ScoreCalculation');
			startMonitor('ScoreCalculation');
		}

		if (this.selectedStateCampaignMember == 'Off') {
			stopMonitor('CampaignMember');
		}
		else if (this.selectedStateCampaignMember == 'On' && isCampaignMemberChanged) {
			stopMonitor('CampaignMember');
			startMonitor('CampaignMember');
		}

		if (this.selectedStateDataAppend == 'Off') {
			stopMonitor('DataAppend');
		}
		else if (this.selectedStateDataAppend == 'On' && isDataAppendChanged) {
			stopMonitor('DataAppend');
			startMonitor('DataAppend');
		}

		if (this.selectedStateHouseCleaner == 'Off') {
			stopMonitor('HouseCleaner');
		}
		else if (this.selectedStateHouseCleaner == 'On' && isHouseCleanerChanged) {
			stopMonitor('HouseCleaner');
			startMonitor('HouseCleaner');
		}

		if (this.selectedStateSubscription == 'Off') {
			stopMonitor('SubscriptionOrder');
		}
		else if (this.selectedStateSubscription == 'On' && isSubscriptionChanged) {
			stopMonitor('SubscriptionOrder');
			startMonitor('SubscriptionOrder');
		}

		timeScheduleJobs();
	}

	public void cancelTouchCRSettings() {
		initTouchCRSettings();
		ApexPages.addmessage(
			new ApexPages.Message(ApexPages.Severity.WARNING, 'Your changes were cancelled.')
		);
	}

	private void startMonitor(String nameCronTrigger) {
		Id schJobId = getScheduleJobs(nameCronTrigger);
		if (schJobId == null) {
			if (nameCronTrigger == 'ScoreBrandCounter') {
				ScoreBrandCounterScheduler scheduler = new ScoreBrandCounterScheduler();
				String cronStr = '0 0 ' + this.selectedExecuteAtRFMScoreBrand + ' 1/1 * ? *';
				System.schedule(nameCronTrigger , cronStr, scheduler);
			}
			if (nameCronTrigger == 'ScoreCalculation') {
				ScoreCalculationScheduler scheduler = new ScoreCalculationScheduler();
				String cronStr = '0 0 ' + this.selectedExecuteAtRFMScore + ' 1/' + this.selectedExecuteAtRFMScoreDay + ' * ? *';
				System.schedule(nameCronTrigger , cronStr, scheduler);
			}
			if (nameCronTrigger == 'CampaignMember') {
				CampaignMemberScheduler scheduler = new CampaignMemberScheduler();
				String cronStr = '0 0 ' + this.selectedExecuteCampaignMember + ' 1/' + this.selectedExecuteCampaignMemberDay + ' * ? *';
				System.schedule(nameCronTrigger , cronStr, scheduler);
			}
			if (nameCronTrigger == 'DataAppend') {
				DataAppendScheduler scheduler = new DataAppendScheduler();
				String cronStr = '0 0 0/' + this.selectedExecuteDataAppend + ' 1/1 * ? *';
				System.schedule(nameCronTrigger , cronStr, scheduler);
			}
			if (nameCronTrigger == 'HouseCleaner') {
				TouchCRHouseCleanerBatchScheduler scheduler = new TouchCRHouseCleanerBatchScheduler();
				String cronStr = '0 0 ' + this.selectedExecuteHouseCleaner + ' 1/' + this.selectedExecuteHouseCleanerDay + ' * ? *';
				System.schedule(nameCronTrigger , cronStr, scheduler);
			}
			if (nameCronTrigger == 'MagentoSync') {
				try {
					Type newMagentoScheduler = Type.forName('TouchCRMag', 'MagentoSyncAPIClient');
					String cronStr = this.selectedFrequencyParameterMagento == 'Days' ?
					'0 0 ' + this.selectedExecuteMagento + ' 1/' + this.selectedExecuteMagentoDay + ' * ? *' : '0 0 ' + '0/' + this.selectedExecuteHoursMagento + ' 1/1 * ? *';
					System.schedule(nameCronTrigger , cronStr, (Schedulable)newMagentoScheduler.newInstance());
				}
				catch (Exception e) {
					ApexPages.addmessage(
						new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:' + e.getMessage())
					);
				}
			}
			if (nameCronTrigger == 'AmazonSync') {
				try {
					String cronStr = this.selectedFrequencyParameterAmazon == 'Days' ?
					'0 0 ' + this.selectedExecuteAmazon + ' 1/' + this.selectedExecuteAmazonDay + ' * ? *' : '0 0 ' + '0/' + this.selectedExecuteHoursAmazon + ' 1/1 * ? *';

					Type newAmazonScheduler = Type.forName('TouchCRAmz', 'AmazonSyncAPIClient');
					System.schedule(nameCronTrigger , cronStr, (Schedulable)newAmazonScheduler.newInstance());
				}
				catch (Exception e) {
					ApexPages.addmessage(
						new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:' + e.getMessage())
					);
				}
			}
			if (nameCronTrigger == 'Amazon Find Mergeable Accounts') {
				try {
					String cronStr = this.selectedFrequencyParameterAmazonMerge == 'Days' ?
					'0 0 ' + this.selectedExecuteAmazonMerge + ' 1/' + this.selectedExecuteAmazonMergeDay + ' * ? *' : '0 0 ' + '0/' + this.selectedExecuteHoursAmazonMerge + ' 1/1 * ? *';
					Type newAmazonMergeScheduler = Type.forName('TouchCRAmz', 'AmazonFindMergeableAccountsScheduler');
					System.schedule(nameCronTrigger , cronStr, (Schedulable)newAmazonMergeScheduler.newInstance());
				}
				catch (Exception e) {
					ApexPages.addmessage(
						new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:' + e.getMessage())
					);
				}
			}

			if (nameCronTrigger == 'ShopifySync') {
				try {
					String cronStr = this.selectedFrequencyParameterShopify == 'Days' ?
						'0 0 ' + this.selectedExecuteShopify + ' 1/' + this.selectedExecuteShopifyDay + ' * ? *' :
						'0 0 ' + '0/' + this.selectedExecuteHoursShopify + ' 1/1 * ? *';
					Type newShopifyScheduler = Type.forName('TouchCRShop', 'ShopifySyncAPIClient');
					System.schedule(nameCronTrigger , cronStr, (Schedulable)newShopifyScheduler.newInstance());
				}
				catch (Exception e) {
					ApexPages.addmessage(
						new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:' + e.getMessage())
					);
				}
			}
			if (nameCronTrigger == 'JetSync') {
				try {
					String cronStr = this.selectedFrequencyParameterJet == 'Days' ?
						'0 0 ' + this.selectedExecuteJet + ' 1/' + this.selectedExecuteJetDay + ' * ? *' :
						'0 0 ' + '0/' + this.selectedExecuteHoursJet + ' 1/1 * ? *';
					Type newJetScheduler = Type.forName('TouchCRJet', 'JetSyncAPIClient');
					System.schedule(nameCronTrigger, cronStr, (Schedulable) newJetScheduler.newInstance());
				}
				catch (Exception e) {
					ApexPages.addmessage(
						new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:' + e.getMessage())
					);
				}
			}
			if (nameCronTrigger == 'WooSync') {
				try {
					String cronStr = this.selectedFrequencyParameterWoo == 'Days' ?
						'0 0 ' + this.selectedExecuteWoo + ' 1/' + this.selectedExecuteWooDay + ' * ? *' :
						'0 0 ' + '0/' + this.selectedExecuteHoursWoo + ' 1/1 * ? *';
					Type newWooScheduler = Type.forName('TouchCRWC', 'WooSyncAPIClient');
					System.schedule(nameCronTrigger , cronStr, (Schedulable)newWooScheduler.newInstance());
				}
				catch (Exception e) {
					ApexPages.addmessage(
						new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:' + e.getMessage())
					);
				}
			}
			if (nameCronTrigger == 'SubscriptionOrder') {
				SubscriptionOrderScheduler scheduler = new SubscriptionOrderScheduler();
				String cronStr = '0 0 ' + this.selectedExecuteAtSubscription + ' 1/' + this.selectedExecuteAtSubscriptionDay + ' * ? *';
				System.schedule(nameCronTrigger , cronStr, scheduler);
			}
			if (nameCronTrigger == 'RefundPeriod') {
				try {
					String cronStr = '0 0 ' + this.selectedExecuteAtRefundPeriod + ' 1/' + this.selectedExecuteAtRefundPeriodDay + ' * ? *';
					Type refundPeriod = Type.forName('CommissionEarnedScheduler');
					System.schedule('RefundPeriod' , cronStr, (Schedulable)refundPeriod.newInstance());
				}
				catch (Exception e) {
					ApexPages.addmessage(
						new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:' + e.getMessage())
					);
				}
			}
		}
	}
	// if there is active batches then true
	private Boolean searchActiveBatches(Set<String> namesBatches) {
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'AsyncApexJob',
				'DataAppendAccountListViewController.cls [init]',
				new List<Schema.DescribeFieldResult> {
					AsyncApexJob.ApexClassId.getDescribe(), AsyncApexJob.Status.getDescribe()
				}
			);
			SFDCAccessController.AccessibleWithoutSharing (
				'ApexClass',
				'DataAppendAccountListViewController.cls [init]',
				new List<Schema.DescribeFieldResult> {
					ApexClass.Name.getDescribe()
				}
			);
			List<AsyncApexJob> jobs = [
				SELECT Id, Status, ApexClassId, ApexClass.Name
				FROM AsyncApexJob
				WHERE ApexClass.Name IN : namesBatches
				AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
			];
			if (jobs.isEmpty()) {
				return false;
			}
			else {
				return true;
			}
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	private void stopMonitor(String nameCronTrigger) {
		Id schJobId = getScheduleJobs(nameCronTrigger);
		if (schJobId != null) {
			System.abortJob(schJobId);
		}
	}

	private Id getScheduleJobs(String nameCronTrigger) {
		Id result = null;
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'CronJobDetail',
				'TouchCRConfigurationController.cls [getScheduleJobs]',
				new List<Schema.DescribeFieldResult> {
					CronJobDetail.Name.getDescribe()
				}
			);
			SFDCAccessController.AccessibleWithoutSharing (
				'CronTrigger',
				'TouchCRConfigurationController.cls [getScheduleJobs]',
				new List<Schema.DescribeFieldResult> {
					CronTrigger.NextFireTime.getDescribe()
				}
			);
			List<CronTrigger> scheduleInProgress = [
				SELECT Id, NextFireTime
				FROM CronTrigger
				WHERE CronJobDetail.Name =: nameCronTrigger
			];
			result = (scheduleInProgress.isEmpty()) ? NULL : scheduleInProgress.get(0).Id;
			return result;
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	private void timeScheduleJobs() {
		Map<String, DateTime> scheduleJobsMap = new Map<String, DateTime>();
		Set<String> nameScheduleJobs = new Set<String>{
			'ScoreBrandCounter', 'ScoreCalculation', 'CampaignMember', 'DataAppend', 'HouseCleaner', 'MagentoSync', 'AmazonSync',
			'Amazon Find Mergeable Accounts', 'ShopifySync', 'SubscriptionOrder', 'WooSync', 'JetSync', 'RefundPeriod'};
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'CronJobDetail',
				'TouchCRConfigurationController.cls [getScheduleJobs]',
				new List<Schema.DescribeFieldResult> {
					CronJobDetail.Name.getDescribe()
				}
			);
			SFDCAccessController.AccessibleWithoutSharing (
				'CronTrigger',
				'TouchCRConfigurationController.cls [getScheduleJobs]',
				new List<Schema.DescribeFieldResult> {
					CronTrigger.NextFireTime.getDescribe()
				}
			);

			List<CronTrigger> scheduleInProgress = [
				SELECT Id, NextFireTime, CronJobDetail.Name
				FROM CronTrigger
				WHERE CronJobDetail.Name IN :nameScheduleJobs
				LIMIT 10
			];
			for (CronTrigger item : scheduleInProgress) {
				scheduleJobsMap.put(item.CronJobDetail.Name, item.NextFireTime);
			}
		this.nextRunTimeRFMScoreBrand = (scheduleJobsMap.containsKey('ScoreBrandCounter')) ? scheduleJobsMap.get('ScoreBrandCounter') : NULL;
		this.nextRunTimeRFMScore = (scheduleJobsMap.containsKey('ScoreCalculation')) ? scheduleJobsMap.get('ScoreCalculation') : NULL;
		this.nextRunTimeCampaignMember = (scheduleJobsMap.containsKey('CampaignMember')) ? scheduleJobsMap.get('CampaignMember') : NULL;
		this.nextRunTimeDataAppend = (scheduleJobsMap.containsKey('DataAppend')) ? scheduleJobsMap.get('DataAppend') : NULL;
		this.nextRunTimeHouseCleaner = (scheduleJobsMap.containsKey('HouseCleaner')) ? scheduleJobsMap.get('HouseCleaner') : NULL;
		this.nextRunTimeMagento = (scheduleJobsMap.containsKey('MagentoSync')) ? scheduleJobsMap.get('MagentoSync') : NULL;
		this.nextRunTimeWoo = (scheduleJobsMap.containsKey('WooSync')) ? scheduleJobsMap.get('WooSync') : NULL;
		this.nextRunTimeAmazon = (scheduleJobsMap.containsKey('AmazonSync')) ? scheduleJobsMap.get('AmazonSync') : NULL;
		this.nextRunTimeShopify = (scheduleJobsMap.containsKey('ShopifySync')) ? scheduleJobsMap.get('ShopifySync') : NULL;
		this.nextRunTimeJet = (scheduleJobsMap.containsKey('JetSync')) ? scheduleJobsMap.get('JetSync') : NULL;
		this.nextRunTimeAmazonMerge = (scheduleJobsMap.containsKey('Amazon Find Mergeable Accounts')) ? scheduleJobsMap.get('Amazon Find Mergeable Accounts') : NULL;
		this.nextRunTimeSubscription = (scheduleJobsMap.containsKey('SubscriptionOrder')) ? scheduleJobsMap.get('SubscriptionOrder') : NULL;
		this.nextRunTimeRefundPeriod = (scheduleJobsMap.containsKey('RefundPeriod')) ? scheduleJobsMap.get('RefundPeriod') : NULL;
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

	}

	public void executeNowRFMScoreBrand() {
		DateTime dt = Datetime.now().addMinutes(1);
		String cronString = '' + dt.second() + ' ' +
			dt.minute() + ' ' + dt.hour() + ' ' +
			dt.day() + ' ' + dt.month() + ' ? ' +
			dt.year();
		if (searchActiveBatches(NAME_TO_CLASSES.get('ScoreBrandCounter')) == false) {
			stopMonitor('ScoreBrandCounter');
			ScoreBrandCounterScheduler scheduler = new ScoreBrandCounterScheduler();
			System.schedule('ScoreBrandCounter' , cronString, scheduler);
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.CONFIRM, 'RFM Score Brand Batch will be initiated in 1 minute')
			);
			timeScheduleJobs();

		}
		else {
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.WARNING, 'RFM Score Brand Batch cannot be started, please try again later.')
			);
		}
	}

	public void executeNowRFMScore() {
		DateTime dt = Datetime.now().addMinutes(1);
		String cronString = '' + dt.second() + ' ' +
			dt.minute() + ' ' + dt.hour() + ' ' +
			dt.day() + ' ' + dt.month() + ' ? ' +
			dt.year();
		if (searchActiveBatches(NAME_TO_CLASSES.get('ScoreCalculation')) == false) {
			stopMonitor('ScoreCalculation');
			ScoreCalculationScheduler scheduler = new ScoreCalculationScheduler();
			System.schedule('ScoreCalculation' , cronString, scheduler);
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.CONFIRM, 'RFM Score Batch will be initiated in 1 minute')
			);
			timeScheduleJobs();

		}
		else {
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.WARNING, 'RFM Score Batch cannot be started, please try again later.')
			);
		}
	}

	public void executeNowCampaignMember() {
		DateTime dt = Datetime.now().addMinutes(1);
		String cronString = '' + dt.second() + ' ' +
			dt.minute() + ' ' + dt.hour() + ' ' +
			dt.day() + ' ' + dt.month() + ' ? ' +
			dt.year();
		if (searchActiveBatches(NAME_TO_CLASSES.get('CampaignMember')) == false) {
			stopMonitor('CampaignMember');
			CampaignMemberScheduler scheduler = new CampaignMemberScheduler();
			System.schedule('CampaignMember' , cronString, scheduler);
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Campaign Member Batch will be initiated in 1 minute')
			);
			timeScheduleJobs();

		}
		else {
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.WARNING, 'Campaign Member Batch cannot be started, please try again later.')
			);
		}
	}

	public void executeNowDataAppend() {
		DateTime dt = Datetime.now().addMinutes(1);
		String cronString = '' + dt.second() + ' ' +
			dt.minute() + ' ' + dt.hour() + ' ' +
			dt.day() + ' ' + dt.month() + ' ? ' +
			dt.year();
		if (searchActiveBatches(NAME_TO_CLASSES.get('DataAppend')) == false) {
			stopMonitor('DataAppend');
			DataAppendScheduler scheduler = new DataAppendScheduler();
			System.schedule('DataAppend' , cronString, scheduler);
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Data Append Batch will be initiated in 1 minute')
			);
			timeScheduleJobs();

		}
		else {
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.WARNING, 'Data Append Batch cannot be started, please try again later.')
			);
		}
	}

	public void executeNowHouseCleaner() {
		DateTime dt = Datetime.now().addMinutes(1);
		String cronString = '' + dt.second() + ' ' +
			dt.minute() + ' ' + dt.hour() + ' ' +
			dt.day() + ' ' + dt.month() + ' ? ' +
			dt.year();


		if (searchActiveBatches(NAME_TO_CLASSES.get('HouseCleaner')) == false) {
			stopMonitor('HouseCleaner');
			TouchCRHouseCleanerBatchScheduler scheduler = new TouchCRHouseCleanerBatchScheduler();
			System.schedule('HouseCleaner' , cronString, scheduler);
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.CONFIRM, 'House Cleaner Batch will be initiated in 1 minute')
			);
			timeScheduleJobs();
		}
		else {
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.WARNING, 'House Cleaner Batch cannot be started, please try again later.')
			);
		}
	}

	public void executeNowSubscription() {
		DateTime dt = Datetime.now().addMinutes(1);
		String cronString = '' + dt.second() + ' ' +
			dt.minute() + ' ' + dt.hour() + ' ' +
			dt.day() + ' ' + dt.month() + ' ? ' +
			dt.year();
		if (searchActiveBatches(NAME_TO_CLASSES.get('SubscriptionOrder')) == false) {
			stopMonitor('SubscriptionOrder');
			SubscriptionOrderScheduler scheduler = new SubscriptionOrderScheduler();
			System.schedule('SubscriptionOrder' , cronString, scheduler);
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Subscription Batch will be initiated in 1 minute')
			);
			timeScheduleJobs();

		}
		else {
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.WARNING, 'Subscription Batch cannot be started, please try again later.')
			);
		}
	}


	//retruns Map where key is brand value, value is GatewayId
	public static Map<String, String> collectionBrandToGateway() {
		Map<String, String> result = new Map<String, String>();
		Map<String, Map<String, String>> allBrandValuesMap = getAllBrandValues();
		Map<String, TouchCR_Settings__c> allBrandSettings = getBrandSettings();

		for (String brandKey : allBrandValuesMap.keySet()) {
			if (String.isNotBlank(allBrandSettings.get(allBrandValuesMap.get(brandKey).get(GATEWAYS_SETTINGS_PREFIX)).Value__c)) {
				result.put(brandKey, allBrandSettings.get(allBrandValuesMap.get(brandKey).get(GATEWAYS_SETTINGS_PREFIX)).Value__c);
			}
		}
		return result;
	}

	public static Set<String> getActiveBrandValuesWithOutPrefix() {
		return (!Test.isRunningTest()) ? getActiveBrandsNamesMap().keySet() : activeBrandsTest;
	}

	public static String getGATracking(String str) {
		String result = '';
		Map<String, TouchCR_Settings__c> allBrandSettings = getBrandSettings();
		if (allBrandSettings.containsKey(GOOGLE_SETTINGS_PREFIX + str)) {
			TouchCR_Settings__c touchCRSetting = allBrandSettings.get(GOOGLE_SETTINGS_PREFIX + str);
			result = touchCRSetting.Value__c;
		}
		return result;
	}
	// retruns Map where key is brand value, value is profileId
	public static Map<String, String> getBrandToProfileId() {
		Map<String, String> result = new Map<String, String>();
		Map<String, TouchCR_Settings__c> allSettings = getBrandSettings();
		Map<String, Id> allProfMap = getNameToProfileIdForBrand();

		for (String brand : getAllBrandValues().keySet()) {
			if (allSettings.containsKey(COMMUNITY_SETTINGS_PREFIX + brand)) {
				result.put(brand, allSettings.get(COMMUNITY_SETTINGS_PREFIX + brand).Value__c);
			}
		}
		// TODO default the value profile is not selected brand
		if (Test.isRunningTest()) { return availableBrandsToProfileTest; }
		if (allProfMap.containsKey('Customer Community Login User')) {
			result.put('default', String.valueOf(allProfMap.get('Customer Community Login User')));
		}
		else {
			// without CCLU get just 1st profile id
			result.put('default', String.valueOf(allProfMap.values().get(0)));
		}
		return result;
	}

	public static Map<String, TouchCR_Settings__c> getBrandSettings() {
		return getSettingsForBrandPLValues(getAllBrandValues().keySet());
	}

	// method retrieves picklist values from Account Brand field
	// checks if these values are set to active in settings
	// retruns Map where key is brand value WITH a prefix, value is brand name WITHOUT prefix
	private static Map<String, String> getActiveBrandsNamesMap() {
		Map<String, String> result = new Map<String, String>();
		Map<String, Map<String, String>> allBrandsNames = getAllBrandValues();
		Map<String, TouchCR_Settings__c> allBrandSettings = getBrandSettings();

		for (String brandKey : allBrandsNames.keySet()) {
			String brandCustomSettingName = allBrandsNames.get(brandKey).get(BRAND_SETTINGS_PREFIX);
			if (allBrandSettings.containsKey(brandCustomSettingName)) {
				// fill active brands
				Boolean isBrandActive = Boolean.valueOf(allBrandSettings.get(brandCustomSettingName).Value__c);
				if (isBrandActive) {
					// key is brand value WITHOUT a prefix, value is brand name WITH prefix
					result.put(brandKey, brandCustomSettingName);
				}
			}
		}
		return result;
	}
	// method return map of all picklist values
	// the value in this map will be map
	// key - prefix and value - is brand value WITH a prefix
	private static Map<String, Map<String, String>> getAllBrandValues() {
		Map<String, Map<String, String>> result = new Map<String, Map<String, String>>();
		Schema.DescribeFieldResult fieldResult = Account.Brand_Assortment__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		for (Schema.PicklistEntry f : ple) {
			if (f.isActive()) {
				String value = f.getValue().abbreviate(33);
				result.put(f.getLabel(), new Map<String, String>{
					BRAND_SETTINGS_PREFIX => BRAND_SETTINGS_PREFIX + value,
						COMMUNITY_SETTINGS_PREFIX => COMMUNITY_SETTINGS_PREFIX + value,
						GATEWAYS_SETTINGS_PREFIX => GATEWAYS_SETTINGS_PREFIX + value,
						GOOGLE_SETTINGS_PREFIX => GOOGLE_SETTINGS_PREFIX + value
						});
			}
		}
		return result;
	}

	// returns custom settings according to active brands picklist values
	private static Map<String, TouchCR_Settings__c> getSettingsForBrandPLValues(Set<String> brands) {
		//get all settings
		Map<String, TouchCR_Settings__c> allSettings = TouchCR_Settings__c.getAll();
		Map<String, TouchCR_Settings__c> result = new Map<String, TouchCR_Settings__c>();
		Map<String, Map<String, String>> allBrandValuesMap = getAllBrandValues();
		Map<String, Id> allProfMap = getNameToProfileIdForBrand();

		for (String settingKey : brands) {
			Map<String, String> settingsNameMap = allBrandValuesMap.get(settingKey);
			for (String item : settingsNameMap.values()) {
				if (allSettings.containsKey(item)) {
					result.put(item, allSettings.get(item));
				}
				else {
					//create setting with the default 'Customer Community Login User' Profile
					if (allProfMap.containsKey('Customer Community Login User') && item.contains(COMMUNITY_SETTINGS_PREFIX + '.')) {
						result.put(item, new TouchCR_Settings__c(Name = item, Value__c = String.valueOf(allProfMap.get('Customer Community Login User'))));
					}
					else {
						result.put(item, new TouchCR_Settings__c(Name = item, Value__c = ''));
					}
				}
			}
		}
		return result;
	}

	private static Map<String, Id> getNameToProfileIdForBrand() {
		Map<String, Id> result = new Map<String, Id>();
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Profile',
				'TouchCRConfigurationController.cls [getNameToProfileIdForBrand]',
				new List<Schema.DescribeFieldResult> {
					Profile.Name.getDescribe()
				}
			);
			SFDCAccessController.AccessibleWithoutSharing (
				'UserLicense',
				'TouchCRConfigurationController.cls [getNameToProfileIdForBrand]',
				new List<Schema.DescribeFieldResult> {
					UserLicense.Name.getDescribe()
				}
			);
			List<Profile> profList = new List<Profile>([
				SELECT Id, Name
				FROM Profile
				WHERE UserLicense.LicenseDefinitionKey IN :portalUserLicensesTypes
				LIMIT 100
			]);
			for (Profile profileItem : profList) {
				result.put(profileItem.Name, profileItem.Id);
			}
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
		return result;
	}

	public class SettingWrapper {
		public String name { get; set; }
		public String brandSetting { get; set; }
		public String commSetting { get; set; }
		public String gatewaySetting { get; set; }
		public String commValue { get; set; }
		public String gatewayId { get; set; }
		public String googleSetting { get; set; }
		public String googleValue { get; set; }
		public Boolean status { get; set; }

		public SettingWrapper(String name, String brandSetting, String status, String commSetting, String commValue, String gatewaySetting, String gatewayId, String googleSetting, String googleValue) {
			this.name = name;
			this.brandSetting = brandSetting;
			this.status = Boolean.valueOf(status);
			this.commSetting = commSetting;
			this.commValue = commValue;
			this.gatewaySetting = gatewaySetting;
			this.gatewayId = gatewayId;
			this.googleSetting = googleSetting;
			this.googleValue = googleValue;
		}
	}

	@TestVisible private static Set<String> activeBrandsTest = new Set<String>();
	@TestVisible private static void setActiveBrandsTest(Set<String> brands) {
		activeBrandsTest = new Set<String>(brands);
	}

	@TestVisible private static Map<String, String> availableBrandsToProfileTest = new Map<String, String>();
	@TestVisible private static void setAvailableBrandsToProfileTest(Map<String, String> brandsToProfile) {
		availableBrandsToProfileTest = new Map<String, String>(brandsToProfile);
	}

	@TestVisible private static Map<String, String> activeBrandsNamesMap() {
		return getActiveBrandsNamesMap();
	}

	/**
	 * TOUCHCR AUTHORIZE ENDPOINT SETTINGS
	 */

	public String clientIdEndpoint { get; set; }
	public String clientSecretEndpoint { get; set; }
	public String tokenTypeEndpoint { get; set; }
	public String tokenPart1Endpoint { get; set; }
	public String tokenPart2Endpoint { get; set; }
	public String expiresInEndpoint { get; set; }

	public Boolean showCredentialInput { get; set; }

	public void initAuthorizeEndpointSettings() {
		Map<String, TouchCR_Settings__c> endpointSettings = getSettings(AUTHORIZE_ENDPOINT_SETTING.keySet());
		this.clientIdEndpoint = endpointSettings.get('Endpoint.ClientId').Value__c;
		this.clientSecretEndpoint = endpointSettings.get('Endpoint.ClientSecret').Value__c;
		this.tokenTypeEndpoint = endpointSettings.get('Endpoint.TokenType').Value__c;
		this.tokenPart1Endpoint = endpointSettings.get('Endpoint.TokenPart1').Value__c;
		this.tokenPart2Endpoint = endpointSettings.get('Endpoint.TokenPart2').Value__c;
		this.expiresInEndpoint = endpointSettings.get('Endpoint.ExpiresIn').Value__c;

		this.showCredentialInput = String.isBlank(this.clientIdEndpoint);
	}

	public void linkAuthorizeEndpointToken() {
		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setEndpoint('callout:PaymentEndpoint/oauth/token');
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		req.setHeader('application', 'x-www-form-urlencoded');
		req.setTimeout(120000);

		Blob headerValue = Blob.valueOf(this.clientIdEndpoint + ':' + this.clientSecretEndpoint);
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);
		req.setBody('grant_type=client_credentials&client_id' + this.clientIdEndpoint + '&client_secret=' + this.clientSecretEndpoint);
		Http binding = new Http();
		HttpResponse res = binding.send(req);

		if (res.getStatus() == 'OK') {
			String access_token;

			JSONParser parser = JSON.createParser(res.getBody());
			while (parser.nextToken() != null) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					if (parser.getText() == 'access_token') {
						parser.nextToken();
						access_token = parser.getText();
					}
					if (parser.getText() == 'token_type') {
						parser.nextToken();
						this.tokenTypeEndpoint = parser.getText().capitalize();
					}
					if (parser.getText() == 'expires_in') {
						parser.nextToken();
						this.expiresInEndpoint = parser.getText();
					}
				}
			}
			//received token is not placed to one setting
			if (access_token.length() > 253) {
				this.tokenPart1Endpoint = access_token.substring(0, 254);
				this.tokenPart2Endpoint = access_token.substring(254);
			}
			else {
				this.tokenPart1Endpoint = access_token;
				this.tokenPart2Endpoint = '';
			}

			Map<String, TouchCR_Settings__c> endpointSettings = getSettings(AUTHORIZE_ENDPOINT_SETTING.keySet());
			List<TouchCR_Settings__c> settingsToUpsert = new List<TouchCR_Settings__c>();

			if (endpointSettings.get('Endpoint.ClientId').Value__c != this.clientIdEndpoint) {
				TouchCR_Settings__c userNameSetting = endpointSettings.get('Endpoint.ClientId');
				userNameSetting.Value__c = this.clientIdEndpoint;
				settingsToUpsert.add(userNameSetting);
			}
			if (endpointSettings.get('Endpoint.ClientSecret').Value__c != this.clientSecretEndpoint) {
				TouchCR_Settings__c clientSecretSetting = endpointSettings.get('Endpoint.ClientSecret');
				clientSecretSetting.Value__c = this.clientSecretEndpoint;
				settingsToUpsert.add(clientSecretSetting);
			}
			if (endpointSettings.get('Endpoint.TokenType').Value__c != this.tokenTypeEndpoint) {
				TouchCR_Settings__c tokenTypeSetting = endpointSettings.get('Endpoint.TokenType');
				tokenTypeSetting.Value__c = this.tokenTypeEndpoint;
				settingsToUpsert.add(tokenTypeSetting);
			}
			if (endpointSettings.get('Endpoint.TokenPart1').Value__c != this.tokenPart1Endpoint) {
				TouchCR_Settings__c tokenPart1Setting = endpointSettings.get('Endpoint.TokenPart1');
				tokenPart1Setting.Value__c = this.tokenPart1Endpoint;
				settingsToUpsert.add(tokenPart1Setting);
			}
			if (endpointSettings.get('Endpoint.TokenPart2').Value__c != this.tokenPart2Endpoint) {
				TouchCR_Settings__c tokenPart2Setting = endpointSettings.get('Endpoint.TokenPart2');
				tokenPart2Setting.Value__c = this.tokenPart2Endpoint;
				settingsToUpsert.add(tokenPart2Setting);
			}
			if (endpointSettings.get('Endpoint.ExpiresIn').Value__c != this.expiresInEndpoint) {
				TouchCR_Settings__c expiresInSetting = endpointSettings.get('Endpoint.ExpiresIn');
				expiresInSetting.Value__c = this.expiresInEndpoint;
				settingsToUpsert.add(expiresInSetting);
			}

			if (!settingsToUpsert.isEmpty()) {
				try {
					SFDCAccessController.UpsertWithoutSharing (
						settingsToUpsert,
						'TouchCRConfigurationController.cls [linkEndpointToken]',
						new List<Schema.DescribeFieldResult> {
							TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
						}
					);
					ApexPages.addmessage(
							new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Changes saved successfully!')
					);
				}
				catch (Exception e) { throw new SFDCAccessControlException(); }
			}

			this.showCredentialInput = String.isBlank(this.clientIdEndpoint);
		}
		else {
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.ERROR, res.getBody())
			);
		}
	}

	public void unlinkAuthorizeEndpointToken() {
		Map<String, TouchCR_Settings__c> endpointSettings = getSettings(AUTHORIZE_ENDPOINT_SETTING.keySet());
		List<TouchCR_Settings__c> settingsToUpsert = new List<TouchCR_Settings__c>();

		TouchCR_Settings__c userNameSetting = endpointSettings.get('Endpoint.ClientId');
		userNameSetting.Value__c = '';
		settingsToUpsert.add(userNameSetting);

		TouchCR_Settings__c clientSecretSetting = endpointSettings.get('Endpoint.ClientSecret');
		clientSecretSetting.Value__c = '';
		settingsToUpsert.add(clientSecretSetting);

		TouchCR_Settings__c tokenTypeSetting = endpointSettings.get('Endpoint.TokenType');
		tokenTypeSetting.Value__c = '';
		settingsToUpsert.add(tokenTypeSetting);

		TouchCR_Settings__c tokenPart1Setting = endpointSettings.get('Endpoint.TokenPart1');
		tokenPart1Setting.Value__c = '';
		settingsToUpsert.add(tokenPart1Setting);

		TouchCR_Settings__c tokenPart2Setting = endpointSettings.get('Endpoint.TokenPart2');
		tokenPart2Setting.Value__c = '';
		settingsToUpsert.add(tokenPart2Setting);

		TouchCR_Settings__c expiresInSetting = endpointSettings.get('Endpoint.ExpiresIn');
		expiresInSetting.Value__c = '';
		settingsToUpsert.add(expiresInSetting);

		if (!settingsToUpsert.isEmpty()) {
			try {
				SFDCAccessController.UpsertWithoutSharing (
					settingsToUpsert,
					'TouchCRConfigurationController.cls [unlinkEndpointToken]',
					new List<Schema.DescribeFieldResult> {
						TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
					}
				);
				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Data removed!')
				);
			}
			catch (Exception e) { throw new SFDCAccessControlException(); }
		}

		this.clientIdEndpoint = '';
		this.clientSecretEndpoint = '';
		this.showCredentialInput = true;
	}

	/**
	* WOO SETTINGS
	*/
	
	public String wooCallouts { get; set; }

	public String selectedStateWoo { get; set; }

	public String selectedFrequencyParameterWoo { get; set; }
	public String selectedExecuteWooDay { get; set; }
	public String selectedExecuteWoo { get; set; }
	public String selectedExecuteHoursWoo { get; set; }

	public List<SelectOption> allStatesWoo { get; set; }

	public List<SelectOption> allFrequencyParametersWoo { get; set; }
	public List<SelectOption> allExecuteHoursWoo {get; set;}
	public List<SelectOption> allExecuteAtWoo { get; set; }
	public List<SelectOption> allExecuteAtDayWoo { get; set; }

	public DateTime nextRunTimeWoo { get; private set; }

	/*WOO AVAILABLE CONNECTION*/
	public List<TouchCRConnection__c> wooConnections {get; set;}

	public void initWooSettings() {

		timeScheduleJobs();
		this.wooConnections = [SELECT Id, Name, Feature__c, Brand__c, isActive__c FROM TouchCRConnection__c WHERE Feature__c = 'Woo' AND isActive__c = true];

		Map<String, TouchCR_Settings__c> wooBooleanSettings = getSettings(WOO_SETTING_B.keySet());
		Map<String, TouchCR_Settings__c> wooStringSettings = getSettings(WOO_SETTING_S.keySet());
		Map<String, TouchCR_Settings__c> batchSettings = getSettings(BATCH_SETTING.keySet());

		// WOO GLOBAL SETTINGS
		this.wooCallouts = wooStringSettings.get('Woo.callOut').Value__c;

		// SELECTED BATCH OPTIONS
		this.selectedStateWoo = batchSettings.get('Batch.WooStatus').Value__c;
		this.selectedStateWoo = String.isBlank(this.selectedStateWoo) ? 'Off' : this.selectedStateWoo;
		this.selectedStateWoo = String.isBlank( String.valueOf(this.nextRunTimeWoo) ) ? 'Off' : 'On';

		this.selectedFrequencyParameterWoo = batchSettings.get('Batch.WooFrequencyParameters').Value__c;
		this.selectedFrequencyParameterWoo = String.isBlank(this.selectedFrequencyParameterWoo) ? 'Days' : this.selectedFrequencyParameterWoo;

		this.selectedExecuteHoursWoo = batchSettings.get('Batch.WooHours').Value__c;
		this.selectedExecuteHoursWoo = String.isBlank(this.selectedExecuteHoursWoo) ? '1' : this.selectedExecuteHoursWoo;

		this.selectedExecuteWoo = batchSettings.get('Batch.WooTime').Value__c;
		this.selectedExecuteWoo = String.isBlank(this.selectedExecuteWoo) ? '0' : this.selectedExecuteWoo;

		this.selectedExecuteWooDay = batchSettings.get('Batch.WooDay').Value__c;
		this.selectedExecuteWooDay = String.isBlank(this.selectedExecuteWooDay) ? '1' : this.selectedExecuteWooDay;

		// AVAILABLE BATCH OPTIONS
		this.allFrequencyParametersWoo = getFrequencyParameters();
		this.allExecuteHoursWoo = getHoursFrequency();
		this.allExecuteAtWoo = getHours();

		this.allExecuteAtDayWoo = new List<SelectOption>();
		this.allExecuteAtDayWoo.add(new SelectOption('1','1 day'));
		this.allExecuteAtDayWoo.add(new SelectOption('2','2 days'));
		this.allExecuteAtDayWoo.add(new SelectOption('3','3 days'));
		this.allExecuteAtDayWoo.add(new SelectOption('4','4 days'));
		this.allExecuteAtDayWoo.add(new SelectOption('5','5 days'));
		this.allExecuteAtDayWoo.add(new SelectOption('6','6 days'));
		this.allExecuteAtDayWoo.add(new SelectOption('7','7 days'));

		this.allStatesWoo = new List<SelectOption>();
		this.allStatesWoo.add(new SelectOption('Off','Off'));
		this.allStatesWoo.add(new SelectOption('On','On'));
	 }

	public void saveWooSettings() {
		// get selected brands
		List<TouchCR_Settings__c> settingsToUpsert = new List<TouchCR_Settings__c>();
		Map<String, TouchCR_Settings__c> wooBooleanSettings = getSettings(WOO_SETTING_B.keySet());
		Map<String, TouchCR_Settings__c> wooStringSettings = getSettings(WOO_SETTING_S.keySet());
		Map<String, TouchCR_Settings__c> batchSettings = getSettings(BATCH_SETTING.keySet());

		//BATCH SETTINGS
		if (batchSettings.get('Batch.WooStatus').Value__c != this.selectedStateWoo) {
			TouchCR_Settings__c settingWooStatus = batchSettings.get('Batch.WooStatus');
			settingWooStatus.Value__c = this.selectedStateWoo;
			settingsToUpsert.add(settingWooStatus);
		}
		if (batchSettings.get('Batch.WooDay').Value__c != this.selectedExecuteWooDay) {
			TouchCR_Settings__c settingWooDay = batchSettings.get('Batch.WooDay');
			settingWooDay.Value__c = this.selectedExecuteWooDay;
			settingsToUpsert.add(settingWooDay);
		}
		if (batchSettings.get('Batch.WooTime').Value__c != this.selectedExecuteWoo) {
			TouchCR_Settings__c settingWoo = batchSettings.get('Batch.WooTime');
			settingWoo.Value__c = this.selectedExecuteWoo;
			settingsToUpsert.add(settingWoo);
		}
		if (batchSettings.get('Batch.WooFrequencyParameters').Value__c != this.selectedFrequencyParameterWoo) {
			TouchCR_Settings__c settingWoo = batchSettings.get('Batch.WooFrequencyParameters');
			settingWoo.Value__c = this.selectedFrequencyParameterWoo;
			settingsToUpsert.add(settingWoo);
		}
		if (batchSettings.get('Batch.WooHours').Value__c != this.selectedExecuteHoursWoo) {
			TouchCR_Settings__c settingWoo = batchSettings.get('Batch.WooHours');
			settingWoo.Value__c = this.selectedExecuteHoursWoo;
			settingsToUpsert.add(settingWoo);
		}
		//WOO SETTINGS
		if ((wooStringSettings.get('Woo.callOut').Value__c != this.wooCallouts) || String.isBlank(this.wooCallouts)) {
			TouchCR_Settings__c settingWooCallOut = wooStringSettings.get('Woo.callOut');
			settingWooCallOut.Value__c = this.wooCallouts;
			settingsToUpsert.add(settingWooCallOut);
		}

		if (this.selectedStateWoo == 'Off') {
			stopMonitor('WooSync');
		}
		else if (this.selectedStateWoo == 'On') {
			stopMonitor('WooSync');
			startMonitor('WooSync');
		}

		timeScheduleJobs();

		if (!settingsToUpsert.isEmpty()) {
			try {
				SFDCAccessController.UpsertWithoutSharing (
					settingsToUpsert,
					'TouchCRConfigurationController.cls [saveWooSettings]',
					new List<Schema.DescribeFieldResult> {
						TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
					}
				);
				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Changes saved successfully!')
				);
			}
			catch (Exception e) { throw new SFDCAccessControlException(); }
		}
	}

	public void cancelWooSettings() {
		initWooSettings();
		ApexPages.addmessage(
			new ApexPages.Message(ApexPages.Severity.WARNING, 'Your changes were cancelled.')
		);
	}

	public void executeNowWoo() {
		DateTime dt = Datetime.now().addMinutes(1);
		String cronString = '' + dt.second() + ' ' +
			dt.minute() + ' ' + dt.hour() + ' ' +
			dt.day() + ' ' + dt.month() + ' ? ' +
			dt.year();

		Boolean isRunning = false;
		for (String schedulerName : NAME_TO_CLASSES.get('WooSyncScheluders')) {
			if (getScheduleJobs(schedulerName) != null) {
				isRunning = true;
			}
		}

		if (searchActiveBatches(NAME_TO_CLASSES.get('WooSync')) == false && isRunning == false) {
			try {
				stopMonitor('WooSync');
				Type newWooScheduler = Type.forName('TouchCRWC', 'WooSyncAPIClient');
				System.schedule('WooSync' , cronString, (Schedulable)newWooScheduler.newInstance());

				timeScheduleJobs();

				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Woo Batch will be initiated in 1 minute')
				);
				timeScheduleJobs();
			}
			catch (exception e) {
				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:' + e.getMessage())
				);
			}
		}
		else {
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.WARNING, 'Woo Batch cannot be started, please try again later.')
			);
		}
	}

	public Integer dataAppendLimit { get; set; }
	public Integer dataAppendExcess { get; set; }

	public Account approverId1 { get; set; }
	public Account approverId2 { get; set; }
	public Account approverId3 { get; set; }

	public Boolean userApprover { get; set; }
	public Boolean enableExecuteDataAppend { get; set; }

	public List<SettingsWr> accountSettingsBWr { get; set; }
	public List<SettingsWr> leadSettingsBWr { get; set; }

	public List<SettingsWr> globalSettingsBWr { get; set; }
	public List<SettingsWr> globalSettingsNWr { get; set; }
	public List<SettingsWr> globalSettingsSWr { get; set; }
	public List<SettingsWr> globalSettingsDWr { get; set; }

	public List<SettingsWr> leadConverseSettingsBWr { get; set; }
	public List<SettingsWr> leadConverseSettingsNWr { get; set; }

	private void initDASettings() {
		Map<String, TouchCR_Settings__c> accountSettingsB = getSettings(ACCOUNT_SETTING_KEYS_B.keySet());
		Map<String, TouchCR_Settings__c> leadSettingsB = getSettings(LEAD_SETTING_KEYS_B.keySet());

		Map<String, TouchCR_Settings__c> globalSettingsB = getSettings(GLOBAL_SETTING_KEYS_B.keySet());
		Map<String, TouchCR_Settings__c> globalSettingsN = getSettings(GLOBAL_SETTING_KEYS_N.keySet());
		Map<String, TouchCR_Settings__c> globalSettingsS = getSettings(GLOBAL_SETTING_KEYS_S.keySet());
		Map<String, TouchCR_Settings__c> globalSettingsD = getSettings(GLOBAL_SETTING_KEYS_D.keySet());

		Map<String, TouchCR_Settings__c> leadCSettingsB = getSettings(LC_SETTING_KEYS_B.keySet());
		Map<String, TouchCR_Settings__c> leadCSettingsN = getSettings(LC_SETTING_KEYS_N.keySet());
		Map<String, TouchCR_Settings__c> personApprovedSettings = getSettings(APPROVED_SETTING.keySet());
		//Accounts for standard lookup fields
		this.approverId1 = new Account();
		this.approverId2 = new Account();
		this.approverId3 = new Account();

		if (String.isNotBlank(personApprovedSettings.get('DataAppend.Approver1').Value__c)) {
			this.approverId1.OwnerId = Id.valueOf(personApprovedSettings.get('DataAppend.Approver1').Value__c);
		}
		if (String.isNotBlank(personApprovedSettings.get('DataAppend.Approver2').Value__c)) {
			this.approverId2.OwnerId = Id.valueOf(personApprovedSettings.get('DataAppend.Approver2').Value__c);
		}
		if (String.isNotBlank(personApprovedSettings.get('DataAppend.Approver3').Value__c)) {
			this.approverId3.OwnerId = Id.valueOf(personApprovedSettings.get('DataAppend.Approver3').Value__c);
		}

		this.dataAppendLimit = personApprovedSettings.get('DataAppend.Limit').Value__c != '' ? Integer.valueOf(personApprovedSettings.get('DataAppend.Limit').Value__c) : 0;
		this.dataAppendExcess = personApprovedSettings.get('DataAppend.Excess').Value__c != '' ? Integer.valueOf(personApprovedSettings.get('DataAppend.Excess').Value__c) : 0;

		//Check whether the current user can approve the limit
		Id activeUser = UserInfo.getUserId();

		this.userApprover = (this.approverId1.OwnerId == activeUser || this.approverId2.OwnerId == activeUser || this.approverId3.OwnerId == activeUser) ? true : false;
		this.enableExecuteDataAppend = personApprovedSettings.get('DataAppend.EnableExecute').Value__c != null ? Boolean.valueOf(personApprovedSettings.get('DataAppend.EnableExecute').Value__c) : false;

		this.accountSettingsBWr = new List<SettingsWr>();
		this.leadSettingsBWr = new List<SettingsWr>();
		this.globalSettingsBWr = new List<SettingsWr>();
		this.globalSettingsNWr = new List<SettingsWr>();
		this.globalSettingsSWr = new List<SettingsWr>();
		this.globalSettingsDWr = new List<SettingsWr>();

		this.leadConverseSettingsBWr = new List<SettingsWr>();
		this.leadConverseSettingsNWr = new List<SettingsWr>();
		//account B settings
		for (String key : accountSettingsB.keySet()) {
			TouchCR_Settings__c setting = accountSettingsB.get(key);
			SettingsWr settingWr = new SettingsWr();
			settingWr.name = setting.Name;
			settingWr.label = ACCOUNT_SETTING_KEYS_B.get(key);
			settingWr.valueB = Boolean.valueOf(setting.Value__c);
			this.accountSettingsBWr.add(settingWr);
		}
		//lead B settings
		for (String key : leadSettingsB.keySet()) {
			TouchCR_Settings__c setting = leadSettingsB.get(key);
			SettingsWr settingWr = new SettingsWr();
			settingWr.name = setting.Name;
			settingWr.label = LEAD_SETTING_KEYS_B.get(key);
			settingWr.valueB = Boolean.valueOf(setting.Value__c);
			this.leadSettingsBWr.add(settingWr);
		}
		//global B settings
		for (String key : globalSettingsB.keySet()) {
			TouchCR_Settings__c setting = globalSettingsB.get(key);
			SettingsWr settingWr = new SettingsWr();
			settingWr.name = setting.Name;
			settingWr.label = GLOBAL_SETTING_KEYS_B.get(key);
			settingWr.valueB = Boolean.valueOf(setting.Value__c);
			this.globalSettingsBWr.add(settingWr);
		}
		//global N settings
		for (String key : globalSettingsN.keySet()) {
			TouchCR_Settings__c setting = globalSettingsN.get(key);
			SettingsWr settingWr = new SettingsWr();
			settingWr.name = setting.Name;
			settingWr.label = GLOBAL_SETTING_KEYS_N.get(key);
			settingWr.valueN = setting.Value__c;
			this.globalSettingsNWr.add(settingWr);
		}
		//global S settings
		for (String key : globalSettingsS.keySet()) {
			TouchCR_Settings__c setting = globalSettingsS.get(key);
			SettingsWr settingWr = new SettingsWr();
			settingWr.name = setting.Name;
			settingWr.label = GLOBAL_SETTING_KEYS_S.get(key);
			settingWr.valueS = setting.Value__c;
			this.globalSettingsSWr.add(settingWr);
		}
		//global D settings
		for (String key : globalSettingsD.keySet()) {
			TouchCR_Settings__c setting = globalSettingsD.get(key);
			SettingsWr settingWr = new SettingsWr();
			settingWr.name = setting.Name;
			settingWr.label = GLOBAL_SETTING_KEYS_D.get(key);
			settingWr.valueD = setting.Value__c;
			this.globalSettingsDWr.add(settingWr);
		}
		//lead c B settings
		for (String key : leadCSettingsB.keySet()) {
			TouchCR_Settings__c setting = leadCSettingsB.get(key);
			SettingsWr settingWr = new SettingsWr();
			settingWr.name = setting.Name;
			settingWr.label = LC_SETTING_KEYS_B.get(key);
			settingWr.valueB = Boolean.valueOf(setting.Value__c);
			this.leadConverseSettingsBWr.add(settingWr);
		}
		//lead c N settings
		for (String key : leadCSettingsN.keySet()) {
			TouchCR_Settings__c setting = leadCSettingsN.get(key);
			SettingsWr settingWr = new SettingsWr();
			settingWr.name = setting.Name;
			settingWr.label = LC_SETTING_KEYS_N.get(key);
			settingWr.valueN = setting.Value__c;
			this.leadConverseSettingsNWr.add(settingWr);
		}
	}

	public void saveDASettings() {
		List<TouchCR_Settings__c> settingsToUpsert = new List<TouchCR_Settings__c>();
		Map<String, TouchCR_Settings__c> accountSettingsB = getSettings(ACCOUNT_SETTING_KEYS_B.keySet());
		Map<String, TouchCR_Settings__c> leadSettingsB = getSettings(LEAD_SETTING_KEYS_B.keySet());
		Map<String, TouchCR_Settings__c> personApprovedSettings = getSettings(APPROVED_SETTING.keySet());

		Map<String, TouchCR_Settings__c> globalSettingsB = getSettings(GLOBAL_SETTING_KEYS_B.keySet());
		Map<String, TouchCR_Settings__c> globalSettingsN = getSettings(GLOBAL_SETTING_KEYS_N.keySet());
		Map<String, TouchCR_Settings__c> globalSettingsS = getSettings(GLOBAL_SETTING_KEYS_S.keySet());
		Map<String, TouchCR_Settings__c> globalSettingsD = getSettings(GLOBAL_SETTING_KEYS_D.keySet());

		Map<String, TouchCR_Settings__c> leadCSettingsB = getSettings(LC_SETTING_KEYS_B.keySet());
		Map<String, TouchCR_Settings__c> leadCSettingsN = getSettings(LC_SETTING_KEYS_N.keySet());

		//Setting DATAAPPEND
		if (String.isBlank(this.approverId1.OwnerId)) {
			if (personApprovedSettings.get('DataAppend.Approver1').Value__c != '') {
				TouchCR_Settings__c newDataAppendApprover1Setting = personApprovedSettings.get('DataAppend.Approver1');
				newDataAppendApprover1Setting.Value__c = '';
				settingsToUpsert.add(newDataAppendApprover1Setting);
			}
		}
		else if (personApprovedSettings.get('DataAppend.Approver1').Value__c != String.valueOf(this.approverId1.OwnerId)) {
			TouchCR_Settings__c newDataAppendApprover1Setting = personApprovedSettings.get('DataAppend.Approver1');
			newDataAppendApprover1Setting.Value__c = String.valueOf(this.approverId1.OwnerId);
			settingsToUpsert.add(newDataAppendApprover1Setting);
		}

		if (String.isBlank(this.approverId2.OwnerId)) {
			if (personApprovedSettings.get('DataAppend.Approver2').Value__c != '') {
				TouchCR_Settings__c newDataAppendApprover2Setting = personApprovedSettings.get('DataAppend.Approver2');
				newDataAppendApprover2Setting.Value__c = '';
				settingsToUpsert.add(newDataAppendApprover2Setting);
			}
		}
		else if (personApprovedSettings.get('DataAppend.Approver2').Value__c != String.valueOf(this.approverId2.OwnerId)) {
			TouchCR_Settings__c newDataAppendApprover2Setting = personApprovedSettings.get('DataAppend.Approver2');
			newDataAppendApprover2Setting.Value__c = String.valueOf(this.approverId2.OwnerId);
			settingsToUpsert.add(newDataAppendApprover2Setting);
		}

		if (String.isBlank(this.approverId3.OwnerId)) {
			if (personApprovedSettings.get('DataAppend.Approver3').Value__c != '') {
				TouchCR_Settings__c newDataAppendApprover3Setting = personApprovedSettings.get('DataAppend.Approver3');
				newDataAppendApprover3Setting.Value__c = '';
				settingsToUpsert.add(newDataAppendApprover3Setting);
			}
		}
		else if (personApprovedSettings.get('DataAppend.Approver3').Value__c != String.valueOf(this.approverId3.OwnerId)) {
			TouchCR_Settings__c newDataAppendApprover3Setting = personApprovedSettings.get('DataAppend.Approver3');
			newDataAppendApprover3Setting.Value__c = String.valueOf(this.approverId3.OwnerId);
			settingsToUpsert.add(newDataAppendApprover3Setting);
		}

		//Collect Id approver for finding Emails
		Set<Id> userApproverIds = new Set<Id>();
		if (String.isNotBlank(this.approverId1.OwnerId)) {
			userApproverIds.add(this.approverId1.OwnerId);
		}
		if (String.isNotBlank(this.approverId2.OwnerId)) {
			userApproverIds.add(this.approverId2.OwnerId);
		}
		if (String.isNotBlank(this.approverId3.OwnerId)) {
			userApproverIds.add(this.approverId3.OwnerId);
		}

		Map<Id, User> approverUsers = new Map<Id, User>();
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'User',
				'TouchCRConfigurationController.cls [saveDASettings]',
				new List<Schema.DescribeFieldResult> {
					User.Email.getDescribe()
				}
			);
			//Search mail for users
			approverUsers = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN: userApproverIds]);
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

		if (approverUsers.containsKey(this.approverId1.OwnerId)) {
			TouchCR_Settings__c newDataAppendApproverEmail1Setting = personApprovedSettings.get('DataAppend.ApproverEmail1');
			newDataAppendApproverEmail1Setting.Value__c = approverUsers.get(this.approverId1.OwnerId).Email;
			settingsToUpsert.add(newDataAppendApproverEmail1Setting);
		}

		if (approverUsers.containsKey(this.approverId2.OwnerId)) {
			TouchCR_Settings__c newDataAppendApproverEmail2Setting = personApprovedSettings.get('DataAppend.ApproverEmail2');
			newDataAppendApproverEmail2Setting.Value__c = approverUsers.get(this.approverId2.OwnerId).Email;
			settingsToUpsert.add(newDataAppendApproverEmail2Setting);
		}

		if (approverUsers.containsKey(this.approverId3.OwnerId)) {
			TouchCR_Settings__c newDataAppendApproverEmail3Setting = personApprovedSettings.get('DataAppend.ApproverEmail3');
			newDataAppendApproverEmail3Setting.Value__c = approverUsers.get(this.approverId3.OwnerId).Email;
			settingsToUpsert.add(newDataAppendApproverEmail3Setting);
		}

		if (personApprovedSettings.get('DataAppend.Limit').Value__c != String.valueOf(this.dataAppendLimit)) {
			TouchCR_Settings__c newDataAppendLimitSetting = personApprovedSettings.get('DataAppend.Limit');
			newDataAppendLimitSetting.Value__c = String.valueOf(this.dataAppendLimit);
			settingsToUpsert.add(newDataAppendLimitSetting);
		}

		if (personApprovedSettings.get('DataAppend.Excess').Value__c != String.valueOf(this.dataAppendExcess)) {
			TouchCR_Settings__c newDataAppendExcessSetting = personApprovedSettings.get('DataAppend.Excess');
			newDataAppendExcessSetting.Value__c = String.valueOf(this.dataAppendExcess);
			settingsToUpsert.add(newDataAppendExcessSetting);
		}

		if (personApprovedSettings.get('DataAppend.EnableExecute').Value__c != String.valueOf(this.enableExecuteDataAppend)) {
			TouchCR_Settings__c newDataAppendEnableExecuteDataAppend = personApprovedSettings.get('DataAppend.EnableExecute');
			newDataAppendEnableExecuteDataAppend.Value__c = String.valueOf(this.enableExecuteDataAppend);
			settingsToUpsert.add(newDataAppendEnableExecuteDataAppend);
		}

		//account B settings
		for (SettingsWr newSetting : accountSettingsBWr) {
			TouchCR_Settings__c oldSetting = accountSettingsB.get(newSetting.name);
			String valueToUpdate = String.valueOf(newSetting.valueB);
			if (oldSetting.Value__c != valueToUpdate) {
				oldSetting.Value__c = valueToUpdate;
				settingsToUpsert.add(oldSetting);
			}
		}
		//lead B settings
		for (SettingsWr newSetting : leadSettingsBWr) {
			TouchCR_Settings__c oldSetting = leadSettingsB.get(newSetting.name);
			String valueToUpdate = String.valueOf(newSetting.valueB);
			if (oldSetting.Value__c != valueToUpdate) {
				oldSetting.Value__c = valueToUpdate;
				settingsToUpsert.add(oldSetting);
			}
		}
		//global B settings
		for (SettingsWr newSetting : globalSettingsBWr) {
			TouchCR_Settings__c oldSetting = globalSettingsB.get(newSetting.name);
			String valueToUpdate = String.valueOf(newSetting.valueB);
			if (oldSetting.Value__c != valueToUpdate) {
				oldSetting.Value__c = valueToUpdate;
				settingsToUpsert.add(oldSetting);
			}
		}
		//global N settings
		for (SettingsWr newSetting : globalSettingsNWr) {
			TouchCR_Settings__c oldSetting = globalSettingsN.get(newSetting.name);
			String valueToUpdate = String.valueOf(newSetting.valueN);
			if (oldSetting.Value__c != valueToUpdate) {
				oldSetting.Value__c = valueToUpdate;
				settingsToUpsert.add(oldSetting);
			}
		}
		//global S settings
		for (SettingsWr newSetting : globalSettingsSWr) {
			TouchCR_Settings__c oldSetting = globalSettingsS.get(newSetting.name);
			String valueToUpdate = String.valueOf(newSetting.valueS);
			if (oldSetting.Value__c != valueToUpdate) {
				oldSetting.Value__c = valueToUpdate;
				settingsToUpsert.add(oldSetting);
			}
		}
		//global D settings
		for (SettingsWr newSetting : globalSettingsDWr) {
			TouchCR_Settings__c oldSetting = globalSettingsD.get(newSetting.name);
			String valueToUpdate = '';
			try {
				valueToUpdate = String.valueOf(Date.parse(newSetting.valueD));
			}
			catch (Exception e) {}
			if (oldSetting.Value__c != valueToUpdate) {
				oldSetting.Value__c = valueToUpdate;
				settingsToUpsert.add(oldSetting);
			}
		}
		//lead c B settings
		for (SettingsWr newSetting : leadConverseSettingsBWr) {
			TouchCR_Settings__c oldSetting = leadCSettingsB.get(newSetting.name);
			String valueToUpdate = String.valueOf(newSetting.valueB);
			if (oldSetting.Value__c != valueToUpdate) {
				oldSetting.Value__c = valueToUpdate;
				settingsToUpsert.add(oldSetting);
			}
		}
		//lead c N settings
		for (SettingsWr newSetting : leadConverseSettingsNWr) {
			TouchCR_Settings__c oldSetting = leadCSettingsN.get(newSetting.name);
			String valueToUpdate = String.valueOf(newSetting.valueN);
			if (oldSetting.Value__c != valueToUpdate) {
				oldSetting.Value__c = valueToUpdate;
				settingsToUpsert.add(oldSetting);
			}
		}

		if (!settingsToUpsert.isEmpty()) {
			try {
				SFDCAccessController.UpsertWithoutSharing (
					settingsToUpsert,
					'TouchCRConfigurationController.cls [saveDASettings]',
					new List<Schema.DescribeFieldResult> {
						TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
					}
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}

		saveFCSettings();
		initFCSettings();
		initDASettings();

		ApexPages.addmessage(
			new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Changes saved successfully!')
		);
	}

	public void cancelDASettings() {
		initDASettings();
		initFCSettings();
		ApexPages.addmessage(
			new ApexPages.Message(ApexPages.Severity.WARNING, 'Your changes were cancelled.')
		);
	}

	public void confirmWork() {
		Map<String, TouchCR_Settings__c> personApprovedSettings = getSettings(APPROVED_SETTING.keySet());
		List<TouchCR_Settings__c> settingsToUpsert = new List<TouchCR_Settings__c>();

		TouchCR_Settings__c newDataAppendConfirmedSetting = personApprovedSettings.get('DataAppend.Confirmed');
		newDataAppendConfirmedSetting.Value__c = 'true';
		settingsToUpsert.add(newDataAppendConfirmedSetting);

		TouchCR_Settings__c newDateTimeApproveSetting = personApprovedSettings.get('DataAppend.DateTimeApprove');
		newDateTimeApproveSetting.Value__c = String.valueOf(Datetime.now());
		settingsToUpsert.add(newDateTimeApproveSetting);

		TouchCR_Settings__c newExcessSetting = personApprovedSettings.get('DataAppend.Excess');
		newExcessSetting.Value__c = '0';
		settingsToUpsert.add(newExcessSetting);

		if (!settingsToUpsert.isEmpty()) {
			try {
				SFDCAccessController.UpsertWithoutSharing (
					settingsToUpsert,
					'TouchCRConfigurationController.cls [confirmWork]',
					new List<Schema.DescribeFieldResult> {
						TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
					}
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}

		initDASettings();
		ApexPages.addmessage(
			new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Restrictions limit not valid the next 24 hours')
		);
	}

	public Integer fullContactLimit { get; set; }
	public Integer fullContactExcess { get; set; }

	public Boolean enableExecuteFullContact { get; set; }
	public Boolean appendSocialProfiles { get; set; }

	public List<SettingsWr> fcSettingsSWr { get; set; }

	private void initFCSettings() {

		Map<String, TouchCR_Settings__c> fcSettingsS = getSettings(FULLCONTACT_SETTING_KEYS_S.keySet());
		Map<String, TouchCR_Settings__c> personFCApprovedSettings = getSettings(FULLCONTACT_APPROVED_SETTING.keySet());

		this.fullContactLimit = personFCApprovedSettings.get('FullContact.Limit').Value__c != '' ? Integer.valueOf(personFCApprovedSettings.get('FullContact.Limit').Value__c) : 0;
		this.fullContactExcess = personFCApprovedSettings.get('FullContact.Excess').Value__c != '' ? Integer.valueOf(personFCApprovedSettings.get('FullContact.Excess').Value__c) : 0;

		this.enableExecuteFullContact = personFCApprovedSettings.get('FullContact.EnableExecute').Value__c != null ? Boolean.valueOf(personFCApprovedSettings.get('FullContact.EnableExecute').Value__c) : false;
		this.appendSocialProfiles = personFCApprovedSettings.get('FullContact.AppendSocialProfiles').Value__c != null ? Boolean.valueOf(personFCApprovedSettings.get('FullContact.AppendSocialProfiles').Value__c) : false;

		this.fcSettingsSWr = new List<SettingsWr>();

		//FullContact S settings
		for (String key : fcSettingsS.keySet()) {
			TouchCR_Settings__c setting = fcSettingsS.get(key);
			SettingsWr settingWr = new SettingsWr();
			settingWr.name = setting.Name;
			settingWr.label = FULLCONTACT_SETTING_KEYS_S.get(key);
			settingWr.valueS = setting.Value__c;
			this.fcSettingsSWr.add(settingWr);
		}
	}

	public void saveFCSettings() {

		List<TouchCR_Settings__c> settingsToUpsert = new List<TouchCR_Settings__c>();

		Map<String, TouchCR_Settings__c> fcSettingsS = getSettings(FULLCONTACT_SETTING_KEYS_S.keySet());
		Map<String, TouchCR_Settings__c> personFCApprovedSettings = getSettings(FULLCONTACT_APPROVED_SETTING.keySet());

		//Setting FULLCONTACT
		if (personFCApprovedSettings.get('FullContact.Limit').Value__c != String.valueOf(this.fullContactLimit)) {
			TouchCR_Settings__c newDataAppendLimitSetting = personFCApprovedSettings.get('FullContact.Limit');
			newDataAppendLimitSetting.Value__c = String.valueOf(this.fullContactLimit);
			settingsToUpsert.add(newDataAppendLimitSetting);
		}
		if (personFCApprovedSettings.get('FullContact.Excess').Value__c != String.valueOf(this.fullContactExcess)) {
			TouchCR_Settings__c newDataAppendExcessSetting = personFCApprovedSettings.get('FullContact.Excess');
			newDataAppendExcessSetting.Value__c = String.valueOf(this.fullContactExcess);
			settingsToUpsert.add(newDataAppendExcessSetting);
		}
		if (personFCApprovedSettings.get('FullContact.EnableExecute').Value__c != String.valueOf(this.enableExecuteFullContact)) {
			TouchCR_Settings__c newDataAppendEnableExecuteFullContact = personFCApprovedSettings.get('FullContact.EnableExecute');
			newDataAppendEnableExecuteFullContact.Value__c = String.valueOf(this.enableExecuteFullContact);
			settingsToUpsert.add(newDataAppendEnableExecuteFullContact);
		}
		if (personFCApprovedSettings.get('FullContact.AppendSocialProfiles').Value__c != String.valueOf(this.appendSocialProfiles)) {
			TouchCR_Settings__c newDataAppendSocialProfiles = personFCApprovedSettings.get('FullContact.AppendSocialProfiles');
			newDataAppendSocialProfiles.Value__c = String.valueOf(this.appendSocialProfiles);
			settingsToUpsert.add(newDataAppendSocialProfiles);
		}

		//FullContact S settings
		for (SettingsWr newSetting : fcSettingsSWr) {
			TouchCR_Settings__c oldSetting = fcSettingsS.get(newSetting.name);
			String valueToUpdate = String.valueOf(newSetting.valueS);
			if (oldSetting.Value__c != valueToUpdate) {
				oldSetting.Value__c = valueToUpdate;
				settingsToUpsert.add(oldSetting);
			}
		}

		if (!settingsToUpsert.isEmpty()) {
			try {
				SFDCAccessController.UpsertWithoutSharing (
					settingsToUpsert,
					'TouchCRConfigurationController.cls [saveFCSettings]',
					new List<Schema.DescribeFieldResult> {
						TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
					}
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}

		initFCSettings();
	}

	public void cancelFCSettings() {
		initFCSettings();
		ApexPages.addmessage(
			new ApexPages.Message(ApexPages.Severity.WARNING, 'Your changes were cancelled.')
		);
	}

	public void confirmWorkFC() {
		Map<String, TouchCR_Settings__c> personFCApprovedSettings = getSettings(FULLCONTACT_APPROVED_SETTING.keySet());
		List<TouchCR_Settings__c> settingsToUpsert = new List<TouchCR_Settings__c>();

		TouchCR_Settings__c newDataAppendConfirmedSetting = personFCApprovedSettings.get('FullContact.Confirmed');
		newDataAppendConfirmedSetting.Value__c = 'true';
		settingsToUpsert.add(newDataAppendConfirmedSetting);

		TouchCR_Settings__c newDateTimeApproveSetting = personFCApprovedSettings.get('FullContact.DateTimeApprove');
		newDateTimeApproveSetting.Value__c = String.valueOf(Datetime.now());
		settingsToUpsert.add(newDateTimeApproveSetting);

		TouchCR_Settings__c newExcessSetting = personFCApprovedSettings.get('FullContact.Excess');
		newExcessSetting.Value__c = '0';
		settingsToUpsert.add(newExcessSetting);

		if (!settingsToUpsert.isEmpty()) {
			try {
				SFDCAccessController.UpsertWithoutSharing (
					settingsToUpsert,
					'TouchCRConfigurationController.cls [confirmWorkFC]',
					new List<Schema.DescribeFieldResult> {
						TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
					}
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}

		initFCSettings();
		ApexPages.addmessage(
			new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Restrictions limit not valid the next 24 hours')
		);
	}

	public class SettingsWr {
		public SettingsWr() {}
		public String name { get; set; }
		public String label { get; set; }
		public String valueN { get; set; }
		public String valueS { get; set; }
		public Boolean valueB { get; set; }
		public String valueD { get; set; }
	}

	//STATIC GET SETTINGS
	public static TowerDataDTO.TowerDataSettings initSettings() {
		TowerDataDTO.TowerDataSettings result = new TowerDataDTO.TowerDataSettings();

		Map<String, TouchCR_Settings__c> accountSettingsB = getSettings(ACCOUNT_SETTING_KEYS_B.keySet());
		Map<String, TouchCR_Settings__c> leadSettingsB = getSettings(LEAD_SETTING_KEYS_B.keySet());

		Map<String, TouchCR_Settings__c> globalSettingsB = getSettings(GLOBAL_SETTING_KEYS_B.keySet());
		Map<String, TouchCR_Settings__c> globalSettingsN = getSettings(GLOBAL_SETTING_KEYS_N.keySet());
		Map<String, TouchCR_Settings__c> globalSettingsS = getSettings(GLOBAL_SETTING_KEYS_S.keySet());
		Map<String, TouchCR_Settings__c> globalSettingsD = getSettings(GLOBAL_SETTING_KEYS_D.keySet());

		Map<String, TouchCR_Settings__c> leadCSettingsB = getSettings(LC_SETTING_KEYS_B.keySet());
		Map<String, TouchCR_Settings__c> leadCSettingsN = getSettings(LC_SETTING_KEYS_N.keySet());

		//lead B settings
		result.leadValidateEmail = Boolean.valueOf(leadSettingsB.get('Lead.ValidateEmail').Value__c);
		result.leadCorrectEmail = Boolean.valueOf(leadSettingsB.get('Lead.CorrectEmail').Value__c);
		result.leadEnableDemo = Boolean.valueOf(leadSettingsB.get('Lead.EnableDemographics').Value__c);
		//result.leadIpAddress = Boolean.valueOf(leadSettingsB.get('Lead.IPAddressLocation').Value__c);
		result.leadAppendNameAddress = Boolean.valueOf(leadSettingsB.get('Lead.AppendNameAddress').Value__c);
		result.leadAppendEam = Boolean.valueOf(leadSettingsB.get('Lead.EmailActivityMetrics').Value__c);

		result.leadAppendDemoBasic = Boolean.valueOf(leadSettingsB.get('Lead.AppendDemographicBasics').Value__c);
		result.leadAppendDemoHousing = Boolean.valueOf(leadSettingsB.get('Lead.AppendHousing').Value__c);
		result.leadAppendDemoInterest = Boolean.valueOf(leadSettingsB.get('Lead.AppendInterest').Value__c);
		result.leadAppendDemoPurchase = Boolean.valueOf(leadSettingsB.get('Lead.AppendPurchase').Value__c);

		//account B result
		result.accountValidateEmail = Boolean.valueOf(accountSettingsB.get('Account.ValidateEmail').Value__c);
		result.accountCorrectEmail = Boolean.valueOf(accountSettingsB.get('Account.CorrectEmail').Value__c);
		result.accountEnableDemo = Boolean.valueOf(accountSettingsB.get('Account.EnableDemographics').Value__c);
		//result.accountIpAddress = Boolean.valueOf(accountSettingsB.get('Account.IPAddressLocation').Value__c);
		result.accountAppendNameAddress = Boolean.valueOf(accountSettingsB.get('Account.AppendNameAddress').Value__c);

		result.accountAppendEam = Boolean.valueOf(accountSettingsB.get('Account.EmailActivityMetrics').Value__c);
		result.accountAppendDemoBasic = Boolean.valueOf(accountSettingsB.get('Account.AppendDemographicBasics').Value__c);
		result.accountAppendDemoHousing = Boolean.valueOf(accountSettingsB.get('Account.AppendHousing').Value__c);
		result.accountAppendDemoInterest = Boolean.valueOf(accountSettingsB.get('Account.AppendInterest').Value__c);
		result.accountAppendDemoPurchase = Boolean.valueOf(accountSettingsB.get('Account.AppendPurchase').Value__c);

		//global
		//keys
		result.license = globalSettingsS.get('Global.License').Value__c;
		result.demokey = globalSettingsS.get('Global.APIKey').Value__c;
		//settings append on/off
		result.appendOn = Boolean.valueOf(globalSettingsB.get('Global.EmailOn').Value__c);
		result.appendOnNewAccount = Boolean.valueOf(globalSettingsB.get('Global.AppendOnNewAccount').Value__c);
		result.appendOnNewLead = Boolean.valueOf(globalSettingsB.get('Global.AppendOnNewLead').Value__c);
		// parse string to date
		String ignoreDateStr = globalSettingsD.get('Global.IgnoreOlderThan').Value__c;
		try {
			result.appendIgnoreOlderThan = Date.valueOf(ignoreDateStr);
		}
		catch (Exception e) {}
		//reappend on days

		result.reappendOnDays = getNumberFromString(globalSettingsN.get('Global.ReappendOnDays').Value__c);
		// lead conversion
		result.leadConvertAppend = Boolean.valueOf(leadCSettingsB.get('Global.LeadConvert').Value__c);
		result.leadConvertAccountAged = getNumberFromString(leadCSettingsN.get('Global.LeadAccountAged').Value__c);

		return result;
	}
	//STATIC GET FC SETTINGS
	public static FullContactDTO.FullContactSettings initSettingsFC() {
		FullContactDTO.FullContactSettings result = new FullContactDTO.FullContactSettings();
		Map<String, TouchCR_Settings__c> fullContactSettingsS = getSettings(FULLCONTACT_SETTING_KEYS_S.keySet());
		result.apiKey = fullContactSettingsS.get('FullContact.APIKey').Value__c;

		return result;
	}

	private static Integer getNumberFromString(String param) {
		Integer result = 0;
		try {
			result = Integer.valueOf(param);
		}
		catch (Exception e) {}
		return result;
	}

	/**
	* PAYPAL SETTINGS
	*/

	public List<SettingsWr> ppSettingsWrS { get; set; }
	public List<SettingsWr> ppSettingsWrB { get; set; }

	public void initPaypalSettings() {
		ppSettingsWrS = new List<SettingsWr>();
		ppSettingsWrB = new List<SettingsWr>();

		Map<String, TouchCR_Settings__c> ppSettingsS = getSettings(PAYPAL_SETTING_S.keySet());
		Map<String, TouchCR_Settings__c> ppSettingsB = getSettings(PAYPAL_SETTING_B.keySet());
		// PP String
		for (String key : ppSettingsS.keySet()) {
			TouchCR_Settings__c setting = ppSettingsS.get(key);
			SettingsWr settingWr = new SettingsWr();
			settingWr.name = setting.Name;
			settingWr.label = PAYPAL_SETTING_S.get(key);
			settingWr.valueS = setting.Value__c;
			ppSettingsWrS.add(settingWr);
		}
		// PP Bool
		for (String key : ppSettingsB.keySet()) {
			TouchCR_Settings__c setting = ppSettingsB.get(key);
			SettingsWr settingWr = new SettingsWr();
			settingWr.name = setting.Name;
			settingWr.label = PAYPAL_SETTING_B.get(key);
			settingWr.valueB = Boolean.valueOf(setting.Value__c);
			ppSettingsWrB.add(settingWr);
		}
	}

	public void savePaypalSettings() {
		List<TouchCR_Settings__c> settingsToUpsert_p = new List<TouchCR_Settings__c>();

		Map<String, TouchCR_Settings__c> oldSettingS = getSettings(PAYPAL_SETTING_S.keySet());
		Map<String, TouchCR_Settings__c> oldSettingsB = getSettings(PAYPAL_SETTING_B.keySet());

		for (SettingsWr newSetting : ppSettingsWrS) {
			TouchCR_Settings__c oldSetting = oldSettingS.get(newSetting.name);
			String valueToUpdate = String.valueOf(newSetting.valueS);
			if (oldSetting.Value__c != valueToUpdate) {
				oldSetting.Value__c = valueToUpdate;
				settingsToUpsert_p.add(oldSetting);
			}
		}
		for (SettingsWr newSetting : ppSettingsWrB) {
			TouchCR_Settings__c oldSetting = oldSettingsB.get(newSetting.name);
			String valueToUpdate = String.valueOf(newSetting.valueB);
			if (oldSetting.Value__c != valueToUpdate) {
				oldSetting.Value__c = valueToUpdate;
				settingsToUpsert_p.add(oldSetting);
			}
		}

		if (!settingsToUpsert_p.isEmpty()) {
			try {
				SFDCAccessController.UpsertWithoutSharing (
					settingsToUpsert_p,
					'TouchCRConfigurationController.cls [savePaypalSettings]',
					new List<Schema.DescribeFieldResult> {
						TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
					}
				);
				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Changes saved successfully!')
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}

		initPaypalSettings();
	}

	public void cancelPaypalSettings() {
		initPaypalSettings();
		ApexPages.addmessage(
			new ApexPages.Message(ApexPages.Severity.WARNING, 'Your changes were cancelled.')
		);
	}

	/**
	* SHOPIFY SETTINGS
	*/

	/*BATCH SETTINGS*/
	public String shopifyCallouts { get; set; }

	public String selectedStateShopify { get; set; }

	public String selectedFrequencyParameterShopify { get; set; }
	public String selectedExecuteShopifyDay { get; set; }
	public String selectedExecuteShopify { get; set; }
	public String selectedExecuteHoursShopify { get; set; }

	public List<SelectOption> allStatesShopify { get; set; }

	public List<SelectOption> allFrequencyParametersShopify { get; set; }
	public List<SelectOption> allExecuteHoursShopify {get; set;}
	public List<SelectOption> allExecuteAtShopify { get; set; }
	public List<SelectOption> allExecuteAtDayShopify { get; set; }

	public DateTime nextRunTimeShopify { get; private set; }

	/*SHOPIFY AVAILABLE CONNECTION*/
	public List<TouchCRConnection__c> shopifyConnections {get; set;}

	public void initShopifySettings() {

		timeScheduleJobs();

		this.shopifyConnections = [SELECT Id, Name, Feature__c, Brand__c, isActive__c FROM TouchCRConnection__c WHERE Feature__c = 'Shopify' AND isActive__c = true];

		Map<String, TouchCR_Settings__c> shopifyStringSettings = getSettings(SHOPIFY_SETTING_S.keySet());
		Map<String, TouchCR_Settings__c> shopifyBooleanSettings = getSettings(SHOPIFY_SETTING_B.keySet());
		Map<String, TouchCR_Settings__c> batchSettings = getSettings(BATCH_SETTING.keySet());

		// SHOPIFY GLOBAL SETTINGS
		this.shopifyCallouts = shopifyStringSettings.get('Shopify.callOut').Value__c;

		// SELECTED BATCH OPTIONS
		this.selectedStateShopify = batchSettings.get('Batch.ShopifyStatus').Value__c;
		this.selectedStateShopify = String.isBlank(this.selectedStateShopify) ? 'Off' : this.selectedStateShopify;
		this.selectedStateShopify = String.isBlank( String.valueOf(this.nextRunTimeShopify) ) ? 'Off' : 'On';

		this.selectedFrequencyParameterShopify = batchSettings.get('Batch.ShopifyFrequencyParameters').Value__c;
		this.selectedFrequencyParameterShopify = String.isBlank(this.selectedFrequencyParameterShopify) ? 'Days' : this.selectedFrequencyParameterShopify;

		this.selectedExecuteHoursShopify = batchSettings.get('Batch.ShopifyHours').Value__c;
		this.selectedExecuteHoursShopify = String.isBlank(this.selectedExecuteHoursShopify) ? '1' : this.selectedExecuteHoursShopify;

		this.selectedExecuteShopify = batchSettings.get('Batch.ShopifyTime').Value__c;
		this.selectedExecuteShopify = String.isBlank(this.selectedExecuteShopify) ? '0' : this.selectedExecuteShopify;

		this.selectedExecuteShopifyDay = batchSettings.get('Batch.ShopifyDay').Value__c;
		this.selectedExecuteShopifyDay = String.isBlank(this.selectedExecuteShopifyDay) ? '1' : this.selectedExecuteShopifyDay;

		// AVAILABLE BATCH OPTIONS
		this.allFrequencyParametersShopify = getFrequencyParameters();
		this.allExecuteHoursShopify = getHoursFrequency();
		this.allExecuteAtShopify = getHours();

		this.allExecuteAtDayShopify = new List<SelectOption>();
		this.allExecuteAtDayShopify.add(new SelectOption('1','1 day'));
		this.allExecuteAtDayShopify.add(new SelectOption('2','2 days'));
		this.allExecuteAtDayShopify.add(new SelectOption('3','3 days'));
		this.allExecuteAtDayShopify.add(new SelectOption('4','4 days'));
		this.allExecuteAtDayShopify.add(new SelectOption('5','5 days'));
		this.allExecuteAtDayShopify.add(new SelectOption('6','6 days'));
		this.allExecuteAtDayShopify.add(new SelectOption('7','7 days'));

		this.allStatesShopify = new List<SelectOption>();
		this.allStatesShopify.add(new SelectOption('Off','Off'));
		this.allStatesShopify.add(new SelectOption('On','On'));
	}

	public void saveShopifySettings() {

		List<TouchCR_Settings__c> settingsToUpsert = new List<TouchCR_Settings__c>();
		Map<String, TouchCR_Settings__c> shopifyStringSettings = getSettings(SHOPIFY_SETTING_S.keySet());
		Map<String, TouchCR_Settings__c> shopifyBooleanSettings = getSettings(SHOPIFY_SETTING_B.keySet());
		Map<String, TouchCR_Settings__c> batchSettings = getSettings(BATCH_SETTING.keySet());

		//BATCH SETTINGS
		if (batchSettings.get('Batch.ShopifyStatus').Value__c != this.selectedStateShopify) {
			TouchCR_Settings__c settingShopifyStatus = batchSettings.get('Batch.ShopifyStatus');
			settingShopifyStatus.Value__c = this.selectedStateShopify;
			settingsToUpsert.add(settingShopifyStatus);
		}
		if (batchSettings.get('Batch.ShopifyDay').Value__c != this.selectedExecuteShopifyDay) {
			TouchCR_Settings__c settingShopifyDay = batchSettings.get('Batch.ShopifyDay');
			settingShopifyDay.Value__c = this.selectedExecuteShopifyDay;
			settingsToUpsert.add(settingShopifyDay);
		}
		if (batchSettings.get('Batch.ShopifyTime').Value__c != this.selectedExecuteShopify) {
			TouchCR_Settings__c settingShopify = batchSettings.get('Batch.ShopifyTime');
			settingShopify.Value__c = this.selectedExecuteShopify;
			settingsToUpsert.add(settingShopify);
		}
		if (batchSettings.get('Batch.ShopifyFrequencyParameters').Value__c != this.selectedFrequencyParameterShopify) {
			TouchCR_Settings__c settingShopify = batchSettings.get('Batch.ShopifyFrequencyParameters');
			settingShopify.Value__c = this.selectedFrequencyParameterShopify;
			settingsToUpsert.add(settingShopify);
		}
		if (batchSettings.get('Batch.ShopifyHours').Value__c != this.selectedExecuteHoursShopify) {
			TouchCR_Settings__c settingShopify = batchSettings.get('Batch.ShopifyHours');
			settingShopify.Value__c = this.selectedExecuteHoursShopify;
			settingsToUpsert.add(settingShopify);
		}
		//SHOPIFY SETTINGS
		if ((shopifyStringSettings.get('Shopify.callOut').Value__c != this.shopifyCallouts) || String.isBlank(this.shopifyCallouts)) {
			TouchCR_Settings__c settingShopifyCallOut = shopifyStringSettings.get('Shopify.callOut');
			settingShopifyCallOut.Value__c = this.shopifyCallouts;
			settingsToUpsert.add(settingShopifyCallOut);
		}

		if (this.selectedStateShopify == 'Off') {
				stopMonitor('ShopifySync');
			}
			else if (this.selectedStateShopify == 'On') {
				stopMonitor('ShopifySync');
				startMonitor('ShopifySync');
			}

		timeScheduleJobs();

		if (!settingsToUpsert.isEmpty()) {
			try {
				SFDCAccessController.UpsertWithoutSharing (
					settingsToUpsert,
					'TouchCRConfigurationController.cls [saveShopifySettings]',
					new List<Schema.DescribeFieldResult> {
						TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
					}
				);
				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Changes saved successfully!')
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}
	}

	public void cancelShopifySettings() {
		initShopifySettings();
		ApexPages.addmessage(
			new ApexPages.Message(ApexPages.Severity.WARNING, 'Your changes were cancelled.')
		);
	}

	public void executeNowShopify() {

		try {
			//stopMonitor('ShopifySync');
			Type newShopifyScheduler = Type.forName('TouchCRShop', 'ShopifySyncAPIClient');
			Database.executeBatch( (Database.Batchable<sObject>) newShopifyScheduler.newInstance());

			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Shopify Batch will be initiated in 1 minute')
			);
		}
		catch (exception e) {
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:' + e.getMessage())
			);
		}
	}


	/**
	* MAGENTO SETTINGS
	*/

	public Boolean magentoSchedulingOptionsChanged; //prevent rescheduling if nothing changed

	public Boolean magentoSalesforceMaster { get; set; }

	public String selectedStateMagento { get; set; } // selected On/Off
	public String selectedFrequencyParameterMagento { get; set; } // selected Days/Hours
	public String selectedExecuteHoursMagento { get; set; } // 1 3 6 9 12 16 20
	public String selectedExecuteMagento { get; set; } // 0 0 selectedTimer * * ?
	public String selectedExecuteMagentoDay { get; set; } // 0 0 selectedDay * * ?
	public DateTime nextRunTimeMagento { get; private set; }

	public List<SelectOption> allFrequencyParametersMagento { get; set; }
	public List<SelectOption> allExecuteHoursMagento {get; set;}
	public List<SelectOption> allExecuteAtMagento { get; set; }
	public List<SelectOption> allExecuteAtDayMagento { get; set; }
	public List<SelectOption> allStatesMagento { get; set; }

	public List<TouchCRConnection__c> magentoConnections { get; set; }

	public void initMagentoSettings() {

		this.magentoConnections = new List<TouchCRConnection__c>();
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'TouchCRConnection__c',
				'TouchCRConfigurationController.cls [initMagentoSettings]',
				new List<Schema.DescribeFieldResult> {
					TouchCRConnection__c.Name.getDescribe(), TouchCRConnection__c.Feature__c.getDescribe(),
					TouchCRConnection__c.isActive__c.getDescribe(), TouchCRConnection__c.Brand__c.getDescribe()
				}
			);
			this.magentoConnections = [SELECT Id, Name, Feature__c, Brand__c FROM TouchCRConnection__c WHERE Feature__c = 'Magento' AND isActive__c = true];
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

		timeScheduleJobs();
		this.magentoSchedulingOptionsChanged = false;

		Map<String, TouchCR_Settings__c> magentoStringSettings = getSettings(MAGENTO_SETTING_S.keySet());
		Map<String, TouchCR_Settings__c> magentoBooleanSettings = getSettings(MAGENTO_SETTING_B.keySet());
		Map<String, TouchCR_Settings__c> batchSettings = getSettings(BATCH_SETTING.keySet());

		this.magentoSalesforceMaster = Boolean.valueOf(magentoBooleanSettings.get('Magento.SalesforceMaster').Value__c);

		this.selectedStateMagento = batchSettings.get('Batch.MagentoStatus').Value__c;
		this.selectedStateMagento = String.isBlank(this.selectedStateMagento) ? 'Off' : this.selectedStateMagento;
		this.selectedStateMagento = String.isBlank( String.valueOf(this.nextRunTimeMagento) ) ? 'Off' : 'On';

		this.selectedFrequencyParameterMagento = batchSettings.get('Batch.MagentoFrequencyParameters').Value__c;
		this.selectedFrequencyParameterMagento = String.isBlank(this.selectedFrequencyParameterMagento) ? 'Days' : this.selectedFrequencyParameterMagento;

		this.selectedExecuteHoursMagento = batchSettings.get('Batch.MagentoHours').Value__c;
		this.selectedExecuteHoursMagento = String.isBlank(this.selectedExecuteHoursMagento) ? '1' : this.selectedExecuteHoursMagento;

		this.selectedExecuteMagento = batchSettings.get('Batch.MagentoTime').Value__c;
		this.selectedExecuteMagento = String.isBlank(this.selectedExecuteMagento) ? '0' : this.selectedExecuteMagento;

		this.selectedExecuteMagentoDay = batchSettings.get('Batch.MagentoDay').Value__c;
		this.selectedExecuteMagentoDay = String.isBlank(this.selectedExecuteMagentoDay) ? '1' : this.selectedExecuteMagentoDay;

		this.allFrequencyParametersMagento = getFrequencyParameters();
		this.allExecuteHoursMagento = getHoursFrequency();
		this.allExecuteAtMagento = getHours();

		this.allExecuteAtDayMagento = new List<SelectOption>();
		this.allExecuteAtDayMagento.add(new SelectOption('1','1 day'));
		this.allExecuteAtDayMagento.add(new SelectOption('2','2 days'));
		this.allExecuteAtDayMagento.add(new SelectOption('3','3 days'));
		this.allExecuteAtDayMagento.add(new SelectOption('4','4 days'));
		this.allExecuteAtDayMagento.add(new SelectOption('5','5 days'));
		this.allExecuteAtDayMagento.add(new SelectOption('6','6 days'));
		this.allExecuteAtDayMagento.add(new SelectOption('7','7 days'));


		this.allStatesMagento = new List<SelectOption>();
		this.allStatesMagento.add(new SelectOption('Off','Off'));
		this.allStatesMagento.add(new SelectOption('On','On'));
	}

	public void saveMagentoSettings() {

		List<TouchCR_Settings__c> settingsToUpsert = new List<TouchCR_Settings__c>();
		Map<String, TouchCR_Settings__c> magentoStringSettings = getSettings(MAGENTO_SETTING_S.keySet());
		Map<String, TouchCR_Settings__c> magentoBooleanSettings = getSettings(MAGENTO_SETTING_B.keySet());

		if (magentoBooleanSettings.get('Magento.SalesforceMaster').Value__c != String.valueOf(this.magentoSalesforceMaster)) {
			TouchCR_Settings__c settingMagentoSalesforceMaster = magentoBooleanSettings.get('Magento.SalesforceMaster');
			settingMagentoSalesforceMaster.Value__c = String.valueOf(this.magentoSalesforceMaster);
			settingsToUpsert.add(settingMagentoSalesforceMaster);
		}

		Map<String, TouchCR_Settings__c> batchSettings = getSettings(BATCH_SETTING.keySet());
		if (batchSettings.get('Batch.MagentoStatus').Value__c != this.selectedStateMagento) {
			TouchCR_Settings__c settingMagentoStatus = batchSettings.get('Batch.MagentoStatus');
			settingMagentoStatus.Value__c = this.selectedStateMagento;
			settingsToUpsert.add(settingMagentoStatus);
		}
		if (batchSettings.get('Batch.MagentoDay').Value__c != this.selectedExecuteMagentoDay) {
			TouchCR_Settings__c settingMagentoDay = batchSettings.get('Batch.MagentoDay');
			settingMagentoDay.Value__c = this.selectedExecuteMagentoDay;
			settingsToUpsert.add(settingMagentoDay);
			this.magentoSchedulingOptionsChanged = true;
		}
		if (batchSettings.get('Batch.MagentoTime').Value__c != this.selectedExecuteMagento) {
			TouchCR_Settings__c settingMagento = batchSettings.get('Batch.MagentoTime');
			settingMagento.Value__c = this.selectedExecuteMagento;
			settingsToUpsert.add(settingMagento);
			this.magentoSchedulingOptionsChanged = true;
		}
		if (batchSettings.get('Batch.MagentoFrequencyParameters').Value__c != this.selectedFrequencyParameterMagento) {
			TouchCR_Settings__c settingMagento = batchSettings.get('Batch.MagentoFrequencyParameters');
			settingMagento.Value__c = this.selectedFrequencyParameterMagento;
			settingsToUpsert.add(settingMagento);
			this.magentoSchedulingOptionsChanged = true;
		}
		if (batchSettings.get('Batch.MagentoHours').Value__c != this.selectedExecuteHoursMagento) {
			TouchCR_Settings__c settingMagento = batchSettings.get('Batch.MagentoHours');
			settingMagento.Value__c = this.selectedExecuteHoursMagento;
			settingsToUpsert.add(settingMagento);
			this.magentoSchedulingOptionsChanged = true;
		}

		if (this.selectedStateMagento == 'Off') {
			stopMonitor('MagentoSync');
		}
		else if (this.selectedStateMagento == 'On' && this.magentoSchedulingOptionsChanged) {
			stopMonitor('MagentoSync');
			startMonitor('MagentoSync');
		}
		timeScheduleJobs();

		if (!settingsToUpsert.isEmpty()) {
			try {
				SFDCAccessController.UpsertWithoutSharing (
					settingsToUpsert,
					'TouchCRConfigurationController.cls [saveMagentoSettings]',
					new List<Schema.DescribeFieldResult> {
						TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
					}
				);
				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Changes saved successfully!')
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}
	}

	public void cancelMagentoSettings() {
		initMagentoSettings();
		ApexPages.addmessage(
			new ApexPages.Message(ApexPages.Severity.WARNING, 'Your changes were cancelled.')
		);
	}

	public void executeNowMagento() {
		DateTime dt = DateTime.now().addMinutes(1);
		String cronString = '' + dt.second() + ' ' +
			dt.minute() + ' ' + dt.hour() + ' ' +
			dt.day() + ' ' + dt.month() + ' ? ' +
			dt.year();

		Boolean isRunning = false;
		for (String schedulerName : NAME_TO_CLASSES.get('MagentoSyncScheluders')) {
			if (getScheduleJobs(schedulerName) != null) {
				isRunning = true;
			}
		}

		if (searchActiveBatches(NAME_TO_CLASSES.get('MagentoSync')) == false && isRunning == false) {
			try {
				stopMonitor('MagentoSync');
				Type newMagentoScheduler = Type.forName('TouchCRMag', 'MagentoSyncAPIClient');
				System.schedule('MagentoSync' , cronString, (Schedulable)newMagentoScheduler.newInstance());
				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Magento Batch will be initiated in 1 minute')
				);
				timeScheduleJobs();
			}
			catch (exception e) {
				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:' + e.getMessage())
				);
			}
		}
		else {
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.WARNING, 'Magento Batch cannot be started, please try again later.')
			);
		}
	}

	/**
	 * AMAZON SETTINGS
	 */

	public Boolean amazonSchedulingOptionsChanged; //prevent rescheduling if nothing changed
	public Boolean amazonMergeSchedulingOptionsChanged;

	public Boolean amazonResolveEmail { get; set; }
	public Boolean amazonSalesforceMaster { get; set; }

	public String amazonDataFinderKey { get; set; }

	public String selectedStateAmazon { get; set; } // selected On/Off
	public String selectedStateAmazonMerge { get; set; } // selected On/Off
	public String selectedFrequencyParameterAmazon { get; set; } // selected Days/Hours
	public String selectedFrequencyParameterAmazonMerge { get; set; } // selected Days/Hours
	public String selectedExecuteHoursAmazon { get; set; } // 1 3 6 9 12 16 20
	public String selectedExecuteHoursAmazonMerge { get; set; } // 1 3 6 9 12 16 20
	public String selectedExecuteAmazon { get; set; } // 0 0 selectedTimer * * ?
	public String selectedExecuteAmazonMerge { get; set; } // 0 0 selectedTimer * * ?
	public String selectedExecuteAmazonDay { get; set; } // 0 0 selectedDay * * ?
	public String selectedExecuteAmazonMergeDay { get; set; } // 0 0 selectedDay * * ?
	public DateTime nextRunTimeAmazon { get; private set; }
	public DateTime nextRunTimeAmazonMerge { get; private set; }

	public List<SelectOption> allFrequencyParametersAmazon { get; set; }
	public List<SelectOption> allExecuteHoursAmazon {get; set;}
	public List<SelectOption> allExecuteAtAmazon { get; set; }
	public List<SelectOption> allExecuteAtDayAmazon { get; set; }
	public List<SelectOption> allStatesAmazon { get; set; }


	public List<TouchCRConnection__c> amazonConnections { get; set; }

	public void initAmazonSettings() {
		timeScheduleJobs();
		this.amazonSchedulingOptionsChanged = false;
		this.amazonMergeSchedulingOptionsChanged = false;

		this.amazonConnections = new List<TouchCRConnection__c>();

		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'TouchCRConnection__c',
				'TouchCRConfigurationController.cls [initAmazonSettings]',
				new List<Schema.DescribeFieldResult> {
					TouchCRConnection__c.Name.getDescribe(), TouchCRConnection__c.Feature__c.getDescribe(),
					TouchCRConnection__c.isActive__c.getDescribe(), TouchCRConnection__c.Brand__c.getDescribe()
				}
			);
			this.amazonConnections = [SELECT Id, Name, Feature__c, Brand__c FROM TouchCRConnection__c WHERE Feature__c = 'Amazon' AND isActive__c = true];
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

		Map<String, TouchCR_Settings__c> amazonStringSettings = getSettings(AMAZON_SETTING_S.keySet());
		Map<String, TouchCR_Settings__c> amazonBooleanSettings = getSettings(AMAZON_SETTING_B.keySet());
		Map<String, TouchCR_Settings__c> batchSettings = getSettings(BATCH_SETTING.keySet());

		this.amazonDataFinderKey = amazonStringSettings.get('Amazon.DataFinderKey').Value__c;

		this.amazonSalesforceMaster = Boolean.valueOf(amazonBooleanSettings.get('Amazon.SalesforceMaster').Value__c);
		this.amazonResolveEmail = Boolean.valueOf(amazonBooleanSettings.get('Amazon.ResolveEmail').Value__c);

		this.selectedStateAmazon = batchSettings.get('Batch.AmazonStatus').Value__c;
		this.selectedStateAmazon = String.isBlank(this.selectedStateAmazon) ? 'Off' : this.selectedStateAmazon;
		this.selectedStateAmazon = String.isBlank( String.valueOf(this.nextRunTimeAmazon) ) ? 'Off' : 'On';

		this.selectedFrequencyParameterAmazon = batchSettings.get('Batch.AmazonFrequencyParameters').Value__c;
		this.selectedFrequencyParameterAmazon = String.isBlank(this.selectedFrequencyParameterAmazon) ? 'Days' : this.selectedFrequencyParameterAmazon;

		this.selectedExecuteHoursAmazon = batchSettings.get('Batch.AmazonHours').Value__c;
		this.selectedExecuteHoursAmazon = String.isBlank(this.selectedExecuteHoursAmazon) ? '1' : this.selectedExecuteHoursAmazon;

		this.selectedExecuteAmazon = batchSettings.get('Batch.AmazonTime').Value__c;
		this.selectedExecuteAmazon = String.isBlank(this.selectedExecuteAmazon) ? '0' : this.selectedExecuteAmazon;

		this.selectedExecuteAmazonDay = batchSettings.get('Batch.AmazonDay').Value__c;
		this.selectedExecuteAmazonDay = String.isBlank(this.selectedExecuteAmazonDay) ? '1' : this.selectedExecuteAmazonDay;

		this.selectedStateAmazonMerge = batchSettings.get('Batch.AmazonMergeStatus').Value__c;
		this.selectedStateAmazonMerge = String.isBlank(this.selectedStateAmazonMerge) ? 'Off' : this.selectedStateAmazonMerge;
		this.selectedStateAmazonMerge = String.isBlank( String.valueOf(this.nextRunTimeAmazonMerge) ) ? 'Off' : 'On';

		this.selectedFrequencyParameterAmazonMerge = batchSettings.get('Batch.AmazonMergeFrequencyParameters').Value__c;
		this.selectedFrequencyParameterAmazonMerge = String.isBlank(this.selectedFrequencyParameterAmazonMerge) ? 'Days' : this.selectedFrequencyParameterAmazonMerge;

		this.selectedExecuteHoursAmazonMerge = batchSettings.get('Batch.AmazonMergeHours').Value__c;
		this.selectedExecuteHoursAmazonMerge = String.isBlank(this.selectedExecuteHoursAmazonMerge) ? '1' : this.selectedExecuteHoursAmazonMerge;

		this.selectedExecuteAmazonMerge = batchSettings.get('Batch.AmazonMergeTime').Value__c;
		this.selectedExecuteAmazonMerge = String.isBlank(this.selectedExecuteAmazonMerge) ? '0' : this.selectedExecuteAmazonMerge;

		this.selectedExecuteAmazonMergeDay = batchSettings.get('Batch.AmazonMergeDay').Value__c;
		this.selectedExecuteAmazonMergeDay = String.isBlank(this.selectedExecuteAmazonMergeDay) ? '1' : this.selectedExecuteAmazonMergeDay;

		this.allFrequencyParametersAmazon = getFrequencyParameters();
		this.allExecuteHoursAmazon = getHoursFrequency();
		this.allExecuteAtAmazon = getHours();

		this.allExecuteAtDayAmazon = new List<SelectOption>();
		this.allExecuteAtDayAmazon.add(new SelectOption('1','1 day'));
		this.allExecuteAtDayAmazon.add(new SelectOption('2','2 days'));
		this.allExecuteAtDayAmazon.add(new SelectOption('3','3 days'));
		this.allExecuteAtDayAmazon.add(new SelectOption('4','4 days'));
		this.allExecuteAtDayAmazon.add(new SelectOption('5','5 days'));
		this.allExecuteAtDayAmazon.add(new SelectOption('6','6 days'));
		this.allExecuteAtDayAmazon.add(new SelectOption('7','7 days'));


		this.allStatesAmazon = new List<SelectOption>();
		this.allStatesAmazon.add(new SelectOption('Off','Off'));
		this.allStatesAmazon.add(new SelectOption('On','On'));
	}

	public void saveAmazonSettings() {

		List<TouchCR_Settings__c> settingsToUpsert = new List<TouchCR_Settings__c>();
		Map<String, TouchCR_Settings__c> amazonStringSettings = getSettings(AMAZON_SETTING_S.keySet());
		Map<String, TouchCR_Settings__c> amazonBooleanSettings = getSettings(AMAZON_SETTING_B.keySet());

		if (amazonStringSettings.get('Amazon.DataFinderKey').Value__c != String.valueOf(this.amazonDataFinderKey)) {
			TouchCR_Settings__c settingAmazonDataFinderKey = amazonStringSettings.get('Amazon.DataFinderKey');
			settingAmazonDataFinderKey.Value__c = String.valueOf(this.amazonDataFinderKey);
			settingsToUpsert.add(settingAmazonDataFinderKey);
		}

		if (amazonBooleanSettings.get('Amazon.SalesforceMaster').Value__c != String.valueOf(this.amazonSalesforceMaster)) {
			TouchCR_Settings__c settingAmazonSalesforceMaster = amazonBooleanSettings.get('Amazon.SalesforceMaster');
			settingAmazonSalesforceMaster.Value__c = String.valueOf(this.amazonSalesforceMaster);
			settingsToUpsert.add(settingAmazonSalesforceMaster);
		}
		if (amazonBooleanSettings.get('Amazon.ResolveEmail').Value__c != String.valueOf(this.amazonResolveEmail)) {
			TouchCR_Settings__c settingAmazonResolveEmail = amazonBooleanSettings.get('Amazon.ResolveEmail');
			settingAmazonResolveEmail.Value__c = String.valueOf(this.amazonResolveEmail);
			settingsToUpsert.add(settingAmazonResolveEmail);
		}

		Map<String, TouchCR_Settings__c> batchSettings = getSettings(BATCH_SETTING.keySet());
		if (batchSettings.get('Batch.AmazonStatus').Value__c != this.selectedStateAmazon) {
			TouchCR_Settings__c settingAmazonStatus = batchSettings.get('Batch.AmazonStatus');
			settingAmazonStatus.Value__c = this.selectedStateAmazon;
			settingsToUpsert.add(settingAmazonStatus);
			this.amazonSchedulingOptionsChanged = true;
		}
		if (batchSettings.get('Batch.AmazonDay').Value__c != this.selectedExecuteAmazonDay) {
			TouchCR_Settings__c settingAmazonDay = batchSettings.get('Batch.AmazonDay');
			settingAmazonDay.Value__c = this.selectedExecuteAmazonDay;
			settingsToUpsert.add(settingAmazonDay);
			this.amazonSchedulingOptionsChanged = true;
		}
		if (batchSettings.get('Batch.AmazonTime').Value__c != this.selectedExecuteAmazon) {
			TouchCR_Settings__c settingAmazon = batchSettings.get('Batch.AmazonTime');
			settingAmazon.Value__c = this.selectedExecuteAmazon;
			settingsToUpsert.add(settingAmazon);
			this.amazonSchedulingOptionsChanged = true;
		}
		if (batchSettings.get('Batch.AmazonFrequencyParameters').Value__c != this.selectedFrequencyParameterAmazon) {
			TouchCR_Settings__c settingAmazon = batchSettings.get('Batch.AmazonFrequencyParameters');
			settingAmazon.Value__c = this.selectedFrequencyParameterAmazon;
			settingsToUpsert.add(settingAmazon);
			this.amazonSchedulingOptionsChanged = true;
		}
		if (batchSettings.get('Batch.AmazonHours').Value__c != this.selectedExecuteHoursAmazon) {
			TouchCR_Settings__c settingAmazon = batchSettings.get('Batch.AmazonHours');
			settingAmazon.Value__c = this.selectedExecuteHoursAmazon;
			settingsToUpsert.add(settingAmazon);
			this.amazonSchedulingOptionsChanged = true;
		}

		if (this.selectedStateAmazon == 'Off') {
			stopMonitor('AmazonSync');
		}
		else if (this.selectedStateAmazon == 'On' && this.amazonSchedulingOptionsChanged) {
			stopMonitor('AmazonSync');
			startMonitor('AmazonSync');
		}

		if (batchSettings.get('Batch.AmazonMergeStatus').Value__c != this.selectedStateAmazonMerge) {
			TouchCR_Settings__c settingAmazonMergeStatus = batchSettings.get('Batch.AmazonMergeStatus');
			settingAmazonMergeStatus.Value__c = this.selectedStateAmazonMerge;
			settingsToUpsert.add(settingAmazonMergeStatus);
			this.amazonMergeSchedulingOptionsChanged = true;
		}
		if (batchSettings.get('Batch.AmazonMergeDay').Value__c != this.selectedExecuteAmazonMergeDay) {
			TouchCR_Settings__c settingAmazonMergeDay = batchSettings.get('Batch.AmazonMergeDay');
			settingAmazonMergeDay.Value__c = this.selectedExecuteAmazonMergeDay;
			settingsToUpsert.add(settingAmazonMergeDay);
			this.amazonMergeSchedulingOptionsChanged = true;
		}
		if (batchSettings.get('Batch.AmazonMergeTime').Value__c != this.selectedExecuteAmazonMerge) {
			TouchCR_Settings__c settingAmazonMerge = batchSettings.get('Batch.AmazonMergeTime');
			settingAmazonMerge.Value__c = this.selectedExecuteAmazonMerge;
			settingsToUpsert.add(settingAmazonMerge);
			this.amazonMergeSchedulingOptionsChanged = true;
		}
		if (batchSettings.get('Batch.AmazonMergeFrequencyParameters').Value__c != this.selectedFrequencyParameterAmazonMerge) {
			TouchCR_Settings__c settingAmazonMerge = batchSettings.get('Batch.AmazonMergeFrequencyParameters');
			settingAmazonMerge.Value__c = this.selectedFrequencyParameterAmazonMerge;
			settingsToUpsert.add(settingAmazonMerge);
			this.amazonMergeSchedulingOptionsChanged = true;
		}
		if (batchSettings.get('Batch.AmazonMergeHours').Value__c != this.selectedExecuteHoursAmazonMerge) {
			TouchCR_Settings__c settingAmazonMerge = batchSettings.get('Batch.AmazonMergeHours');
			settingAmazonMerge.Value__c = this.selectedExecuteHoursAmazonMerge;
			settingsToUpsert.add(settingAmazonMerge);
			this.amazonMergeSchedulingOptionsChanged = true;
		}

		if (this.selectedStateAmazonMerge == 'Off') {
			stopMonitor('Amazon Find Mergeable Accounts');
		}
		else if (this.selectedStateAmazonMerge == 'On' && amazonMergeSchedulingOptionsChanged) {
			stopMonitor('Amazon Find Mergeable Accounts');
			startMonitor('Amazon Find Mergeable Accounts');
		}

		timeScheduleJobs();

		if (!settingsToUpsert.isEmpty()) {
			try {
				SFDCAccessController.UpsertWithoutSharing (
					settingsToUpsert,
					'TouchCRConfigurationController.cls [saveMagentoSettings]',
					new List<Schema.DescribeFieldResult> {
						TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
					}
				);
				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Changes saved successfully!')
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}
	}

	public void cancelAmazonSettings() {
		initAmazonSettings();
		ApexPages.addmessage(
			new ApexPages.Message(ApexPages.Severity.WARNING, 'Your changes were cancelled.')
		);
	}

	public void executeNowAmazon() {
		DateTime dt = Datetime.now().addMinutes(1);
		String cronString = '' + dt.second() + ' ' +
			dt.minute() + ' ' + dt.hour() + ' ' +
			dt.day() + ' ' + dt.month() + ' ? ' +
			dt.year();

		Boolean isRunning = false;
		for (String schedulerName : NAME_TO_CLASSES.get('AmazonSyncScheluders')) {
			if (getScheduleJobs(schedulerName) != null) {
				isRunning = true;
			}
		}

		if (searchActiveBatches(NAME_TO_CLASSES.get('AmazonSync')) == false && isRunning == false) {
			try {
				stopMonitor('AmazonSync');
				Type newAmazonScheduler = Type.forName('TouchCRAmz', 'AmazonSyncAPIClient');
				System.schedule('AmazonSync' , cronString, (Schedulable)newAmazonScheduler.newInstance());

				timeScheduleJobs();

				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Amazon Batch will be initiated in 1 minute')
				);
				timeScheduleJobs();
			}
			catch (exception e) {
				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:' + e.getMessage())
				);
			}
		}
		else {
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.WARNING, 'Amazon Batch cannot be started, please try again later.')
			);
		}
	}

	public void executeNowAmazonMergeSearch() {
		DateTime dt = Datetime.now().addMinutes(1);
		String cronString = '' + dt.second() + ' ' +
			dt.minute() + ' ' + dt.hour() + ' ' +
			dt.day() + ' ' + dt.month() + ' ? ' +
			dt.year();

		try {
			stopMonitor('Amazon Find Mergeable Accounts');
			Type newAmazonScheduler = Type.forName('TouchCRAmz', 'AmazonFindMergeableAccountsScheduler');
			System.schedule('Amazon Find Mergeable Accounts' , cronString, (Schedulable)newAmazonScheduler.newInstance());

			timeScheduleJobs();

			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Search mergeable accounts Batch will be initiated in 1 minute.')
			);
		}
		catch (exception e) {
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:' + e.getMessage())
			);
		}
	}


	/**
	* JET SETTINGS
	*/

	/*BATCH SETTINGS*/
	public String selectedStateJet { get; set; }

	public String selectedFrequencyParameterJet { get; set; }
	public String selectedExecuteJetDay { get; set; }
	public String selectedExecuteJet { get; set; }
	public String selectedExecuteHoursJet { get; set; }

	public List<SelectOption> allStatesJet { get; set; }

	public List<SelectOption> allFrequencyParametersJet { get; set; }
	public List<SelectOption> allExecuteHoursJet { get; set; }
	public List<SelectOption> allExecuteAtJet { get; set; }
	public List<SelectOption> allExecuteAtDayJet { get; set; }

	public DateTime nextRunTimeJet { get; private set; }

	/*JET AVAILABLE CONNECTION*/
	public List<TouchCRConnection__c> jetConnections { get; set; }

	public void initJetSettings() {

		timeScheduleJobs();

		this.jetConnections = [SELECT Id, Name, Feature__c, Brand__c, isActive__c FROM TouchCRConnection__c WHERE Feature__c = 'Jet' AND isActive__c = true];

		Map<String, TouchCR_Settings__c> jetStringSettings = getSettings(JET_SETTING_S.keySet());
		Map<String, TouchCR_Settings__c> jetBooleanSettings = getSettings(JET_SETTING_B.keySet());
		Map<String, TouchCR_Settings__c> batchSettings = getSettings(BATCH_SETTING.keySet());

		// SELECTED BATCH OPTIONS
		this.selectedStateJet = batchSettings.get('Batch.JetStatus').Value__c;
		this.selectedStateJet = String.isBlank(this.selectedStateJet) ? 'Off' : this.selectedStateJet;
		this.selectedStateJet = String.isBlank(String.valueOf(this.nextRunTimeJet)) ? 'Off' : 'On';

		this.selectedFrequencyParameterJet = batchSettings.get('Batch.JetFrequencyParameters').Value__c;
		this.selectedFrequencyParameterJet = String.isBlank(this.selectedFrequencyParameterJet) ? 'Days' : this.selectedFrequencyParameterJet;

		this.selectedExecuteHoursJet = batchSettings.get('Batch.JetHours').Value__c;
		this.selectedExecuteHoursJet = String.isBlank(this.selectedExecuteHoursJet) ? '1' : this.selectedExecuteHoursJet;

		this.selectedExecuteJet = batchSettings.get('Batch.JetTime').Value__c;
		this.selectedExecuteJet = String.isBlank(this.selectedExecuteJet) ? '0' : this.selectedExecuteJet;

		this.selectedExecuteJetDay = batchSettings.get('Batch.JetDay').Value__c;
		this.selectedExecuteJetDay = String.isBlank(this.selectedExecuteJetDay) ? '1' : this.selectedExecuteJetDay;

		// AVAILABLE BATCH OPTIONS
		this.allFrequencyParametersJet = getFrequencyParameters();
		this.allExecuteHoursJet = getHoursFrequency();
		this.allExecuteAtJet = getHours();

		this.allExecuteAtDayJet = new List<SelectOption>();
		this.allExecuteAtDayJet.add(new SelectOption('1', '1 day'));
		this.allExecuteAtDayJet.add(new SelectOption('2', '2 days'));
		this.allExecuteAtDayJet.add(new SelectOption('3', '3 days'));
		this.allExecuteAtDayJet.add(new SelectOption('4', '4 days'));
		this.allExecuteAtDayJet.add(new SelectOption('5', '5 days'));
		this.allExecuteAtDayJet.add(new SelectOption('6', '6 days'));
		this.allExecuteAtDayJet.add(new SelectOption('7', '7 days'));

		this.allStatesJet = new List<SelectOption>();
		this.allStatesJet.add(new SelectOption('Off', 'Off'));
		this.allStatesJet.add(new SelectOption('On', 'On'));
	}

	public void saveJetSettings() {

		List<TouchCR_Settings__c> settingsToUpsert = new List<TouchCR_Settings__c>();
		Map<String, TouchCR_Settings__c> jetStringSettings = getSettings(JET_SETTING_S.keySet());
		Map<String, TouchCR_Settings__c> jetBooleanSettings = getSettings(JET_SETTING_B.keySet());
		Map<String, TouchCR_Settings__c> batchSettings = getSettings(BATCH_SETTING.keySet());

		//BATCH SETTINGS
		if (batchSettings.get('Batch.JetStatus').Value__c != this.selectedStateJet) {
			TouchCR_Settings__c settingJetStatus = batchSettings.get('Batch.JetStatus');
			settingJetStatus.Value__c = this.selectedStateJet;
			settingsToUpsert.add(settingJetStatus);
		}
		if (batchSettings.get('Batch.JetDay').Value__c != this.selectedExecuteJetDay) {
			TouchCR_Settings__c settingJetDay = batchSettings.get('Batch.JetDay');
			settingJetDay.Value__c = this.selectedExecuteJetDay;
			settingsToUpsert.add(settingJetDay);
		}
		if (batchSettings.get('Batch.JetTime').Value__c != this.selectedExecuteJet) {
			TouchCR_Settings__c settingJet = batchSettings.get('Batch.JetTime');
			settingJet.Value__c = this.selectedExecuteJet;
			settingsToUpsert.add(settingJet);
		}
		if (batchSettings.get('Batch.JetFrequencyParameters').Value__c != this.selectedFrequencyParameterJet) {
			TouchCR_Settings__c settingJet = batchSettings.get('Batch.JetFrequencyParameters');
			settingJet.Value__c = this.selectedFrequencyParameterJet;
			settingsToUpsert.add(settingJet);
		}
		if (batchSettings.get('Batch.JetHours').Value__c != this.selectedExecuteHoursJet) {
			TouchCR_Settings__c settingJet = batchSettings.get('Batch.JetHours');
			settingJet.Value__c = this.selectedExecuteHoursJet;
			settingsToUpsert.add(settingJet);
		}

		if (this.selectedStateJet == 'Off') {
			stopMonitor('JetSync');
		}
		else if (this.selectedStateJet == 'On') {
			stopMonitor('JetSync');
			startMonitor('JetSync');
		}

		timeScheduleJobs();

		if (!settingsToUpsert.isEmpty()) {
			try {
				SFDCAccessController.UpsertWithoutSharing (
					settingsToUpsert,
					'TouchCRConfigurationController.cls [saveJetSettings]',
					new List<Schema.DescribeFieldResult>{
						TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
					}
				);
				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Changes saved successfully!')
				);
			}
			catch (Exception e) {
				throw new SFDCAccessControlException();
			}
		}
	}

	public void cancelJetSettings() {
		initJetSettings();
		ApexPages.addmessage(
			new ApexPages.Message(ApexPages.Severity.WARNING, 'Your changes were cancelled.')
		);
	}

	public void executeNowJet() {

		try {

			Type newJetScheduler = Type.forName('TouchCRJet', 'JetSyncAPIClient');
			Database.executeBatch((Database.Batchable<sObject>) newJetScheduler.newInstance());

			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Jet Batch will be initiated in 1 minute')
			);
		}
		catch (exception e) {
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:' + e.getMessage())
			);
		}
	}



	/**
	* SHOPPING CART SETTINGS
	*/


	public String scStoreLogo { get; set; }
	public String scBrand { get; set; }

	public void initScSettings() {

		Map<String, TouchCR_Settings__c> scStringSettings = getSettings(SC_SETTING_S.keySet());
		this.scStoreLogo = scStringSettings.get('SC.StoreLogo').Value__c;

		this.scBrand = scStringSettings.get('SC.Brand').Value__c;

		System.debug('scStoreLogo'+scStoreLogo);
	}

	public void saveScSettings() {
		// get selected brands

		Map<String, TouchCR_Settings__c> scStringSettings = getSettings(SC_SETTING_S.keySet());
		List<TouchCR_Settings__c> settingsToUpsert = new List<TouchCR_Settings__c>();



		if (scStringSettings.get('SC.StoreLogo').Value__c != this.scStoreLogo) {
			String url = this.scStoreLogo;
			if (url.right(1) != '/') {
				this.scStoreLogo = url + '/';
			}
			TouchCR_Settings__c newStoreUrlSetting = scStringSettings.get('SC.StoreLogo');
			newStoreUrlSetting.Value__c = this.scStoreLogo;
			settingsToUpsert.add(newStoreUrlSetting);
		}
		System.debug('scStoreLogo'+scStoreLogo);

	if ((scStringSettings.get('SC.Brand').Value__c != this.scBrand) || String.isBlank(this.scBrand)) {
			TouchCR_Settings__c newBrandSetting = scStringSettings.get('SC.Brand');
			newBrandSetting.Value__c = this.scBrand;
			settingsToUpsert.add(newBrandSetting);
		}


		System.debug('settingsToUpsert'+settingsToUpsert);
		if (!settingsToUpsert.isEmpty()) {
			try {
				SFDCAccessController.UpsertWithoutSharing (
					settingsToUpsert,
					'TouchCRConfigurationController.cls [saveMagentoSettings]',
					new List<Schema.DescribeFieldResult> {
						TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
					}
				);
				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Changes saved successfully!')
				);
			}
			catch (Exception e) {throw new SFDCAccessControlException();}
		}
	}

	public void cancelScSettings() {
		initScSettings();
		ApexPages.addmessage(
			new ApexPages.Message(ApexPages.Severity.WARNING, 'Your changes were cancelled.')
		);
	}

	/**
	* AFFILIATE SETTINGS
	*/

	public String selectedExecuteAtRefundPeriod { get; set; } // 0 0 selectedTimer * * ?
	public String selectedExecuteAtRefundPeriodDay { get; set; } // 0 0 selectedDay * * ?
	public String selectedDaysRefundPeriod {get; set;}
	public String selectedStateRefundPeriod { get; set; } // selected On/Off
	public DateTime nextRunTimeRefundPeriod { get; private set; }
	public List<SelectOption> allSelectedDaysRefundPeriod { get; set; }

	/*
	*	Initialization "Affiliate Setting" tab 
	*/
	public void initAffiliateSettings() {

		timeScheduleJobs();

		Map<String, TouchCR_Settings__c> batchSettings = getSettings(BATCH_SETTING.keySet());

		// SELECTED BATCH OPTIONS
		this.selectedExecuteAtRefundPeriod = batchSettings.get('Batch.RefundPeriodTime').Value__c;
		this.selectedExecuteAtRefundPeriodDay = batchSettings.get('Batch.RefundPeriodDay').Value__c;
		this.selectedStateRefundPeriod = batchSettings.get('Batch.RefundPeriodStatus').Value__c;
		this.selectedDaysRefundPeriod = batchSettings.get('Batch.RefundPeriodValue').Value__c;

		// AVAILABLE AFFILIATE OPTIONS
		this.allSelectedDaysRefundPeriod = new List<SelectOption>();
		this.allSelectedDaysRefundPeriod.add(new SelectOption('14','14 Days'));
		this.allSelectedDaysRefundPeriod.add(new SelectOption('30','1 Month'));

	}

	/*
	*	button "Save" on the "Affiliate Setting" tab.
	*/
	public void saveAffiliateSettings() {

		List<TouchCR_Settings__c> settingsToUpsert = new List<TouchCR_Settings__c>();
		Map<String, TouchCR_Settings__c> batchSettings = getSettings(BATCH_SETTING.keySet());

		//BATCH SETTINGS

		Boolean isRefundPeriodChanged = (
				this.selectedStateRefundPeriod != batchSettings.get('Batch.RefundPeriodStatus').Value__c ||
				this.selectedDaysRefundPeriod != batchSettings.get('Batch.RefundPeriodValue').Value__c ||
				this.selectedExecuteAtRefundPeriodDay != batchSettings.get('Batch.RefundPeriodDay').Value__c ||
				this.selectedExecuteAtRefundPeriod != batchSettings.get('Batch.RefundPeriodTime').Value__c
		);

		if (batchSettings.get('Batch.RefundPeriodStatus').Value__c != this.selectedStateRefundPeriod) {
			TouchCR_Settings__c settingStateRefundPeriod = batchSettings.get('Batch.RefundPeriodStatus');
			settingStateRefundPeriod.Value__c = this.selectedStateRefundPeriod;
			settingsToUpsert.add(settingStateRefundPeriod);
		}

		if (batchSettings.get('Batch.RefundPeriodValue').Value__c != this.selectedDaysRefundPeriod) {
			TouchCR_Settings__c settingDaysRefundPeriod = batchSettings.get('Batch.RefundPeriodValue');
			settingDaysRefundPeriod.Value__c = this.selectedDaysRefundPeriod;
			settingsToUpsert.add(settingDaysRefundPeriod);
		}

		if (batchSettings.get('Batch.RefundPeriodDay').Value__c != this.selectedExecuteAtRefundPeriodDay) {
			TouchCR_Settings__c settingExecuteAtRefundPeriodDay = batchSettings.get('Batch.RefundPeriodDay');
			settingExecuteAtRefundPeriodDay.Value__c = this.selectedExecuteAtRefundPeriodDay;
			settingsToUpsert.add(settingExecuteAtRefundPeriodDay);
		}

		if (batchSettings.get('Batch.RefundPeriodTime').Value__c != this.selectedExecuteAtRefundPeriod) {
			TouchCR_Settings__c settingExecuteAtRefundPeriod = batchSettings.get('Batch.RefundPeriodTime');
			settingExecuteAtRefundPeriod.Value__c = this.selectedExecuteAtRefundPeriod;
			settingsToUpsert.add(settingExecuteAtRefundPeriod);
		}

		if (this.selectedStateRefundPeriod == 'Off') {
			stopMonitor('RefundPeriod');
		}
		else if (this.selectedStateRefundPeriod == 'On' && isRefundPeriodChanged) {
			stopMonitor('RefundPeriod');
			startMonitor('RefundPeriod');
		}

		timeScheduleJobs();

		if (!settingsToUpsert.isEmpty()) {
			try {
				SFDCAccessController.UpsertWithoutSharing (
					settingsToUpsert,
					'TouchCRConfigurationController.cls [saveAffiliateSettings]',
					new List<Schema.DescribeFieldResult>{
						TouchCR_Settings__c.Name.getDescribe(), TouchCR_Settings__c.Value__c.getDescribe()
					}
				);
				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Changes saved successfully!')
				);
			}
			catch (Exception e) {
				throw new SFDCAccessControlException();
			}
		}
	}

	/*
	*	button "Cancel" on the "Affiliate Setting" tab.
	*/
	public void cancelAffiliateSettings() {
		initAffiliateSettings();
		ApexPages.addmessage(
			new ApexPages.Message(ApexPages.Severity.WARNING, 'Your changes were cancelled.')
		);
	}

	/*
	*	Execute Refund Period Batch
	*/
	public void executeNowRefundPeriod() {
		DateTime dt = Datetime.now().addMinutes(1);
		String cronString = '' + dt.second() + ' ' +
			dt.minute() + ' ' + dt.hour() + ' ' +
			dt.day() + ' ' + dt.month() + ' ? ' +
			dt.year();
		if (searchActiveBatches(NAME_TO_CLASSES.get('RefundPeriod')) == false) {
			stopMonitor('RefundPeriod');
			Type refundPeriod = Type.forName('CommissionEarnedScheduler');
			System.schedule('RefundPeriod' , cronString, (Schedulable)refundPeriod.newInstance());
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.CONFIRM, 'RefundPeriod Batch will be initiated in 1 minute')
			);
			timeScheduleJobs();

		}
		else {
			ApexPages.addmessage(
				new ApexPages.Message(ApexPages.Severity.WARNING, 'RefundPeriod Batch cannot be started, please try again later.')
			);
		}
	}
	
}