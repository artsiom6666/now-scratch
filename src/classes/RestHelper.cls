public with sharing class RestHelper {

	public class RestCallsWrapper {
		public String method { get; set; }
		public Map<String, String> generalData { get; set; }
		public Map<String, String> creditCard { get; set; }
		public DataForOrderItems dataForOrderItems { get; set; }

	}

	public class DataForOrderItems {
		public List<ProductsInformationWrapper> products { get; set; }
		public List<ProductsInformationWrapperBumpOffer> bumpOffers { get; set; }
		public List<ProductsInformationWrapperUpsells> upsells { get; set; }
		public List<ProductsInformationWrapperCoupon> coupons { get; set; }
		public List<ProductsInformationWrapperVariant> variants { get; set; }
	}

	public class ProductsInformationWrapper {
		public String productId { get; set; }
		public String count { get; set; }
	}

	public class ProductsInformationWrapperBumpOffer {
		public String orderFormId { get; set; }
		public String count { get; set; }
	}

	public class ProductsInformationWrapperUpsells {
		public String orderFormId { get; set; }
		public String count { get; set; }
	}

	public class ProductsInformationWrapperVariant {
		public String variantId { get; set; }
		public String count { get; set; }
	}

	public class ProductsInformationWrapperCoupon{
		public String productId { get; set; }
		public String productVariantId { get; set; }
		public String count { get; set; }
		public String price { get; set; }
		public String couponId { get; set; }
	}

	public class AddressproInfo {
		@AuraEnabled
		public String Suburb { get; set; }	//SYDENHAM
		@AuraEnabled
		public String NumberFirst { get; set; }	//1
		@AuraEnabled
		public String State { get; set; }	//NSW
		@AuraEnabled
		public String Street { get; set; }	//GEORGE
		@AuraEnabled
		public String StreetLine { get; set; }	//1 GEORGE ST
		@AuraEnabled
		public String StreetType { get; set; }	//ST
		@AuraEnabled
		public String StreetTypeFull { get; set; }	//STREET
		@AuraEnabled
		public String Postcode { get; set; }	//2044
		@AuraEnabled
		public Double Longitude { get; set; }	//151.17056839
		@AuraEnabled
		public Double Latitude { get; set; }	//-33.91759949
		@AuraEnabled
		public String Meshblock { get; set; }	//10516310000
		@AuraEnabled
		public String Gnaf_ID { get; set; }	//GANSW706417964
		@AuraEnabled
		public Boolean Valid { get; set; }
		@AuraEnabled
		public Boolean Delivery { get; set; }
		@AuraEnabled
		public Boolean nonService { get; set; }
	
	}


	private static Integer MINUTES_FOR_ADDING_UPSELLS = 14;

	public static String createOrder(Map<String, String> orderFormData, RestHelper.DataForOrderItems dataForOrderItems) {
		try{
			Id ownerId = orderFormData.containsKey('ownerId') ? Id.valueOf(orderFormData.get('ownerId')) : null;
			Id accountId = orderFormData.containsKey('accountId') ? Id.valueOf(orderFormData.get('accountId')) : null;
			if (accountId == null) { return '{"error":"Account Id was not found","message":"error"}'; }

			String email = orderFormData.containsKey('email') ? orderFormData.get('email') : null;
			String fname = orderFormData.containsKey('fname') ? orderFormData.get('fname') : null;
			String lname = orderFormData.containsKey('lname') ? orderFormData.get('lname') : null;
			String phone = orderFormData.containsKey('phone') ? orderFormData.get('phone') : null;

			String billingStreet = orderFormData.containsKey('billingStreet') ? orderFormData.get('billingStreet') : null;
			String billingCity = orderFormData.containsKey('billingCity') ? orderFormData.get('billingCity') : null;
			String billingPostalCode = orderFormData.containsKey('billingPostalCode') ? orderFormData.get('billingPostalCode') : null;
			String billingState = orderFormData.containsKey('billingState') ? orderFormData.get('billingState') : null;
			String billingStateCode = orderFormData.containsKey('billingStateCode') ? orderFormData.get('billingStateCode') : null;
			String billingCountry = orderFormData.containsKey('billingCountry') ? orderFormData.get('billingCountry') : null;
			String billingCountryCode = orderFormData.containsKey('billingCountryCode') ? orderFormData.get('billingCountryCode') : null;

			String shippingStreet = orderFormData.containsKey('shippingStreet') ? orderFormData.get('shippingStreet') : null;
			String shippingCity = orderFormData.containsKey('shippingCity') ? orderFormData.get('shippingCity') : null;
			String shippingPostalCode = orderFormData.containsKey('shippingPostalCode') ? orderFormData.get('shippingPostalCode') : null;
			String shippingState = orderFormData.containsKey('shippingState') ? orderFormData.get('shippingState') : null;
			String shippingStateCode = orderFormData.containsKey('shippingStateCode') ? orderFormData.get('shippingStateCode') : null;
			String shippingCountry = orderFormData.containsKey('shippingCountry') ? orderFormData.get('shippingCountry') : null;
			String shippingCountryCode = orderFormData.containsKey('shippingCountryCode') ? orderFormData.get('shippingCountryCode') : null;

			String brand = orderFormData.containsKey('brand') ? orderFormData.get('brand') : 'Winter';

			//Order__c has field Geolocation
			String strLongitude = orderFormData.containsKey('longitude') && orderFormData.get('longitude') != 'null' ? orderFormData.get('longitude') : null;
			String strLatitude = orderFormData.containsKey('latitude') && orderFormData.get('latitude') != 'null' ? orderFormData.get('latitude') : null;

			Decimal longitude = String.isNotBlank(strLongitude) ? Decimal.valueOf(strLongitude) : null;
			Decimal latitude = String.isNotBlank(strLatitude) ? Decimal.valueOf(strLatitude) : null;

			Decimal total = orderFormData.containsKey('total') ? Decimal.valueOf(orderFormData.get('total')) : 0;
			Decimal orderTotal = orderFormData.containsKey('orderTotal') ? Decimal.valueOf(orderFormData.get('orderTotal')) : 0;

			String orderType = orderFormData.containsKey('orderType') ? orderFormData.get('orderType') : 'standard';
			String parrentUpsellOrderId = orderFormData.containsKey('parrentUpsellOrderId') ? orderFormData.get('parrentUpsellOrderId') : null;

			// Multi Currency
			String currency_code = orderFormData.containsKey('currency_code') ? orderFormData.get('currency_code') : null;
			currency_code = TouchCRHelper.validateAndFixCurrencyIsoCode(currency_code);

			String utmCampaign = orderFormData.containsKey('utmCampaign') ? orderFormData.get('utmCampaign') : null;
			String utmContent = orderFormData.containsKey('utmContent') ? orderFormData.get('utmContent') : null;
			String utmMedium = orderFormData.containsKey('utmMedium') ? orderFormData.get('utmMedium') : null;
			String utmSource = orderFormData.containsKey('utmSource') ? orderFormData.get('utmSource') : null;
			String utmTerm = orderFormData.containsKey('utmTerm') ? orderFormData.get('utmTerm') : null;

			String affiliateId = orderFormData.containsKey('affiliateId') ? orderFormData.get('affiliateId') : null;
			String subId1 = orderFormData.containsKey('subId1') ? orderFormData.get('subId1') : null;
			String subId2 = orderFormData.containsKey('subId2') ? orderFormData.get('subId2') : null;
			String subId3 = orderFormData.containsKey('subId3') ? orderFormData.get('subId3') : null;
			String subId4 = orderFormData.containsKey('subId4') ? orderFormData.get('subId4') : null;
			String subId5 = orderFormData.containsKey('subId5') ? orderFormData.get('subId5') : null;

			String paymentMethod = orderFormData.containsKey('paymentMethod') ? orderFormData.get('paymentMethod') : null;
			String orderSource = orderFormData.containsKey('orderSource') ? orderFormData.get('orderSource') : null;

			Decimal couponDiscount = orderFormData.containsKey('couponDiscount') ? Decimal.valueOf(orderFormData.get('couponDiscount')) : 0;
			String customerIp = orderFormData.containsKey('customerIp') ? orderFormData.get('customerIp') : null;

			List<RestHelper.ProductsInformationWrapper> productsList = dataForOrderItems.products;
			List<RestHelper.ProductsInformationWrapperBumpOffer> bumpOffersList = dataForOrderItems.bumpOffers;
			List<RestHelper.ProductsInformationWrapperUpsells> upsellsList = dataForOrderItems.upsells;
			List<RestHelper.ProductsInformationWrapperCoupon> couponsList = dataForOrderItems.coupons;
			List<RestHelper.ProductsInformationWrapperVariant> variantsList = dataForOrderItems.variants;

			Decimal subtotal = 0;
			List<Id> couponsIds = new List<Id>();
			List<OrderItem__c> orderItemsToCreate = new List<OrderItem__c>();
			Subscription__c subscriptionToCreate = new Subscription__c();

			//for check duplicate
			List<Id> orderProductIds = new List<Id>();
			List<Decimal> orderProductQuantities = new List<Decimal>();
			List<Decimal> orderProductOfferprices = new List<Decimal>();


			//Add Products to OrderItems
			if (productsList != null) {
				Set<Id> priceBookProductIds = new Set<Id>();
				for (RestHelper.ProductsInformationWrapper product : productsList) {
					priceBookProductIds.add(Id.valueOf(product.productId));
				}

				String priceBookName = 'Standard Price Book';			
				//Getting information for Product from PricebookEntry
				List<PricebookEntry> priceEntry = [
					SELECT Id, Product2Id, UnitPrice
					FROM PricebookEntry
					WHERE Product2Id =: priceBookProductIds
					AND Pricebook2.Name =: priceBookName
				];

				Map<Id, String> productIdToPrice = new Map<Id, String>();
				//Getting Price from PricebookEntry
				for (PricebookEntry pb : priceEntry) {
					productIdToPrice.put(pb.Product2Id, String.valueOf(pb.UnitPrice));
				}

				for (RestHelper.ProductsInformationWrapper product : productsList) {
					OrderItem__c item = new OrderItem__c();
					item.Product__c = Id.valueOf(product.productId);
					item.Quantity__c = Decimal.valueOf(product.count);
					item.Product_Price__c = Decimal.valueOf(productIdToPrice.get(Id.valueOf(product.productId)));
					orderItemsToCreate.add(item);
					subtotal = subtotal + item.Product_Price__c * item.Quantity__c;

					//add for check duplicate
					orderProductIds.add(item.Product__c);
					orderProductQuantities.add(item.Quantity__c);
					orderProductOfferprices.add(item.Product_Price__c);
				}
			}


			//Add Bump Offers to OrderItems
			if (bumpOffersList != null) {
				Set<Id> bumpOfferOrderFormsIds = new Set<Id>();
				for (RestHelper.ProductsInformationWrapperBumpOffer bumpOffer : bumpOffersList) {
					bumpOfferOrderFormsIds.add(Id.valueOf(bumpOffer.orderFormId));
				}

				List<OrderForm__c> orderForms = [
					SELECT Id, Offer_Price__c, ProductTobeSold__c,
						   Forced_Subscripiton__c, Subscription_Available__c, SubscriptionBillingDays__c, 
						   Subscription_Count__c, Subscription_Days_Postpone__c, Subscription_Frequency__c, 
						   Subscription_Order_Repeat__c, Subscription_Price__c, Subscription_Stop_On__c,
						   Subscription_Stop_Date__c
					FROM OrderForm__c 
					WHERE Id IN: bumpOfferOrderFormsIds
				];
				Map<Id, Decimal> orderFormIdToPrice = new Map<Id, Decimal>();
				Map<Id, Id> orderFormIdToProductId = new Map<Id, Id>();
				for (OrderForm__c orF : orderForms) {
					orderFormIdToPrice.put(orF.Id, orF.Offer_Price__c);
					orderFormIdToProductId.put(orF.Id, orF.ProductTobeSold__c);

					//Subscription
					if (orF.Subscription_Available__c == 'True' || orF.Forced_Subscripiton__c == 'True') {
						subscriptionToCreate.Account__c = accountId;
						subscriptionToCreate.Active__c = true;
						subscriptionToCreate.Charge_Amount__c = orF.Subscription_Price__c;
						subscriptionToCreate.Stop_On__c = orF.Subscription_Stop_On__c;
						subscriptionToCreate.Stop_Count__c = orF.Subscription_Count__c;
						subscriptionToCreate.Stop_Date__c = orF.Subscription_Stop_Date__c;
						subscriptionToCreate.Frequency__c = orF.Subscription_Frequency__c;
						subscriptionToCreate.Order_Repeat__c = orF.Subscription_Order_Repeat__c;
						if (orF.Subscription_Days_Postpone__c != null) {
							subscriptionToCreate.Start_Date__c = Date.today().addDays(Integer.valueOf(orF.Subscription_Days_Postpone__c));
						} else {
							subscriptionToCreate.Start_Date__c = Date.today().addDays(1);
						}
					}
				}

				for (RestHelper.ProductsInformationWrapperBumpOffer bumpOffer : bumpOffersList) {
					OrderItem__c item = new OrderItem__c();
					item.Product__c = orderFormIdToProductId.get(Id.valueOf(bumpOffer.orderFormId));
					item.Quantity__c = Decimal.valueOf(bumpOffer.count);
					item.Product_Price__c = orderFormIdToPrice.get(Id.valueOf(bumpOffer.orderFormId));
					item.Is_Bump_Offer__c = true;
					item.Not_Active_Product__c = true;
					orderItemsToCreate.add(item);
					subtotal = subtotal + item.Product_Price__c * item.Quantity__c;

					//add for check duplicate
					orderProductIds.add(item.Product__c);
					orderProductQuantities.add(item.Quantity__c);
					orderProductOfferprices.add(item.Product_Price__c);
				}
			}


			//Add Coupons to OrderItems
			if (couponsList != null) {
				for (RestHelper.ProductsInformationWrapperCoupon coupon : couponsList) {
					OrderItem__c item = new OrderItem__c();
					item.Product__c = coupon.productId;
					item.Quantity__c = Decimal.valueOf(coupon.count);
					item.Product_Price__c = Decimal.valueOf(coupon.price);
					item.Product_Variant__c = coupon.productVariantId;
					item.Not_Active_Product__c = true;
					orderItemsToCreate.add(item);
					couponsIds.add(Id.valueOf(coupon.couponId));

					//add for check duplicate
					orderProductIds.add(item.Product__c);
					orderProductQuantities.add(item.Quantity__c);
					orderProductOfferprices.add(item.Product_Price__c);
				}
			}


			//Add Upsells to OrderItems
			if (upsellsList != null && (orderType == 'upsell' || orderType == 'downsell')) {
				DateTime earlier = Datetime.now().addMinutes(-MINUTES_FOR_ADDING_UPSELLS);
				if (parrentUpsellOrderId != null) {
					List<Order__c> parrentUpsellOrders = [SELECT Id FROM Order__c WHERE Id =:parrentUpsellOrderId AND Date__c >=: earlier];
					if (parrentUpsellOrders.isEmpty()) { return '{"error": "Special Offer time have Expaired","message":"error"}'; }
				} else { return '{"error": "Parrent Upsell OrderId was not found","message":"error"}'; }

				Set<Id> upsellOrderFormsIds = new Set<Id>();
				for (RestHelper.ProductsInformationWrapperUpsells upsell : upsellsList) {
					upsellOrderFormsIds.add(Id.valueOf(upsell.orderFormId));
				}

				List<OrderForm__c> orderForms = [SELECT Id, Offer_Price__c, ProductTobeSold__c FROM OrderForm__c WHERE Id IN: upsellOrderFormsIds];

				Map<Id, Decimal> orderFormIdToPrice = new Map<Id, Decimal>();
				Map<Id, Id> orderFormIdToProductId = new Map<Id, Id>();
				for (OrderForm__c orF : orderForms) {
					orderFormIdToPrice.put(orF.Id, orF.Offer_Price__c);
					orderFormIdToProductId.put(orF.Id, orF.ProductTobeSold__c);
				}

				for (RestHelper.ProductsInformationWrapperUpsells upsell : upsellsList) {
					OrderItem__c item = new OrderItem__c();
					item.Product__c = orderFormIdToProductId.get(Id.valueOf(upsell.orderFormId));
					item.Quantity__c = Decimal.valueOf(upsell.count);
					item.Product_Price__c = orderFormIdToPrice.get(Id.valueOf(upsell.orderFormId));
					item.Not_Active_Product__c = true;
					orderItemsToCreate.add(item);
					subtotal = subtotal + item.Product_Price__c * item.Quantity__c;

					//add for check duplicate
					orderProductIds.add(item.Product__c);
					orderProductQuantities.add(item.Quantity__c);
					orderProductOfferprices.add(item.Product_Price__c);
				}
			}


			//Add Product Variants to OrderItems
			if (variantsList != null) {
				Set<Id> variantsIds = new Set<Id>();
				for (RestHelper.ProductsInformationWrapperVariant variant : variantsList) {
					variantsIds.add(Id.valueOf(variant.variantId));
				}
				List<Product_Variant__c> variantsBase = [SELECT Id, Price__c, Product__c FROM Product_Variant__c WHERE Id IN: variantsIds];

				//Prepare information of standart prices for Product from PricebookEntry
				Set<Id> priceBookProductIds = new Set<Id>();
				for (Product_Variant__c product : variantsBase) {
					priceBookProductIds.add(product.Product__c);
				}
				String priceBookName = 'Standard Price Book';
				List<PricebookEntry> priceEntry = [
					SELECT Id, Product2Id, UnitPrice
					FROM PricebookEntry
					WHERE Product2Id =: priceBookProductIds
					AND Pricebook2.Name =: priceBookName
				];
				Map<Id, Decimal> productIdToPrice = new Map<Id, Decimal>();
				for (PricebookEntry pb : priceEntry) {
					productIdToPrice.put(pb.Product2Id, pb.UnitPrice);
				}

				Map<Id, Id> variantIdToProductId = new Map<Id, Id>();
				Map<Id, Decimal> variantIdToPrice = new Map<Id, Decimal>();
				for (Product_Variant__c item : variantsBase) {
					variantIdToProductId.put(item.Id, item.Product__c);
					//Check: If ProductVariant Price is not defined (is null) we use standart Price for Product
					if (item.Price__c != null) {
						variantIdToPrice.put(item.Id, item.Price__c);
					} else {
						variantIdToPrice.put(item.Id, productIdToPrice.get(item.Product__c));
					}
				}

				for (RestHelper.ProductsInformationWrapperVariant variant : variantsList) {
					OrderItem__c item = new OrderItem__c();
					item.Product__c = variantIdToProductId.get(Id.valueOf(variant.variantId));
					item.Quantity__c = Decimal.valueOf(variant.count);
					item.Product_Price__c = variantIdToPrice.get(Id.valueOf(variant.variantId));
					item.Product_Variant__c = Id.valueOf(variant.variantId);
					orderItemsToCreate.add(item);
					subtotal = subtotal + item.Product_Price__c * item.Quantity__c;

					//add for check duplicate
					orderProductIds.add(item.Product__c);
					orderProductQuantities.add(item.Quantity__c);
					orderProductOfferprices.add(item.Product_Price__c);
				}
			}

			//Check Prices from SF and from GeneralData
			if (orderTotal != 0 && orderTotal != subtotal) {
				return '{"error":"Price mismatch","message":"error"}';
			}

			if (orderItemsToCreate.size() == 0) { return '{"error":"Products information not found","message":"error"}'; }

			/* -------- Check duplicate order -------- */
			DateTime earlier = Datetime.now().addMinutes(-3);

			List<Order__c> orders = [
				SELECT Id, Subscription_Remains_Amount__c,
					(
						SELECT Order__c
						FROM Order_Items__r
					),
					(
						SELECT Id, Amount__c
						FROM Transactions__r
						WHERE Response_Status__c =: 'Approved'
						ORDER BY CreatedDate DESC
					)
				FROM Order__c
				WHERE Date__c >=: earlier
				AND Account__c  =: accountId
				AND Id IN
					(
						SELECT Order__c
						FROM OrderItem__c
						WHERE Product__c IN: orderProductIds
						AND Quantity__c IN: orderProductQuantities
						AND Product_Price__c IN: orderProductOfferprices
					)
			];

			if (orderType != 'upsell' && orderType != 'downsell') {      //if in second order we have the SAME Upsell/Downsell Products like in first order
				for (Order__c existingOrder : orders) {
					if (existingOrder.Order_Items__r.size() == orderProductIds.size()) {
						//if unpaid order is found then return Id
						if (existingOrder.Transactions__r.isEmpty()) {
							return existingOrder.Id;
						} else {
							List<Order_Transaction__c> approvedTransactions = existingOrder.Transactions__r;
							//if order was paid then return "duplicate order"
							if (existingOrder.Subscription_Remains_Amount__c == approvedTransactions[0].Amount__c) {
								return existingOrder.Id;
							} else {
								return '{"error":"duplicate order","message":"error"}';
							}
						}
					}
				}
			}

			/* -------- Save new Order -------- */
			Order__c cOrder = new Order__c();
			if (ownerId != null){
				cOrder.OwnerId = ownerId;
			}
			cOrder.Account__c = accountId;
			cOrder.Brand__c = brand;
			cOrder.Order_Type__c = orderType;
			cOrder.Parrent_Upsell_Order__c = parrentUpsellOrderId;
			cOrder.Customer_IP__c = customerIp;

			/* -------- Billing Info -------- */
			cOrder.Billing_Last_Name__c = lname;
			cOrder.Date__c = System.now();

			cOrder.Billing_Address__c = billingStreet;
			cOrder.Billing_City__c = billingCity;
			cOrder.Billing_State__c = String.isNotBlank(billingState) ? billingState : billingStateCode;
			cOrder.Billing_Zip_Postal__c = billingPostalCode;

			cOrder.Geolocation__Longitude__s = longitude;
			cOrder.Geolocation__Latitude__s = latitude;

			/* -------- CC information -------- */
			cOrder.Payment_Method__c = String.isNotBlank(paymentMethod) ? paymentMethod : 'Credit Card';

			cOrder.Charge_Amount__c = total;

			/* -------- Order Amount Infromation -------- */
			cOrder.Subtotal__c = subtotal;

			cOrder.Currency__c = currency_code;
			cOrder = (Order__c) TouchCRHelper.setCurrencyIsoCode(cOrder, currency_code);

			/* -------- Shipping Info -------- */
			cOrder.Shipping_First_Name__c = fname;
			cOrder.Shipping_Name__c = lname;
			cOrder.Shipping_Phone__c = phone;

			//TODO
			cOrder.Shipping__c = 0;

			cOrder.Shipping_City__c = shippingCity;
			cOrder.Shipping_State__c = String.isNotBlank(shippingState) ? shippingState : shippingStateCode;
			cOrder.Shipping_Zip_Postal__c = shippingPostalCode;

			/* -------- Payment Gateway Info -------- */
			cOrder.Named_Agent__c = getNamePaymentAgent(brand);

			/* -------- Required fields for MinFraud -------- */
			cOrder.Billing_Email__c = String.isNotEmpty(email) ? email : 'Billing_Email_MinFraud@gmail.com';
			cOrder.Billing_First_Name__c = String.isNotEmpty(fname) ? fname : 'MinFraudFirstName';
			cOrder.Billing_Phone__c = String.isNotEmpty(phone) ? phone : '0000000000';
			cOrder.Billing_Country__c = String.isNotEmpty(billingCountry) ? billingCountry : (String.isNotEmpty(billingCountryCode) ? billingCountryCode : 'US');

			cOrder.Shipping_Address__c = String.isNotEmpty(shippingStreet) ? shippingStreet : 'Shipping Street';
			cOrder.Shipping_Country__c = String.isNotEmpty(shippingCountry) ? shippingCountry : (String.isNotEmpty(shippingCountryCode) ? shippingCountryCode : 'US');

			/* -------- UTM Info -------- */
			cOrder.Utm_Campaign__c = utmCampaign;
			cOrder.Utm_Content__c = utmContent;
			cOrder.Utm_Medium__c = utmMedium;
			cOrder.Utm_Source__c = utmSource;
			cOrder.Utm_Term__c = utmTerm;

			/* ----- For Affiliate ------ */
			if (TouchCRHelper.isAffiliateEnabled()) {
				cOrder.put('Affiliate_Id__c', affiliateId);
			}
			cOrder.Sub_Id1__c = subId1;
			cOrder.Sub_Id2__c = subId2;
			cOrder.Sub_Id3__c = subId3;
			cOrder.Sub_Id4__c = subId4;
			cOrder.Sub_Id5__c = subId5;

			cOrder.Order_Source__c = orderSource;

			cOrder.Coupon_Discount__c = couponDiscount;

			//Subscription
			if (subscriptionToCreate.Account__c != null) {
				try {
					SFDCAccessController.InsertWithoutSharing (
						subscriptionToCreate,
						'RestNewOrderProcessControllerTouchCR.cls [setOrders]',
						new List<Schema.DescribeFieldResult> {
							Subscription__c.Account__c.getDescribe(), Subscription__c.Active__c.getDescribe(),
							Subscription__c.Charge_Amount__c.getDescribe(), Subscription__c.Stop_On__c.getDescribe(),
							Subscription__c.Stop_Count__c.getDescribe(), Subscription__c.Stop_Date__c.getDescribe(),
							Subscription__c.Frequency__c.getDescribe(), Subscription__c.Order_Repeat__c.getDescribe(),
							Subscription__c.Start_Date__c.getDescribe()
						}
					);
				} catch (SFDCAccessControlException e) { return  '{"error":"' + e.ExceptionMessage + '","message":"error"}'; }

				cOrder.Subscription_To__c = subscriptionToCreate.Id;
			}

			try {
				SFDCAccessController.InsertWithoutSharing (
					cOrder,
					'RestNewOrderProcessControllerTouchCR.cls [setOrders]',
					new List<Schema.DescribeFieldResult> {
						Order__c.OwnerId.getDescribe(), Order__c.Account__c.getDescribe(), Order__c.Brand__c.getDescribe(),
						Order__c.Order_Type__c.getDescribe(), Order__c.Parrent_Upsell_Order__c.getDescribe(), Order__c.Billing_Last_Name__c.getDescribe(),
						Order__c.Date__c.getDescribe(), Order__c.Billing_Address__c.getDescribe(), Order__c.Billing_City__c.getDescribe(),
						Order__c.Billing_State__c.getDescribe(), Order__c.Billing_Zip_Postal__c.getDescribe(), Order__c.Geolocation__Longitude__s.getDescribe(),
						Order__c.Geolocation__Latitude__s.getDescribe(), Order__c.Payment_Method__c.getDescribe(), Order__c.Charge_Amount__c.getDescribe(),
						Order__c.Subtotal__c.getDescribe(), Order__c.Currency__c.getDescribe(), Order__c.Shipping_First_Name__c.getDescribe(),
						Order__c.Shipping_Name__c.getDescribe(), Order__c.Shipping_Phone__c.getDescribe(), Order__c.Shipping__c.getDescribe(),
						Order__c.Shipping_City__c.getDescribe(), Order__c.Shipping_State__c.getDescribe(), Order__c.Shipping_Zip_Postal__c.getDescribe(),
						Order__c.Named_Agent__c.getDescribe(), Order__c.Billing_Email__c.getDescribe(), Order__c.Billing_First_Name__c.getDescribe(),
						Order__c.Billing_Phone__c.getDescribe(), Order__c.Billing_Country__c.getDescribe(), Order__c.Shipping_Address__c.getDescribe(),
						Order__c.Shipping_Country__c.getDescribe(), Order__c.Utm_Campaign__c.getDescribe(), Order__c.Utm_Content__c.getDescribe(),
						Order__c.Utm_Medium__c.getDescribe(), Order__c.Utm_Source__c.getDescribe(), Order__c.Utm_Term__c.getDescribe(),
						Order__c.Sub_Id1__c.getDescribe(), Order__c.Sub_Id2__c.getDescribe(),
						Order__c.Sub_Id3__c.getDescribe(), Order__c.Sub_Id4__c.getDescribe(), Order__c.Sub_Id5__c.getDescribe(),
						Order__c.Order_Source__c.getDescribe(), Order__c.Coupon_Discount__c.getDescribe(), Order__c.Subscription_To__c.getDescribe()
					}
				);
			} catch (SFDCAccessControlException e) { return  '{"error":"' + e.ExceptionMessage + '","message":"error"}'; }

			for (OrderItem__c item : orderItemsToCreate) {
				item.Order__c = cOrder.Id;
			}

			try {
				SFDCAccessController.InsertWithoutSharing (
					orderItemsToCreate,
					'RestNewOrderProcessControllerTouchCR.cls [setOrders]',
					new List<Schema.DescribeFieldResult> {
						OrderItem__c.Order__c.getDescribe(), OrderItem__c.Product__c.getDescribe(),
						OrderItem__c.Quantity__c.getDescribe(), OrderItem__c.Product_Price__c.getDescribe(),
						OrderItem__c.Is_Bump_Offer__c.getDescribe(), OrderItem__c.Product_Variant__c.getDescribe()
					}
				);
			} catch (SFDCAccessControlException e) { return  '{"error":"' + e.ExceptionMessage + '","message":"error"}'; }

			if (!couponsIds.isEmpty()) {
				CouponHelper.createCouponOrders(cOrder.Id, couponsIds);
			}

			return cOrder.Id;
		} catch (Exception e) { return '{"error":"' + e.getMessage() + '","message":"error"}'; }
	}

	public static String getNamePaymentAgent(String namebrand) {
		String result = '';
		List<Map<String, String>> allPaymentAgents = TouchCRHelper.getCustomSettings('TouchCRBase__Payment_Agents__c');

		Map<Id, Map<String, String>> idToPaymentAgentName = new Map<Id, Map<String, String>>();
		for (Map<String, String> paymentAgent : allPaymentAgents) {
			idToPaymentAgentName.put(paymentAgent.get('Id'), paymentAgent);
		}

		Map<String, String> brandToIdPaymentAgent = new Map<String, String>();
		Map<String, String> allTouchCRSettingsForPayment = TouchCRHelper.getSettings('D.');
		for (String brandItem : allTouchCRSettingsForPayment.keySet()) {
			brandToIdPaymentAgent.put(brandItem.removeStart('D.'), allTouchCRSettingsForPayment.get(brandItem));
		}

		if (brandToIdPaymentAgent.containsKey(namebrand)) {
			Id paymentAgentId = Id.valueOf(brandToIdPaymentAgent.get(namebrand));
			if (idToPaymentAgentName.containsKey(paymentAgentId)) {
				Map<String, String> paymentAgentData = idToPaymentAgentName.get(paymentAgentId);
				result = paymentAgentData.get('Name');
			}
		}
		return result;
	}

}