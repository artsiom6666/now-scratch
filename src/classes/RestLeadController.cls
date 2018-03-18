public with sharing class RestLeadController {

	public static String createLead(String email, String phone, String fname, String lname, String utm_medium, String utm_campaign, String utm_content, String utm_term, String sales_funnel_name,
									String referral_domain_url, String landing_page_url, String utm_source){

		String response;
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Account',
				'RestLeadController.cls [createLead]',
				new List<Schema.DescribeFieldResult> {
					Account.Id.getDescribe()
				}
			);

			List<Account> accounts = [SELECT Id from Account  WHERE PersonEmail = :email LIMIT 1];
			if (accounts.size()>0) {
				/* If PersonAccount's record already exist */
				response = 'Exist';
			} else {
				SFDCAccessController.AccessibleWithoutSharing (
					'Lead',
					'RestLeadController.cls [createLead]',
					new List<Schema.DescribeFieldResult> {
						Lead.Id.getDescribe()
					}
				);

				List<Lead> leads = [SELECT Id from Lead  WHERE Email = :email LIMIT 1];

				/* If PersonAccount's record does not exist */
				if (leads.size() == 0) {
					Lead ld = new Lead();
					List<String> temp = email.split('@');
					ld.FirstName = fname;
					ld.LastName = lname;
					ld.Email = email;
					ld.Status = 'Open';
					ld.utm_source__c = utm_source;
					ld.utm_medium__c = utm_medium;
					ld.utm_campaign__c = utm_campaign;
					ld.utm_content__c = utm_content;
					ld.utm_term__c = utm_term;
					ld.Sales_Funnel__c = sales_funnel_name;
					ld.Referral_Domain__c = referral_domain_url;
					ld.Landing_Page_URL__c = landing_page_url;

					SFDCAccessController.InsertWithoutSharing (
						ld,
						'RestLeadController.cls [createLead]',
						new List<Schema.DescribeFieldResult> {
							Lead.Email.getDescribe(), Lead.FirstName.getDescribe(),
							Lead.LastName.getDescribe(), Lead.utm_source__c.getDescribe(),
							Lead.utm_medium__c.getDescribe(), Lead.utm_campaign__c.getDescribe(),
							Lead.utm_content__c.getDescribe(), Lead.utm_term__c.getDescribe(),
							Lead.Sales_Funnel__c.getDescribe(), Lead.Referral_Domain__c.getDescribe(),
							Lead.Landing_Page_URL__c.getDescribe(), Lead.Status.getDescribe()
						}
					);
					response = 'Added';

				} else if (phone != 'NA') {
					Lead ld = leads[0];
					/* Update Lead if new information comes in  */
					ld.Phone = phone;
					ld.FirstName = fname;
					ld.LastName = lname;
					ld.utm_source__c = utm_source;
					ld.utm_medium__c = utm_medium;
					ld.utm_campaign__c = utm_campaign;
					ld.utm_content__c = utm_content;
					ld.utm_term__c = utm_term;
					ld.Sales_Funnel__c = sales_funnel_name;
					ld.Referral_Domain__c = referral_domain_url;
					ld.Landing_Page_URL__c = landing_page_url;

					SFDCAccessController.UpdateWithoutSharing (
						ld,
						'RestLeadController.cls [createLead]',
						new List<Schema.DescribeFieldResult> {
							Lead.Phone.getDescribe(), Lead.FirstName.getDescribe(),
							Lead.LastName.getDescribe(), Lead.utm_source__c.getDescribe(),
							Lead.utm_medium__c.getDescribe(), Lead.utm_campaign__c.getDescribe(),
							Lead.utm_content__c.getDescribe(), Lead.utm_term__c.getDescribe(),
							Lead.Sales_Funnel__c.getDescribe(), Lead.Referral_Domain__c.getDescribe(),
							Lead.Landing_Page_URL__c.getDescribe()
						}
					);
					response = 'Updated';
				}
			}
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
		return response;
	}

	public static String setLead(Map<String, String> generalData) {
		try {
			String idLead = generalData.containsKey('id') ? String.valueOf(generalData.get('id')) : null;
			String lastName = generalData.containsKey('lastName') ? generalData.get('lastName') : null;
			String firstName = generalData.containsKey('firstName') ? generalData.get('firstName') : null;
			String email = generalData.containsKey('email') ? generalData.get('email') : null;
			String phone = generalData.containsKey('phone') ? generalData.get('phone') : null;
			String mobilePhone = generalData.containsKey('mobilePhone') ? generalData.get('mobilePhone') : null;

			String street = generalData.containsKey('street') ? generalData.get('street') : null;
			String city = generalData.containsKey('city') ? generalData.get('city') : null;
			String state = generalData.containsKey('state') ? generalData.get('state') : null;
			String postalCode = generalData.containsKey('postalCode') ? generalData.get('postalCode') : null;
			String country = generalData.containsKey('country') ? generalData.get('country') : null;
			String stateCode = generalData.containsKey('stateCode') ? generalData.get('stateCode') : null;
			String countryCode = generalData.containsKey('countryCode') ? generalData.get('countryCode') : null;

			Decimal gLongitude = generalData.containsKey('longitude') ? Decimal.valueOf(generalData.get('longitude')) : null;
			Decimal gLatitude = generalData.containsKey('latitude') ? Decimal.valueOf(generalData.get('latitude')) : null;

			String subId1 = generalData.containsKey('subId1') ? String.valueOf(generalData.get('subId1')) : null;
			String subId2 = generalData.containsKey('subId2') ? String.valueOf(generalData.get('subId2')) : null;
			String subId3 = generalData.containsKey('subId3') ? String.valueOf(generalData.get('subId3')) : null;
			String subId4 = generalData.containsKey('subId4') ? String.valueOf(generalData.get('subId4')) : null;
			String subId5 = generalData.containsKey('subId5') ? String.valueOf(generalData.get('subId5')) : null;
			String utmSource = generalData.containsKey('utmSource') ? String.valueOf(generalData.get('utmSource')) : null;
			String utmMedium = generalData.containsKey('utmMedium') ? String.valueOf(generalData.get('utmMedium')) : null;
			String utmCampaign = generalData.containsKey('utmCampaign') ? String.valueOf(generalData.get('utmCampaign')) : null;
			String utmContent = generalData.containsKey('utmContent') ? String.valueOf(generalData.get('utmContent')) : null;
			String utmTerm = generalData.containsKey('utmTerm') ? String.valueOf(generalData.get('utmTerm')) : null;

			String codeFields = TouchCRHelper.isSCPEnabled() == TRUE ? ' StateCode, CountryCode, ' : '';

			String leadQueryString = 'SELECT Id, LastName, FirstName, Street, City, State, PostalCode, ' +
				'Country, Latitude, Longitude, Phone, ' + codeFields +
				'Email, MobilePhone, Status ' +
				'FROM Lead ';
			leadQueryString += String.isEmpty(idLead) ? ' WHERE Email =\''+String.escapeSingleQuotes(email)+'\'' : ' WHERE Id =\''+String.escapeSingleQuotes(idLead)+'\'';
			List<Lead> lead = Database.query(leadQueryString);

			Lead leadItem = lead.isEmpty() ? new Lead() : lead[0];

			leadItem.LastName = String.isNotBlank(lastName) ? lastName : leadItem.LastName;
			leadItem.FirstName = String.isNotBlank(firstName) ? firstName : leadItem.FirstName;
			leadItem.Email  = String.isNotBlank(email) ? email : leadItem.Email;
			leadItem.Phone = String.isNotBlank(phone) ? phone : leadItem.Phone;
			leadItem.MobilePhone = String.isNotBlank(mobilePhone) ? mobilePhone : leadItem.MobilePhone;

			leadItem.Street = String.isNotBlank(street) ? street : leadItem.Street;
			leadItem.City = String.isNotBlank(city) ? city : leadItem.City;
			leadItem.State = String.isNotBlank(state) ? state : leadItem.State;
			leadItem.PostalCode = String.isNotBlank(postalCode) ? postalCode : leadItem.PostalCode;
			leadItem.Country = String.isNotBlank(country) ? country : leadItem.Country;

			leadItem.Sub_Id1__c = String.isNotBlank(subId1) ? subId1 : leadItem.Sub_Id1__c;
			leadItem.Sub_Id2__c = String.isNotBlank(subId2) ? subId2 : leadItem.Sub_Id2__c;
			leadItem.Sub_Id3__c = String.isNotBlank(subId3) ? subId3 : leadItem.Sub_Id3__c;
			leadItem.Sub_Id4__c = String.isNotBlank(subId4) ? subId4 : leadItem.Sub_Id4__c;
			leadItem.Sub_Id5__c = String.isNotBlank(subId5) ? subId5 : leadItem.Sub_Id5__c;
			leadItem.utm_source__c = String.isNotBlank(utmSource) ? utmSource : leadItem.utm_source__c;
			leadItem.utm_medium__c = String.isNotBlank(utmMedium) ? utmMedium : leadItem.utm_medium__c;
			leadItem.utm_campaign__c = String.isNotBlank(utmCampaign) ? utmCampaign : leadItem.utm_campaign__c;
			leadItem.utm_content__c = String.isNotBlank(utmContent) ? utmContent : leadItem.utm_content__c;
			leadItem.utm_term__c = String.isNotBlank(utmTerm) ? utmTerm : leadItem.utm_term__c;
			
			if (TouchCRHelper.isSCPEnabled()) {		
				leadItem.put('StateCode', String.isNotBlank(stateCode) ? stateCode : leadItem.get('StateCode'));
				leadItem.put('CountryCode', String.isNotBlank(countryCode) ? countryCode : leadItem.get('CountryCode'));
			}

			leadItem.Longitude = gLongitude != null ? gLongitude : leadItem.Longitude;
			leadItem.Latitude = gLatitude != null ? gLatitude : leadItem.Latitude;
			upsert leadItem;

			return '{"leadId":"' + leadItem.Id + '","message":"success"}';
		} catch (Exception e) {
			return '{"error":"' + e.getMessage() + '","message":"error"}';
		}
	}


}