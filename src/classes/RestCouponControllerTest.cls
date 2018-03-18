@isTest
public class RestCouponControllerTest {

	/* test method for if every thing is ok  */
	@isTest static void testgetCouponDiscount(){        
		
		Product2 p = new Product2();
		p.Name = 'test';
		p.ProductCode = 'DSX';
		p.IsActive = true;
		insert p;
		String productId  = p.Id;
		
		Coupon__c coupon = new Coupon__c();
		coupon.Discount_Amount__c = 20;
		coupon.Discount_Type__c = '% Off';
		
		date startDate = date.parse('01/01/2015');
		date endtDate = date.parse('12/01/2016');
		
		coupon.Start_Date__c = startDate;
		coupon.End_Date__c = endtDate;
		coupon.Product__c =  p.Id;
		coupon.Visible_Name__c = 'dxdev';
		coupon.Uses_Limit_Value__c = 100;
		insert coupon; 
		productId = productId.substring(0,15);                
		String result = RestCouponController.getCouponDiscount('dxdev','11/11/2015',productId);
		System.assertEquals('{"value":"20","type":"% Off","productId":"'+productId+'"}', result);
	}
	
	/* test method for if coupon is expired  */
	@isTest static void testgetCouponDiscount1(){        
		
		Product2 p = new Product2();
		p.Name = 'test';
		p.ProductCode = 'DSX';
		p.IsActive = true;
		insert p;
		String productId  = p.Id;
		
		Coupon__c coupon = new Coupon__c();
		coupon.Discount_Amount__c = 20;
		coupon.Discount_Type__c = '% Off';
		
		date startDate = date.parse('01/01/2015');
		date endtDate = date.parse('12/01/2016');
		
		coupon.Start_Date__c = startDate;
		coupon.End_Date__c = endtDate;
		coupon.Product__c =  p.Id;
		coupon.Visible_Name__c = 'dxdev';
		coupon.Uses_Limit_Value__c = 100;
		insert coupon; 
				
		String result = RestCouponController.getCouponDiscount('dxdev','11/11/2010',productId);
		System.assertEquals('invalid Coupon', result);
	}
	
	/* test method for if coupon code is invalid or  coupon not available for current product */
	@isTest static void testgetCouponDiscount2(){        

		Product2 p = new Product2();
		p.Name = 'test';
		p.ProductCode = 'DSX';
		p.IsActive = true;
		insert p;
		String productId  = p.Id;
		
		Coupon__c coupon = new Coupon__c();
		coupon.Discount_Amount__c = 20;
		coupon.Discount_Type__c = '% Off';
		
		date startDate = date.parse('01/01/2015');
		date endtDate = date.parse('12/01/2016');
		
		coupon.Start_Date__c = startDate;
		coupon.End_Date__c = endtDate;
		coupon.Product__c =  p.Id;
		coupon.Visible_Name__c = 'dxdev';
		coupon.Uses_Limit_Value__c = 100;
		insert coupon; 
				
		String result = RestCouponController.getCouponDiscount('dxdev','11/11/2015','ASDFGHJKLASDFGHJKLMNBVCXZ');
		System.assertEquals('Coupon is not available for this product.', result);
	}

	// test method name: overallTest
	// created: 01/25/2018
	// Author: Stanislau Yarashchuk
	// positive test Dollar Off and Overall
	@isTest static void overallTest(){  
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		//success
		Account account1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName1', LastName = 'lastName1', Phone = '9876543210', 
			PersonEmail = 'test@test1.com'
		);
		insert account1;

		Coupon__c coupon1 = new Coupon__c(
			Coupon_Code__c = 'coupon1',
			Description__c = 'test coupon1',
			Discount_Amount__c = 10,
			Discount_Type__c = '$ Off',
			End_Date__c = Date.today().addDays(30),
			Start_Date__c = Date.today().addDays(-2),
			New_Customer__c = false,
			Status__c = 'Active',
			Uses_Limit__c = 'Overall',
			Uses_Limit_Value__c = 1
		);
		insert coupon1;

		Coupon_Uses__c couponUses1 = new Coupon_Uses__c(
			Coupon__c = coupon1.Id,
			Uses__c = 0
		);
		insert couponUses1;

