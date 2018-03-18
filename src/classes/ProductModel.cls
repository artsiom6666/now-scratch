global with sharing class ProductModel {

	/* inner Classes' Instances */
	global Dimension dimensions{get;set;}
	global List<Image> images{get;set;}
	global List<Variations> variations{get;set;}
	global String title{get;set;}
	global String id{get;set;}
	global String created_at{get;set;}
	global String updated_at{get;set;}
	global String type{get;set;}
	global String status{get;set;}
	global String downloadable{get;set;}
	global String virtualType{get;set;}
	global String permalink{get;set;}
	global String sku{get;set;}
	global Decimal price{get;set;}
	global Decimal regular_price{get;set;}
	global String sale_price{get;set;}
	global String price_html{get;set;}
	global String taxable{get;set;}
	global String tax_status{get;set;}
	global String tax_class{get;set;}
	global String managing_stock{get;set;}
	global String sold_individually{get;set;}
	global String in_stock{get;set;}
	global String backordered{get;set;}
	global String backorders_allowed{get;set;}
	global String purchaseable{get;set;}
	global String featured{get;set;}
	global String visible{get;set;}
	global String catalog_visibility{get;set;}
	global String on_sale{get;set;}
	global String product_url{get;set;}
	global String button_text{get;set;}
	global String weight{get;set;}
	global String shipping_required{get;set;}
	global String shipping_class{get;set;}
	global String shipping_class_id{get;set;}
	global String reviews_allowed{get;set;}
	global String description{get;set;}
	global String short_description{get;set;}
	global String average_rating{get;set;}
	global String rating_count{get;set;}
	global String parent_id{get;set;}
	global String total_sales{get;set;}
	global List<String> categories{get;set;}
	global String featured_src{get;set;}
	global String download_limit{get;set;}
	global String download_expiry{get;set;}
	global String download_type{get;set;}
	global String purchase_note{get;set;}
	global List<Atributes> custom_attributes{get;set;}

	/* Atributes inner class */
	global with sharing class Atributes{

		global String attribute_code{get;set;}
		global String value{get;set;}
	}

	/* Dimension inner class */
	global with sharing class Dimension{

		global String length{get;set;}
		global String width{get;set;}
		global String height{get;set;}
		global String unit{get;set;}
	}


	/* Image inner class */
	global with sharing class Image{

		global String id{get;set;}
		global List<String> variant_ids{get;set;}
		global String created_at{get;set;}
		global String updated_at{get;set;}
		global String src{get;set;}
		global String title{get;set;}
		global String alt{get;set;}
		global String position{get;set;}

	}

	/* Image inner class */
	global with sharing class Variations{

		global String id{get;set;}
		global String image_id{get;set;}
		global Datetime created_at{get;set;}
		global Datetime updated_at{get;set;}
		global Boolean downloadable{get;set;}
		global Boolean virtualType{get;set;}
		global String permalink{get;set;}
		global String sku{get;set;}
		global Decimal price{get;set;}
		global Decimal regular_price{get;set;}
		global Decimal sale_price{get;set;}
		global Boolean taxable{get;set;}
		global String tax_status{get;set;}
		global String tax_class{get;set;}
		global Boolean managing_stock{get;set;}
		global Integer stock_quantity{get;set;}
		global Boolean in_stock{get;set;}
		global Boolean backordered{get;set;}
		global Boolean purchaseable{get;set;}
		global Boolean visible{get;set;}
		global Boolean on_sale{get;set;}
		global String weight{get;set;}
		global Dimension dimensions{get;set;}
		global String shipping_class{get;set;}
		global String shipping_class_id{get;set;}
		global List<Image> image{get;set;}
	}
}