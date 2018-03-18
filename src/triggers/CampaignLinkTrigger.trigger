trigger CampaignLinkTrigger on Campaign_Links__c (before insert, before update) {

	List<Id> campaignIds = new List<Id>();

	for (Campaign_Links__c aCampaignLinks : Trigger.new) {
		//Remove the spaces from image field in Campaign Links
		if (aCampaignLinks.Image_Name__c != null) {
			if (aCampaignLinks.Image_Name__c.contains(' ')) {
				aCampaignLinks.Image_Name__c = aCampaignLinks.Image_Name__c.replace(' ', '_');
			}
		}
		if (aCampaignLinks.Headline_Text_Name__c != null) {
			if (aCampaignLinks.Headline_Text_Name__c.contains(' ')) {
				aCampaignLinks.Headline_Text_Name__c = aCampaignLinks.Headline_Text_Name__c.replace(' ', '_');
			}
		}
		if (aCampaignLinks.Email_Name__c != null) {
			if (aCampaignLinks.Email_Name__c.contains(' ')) {
				aCampaignLinks.Email_Name__c = aCampaignLinks.Email_Name__c.replace(' ', '_');
			}
		}
		if (aCampaignLinks.Email_Section_Name__c != null) {
			if (aCampaignLinks.Email_Section_Name__c.contains(' ')) {
				aCampaignLinks.Email_Section_Name__c = aCampaignLinks.Email_Section_Name__c.replace(' ', '_');
			}
		}
		if (aCampaignLinks.Email_Link_Name__c != null) {
			if (aCampaignLinks.Email_Link_Name__c.contains(' ')) {
				aCampaignLinks.Email_Link_Name__c = aCampaignLinks.Email_Link_Name__c.replace(' ', '_');
			}
		}
		campaignIds.add(aCampaignLinks.Campaign__c);
	}

	Map<Id, Campaign> newCampaigns = new Map<Id, Campaign>([
		SELECT Id, URL__c, UTM_Hash__c, Landing_Page__c
		FROM Campaign
		WHERE Id IN :campaignIds
	]);

	for (Campaign_Links__c aCampaignLink : Trigger.new) {
		Campaign campaignUrlUtm = newCampaigns.get(aCampaignLink.Campaign__C);
		aCampaignLink.UTM_Hash__c = campaignUrlUtm.UTM_Hash__c;

		String urlLanding = '';
		//override LandingPage for CampaignLinks
		if (String.isNotBlank(aCampaignLink.Landing_Page_Override__c)) {
			urlLanding = aCampaignLink.Landing_Page_Override__c.toLowerCase().trim();
		}
		else {
			if (String.isNotBlank(campaignUrlUtm.Landing_Page__c)) {
				urlLanding = campaignUrlUtm.Landing_Page__c.toLowerCase().trim();
			}
		}
		Pagereference prNew = new PageReference((String.isBlank(urlLanding)) ? '' : urlLanding);

		//use the Campaign parameters
		Pagereference prOld = new Pagereference(campaignUrlUtm.Url__c);
		String urlSource = prOld.getParameters().get('utm_source');
		String urlMeduim = prOld.getParameters().get('utm_medium');
		String urlCampaign = prOld.getParameters().get('utm_campaign');
		String urlContent = prOld.getParameters().get('utm_content');
		String urlTerm = prOld.getParameters().get('utm_term');

		String urlHash = '';
		//create a new URL for Campaign_Links__c
		if (String.isNotBlank(urlSource)) {
			prNew.getParameters().put('utm_source', urlSource);
			urlHash += urlSource;
		}
		if (String.isNotBlank(urlMeduim)) {
			prNew.getParameters().put('utm_medium', urlMeduim);
			urlHash += urlMeduim;
		}
		if (String.isNotBlank(urlCampaign)) {
			prNew.getParameters().put('utm_campaign', urlCampaign);
			urlHash += urlCampaign;
		}
		if (String.isNotBlank(urlContent)) {
			prNew.getParameters().put('utm_content', urlContent);
			urlHash += urlContent;
		}
		if (String.isBlank(urlTerm)) {
			urlTerm = '';
		}
		//adding Campaign parameters_Links__c for URL
		if (String.isNotBlank(aCampaignLink.Device__c)) {
			if (String.isBlank(urlTerm)) {
				urlTerm += aCampaignLink.Device__c.toLowerCase().trim();
			}
			else {
				urlTerm += '_' + aCampaignLink.Device__c.toLowerCase().trim();
			}
		}
		if (String.isNotBlank(aCampaignLink.Image_Name__c)) {
			if (String.isBlank(urlTerm)) {
				urlTerm += aCampaignLink.Image_Name__c.toLowerCase().trim();
			}
			else {
				urlTerm += '_' + aCampaignLink.Image_Name__c.toLowerCase().trim();
			}
		}
		if (String.isNotBlank(aCampaignLink.Headline_Text_Name__c)) {
			if (String.isBlank(urlTerm)) {
				urlTerm += aCampaignLink.Headline_Text_Name__c.toLowerCase().trim();
			}
			else {
				urlTerm += '_' + aCampaignLink.Headline_Text_Name__c.toLowerCase().trim();
			}
		}
		if (String.isNotBlank(aCampaignLink.Email_Name__c)) {
			if (String.isBlank(urlTerm)) {
				urlTerm += aCampaignLink.Email_Name__c.toLowerCase().trim();
			}
			else {
				urlTerm += '_' + aCampaignLink.Email_Name__c.toLowerCase().trim();
			}
		}
		if (String.isNotBlank(aCampaignLink.Email_Section_Name__c)) {
			if (String.isBlank(urlTerm)) {
				urlTerm += aCampaignLink.Email_Section_Name__c.toLowerCase().trim();
			}
			else {
				urlTerm += '_' + aCampaignLink.Email_Section_Name__c.toLowerCase().trim();
			}
		}
		if (String.isNotBlank(aCampaignLink.Email_Link_Name__c)) {
			if (String.isBlank(urlTerm)) {
				urlTerm += aCampaignLink.Email_Link_Name__c.toLowerCase().trim();
			}
			else {
				urlTerm += '_' + aCampaignLink.Email_Link_Name__c.toLowerCase().trim();
			}
		}
		if (String.isNotBlank(aCampaignLink.Ad_Sizes__c)) {
			if (String.isBlank(urlTerm)) {
				urlTerm += aCampaignLink.Ad_Sizes__c.toLowerCase().trim();
			}
			else {
				urlTerm += '_' + aCampaignLink.Ad_Sizes__c.toLowerCase().trim();
			}
		}

		aCampaignLink.UTM_Hash__c = urlHash + urlTerm;
		prNew.getParameters().put('utm_term', urlTerm);
		aCampaignLink.URL__c = prNew.getUrl();
	}
}