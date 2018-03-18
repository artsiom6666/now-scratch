global with sharing class OrderModel {

	/* Inner class instances */
	global PaymentDetails payment_details{get;set;}
	global BillingAddress billing_address{get;set;}
	global ShippingAddress shipping_address{get;set;}
	global CustomerModel customer{get;set;}
	global LineItems line_item{get;set;}
	global ShippingLines shipping_line{get;set;}
	global List<LineItems> line_items{get;set;}
	global List<ShippingLines> shipping_lines{get;set;}
	global List<CouponCodes> coupon_codes{get;set;}
	global String id{get;set;}
	global String email{get;set;}
	global String order_number{get;set;}
	global Datetime created_at{get;set;}
	global Datetime updated_at{get;set;}
	global Datetime completed_at{get;set;}
	global String status{get;set;}
	global String currencyType{get;set;}
	global Decimal total{get;set;}
	global Decimal subtotal{get;set;}
	global String total_line_items_quantity{get;set;}
	global Decimal total_tax{get;set;}
	global Decimal total_shipping{get;set;}
	global Decimal cart_tax{get;set;}
	global Decimal shipping_tax{get;set;}
	global Decimal total_discount{get;set;}
	global String shipping_methods{get;set;}
	global String note{get;set;}
	global String customer_ip{get;set;}
	global String customer_user_agent{get;set;}
	global String customer_id{get;set;}
	global String view_order_url{get;set;}

	global String landing_site{get;set;}


	/* PaymentDetails inner class */
	global with sharing class PaymentDetails{

		global String method_id{get;set;}
		global String method_title{get;set;}
		global String paid{get;set;}
	}

	/* BillingAddres inner class */
	global with sharing class BillingAddress{

		global String first_name{get;set;}
		global String last_name{get;set;}
		global String company{get;set;}
		global String address_1{get;set;}
		global String address_2{get;set;}
		global String city{get;set;}
		global String state{get;set;}
		global String postcode{get;set;}
		global String country{get;set;}
		global String email{get;set;}
		global String phone{get;set;}
	}

	/* ShippingAddres inner class */
	global with sharing class ShippingAddress{

		global String first_name{get;set;}
		global String last_name{get;set;}
		global String company{get;set;}
		global String address_1{get;set;}
		global String address_2{get;set;}
		global String city{get;set;}
		global String state{get;set;}
		global String postcode{get;set;}
		global String country{get;set;}
	}

	/* LineItems inner class */
	global with sharing class LineItems{

		global String id{get;set;}
		global String orderId{get;set;}
		global String subtotal{get;set;}
		global String subtotal_tax{get;set;}
		global String total{get;set;}
		global String total_tax{get;set;}
		global Decimal price{get;set;}
		global Decimal quantity{get;set;}
		global String tax_class{get;set;}
		global String name{get;set;}
		global String product_id{get;set;}
		global String variant_id{get;set;}
		global String sku{get;set;}
	}

	/* ShippingLines inner class */
	global with sharing class ShippingLines{

		global String id{get;set;}
		global String method_id{get;set;}
		global String method_title{get;set;}
		global Decimal total{get;set;}
	}


	/* CouponCodes inner class */
	global with sharing class CouponCodes{

		global String id{get;set;}
		global String code{get;set;}
		global Decimal amount{get;set;}
		global String type{get;set;}
	}
}