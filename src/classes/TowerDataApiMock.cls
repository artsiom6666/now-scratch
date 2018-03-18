@isTest
public class TowerDataApiMock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    protected Boolean defaultMode = false;

    private static final Integer DEFAULT_CODE = 200;
    private static final String DEFAULT_STATUS = 'OK';
    private static final String DEFAULT_BODY = '';
    private static final Map<String, String> DEFAULT_HEADERS = new Map<String, String>{'Content-Type:' => 'application/json', 'Access-Token' => 'updatedTokeneyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyU0xZMU9FU1VHMzZDVFBIUlhMS1lLQ0EzIiwiaXNzIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hcHBsaWNhdGlvbnMvVWJlVU9WYlNVM1dCMVlCR05QaVl5IiwiaWF0IjoxNDg4MjgyNjA4LCJleHAiOjE0ODkxNDY2MDgsInNjb3BlIjoiIn0.5oTNt5CmE80imx4DvyZtgz8hOsaH22iePiDhT7Xpeqw', 'Access-Token-Expire-Time' => '86400', 'Access-Token-Type' => 'bearer'};

    public static final String OK_EMAIL = '{"email":{"ok":true,"status_code":110,"status_desc":"Invalid character in address","validation_level":2,"address":"john;doe@example.com","username":null,"domain":null,"domain_type":null,"role":false,"corrections":["john.doe@example.com","johndoe@example.com"]},"found_postal":{"ok":true,"status_code":10,"status_desc":"Data found","fname":"JANE","lname":"SMITH","address1":"100 MAIN ST APT 3","address2":null,"city":"SPRINGFIELD","state":"MA","zip":"11111","plus4":"1234","source":"email"},"ip":{"status_code":10,"status_desc":"IP Found","ok":true,"address":"66.108.76.101","country_code":"US","country_name":"UNITED STATES","region":"NY","city":"NEW YORK","isp":"TIME WARNER CABLE","domain":"roadrunner.com"},"status_code":10,"status_desc":"Success"}';
    public static final String OK_DEMO = '{"age":"45-54","gender":"Female","zip":"60614","education":"Completed College","net_worth":"500k-750k","household_income":"150k-175k","home_market_value":"350k-500k","home_owner_status":"Own","length_of_residence":"3 Years","marital_status":"Single","occupation":"Professional","presence_of_children":"No","eam":{"month_last_open":"2016-04","velocity":10,"date_first_seen":"2010-04-17","popularity":9},"interests":{"arts_and_crafts":true,"blogging":true,"books":true,"business":true,"health_and_wellness":true,"news_and_current_events":true,"automotive":true,"baby_product_buyer":true,"beauty":true,"charitable_donors":true,"cooking":true,"discount_shopper":true,"high_end_brand_buyer":true,"home_and_garden":true,"home_improvement":true,"luxury_goods":true,"magazine_buyer":true,"outdoor_and_adventure":true,"pets":true,"sports":true,"technology":true,"travel":true}}';

    public TowerDataApiMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    public TowerDataApiMock(String body) {
        this(DEFAULT_CODE, DEFAULT_STATUS, body, DEFAULT_HEADERS);
    }

    public TowerDataApiMock() {
        this(DEFAULT_CODE, DEFAULT_STATUS, DEFAULT_BODY, DEFAULT_HEADERS);
        this.defaultMode = true;
    }

    public HTTPResponse respond(HTTPRequest req) {

        System.assertEquals('GET', req.getMethod());

        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }

        //send a default response body
        String endpoint = req.getEndpoint();
        //email api response, endpoint has license param
        if (endpoint.containsIgnoreCase('license=') && defaultMode) {
            this.body = OK_EMAIL;
        }
        //demo api response, enpoint has api_key param
        else if (endpoint.containsIgnoreCase('api_key=') && defaultMode) {
            this.body = OK_DEMO;
        }

        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }

}