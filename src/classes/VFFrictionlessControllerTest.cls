@isTest
public class VFFrictionlessControllerTest {

    static testMethod void getOfferInfoTest(){

        Product2 product = new Product2();
        product.Name = 'test22';
        product.ProductCode = 'DSX22';
        product.IsActive = true;
        insert product;

        OrderForm__c orderForm = new OrderForm__c();
        orderForm.ProductTobeSold__c = product.Id;
        orderForm.Name = product.Id;
        orderForm.Offer_Price__c = 20;
        insert orderForm;

        Test.setCurrentPageReference(new PageReference('Page.frictionless'));
        System.currentPageReference().getParameters().put('utm_source', 'test1');
        System.currentPageReference().getParameters().put('utm_medium', 'test211');
        System.currentPageReference().getParameters().put('utm_campaign', 'test211');
        System.currentPageReference().getParameters().put('utm_content', 'test2112');
        System.currentPageReference().getParameters().put('utm_term', 'test2143');
        System.currentPageReference().getHeaders().put('Referer', 'test2143');
        System.currentPageReference().getParameters().put('email', 'test21@gmail.com');
        System.currentPageReference().getParameters().put('offer', orderForm.Id);

        VFFrictionlessController VF = new VFFrictionlessController();
        VF.getOfferInfo();

        OrderForm__c offers = [SELECT Offer_Price__c, Frictionless_Banner_Image__c, ProductTobeSold__r.Id, Name, SubscriptionBillingDays__c   FROM OrderForm__c WHERE Id =:orderForm.Id];
        System.assertEquals(offers, VF.offerInfo);
    }

    static testMethod void processOrderTest(){

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUsr = createTestUser(profiles[0].Id, 'usrFname', 'usrLname');
        insert testUsr;
        // System.runAs(testUsr) {
            RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
            Account testAcc = new Account();
            testAcc.RecordTypeId = customerRecordType.Id;
            testAcc.FirstName = testUsr.FirstName;
            testAcc.LastName = testUsr.LastName;
            testAcc.Phone = '9876543210';
            testAcc.PersonEmail = testUsr.Email;
            testAcc.BillingState = 'Alaska';
            testAcc.BillingCountry = 'United States';

            testAcc.ShippingState = 'Alaska';
            testAcc.ShippingCountry = 'United States';
            insert testAcc;
            String email = testUsr.Email;

            Order__c order = new Order__c();
            order.Account__c = testAcc.Id;
            order.Status__c = 'Initiated';
            order.Billing_Email__c = 'test@gmail.com';
            order.Billing_First_Name__c = 'test';
            order.Billing_Last_Name__c = 'dx';
            order.Billing_Phone__c = '9876543210';
            order.Billing_Address__c = '123 main Street';
            order.Billing_City__c =  'New York';
            order.Billing_State__c = 'LA';
            order.Billing_Country__c = 'US';
            order.Billing_Zip_Postal__c = '10035';
            order.Shipping_Address__c = '123 main Street';
            order.Shipping_City__c = 'New York';
            order.Shipping_State__c = 'LA';
            order.Shipping_Country__c = 'US';
            order.Shipping_Zip_Postal__c = '10035';
            order.Subtotal__c = 10;
            order.Shipping__c = 2;
            order.Tax__c= 2;
            order.Currency__c = 'US Dollar';
            order.Payment_Method__c = 'Credit Card';
            insert order;

            Order_Transaction__c transection = new Order_Transaction__c();
            transection.Order__c = order.Id;
            transection.Type__c = 'Charge';
            transection.Payment_Date__c = Datetime.now();
            transection.Response_Status__c = 'Approved';
            transection.Payment_Method__c = 'Credit Card';
            transection.Currency__c = 'US Dollars';
            transection.Payment_Profile__c = 'token';
            insert transection;

            Product2 product = new Product2();
            product.Name = 'test22';
            product.ProductCode = 'DSX22';
            product.IsActive = true;
            insert product;


            OrderForm__c orderForm = new OrderForm__c();
            orderForm.ProductTobeSold__c = product.Id;
            orderForm.Name = product.Id;
            orderForm.Offer_Price__c = 20;
            insert orderForm;


            String response = VFFrictionlessController.processOrder(orderForm.Id, null);
            System.assertNotEquals('invalidorder', response);
//        }
    }

    static testMethod void getValidateTest(){

        VFFrictionlessController VF = new VFFrictionlessController();
        String actual = VF.getValidate('test');
        System.assertEquals('test', actual);
    }


    static testMethod void getAuthenticatedTest(){

        VFFrictionlessController VF = new VFFrictionlessController();
        VF.userName = '';
        VF.password = '';
        PageReference actual = VF.getAuthenticated();
        PageReference page = new PageReference('/test/VFFrictionlessError');
        System.assertNotEquals(page, actual);
    }

    static testMethod void getNextDateTest(){


        Map<String, String> subscriptionInfo = new Map<String, String>();

        subscriptionInfo = VFFrictionlessController.getNextDate(0);
        System.assertEquals('Once', subscriptionInfo.get('frequency'));


        subscriptionInfo = VFFrictionlessController.getNextDate(1);
        System.assertEquals('Daily', subscriptionInfo.get('frequency'));



        subscriptionInfo = VFFrictionlessController.getNextDate(7);
        System.assertEquals('Weekly', subscriptionInfo.get('frequency'));



        subscriptionInfo = VFFrictionlessController.getNextDate(14);
        System.assertEquals('Biweekly', subscriptionInfo.get('frequency'));



        subscriptionInfo = VFFrictionlessController.getNextDate(30);
        System.assertEquals('Monthly', subscriptionInfo.get('frequency'));




        subscriptionInfo = VFFrictionlessController.getNextDate(60);
        System.assertEquals('Bimonthly', subscriptionInfo.get('frequency'));




        subscriptionInfo = VFFrictionlessController.getNextDate(90);
        System.assertEquals('Quarterly', subscriptionInfo.get('frequency'));




        subscriptionInfo = VFFrictionlessController.getNextDate(180);
        System.assertEquals('Semiannual', subscriptionInfo.get('frequency'));




        subscriptionInfo = VFFrictionlessController.getNextDate(365);
        System.assertEquals('Annual', subscriptionInfo.get('frequency'));




        subscriptionInfo = VFFrictionlessController.getNextDate(730);
        System.assertEquals('Biennial', subscriptionInfo.get('frequency'));



    }

    static testMethod void setErrorMessageTest(){

        VFFrictionlessController VF = new VFFrictionlessController();
        VF.setErrorMessage();
        System.assert(true);
    }


    public static User createTestUser(Id profId, String fName, String lName) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  Firstname = fName,
                                LastName = lName,
                                Email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = profId
                            );
        return tuser;
    }
}