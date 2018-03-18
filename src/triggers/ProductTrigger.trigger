trigger ProductTrigger on Product2 (before insert, before update, before delete) {


	if (Trigger.isBefore && Trigger.isUpdate) {

		//added for Product Bundle
		//ids product for error 
		Set<Id> idOfProductBundles = new Set<Id>();

		List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE DeveloperName = 'Product_Bundle' AND SobjectType = 'Product2' AND IsActive = TRUE];
		if (!recordTypes.isEmpty()) {
			for (Product2 newProduct2 : Trigger.newMap.values()) {
				Product2 oldProduct2 = Trigger.oldMap.get(newProduct2.Id);
				if (oldProduct2.RecordTypeId != newProduct2.RecordTypeId && oldProduct2.RecordTypeId == recordTypes[0].Id) {
					idOfProductBundles.add(newProduct2.Id);
				}
			}
		}

		List<Product2> productsWithProductBundle = [
			SELECT Id, 
				(
				SELECT Id 
				FROM Product_Bundle__r
			) 
			FROM Product2
			WHERE Id IN: idOfProductBundles
			AND Id IN 
				(
				SELECT Product_Bundle__c 
				FROM Product_Bundle_Item__c
			)
		];

		for (Product2 pr : productsWithProductBundle) {
			//show error
			Product2 actualProduct = Trigger.newMap.get(pr.id);
			actualProduct.adderror('Please remove dependent Product Bundle Items');
		}
	}



	if (Trigger.isBefore && Trigger.isDelete) {

		//added for Product Bundles
		//ids product for error 
		Set<Id> idOfProductBundles = new Set<Id>();

		List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE DeveloperName = 'Product_Bundle' AND SobjectType = 'Product2' AND IsActive = TRUE];
		if (!recordTypes.isEmpty()) {
			for (Product2 oldProduct2 : Trigger.oldMap.values()) {
				if (oldProduct2.RecordTypeId == recordTypes[0].Id) {
					idOfProductBundles.add(oldProduct2.id);
				}
			}		
		}

		List<Product2> productsWithProductBundle = [
			SELECT Id, 
				(
				SELECT Id 
				FROM Product_Bundle__r
			) 
			FROM Product2
			WHERE Id IN: idOfProductBundles
			AND Id IN 
				(
				SELECT Product_Bundle__c 
				FROM Product_Bundle_Item__c
			)
		];

		for (Product2 pr : productsWithProductBundle) {
			//show error
			Product2 actualProduct = Trigger.oldMap.get(pr.id);
			actualProduct.adderror('Please remove dependent Product Bundle Items');
		}



	}
}