@isTest
public class RestFraudDetectionControllerMockResponse implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body;
        if (req.getBody().containsIgnoreCase('spApiKeyId') && req.getBody().containsIgnoreCase('spApiKeySecret')) {
            body = 'distance=;countryMatch=;countryCode=;freeMail=;anonymousProxy=;binMatch=;binCountry=;err=IP_NOT_FOUND;proxyScore=;ip_region=;ip_city=;ip_latitude=;ip_longitude=;binName=;ip_isp=;ip_org=;binNameMatch=;binPhoneMatch=;binPhone=;custPhoneInBillingLoc=;highRiskCountry=;queriesRemaining=449;cityPostalMatch=;shipCityPostalMatch=;maxmindID=LEE7JJV5;ip_asnum=;ip_userType=;ip_countryConf=;ip_regionConf=;ip_cityConf=;ip_postalCode=;ip_postalConf=;ip_accuracyRadius=;ip_netSpeedCell=;ip_metroCode=;ip_areaCode=;ip_timeZone=;ip_regionName=;ip_domain=;ip_countryName=;ip_continentCode=;ip_corporateProxy=;riskScore=0.23;prepaid=;minfraud_version=;service_level=standard';
        } 
        else {
            body = 'distance=;countryMatch=;countryCode=;freeMail=;anonymousProxy=;binMatch=;binCountry=;err=IP_NOT_FOUND;proxyScore=;ip_region=;ip_city=;ip_latitude=;ip_longitude=;binName=;ip_isp=;ip_org=;binNameMatch=;binPhoneMatch=;binPhone=;custPhoneInBillingLoc=;highRiskCountry=;queriesRemaining=449;cityPostalMatch=;shipCityPostalMatch=;maxmindID=LEE7JJV5;ip_asnum=;ip_userType=;ip_countryConf=;ip_regionConf=;ip_cityConf=;ip_postalCode=;ip_postalConf=;ip_accuracyRadius=;ip_netSpeedCell=;ip_metroCode=;ip_areaCode=;ip_timeZone=;ip_regionName=;ip_domain=;ip_countryName=;ip_continentCode=;ip_corporateProxy=;riskScore=0.23;prepaid=;minfraud_version=;service_level=standard;';
        }
        res.setBody(body);
        res.setHeader('Access-Token', 'updatedTokeneyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyU0xZMU9FU1VHMzZDVFBIUlhMS1lLQ0EzIiwiaXNzIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hcHBsaWNhdGlvbnMvVWJlVU9WYlNVM1dCMVlCR05QaVl5IiwiaWF0IjoxNDg4MjgyNjA4LCJleHAiOjE0ODkxNDY2MDgsInNjb3BlIjoiIn0.5oTNt5CmE80imx4DvyZtgz8hOsaH22iePiDhT7Xpeqw');
		res.setHeader('Access-Token-Expire-Time', '86400');
		res.setHeader('Access-Token-Type', 'bearer');
        System.assert(true);
        res.setStatusCode(200);
        return res;
    }
}