public with sharing class DataFinderApiMock implements HttpCalloutMock {

	protected Integer code;
	protected String status;
	protected String body;
	protected Map<String, String> responseHeaders;

	private static final Integer DEFAULT_CODE = 200;
	private static final String DEFAULT_STATUS = 'OK';
	private static final String DEFAULT_BODY = '';
	private static final Map<String, String> DEFAULT_HEADERS = new Map<String, String>{DataFinderApi.CONTENT_KEY => DataFinderApi.CONTENT_TYPE, 'Access-Token' => 'updatedTokeneyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyU0xZMU9FU1VHMzZDVFBIUlhMS1lLQ0EzIiwiaXNzIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hcHBsaWNhdGlvbnMvVWJlVU9WYlNVM1dCMVlCR05QaVl5IiwiaWF0IjoxNDg4MjgyNjA4LCJleHAiOjE0ODkxNDY2MDgsInNjb3BlIjoiIn0.5oTNt5CmE80imx4DvyZtgz8hOsaH22iePiDhT7Xpeqw', 'Access-Token-Expire-Time' => '86400', 'Access-Token-Type' => 'bearer'};

	// LBASFORD@HOTMAIL.COM
	public static final String RESULTS_ONE_NOT_INDIVHHLD = '{"datafinder":{"version":"2.0","query-id":"32ea231251ad5a3ed846b1bff878e0bb","results":[{"#RawScore":"22","#WeightedScore":"61.5","#RawMatchCodes":"F0,L0,LF0,R0","FirstName":"LAURIE","MiddleName":"G","LastName":"BASFORD","Address":"9715 SOTHERLOCH LAKE DR","City":"SPRING","State":"TX","Zip":"77379","Zip4":"3687","TimeStamp":"20150123","EmailAddr":"LBASFORD@HOTMAIL.COM","IP":"192.92.93.93","URLSource":"JCARTER_425_1.COM","EmailAddrUsable":"YES"}],"input-query":{"FirstName":"LAURIE","LastName":"BASFORD"},"num-results":1,"query-time":"0.088"}}';
	// wyoarts@google.com score 85 - wyoarts@yahoo.com score 90.342857142857
	public static final String RESULTS_TWO_INDIVHHLD = '{"datafinder":{"version":"2.0","query-id":"95a88fd8262d96769f65e95aa357de29","results":[{"#RawScore":"85","#WeightedScore":"809.39957142857","#RawMatchCodes":"F8,L0,C0,S0,Z0,AHN0,AS0,A0,LF0,ACSZ,-0F,INDIV,HHLD,R1","FirstName":"ANTHONY","LastName":"GUZZO","Address":"810 S 12TH ST","City":"LARAMIE","State":"WY","Zip":"82070","Zip4":"4630","Country":"US","TimeStamp":"20141219","EmailAddr":"wyoarts@google.com","IP":"69.46.191.186","URLSource":"CBSMARKETWATCH.COM","EmailAddrUsable":"YES"},{"#RawScore":"90.342857142857","#WeightedScore":"809.39957142857","#RawMatchCodes":"F8,L0,C0,S0,Z0,AHN0,AS0,A0,LF0,ACSZ,-0F,INDIV,HHLD,R1","FirstName":"ANTHONY","LastName":"GUZZO","Address":"810 S 12TH ST","City":"LARAMIE","State":"WY","Zip":"82070","Zip4":"4630","Country":"US","TimeStamp":"20141219","EmailAddr":"wyoarts@yahoo.com","IP":"69.46.191.186","URLSource":"CBSMARKETWATCH.COM","EmailAddrUsable":"YES"}],"input-query":{"City":"LARAMIE","FirstName":"A","Address":"810 S 12TH ST","LastName":"Guzzo","State":"WY","PostalCode":"82070","HouseNum":"810","Street":"S 12TH ST"},"num-results":2,"query-time":"2.726"}}';
	public static final String OK_NORESULT = '{"datafinder":{"version":"2.0","query-id":"26af652ac5a0a04aabebde82bc895dc4","input-query":{"FirstName":"Miste","LastName":"Adair","Phone":"3037153480"},"num-results":0,"query-time":"0.057"}}';
	public static final String ERR_INVALIDKEY = '{"datafinder":{"version":"2.0","query-id":"05420a80a54a53e292ac20273a69cabd","results":[],"input-query":{"FirstName":"LAURIE","LastName":"BASFORD"},"num-results":0,"query-time":"0.072","errors":["Please include a valid key and service."]}}';
	public static final String ERR = 'not a json';

	public DataFinderApiMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
		this.code = code;
		this.status = status;
		this.body = body;
		this.responseHeaders = responseHeaders;
	}

	public DataFinderApiMock(String body) {
		this(DEFAULT_CODE, DEFAULT_STATUS, body, DEFAULT_HEADERS);
	}

	public DataFinderApiMock() {
		this(DEFAULT_CODE, DEFAULT_STATUS, DEFAULT_BODY, DEFAULT_HEADERS);
	}

	public HTTPResponse respond(HTTPRequest req) {

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