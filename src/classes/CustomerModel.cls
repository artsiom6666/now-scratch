global with sharing class CustomerModel {

	/* inner Classes' Instances */
	global BillingAddress billing_address {get;set;}
	global ShippingAddress shipping_address {get;set;}
	global String id {get;set;}
	global String created_at {get;set;}
	global String updated_at {get;set;}
	global String email {get;set;}
	global String first_name {get;set;}
	global String last_name {get;set;}
	global String username {get;set;}
	global String role {get;set;}
	global String last_order_id {get;set;}
	global String last_order_date {get;set;}
	global String orders_count {get;set;}
	global String total_spent {get;set;}
	global String avatar_url {get;set;}

	/* inner class */
	global with sharing class BillingAddress{

		global String first_name {get;set;}
		global String last_name {get;set;}
		global String company {get;set;}
		global String address_1 {get;set;}
		global String address_2 {get;set;}
		global String city {get;set;}
		global String state {get;set;}
		global String postcode {get;set;}
		global String country {get;set;}
		global String email {get;set;}
		global String phone {get;set;}
	}

	/* inner Class */
	global with sharing class ShippingAddress{

		global String first_name {get;set;}
		global String last_name {get;set;}
		global String company {get;set;}
		global String address_1 {get;set;}
		global String address_2 {get;set;}
		global String city {get;set;}
		global String state {get;set;}
		global String postcode {get;set;}
		global String country {get;set;}
	}
}