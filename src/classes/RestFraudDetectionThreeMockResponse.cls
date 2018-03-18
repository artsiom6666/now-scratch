@isTest
public class RestFraudDetectionThreeMockResponse implements HttpCalloutMock {

	public HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		String str = 'distance=;countryMatch=;countryCode=;freeMail=;anonymousProxy=;binMatch=;binCountry=;err=IP_NOT_FOUND;proxyScore=;ip_region=;ip_city=;ip_latitude=;ip_longitude=;binName=;ip_isp=;ip_org=;binNameMatch=;binPhoneMatch=;binPhone=;custPhoneInBillingLoc=;highRiskCountry=;queriesRemaining=449;cityPostalMatch=;shipCityPostalMatch=;maxmindID=LEE7JJV5;ip_asnum=;ip_userType=;ip_countryConf=;ip_regionConf=;ip_cityConf=;ip_postalCode=;ip_postalConf=;ip_accuracyRadius=;ip_netSpeedCell=;ip_metroCode=;ip_areaCode=;ip_timeZone=;ip_regionName=;ip_domain=;ip_countryName=;ip_continentCode=;ip_corporateProxy=;riskScore=90.0;prepaid=;minfraud_version=;service_level=standard';
		res.setBody(str);
		System.assert(true);
		res.setStatusCode(200);
		return res;
	}
}