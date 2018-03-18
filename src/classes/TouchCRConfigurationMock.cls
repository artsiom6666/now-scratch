@isTest
global class TouchCRConfigurationMock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    protected Boolean defaultMode = false;

    private static final Integer DEFAULT_CODE = 200;
    private static final String DEFAULT_STATUS = 'OK';
    private static final String DEFAULT_BODY = '';
    private static final Map<String, String> DEFAULT_HEADERS = new Map<String, String>{'Content-Type:' => 'application/json'};

    global TouchCRConfigurationMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    global TouchCRConfigurationMock(String body) {
        this(DEFAULT_CODE, DEFAULT_STATUS, body, DEFAULT_HEADERS);
    }

    global TouchCRConfigurationMock() {
        this(DEFAULT_CODE, DEFAULT_STATUS, DEFAULT_BODY, DEFAULT_HEADERS);
        this.defaultMode = true;
    }

	global HTTPResponse respond(HTTPRequest req) {
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