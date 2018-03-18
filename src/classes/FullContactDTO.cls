public with sharing class FullContactDTO {

	// SETTINGS CLASS
	public class FullContactSettings {
		//APIKey
		public String apiKey { get {return (apiKey == null) ? '' : apiKey;} set; }
	}
	//RESPONSE API CLASSES
	public class FullContactResponse {
		public Integer status;
		public String message;
		public String requestId;
		public Double likelihood;

		public List<FullContactPhotos> photos;
		public FullContactContactInfo contactInfo;
		public List<FullContactOrganizations> organizations;
		public FullContactDemographics demographics;
		public List<FullContactSocialProfiles> socialProfiles;
		public FullContactDigitalFootprint digitalFootprint;
		public FullContactMacromeasures macromeasures;
	}

	public class FullContactPhotos {
		public String type;
		public String typeId;
		public String typeName;
		public String url;
		public Boolean isPrimary;
	}

	public class FullContactContactInfo {
		public String familyName;
		public String fullName;
		public String givenName;
		public List<FullContactWebsites> websites;
		public List<FullContactChats> chats;
	}

	public class FullContactWebsites {
		public String url;
	}

	public class FullContactChats {
		public String client;
		public String handle;
	}

	public class FullContactOrganizations {
		public Boolean isPrimary;
		public String name;
		public String startDate;
		public String endDate;
		public String title;
		public Boolean current;
	}

	public class FullContactDemographics {
		public String age;
		public String gender;
		public String ageRange;
		public String locationGeneral;
		public FullContactLocationDeduced locationDeduced;
	}

	public class FullContactLocationDeduced {
		public String normalizedLocation;
		public String deducedLocation;
		public Double likelihood;
		public FullContactCity city;
		public FullContactState state;
		public FullContactCountry country;
		public FullContactContinent continent;
		public FullContactCounty county;
	}

	public class FullContactCity {
		public Boolean deduced;
		public String name;
	}

	public class FullContactState {
		public Boolean deduced;
		public String name;
		public String code;
	}

	public class FullContactCountry {
		public Boolean deduced;
		public String name;
		public String code;
	}

	public class FullContactContinent {
		public Boolean deduced;
		public String name;
	}

	public class FullContactCounty {
		public Boolean deduced;
		public String name;
		public String code;
	}

	public class FullContactSocialProfiles {
		public String bio;
		public Integer followers;
		public Integer following;
		public String type;
		public String typeId;
		public String typeName;
		public String url;
		public String username;
		public String id;
		public String rss;
	}

	public class FullContactDigitalFootprint {
		public List<FullContactScores> scores;
		public List<FullContactTopics> topics;
	}

	public class FullContactScores {
		public String provider;
		public String type;
		public Integer value;
	}

	public class FullContactTopics {
		public String provider;
		public String value;
	}

	public class FullContactMacromeasures {
		public List<FullContactInterests> interests;
	}

	public class FullContactInterests {
		public String name;
		public String id;
		public Double score;
		public List<String> parents;
		public String category;
	}
}