public with sharing class CouponHelper {

	/**
	 * method name: addCouponData
	 * created: 01/26/2018
	 * Author: Stanislau Yarashchuk
	 * increment Coupon Uses and create coupon customers records
	 * @param  orderId			Order Id
	 * @param  accountId		Account Id
	 */
	public static Void addCouponData (Id orderId, Id accountId) {

		if (orderId == NULL || accountId == NULL) { return; }

		SFDCAccessController.AccessibleWithoutSharing (
			'Coupon_Order__c',
			'CouponHelper.cls [addCouponData]',
			new List<Schema.DescribeFieldResult> {
				Coupon_Order__c.Coupon__c.getDescribe(),
				Coupon_Order__c.Order__c.getDescribe()
			}
		);
		List<Coupon_Order__c> couponOrderList = [
			SELECT Coupon__c
			FROM Coupon_Order__c
			WHERE Order__c = :orderId
		];

		List<Id> couponIdList = new List<Id>();
		if (!couponOrderList.isEmpty()) {
			for (Coupon_Order__c item : couponOrderList) {
				couponIdList.add(item.Coupon__c);
			}
		}

		if (!couponIdList.isEmpty()) {
			CouponHelper.incrementCouponUses(couponIdList);
			CouponHelper.createCouponCustomers(couponIdList, accountId);
		}

	}


	/**
	 * method name: incrementCouponUses
	 * created: 02/02/2018
	 * Author: Stanislau Yarashchuk
	 * increment Coupon Uses
	 * @param  couponIdList		Coupon Id List
	 */
	private static Void incrementCouponUses (List<Id> couponIdList) {
		Set<Id> couponUsesSet = new Set<Id>();
		if (couponIdList != NULL && !couponIdList.isEmpty()) {
			couponUsesSet.addAll(couponIdList);
		}

		List<Coupon_Uses__c> couponUsesList = CouponHelper.getCouponUsesByCouponIds(couponIdList);
		for (Coupon_Uses__c item : couponUsesList) {
			if (couponUsesSet.contains(item.Coupon__c)) {
				couponUsesSet.remove(item.Coupon__c);
			}
		}

		if (!couponUsesSet.isEmpty()) {
			for (Id item : couponUsesSet) {
				couponUsesList.add(
					new Coupon_Uses__c (
						Coupon__c = item,
						Uses__c = 0
					)
				);
			}
		}

		for (Coupon_Uses__c item : couponUsesList) {
			item.Uses__c = item.Uses__c != NULL ? item.Uses__c + 1 : 1;
		}

		SFDCAccessController.UpsertWithoutSharing (
			couponUsesList,
			'CouponHelper.cls [incrementCouponUses]',
			new List<Schema.DescribeFieldResult> {
				Coupon_Uses__c.Coupon__c.getDescribe(),
				Coupon_Uses__c.Uses__c.getDescribe()
			}
		);
	}

	/**
	 * method name: createCouponCustomers
	 * created: 02/02/2018
	 * Author: Stanislau Yarashchuk
	 * increment Coupon Uses
	 * @param  couponIdList		Coupon Id List
	 */
	private static Void createCouponCustomers (List<Id> couponIdList, Id accountId) {

		if (couponIdList == NULL || couponIdList.isEmpty() || accountId == NULL) { return; }

		List<Coupon_Customer__c> couponCustomerList = new List<Coupon_Customer__c>();
		for (Id item : couponIdList) {
			couponCustomerList.add(
				new Coupon_Customer__c(
					Account__c = accountId,
					Coupon__c = item
				)
			);
		}

		SFDCAccessController.UpsertWithoutSharing (
			couponCustomerList,
			'CouponHelper.cls [createCouponCustomers]',
			new List<Schema.DescribeFieldResult> {
				Coupon_Customer__c.Account__c.getDescribe(),
				Coupon_Customer__c.Coupon__c.getDescribe()
			}
		);
	}

	// method name: getCouponByCouponId
	// created: 01/26/2018
	// Author: Stanislau Yarashchuk
	// get Coupon Info
	public static Coupon__c getCouponByCouponId (Id couponId) {
		SFDCAccessController.AccessibleWithoutSharing (
			'Coupon__c',
			'CouponHelper.cls [getCouponByCouponId]',
			new List<Schema.DescribeFieldResult> {
				Coupon__c.Id.getDescribe(),
				Coupon__c.Name.getDescribe(),
				Coupon__c.Discount_Amount__c.getDescribe(),
				Coupon__c.Coupon_Code__c.getDescribe(), 
				Coupon__c.Start_Date__c.getDescribe(), 
				Coupon__c.End_Date__c.getDescribe(), 
				Coupon__c.Uses_Limit__c.getDescribe(), 
				Coupon__c.Status__c.getDescribe(),
				Coupon__c.Discount_Type__c.getDescribe(),
				Coupon__c.Uses_Limit_Value__c.getDescribe(),
				Coupon__c.New_Customer__c.getDescribe(),
				Coupon__c.Product__c.getDescribe(),
				Coupon__c.Cart_Over_Value__c.getDescribe(),
				Coupon__c.Auto_Apply__c.getDescribe()			}
		);

		Date today = Date.today();
		List<Coupon__c> couponList = [
			SELECT Id, Name, Discount_Amount__c, Coupon_Code__c, Start_Date__c, End_Date__c, Uses_Limit__c, Status__c,
				Discount_Type__c, Uses_Limit_Value__c, New_Customer__c, Product__c, Cart_Over_Value__c, Auto_Apply__c
			FROM Coupon__c
			WHERE Id = :couponId AND Status__c = 'Active' AND Start_Date__c <= :today AND End_Date__c >= :today
			LIMIT 1
		];

		Coupon__c result = !couponList.isEmpty() ? couponList[0] : NULL;

		return result;
	}


	// method name: getCouponByCouponCode
	// created: 01/25/2018
	// Author: Stanislau Yarashchuk
	// get Coupon Info
	public static Coupon__c getCouponByCouponCode (String couponCode) {
		SFDCAccessController.AccessibleWithoutSharing (
			'Coupon__c',
			'CouponHelper.cls [getCouponByCouponCode]',
			new List<Schema.DescribeFieldResult> {
				Coupon__c.Id.getDescribe(),
				Coupon__c.Name.getDescribe(),
				Coupon__c.Discount_Amount__c.getDescribe(),
				Coupon__c.Coupon_Code__c.getDescribe(), 
				Coupon__c.Start_Date__c.getDescribe(), 
				Coupon__c.End_Date__c.getDescribe(), 
				Coupon__c.Uses_Limit__c.getDescribe(), 
				Coupon__c.Status__c.getDescribe(),
				Coupon__c.Discount_Type__c.getDescribe(),
				Coupon__c.Uses_Limit_Value__c.getDescribe(),
				Coupon__c.New_Customer__c.getDescribe(),
				Coupon__c.Product__c.getDescribe(),
				Coupon__c.Cart_Over_Value__c.getDescribe(),
				Coupon__c.Auto_Apply__c.getDescribe()		
			}
		);

		Date today = Date.today();
		List<Coupon__c> couponList = [
			SELECT Id, Name, Discount_Amount__c, Coupon_Code__c, Start_Date__c, End_Date__c, Uses_Limit__c, Status__c, 
				Discount_Type__c, Uses_Limit_Value__c, New_Customer__c, Product__c, Cart_Over_Value__c, Auto_Apply__c
			FROM Coupon__c
			WHERE Coupon_Code__c = :couponCode AND Status__c = 'Active' AND Start_Date__c <= :today AND End_Date__c >= :today
			LIMIT 1
		];

		Coupon__c result = !couponList.isEmpty() ? couponList[0] : NULL;

		return result;
	}

	// method name: getCouponUsesByCouponId
	// created: 01/25/2018
	// Author: Stanislau Yarashchuk
	// get Coupon Uses
	public static Coupon_Uses__c getCouponUsesByCouponId(Id couponId) {

		SFDCAccessController.AccessibleWithoutSharing (
			'Coupon_Uses__c',
			'CouponHelper.cls [getCouponUsesByCouponId]',
			new List<Schema.DescribeFieldResult> {
				Coupon_Uses__c.Id.getDescribe(), 
				Coupon_Uses__c.Name.getDescribe(), 
				Coupon_Uses__c.Uses__c.getDescribe(), 
				Coupon_Uses__c.Coupon__c.getDescribe()
			}
		);

		List<Coupon_Uses__c> couponUsesList = [
			SELECT Id, Name, Uses__c, Coupon__c
			FROM Coupon_Uses__c
			WHERE Coupon__c = :couponId
			LIMIT 1
		];

		Coupon_Uses__c result = !couponUsesList.isEmpty() ? couponUsesList[0] : NULL;

		return result;
	}

	/**
	 * method name: getCouponUsesByCouponIds
	 * created: 02/02/2018
	 * Author: Stanislau Yarashchuk
	 * get Coupon Uses
	 * @param  couponIdList			List of Coupon Ids
	 */
	public static List<Coupon_Uses__c> getCouponUsesByCouponIds(List<Id> couponIdList) {

		SFDCAccessController.AccessibleWithoutSharing (
			'Coupon_Uses__c',
			'CouponHelper.cls [getCouponUsesByCouponId]',
			new List<Schema.DescribeFieldResult> {
				Coupon_Uses__c.Id.getDescribe(), 
				Coupon_Uses__c.Name.getDescribe(), 
				Coupon_Uses__c.Uses__c.getDescribe(), 
				Coupon_Uses__c.Coupon__c.getDescribe()
			}
		);

		List<Coupon_Uses__c> couponUsesList = [
			SELECT Id, Name, Uses__c, Coupon__c
			FROM Coupon_Uses__c
			WHERE Coupon__c IN :couponIdList
		];

		return couponUsesList;
	}

	// method name: getCouponCustomersByIds
	// created: 01/25/2018
	// Author: Stanislau Yarashchuk
	// get List Coupon Customers
	public static List<Coupon_Customer__c> getCouponCustomersByIds(Id couponId, Id accountId) {
		List<Coupon_Customer__c> result = new List<Coupon_Customer__c>();
		SFDCAccessController.AccessibleWithoutSharing (
			'Coupon_Customer__c',
			'CouponHelper.cls [getCouponCustomersByIds]',
			new List<Schema.DescribeFieldResult> {
				Coupon_Customer__c.Account__c.getDescribe(), 
				Coupon_Customer__c.Coupon__c.getDescribe()
			}
		);

		result = [
			SELECT Account__c, Coupon__c 
			FROM Coupon_Customer__c
			WHERE Coupon__c = :couponId AND Account__c = :accountId
		];

		return result;
	}

	// method name: isNewCustomer
	// created: 01/25/2018
	// Author: Stanislau Yarashchuk
	// get List Coupon Customers
	public static Boolean isNewCustomer(Id accountId) {

		SFDCAccessController.AccessibleWithoutSharing (
			'Order_Transaction__c',
			'CouponHelper.cls [isNewCustomer]',
			new List<Schema.DescribeFieldResult> {
				Order_Transaction__c.Id.getDescribe(),
				Order_Transaction__c.Status__c.getDescribe(),
				Order_Transaction__c.Type__c.getDescribe(),
				Order__c.Account__c.getDescribe()
			}
		);

		List<Order_Transaction__c> orderTransactionList = [
			SELECT Id
			FROM Order_Transaction__c
			WHERE Order__r.Account__c = :accountId AND Response_Status__c = 'Approved' AND Type__c = 'Charge'
			LIMIT 1
		];

		Boolean result = !orderTransactionList.isEmpty() ? FALSE : TRUE;

		return result;
	}

	// method name: getCouponProductByBrand
	// created: 02/01/2018
	// Author: Stanislau Yarashchuk
	// get Coupon Product by Brand
	public static Product2 getCouponProductByBrand(String brand) {

		Product2 result = new Product2();

		SFDCAccessController.AccessibleWithoutSharing (
			'Product2',
			'CouponHelper.cls [getCouponProductByBrand]',
			new List<Schema.DescribeFieldResult> {
				Product2.Id.getDescribe(),
				Product2.Name.getDescribe(),
				Product2.Family.getDescribe()
			}
		);

		List<Product2> productList = [
			SELECT Id, Name, Family
			FROM Product2
			WHERE Name = 'Coupon' AND Family = :brand
			LIMIT 1
		];

		if (!productList.isEmpty()) {
			result = productList[0];
		}
		else {
			Product2 newProduct = new Product2(
				Name = 'Coupon',
				Family = brand
			);
			SFDCAccessController.UpsertWithoutSharing (
				newProduct,
				'CouponHelper.cls [getCouponProductByBrand]',
				new List<Schema.DescribeFieldResult> {
					Product2.Name.getDescribe(),
					Product2.Family.getDescribe()
				}
			);
			result = newProduct;
		}

		return result;
	}

	/**
	 * method name: getCouponProductVariant
	 * created: 02/01/2018
	 * Author: Stanislau Yarashchuk
	 * get Coupon Product by Brand
	 * @param  productId		Coupon Product Id
	 * @param  couponName		Coupon Name
	 */
	public static Product_Variant__c getCouponProductVariant(Id productId, String couponName) {

		Product_Variant__c result = new Product_Variant__c();

		SFDCAccessController.AccessibleWithoutSharing (
			'Product_Variant__c',
			'CouponHelper.cls [getCouponProductVariant]',
			new List<Schema.DescribeFieldResult> {
				Product_Variant__c.Id.getDescribe(),
				Product_Variant__c.Name.getDescribe(),
				Product_Variant__c.Product__c.getDescribe()
			}
		);

		List<Product_Variant__c> productVariantList = [
			SELECT Id, Name, Product__c
			FROM Product_Variant__c
			WHERE Name = :couponName AND Product__c = :productId
			LIMIT 1
		];

		if (!productVariantList.isEmpty()) {
			result = productVariantList[0];
		}
		else {
			Product_Variant__c newProductVariant = new Product_Variant__c(
				Name = couponName,
				Product__c = productId
			);
			SFDCAccessController.UpsertWithoutSharing (
				newProductVariant,
				'CouponHelper.cls [getCouponProductVariant]',
				new List<Schema.DescribeFieldResult> {
					Product_Variant__c.Name.getDescribe(),
					Product_Variant__c.Product__c.getDescribe()
				}
			);
			result = newProductVariant;
		}

		return result;
	}

	/**
	 * method name: createCouponOrders
	 * created: 02/01/2018
	 * Author: Stanislau Yarashchuk
	 * get Coupon Product by Brand
	 * @param  orderId			Order Id
	 * @param  couponIdList		Coupon Ids
	 */
	public static Void createCouponOrders(Id orderId, List<Id> couponIdList) {

		List<Coupon_Order__c> couponOrderList = new List<Coupon_Order__c>();
		for (Id item : couponIdList) {
			couponOrderList.add(
				new Coupon_Order__c(
					Coupon__c = item,
					Order__c = orderId
				)
			);
		}

		SFDCAccessController.UpsertWithoutSharing (
			couponOrderList,
			'CouponHelper.cls [createCouponOrders]',
			new List<Schema.DescribeFieldResult> {
				Coupon_Order__c.Coupon__c.getDescribe(),
				Coupon_Order__c.Order__c.getDescribe()
			}
		);

	}


}