@isTest
public class FullContactApiMock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    private static final Integer DEFAULT_CODE = 200;
    private static final String DEFAULT_STATUS = 'OK';
    private static final String DEFAULT_BODY = '{"status":200,"requestId":"a5dd3684-fba1-439b-ba06-8f6e5438ec2f","likelihood":0.99,"photos":[{"type":"foursquare","typeId":"foursquare","typeName":"Foursquare","url":"https://d2ojpxxtu63wzl.cloudfront.net/static/a7e6a5aba590d4933e35eaadabd97fd2_44e00e968ac57725a15b32f9ca714827aff8e4818d290cb0c611f2e2585253b3","isPrimary":true}],"contactInfo":{"chats":[{"client":"gtalk","handle":"lorangb@gmail.com"},{"client":"skype","handle":"bart.lorang"}],"websites":[{"url":"https://fullcontact.com/bart"},{"url":"http://bartlorang.com"}],"familyName":"Lorang","fullName":"BartLorang","givenName":"Bart"},"organizations":[{"isPrimary":false,"name":"FullContact","startDate":"2010","title":"Co-Founder & CEO","current":true},{"isPrimary":false,"name":"V1.vc","startDate":"2015-07","title":"Co-Founder & Managing Director","current":true}],"demographics":{"locationDeduced":{"normalizedLocation":"Boulder,Colorado,United States","deducedLocation":"Boulder,Colorado,United States","city":{"deduced":false,"name":"Boulder"},"state":{"deduced":false,"name":"Colorado","code":"CO"},"country":{"deduced":false,"name":"United States","code":"US"},"continent":{"deduced":true,"name":"North America"},"county":{"deduced":true,"name":"Boulder"},"likelihood":1},"gender":"Male","locationGeneral":"Boulder,Colorado,United States"},"socialProfiles":[{"bio":"Co-FounderandCEOofFullContact","type":"aboutme","typeId":"aboutme","typeName":"About.me","url":"https://about.me/lorangb","username":"lorangb"},{"bio":"Entrepeneur,TechNerd;CEOandCo-Founderof@fullcontact.Passionateaboutsolvingtheworldscontactinformationproblemandhelpingentrepreneurs.","followers":2919,"type":"angellist","typeId":"angellist","typeName":"AngelList","url":"https://angel.co/bartlorang","username":"bartlorang","id":"182"},{"type":"facebook","typeId":"facebook","typeName":"Facebook","url":"https://www.facebook.com/bart.lorang"},{"type":"flickr","typeId":"flickr","typeName":"Flickr","url":"https://www.flickr.com/people/39267654@N00","username":"39267654@n00","id":"39267654@N00"},{"type":"github","typeId":"github","typeName":"Github","url":"https://github.com/lorangb","username":"lorangb"},{"followers":1,"type":"google","typeId":"google","typeName":"GooglePlus","url":"https://plus.google.com/111748526539078793602","id":"111748526539078793602"},{"bio":"http://about.me/lorangb","type":"gravatar","typeId":"gravatar","typeName":"Gravatar","url":"https://gravatar.com/blorang","username":"blorang","id":"18197740"},{"type":"hackernews","typeId":"hackernews","typeName":"HackerNews","url":"http://news.ycombinator.com/user?id=lorangb","username":"lorangb"},{"type":"instagram","typeId":"instagram","typeName":"Instagram","url":"https://instagram.com/bartlorang"},{"bio":"CEO&FounderofFullContactManagingDirectorofv1.vcTechEntrepreneur,Investor","type":"keybase","typeId":"keybase","typeName":"Keybase","url":"https://keybase.io/bartlorang","username":"bartlorang","id":"b4efc8f483638567f42dca0561caa319"},{"bio":"Mr.Lorangisaprovenentrepreneur,executiveandmanagerintheglobaltechnologyindustry.Mr.Lorangisactiveinthestartuptechnologycommunityasanangelinvestor,strategicadvisorandspeakeratindustryevents.BartservesasCo-Founder&CEOofFullContact.Mr.LorangisresponsibleforcommunicatingFullContactsvisionandstrategy.Mr.Lorangisavisionarytechnologistwithextensiveexperienceconceiving,designing,building,marketingandsellingenterprisesoftwaresolutionsonaglobalscale.BartisalsoCo-FounderandManagingDirectorofv1.vc,a$5Mseedstagefunddedicatedtohelpingcrazyentrepreneurschangetheworld.BartservesontheBoardoftheColoradoTechnologyAssociation,RaptMediaandisontheAdvisoryBoardofEducationFundingPartners.BartisaregularguestonFOXBusinesschannelandhasbeenfeaturedbyABC,CNN,FOXNews,MSNBC,Forbes,FastCompany,Yahoo,IncMagazineandTechCrunch.PriortofoundingFullContact,Mr.LorangwasanownerinDimensionTechnologySolutionswhereheservedasPresidentandoversawalldaytodayoperations,customerengagements,partnerrelations,productdevelopment,salesandmarketingfunctions.Mr.Lorangisrecognizedforprovidingsolutionsthataresimpleandworkreliably.Hestronglybelievesinusingtechnologytosolveproblemsasopposedtousingproblemstodemonstratetechnology.Mr.LorangholdsaBachelorofSciencedegreeinComputerSciencefromtheUniversityofColoradoandanMBAfromtheDanielsCollegeofBusinessatUniversityofDenver.Specialties:Investments,Startups,FinancialAnalysis,Sales,TechnicalSales,Implementations,SystemIntegration,ProjectManagement,Leadership","followers":500,"following":500,"type":"linkedin","typeId":"linkedin","typeName":"LinkedIn","url":"https://www.linkedin.com/in/bartlorang","username":"bartlorang","id":"8995706"},{"followers":91,"following":26,"type":"pinterest","typeId":"pinterest","typeName":"Pinterest","url":"http://www.pinterest.com/lorangb/","username":"lorangb"},{"type":"plancast","typeId":"plancast","typeName":"Plancast","url":"http://www.plancast.com/lorangb","username":"lorangb"},{"type":"quora","typeId":"quora","typeName":"Quora","url":"http://www.quora.com/bart-lorang","username":"bart-lorang"},{"bio":"CEO&Co-Founderof@FullContact,ManagingDirector@v1vc_.TechEntrepreneur,Investor.Husbandto@parkerbensonandFathertoGreysonLorang","followers":5454,"following":741,"type":"twitter","typeId":"twitter","typeName":"Twitter","url":"https://twitter.com/bartlorang","username":"bartlorang","id":"5998422"},{"type":"xing","typeId":"xing","typeName":"Xing","url":"https://www.xing.com/profile/bart_lorang2","username":"bart_lorang2"},{"type":"youtube","typeId":"youtube","typeName":"YouTube","url":"https://youtube.com/user/lorangb","username":"lorangb"}],"digitalFootprint":{"topics":[{"provider":"aboutme","value":"AngelInvestor"},{"provider":"aboutme","value":"Entrepreneur"},{"provider":"aboutme","value":"Husband"},{"provider":"aboutme","value":"TechNerd"},{"provider":"aboutme","value":"Technology"}]}}';
    private static final Map<String, String> DEFAULT_HEADERS = new Map<String, String>{'Content-Type:' => 'application/json', 'Access-Token' => 'updatedTokeneyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyU0xZMU9FU1VHMzZDVFBIUlhMS1lLQ0EzIiwiaXNzIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hcHBsaWNhdGlvbnMvVWJlVU9WYlNVM1dCMVlCR05QaVl5IiwiaWF0IjoxNDg4MjgyNjA4LCJleHAiOjE0ODkxNDY2MDgsInNjb3BlIjoiIn0.5oTNt5CmE80imx4DvyZtgz8hOsaH22iePiDhT7Xpeqw', 'Access-Token-Expire-Time' => '86400', 'Access-Token-Type' => 'bearer'};

    public FullContactApiMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    public FullContactApiMock(String body) {
        this(DEFAULT_CODE, DEFAULT_STATUS, body, DEFAULT_HEADERS);
    }

    public FullContactApiMock() {
        this(DEFAULT_CODE, DEFAULT_STATUS, DEFAULT_BODY, DEFAULT_HEADERS);
    }

    public HTTPResponse respond(HTTPRequest req) {

        System.assertEquals('GET', req.getMethod());

        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }

        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }

}