		Map<String,String> data = new Map<String,String>();
		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		String result = RestCouponController.getCoupon(data);
		Map<String,Object> couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);
		Map<String,Object> couponMap = (Map<String,Object>)couponResult.get('coupon');

		System.assertEquals('success', couponResult.get('message'));
		System.assertEquals(coupon1.Id, (String)couponMap.get('id'));
		System.assertEquals(10, (Decimal)couponMap.get('discount'));
		System.assertEquals(coupon1.Discount_Type__c, (String)couponMap.get('type'));
		System.assertEquals(coupon1.Uses_Limit__c, (String)couponMap.get('usesLimit'));


		coupon1.Discount_Type__c = 'Discount %';
		coupon1.Discount_Amount__c = 20;
		update coupon1;

		data = new Map<String,String>();
		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		result = RestCouponController.getCoupon(data);
		couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);
		couponMap = (Map<String,Object>)couponResult.get('coupon');

		System.assertEquals('success', couponResult.get('message'));
		System.assertEquals(coupon1.Id, (String)couponMap.get('id'));
		System.assertEquals(200, (Decimal)couponMap.get('discount'));
		System.assertEquals(coupon1.Discount_Type__c, (String)couponMap.get('type'));
		System.assertEquals(coupon1.Uses_Limit__c, (String)couponMap.get('usesLimit'));


		//errors
		coupon1.Status__c = 'InActive';
		update coupon1;

		data = new Map<String,String>();
		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		result = RestCouponController.getCoupon(data);
		couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);

		System.assertEquals('error', couponResult.get('message'));
		System.assertEquals('Coupon was not found', couponResult.get('error'));

		coupon1.Status__c = 'Active';
		coupon1.Start_Date__c = Date.today().addDays(10);
		update coupon1;

		couponUses1.Uses__c = 1;
		update couponUses1;

		data = new Map<String,String>();
		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		result = RestCouponController.getCoupon(data);
		couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);

		System.assertEquals('error', couponResult.get('message'));
		System.assertEquals('Coupon was not found', couponResult.get('error'));

		coupon1.Start_Date__c = Date.today().addDays(-2);
		update coupon1;

		couponUses1.Uses__c = 1;
		update couponUses1;

		data = new Map<String,String>();
		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		result = RestCouponController.getCoupon(data);
		couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);

		System.assertEquals('error', couponResult.get('message'));
		System.assertEquals('Coupon using Limit is exceeded', couponResult.get('error'));


	}

	// test method name: perCustomerTest
	// created: 01/25/2018
	// Author: Stanislau Yarashchuk
	// positive test Dollar Off and Overall
	@isTest static void perCustomerTest(){  
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];

		//success
		Account account1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName1', LastName = 'lastName1', Phone = '9876543210', 
			PersonEmail = 'test@test1.com'
		);
		insert account1;

		Coupon__c coupon1 = new Coupon__c(
			Coupon_Code__c = 'coupon1',
			Description__c = 'test coupon1',
			Discount_Amount__c = 10,
			Discount_Type__c = '$ Off',
			End_Date__c = Date.today().addDays(30),
			Start_Date__c = Date.today().addDays(-2),
			New_Customer__c = false,
			Status__c = 'Active',
			Uses_Limit__c = 'Per Customer',
			Uses_Limit_Value__c = 1
		);
		insert coupon1;

		Map<String,String> data = new Map<String,String>();
		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		String result = RestCouponController.getCoupon(data);
		Map<String,Object> couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);
		Map<String,Object> couponMap = (Map<String,Object>)couponResult.get('coupon');

		System.assertEquals('success', couponResult.get('message'));
		System.assertEquals(coupon1.Id, (String)couponMap.get('id'));
		System.assertEquals(10, (Decimal)couponMap.get('discount'));
		System.assertEquals(coupon1.Discount_Type__c, (String)couponMap.get('type'));
		System.assertEquals(coupon1.Uses_Limit__c, (String)couponMap.get('usesLimit'));


		coupon1.Discount_Type__c = 'Discount %';
		coupon1.Discount_Amount__c = 20;
		update coupon1;

		data = new Map<String,String>();
		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		result = RestCouponController.getCoupon(data);
		couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);
		couponMap = (Map<String,Object>)couponResult.get('coupon');

		System.assertEquals('success', couponResult.get('message'));
		System.assertEquals(coupon1.Id, (String)couponMap.get('id'));
		System.assertEquals(200, (Decimal)couponMap.get('discount'));
		System.assertEquals(coupon1.Discount_Type__c, (String)couponMap.get('type'));
		System.assertEquals(coupon1.Uses_Limit__c, (String)couponMap.get('usesLimit'));


		//errors
		coupon1.Status__c = 'InActive';
		update coupon1;

		data = new Map<String,String>();
		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		result = RestCouponController.getCoupon(data);
		couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);

		System.assertEquals('error', couponResult.get('message'));
		System.assertEquals('Coupon was not found', couponResult.get('error'));

		coupon1.Status__c = 'Active';
		coupon1.Start_Date__c = Date.today().addDays(10);
		update coupon1;

		data = new Map<String,String>();
		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		result = RestCouponController.getCoupon(data);
		couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);

		System.assertEquals('error', couponResult.get('message'));
		System.assertEquals('Coupon was not found', couponResult.get('error'));

		coupon1.Start_Date__c = Date.today().addDays(-2);
		update coupon1;

		Coupon_Customer__c couponCustomer = new Coupon_Customer__c(
			Coupon__c = coupon1.Id,
			Account__c = account1.Id
		);
		insert couponCustomer;

		data = new Map<String,String>();
		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		result = RestCouponController.getCoupon(data);
		couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);

		System.assertEquals('error', couponResult.get('message'));
		System.assertEquals('Coupon using Limit is exceeded', couponResult.get('error'));


	}

	// test method name: testParams
	// created: 01/25/2018
	// Author: Stanislau Yarashchuk
	// test params
	@isTest static void testParams(){ 
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account account1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName1', LastName = 'lastName1', Phone = '9876543210', 
			PersonEmail = 'test@test1.com'
		);
		insert account1;

		Coupon__c coupon1 = new Coupon__c(
			Coupon_Code__c = 'coupon1',
			Description__c = 'test coupon1',
			Discount_Amount__c = 10,
			Discount_Type__c = '$ Off',
			End_Date__c = Date.today().addDays(30),
			Start_Date__c = Date.today().addDays(-2),
			New_Customer__c = false,
			Status__c = 'Active',
			Uses_Limit__c = 'Overall',
			Uses_Limit_Value__c = 1
		);
		insert coupon1;

		Coupon_Uses__c couponUses1 = new Coupon_Uses__c(
			Coupon__c = coupon1.Id,
			Uses__c = 0
		);
		insert couponUses1;

		Map<String,String> data = new Map<String,String>();
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		String result = RestCouponController.getCoupon(data);
		Map<String,Object> couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);
		Map<String,Object> couponMap = (Map<String,Object>)couponResult.get('coupon');

		System.assertEquals('error', couponResult.get('message'));
		System.assertEquals('Please enter coupon code', couponResult.get('error'));

		data.put('couponCode', '');
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		result = RestCouponController.getCoupon(data);
		couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);
		couponMap = (Map<String,Object>)couponResult.get('coupon');

		System.assertEquals('error', couponResult.get('message'));
		System.assertEquals('Please enter coupon code', couponResult.get('error'));


		data.put('couponCode', coupon1.Coupon_Code__c);
		data.remove('amount');
		data.put('accountId', account1.Id);
		result = RestCouponController.getCoupon(data);
		couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);
		couponMap = (Map<String,Object>)couponResult.get('coupon');

		System.assertEquals('error', couponResult.get('message'));
		System.assertEquals('Please enter amount', couponResult.get('error'));

		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '');
		data.put('accountId', account1.Id);
		result = RestCouponController.getCoupon(data);
		couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);
		couponMap = (Map<String,Object>)couponResult.get('coupon');

		System.assertEquals('error', couponResult.get('message'));
		System.assertEquals('Invalid decimal: ', couponResult.get('error'));


		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.remove('accountId');
		result = RestCouponController.getCoupon(data);
		couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);
		couponMap = (Map<String,Object>)couponResult.get('coupon');

		System.assertEquals('error', couponResult.get('message'));
		System.assertEquals('Please enter account Id', couponResult.get('error'));

		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.put('accountId', '');
		result = RestCouponController.getCoupon(data);
		couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);
		couponMap = (Map<String,Object>)couponResult.get('coupon');

		System.assertEquals('error', couponResult.get('message'));
		System.assertEquals('Invalid id: ', couponResult.get('error'));

	}

	// test method name: checkNewCustomer
	// created: 01/25/2018
	// Author: Stanislau Yarashchuk
	// Check New Customer
	@isTest static void checkNewCustomer(){ 
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account account1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName1', LastName = 'lastName1', Phone = '9876543210', 
			PersonEmail = 'test@test1.com'
		);
		insert account1;

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
			Uses_Limit_Value__c = 1
		);
		insert coupon1;

		Coupon_Uses__c couponUses1 = new Coupon_Uses__c(
			Coupon__c = coupon1.Id,
			Uses__c = 0
		);
		insert couponUses1;

		Map<String,String> data = new Map<String,String>();
		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		String result = RestCouponController.getCoupon(data);
		Map<String,Object> couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);
		Map<String,Object> couponMap = (Map<String,Object>)couponResult.get('coupon');

		System.assertEquals('success', couponResult.get('message'));
		System.assertEquals(coupon1.Id, (String)couponMap.get('id'));
		System.assertEquals(10, (Decimal)couponMap.get('discount'));
		System.assertEquals(coupon1.Discount_Type__c, (String)couponMap.get('type'));
		System.assertEquals(coupon1.Uses_Limit__c, (String)couponMap.get('usesLimit'));

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

		data = new Map<String,String>();
		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		result = RestCouponController.getCoupon(data);
		couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);
		couponMap = (Map<String,Object>)couponResult.get('coupon');

		System.assertEquals('error', couponResult.get('message'));
		System.assertEquals('This coupon only for new customers', couponResult.get('error'));
	}

	// test method name: checkCartOverValue	
	// created: 01/26/2018
	// Author: Stanislau Yarashchuk
	// Check Cart Over Value
	@isTest static void checkCartOverValue(){ 
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account account1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName1', LastName = 'lastName1', Phone = '9876543210', 
			PersonEmail = 'test@test1.com'
		);
		insert account1;

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

		Map<String,String> data = new Map<String,String>();
		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		String result = RestCouponController.getCoupon(data);
		Map<String,Object> couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);
		Map<String,Object> couponMap = (Map<String,Object>)couponResult.get('coupon');

		System.assertEquals('success', couponResult.get('message'));
		System.assertEquals(coupon1.Id, (String)couponMap.get('id'));
		System.assertEquals(10, (Decimal)couponMap.get('discount'));
		System.assertEquals(coupon1.Discount_Type__c, (String)couponMap.get('type'));
		System.assertEquals(coupon1.Uses_Limit__c, (String)couponMap.get('usesLimit'));

		coupon1.Cart_Over_Value__c = 10000;
		update coupon1;

		data = new Map<String,String>();
		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		result = RestCouponController.getCoupon(data);
		couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);
		couponMap = (Map<String,Object>)couponResult.get('coupon');

		System.assertEquals('error', couponResult.get('message'));
		System.assertEquals('Not reached the minimum amount for use this coupon', couponResult.get('error'));
	}

	// test method name: checkAutoApply	
	// created: 01/30/2018
	// Author: Stanislau Yarashchuk
	// Check Auto Apply logic
	@isTest static void checkAutoApply(){ 
		RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
		Account account1 = new Account(
			RecordTypeId = customerRecordType.Id,
			FirstName = 'firstName1', LastName = 'lastName1', Phone = '9876543210', 
			PersonEmail = 'test@test1.com'
		);
		insert account1;

		Coupon__c coupon1 = new Coupon__c(
			Coupon_Code__c = NULL,
			Description__c = 'test coupon1',
			Discount_Amount__c = 10,
			Discount_Type__c = '$ Off',
			End_Date__c = Date.today().addDays(30),
			Start_Date__c = Date.today().addDays(-2),
			New_Customer__c = true,
			Status__c = 'Active',
			Uses_Limit__c = 'Overall',
			Uses_Limit_Value__c = 1,
			Cart_Over_Value__c = 1,
			Auto_Apply__c = TRUE
		);
		insert coupon1;

		Coupon_Uses__c couponUses1 = new Coupon_Uses__c(
			Coupon__c = coupon1.Id,
			Uses__c = 0
		);
		insert couponUses1;

		Map<String,String> data = new Map<String,String>();
		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		data.put('autoApply', 'TRUE');
		String result = RestCouponController.getCoupon(data);
		Map<String,Object> couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);
		Map<String,Object> couponMap = (Map<String,Object>)couponResult.get('coupon');

		System.assertEquals('success', couponResult.get('message'));
		System.assertEquals(coupon1.Id, (String)couponMap.get('id'));
		System.assertEquals(10, (Decimal)couponMap.get('discount'));
		System.assertEquals(coupon1.Discount_Type__c, (String)couponMap.get('type'));
		System.assertEquals(coupon1.Uses_Limit__c, (String)couponMap.get('usesLimit'));

		coupon1.Auto_Apply__c = FALSE;
		update coupon1;

		data = new Map<String,String>();
		data.put('couponCode', coupon1.Coupon_Code__c);
		data.put('amount', '1000');
		data.put('accountId', account1.Id);
		data.put('autoApply', 'TRUE');
		result = RestCouponController.getCoupon(data);
		couponResult = (Map<String, Object>)JSON.deserializeUntyped(result);
		couponMap = (Map<String,Object>)couponResult.get('coupon');

		System.assertEquals('error', couponResult.get('message'));
		System.assertEquals('Error coupon', couponResult.get('error'));
	}
}