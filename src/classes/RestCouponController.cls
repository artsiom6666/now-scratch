public with sharing class RestCouponController {

	public static String getCouponDiscount(String couponCode, String orederDate, String productId){
		String result;
		Date couponDate = Date.parse(orederDate);

		try {
			SFDCAccessController.AccessibleWithoutSharing (
				'Coupon__c',
				'NewOrderProcessController.cls [getVariants]',
				new List<Schema.DescribeFieldResult> {
					Coupon__c.Id.getDescribe(), Coupon__c.Product__c.getDescribe(),
					Coupon__c.Discount_Type__c.getDescribe(), Coupon__c.Discount_Type__c.getDescribe(),
					Coupon__c.Discount_Amount__c.getDescribe(), Coupon__c.Start_Date__c.getDescribe(),
					Coupon__c.End_Date__c.getDescribe()
				}
			);

			List<Coupon__c> cRecord = [SELECT Id, Product__c, Discount_Type__c, Discount_Amount__c, Start_Date__c, End_Date__c
				FROM Coupon__c
				WHERE Visible_Name__c =:couponCode
				AND Start_Date__c <:couponDate
				AND End_Date__c >:couponDate
			];
			if (cRecord.isEmpty()) {
				/* Coupon not found or coupon is expired */
				result = 'invalid Coupon';
			} else {
				String pID = cRecord[0].Product__c;
				pID = pID.substring(0,15);
				if (!productId.contains(pID)) {
					/* Coupon is not available for this product */
					result = 'Coupon is not available for this product.';
				} else {
					/* Create Json of discount type and discount value */
					Decimal amount = cRecord[0].Discount_Amount__c;
					String myAmount = string.valueof(amount);
					Map<String, String> data = new Map<String, String>{'productId'=>pID, 'type' => cRecord[0].Discount_Type__c, 'value' => myAmount };
					result = JSON.serialize(data);
				}
			}
		}
		catch (Exception e) {throw new SFDCAccessControlException();}

		return result;
	}

	// rest method name: getCoupon
	// created: 01/24/2018
	// Author: Stanislau Yarashchuk
	// calculate discount and return information about Discount
	public static String getCoupon(Map<String, String> generalData){
		try{

			// required params
			String couponCode = generalData.containsKey('couponCode') ? String.valueOf(generalData.get('couponCode')) : null;
			Decimal amount = generalData.containsKey('amount') ? Decimal.valueOf(generalData.get('amount')) : null;
			Id accountId = generalData.containsKey('accountId') ? Id.valueOf(generalData.get('accountId')) : null;
			String brand = generalData.containsKey('brand') ? String.valueOf(generalData.get('brand')) : null;

			// optional params
			String autoApply = generalData.containsKey('autoApply') ? String.valueOf(generalData.get('autoApply')) : null;

			// Check input parameters
			if (String.isBlank(couponCode) && (autoApply == null || autoApply == 'FALSE')) { return '{"error":"Please enter coupon code","message":"error"}'; }
			if (amount == null) { return '{"error":"Please enter amount","message":"error"}'; }
			if (accountId == null) { return '{"error":"Please enter account Id","message":"error"}'; }

			// Check coupon
			Coupon__c coupon = CouponHelper.getCouponByCouponCode(couponCode);
			if (coupon == NULL ) { return '{"error":"Coupon was not found","message":"error"}'; }

			// Check Auto-Apply
			if (autoApply == 'TRUE' && coupon.Auto_Apply__c == FALSE) {
				return '{"error":"Error coupon","message":"error"}';	
			}

			// Check New Customer
			if (coupon.New_Customer__c == TRUE && CouponHelper.isNewCustomer(accountId) == FALSE) {
				return '{"error":"This coupon only for new customers","message":"error"}';
			}

			// Check Uses Limit
			if (coupon.Uses_Limit__c == 'Overall' ) {
				Coupon_Uses__c couponUses = CouponHelper.getCouponUsesByCouponId(coupon.Id);
				if (couponUses != NULL && couponUses.Uses__c >= coupon.Uses_Limit_Value__c) {
					return '{"error":"Coupon using Limit is exceeded","message":"error"}';
				}
			}
			else if (coupon.Uses_Limit__c == 'Per Customer') {
				List<Coupon_Customer__c> couponCustomerList = CouponHelper.getCouponCustomersByIds(coupon.Id, accountId);
				if (!couponCustomerList.isEmpty() && couponCustomerList.size() >= coupon.Uses_Limit_Value__c) {
					return '{"error":"Coupon using Limit is exceeded","message":"error"}';
				}
			}

			// Check Cart Over Value	
			if ((coupon.Cart_Over_Value__c != NULL && coupon.Cart_Over_Value__c != 0) && coupon.Cart_Over_Value__c > amount) {
				return '{"error":"Not reached the minimum amount for use this coupon","message":"error"}';
			}

			// Check discount type and calculate discount
			Decimal discount = 0.00;
			if (coupon.Discount_Type__c == '$ Off' && coupon.Discount_Amount__c != NULL) {
				discount = coupon.Discount_Amount__c;
			}
			else if (coupon.Discount_Type__c == 'Discount %' && coupon.Discount_Amount__c != NULL) {
				discount = (amount * (coupon.Discount_Amount__c / 100)).setScale(2);
			}

			Product2 product = CouponHelper.getCouponProductByBrand(brand);
			Product_Variant__c productVariant = CouponHelper.getCouponProductVariant(product.Id, coupon.Name);

			// Create result map
			Map<String, Object> result = new Map<String, Object>();
			result.put('id', coupon.Id);
			result.put('discount', discount);
			result.put('type', coupon.Discount_Type__c);
			result.put('usesLimit', coupon.Uses_Limit__c);
			result.put('productId', product.Id);
			result.put('productVariantId', productVariant.Id);

			return JSON.serialize(new Map<String, Object>{
				'coupon' => result,
				'message' => 'success'
			});

		} catch (Exception e) {
			return '{"error":"' + e.getMessage() + '","message":"error"}'; 
		}
	}

}