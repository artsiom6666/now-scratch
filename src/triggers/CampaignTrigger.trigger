trigger CampaignTrigger on Campaign (before insert, before update) {

	for (Campaign aCampaign : Trigger.new) {
		//Updated Standard Cost
		aCampaign.ActualCost = aCampaign.Total_Cost__c;

		String urlLanding, urlSource, urlMeduim, urlCampaign, urlContent, urlTerm, urlHash;
		PageReference pr;

		// Landing_Page__c is required field
		// url encode authority and path
		// the rest of parameters will be encoded by pagereference
		if (!String.isBlank(aCampaign.Landing_Page__c)) {
			urlLanding = aCampaign.Landing_Page__c.toLowerCase().trim();
		}
		//UTM_Source__c
		if (!String.isBlank(aCampaign.Ad_Platform__c)) {
			urlSource = aCampaign.Ad_Platform__c.toLowerCase().trim().replaceAll(' ', '_');
		}
		//UTM_Medium__c
		if (!String.isBlank(aCampaign.Buying_Type__c)) {
			urlMeduim = aCampaign.Buying_Type__c.toLowerCase().trim().replaceAll(' ', '_');
		}
		//UTM_Campaign__c
		if (!String.isBlank(aCampaign.Name)) {
			urlCampaign = aCampaign.Name.toLowerCase().trim().replaceAll(' ', '_');
		}
		if (!String.isBlank(aCampaign.Campaign__c)) {
			urlCampaign += aCampaign.Campaign__c.toLowerCase().trim().replaceAll(' ', '_');
		}
		//UTM_Content__c
		if (!String.isBlank(aCampaign.Ad_Type__c)) {
			urlContent = aCampaign.Ad_Type__c.toLowerCase().trim().replaceAll(' ', '_');
		}
		if (!String.isBlank(aCampaign.Content__c)) {
			urlContent += aCampaign.Content__c.toLowerCase().trim().replaceAll(' ', '_');
		}
		//Term__c
		if (!String.isBlank(aCampaign.Term__c)) {
			urlTerm = aCampaign.Term__c.toLowerCase().trim().replaceAll(' ', '_');
		}

		pr = new PageReference((String.isBlank(urlLanding)) ? '' : urlLanding);
		urlHash = '';

		if (!String.isBlank(urlSource)) {
			pr.getParameters().put('utm_source', urlSource);
			urlHash += urlSource;
		}
		if (!String.isBlank(urlMeduim)) {
			pr.getParameters().put('utm_medium', urlMeduim);
			urlHash += urlMeduim;
		}
		if (!String.isBlank(urlCampaign)) {
			pr.getParameters().put('utm_campaign', urlCampaign);
			urlHash += urlCampaign;
		}
		if (!String.isBlank(urlContent)) {
			pr.getParameters().put('utm_content', urlContent);
			urlHash += urlContent;
		}
		if (!String.isBlank(urlTerm)) {
			pr.getParameters().put('utm_term', urlTerm);
			urlHash += urlTerm;
		}

		// check for protocol
		String urlWithProtocol = pr.getUrl();
		try {
			new Url(urlWithProtocol);
		}
		catch (Exception e) {
			urlWithProtocol = 'http://' + urlWithProtocol;
		}
		aCampaign.URL__c = urlWithProtocol;
		aCampaign.UTM_Hash__c = urlHash;

		/**
		 * UTM_Source__c = TRIM( Ad_Platform__c )
		 * UTM_Medium__c = TEXT( Buying_Type__c )
		 * UTM_Campaign__c = SUBSTITUTE( Name , " ", "") & TRIM( Campaign__c )
		 * UTM_Content__c = SUBSTITUTE(TEXT( Ad_Type__c ), " ", "") & trim( Content__c )
		 * Term__c = Term__c
		 */

		/*Landing_Page__c
		&
		"?"
		&
		if(NOT(ISBLANK(UTM_Source__c)),"utm_source=" & TRIM(UTM_Source__c) & "&", "")
		&
		if(NOT(ISBLANK(UTM_Medium__c)),"utm_medium=" & TRIM(UTM_Medium__c) & "&", "")
		&
		if(NOT(ISBLANK(UTM_Campaign__c )),"utm_campaign=" & TRIM(UTM_Campaign__c) & "&", "")
		&
		if(NOT(ISBLANK(UTM_Content__c)),"utm_content=" & TRIM(UTM_Content__c) & "&", "")
		&
		if(NOT(ISBLANK(Term__c)),"utm_term=" & TRIM(Term__c), "")*/
	}
}