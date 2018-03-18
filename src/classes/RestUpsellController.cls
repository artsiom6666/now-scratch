public with sharing class RestUpsellController {

	public static String processUpsell(String orderId, Decimal price, Decimal shipping, Decimal tax, String product_id, Decimal quantity) {
		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Order__c',
				'RestUpsellController.cls [processUpsell]',
				new List<Schema.DescribeFieldResult>{
					Order__c.Id.getDescribe(), Order__c.Account__c.getDescribe(),
					Order__c.Date__c.getDescribe(), Order__c.Named_Agent__c.getDescribe(),
					Order__c.Billing_Email__c.getDescribe(), Order__c.Billing_First_Name__c.getDescribe(),
					Order__c.Billing_Last_Name__c.getDescribe(), Order__c.Billing_Phone__c.getDescribe(),
					Order__c.Billing_Address__c.getDescribe(), Order__c.Billing_City__c.getDescribe(),
					Order__c.Billing_State__c.getDescribe(), Order__c.Billing_Country__c.getDescribe(),
					Order__c.Billing_Zip_Postal__c.getDescribe(), Order__c.Shipping_Address__c.getDescribe(),
					Order__c.Shipping_City__c.getDescribe(), Order__c.Shipping_State__c.getDescribe(),
					Order__c.Shipping_Country__c.getDescribe(), Order__c.Shipping_Zip_Postal__c.getDescribe(),
					Order__c.Shipping__c.getDescribe(), Order__c.Tax__c.getDescribe(),
					Order__c.Utm_Source__c.getDescribe(), Order__c.Utm_Medium__c.getDescribe(),
					Order__c.Utm_Campaign__c.getDescribe(), Order__c.Utm_Content__c.getDescribe(),
					Order__c.Utm_Term__c.getDescribe(), Order__c.Sales_Funnel_Name__c.getDescribe(),
					Order__c.Landing_Page_Url__c.getDescribe(), Order__c.Referral_Domain_Url__c.getDescribe(),
					Order__c.Minfraud_Score__c.getDescribe()
				}
			);
			String pastOrderQuery = 'SELECT Id, Account__c, Date__c, Named_Agent__c, Billing_Email__c, Billing_First_Name__c, Billing_Last_Name__c, Billing_Phone__c, ' +
				'Billing_Address__c, Billing_City__c, Billing_State__c, Billing_Country__c, Billing_Zip_Postal__c, Shipping_Address__c, Shipping_City__c, ' +
				'Shipping_State__c, Shipping_Country__c, Shipping_Zip_Postal__c, Shipping__c, Tax__c, Utm_Source__c, Utm_Medium__c, Utm_Campaign__c, ' +
				'Utm_Content__c, Utm_Term__c, Sales_Funnel_Name__c, Landing_Page_Url__c, Referral_Domain_Url__c, Minfraud_Score__c ';

			if (UserInfo.isMultiCurrencyOrganization()) {
				pastOrderQuery += ', CurrencyIsoCode ';
			}
			pastOrderQuery += ' FROM Order__c WHERE Id =: orderId ORDER BY Id DESC LIMIT 1';

			Order__c past = Database.query(pastOrderQuery);

			Order__c order = new Order__c();
			order.Account__c = past.Account__c;
			order.Date__c = past.Date__c;
			order.Minfraud_Score__c = past.Minfraud_Score__c;
			order.Billing_Email__c = past.Billing_Email__c;
			order.Billing_First_Name__c = past.Billing_First_Name__c;
			order.Billing_Last_Name__c = past.Billing_Last_Name__c;
			order.Billing_Phone__c = past.Billing_Phone__c;
			order.Billing_Address__c = past.Billing_Address__c;
			order.Billing_City__c = past.Billing_City__c;
			order.Billing_State__c = past.Billing_State__c;
			order.Billing_Country__c = past.Billing_Country__c;
			order.Billing_Zip_Postal__c = past.Billing_Zip_Postal__c;
			order.Shipping_Address__c = past.Shipping_Address__c;
			order.Shipping_City__c = past.Shipping_City__c;
			order.Shipping_State__c = past.Shipping_State__c;
			order.Shipping_Country__c = past.Shipping_Country__c;
			order.Shipping_Zip_Postal__c = past.Shipping_Zip_Postal__c;
			order.Charge_Amount__c = price + shipping + tax;
			order.Subtotal__c = price;
			order.Shipping__c = shipping;
			order.Tax__c = tax;

			order.Currency__c = TouchCRHelper.getCurrencyLabel(past);

			order.Payment_Method__c = 'Credit Card';
			order.Named_Agent__c = past.Named_Agent__c;

			/* --------------------- Tracking Information --------------------- */
			order.Utm_Source__c = past.Utm_Source__c;
			order.Utm_Medium__c = past.Utm_Medium__c;
			order.Utm_Campaign__c = past.Utm_Campaign__c;
			order.Utm_Content__c = past.Utm_Content__c;
			order.Utm_Term__c = past.Utm_Term__c;
			order.Sales_Funnel_Name__c = past.Sales_Funnel_Name__c;
			order.Landing_Page_Url__c = past.Landing_Page_Url__c;
			order.Referral_Domain_Url__c = past.Referral_Domain_Url__c;

			order = (Order__c) TouchCRHelper.setCurrencyIsoCode(order, TouchCRHelper.getCurrencyIsoCode(past));

			SFDCAccessController.InsertWithoutSharing (
				order,
				'RestUpsellController.cls [processUpsell]',
				new List<Schema.DescribeFieldResult>{
					Order__c.Account__c.getDescribe(), Order__c.Date__c.getDescribe(),
					Order__c.Minfraud_Score__c.getDescribe(), Order__c.Billing_Email__c.getDescribe(),
					Order__c.Billing_First_Name__c.getDescribe(), Order__c.Billing_Last_Name__c.getDescribe(),
					Order__c.Billing_Phone__c.getDescribe(), Order__c.Billing_Address__c.getDescribe(),
					Order__c.Billing_City__c.getDescribe(), Order__c.Billing_State__c.getDescribe(),
					Order__c.Billing_Country__c.getDescribe(), Order__c.Billing_Zip_Postal__c.getDescribe(),
					Order__c.Shipping_Address__c.getDescribe(), Order__c.Shipping_City__c.getDescribe(),
					Order__c.Shipping_State__c.getDescribe(), Order__c.Shipping_Country__c.getDescribe(),
					Order__c.Shipping_Zip_Postal__c.getDescribe(), Order__c.Charge_Amount__c.getDescribe(),
					Order__c.Subtotal__c.getDescribe(), Order__c.Shipping__c.getDescribe(),
					Order__c.Tax__c.getDescribe(), Order__c.Currency__c.getDescribe(),
					Order__c.Payment_Method__c.getDescribe(), Order__c.Named_Agent__c.getDescribe(),
					Order__c.Utm_Source__c.getDescribe(), Order__c.Utm_Medium__c.getDescribe(),
					Order__c.Utm_Campaign__c.getDescribe(), Order__c.Utm_Content__c.getDescribe(),
					Order__c.Utm_Term__c.getDescribe(), Order__c.Sales_Funnel_Name__c.getDescribe(),
					Order__c.Landing_Page_Url__c.getDescribe(), Order__c.Referral_Domain_Url__c.getDescribe()
				}
			);
			String order_Id = order.Id;
			setOrderItem(order_Id, product_id, price, quantity);
			return order_Id.substring(0, 15);
		} catch (SFDCAccessControlException e) { return e.ExceptionMessage; }
	}

	public static void setOrderItem(String orderId, String productId, Decimal price, Decimal quantity) {
		OrderItem__c oi = new OrderItem__c();
		oi.Order__c = orderId;
		oi.Product__c = productId;
		oi.Product_Price__c = price;
		oi.Quantity__c = quantity;

		try {
			SFDCAccessController.InsertWithoutSharing (
				oi,
				'RestUpsellController.cls [setOrderItem]',
				new List<Schema.DescribeFieldResult>{
					OrderItem__c.Order__c.getDescribe(), OrderItem__c.Product__c.getDescribe(),
					OrderItem__c.Quantity__c.getDescribe(), OrderItem__c.Product_Price__c.getDescribe()
				}
			);
		}
		catch (Exception e) {
			throw new SFDCAccessControlException(e);
		}
	}

}