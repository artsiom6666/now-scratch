@isTest
private class ProductTriggerTest {

	//added for Product Bundles
	@isTest static void updateAndDeleteProductBundleBulkTest() {

		List<RecordType> recordTypeProductBundle = [SELECT Id FROM RecordType WHERE DeveloperName = 'Product_Bundle' AND SobjectType = 'Product2' AND IsActive = TRUE];
		List<RecordType> recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'Product' AND SobjectType = 'Product2' AND IsActive = TRUE];

		List<Product2> productBundlesWithProductBundleItems = new List<Product2>();
		for (Integer i = 0; i < 200; i++) {
			productBundlesWithProductBundleItems.add(new Product2(Name = 'Apple Pie + 2L Choc Chip', isActive = true, RecordTypeId = recordTypeProductBundle[0].Id));

		}
		insert productBundlesWithProductBundleItems;

		List<Product2> productBundlesWithoutProductBundleItems = new List<Product2>();
		for (Integer i = 0; i < 200; i++) {
			productBundlesWithoutProductBundleItems.add(new Product2(Name = 'Apple Pie + 2L Choc Chip', isActive = true, RecordTypeId = recordTypeProductBundle[0].Id));

		}
		insert productBundlesWithoutProductBundleItems;

		Product2 prod1 = new Product2(Name = 'Apple Pie', RecordTypeId = recordTypeProduct[0].Id, isActive = true);
		Product2 prod2 = new Product2(Name = '2L Chocolate Chip', RecordTypeId = recordTypeProduct[0].Id, isActive = true);
		insert new List<Product2>{prod1, prod2};

		List<Product_Bundle_Item__c> productBundleItems = new List<Product_Bundle_Item__c>();
		for (Integer i = 0; i < 200; i++) {
			productBundleItems.add(new Product_Bundle_Item__c(Product__c = prod1.Id, Product_Bundle__c = productBundlesWithProductBundleItems[i].Id, Default_Quantity__c = 1));
			productBundleItems.add(new Product_Bundle_Item__c(Product__c = prod2.Id, Product_Bundle__c = productBundlesWithProductBundleItems[i].Id, Default_Quantity__c = 1));

		}
		insert productBundleItems;

		Test.startTest();
			for (Integer i = 0; i < 200; i++) {
				productBundlesWithProductBundleItems[i].RecordTypeId = recordTypeProduct[0].Id;
				productBundlesWithoutProductBundleItems[i].RecordTypeId = recordTypeProduct[0].Id;
			}
			
			Database.SaveResult[] SRproductBundlesWithProductBundleItems = Database.update(productBundlesWithProductBundleItems, false);
			for (Database.SaveResult sr : SRproductBundlesWithProductBundleItems) {
				System.assertEquals(false, sr.isSuccess());
			}

			Database.SaveResult[] SRproductBundlesWithoutProductBundleItems = Database.update(productBundlesWithoutProductBundleItems, false);
			for (Database.SaveResult sr : SRproductBundlesWithoutProductBundleItems) {
				System.assertEquals(true, sr.isSuccess());
			}
			
			for (Integer i = 0; i < 200; i++) {
				productBundlesWithProductBundleItems[i].RecordTypeId = recordTypeProductBundle[0].Id;
				productBundlesWithProductBundleItems[i].RecordTypeId = recordTypeProduct[0].Id;
				productBundlesWithoutProductBundleItems[i].RecordTypeId = recordTypeProductBundle[0].Id;
				productBundlesWithoutProductBundleItems[i].RecordTypeId = recordTypeProduct[0].Id;
			}

			SRproductBundlesWithProductBundleItems = Database.update(productBundlesWithProductBundleItems, false);
			for (Database.SaveResult sr : SRproductBundlesWithProductBundleItems) {
				System.assertEquals(false, sr.isSuccess());
			}

			SRproductBundlesWithoutProductBundleItems = Database.update(productBundlesWithoutProductBundleItems, false);
			for (Database.SaveResult sr : SRproductBundlesWithoutProductBundleItems) {
				System.assertEquals(true, sr.isSuccess());
			}
			
			Database.DeleteResult[] DLproductBundlesWithProductBundleItems = Database.delete(productBundlesWithProductBundleItems, false);
			for (Database.DeleteResult dl : DLproductBundlesWithProductBundleItems) {
				System.assertEquals(false, dl.isSuccess());
			}

			Database.DeleteResult[] DLproductBundlesWithoutProductBundleItems = Database.delete(productBundlesWithoutProductBundleItems, false);
			for (Database.DeleteResult dl : DLproductBundlesWithoutProductBundleItems) {
				System.assertEquals(true, dl.isSuccess());
			}

		Test.stopTest();
	}

}