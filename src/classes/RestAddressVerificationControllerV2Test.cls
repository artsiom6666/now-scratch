@isTest
public class RestAddressVerificationControllerV2Test {

    static testMethod void testcreateNewShipping(){

        Test.setMock(HttpCalloutMock.class, new USPSHttpCalloutMock()); 
        
        Map<String, String> address = new  Map<String, String>();
        address.put('address', '73 east lake street');
        address.put('city', 'Chicago');
        address.put('state', 'IL');
        address.put('zip', '20770');

        String access_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyU0xZMU9FU1VHMzZDVFBIUlhMS1lLQ0EzIiwiaXNzIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hcHBsaWNhdGlvbnMvVWJlVU9WYlNVM1dCMVlCR05QaVl5IiwiaWF0IjoxNDg4MjgyNjA4LCJleHAiOjE0ODkxNDY2MDgsInNjb3BlIjoiIn0.5oTNt5CmE80imx4DvyZtgz8hOsaH22iePiDhT7Xpeqw';

		Map<String, String> uspsSettingsToUpsert = new Map<String, String>();
            uspsSettingsToUpsert.put('USPS.UserID', 'test');

        TouchCRHelper.setSettings(uspsSettingsToUpsert);

        Map<String, String> touchCrSettingsToUpsert = new Map<String, String>();
            touchCrSettingsToUpsert.put('Endpoint.TokenPart1', access_token.substring(0, 254));
            touchCrSettingsToUpsert.put('Endpoint.TokenPart2', access_token.substring(254));
            touchCrSettingsToUpsert.put('Endpoint.TokenType', 'Bearer');
            touchCrSettingsToUpsert.put('Endpoint.ClientId', 'Test');
            touchCrSettingsToUpsert.put('Endpoint.ClientSecret', 'Test');

        TouchCRHelper.setSettings(touchCrSettingsToUpsert);
        
        Test.startTest();
            RestAddressVerificationControllerV2.isProxy = true;
            String strResponse = RestAddressVerificationControllerV2.getValidate(address);
            List<String> apiCallInfo = RestAddressVerificationControllerV2.getApiCallInfo();
        Test.stopTest();

        Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();
        TouchCR_Settings__c tokenPart1 = settingsMap.get('Endpoint.TokenPart1');
        TouchCR_Settings__c tokenPart2 = settingsMap.get('Endpoint.TokenPart2');

		String updated_access_token = 'updatedToken' + access_token;

		//AUTH
		System.assertEquals(updated_access_token, tokenPart1.Value__c + tokenPart2.Value__c);
        //RESPONSE
        System.assertEquals('valid',strResponse);
        System.assertEquals(apiCallInfo[0], 'Request Body:');
        System.assertEquals(apiCallInfo[1], 'callout:TouchCRBase__SecureProxy/shipping/ShippingAPI.dll?API=Verify&XML=%3CAddressValidateRequest+USERID%3D%22test%22%3E%3CAddress%3E%3CAddress1%3E%3C%2FAddress1%3E%3CAddress2%3E73+east+lake+street%3C%2FAddress2%3E%3CCity%3EChicago%3C%2FCity%3E%3CState%3EIL%3C%2FState%3E%3CZip5%3E20770%3C%2FZip5%3E%3CZip4%3E%3C%2FZip4%3E%3C%2FAddress%3E%3C%2FAddressValidateRequest%3E&v=2&spApiKeyId=Test&spApiKeySecret=Test');
        System.assertEquals(apiCallInfo[2], 'Response Body:');
        System.assertEquals(apiCallInfo[3], '<?xml version="1.0"?><AddressValidateResponse><Address ID="0"><Address1>Test</Address1><Address2>6406 IVY LN</Address2><City>GREENBELT</City><State>MD</State><Zip5>20770</Zip5><Zip4>1441</Zip4></Address></AddressValidateResponse>');
    }

   static testMethod void testcreateNewShippingERROR(){

        Test.setMock(HttpCalloutMock.class, new USPSHttpCalloutMock());
        Map<String, String> uspsSettingsToUpsert = new Map<String, String>();
            uspsSettingsToUpsert.put('USPS.UserID', 'test');

        TouchCRHelper.setSettings(uspsSettingsToUpsert); 
        
        Map<String, String> address = new  Map<String, String>();
        address.put('address', 'ERROR');
        address.put('city', 'Chicago');
        address.put('state', 'IL');
        address.put('zip', '60601');
        
        Test.startTest();
        String strResponse = RestAddressVerificationControllerV2.getValidate(address);
        Test.stopTest();
        System.assertEquals('invalid',strResponse);
    }

   static testMethod void testcreateNewShippingNULL(){

       	Test.setMock(HttpCalloutMock.class, new USPSHttpCalloutMock());
        Map<String, String> uspsSettingsToUpsert = new Map<String, String>();
            uspsSettingsToUpsert.put('USPS.UserID', 'test');

        TouchCRHelper.setSettings(uspsSettingsToUpsert); 
        
        Map<String, String> address = new  Map<String, String>();
        address.put('address', 'NULL');
        address.put('city', 'Chicago');
        address.put('state', 'IL');
        address.put('zip', '60601');
        
        Test.startTest();
        String strResponse = RestAddressVerificationControllerV2.getValidate(address);
        Test.stopTest();
        System.assertEquals('invalid',strResponse);
    }
    
    static testMethod void setLogTest(){

        Test.setMock(HttpCalloutMock.class, new USPSHttpCalloutMock());
        Map<String, String> uspsSettingsToUpsert = new Map<String, String>();
            uspsSettingsToUpsert.put('USPS.UserID', 'test');

        TouchCRHelper.setSettings(uspsSettingsToUpsert); 
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        Account ant = new Account();
        ant.RecordTypeId = customerRecordType.Id;
        ant.FirstName = 'XXX';
        ant.LastName = 'YYY';
        ant.Phone = '9876543210';
        ant.PersonEmail = 'xxx009@ymail.com';
        ant.Orders_Failed__c = 10;
        insert ant;
        String accountId = ant.Id;

        RestAddressVerificationControllerV2.setLog('test', 'test', accountId);
        Log__c log = [SELECT Id, Event_Type__c, Event_Status__c, Event_Endpoint__c, Event_Description__c, Account__c FROM Log__c WHERE Account__c = :accountId];
        System.assertEquals('test', log.Event_Type__c);
        System.assertEquals('test', log.Event_Description__c);
    }
}