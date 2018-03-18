public with sharing class ShoppingCartController {

	/**    get url of product by id with security validation    **/
	@AuraEnabled
	public static PricebookEntry getMyProductById(ID ProductId) {
		Set<String> pricebookAccessFields = new Set<String> {'Id',
													   'UnitPrice'
													   };
		Set<String> productAccessFields = new Set<String> {'Id',
													   'ProductCode',
													   'Name',
													   'Description'
													   };

		// Obtain the field name/token map for the Expense object
		Map<String,Schema.SObjectField> pb = Schema.SObjectType.PricebookEntry.fields.getMap();
		Map<String,Schema.SObjectField> prod = Schema.SObjectType.Product2.fields.getMap();

		for (String fieldToCheck : pb.keySet()) {
			Schema.SObjectField F = pb.get(fieldToCheck);
			Schema.DescribeFieldResult R = F.getDescribe();
			String fieldLocalName = R.getLocalName();
			// Check if the user has access to view field
			if (pricebookAccessFields.contains(fieldLocalName) && !R.isAccessible()) {
				// Pass error to client
				throw new System.NoAccessException();
				// Suppress editor logs
				return null;
			}
		}
		for (String fieldToCheck : prod.keySet()) {
			Schema.SObjectField F = prod.get(fieldToCheck);
			Schema.DescribeFieldResult R = F.getDescribe();
			String fieldLocalName = R.getLocalName();
			// Check if the user has access to view field
			if (productAccessFields.contains(fieldLocalName) && !R.isAccessible()) {
				// Pass error to client
				throw new System.NoAccessException();
				// Suppress editor logs
				return null;
			}
		}

		// Query the object safely
		return [SELECT Id, UnitPrice, Product2.Id, Product2.ProductCode, Product2.Name, Product2.Description FROM PricebookEntry WHERE Product2.Id = :ProductId LIMIT 1];
	}

	/**    get image of product by id with security validation    **/
	@AuraEnabled
	public static string getMyProductImageById(ID ProductId) {
		Set<String> productimageAccessFields = new Set<String> {'Id',
													   'Image_URL__c'
													   };
		Set<String> productAccessFields = new Set<String> {'Id'
													   };

		// Obtain the field name/token map for the Expense object
		Map<String,Schema.SObjectField> pb = Schema.SObjectType.Product_Image__c.fields.getMap();
		Map<String,Schema.SObjectField> prod = Schema.SObjectType.Product2.fields.getMap();

		for (String fieldToCheck : pb.keySet()) {
			Schema.SObjectField F = pb.get(fieldToCheck);
			Schema.DescribeFieldResult R = F.getDescribe();
			String fieldLocalName = R.getLocalName();
			// Check if the user has access to view field
			if (productimageAccessFields.contains(fieldLocalName) && !R.isAccessible()) {
				// Pass error to client
				throw new System.NoAccessException();
				// Suppress editor logs
				return null;
			}
		}
		for (String fieldToCheck : prod.keySet()) {
			Schema.SObjectField F = prod.get(fieldToCheck);
			Schema.DescribeFieldResult R = F.getDescribe();
			String fieldLocalName = R.getLocalName();
			// Check if the user has access to view field
			if (productAccessFields.contains(fieldLocalName) && !R.isAccessible()) {
				// Pass error to client
				throw new System.NoAccessException();
				// Suppress editor logs
				return null;
			}
		}

		// Query the object safely
		String tmpState = [SELECT Image_URL__c FROM Product_Image__c WHERE Product_Lookup__r.Id = :ProductId LIMIT 1].Image_URL__c;
		return tmpState;
	}

	/**    get image of variant by id with security validation    **/
	@AuraEnabled
	public static string getMyVariantImageById(ID VariantId) {
		Set<String> productimageAccessFields = new Set<String> {'Id',
													   'Image_URL__c'
													   };
		Set<String> variantAccessFields = new Set<String> {'Id'
													   };

		// Obtain the field name/token map for the Expense object
		Map<String,Schema.SObjectField> pb = Schema.SObjectType.Product_Image__c.fields.getMap();
		Map<String,Schema.SObjectField> vari = Schema.SObjectType.Product_Variant__c.fields.getMap();

		for (String fieldToCheck : pb.keySet()) {
			Schema.SObjectField F = pb.get(fieldToCheck);
			Schema.DescribeFieldResult R = F.getDescribe();
			String fieldLocalName = R.getLocalName();
			// Check if the user has access to view field
			if (productimageAccessFields.contains(fieldLocalName) && !R.isAccessible()) {
				// Pass error to client
				throw new System.NoAccessException();
				// Suppress editor logs
				return null;
			}
		}
		for (String fieldToCheck : vari.keySet()) {
			Schema.SObjectField F = vari.get(fieldToCheck);
			Schema.DescribeFieldResult R = F.getDescribe();
			String fieldLocalName = R.getLocalName();
			// Check if the user has access to view field
			if (variantAccessFields.contains(fieldLocalName) && !R.isAccessible()) {
				// Pass error to client
				throw new System.NoAccessException();
				// Suppress editor logs
				return null;
			}
		}

		// Query the object safely
		String tmpState = [SELECT Image_URL__c FROM Product_Image__c WHERE Product_Variant_Lookup__r.Id = :VariantId LIMIT 1].Image_URL__c;
		return tmpState;
	}

	@AuraEnabled
	public static List<PricebookEntry> getProductsListbyCategory(String catid) {

		String categ = catid;

		Set<String> pricebookAccessFields = new Set<String> {'Id',
													   'UnitPrice'
													   };
		Set<String> productAccessFields = new Set<String> {'Id',
													   'ProductCode',
													   'Name',
													   'Description'
													   };

		// Obtain the field name/token map for the Expense object
		Map<String,Schema.SObjectField> m = Schema.SObjectType.PricebookEntry.fields.getMap();
		Map<String,Schema.SObjectField> prod = Schema.SObjectType.Product2.fields.getMap();

		for (String fieldToCheck : m.keySet()) {
			Schema.SObjectField F = m.get(fieldToCheck);
			Schema.DescribeFieldResult R = F.getDescribe();
			String fieldLocalName = R.getLocalName();
			// Check if the user has access to view field
			if (pricebookAccessFields.contains(fieldLocalName) && !R.isAccessible()) {
				// Pass error to client
				throw new System.NoAccessException();
				// Suppress editor logs
				return null;
			}
		}
		for (String fieldToCheck : prod.keySet()) {
			Schema.SObjectField F = prod.get(fieldToCheck);
			Schema.DescribeFieldResult R = F.getDescribe();
			String fieldLocalName = R.getLocalName();
			// Check if the user has access to view field
			if (productAccessFields.contains(fieldLocalName) && !R.isAccessible()) {
				// Pass error to client
				throw new System.NoAccessException();
				// Suppress editor logs
				return null;
			}
		}
		return [SELECT Id, UnitPrice, Product2.Id, Product2.Name, Product2.ProductCode FROM PricebookEntry WHERE Product2.Category__r.Name = :categ AND IsActive = true];
	 }

		 @AuraEnabled
	public static List<Category__c> getTopCategoryList(String brand) {

		String categ = brand;

		Set<String> categoryAccessFields = new Set<String> {'Name',
													   'Brand__c',
													   'ParentCategory__c',
													   'Category_Description__c',
													   'Category_Keywords__c',
													   'Category_Name__c'
													   };


		// Obtain the field name/token map for the Expense object
		Map<String,Schema.SObjectField> m = Schema.SObjectType.Category__c.fields.getMap();

		for (String fieldToCheck : m.keySet()) {
			Schema.SObjectField F = m.get(fieldToCheck);
			Schema.DescribeFieldResult R = F.getDescribe();
			String fieldLocalName = R.getLocalName();
			// Check if the user has access to view field
			if (categoryAccessFields.contains(fieldLocalName) && !R.isAccessible()) {
				// Pass error to client
				throw new System.NoAccessException();
				// Suppress editor logs
				return null;
			}
		}

		return [SELECT Id, Name, Category_Description__c, Category_Keywords__c, Category_Name__c, ParentCategory__c, (Select Id, Name, Category_Description__c, Category_Keywords__c, Category_Name__c, ParentCategory__c from Categories__r) FROM Category__c WHERE Brand__c = :brand AND ParentCategory__c = NULL LIMIT 2000];

	 }
	@AuraEnabled
	public static String getCategoryIdbyCategoryName(String catname) {

		String categ = catname;

		Set<String> categoryAccessFields = new Set<String> {'Name',
													   'Category_Name__c'
													   };


		// Obtain the field name/token map for the Expense object
		Map<String,Schema.SObjectField> m = Schema.SObjectType.Category__c.fields.getMap();

		for (String fieldToCheck : m.keySet()) {
			Schema.SObjectField F = m.get(fieldToCheck);
			Schema.DescribeFieldResult R = F.getDescribe();
			String fieldLocalName = R.getLocalName();
			// Check if the user has access to view field
			if (categoryAccessFields.contains(fieldLocalName) && !R.isAccessible()) {
				// Pass error to client
				throw new System.NoAccessException();
				// Suppress editor logs
				return null;
			}
		}
		List<Category__c> catlist = [SELECT Name FROM Category__c WHERE Category_Name__c = :categ LIMIT 1];
		String catid = catlist[0].Name;
		return catid;
	 }
	/**    get image of product by id with security validation    **/
	@AuraEnabled
	public static List<Product_Variant__c> getMyProductVariantsById(ID ProductId) {
		Set<String> productvariantAccessFields = new Set<String> {'Id',
														'Product_Title__c',
														'Variant_Type__c',
														'Price__c'
													   };
		Set<String> productAccessFields = new Set<String> {'Id'
													   };

		// Obtain the field name/token map for the Expense object
		Map<String,Schema.SObjectField> pb = Schema.SObjectType.Product_Variant__c.fields.getMap();
		Map<String,Schema.SObjectField> prod = Schema.SObjectType.Product2.fields.getMap();

		for (String fieldToCheck : pb.keySet()) {
			Schema.SObjectField F = pb.get(fieldToCheck);
			Schema.DescribeFieldResult R = F.getDescribe();
			String fieldLocalName = R.getLocalName();
			// Check if the user has access to view field
			if (productvariantAccessFields.contains(fieldLocalName) && !R.isAccessible()) {
				// Pass error to client
				throw new System.NoAccessException();
				// Suppress editor logs
				return null;
			}
		}
		for (String fieldToCheck : prod.keySet()) {
			Schema.SObjectField F = prod.get(fieldToCheck);
			Schema.DescribeFieldResult R = F.getDescribe();
			String fieldLocalName = R.getLocalName();
			// Check if the user has access to view field
			if (productAccessFields.contains(fieldLocalName) && !R.isAccessible()) {
				// Pass error to client
				throw new System.NoAccessException();
				// Suppress editor logs
				return null;
			}
		}

		// Query the object safely
		List<Product_Variant__c> variantlist = [SELECT Id, Product_Title__c, Variant_Type__c, Price__c  FROM Product_Variant__c WHERE Product__r.Id = :ProductId LIMIT 100];
		return variantlist;
	}

}