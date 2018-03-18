@isTest
private class CouponHelperTest {
	
	// test method name: checkIsNewCustomer	
	// created: 01/26/2018
	// Author: Stanislau Yarashchuk
	// Check New Customer Logic
	@isTest static void checkIsNewCustomer(){ 
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account account1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName1', LastName = 'lastName1', Phone = '9876543211', 
			PersonEmail = 'test@test1.com'
		);
		Account account2 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName2', LastName = 'lastName2', Phone = '9876543212', 
			PersonEmail = 'test@test2.com'
		);
		insert new List<Account>{account1,account2};

		Order__c order1 = new Order__c(
			Account__c = account1.Id
		);
		insert order1;

		Order_Transaction__c orderTransaction1 = new Order_Transaction__c(
			Order__c = order1.Id,
			Type__c = 'Charge',
			Response_Status__c = 'Approved'
		);
		insert orderTransaction1;

		System.assertEquals(FALSE, CouponHelper.isNewCustomer(account1.Id));
		System.assertEquals(TRUE, CouponHelper.isNewCustomer(account2.Id));
	}

	// test method name: checkGetCouponCustomersByIds	
	// created: 01/26/2018
	// Author: Stanislau Yarashchuk
	// Check method getCouponCustomersByIds
	@isTest static void checkGetCouponCustomersByIds(){ 
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account account1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName1', LastName = 'lastName1', Phone = '9876543211', 
			PersonEmail = 'test@test1.com'
		);
		Account account2 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName2', LastName = 'lastName2', Phone = '9876543212', 
			PersonEmail = 'test@test2.com'
		);
		insert new List<Account>{account1,account2};

		Coupon__c coupon1 = new Coupon__c(
			Coupon_Code__c = 'coupon1',
			Description__c = 'test coupon1',
			Discount_Amount__c = 10,
			Discount_Type__c = '$ Off',
			End_Date__c = Date.today().addDays(30),
			Start_Date__c = Date.today().addDays(-2),
			New_Customer__c = true,
			Status__c = 'Active',
			Uses_Limit__c = 'Overall',
			Uses_Limit_Value__c = 1,
			Cart_Over_Value__c = 1
		);
		insert coupon1;

		Coupon_Uses__c couponUses1 = new Coupon_Uses__c(
			Coupon__c = coupon1.Id,
			Uses__c = 0
		);
		insert couponUses1;

		Coupon_Customer__c couponCustomer = new Coupon_Customer__c(
			Coupon__c = coupon1.Id,
			Account__c = account1.Id
		);
		insert couponCustomer;

		System.assertEquals(1, CouponHelper.getCouponCustomersByIds(coupon1.Id, account1.Id).size());
		System.assertEquals(0, CouponHelper.getCouponCustomersByIds(coupon1.Id, account2.Id).size());
	}

	// test method name: checkGetCouponUsesByCouponId	
	// created: 01/26/2018
	// Author: Stanislau Yarashchuk
	// Check method getCouponUsesByCouponId
	@isTest static void checkGetCouponUsesByCouponId(){ 
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account account1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName1', LastName = 'lastName1', Phone = '9876543211', 
			PersonEmail = 'test@test1.com'
		);
		Account account2 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName2', LastName = 'lastName2', Phone = '9876543212', 
			PersonEmail = 'test@test2.com'
		);
		insert new List<Account>{account1,account2};

		Coupon__c coupon1 = new Coupon__c(
			Coupon_Code__c = 'coupon1',
			Description__c = 'test coupon1',
			Discount_Amount__c = 10,
			Discount_Type__c = '$ Off',
			End_Date__c = Date.today().addDays(30),
			Start_Date__c = Date.today().addDays(-2),
			New_Customer__c = true,
			Status__c = 'Active',
			Uses_Limit__c = 'Overall',
			Uses_Limit_Value__c = 10,
			Cart_Over_Value__c = 1
		);
		Coupon__c coupon2 = new Coupon__c(
			Coupon_Code__c = 'coupon2',
			Description__c = 'test coupon1',
			Discount_Amount__c = 10,
			Discount_Type__c = '$ Off',
			End_Date__c = Date.today().addDays(30),
			Start_Date__c = Date.today().addDays(-2),
			New_Customer__c = true,
			Status__c = 'Active',
			Uses_Limit__c = 'Overall',
			Uses_Limit_Value__c = 10,
			Cart_Over_Value__c = 1
		);
		insert new List<Coupon__c>{coupon1,coupon2};

		Coupon_Uses__c couponUses1 = new Coupon_Uses__c(
			Coupon__c = coupon1.Id,
			Uses__c = 5
		);
		insert couponUses1;

		System.assertEquals(5, CouponHelper.getCouponUsesByCouponId(coupon1.Id).Uses__c);
		System.assertEquals(NULL, CouponHelper.getCouponUsesByCouponId(coupon2.Id));
	}

	// test method name: checkGetCouponByCouponCode	
	// created: 01/26/2018
	// Author: Stanislau Yarashchuk
	// Check method getCouponByCouponCode
	@isTest static void checkGetCouponByCouponCode(){ 
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account account1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName1', LastName = 'lastName1', Phone = '9876543211', 
			PersonEmail = 'test@test1.com'
		);
		Account account2 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName2', LastName = 'lastName2', Phone = '9876543212', 
			PersonEmail = 'test@test2.com'
		);
		insert new List<Account>{account1,account2};

		Coupon__c coupon1 = new Coupon__c(
			Coupon_Code__c = 'coupon1',
			Description__c = 'test coupon1',
			Discount_Amount__c = 10,
			Discount_Type__c = '$ Off',
			End_Date__c = Date.today().addDays(30),
			Start_Date__c = Date.today().addDays(-2),
			New_Customer__c = true,
			Status__c = 'Active',
			Uses_Limit__c = 'Overall',
			Uses_Limit_Value__c = 10,
			Cart_Over_Value__c = 1
		);
		Coupon__c coupon2 = new Coupon__c(
			Coupon_Code__c = 'coupon2',
			Description__c = 'test coupon1',
			Discount_Amount__c = 10,
			Discount_Type__c = '$ Off',
			End_Date__c = Date.today().addDays(30),
			Start_Date__c = Date.today().addDays(-2),
			New_Customer__c = true,
			Status__c = 'Active',
			Uses_Limit__c = 'Overall',
			Uses_Limit_Value__c = 10,
			Cart_Over_Value__c = 1,
			Product__c = NULL
		);
		insert new List<Coupon__c>{coupon1,coupon2};

		Coupon_Uses__c couponUses1 = new Coupon_Uses__c(
			Coupon__c = coupon1.Id,
			Uses__c = 5
		);
		insert couponUses1;

		Coupon__c getCoupon = CouponHelper.getCouponByCouponCode('coupon1');
		System.assertEquals(coupon1.Id, getCoupon.Id);
		System.assertEquals(coupon1.Discount_Amount__c, getCoupon.Discount_Amount__c);
		System.assertEquals(coupon1.Coupon_Code__c, getCoupon.Coupon_Code__c);
		System.assertEquals(coupon1.Start_Date__c, getCoupon.Start_Date__c);
		System.assertEquals(coupon1.End_Date__c, getCoupon.End_Date__c);
		System.assertEquals(coupon1.Uses_Limit__c, getCoupon.Uses_Limit__c);
		System.assertEquals(coupon1.Status__c, getCoupon.Status__c);
		System.assertEquals(coupon1.Discount_Type__c, getCoupon.Discount_Type__c);
		System.assertEquals(coupon1.Uses_Limit_Value__c, getCoupon.Uses_Limit_Value__c);
		System.assertEquals(coupon1.New_Customer__c, getCoupon.New_Customer__c);
		System.assertEquals(coupon1.Product__c, getCoupon.Product__c);
		System.assertEquals(coupon1.Cart_Over_Value__c, getCoupon.Cart_Over_Value__c);

		System.assertEquals(NULL, CouponHelper.getCouponByCouponCode(coupon2.Id));
	}

	// test method name: checkGetCouponByCouponId
	// created: 01/26/2018
	// Author: Stanislau Yarashchuk
	// Check method getCouponByCouponId
	@isTest static void checkGetCouponByCouponId(){ 
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account account1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName1', LastName = 'lastName1', Phone = '9876543211', 
			PersonEmail = 'test@test1.com'
		);
		Account account2 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName2', LastName = 'lastName2', Phone = '9876543212', 
			PersonEmail = 'test@test2.com'
		);
		insert new List<Account>{account1,account2};

		Coupon__c coupon1 = new Coupon__c(
			Coupon_Code__c = 'coupon1',
			Description__c = 'test coupon1',
			Discount_Amount__c = 10,
			Discount_Type__c = '$ Off',
			End_Date__c = Date.today().addDays(30),
			Start_Date__c = Date.today().addDays(-2),
			New_Customer__c = true,
			Status__c = 'Active',
			Uses_Limit__c = 'Overall',
			Uses_Limit_Value__c = 10,
			Cart_Over_Value__c = 1
		);
		Coupon__c coupon2 = new Coupon__c(
			Coupon_Code__c = 'coupon2',
			Description__c = 'test coupon1',
			Discount_Amount__c = 10,
			Discount_Type__c = '$ Off',
			End_Date__c = Date.today().addDays(30),
			Start_Date__c = Date.today().addDays(10),
			New_Customer__c = true,
			Status__c = 'Active',
			Uses_Limit__c = 'Overall',
			Uses_Limit_Value__c = 10,
			Cart_Over_Value__c = 1,
			Product__c = NULL
		);
		insert new List<Coupon__c>{coupon1,coupon2};

		Coupon_Uses__c couponUses1 = new Coupon_Uses__c(
			Coupon__c = coupon1.Id,
			Uses__c = 5
		);
		insert couponUses1;
		
		Coupon__c getCoupon = CouponHelper.getCouponByCouponId(coupon1.Id);
		System.assertEquals(coupon1.Id, getCoupon.Id);
		System.assertEquals(coupon1.Discount_Amount__c, getCoupon.Discount_Amount__c);
		System.assertEquals(coupon1.Coupon_Code__c, getCoupon.Coupon_Code__c);
		System.assertEquals(coupon1.Start_Date__c, getCoupon.Start_Date__c);
		System.assertEquals(coupon1.End_Date__c, getCoupon.End_Date__c);
		System.assertEquals(coupon1.Uses_Limit__c, getCoupon.Uses_Limit__c);
		System.assertEquals(coupon1.Status__c, getCoupon.Status__c);
		System.assertEquals(coupon1.Discount_Type__c, getCoupon.Discount_Type__c);
		System.assertEquals(coupon1.Uses_Limit_Value__c, getCoupon.Uses_Limit_Value__c);
		System.assertEquals(coupon1.New_Customer__c, getCoupon.New_Customer__c);
		System.assertEquals(coupon1.Product__c, getCoupon.Product__c);
		System.assertEquals(coupon1.Cart_Over_Value__c, getCoupon.Cart_Over_Value__c);

		System.assertEquals(NULL, CouponHelper.getCouponByCouponId(coupon2.Id));
	}

	// test method name: checkAddCouponData
	// created: 01/26/2018
	// Author: Stanislau Yarashchuk
	// Check method addCouponData
	@isTest static void checkAddCouponData(){ 

		Order__c order1 = new Order__c();
		insert order1;

		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account account1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName1', LastName = 'lastName1', Phone = '9876543211', 
			PersonEmail = 'test@test1.com'
		);
		Account account2 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName2', LastName = 'lastName2', Phone = '9876543212', 
			PersonEmail = 'test@test2.com'
		);
		insert new List<Account>{account1,account2};

		Coupon__c coupon1 = new Coupon__c(
			Coupon_Code__c = 'coupon1',
			Description__c = 'test coupon1',
			Discount_Amount__c = 10,
			Discount_Type__c = '$ Off',
			End_Date__c = Date.today().addDays(30),
			Start_Date__c = Date.today().addDays(-2),
			New_Customer__c = true,
			Status__c = 'Active',
			Uses_Limit__c = 'Overall',
			Uses_Limit_Value__c = 10,
			Cart_Over_Value__c = 1
		);
		Coupon__c coupon2 = new Coupon__c(
			Coupon_Code__c = 'coupon2',
			Description__c = 'test coupon1',
			Discount_Amount__c = 10,
			Discount_Type__c = '$ Off',
			End_Date__c = Date.today().addDays(30),
			Start_Date__c = Date.today().addDays(10),
			New_Customer__c = true,
			Status__c = 'Active',
			Uses_Limit__c = 'Overall',
			Uses_Limit_Value__c = 10,
			Cart_Over_Value__c = 1,
			Product__c = NULL
		);
		insert new List<Coupon__c>{coupon1,coupon2};

		Coupon_Uses__c couponUses1 = new Coupon_Uses__c(
			Coupon__c = coupon1.Id,
			Uses__c = 5
		);
		insert couponUses1;

		CouponHelper.createCouponOrders(order1.Id, new List<Id>{coupon1.Id, coupon2.Id});

		System.assertEquals(5, CouponHelper.getCouponUsesByCouponId(coupon1.Id).Uses__c);
		System.assertEquals(0, CouponHelper.getCouponCustomersByIds(coupon1.Id, account1.Id).size());

		CouponHelper.addCouponData(order1.Id, account1.Id);
		System.assertEquals(6, CouponHelper.getCouponUsesByCouponId(coupon1.Id).Uses__c);
		System.assertEquals(1, CouponHelper.getCouponCustomersByIds(coupon1.Id, account1.Id).size());
	}

	// test method name: checkCouponProduct
	// created: 02/02/2018
	// Author: Stanislau Yarashchuk
	// Check method getCouponProductByBrand
	@isTest static void checkCouponProduct(){ 
		Product2 couponProduct1 = CouponHelper.getCouponProductByBrand('Winter');
		Product2 couponProduct2 = CouponHelper.getCouponProductByBrand('Spring');
		System.assertEquals('Coupon', couponProduct1.Name);
		System.assertEquals('Winter', couponProduct1.Family);
		System.assertEquals('Coupon', couponProduct2.Name);
		System.assertEquals('Spring', couponProduct2.Family);

		Product2 couponProduct3 = CouponHelper.getCouponProductByBrand('Spring');
		System.assertEquals(couponProduct2.Id, couponProduct3.Id);
		System.assertEquals('Spring', couponProduct3.Family);
	}

	// test method name: checkCouponProductVariant
	// created: 02/02/2018
	// Author: Stanislau Yarashchuk
	// Check method checkCouponProductVariant
	@isTest static void checkCouponProductVariant(){ 
		Product2 couponProduct1 = CouponHelper.getCouponProductByBrand('Winter');
		System.assertEquals('Coupon', couponProduct1.Name);
		System.assertEquals('Winter', couponProduct1.Family);

		Coupon__c coupon1 = new Coupon__c(
			Name = 'test coupon',
			Coupon_Code__c = 'coupon1',
			Description__c = 'test coupon1',
			Discount_Amount__c = 10,
			Discount_Type__c = '$ Off',
			End_Date__c = Date.today().addDays(30),
			Start_Date__c = Date.today().addDays(-2),
			New_Customer__c = true,
			Status__c = 'Active',
			Uses_Limit__c = 'Overall',
			Uses_Limit_Value__c = 10,
			Cart_Over_Value__c = 1
		);
		insert coupon1;

		Product_Variant__c productVariant = CouponHelper.getCouponProductVariant(couponProduct1.Id, coupon1.Name);
		System.assertEquals(couponProduct1.Id, productVariant.Product__c);
		System.assertEquals(coupon1.Name, productVariant.Name);

	}	

}