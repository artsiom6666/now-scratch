@isTest
public with sharing class RestPaymentMockResponse implements HttpCalloutMock {

	public HTTPResponse respond(HTTPRequest req) {
		HttpResponse request = new HttpResponse();
		request.setHeader('Access-Token', 'updatedTokeneyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyU0xZMU9FU1VHMzZDVFBIUlhMS1lLQ0EzIiwiaXNzIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hcHBsaWNhdGlvbnMvVWJlVU9WYlNVM1dCMVlCR05QaVl5IiwiaWF0IjoxNDg4MjgyNjA4LCJleHAiOjE0ODkxNDY2MDgsInNjb3BlIjoiIn0.5oTNt5CmE80imx4DvyZtgz8hOsaH22iePiDhT7Xpeqw');
		request.setHeader('Access-Token-Expire-Time', '86400');
		request.setHeader('Access-Token-Type', 'bearer');
		request.setBody('{"transactionId": "ch_19cu0KCF2TV51fDnCuGS5hUk","original": {"id": "ch_19cu0KCF2TV51fDnCuGS5hUk","object": "charge","amount": 24700,"amount_refunded": 0,"application": null,"application_fee": null,"balance_transaction": "txn_19cu0KCF2TV51fDnTMPwBkck","captured": true,"created": 1484648152,"currency": "usd","customer": "cus_9vJpSe54a4rpQl","description": null,"destination": null,"dispute": null,"failure_code": null,"failure_message": null,"fraud_details": {},"invoice": null,"livemode": false,"metadata": {},"order": null,"outcome": {"network_status": "approved_by_network","reason": null,"risk_level": "normal","seller_message": "Payment complete.","type": "authorized"},"paid": true,"receipt_email": null,"receipt_number": null,"refunded": false,"refunds": {"object": "list","data": [],"has_more": false,"total_count": 0,"url": "/v1/charges/ch_19cu0KCF2TV51fDnCuGS5hUk/refunds"},"review": null,"shipping": null,"source": {"id": "card_19bTCACF2TV51fDn01RGB9UX","object": "card","address_city": null,"address_country": null,"address_line1": null,"address_line1_check": null,"address_line2": null,"address_state": null,"address_zip": null,"address_zip_check": null,"brand": "Visa","country": "US","customer": "cus_9vJpSe54a4rpQl","cvc_check": null,"dynamic_last4": null,"exp_month": 1,"exp_year": 2017,"fingerprint": "SzkZweODjqZloxaR","funding": "credit","last4": "4242","metadata": {},"name": null,"tokenization_method": null},"source_transfer": null,"statement_descriptor": null,"status": "succeeded"}}');
		request.setStatus('OK');
		request.setStatusCode(200);
		System.assertEquals('OK', request.getStatus());
		return request;
	}
}