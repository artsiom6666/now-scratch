public with sharing class VFFrictionlessController {

	/* Login Credentials */
	public String userName{get;set;}
	public String password{get;set;}

	/* Tracking data */
	public String utm_source{get;set;}
	public String utm_medium{get;set;}
	public String utm_campaign{get;set;}
	public String utm_content{get;set;}
	public String utm_term{get;set;}
	public String sales_funnel_name{get;set;}
	public String landing_page_url{get;set;}
	public String referral_domain_url{get;set;}
	public Id offerId{get;set;}
	Public Id productId{get;set;}

	/* VisualForce pages Massages */
	public String pageResponse{get;set;}
	public String ajaxStatus{get;set;}
	public String ipAddress{get;set;}

	/* Offer information */
	public OrderForm__c offerInfo{get;set;}

	/* Get Offer information from Offer Id which come from Frictionless URL */
	public void getOfferInfo(){

		/* get tracking value from frictionless URl */
		utm_source = ApexPages.currentPage().getParameters().get('utm_source');
		utm_source = getValidate(utm_source);

		utm_medium = ApexPages.currentPage().getParameters().get('utm_medium');
		utm_medium = getValidate(utm_medium);

		utm_campaign = ApexPages.currentPage().getParameters().get('utm_campaign');
		utm_campaign = getValidate(utm_campaign);

		utm_content = ApexPages.currentPage().getParameters().get('utm_content');
		utm_content = getValidate(utm_content);

		utm_term = ApexPages.currentPage().getParameters().get('utm_term');
		utm_term = getValidate(utm_term);

		sales_funnel_name = ApexPages.currentPage().getParameters().get('sales_funnel_name');
		sales_funnel_name = getValidate(sales_funnel_name);

		landing_page_url = 'customerservice/apex/VFFrictionlessPage';

		referral_domain_url = ApexPages.currentPage().getHeaders().get('Referer');
		referral_domain_url = getValidate(referral_domain_url);

		userName = ApexPages.currentPage().getParameters().get('email');
		userName = getValidate(userName);

		offerId = ApexPages.currentPage().getParameters().get('offer');
		offerId = getValidate(offerId);

		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'OrderForm__c',
				'VFFrictionlessController.cls [getOfferInfo]',
				new List<Schema.DescribeFieldResult> {
					OrderForm__c.Offer_Price__c.getDescribe(), OrderForm__c.Frictionless_Banner_Image__c.getDescribe(),
					OrderForm__c.Name.getDescribe(), OrderForm__c.SubscriptionBillingDays__c.getDescribe()
				}
			);
			SFDCAccessController.AccessibleWithoutSharing (
				'Product2',
				'VFFrictionlessController.cls [getOfferInfo]',
				new List<Schema.DescribeFieldResult> {
					Product2.Id.getDescribe()
				}
			);
			List<OrderForm__c> offers = [
				SELECT Offer_Price__c, Frictionless_Banner_Image__c, ProductTobeSold__r.Id, Name, SubscriptionBillingDays__c
				FROM OrderForm__c
				WHERE Id =:offerId
			];
			if (offers.size() > 0) {
				offerInfo = offers[0];
				productId = offers[0].ProductTobeSold__r.Id;
			} else {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Page URL'));
				pageResponse = 'true';
			}
		}
		catch (Exception e) {throw new SFDCAccessControlException();}
	}

	/* Add order to SF with the help of RestOrderProcessController Class */
	public PageReference getAuthenticated(){
		PageReference page;
		String loginURL = '/test/VFFrictionlessLogin?oid='+offerId;
		page = Site.login(userName, password, loginURL);
		System.debug('Login Data: '+page );

		if(page == null) {
			page = new PageReference('/test/VFFrictionlessError');
		}
		return page;
	}


	public static String processOrder(String offerId, String ip){
		String orderId;
		Account acc;

		/* Get Person Account Detail for order processing */
		String userName =  Userinfo.getUserEmail();
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Account',
				'VFFrictionlessController.cls [processOrder]',
				new List<Schema.DescribeFieldResult> {
					Account.Brand_Assortment__c.getDescribe(), Account.PersonEmail.getDescribe()
				}
			);
			if (Test.isRunningTest()) {
				acc = [SELECT Id, Brand_Assortment__c From Account LIMIT 1];
			} else {
				acc = [SELECT Id, Brand_Assortment__c From Account WHERE PersonEmail = :userName];
			}
			SFDCAccessController.AccessibleWithoutSharing (
				'Order_Transaction__c',
				'VFFrictionlessController.cls [processOrder]',
				new List<Schema.DescribeFieldResult> {
					Order_Transaction__c.Payment_Profile__c.getDescribe(), Order_Transaction__c.Type__c.getDescribe()
				}
			);
			SFDCAccessController.AccessibleWithoutSharing (
				'Order__c',
				'VFFrictionlessController.cls [processOrder]',
				new List<Schema.DescribeFieldResult> {
					Order__c.Account__c.getDescribe(), Order__c.Billing_Email__c.getDescribe(),
					Order__c.Billing_First_Name__c.getDescribe(), Order__c.Billing_Last_Name__c.getDescribe(),
					Order__c.Billing_Phone__c.getDescribe(), Order__c.Billing_Address__c.getDescribe(),
					Order__c.Billing_City__c.getDescribe(), Order__c.Billing_State__c.getDescribe(),
					Order__c.Billing_Country__c.getDescribe(), Order__c.Billing_Zip_Postal__c.getDescribe(),
					Order__c.Shipping_Address__c.getDescribe(), Order__c.Shipping_City__c.getDescribe(),
					Order__c.Shipping_State__c.getDescribe(), Order__c.Shipping_Country__c.getDescribe(),
					Order__c.Shipping_Zip_Postal__c.getDescribe(), Order__c.Named_Agent__c.getDescribe()
				}
			);
			/* Get last order where Payment_Profile__c != '' And Type 'Profile' or 'Charge' of current user for frictionless order init. */
			List<Order_Transaction__c> lastOrder = [
				SELECT Id, Order__r.Account__c, Order__r.Billing_Email__c, Order__r.Billing_First_Name__c,
					Order__r.Billing_Last_Name__c, Order__r.Billing_Phone__c,
					Order__r.Billing_Address__c, Order__r.Billing_City__c,
					Order__r.Billing_State__c, Order__r.Billing_Country__c,
					Order__r.Billing_Zip_Postal__c, Order__r.Shipping_Address__c,
					Order__r.Shipping_City__c, Order__r.Shipping_State__c, Order__r.Shipping_Country__c,
					Order__r.Shipping_Zip_Postal__c, Order__r.Named_Agent__c
				FROM Order_Transaction__c
				WHERE Payment_Profile__c != ''
				AND Order__r.Account__c =: acc.Id
				AND (Type__c = 'Profile' OR Type__c = 'Charge')
				ORDER BY Id DESC
				LIMIT 1
			];

			if (lastOrder.size() > 0) {
				OrderForm__c offer;

				SFDCAccessController.AccessibleWithoutSharing (
					'OrderForm__c',
					'VFFrictionlessController.cls [processOrder]',
					new List<Schema.DescribeFieldResult> {
						OrderForm__c.SubscriptionBillingDays__c.getDescribe(), OrderForm__c.Offer_Price__c.getDescribe()
					}
				);
				SFDCAccessController.AccessibleWithoutSharing (
					'Product2',
					'VFFrictionlessController.cls [processOrder]',
					new List<Schema.DescribeFieldResult> {
						Product2.Id.getDescribe()
					}
				);
				/* Get Offer info */
				offer = [SELECT ProductTobeSold__r.Id, Offer_Price__c, SubscriptionBillingDays__c FROM OrderForm__c WHERE Id =:offerId LIMIT 1];

				Decimal offerPrice = offer.Offer_Price__c;
				Map<String, String> subscriptionInfo = getNextDate(Integer.valueOf(offer.SubscriptionBillingDays__c));

				String recurring = subscriptionInfo.get('recurring');
				String frequency = subscriptionInfo.get('frequency');

				Map<String, String> orderFormData = new Map<String, String>();
				orderFormData.put('product_id', offer.ProductTobeSold__r.Id);
				orderFormData.put('product_variant', '');
				orderFormData.put('email', userName);
				orderFormData.put('fname', lastOrder[0].Order__r.Billing_First_Name__c);
				orderFormData.put('lname', lastOrder[0].Order__r.Billing_Last_Name__c);
				orderFormData.put('phone', lastOrder[0].Order__r.Billing_Phone__c);
				String billingAddress = lastOrder[0].Order__r.Billing_Address__c+'~'+lastOrder[0].Order__r.Billing_City__c+'~'+lastOrder[0].Order__r.Billing_State__c+'~'+lastOrder[0].Order__r.Billing_Country__c+'~'+lastOrder[0].Order__r.Billing_Zip_Postal__c;
				orderFormData.put('b_common', billingAddress);
				String shippingAddress = lastOrder[0].Order__r.Shipping_Address__c+'~'+lastOrder[0].Order__r.Shipping_City__c+'~'+lastOrder[0].Order__r.Shipping_State__c+'~'+lastOrder[0].Order__r.Shipping_Country__c+'~'+lastOrder[0].Order__r.Shipping_Zip_Postal__c;
				orderFormData.put('s_common', shippingAddress);
				orderFormData.put('utm_source', 'utm_source');
				orderFormData.put('utm_medium', 'utm_medium');
				orderFormData.put('utm_campaign', 'utm_campaign');
				orderFormData.put('utm_content', 'utm_content');
				orderFormData.put('utm_term', 'utm_term');
				orderFormData.put('sales_funnel_name', 'sales_funnel_name');
				orderFormData.put('landing_page_url', 'landing_page_url');
				orderFormData.put('referral_domain_url', 'referral_domain_url');
				Datetime orderDate = Datetime.now();
				String startDate = orderDate.format('MM/dd/yyyy');
				orderFormData.put('start_date', startDate);

				/* Get Sale Tax Amount */
				Decimal taxAmount = RestSaleTaxController.getSalesTax();
				orderFormData.put('tax', String.valueOf(taxAmount));

				/* Get Shipping Amount */
				Decimal shippingAmount = RestShippingController.getValidate(lastOrder[0].Order__r.Shipping_Country__c);
				orderFormData.put('shipping', String.valueOf(shippingAmount));

				/* Update order's total and order's subtotal */
				orderFormData.put('subtotal', String.valueOf(offerPrice));
				orderFormData.put('total',String.valueOf(offerPrice+taxAmount+shippingAmount));

				orderFormData.put('quantity', '1');
				orderFormData.put('Offerprice', String.valueOf(offerPrice));
				orderFormData.put('gateway', lastOrder[0].Order__r.Named_Agent__c);
				orderFormData.put('brand', acc.Brand_Assortment__c);

				orderId = RestNewOrderProcessController.setOrders(orderFormData);
				orderId = orderId.replace('"', '');

				if( orderId == 'insertFail' || orderId == 'duplicate order' || orderId == 'multiple account founded' || orderId == 'Somthing went wrong.' || orderId == 'fraud' ||
				   orderId == 'no order allowed' || orderId == 'NO CC'){

					/* Un able to initialize the chargent order */
					orderId = 'fail';
				}else{

					   orderId = '{"orderId":"'+orderId+'","recurring":"'+recurring+'","frequency":"'+frequency+'","startDate":"'+startDate+'"}';
				}
			} else {
				orderId = 'invalidorder';
			}
			return orderId;
		}
		catch (Exception e) {
			throw new SFDCAccessControlException(e.getMessage());
			return e.getMessage();
		}
	}

	/* Process the order payment with AJAX
	* Parm: @frequency - String type parm
	* Parm: @recurring - String recurring type like daily ,  Weekly etc
	* Parm: @startDate - String order Date
	* Parm: @orderId - String will hold order Id
	* Return type String
	*/
	public static String processPayment(String OrdFrequency, String OrdRecurring, String OrdStartDate, String OrdOrderId, Map<String, Object> creditCard){
		Datetime todayDate = Datetime.now();
		String currentDay = todayDate.format('dd');
		/*return frequency+' = '+recurring+' = '+startDate+' = '+currentDay+' = '+orderId;*/
		String paymentStatus = RestPaymentProcessController.processPayment( OrdFrequency,  OrdRecurring,  OrdStartDate,  currentDay,  OrdOrderId, creditCard);
		System.debug('paymentStatus: '+paymentStatus);
		return paymentStatus;
	}


	/* Get validate tracking URL's data
	* @Parm value: Any String
	* @Return Type String
	*/
	public String getValidate( String value){
		if (value != null) {
			return String.escapeSingleQuotes(value);
		} else {
			return value;
		}
	}

	/**
	* @ Get Calculate next billing date
	* @ Args days
	* @ return voide
	*/
	public Static Map<String, String> getNextDate(Integer days){
		Map<String, String> subscriptionInfo = new Map<String, String>();

		String recurring = 'Recurring';
		String frequency = 'Once';
		if(days == 0){
			recurring = '';
			frequency = 'Once';
		}else if( days == 1){
			frequency = 'Daily';
		}else if(days == 7){
			frequency = 'Weekly';
		}else if(days == 14){
			frequency = 'Biweekly';
		}else if(days == 30){
			frequency = 'Monthly';
		}else if(days == 60){
			frequency = 'Bimonthly';
		}else if(days == 90){
			frequency = 'Quarterly';
		}else if(days == 180){
			frequency = 'Semiannual';
		}else if(days == 365){
			frequency = 'Annual';
		}else if(days == 730){
			frequency = 'Biennial';
		}

		subscriptionInfo.put('recurring', recurring);
		subscriptionInfo.put('frequency', frequency);
		return subscriptionInfo;
	}

	/* Set error message to thanyou page */
	public void setErrorMessage(){
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Sorry! User name or password is wrong. Please try again.' ));
	}

}