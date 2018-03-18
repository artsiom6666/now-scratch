public class USPSHttpCalloutMock implements HttpCalloutMock {

	public HTTPResponse respond(HTTPRequest req) {

		string IncomingRequest = req.getEndpoint();
		system.debug('Incoming EndPoint: ' + IncomingRequest);

		System.Httpresponse ReturnValue = new System.Httpresponse();

		string XMLValue = '';

		// to increase test coverage, we vary our response when certain key words are present
		if (IncomingRequest.contains('ERROR')) {

			// starting XML tags
			XMLValue = '<?xml version=\"1.0\"?><AddressValidateResponse><Address ID=\"0\">';

			// error
			XMLValue += '<Error><Number>-2147219401</Number>';
			XMLValue += '<Source>API_AddressCleancAddressClean.CleanAddress2;SOLServer.CallAddressDll</Source>';
			XMLValue += '<Description>Address Not Found.</Description>';

			// closing XML tags
			XMLValue += '</Error></Address></AddressValidateResponse>';


		} else if (IncomingRequest.contains('NULL')) {
			// starting XML tags
			XMLValue = '<?xml version=\"1.0\"?><AddressValidateResponse><Address ID=\"0\">';

			// return a blank address
			XMLValue += '<Address1></Address1>';
			XMLValue += '<Address2></Address2>';
			XMLValue += '<City></City><State></State><Zip5></Zip5><Zip4></Zip4>';

			// closing XML tags
			XMLValue += '</Address></AddressValidateResponse>';

		} else {
			// Default response . . . .
			// starting XML tags
			XMLValue = '<?xml version=\"1.0\"?><AddressValidateResponse><Address ID=\"0\">';

			// return the offical Test Request 1 from the USPS (with address1 added)
			XMLValue += '<Address1>Test</Address1>';
			XMLValue += '<Address2>6406 IVY LN</Address2>';
			XMLValue += '<City>GREENBELT</City><State>MD</State><Zip5>20770</Zip5><Zip4>1441</Zip4>';
			XMLValue += '</Address>';
			// closing XML tags
			XMLValue += '</AddressValidateResponse>';

		} // IncomingRequest.contains('ERROR')

		ReturnValue.setBody(XMLValue);
		ReturnValue.setHeader('Access-Token', 'updatedTokeneyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyU0xZMU9FU1VHMzZDVFBIUlhMS1lLQ0EzIiwiaXNzIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hcHBsaWNhdGlvbnMvVWJlVU9WYlNVM1dCMVlCR05QaVl5IiwiaWF0IjoxNDg4MjgyNjA4LCJleHAiOjE0ODkxNDY2MDgsInNjb3BlIjoiIn0.5oTNt5CmE80imx4DvyZtgz8hOsaH22iePiDhT7Xpeqw');
		ReturnValue.setHeader('Access-Token-Expire-Time', '86400');
		ReturnValue.setHeader('Access-Token-Type', 'bearer');

		return ReturnValue;

	} // HTTPResponse Method
} // USPSHttpCalloutMock