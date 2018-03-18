({
	//METHODS FROM 1 STEP ====> 2 STEP (BEGINNING)
	
	checkValidEmail : function(email) {
		//email validation regular expression
		var validEmail = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/; 
		return validEmail.test(email);
	},
	
	getCountryPicklist : function(component) {
		//Call apex-controller method in order to get Country picklist
		var getCountryList = component.get("c.getAccountShippingCountryPicklist");
		getCountryList.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.shippingCountryPicklist", response.getReturnValue());
				component.set("v.billingCountryPicklist", response.getReturnValue());
			}
				
		});
		$A.enqueueAction(getCountryList);
	},
	
	getStatePickList : function(component) {
		var country = component.find("ShippingCountry").get("v.value");
		var getStateList = component.get("c.getAccountShippingStatePicklist");
		getStateList.setParams({
			"country" : country
		});
		getStateList.setCallback(this,function(response) {
		var state = response.getState();
			if(state === "SUCCESS") {
				var countryStateSet = response.getReturnValue();
				component.set('v.shippingStatePicklist', response.getReturnValue());
			}
		});
	$A.enqueueAction(getStateList);
		
	},
	
	findAccount : function(component, email) {

		//Call apex-controller method (getAccount) in order to check it is existing account or not
		var getAccount = component.get("c.getAccount");

		getAccount.setParams({
			"strEmail": email
		});

		getAccount.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.newAccount", response.getReturnValue());
				var newAccount = component.get("v.newAccount");
				if (newAccount.TouchCRBase__Blacklist__c == 'True') {
					component.find("addEmail").set("v.errors", [{message:"This Email Address is in black list"}]);
					component.set('v.showSpinner', false);
					return;
				}

				var shippingAddress = (newAccount.ShippingStreet === undefined) ? '' : newAccount.ShippingStreet + ', ';
				shippingAddress += (newAccount.ShippingCity === undefined) ? '' : newAccount.ShippingCity + ' ';
				shippingAddress += (newAccount.ShippingStateCode === undefined) ? '' : newAccount.ShippingStateCode + ' ';
				shippingAddress += (newAccount.ShippingPostalCode === undefined) ? '' : newAccount.ShippingPostalCode + ' ';
				shippingAddress += (newAccount.ShippingState === undefined) ? '' : newAccount.ShippingState;

				var billingAddress = (newAccount.BillingStreet === undefined) ? '' : newAccount.BillingStreet + ', ';
				billingAddress += (newAccount.BillingCity === undefined) ? '' : newAccount.BillingCity + ' ';
				billingAddress += (newAccount.BillingState === undefined) ? '' : newAccount.BillingState + ' ';
				billingAddress += (newAccount.BillingStateCode === undefined) ? '' : newAccount.BillingStateCode + ' ';
				billingAddress += (newAccount.BillingPostalCode === undefined) ? '' : newAccount.BillingPostalCode;

				component.set("v.shippingAddress", shippingAddress);
				component.set("v.billingAddress", billingAddress);
				if($A.util.isEmpty(component.get('v.shippingCountryPicklist'))) {
					document.getElementById('ShippingCountryEmpty').className = "slds-show";
					document.getElementById('ShippingCountry').className = "slds-hide";
					document.getElementById('ShippingState').className = "slds-hide";
					document.getElementById('ShippingStateEmpty').className = "slds-show";
				}
				component.find("ShippingCountry").set("v.value", newAccount.ShippingCountry);
				component.find("ShippingState").set("v.value", newAccount.ShippingState);
				component.find("ShippingCountryEmpty").set("v.value", newAccount.ShippingCountry);
				component.find("ShippingStateEmpty").set("v.value", newAccount.ShippingState);
				component.find("BillingCountry").set("v.value", newAccount.BillingCountry);
				component.find("BillingCountry").set("v.value", newAccount.BillingCountry);
				
				this.getStatePickList(component);  
							 

				if(newAccount.BillingStreet === newAccount.ShippingStreet && newAccount.BillingCity === newAccount.ShippingCity
				   && newAccount.BillingCountryCode === newAccount.ShippingCountryCode && newAccount.BillingPostalCode === newAccount.ShippingPostalCode) {
					component.set("v.sameBillingAddress", true);
				}
				else if($A.util.isEmpty(newAccount.BillingStreet) || $A.util.isEmpty(newAccount.BillingCity) || $A.util.isEmpty(newAccount.BillingCountryCode)
				   || $A.util.isEmpty(newAccount.BillingPostalCode)) {
					component.set("v.sameBillingAddress", false);
				}
				//If new customer Shipping Address is the same as Billing Address
				else if (newAccount.Id === undefined) {
					component.set("v.sameBillingAddress", true);
				}

				if (component.get("v.sameBillingAddress")) {
					document.getElementById("addressCheckbox").setAttribute("checked", true);
					document.getElementById("BillingAddressIsTheSame").className = "slds-hide";
				} else {
					document.getElementById("addressCheckbox").removeAttribute("checked");
					document.getElementById("BillingAddressIsTheSame").className = "slds-show";
				}

				//Call apex-controller method in order to get account brand picklist
				var getAccountBrandPicklist = component.get("c.getAccountBrandPicklist");
				getAccountBrandPicklist.setCallback(this, function(response2){
					var state2 = response2.getState();
					if (state2 === "SUCCESS") {
						component.set("v.brandPicklist", response2.getReturnValue());

						var brandPicklist = component.get("v.brandPicklist");
						var newAccount2 = component.get("v.newAccount");
						var brand = [];
						
						if (newAccount2.TouchCRBase__Brand_Assortment__c !== undefined) {
							brand[0] = newAccount2.TouchCRBase__Brand_Assortment__c;
							for (var i = 0; i < brandPicklist.length; i++) {
								if (brandPicklist[i] !== newAccount2.TouchCRBase__Brand_Assortment__c) {
									brand.push(brandPicklist[i]);
								}
							}
							component.set("v.brandPicklist", brand);
						}
					}
				});
				$A.enqueueAction(getAccountBrandPicklist);

			}
			this.showStep2(response.getReturnValue() != null);
			component.set('v.showSpinner', false);
		});
		$A.enqueueAction(getAccount);
	},
	//METHODS FROM 1 STEP ====> 2 STEP (ENDING)


	//METHODS FROM 2 STEP ====> 3 STEP (BEGINNING)
	inputFieldsValidation : function(component) {
		component.set("v.validData", true);

		//collect ids of all input fields
		var accountFields = ['FirstName', 'LastName', 'PersonEmail', 'Phone', 'ShippingAddress', 'BillingAddress', 
			'ShippingCountry','ShippingStreet', 'ShippingCity', 'ShippingPostalCode',
			'BillingCountry', 'BillingStreet', 'BillingCity', 'BillingPostalCode'];

		var accountDataTemp = [];
		var accountData = [];

		var accountsDataForUpsert = {};

		var sameBillingAddress = component.get("v.sameBillingAddress");

		var validEmail = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
		var validNames = /^[a-zA-Z-\s]{1,20}$/i;
		var validPhone = /^\d+$/i;
		var validAddress = /^[0-9a-zA-Z-\s-\.-\,]{1,124}$/;

		//If collected fields are blank then set error
		for (var i = 0; i < accountFields.length; i++) {
			accountDataTemp[i] = component.find(accountFields[i]);
			accountData[i] = accountDataTemp[i].get("v.value");

			if (i < 4) {
				accountsDataForUpsert[accountFields[i]] = accountData[i];
			}
		}
		var account = component.get("v.newAccount");
		if(!$A.util.isEmpty(component.get('v.shippingCountryPicklist'))) {
			account.ShippingCountry = component.find("ShippingCountry").get("v.value");
		}
		if($A.util.isEmpty(component.get('v.shippingCountryPicklist'))) {
			account.ShippingCountry = component.find("ShippingCountryEmpty").get("v.value");
		}
		if(!$A.util.isEmpty(component.get('v.shippingStatePicklist'))) {
			account.ShippingState = component.find("ShippingState").get("v.value");
		}
		if($A.util.isEmpty(component.get('v.shippingStatePicklist'))) {
			account.ShippingState = component.find("ShippingStateEmpty").get("v.value");
		}
		account.BillingCountry = component.find("BillingCountry").get("v.value");

		accountsDataForUpsert['Brand'] = value;
		
		accountsDataForUpsert['Id'] = account.Id;

		accountsDataForUpsert['ShippingStreet'] = account.ShippingStreet;
		accountsDataForUpsert['ShippingCity'] = account.ShippingCity;
		accountsDataForUpsert['ShippingPostalCode'] = account.ShippingPostalCode;
		if(!$A.util.isEmpty(component.get('v.shippingCountryPicklist'))) {
			accountsDataForUpsert['ShippingStateCode'] = account.ShippingStateCode;
			accountsDataForUpsert['ShippingCountryCode'] = account.ShippingCountryCode;
		}
		accountsDataForUpsert['ShippingCountry'] = account.ShippingCountry;
		accountsDataForUpsert['ShippingState'] = account.ShippingState;
		if (sameBillingAddress) {

			accountsDataForUpsert['BillingStreet'] = accountsDataForUpsert['ShippingStreet'];
			accountsDataForUpsert['BillingPostalCode'] = accountsDataForUpsert['ShippingPostalCode'];
			accountsDataForUpsert['BillingCity'] = accountsDataForUpsert['ShippingCity'];
			if(!$A.util.isEmpty(component.get('v.shippingCountryPicklist'))) {
				accountsDataForUpsert['BillingCountryCode'] = accountsDataForUpsert['ShippingCountryCode'];
				accountsDataForUpsert['BillingStateCode'] = accountsDataForUpsert['ShippingStateCode'];
			}
			accountsDataForUpsert['BillingCountry'] = accountsDataForUpsert['ShippingCountry'];
			accountsDataForUpsert['BillingState'] = accountsDataForUpsert['ShippingState'];
			
			accountData[5] = accountData[4];

			account.BillingStreet = account.ShippingStreet;
			account.BillingCity = account.ShippingCity;
			account.BillingPostalCode = account.ShippingPostalCode;
			if(!$A.util.isEmpty(component.get('v.shippingCountryPicklist'))) {
				account.BillingCountryCode = account.ShippingCountryCode;
				account.BillingStateCode = account.ShippingStateCode;
			}
			account.BillingCountry = account.ShippingCountry;
			account.BillingState = account.ShippingState;

		} else {
			accountsDataForUpsert['BillingStreet'] = account.BillingStreet;
			accountsDataForUpsert['BillingPostalCode'] = account.BillingPostalCode;
			if(!$A.util.isEmpty(component.get('v.shippingCountryPicklist'))) {
				accountsDataForUpsert['BillingStateCode'] = account.BillingStateCode;
				accountsDataForUpsert['BillingCountryCode'] = account.BillingCountryCode;
			}
			accountsDataForUpsert['BillingCity'] = account.BillingCity;
			accountsDataForUpsert['BillingCountry'] = account.BillingCountry;
			accountsDataForUpsert['BillingState'] = account.BillingState;
		}
		
		component.find("BillingCountry").set("v.value", account.BillingCountry); 

		var validData = component.get("v.validData");

		if(validData) {
			//Wrong input data checking start
			//accountDataTemp[0] = input FirstName
			if(!validNames.test(accountData[0]) && (accountData[0] !== "" || accountData[0] !== undefined)) {
				component.set("v.validData", false);
				accountDataTemp[0].set("v.errors", [{message:"You can use letters only"}]);
			} else {
				accountDataTemp[0].set("v.errors", null);
			}
			//accountDataTemp[1] = input LastName
			if(!validNames.test(accountData[1])) {
				component.set("v.validData", false);
				accountDataTemp[1].set("v.errors", [{message:"You can use letters only"}]);
			} else {
				accountDataTemp[1].set("v.errors", null);
			}

			//accountDataTemp[2] = input PersonEmail
			if(!validEmail.test(accountData[2])) {
				component.set("v.validData", false);
				accountDataTemp[2].set("v.errors", [{message:"Incorrect format of email address"}]);

			} else {
				accountDataTemp[2].set("v.errors", null);
			}

			//accountDataTemp[3] = input Phone
			if(!validPhone.test(accountData[3])) {
				component.set("v.validData", false);
				accountDataTemp[3].set("v.errors", [{message:"Incorrect format of phone number"}]);

			} else {
				accountDataTemp[3].set("v.errors", null);
			}

			//accountDataTemp[4] = input ShippingAddress
			if(!validAddress.test(accountData[4])) {
//                component.set("v.validData", false);
//                accountDataTemp[4].set("v.errors", [{message:"You can use letters, numbers, comas and dots only"}]);
			} else {
				accountDataTemp[4].set("v.errors", null);
			}

			//accountDataTemp[5] = input BillingAddress
			if(!validAddress.test(accountData[5])) {
//                component.set("v.validData", false);
//                accountDataTemp[5].set("v.errors", [{message:"You can use letters, numbers, comas and dots only"}]);
			} else {
				accountDataTemp[5].set("v.errors", null);
			}
		   
			if(!validAddress.test(accountData[6])) {
				component.set("v.validData", false);
				accountDataTemp[6].set("v.errors", [{message:"You can use letters, numbers, comas and dots only"}]);
			} else {
				accountDataTemp[6].set("v.errors", null);
			}
			
			if(!validAddress.test(accountData[7])) {
				component.set("v.validData", false);
				accountDataTemp[7].set("v.errors", [{message:"You can use letters, numbers, comas and dots only"}]);
			} else {
				accountDataTemp[7].set("v.errors", null);
			}
			
			if(!validAddress.test(accountData[8])) {
				component.set("v.validData", false);
				accountDataTemp[8].set("v.errors", [{message:"You can use letters, numbers, comas and dots only"}]);
			} else {
				accountDataTemp[8].set("v.errors", null);
			}
			
			if(!validAddress.test(accountData[9])) {
				component.set("v.validData", false);
				accountDataTemp[9].set("v.errors", [{message:"You can use letters, numbers, comas and dots only"}]);
			} else {
				accountDataTemp[9].set("v.errors", null);
			}
			
			if(!validAddress.test(accountData[10])) {
				component.set("v.validData", false);
				accountDataTemp[10].set("v.errors", [{message:"You can use letters, numbers, comas and dots only"}]);
			} else {
				accountDataTemp[10].set("v.errors", null);
			}
			
			if(!validAddress.test(accountData[11])) {
				component.set("v.validData", false);
				accountDataTemp[11].set("v.errors", [{message:"You can use letters, numbers, comas and dots only"}]);
			} else {
				accountDataTemp[11].set("v.errors", null);
			}
			
			if(!validAddress.test(accountData[12])) {
				component.set("v.validData", false);
				accountDataTemp[12].set("v.errors", [{message:"You can use letters, numbers, comas and dots only"}]);
			} else {
				accountDataTemp[12].set("v.errors", null);
			}
			
			if(!validAddress.test(accountData[13])) {
				component.set("v.validData", false);
				accountDataTemp[13].set("v.errors", [{message:"You can use letters, numbers, comas and dots only"}]);
			} else {
				accountDataTemp[13].set("v.errors", null);
			}

		}
		//Wrong input data checking end

		//Start to create correct picklist and account data and add them to account
		var brandPicklist = component.get("v.brandPicklist");

		var temp = component.find("Brand");
		var value = temp.get("v.value");

		if ($A.util.isEmpty(value)) {
			value = brandPicklist[0];
		}

		accountsDataForUpsert['Brand'] = value;
		//End of creating correct picklists and account data
		console.log(accountsDataForUpsert);
		component.set("v.accountsDataForUpsert", accountsDataForUpsert);
		console.log(component.get('v.accountsDataForUpsert'));
		component.set("v.newAccount", account);
		component.set("v.accountData", accountData);
	},

	createOrEditAccount : function(component) {

		var accountsDataForUpsert = component.get("v.accountsDataForUpsert");
		var saveAccount = component.get("c.saveAccount");

		saveAccount.setParams({
			"fieldsOfAccount" : accountsDataForUpsert
		});
		console.log(saveAccount);

		saveAccount.setCallback(this, function(response){
			var state = response.getState();
			console.log(state);
			if (state === "SUCCESS") {
				console.log(response.getReturnValue());
				component.set("v.newAccount", response.getReturnValue());
				var newAccount = component.get("v.newAccount");

				//Call apex-controller method (getVariants) in order to create list of all various products
				var getVariants = component.get("c.getVariants");

				getVariants.setParams({
					"newAccount" : newAccount
				});

				getVariants.setCallback(this, function(response2){
					var state2 = response2.getState();
					if (state2 === "SUCCESS") {
						component.set("v.nodes", response2.getReturnValue());
						this.showStep3(response2.getReturnValue() != null, component.get("v.nodes").length);
						component.set('v.showSpinner', false);
					}
				});
				$A.enqueueAction(getVariants);
			}
			else if (response.getReturnValue() === null){
				var nameField = document.getElementById("editContactDetails");

				document.getElementById("stepTwoBlock").className = "slds-hide";
				document.getElementById("btnStepTwoBlock").className = "slds-hide";
			}
		});
		$A.enqueueAction(saveAccount);
	},
	//METHODS FROM 2 STEP ====> 3 STEP (ENDING)

	//METHODS FROM 3 STEP ====> 4 STEP (BEGINNING)
	getTotalPrices : function(component) {
		var inputElemAmount = document.getElementsByClassName("slds-input amount");
		var amount = [];
		var products = component.get("v.nodes");
		var productsIds = [];

		var validData = /^[\d]*$/;

		for (var i=0; i < inputElemAmount.length; i++) {
			if (validData.test(inputElemAmount[i].value) && inputElemAmount[i].value !== "0" && inputElemAmount[i].value !== "") {
				var temp ={
					value : inputElemAmount[i].value,
					id : inputElemAmount[i].id
				};
				productsIds.push(temp.id);
				amount.push(temp);
				for (var n=0; n < products.length; n++) {
					if (products[n].id == inputElemAmount[i].id) {
						products[n].count = parseInt(inputElemAmount[i].value);
					}
				}
			}
		}
		
		
		component.set('v.nodes', products);
		var actionForInputElementAmount = component.get("c.getInputElementAmount");
		var amountJSONStringify = JSON.stringify(amount);
		var nodeJSONStringify = JSON.stringify(products);

		actionForInputElementAmount.setParams({
			"StandardInfoJSON" : amountJSONStringify,
			"NodeJSON" : nodeJSONStringify
		});

		//Take Account's values
		actionForInputElementAmount.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.price", response.getReturnValue());
				if (component.get('v.subtotalPrice') === 0) {
					component.set('v.subtotalPrice', component.get('v.price')[0]);
				}
				var productsIds = component.get('v.price')[1].split('~');
				var prodPrices = component.get('v.price')[4].split('~');
				var bumpOffers = component.get('v.bumpOffers');
				var newBumpOffers = [];

				for(var i = 0; i < productsIds.length; i++) {
					for(var n = 0; n < bumpOffers.length; n++) {
						if(bumpOffers[n].productId === productsIds[i]) {
							if(bumpOffers[n].oldPrice === undefined) {
								bumpOffers[n].oldPrice = prodPrices[i];
							}
							newBumpOffers.push(bumpOffers[n]);
						}
					}
				}

				component.set('v.bumpOffers', newBumpOffers);
				var price = component.get("v.price");
				this.showStep4(price[0] != "0");
				component.set('v.showSpinner', false);
				component.set("v.autoApply", "true");
				if(component.get('v.couponDiscount') === 0){
					this.validateCouponCode(component);
				}
				if(component.get('v.couponDiscount') != 0) {
					var couponDiscOld = component.get('v.couponDiscount');
					var totalAmount = component.get('v.price[0]') - couponDiscOld;
					component.set('v.price[0]', totalAmount);
				}
				component.set("v.autoApply", "false");
			} 
		});
		$A.enqueueAction(actionForInputElementAmount);
	},
	//METHODS FROM 3 STEP ====> 4 STEP (ENDING)

	//METHODS FROM 4 STEP ====> 5 STEP (BEGINNING)

	creditCardChecking : function(component) {
		var accountValues = component.get("v.newAccount");
		var accountId = accountValues.Id;

		var checkOldCreditCard = component.get("c.checkOldCreditCard");

		function getExperationYears () {
			var currentYear = new Date().getFullYear(), years = [];
			var endYear = new Date();
			endYear.setFullYear(currentYear + 10)
			endYear = endYear.getFullYear();

			while ( currentYear <= endYear ) {
				  years.push('' + currentYear++);
			}

			return years;
		}

		function setExperationMonths () {

			var months = [];
			var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

			for (var i = 0; i < 12; i++) {
				months.push(monthNames[i]);
			}

			var curMonth = new Date().getMonth();

			for (var i = 0; i < curMonth; i++) {
				months.shift();
			}

			component.set("v.experationMonths", months);
			component.set("v.experationMonthValue", monthNames[12 - months.length]);
		}

		var experationYears = getExperationYears();

		component.set("v.experationYears", experationYears);
		component.set("v.experationYearValue", new Date().getFullYear());
		setExperationMonths();

		checkOldCreditCard.setParams({
			"accountId" : accountId
		});

		checkOldCreditCard.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {

				component.set("v.checkOldCreditCardResult", response.getReturnValue());

				var showOrNotPreviousCard = response.getReturnValue();
				if (showOrNotPreviousCard[0] != 'notShowPreviousCard' && showOrNotPreviousCard[0] != 'Not found Gateway') {
					component.set("v.usePreviousCard", true);
				}
				this.showStep5(component.get("v.usePreviousCard"));
				component.set('v.showSpinner', false);

			}
		});
		$A.enqueueAction(checkOldCreditCard);
	},
	//METHODS FROM 4 STEP ====> 5 STEP (ENDING)

	//METHODS FROM 5 STEP ====> 6 STEP (BEGINNING)
	withOldCardDataCreation : function(component) {
		component.set('v.showSpinner', true);
		
		var price = component.get("v.price");
		var account = component.get("v.newAccount");
		var checkOldCreditCardResult = component.get("v.checkOldCreditCardResult");
		var shippingList = component.get("v.shippingList");
		var couponDiscount = - component.get("v.couponDiscount");
		var nodes = JSON.stringify(component.get("v.nodes"));
		var coupons = component.get('v.coupons');
		var boffers = component.get("v.bumpOffers");
		var bOffers_ids = [];
		var quantityBump = [];
		var couponsObj = component.get('v.couponsObj');
		for(var i = 0; i < boffers.length; i++) {
			if(boffers[i].count != 0) {
			bOffers_ids.push(boffers[i].id);
			quantityBump.push(boffers[i].count);
			}
		}
		var orderFormData = {
			product_id : price[1],
			email : account.PersonEmail,
			fname : account.FirstName,
			lname : account.LastName,
			phone : account.Phone,
			cc_number : '',
			security_code : '',
			cc_id : checkOldCreditCardResult[2] ,
			cc_type : '',
			tax : price[6],
			subtotal : price[7],
			couponDiscount : couponDiscount,
			total : (price[0] - couponDiscount),
			shipping : '0',
			quantity : price[3],
			offerprice : price[4],
//			gst : price[5],
			token : checkOldCreditCardResult[3],
			brand: account.TouchCRBase__Brand_Assortment__c,
			nodes: nodes,
			coupon_id: coupons,
			bumpOffers_id: bOffers_ids,
			quantityBump: quantityBump,
		};

		var payment = component.get("c.payment");
		component.set("v.orderFormData", orderFormData);

		var orderFormDataJSONStringify = JSON.stringify(orderFormData);

		payment.setParams({
			"newOrderForm" : orderFormDataJSONStringify,
			"accValues" : account
		});
		payment.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.orderName", response.getReturnValue());

				var orderName = component.get("v.orderName");

				if (orderName[0] === "error") {
					var nameField = document.getElementById("editContactDetails");
					component.set('v.showSpinner', false);
					nameField.innerHTML = "Confirm Your Order";
					document.getElementById("fifthTab").className = "slds-tabs--path__item slds-is-complete";
					document.getElementById("sixthTab").className = "slds-tabs--path__item slds-is-current";
					document.getElementById("stepFiveBlock").className = "slds-hide";
					document.getElementById("notificationStepSix").className = "slds-show";
					document.getElementById("usePreviousCardBtn").className = "slds-hide";
					document.getElementById("btnStepFiveBlock").className = "slds-hide";
					document.getElementById("btnNotificationStepSix").className = "slds-show";
				} else {
					var nameField2 = document.getElementById("editContactDetails");
					component.set('v.showSpinner', false);
					nameField2.innerHTML = "Confirm Your Order";
					document.getElementById("fifthTab").className = "slds-tabs--path__item slds-is-complete";
					document.getElementById("sixthTab").className = "slds-tabs--path__item slds-is-current";
					document.getElementById("stepFiveBlock").className = "slds-hide";
					document.getElementById("stepSixBlock").className = "slds-show";
					document.getElementById("usePreviousCardBtn").className = "slds-hide";
					document.getElementById("btnStepFiveBlock").className = "slds-hide";
					document.getElementById("btnStepSixBlock").className = "slds-show";
				}
			}
		});
		$A.enqueueAction(payment);
	},

	withNewCardDataCreation : function(component) {
		var validCardData = true;

		var cardIds = ['cardType', 'cardNumber', 'cardExpirationYear', 'cardExpirationMonth', 'cardCCV'];
		var cardDataTemp = [];
		var cardData = [];
		
		for (var i = 0; i < cardIds.length; i++) {
			cardDataTemp[i] = component.find(cardIds[i]);
			cardData[i] = cardDataTemp[i].get("v.value");
			if ($A.util.isEmpty(cardData[i])){
				validCardData = false;
				cardDataTemp[i].set("v.errors", [{message:"Field can't be blank."}]);
			}
			else {
				cardDataTemp[i].set("v.errors", null);
			}
		}
		
		var selectCcvInput = component.find("cardCCV").get("v.value");
		var selectCardInput = component.find("cardNumber").get("v.value");

		var inputCcv = component.find("cardCCV");
		var isEmptyCcvInput = $A.util.isEmpty(selectCcvInput);
		var invalidCCV = false;
		
		if (!isEmptyCcvInput) {
			var strCCV = selectCcvInput.toString();
			for (var i = 0; i < strCCV.length; i++) {
				if (!((strCCV[i] < 48 || strCCV[i] > 57) && (strCCV[i] < 96 || strCCV[i] > 105))) {
					invalidCCV = true;
				}
			}
		}

		if (isEmptyCcvInput || selectCcvInput.toString().length != 3 || invalidCCV) {
			inputCcv.set("v.errors", [{message:"Value is not valid "}]);
			validCardData = false;
			component.set('v.showSpinner', false);
		} else {
			inputCcv.set("v.errors", null);
		}

		var inputCard = component.find("cardNumber");
		var isEmptyCardInput = $A.util.isEmpty(selectCardInput);
		var invalidCard = false;
		
		if (!isEmptyCardInput) {
			var strCard = selectCardInput.toString();
			for (var i = 0; i < strCard.length; i++) {
				if (!((strCard[i] < 48 || strCard[i] > 57) && (strCard[i] < 96 || strCard[i] > 105))) {
					invalidCard = true;
				}
			}
		}

		if (isEmptyCardInput || selectCardInput.toString().length != 16 || invalidCard) {
			inputCard.set("v.errors", [{message:"Value is not valid "}]);
			validCardData = false;
			component.set('v.showSpinner', false);
		} else {
			inputCard.set("v.errors", null);
		}


		if (validCardData) {
			component.set('v.showSpinner', true);
			
			var price2 = component.get("v.price");
			var boffers = component.get("v.bumpOffers");
			var bOffers_ids = [];
			var quantityBump = [];
			for(var i = 0; i < boffers.length; i++) {
				if(boffers[i].count != 0) {
				bOffers_ids.push(boffers[i].id);
				quantityBump.push(boffers[i].count);
				}
			}
			var account2 = component.get("v.newAccount");
			var deliveryType;
			var isStandardDelivery = component.get("v.isStandardDelivery");
			var couponDiscount = - component.get("v.couponDiscount");
			var coupons = component.get('v.coupons');

			var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
			cardData[3] = monthNames.indexOf(cardData[3]) + 1;
			if (cardData[3] < 10) {
				cardData[3] = '0' + cardData[3];
			}
			var shippingList2 = component.get("v.shippingList");
			var nodes = JSON.stringify(component.get("v.nodes"));
			var couponsObj = component.get('v.couponsObj');

			var orderFormData2 = {
				product_id : price2[1],
				email : account2.PersonEmail,
				fname : account2.FirstName,
				lname : account2.LastName,
				phone : account2.Phone,
				cc_number : cardData[1],
				security_code : cardData[4],
				cc_exp_month : cardData[3],
				cc_exp_year : cardData[2],
				cc_type : cardData[0],
				tax : price2[6],
				subtotal : price2[7],
				couponDiscount : couponDiscount,
				total : (price2[0] - couponDiscount),
				shipping : '0',
				quantity : price2[3],
				offerprice : price2[4],
				token : '',
				brand : account2.Brand_Assortment__c,
				nodes : nodes,
				coupon_id : coupons,
				bumpOffers_id : bOffers_ids,
				quantityBump : quantityBump,
				couponsObj : couponsObj
			};
			
			var payment2 = component.get("c.payment");
			component.set("v.orderFormData", orderFormData2);
			var orderFormDataJSONStringify2 = JSON.stringify(orderFormData2);
			payment2.setParams({
				"newOrderForm" : orderFormDataJSONStringify2,
				"accValues" : account2
			});

			payment2.setCallback(this, function(response){
				var state = response.getState();
				if (state === "SUCCESS") {
					component.set("v.orderName", response.getReturnValue());

					var orderName = component.get("v.orderName");

					if (orderName[0] === "error") {
						var nameField = document.getElementById("editContactDetails");
						
						nameField.innerHTML = "Confirm Your Order";
						document.getElementById("fifthTab").className = "slds-tabs--path__item slds-is-complete";
						document.getElementById("sixthTab").className = "slds-tabs--path__item slds-is-current";
						document.getElementById("stepFiveBlock").className = "slds-hide";
						document.getElementById("notificationStepSix").className = "slds-show";
						document.getElementById("usePreviousCardBtn").className = "slds-hide";
						document.getElementById("btnStepFiveBlock").className = "slds-hide";
						document.getElementById("btnNotificationStepSix").className = "slds-show";
						component.set('v.showSpinner', false);
					} else {
						var nameField2 = document.getElementById("editContactDetails");
						
						nameField2.innerHTML = "Confirm Your Order";
						document.getElementById("fifthTab").className = "slds-tabs--path__item slds-is-complete";
						document.getElementById("sixthTab").className = "slds-tabs--path__item slds-is-current";
						document.getElementById("stepFiveBlock").className = "slds-hide";
						document.getElementById("stepSixBlock").className = "slds-show";
						document.getElementById("usePreviousCardBtn").className = "slds-hide";
						document.getElementById("btnStepFiveBlock").className = "slds-hide";
						document.getElementById("btnStepSixBlock").className = "slds-show";
						component.set('v.showSpinner', false);
					}
				}
			});
			$A.enqueueAction(payment2);
		}
	},
	//METHODS FROM 5 STEP ====> 6 STEP (ENDING)

	//METHODS FROM 6 STEP ====> 7 STEP (BEGINNING)
	initiateOrder : function(component) {
		
		var orderInfo = component.get("v.orderName");
		var accountValues = component.get("v.newAccount");
		var accountEmaill = accountValues.PersonEmail;
		var lastStep = component.get("c.lastStep");
		var orderFormData = component.get("v.orderFormData");
		var orderFormDataJSONStringify = JSON.stringify(orderFormData);

		lastStep.setParams({
			"orderId" : orderInfo,
			"accountEmail" : accountEmaill,
			"newOrderForm": orderFormDataJSONStringify
		});
	
		
		lastStep.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {

				component.set("v.lastStep", response.getReturnValue());

				var nameField = document.getElementById("editContactDetails");
				
				nameField.innerHTML = "Finish";
				document.getElementById("sixthTab").className = "slds-tabs--path__item slds-is-complete";
				document.getElementById("seventhTab").className = "slds-tabs--path__item slds-is-current";
				document.getElementById("stepSixBlock").className = "slds-hide";
				document.getElementById("stepSevenBlock").className = "slds-show";
				document.getElementById("btnStepSixBlock").className = "slds-hide";
				document.getElementById("btnStepSevenBlock").className = "slds-show";
				component.set('v.showSpinner', false);
			} else {
			}
		});
		$A.enqueueAction(lastStep);
	},
	//METHODS FROM 6 STEP ====> 7 STEP (ENDING)
	getAddressesB : function(component) {
		component.set('v.showAddressesLoadingB', true);

		var action = component.get('c.getAddresses');
		var address	= component.get('v.billingAddress');

		action.setParams({
			"address": address
		});

		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
		 		var value = JSON.parse(response.getReturnValue());

		 		if (value.length > 0) {
			 		component.set('v.addressesB', value);
			 		component.set('v.showAddressesB', true);
		 		} else {
		 			component.set('v.addressesB', []);
		 		}

				component.set('v.showAddressesLoadingB', false);
			}
		});
		$A.enqueueAction(action);
	},
	getAddressesS : function(component) {
		component.set('v.showAddressesLoadingS', true);

		var action = component.get('c.getAddresses');
		var address	= component.get('v.shippingAddress');

		action.setParams({
			"address": address
		});

		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
		 		var value = JSON.parse(response.getReturnValue());

		 		if (value.length > 0) {
			 		component.set('v.addressesS', value);
			 		component.set('v.showAddressesS', true);
		 		} else {
		 			component.set('v.addressesS', []);
		 		}

				component.set('v.showAddressesLoadingS', false);
			}
		});
		$A.enqueueAction(action);
	},
	showStep1 : function () {
		document.getElementById("editContactDetails").innerHTML = "Enter Email Address";
		document.getElementById("firstTab").className = "slds-tabs--path__item slds-is-current";
		document.getElementById("secondTab").className = "slds-tabs--path__item slds-is-incomplete";
		document.getElementById("stepOneBlock").className = "slds-show";
		document.getElementById("stepTwoBlock").className = "slds-hide";
		document.getElementById("btnStepOneBlock").className = "slds-show";
		document.getElementById("btnStepTwoBlock").className = "slds-hide";
	},
	showStep2 : function (result) {
		if (result) {
			document.getElementById("editContactDetails").innerHTML = "Edit Contact Details";
			document.getElementById("firstTab").className = "slds-tabs--path__item slds-is-complete";
			document.getElementById("secondTab").className = "slds-tabs--path__item slds-is-current";
			document.getElementById("thirdTab").className = "slds-tabs--path__item slds-is-incomplete";
			document.getElementById("stepOneBlock").className = "slds-hide";
			document.getElementById("stepTwoBlock").className = "slds-show";
			document.getElementById("stepThreeBlock").className = "slds-hide";
			document.getElementById("btnStepOneBlock").className = "slds-hide";
			document.getElementById("btnStepTwoBlock").className = "slds-show";
			document.getElementById("btnStepThreeBlock").className = "slds-hide";
		}
		else {
			document.getElementById("stepOneBlock").className = "slds-hide";
			document.getElementById("btnStepOneBlock").className = "slds-hide";
		}
	},
	showStep3 : function (result, countNotes) {
		if (result) {
			if (countNotes === 0) {
				document.getElementById("notificationBlock").className = "slds-show";
				document.getElementById("btnNotoficationBlock").className = "slds-show";  
			}
			else {
				document.getElementById("stepThreeBlock").className = "slds-show";
				document.getElementById("btnStepThreeBlock").className = "slds-show";    
			}
			document.getElementById("editContactDetails").innerHTML = "Choose Products";
			document.getElementById("secondTab").className = "slds-tabs--path__item slds-is-complete";
			document.getElementById("thirdTab").className = "slds-tabs--path__item slds-is-current";
			document.getElementById("fourthTab").className = "slds-tabs--path__item slds-is-incomplete";
			document.getElementById("stepTwoBlock").className = "slds-hide";
			document.getElementById("stepFourBlock").className = "slds-hide";
			document.getElementById("btnStepTwoBlock").className = "slds-hide";   
			document.getElementById("btnStepFourBlock").className = "slds-hide";
		}
		else {
			document.getElementById("stepTwoBlock").className = "slds-hide";
			document.getElementById("btnStepTwoBlock").className = "slds-hide";
		}
	},
	showStep4 : function (result) {
		document.getElementById("editContactDetails").innerHTML = "Confirm And Checkout";
		document.getElementById("thirdTab").className = "slds-tabs--path__item slds-is-complete";
		document.getElementById("fourthTab").className = "slds-tabs--path__item slds-is-current";
		document.getElementById("fifthTab").className = "slds-tabs--path__item slds-is-incomplete";
		document.getElementById("stepThreeBlock").className = "slds-hide";
		document.getElementById("stepFiveBlock").className = "slds-hide";
		document.getElementById("btnStepThreeBlock").className = "slds-hide";
		document.getElementById("btnStepFiveBlock").className = "slds-hide"; 
		
		if (result) {
			document.getElementById("stepFourBlock").className = "slds-show";
			document.getElementById("btnStepFourBlock").className = "slds-show"; 
		} 
		else {
			document.getElementById("notificationStepFour").className = "slds-show";
			document.getElementById("btnNotificationStepFour").className = "slds-show";
		}
	},
	showStep5 : function (prevCard) {
		document.getElementById("editContactDetails").innerHTML = "Choose Credit Card";
		document.getElementById("fourthTab").className = "slds-tabs--path__item slds-is-complete";
		document.getElementById("fifthTab").className = "slds-tabs--path__item slds-is-current";
		document.getElementById("sixthTab").className = "slds-tabs--path__item slds-is-incomplete";
		document.getElementById("stepFourBlock").className = "slds-hide";
		document.getElementById("stepFiveBlock").className = "slds-show";
		document.getElementById("stepSixBlock").className = "slds-hide";
		document.getElementById("btnStepFourBlock").className = "slds-hide";
		document.getElementById("btnStepFiveBlock").className = "slds-show"; 
		document.getElementById("btnStepSixBlock").className = "slds-hide";

		if (prevCard) {
			document.getElementById("usePreviousCardBtn").className = "slds-show";
		}
		else {
			document.getElementById("FillCreditCardInfo").className = "slds-show";
		}
	},
	showStep6 : function () {
		
	},
	showStep7 : function () {
		
	},
	validateCouponCode : function(component) {

		var generalDataCoupon = {
			couponCode : component.get('v.couponCode'),
			amount : 	 component.get('v.price[7]'),
			accountId :  component.get('v.newAccount.Id'),
			brand :      component.get('v.newAccount.TouchCRBase__Brand_Assortment__c'),
			autoApply :  component.get('v.autoApply')};

		var couponInfo = component.get("c.checkCoupon");
		var generalDataCouponStringify = JSON.stringify(generalDataCoupon);
		
		couponInfo.setParams({
			"generalData": generalDataCouponStringify
		});

		couponInfo.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
			var couponMessage = response.getReturnValue("coupon");
				if(couponMessage.message === "success"){
					var coupon = couponMessage.coupon;
					var couponDiscOld = component.get('v.couponDiscount');
					var totalAmount = 0;
					if(coupon.discount != undefined) {
						totalAmount = component.get('v.price[0]') - coupon.discount;
						component.set('v.couponDiscount', couponDiscOld + coupon.discount);
					}
					if(generalDataCoupon.couponCode != undefined) {
						component.set('v.discCouponWithCode', coupon.discount)
					}
					component.set('v.price[0]', totalAmount);
					component.set('v.couponError', '');
					var couponIds = component.get('v.coupons');
					couponIds.push(coupon.id);
					component.set('v.coupons', couponIds);
					if(!$A.util.isEmpty(generalDataCoupon.couponCode)) {
					document.getElementById("applyCouponCode").className = "slds-hide";
					document.getElementById("rollbackCouponCode").className = "slds-show";
					}
					component.set('v.showSpinner', false); 
				}
				if(couponMessage.message === "error") {
					component.set("v.couponError" , couponMessage.error);
					component.set('v.showSpinner', false); 
				}
			}
		});
		$A.enqueueAction(couponInfo);
	},

	rollBackCouponWithCode : function(component) {
		var discWithCode = component.get("v.discCouponWithCode");
		var oldPrice = parseInt(component.get("v.price[0]")) + discWithCode;
		var beforeCode = component.get('v.couponDiscount') - discWithCode;
		var coupons = component.get('v.coupons');
		var couponsNew = [];
		for(var i = 0; i < coupons.length-1; i++) {
			couponsNew.push(coupons[i]);
		}
		component.set('v.coupons', couponsNew);
		component.set('v.couponDiscount',beforeCode);
		component.set("v.price[0]", oldPrice);

	},

	getBumpOffers : function(component) {

		var action = component.get('c.getBumpOffers');
		var bumpOffers = [];


		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				 var bumpOffersServ = response.getReturnValue();
		 		if (bumpOffersServ.length != undefined) {
					 for(var i = 0; i < bumpOffersServ.length; i++) {
						 var bumpOffer = {
							id : bumpOffersServ[i].Id,
							name : bumpOffersServ[i].Name,
							type : bumpOffersServ[i].TouchCRBase__Type__c,
							active : bumpOffersServ[i].TouchCRBase__Active__c,
							brand : bumpOffersServ[i].TouchCRBase__Brand_Assortment__c,
							price : bumpOffersServ[i].TouchCRBase__Offer_Price__c,
							productId : bumpOffersServ[i].TouchCRBase__ProductTobeSold__c,
							oldPrice : bumpOffersServ[i].TouchCRBase__Product_Standard_Price__c,
							count : 0,

						 }
						 bumpOffers.push(bumpOffer);
					 }
					 component.set('v.bumpOffers', bumpOffers);
		 		}
			}
		});
		$A.enqueueAction(action);
	},

	getUpsells : function(component) {

		var action = component.get('c.getUpsells');
		var upsells = [];
		var downsells = [];


		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				 var upsellsServ = response.getReturnValue();
		 		if (upsellsServ.length != undefined) {
					 for(var i = 0; i < upsellsServ.length; i++) {
						 var upsell = {
							id : upsellsServ[i].Id,
							name : upsellsServ[i].Name,
							type : upsellsServ[i].TouchCRBase__Type__c,
							active : upsellsServ[i].TouchCRBase__Active__c,
							brand : upsellsServ[i].TouchCRBase__Brand_Assortment__c,
							price : upsellsServ[i].TouchCRBase__Offer_Price__c,
							productId : upsellsServ[i].TouchCRBase__ProductTobeSold__c,
							oldPrice : upsellsServ[i].TouchCRBase__Product_Standard_Price__c,
							count : 1,

						 }
						 if(upsell.type === 'Upsell') {
							upsells.push(upsell);
						 }
						 if(upsell.type === 'Downsell') {
							downsells.push(upsell);
						 }
						 if(upsell.type === undefined) {
							upsells.push(upsell);
						 }
					 }
					 component.set('v.upsells', upsells);
					 component.set('v.downsells', downsells);
					 if(!$A.util.isEmpty(upsells)) {
					 	document.getElementById('upSells').className = "slds-show";
					 }
					 if(!$A.util.isEmpty(downsells) && $A.util.isEmpty(upsells)) {
						document.getElementById('downSells').className = "slds-show";
					 }
		 		}
			}
		});
		$A.enqueueAction(action);
	},

	displayPopUpBOffers : function(component, event, helper) {
		var bumpOffers = component.get('v.bumpOffers');
		if(bumpOffers.lenght > 0 ) {
			document.getElementById("bumpOffersPopUp").className === "slds-show";
		}
	},

	addBOffers : function(component) {
		var bOffers = component.get('v.bumpOffers');
		var couponDisc = component.get('v.couponDiscount');
		var subTotal = 0;
		var subTotalPrice = parseInt(component.get('v.subtotalPrice').trim());
		for(var i = 0; i < bOffers.length; i++) {
			if(bOffers[i].count != 0) {
				var itemCount = bOffers[i].price * bOffers[i].count;
				subTotal = subTotal + itemCount;
			}
		}
		component.set('v.bOffersAmount', subTotal);
		subTotal = subTotal + subTotalPrice - couponDisc;
		component.set('v.price[0]', subTotal);
		document.getElementById("bumpOffersPopUp").className = "slds-hide";
	},

	createChildOrder : function(component, childOrder) {
		component.set('v.showSpinner', true);
		var orderInfo = component.get("v.orderName");
		var upsellData = {
			"orderId" : orderInfo[0],
			"price" : childOrder.price,
			"shipping" : 0,
			"tax" : 0,
			"product_id" : childOrder.productId,
			"quantity" : 1
		}

		var createUpsellOrder = component.get("c.insertUpsellOrder");
		var upsellDataStringify = JSON.stringify(upsellData);

		createUpsellOrder.setParams({
			"upsellData" : upsellDataStringify
		});
		createUpsellOrder.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var upselOrderId = response.getReturnValue();
				this.upsellPayment(component, upselOrderId);
			}
		});
		$A.enqueueAction(createUpsellOrder);
	},

	upsellPayment : function(component, upselOrderId) {
		var upsellPayment = component.get('c.upsellPayment');
		upsellPayment.setParams({
			"upselOrderId": upselOrderId
		});
		upsellPayment.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set('v.showSpinner', false);
			}
		})
		$A.enqueueAction(upsellPayment);
	}
})