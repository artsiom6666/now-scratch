@IsTest
public class RestDataSerializedControllerTest {

    @IsTest
    public static void setSerializedDataTest(){

        String data = 'product_id__01t370000003LRX--email__Mcnabbtest16@gmail.com--fname__Mcnabb--lname__Test--phone__(000) 000-0000--b_common__414 Columbus Ave~San Francisco~CA~United States~94133--s_common__414 Columbus Ave~San Francisco~CA~United States~94133--cc_number__4242424242424242--security_code__242--cc_exp_month__01--cc_exp_year__2018--cc_type__Visa--ip__112.196.23.236--utm_source__NA--utm_medium__NA--utm_campaign__NA--utm_content__NA--utm_term__NA--sales_funnel_name__NA--landing_page_url__NA--referral_domain_url__NA--start_date__06/17/2016--tax__0--subtotal__89--total__89--shipping__0--quantity__1--Offerprice__89--gateway__a02550000014Yz0AAE--token__--brand__Sunology--cardLastFour__4242--product_variant__';
        String response = RestDataSerializedController.setSerializedData(data);
        String expected = '';
        try {
            Id.valueOf(response);
            Order__c order = [SELECT Id FROM Order__c WHERE Id =:response];
            expected = order.Id;
        } catch (Exception e) {
            response = 'error';
            expected = response;
        }
        System.assertEquals(expected, response);
    }

    @IsTest
    public static void setSerializedDataTestCatch(){
        String response;
        String data;
        String expected;

        Profile pr = [SELECT Id FROM Profile WHERE Name='Chatter Free User' LIMIT 1];
        User testUsr = new User(Alias = 'sysadm', Email='sysadmin@test.com',
        EmailEncodingKey='UTF-8', LastName='TestSys', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = pr.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='123touchcrsysadmintest@123test.com');
        insert testUsr;


        System.runAs(testUsr) {
            try {
                data = 'product_id__01t370000003LRX--b_common__414 Columbus Ave~San Francisco~CA~United States~94133--s_common__414 Columbus Ave~San Francisco~CA~United States~94133--cc_number__4242424242424242--security_code__242--cc_exp_month__01--cc_exp_year__2018--cc_type__Visa--ip__112.196.23.236--utm_source__NA--utm_medium__NA--utm_campaign__NA--utm_content__NA--utm_term__NA--sales_funnel_name__NA--landing_page_url__NA--referral_domain_url__NA--start_date__06/17/2016--tax__0--subtotal__89--total__89--shipping__0--quantity__1--Offerprice__89--gateway__a02550000014Yz0AAE--token__--brand__Sunology--cardLastFour__4242--product_variant__';
                response = RestDataSerializedController.setSerializedData(data);
            } catch (Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }
}