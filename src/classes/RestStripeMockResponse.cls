@isTest
public class RestStripeMockResponse implements HttpCalloutMock{

	public HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		String result = 'TChargentResult:[DebugString=null, Message=Transaction created (TRX-000004052) Gateway returns the status: "Approved" Gateway message: "", Reload=true, Status=OK, TransactID=a0855000001elxBAAQ, order_JSON=null, transaction_JSON=null]';
		res.setBody(result);
		System.assert(true);
		res.setStatusCode(200);
		return res;
	}
}