public with sharing class RestNewOrderProcessController {

	/**
* setOrders Method to process order multiple / single order
* Method's param Exp:
*    Map<String, String> orderFormData = new Map<String, String>();     // setOrders method's argument
*    orderFormData.put('product_id', proID);                            // This will hold single or multiple product Ids*
*    orderFormData.put('product_variant', variant.Id);                  // This will hold single or multiple variant Ids*
*    orderFormData.put('email', email);                                 // This will hold email Id of the customer
*    orderFormData.put('fname', firstName);                             // This will hold first name of the customer
*    orderFormData.put('lname', lastName);                              // This will hold last name of the customer
*    orderFormData.put('phone', phone);                                 // This will hold phone number of the customer
*    orderFormData.put('b_common', billingAddress);                     // This will hold billing Address of the customer like: address~city~state~country~zip;
*    orderFormData.put('s_common', shippingAddress);                    // This will hold shipping Address of the customer  like: address~city~state~country~zip;
*    orderFormData.put('cc_number', CCNumber);                          // This will hold CC number
*    orderFormData.put('security_code', CCCode);                        // This will hold CC Code
*    orderFormData.put('cc_exp_month', CCMonth);                        // This will hold CC Exp. Month
*    orderFormData.put('cc_exp_year', CCYear);                          // This will hold CC Exp. Year
*    orderFormData.put('cc_type', CCType);                              // This will hold CC Type
*    orderFormData.put('ip', IPAddress);                                // This will hold utm_source
*    orderFormData.put('utm_source', utm_source);                       // This will hold utm_source
*    orderFormData.put('utm_medium', utm_medium);                       // This will hold utm_medium
*    orderFormData.put('utm_campaign', utm_campaign);                   // This will hold utm_campaign
*    orderFormData.put('utm_content', utm_content);                     // This will hold utm_content
*    orderFormData.put('utm_term', utm_term);                           // This will hold utm_term
*    orderFormData.put('sales_funnel_name', sales_funnel_name);         // This will hold sales_funnel_name
*    orderFormData.put('landing_page_url', landing_page_url);           // This will hold landing_page_url
*    orderFormData.put('referral_domain_url', referral_domain_url);     // This will hold referral_domain_url
*    orderFormData.put('start_date', start_date);                       // This will hold start_date of the order
*    orderFormData.put('tax', tax);                                     // This will hold tax amount on the order
*    orderFormData.put('subtotal', subtotal);                           // This will hold subtotal

*	 orderFormData.put('paypal_token', '72D0681527109671C');
*  	 orderFormData.put('paypal_payerid', '3T5GGNEZ8T33S');
*
*    *In case of multiple product Ids then all Ids should like this: a0B55000000Bm69~a0B55000000Bm69~a0B55000000Bm69 (all product id separated with "~"). And also following data in same manner:
*    product_variant:   a0B5500000grm69~a0B55000000sx69~a0B55000000oy69 (In case of in some product don't have any variant then data should like this a0B5500000grm69~''~a0B55000000oy69)
*    quantity:          1~2~3
*    Offerprice:        20.18~58~102
*    Make sure "product_id", "product_variant", "quantity" and "Offerprice" length always should same
* @return response in String
*/

	@AuraEnabled
	public static String setOrders(Map<String, String> orderFormData) {

		String product_id = orderFormData.get('product_id');
		String product_variant = orderFormData.get('product_variant');

		String email = orderFormData.get('email');
		String fname = orderFormData.get('fname');
		String lname = orderFormData.get('lname');
		String phone = orderFormData.get('phone');
		String b_common = orderFormData.get('b_common');
		String s_common = orderFormData.get('s_common');
		String utm_source = orderFormData.get('utm_source');
		String utm_medium = orderFormData.get('utm_medium');
		String utm_campaign = orderFormData.get('utm_campaign');
		String utm_content = orderFormData.get('utm_content');
		String utm_term = orderFormData.get('utm_term');
		String sales_funnel_name = orderFormData.get('sales_funnel_name');
		String landing_page_url = orderFormData.get('landing_page_url');
		String referral_domain_url = orderFormData.get('referral_domain_url');
		String start_date = orderFormData.get('start_date');
		String quantity = orderFormData.get('quantity');
		String offerprice = orderFormData.get('Offerprice');
		Decimal coupon_discount = orderFormData.containsKey('coupon_discount') ? Decimal.valueOf(orderFormData.get('coupon_discount')) : 0;

		String brand = orderFormData.get('brand');

		// Optional
		// Paypal
		String paypal_token = orderFormData.get('paypal_token');
		String paypal_payerid = orderFormData.get('paypal_payerid');
		Boolean isPaypalOrder = (String.isNotBlank(paypal_token));
		// Multi Currency
		String currency_code = TouchCRHelper.validateAndFixCurrencyIsoCode(orderFormData.get('currency_code'));

		Decimal tax, subtotal, total, shipping;
		//Owner for order record
		Id ownerId;

		try {
			tax = Decimal.valueOf(orderFormData.get('tax')) ;
			subtotal = Decimal.valueOf(orderFormData.get('subtotal'));
			total = Decimal.valueOf(orderFormData.get('total'));
			shipping = Decimal.valueOf(orderFormData.get('shipping'));

			//Are these SF Id valid?
			ownerId = orderFormData.containsKey('idOwner') ? Id.valueOf(orderFormData.get('idOwner')) : null;
		}
		catch (Exception e) {
			RestAddressVerificationControllerV2.setLog('Rest Order Decimal Type Cast', 'Error on line # ' + e.getLineNumber() + '. ' + e.getMessage() + '. ' + e.getCause(), null);
			return null;
		}

		String accountId = '';
		List<Account> anct = [SELECT Id from Account WHERE PersonEmail = :email LIMIT 1];

		/*  --------------------- If PersonAccount's record does not exist --------------------- */
		String OldCustomer = '';
		if (anct.size() == 0) {
			OldCustomer = 'No';
			RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
			Account ant = new Account();
			ant.RecordTypeId = customerRecordType.Id;
			ant.FirstName = fname;
			ant.LastName = lname;
			ant.Phone = phone;
			ant.PersonEmail = email;
			ant.Brand_Assortment__c = brand;

			/* --------------------- Billing Info --------------------- */

			String[] bAddress = b_common.split('~');

			ant.BillingStreet = bAddress[0];
			ant.BillingCity = bAddress[1];
			if (TouchCRHelper.isSCPEnabled()) {
				ant.put('BillingStateCode', bAddress[2]);
				ant.put('BillingCountryCode', bAddress[3]);
			}
			else {
				ant.BillingState = bAddress[2];
				ant.BillingCountry = bAddress[3];
			}
			ant.BillingPostalCode = bAddress[4];

			/* --------------------- Shipping Info --------------------- */
			String[] sAddress = s_common.split('~');

			ant.ShippingStreet = sAddress[0];
			ant.ShippingCity = sAddress[1];
			if (TouchCRHelper.isSCPEnabled()) {
				ant.put('ShippingStateCode', sAddress[2]);
				ant.put('ShippingCountryCode', sAddress[3]);
			}
			else {
				ant.ShippingState = sAddress[2];
				ant.ShippingCountry = sAddress[3];
			}
			ant.ShippingPostalCode = sAddress[4];

			/* --------------------- Tracking Information --------------------- */
			ant.utm_source__c = utm_source;
			ant.utm_medium__c = utm_medium;
			ant.utm_campaign__c = utm_campaign;
			ant.utm_content__c = utm_content;
			ant.utm_term__c = utm_term;
			ant.sales_funnel_name__c = sales_funnel_name;
			ant.landing_page_url__c = landing_page_url;
			ant.referral_domain_url__c = referral_domain_url;

			ant = (Account) TouchCRHelper.setCurrencyIsoCode(ant, currency_code);

			try {
				SFDCAccessController.InsertWithoutSharing (
					ant,
					'RestNewOrderProcessController.cls [setOrders]',
					new List<Schema.DescribeFieldResult>{
						Account.FirstName.getDescribe(), Account.LastName.getDescribe(),
						Account.Phone.getDescribe(), Account.PersonEmail.getDescribe(),
						Account.Brand_Assortment__c.getDescribe(),
						Account.BillingStreet.getDescribe(), Account.BillingCity.getDescribe(),
						Account.BillingCountry.getDescribe(), Account.BillingPostalCode.getDescribe(),
						Account.ShippingStreet.getDescribe(), Account.ShippingCity.getDescribe(),
						Account.ShippingCountry.getDescribe(), Account.ShippingPostalCode.getDescribe(),
						Account.utm_source__c.getDescribe(), Account.utm_medium__c.getDescribe(),
						Account.utm_campaign__c.getDescribe(), Account.utm_content__c.getDescribe(),
						Account.utm_term__c.getDescribe(), Account.sales_funnel_name__c.getDescribe(),
						Account.landing_page_url__c.getDescribe(), Account.referral_domain_url__c.getDescribe()
					}
				);
				accountId = ant.id;
			} catch (SFDCAccessControlException e) { return e.ExceptionMessage; }


			List<Lead> lead = [SELECT Id from Lead WHERE Email = :email LIMIT 1];
			if (lead.size() > 0) {
				try {
					Database.LeadConvert lc = new Database.LeadConvert();
					lc.setLeadId(lead[0].Id);
					lc.setAccountId(accountId);
					LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
					lc.setConvertedStatus(convertStatus.MasterLabel);
					lc.setDoNotCreateOpportunity(true);
					Database.LeadConvertResult lcr = Database.convertLead(lc);
					System.assert(lcr.isSuccess());
				}
				catch (Exception e) {
					RestAddressVerificationControllerV2.setLog('Rest Order Lead conversion', 'Error on line # ' + e.getLineNumber() + '. ' + e.getMessage() + '. ' + e.getCause(), accountId);
				}
			}
		}
		else if (anct.size() > 1) {
			return 'multiple account founded';
		}
		else {
			/* --------------------- If PersonAccount's record already exist --------------------- */
			OldCustomer = 'Yes';
			accountId = anct[0].Id;

			/* --------------------- Update Address in Person Account --------------------- */
			Account singleAcc = anct[0];
			String[] bAddress = b_common.split('~');

			singleAcc.BillingStreet = bAddress[0];
			singleAcc.BillingCity = bAddress[1];
			if (TouchCRHelper.isSCPEnabled()) {
				singleAcc.put('BillingStateCode', bAddress[2]);
				singleAcc.put('BillingCountryCode', bAddress[3]);
			}
			else {
				singleAcc.BillingState = bAddress[2];
				singleAcc.BillingCountry = bAddress[3];
			}
			singleAcc.BillingPostalCode = bAddress[4];


			String[] sAddress = s_common.split('~');
			singleAcc.ShippingStreet = sAddress[0];
			singleAcc.ShippingCity = sAddress[1];
			if (TouchCRHelper.isSCPEnabled()) {
				singleAcc.put('ShippingStateCode', sAddress[2]);
				singleAcc.put('ShippingCountryCode', sAddress[3]);
			}
			else {
				singleAcc.ShippingState = sAddress[2];
				singleAcc.ShippingCountry = sAddress[3];
			}
			singleAcc.ShippingPostalCode = sAddress[4];


			try {
				SFDCAccessController.UpsertWithoutSharing (
					singleAcc,
					'RestNewOrderProcessController.cls [setOrders]',
					new List<Schema.DescribeFieldResult>{
						Account.BillingStreet.getDescribe(), Account.BillingCity.getDescribe(),
						Account.BillingPostalCode.getDescribe(), Account.ShippingStreet.getDescribe(),
						Account.ShippingCity.getDescribe(), Account.ShippingPostalCode.getDescribe(),
						Account.Phone.getDescribe()
					}
				);
			} catch (SFDCAccessControlException e) { return e.ExceptionMessage; }

			String response = getCustomerHistory(accountId);

			if (response != 'true') {
				/* --------------------- Black list or froud founded --------------------- */
				return response;
			}
		}

		/* --------------------- Check duplicate order --------------------- */
		date startDate = date.parse(start_date);

		Datetime myDT = Datetime.now();
		DateTime earlier = myDT.addMinutes(-3);
		String[] products = product_id.split('~');
		String[] variant = product_variant.split('~');

		List<Decimal> quantities = new List<Decimal>();
		for (String qua : quantity.split('~')) {
			quantities.add(Decimal.valueOf(qua));
		}

		List<Decimal> offerprices = new List<Decimal>();
		for (String off : offerprice.split('~')) {
			offerprices.add(Decimal.valueOf(off));
		}

		List<OrderItem__c> order = [
			SELECT Id, Order__r.Date__c, Product__c
			FROM OrderItem__c
			WHERE Order__r.Account__c =: accountId
			AND Product__c IN: products
			AND Product_Variant__c IN: variant
			AND Quantity__c IN: quantities
			AND Product_Price__c IN: offerprices
			AND Order__r.Date__c >=: earlier
		];

		if (order.size() != 0) { return 'duplicate order'; }

		/* --------------------- Save new Order --------------------- */
		Order__c cOrder = new Order__c();
		cOrder.Account__c = accountId;

		/* --------------------- Billing Info --------------------- */

		cOrder.Billing_Email__c = email;
		cOrder.Billing_First_Name__c = fname;
		cOrder.Billing_Last_Name__c = lname;
		cOrder.Billing_Phone__c = phone;
		Datetime orderDATE = System.now();
		cOrder.Date__c = orderDATE;

		String[] bAddress = b_common.split('~');
		cOrder.Billing_Address__c = bAddress[0];
		cOrder.Billing_City__c = bAddress[1];
		cOrder.Billing_State__c = bAddress[2];
		cOrder.Billing_Country__c = bAddress[3];
		cOrder.Billing_Zip_Postal__c = bAddress[4];

		/* --------------------- CC information --------------------- */

		cOrder.Payment_Method__c = (isPaypalOrder) ? 'Paypal' : 'Credit Card';

		/* --------------------- Order Amount Infromation --------------------- */
		cOrder.Charge_Amount__c = total;
		cOrder.Tax__c = tax;
		cOrder.Subtotal__c = subtotal;

		cOrder.Currency__c = currency_code;
		cOrder = (Order__c) TouchCRHelper.setCurrencyIsoCode(cOrder, currency_code);

		/* --------------------- Shipping Info --------------------- lname */

		cOrder.Shipping_First_Name__c = fname;
		cOrder.Shipping_Name__c = lname;
		cOrder.Shipping_Phone__c = phone;
		cOrder.Shipping__c = shipping;

		String[] sAddress = s_common.split('~');
		cOrder.Shipping_Address__c = sAddress[0];
		cOrder.Shipping_City__c = sAddress[1];
		cOrder.Shipping_State__c = sAddress[2];
		cOrder.Shipping_Country__c = sAddress[3];
		cOrder.Shipping_Zip_Postal__c = sAddress[4];

		/* --------------------- Payment Gateway Info --------------------- */
		Map<String, String> brandToGateway = TouchCRConfigurationController.collectionBrandToGateway();
		if (isPaypalOrder) {
			cOrder.Named_Agent__c = 'Paypal';
		}
		else if (brandToGateway.containsKey(brand)) {
			cOrder.Named_Agent__c = PaymentAgentController.idToNameParamAgents(brandToGateway.get(brand));
		}

		//If owner has been received, need to use it for the order record.
		if (ownerId != null) {
			cOrder.OwnerId = ownerId;
		}
		
		/* --------------------- Optional Paypal --------------------- */
		corder.Paypal_Token__c = paypal_token;
		corder.Paypal_PayerId__c = paypal_payerid;
		/* --------------------- Tracking Information --------------------- */
		corder.Utm_Source__c = utm_source;
		cOrder.Utm_Medium__c = utm_medium;
		cOrder.Utm_Campaign__c = utm_campaign;
		cOrder.Utm_Content__c = utm_content;
		cOrder.Utm_Term__c = utm_term;
		cOrder.Sales_Funnel_Name__c = sales_funnel_name;
		cOrder.Landing_Page_Url__c = landing_page_url;
		cOrder.Referral_Domain_Url__c = referral_domain_url;

		cOrder.Coupon_Discount__c = coupon_discount;

		try {
			SFDCAccessController.InsertWithoutSharing (
				cOrder,
				'RestNewOrderProcessController.cls [setOrders]',
				new List<Schema.DescribeFieldResult>{
					Order__c.Account__c.getDescribe(), Order__c.Billing_Email__c.getDescribe(),
					Order__c.Billing_First_Name__c.getDescribe(), Order__c.Billing_Last_Name__c.getDescribe(),
					Order__c.Billing_Phone__c.getDescribe(), Order__c.Date__c.getDescribe(),
					Order__c.Billing_Address__c.getDescribe(), Order__c.Billing_City__c.getDescribe(),
					Order__c.Billing_State__c.getDescribe(), Order__c.Billing_State__c.getDescribe(),
					Order__c.Billing_Country__c.getDescribe(), Order__c.Billing_Zip_Postal__c.getDescribe(),
					Order__c.Payment_Method__c.getDescribe(), Order__c.Charge_Amount__c.getDescribe(),
					Order__c.Tax__c.getDescribe(), Order__c.Subtotal__c.getDescribe(),
					Order__c.Currency__c.getDescribe(), Order__c.Shipping_First_Name__c.getDescribe(),
					Order__c.Shipping_Name__c.getDescribe(), Order__c.Shipping_Phone__c.getDescribe(),
					Order__c.Shipping__c.getDescribe(), Order__c.Shipping_Address__c.getDescribe(),
					Order__c.Shipping_City__c.getDescribe(), Order__c.Shipping_State__c.getDescribe(),
					Order__c.Shipping_Country__c.getDescribe(), Order__c.Shipping_Zip_Postal__c.getDescribe(),
					Order__c.Named_Agent__c.getDescribe(), Order__c.Utm_Source__c.getDescribe(),
					Order__c.Utm_Medium__c.getDescribe(), Order__c.Utm_Campaign__c.getDescribe(),
					Order__c.Utm_Content__c.getDescribe(), Order__c.Utm_Term__c.getDescribe(),
					Order__c.Sales_Funnel_Name__c.getDescribe(), Order__c.Landing_Page_Url__c.getDescribe(),
					Order__c.Referral_Domain_Url__c.getDescribe(), Order__c.OwnerId.getDescribe(),
					Order__c.Coupon_Discount__c.getDescribe()
				}
			);
			String orderId = cOrder.Id;

			String resultOfOrderItems = setOrderItem(orderId, product_id, offerprice, quantity, product_variant);
			return resultOfOrderItems != null ? resultOfOrderItems : orderId;
		} catch (SFDCAccessControlException e) { return e.ExceptionMessage; }
	}

	/**
	* Check Custome previous record
	* String accountId - account Id
	*/
	public static String getCustomerHistory(String accountId) {

		/* --------------------- Remove Last 3 character from id --------------------- */
		String aid = accountId.substring(0, 15);

		/* --------------------- Prepare 2 hours before date-time and fetch 2 hours old case related to account id --------------------- */

		Datetime myDT = Datetime.now();
		DateTime earlier = myDT.addMinutes(-120);
		String payment = 'Payment';
		String unpaid = 'Unpaid Order';
		String close = 'Closed';
		List<Case> cs = [SELECT Id, Status from Case WHERE AccountId = :aid AND CreatedDate >= :earlier AND Type = :payment AND Reason = :unpaid AND Status != :close];

		if (cs.size() != 0) {

			/* --------------------- if 2 hours old case founded make it close --------------------- */
			List<Case> caseToUpdate = new List<Case>{
			};
			for (Case c: cs) {
				c.Status = 'Closed';
				caseToUpdate.add(c);
			}

			try {
				SFDCAccessController.UpdateWithoutSharing (
					caseToUpdate,
					'RestNewOrderProcessController.cls [setOrders]',
					new List<Schema.DescribeFieldResult>{
						Case.Status.getDescribe()
					}
				);
			} catch (SFDCAccessControlException e) { return e.ExceptionMessage; }


			/* --------------------- If transection count grater than 4 then return Fraud --------------------- */
			List<Account> fraud = [SELECT Id FROM Account WHERE Id = :aid AND Orders_Failed__c > 4];
			if (fraud.size() != 0) {
				return 'fraud';
			}
		}

		/* --------------------- Check Black list Record --------------------- */
		String blackListCheck = 'true';

		List<Account> acc = [SELECT Id FROM Account WHERE Id = :aid AND Blacklist__c = :blackListCheck];
		if (acc.size() == 0) {
			/* --------------------- no  black list record --------------------- */
			return 'true';
		}
		else {
			/* --------------------- black list founded --------------------- */
			return 'no order allowed';
		}
	}

	/**
	* Update Order Item Object
	* String orderId - Order Id
	* String productId - Product Id
	*/
	public static String setOrderItem(String orderId, String productId, String offerprice, String quantity, String product_variant) {

		String[] products = productId.split('~');
		String[] quantities = quantity.split('~');
		String[] itemsPrice = offerprice.split('~');

		/* Preparing Variant data */
		String[] variant = product_variant.split('~');

		List<Product_Variant__c> results = [SELECT Id, Price__c, Product__c FROM Product_Variant__c WHERE Id IN :variant];

		Map<String, Decimal> variants = new Map<String, Decimal>();
		for (Integer k = 0; k < results.size(); k++) {

			variants.put(results[k].Product__c, results[k].Price__c);
		}

		/* preparing data for order Iten object */
		OrderItem__c[] itemToCreate = new OrderItem__c[]{
		};

		for (Integer x = 0; x < products.size(); x++) {

			Decimal qty = Decimal.valueOf(quantities[x]);
			Decimal itemprice;
			OrderItem__c itmes;

			if (variants.containsKey(products[x])) {

				/* If Product's variant have valid price */
				Decimal temp_variantPrice = variants.get(products[x]);
				itemprice = Decimal.valueOf(itemsPrice[x]);
				itmes = new OrderItem__c(Order__c = orderId, Product__c = products[x], Quantity__c = qty, Product_Price__c = itemprice, Product_Variant__c = variant[x]);
			}
			else {
				itemprice = Decimal.valueOf(itemsPrice[x]);
				itmes = new OrderItem__c(Order__c = orderId, Product__c = products[x], Quantity__c = qty, Product_Price__c = itemprice);
			}

			itemToCreate.add(itmes);
		}

		try {
			SFDCAccessController.InsertWithoutSharing (
				itemToCreate,
				'RestNewOrderProcessController.cls [setOrders]',
				new List<Schema.DescribeFieldResult>{
					OrderItem__c.Order__c.getDescribe(), OrderItem__c.Product__c.getDescribe(),
					OrderItem__c.Quantity__c.getDescribe(), OrderItem__c.Product_Price__c.getDescribe(),
					OrderItem__c.Product_Variant__c.getDescribe()
				}
			);
			return null;
		} catch (SFDCAccessControlException e) { return e.ExceptionMessage; }
	}

}