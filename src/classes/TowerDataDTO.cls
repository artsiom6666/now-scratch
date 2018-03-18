public with sharing class TowerDataDTO {

    // SETTINGS CLASS
    public class TowerDataSettings {
        //LEAD
        public Boolean leadValidateEmail { get {return (leadValidateEmail == null) ? false : leadValidateEmail;} set; }
        public Boolean leadCorrectEmail { get {return (leadCorrectEmail == null) ? false : leadCorrectEmail;} set; }
        public Boolean leadEnableDemo { get {return (leadEnableDemo == null) ? false : leadEnableDemo;} set; }
        public Boolean leadAppendDemoBasic { get {return (leadAppendDemoBasic == null) ? false : leadAppendDemoBasic;} set; }
        //EAM
        public Boolean leadAppendEam { get {return (accountAppendEam == null) ? false : accountAppendEam;} set; }

        public Boolean leadIpAddress { get {return (leadIpAddress == null) ? false : leadIpAddress;} set; }
        public Boolean leadAppendNameAddress { get {return (leadAppendNameAddress == null) ? false : leadAppendNameAddress;} set; }
        //
        public Boolean leadAppendDemoHousing { get {return (leadAppendDemoHousing == null) ? false : leadAppendDemoHousing;} set; }
        public Boolean leadAppendDemoInterest { get {return (leadAppendDemoInterest == null) ? false : leadAppendDemoInterest;} set; }
        public Boolean leadAppendDemoPurchase { get {return (leadAppendDemoPurchase == null) ? false : leadAppendDemoPurchase;} set; }
        //ACCOUNT
        public Boolean accountValidateEmail { get {return (accountValidateEmail == null) ? false : accountValidateEmail;} set; }
        public Boolean accountCorrectEmail { get {return (accountCorrectEmail == null) ? false : accountCorrectEmail;} set; }
        public Boolean accountEnableDemo { get {return (accountEnableDemo == null) ? false : accountEnableDemo;} set; }
        public Boolean accountAppendDemoBasic { get {return (accountAppendDemoBasic == null) ? false : accountAppendDemoBasic;} set; }
        //EAM
        public Boolean accountAppendEam { get {return (accountAppendEam == null) ? false : accountAppendEam;} set; }

        public Boolean accountIpAddress { get {return (accountIpAddress == null) ? false : accountIpAddress;} set; }
        public Boolean accountAppendNameAddress { get {return (accountAppendNameAddress == null) ? false : accountAppendNameAddress;} set; }
        //
        public Boolean accountAppendDemoHousing { get {return (accountAppendDemoHousing == null) ? false : accountAppendDemoHousing;} set; }
        public Boolean accountAppendDemoInterest { get {return (accountAppendDemoInterest == null) ? false : accountAppendDemoInterest;} set; }
        public Boolean accountAppendDemoPurchase { get {return (accountAppendDemoPurchase == null) ? false : accountAppendDemoPurchase;} set; }
        //license
        public String license { get {return (license == null) ? '' : license;} set; }
        public String demokey { get {return (demokey == null) ? '' : demokey;} set; }
        //GLOBAL
        //callouts allowed?
        public Boolean appendOn { get {return (appendOn == null) ? false : appendOn;} set; }
        public Integer reappendOnDays { get {return (reappendOnDays == null) ? 0 : reappendOnDays;} set; }
        public Boolean appendOnNewAccount { get {return (appendOnNewAccount == null) ? false : appendOnNewAccount;} set; }
        public Boolean appendOnNewLead { get {return (appendOnNewLead == null) ? false : appendOnNewLead;} set; }
        // date
        public Date appendIgnoreOlderThan { get; set; }
        // LEAD CONVERSION SETTIGNS
        public Boolean leadConvertAppend { get {return (leadConvertAppend == null) ? false : leadConvertAppend;} set; }
        public Integer leadConvertAccountAged { get {return (leadConvertAccountAged == null) ? 0 : leadConvertAccountAged;} set; }

        //virutal settings to show if ACCOUNT email needs correction or validation
        public Boolean accountAppendEmailOn { get {return (accountValidateEmail || accountCorrectEmail || accountAppendNameAddress); } set; }
        //virutal settings to show if LEAD email needs correction or validation
        public Boolean leadAppendEmailOn { get {return (leadValidateEmail || leadCorrectEmail || leadAppendNameAddress); } set; }

    }
    //RESPONSE API CLASSES
    public class TowerDataResponse {
        public String status_desc;

        public Integer status_code;

        public TowerDataResponseEmail email;
        public TowerDataFoundPostal found_postal;
        public TowerDataResponseIp ip;
    }

    public class TowerDataResponseEmail {
        public String username;
        public String domain;
        public String address;
        public String status_desc;
        public String domain_type;

        public Integer validation_level;
        public Integer status_code;

        public Boolean ok;
        public Boolean role;

        public List<String> corrections;
    }

    public class TowerDataFoundPostal {
        public String status_desc;
        public String address1;
        public String city;
        public String state;
        public String zip;

        public Integer status_code;

        public Boolean ok;
    }

    public class TowerDataResponseIp {
        public String status_desc;
        public String address;
        public String country_code;
        public String country_name;
        public String region;
        public String city;
        public String isp;
        public String domain;

        public Boolean ok;

        public Integer status_code;
    }

    //RESPONE DEMO CLASSES
    public class TowerDataResponseDemo {

        public String age;
        public String gender;
        public String zip;

        public String education;
        public String net_worth;
        public String household_income;
        public String home_market_value;
        public String home_owner_status;
        public String length_of_residence;
        public String marital_status;
        public String occupation;
        public String presence_of_children;

        public TowerDataResponseDemoInterests interests;
        public TowerDataResponseDemoEam eam;
    }

    public class TowerDataResponseDemoInterests {
        public Boolean arts_and_crafts { get {return (arts_and_crafts == null) ? false : arts_and_crafts;} set; }
        public Boolean blogging { get {return (blogging == null) ? false : blogging;} set; }
        public Boolean books { get {return (books == null) ? false : books;} set; }
        public Boolean business { get {return (business == null) ? false : business;} set; }
        public Boolean health_and_wellness { get {return (health_and_wellness == null) ? false : health_and_wellness;} set; }
        public Boolean news_and_current_events { get {return (news_and_current_events == null) ? false : news_and_current_events;} set; }

        public Boolean automotive { get {return (automotive == null) ? false : automotive;} set; }
        public Boolean baby_product_buyer { get {return (baby_product_buyer == null) ? false : baby_product_buyer;} set; }
        public Boolean beauty { get {return (beauty == null) ? false : beauty;} set; }
        public Boolean charitable_donors { get {return (charitable_donors == null) ? false : charitable_donors;} set; }
        public Boolean cooking { get {return (cooking == null) ? false : cooking;} set; }
        public Boolean discount_shopper { get {return (discount_shopper == null) ? false : discount_shopper;} set; }
        public Boolean high_end_brand_buyer { get {return (high_end_brand_buyer == null) ? false : high_end_brand_buyer;} set; }
        public Boolean home_and_garden { get {return (home_and_garden == null) ? false : home_and_garden;} set; }
        public Boolean home_improvement { get {return (home_improvement == null) ? false : home_improvement;} set; }
        public Boolean luxury_goods { get {return (luxury_goods == null) ? false : luxury_goods;} set; }
        public Boolean magazine_buyer { get {return (magazine_buyer == null) ? false : magazine_buyer;} set; }
        public Boolean outdoor_and_adventure { get {return (outdoor_and_adventure == null) ? false : outdoor_and_adventure;} set; }
        public Boolean pets { get {return (pets == null) ? false : pets;} set; }
        public Boolean sports { get {return (sports == null) ? false : sports;} set; }
        public Boolean technology { get {return (technology == null) ? false : technology;} set; }
        public Boolean travel { get {return (travel == null) ? false : travel;} set; }
    }

    public class TowerDataResponseDemoEam {
        public String date_first_seen;
        public Integer velocity;
        public Integer popularity;
        public String month_last_open;
    }

}