@isTest
public class PushNotificationMock implements HttpCalloutMock{
	protected Integer code;
	protected String status;
	protected String body;
	protected Map<String, String> responseHeaders;

	private static final Integer DEFAULT_CODE = 200;
	private static final String DEFAULT_STATUS = 'OK';
	private static final String DEFAULT_BODY = '';
	private static final Map<String, String> DEFAULT_HEADERS = new Map<String, String>{'Content-Type:' => 'application/json'};

	public PushNotificationMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
		this.code = code;
		this.status = status;
		this.body = body;
		this.responseHeaders = responseHeaders;
	}

	public PushNotificationMock(Integer code, String status, String body) {
		this(code, status, body, DEFAULT_HEADERS);
	}

	public PushNotificationMock(String body) {
		this(DEFAULT_CODE, DEFAULT_STATUS, body, DEFAULT_HEADERS);
	}

	public PushNotificationMock() {
		this(DEFAULT_CODE, DEFAULT_STATUS, DEFAULT_BODY, DEFAULT_HEADERS);
	}

	public PushNotificationMock(String param, Boolean defaultMode) {
		String body;
		if (!defaultMode) {
			if (param == 'sendNotification') {
				body = '{"multicast_id":6434007731026625482,"success":1,"failure":0,"canonical_ids":0,"results":[{"message_id":"0:1516018162130446%cc9b4facf9fd7ecd"}]}';
			}
			else if (param == 'createTopic') {
				body = '[{}]';
			}
		}
		this.code = DEFAULT_CODE;
		this.status = DEFAULT_STATUS;
		this.body = body;
		this.responseHeaders = DEFAULT_HEADERS;
	}

	public HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();

		if (this.status == 'Exception') {
			calloutException e = (CalloutException)CalloutException.class.newInstance();
			e.setMessage(this.body);
			throw e;
		}

		for (String key : this.responseHeaders.keySet()) {
			res.setHeader(key, this.responseHeaders.get(key));
		}

		res.setBody(this.body);
		res.setStatusCode(this.code);
		res.setStatus(this.status);
		return res;
	}
}