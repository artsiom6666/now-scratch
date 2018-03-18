({
	nextStep2 : function(component, event, helper) {
		component.set('v.showSpinner', true);
		
		var addEmailId = component.find("addEmail");
		var email = addEmailId.get("v.value");
		
		if(helper.checkValidEmail(email)) {
			addEmailId.set("v.errors", null);
			helper.getCountryPicklist(component);
			helper.findAccount(component, email);
		} else {
			addEmailId.set("v.errors", [{message:"Incorrect format of email address"}]);
			component.set('v.showSpinner', false);
		}
		component.set('v.showSpinner', false); 
	},

	nextStep3 : function(component, event, helper) {
		component.set('v.showSpinner', true);
		var newAccount = component.get("v.newAccount")

		var sameBillingAddress = component.get("v.sameBillingAddress");

		if (sameBillingAddress) {
			component.set("v.billingAddress", component.get("v.shippingAddress"));
		}

		helper.inputFieldsValidation(component);
		
		var validData = component.get("v.validData");

		if (validData) {
			helper.createOrEditAccount(component);
			helper.getBumpOffers(component);
		}

		component.set('v.showSpinner', false);    
	},

	nextStep4 : function(component, event, helper) {
		helper.displayPopUpBOffers(component);  
		component.set('v.showSpinner', true);
		helper.getTotalPrices(component);
//        component.set('v.showSpinner', false);
	},

	nextStep5 : function(component, event, helper) {
		component.set('v.showSpinner', true);
		helper.creditCardChecking(component);
//        component.set('v.showSpinner', false);
	},

	nextStep6 : function(component, event, helper) {
		component.set('v.showSpinner', true);
		var usePreviousCard = component.get("v.usePreviousCard");

		if (usePreviousCard) {
			helper.withOldCardDataCreation(component);
		} else {
			helper.withNewCardDataCreation(component);
		}
//		component.set('v.showSpinner', false);
	},

	nextStep7 : function(component, event, helper) {
		component.set('v.showSpinner', true);
		helper.initiateOrder(component);
		helper.getUpsells(component);
		document.getElementById("editContactDetails").innerHTML = "Finish";
		document.getElementById("sixthTab").className = "slds-tabs--path__item slds-is-complete";
		document.getElementById("seventhTab").className = "slds-tabs--path__item slds-is-current";
		document.getElementById("stepSixBlock").className = "slds-hide";
		document.getElementById("stepSevenBlock").className = "slds-show";
		document.getElementById("btnStepSixBlock").className = "slds-hide";
		document.getElementById("btnStepSevenBlock").className = "slds-show";
//		component.set('v.showSpinner', false);
	},

	previousStep1 : function(component, event, helper) {
		component.set('v.showSpinner', true);
		component.set("v.newAccount", null);
		helper.showStep1(component);
		component.set('v.showSpinner', false);
	},

	previousStep2 : function(component, event, helper) {
		component.set('v.showSpinner', true);
		
		component.set("v.nodes", undefined);
		component.set("v.price", undefined);
		component.set("v.shippingList", undefined);
		component.set("v.checkOldCreditCardResult", undefined);
		helper.showStep2(true);
		component.set('v.showSpinner', false);
	},

	previousStep3 : function(component, event, helper) {
		component.set('v.showSpinner', true);
		helper.showStep3(true, component.get("v.nodes").length);
		component.set('v.bumpOffers', '');
		helper.getBumpOffers(component);
		component.set('v.bOffersAmount', 0);
		component.set('v.subtotalPrice', 0);
		var rollCoupon = component.get('v.coupons');
		var oldCoupon = [];
		/*for(var i = 0; i < rollCoupon.length - 1; i++) {
			oldCoupon.push(rollCoupon[i]);
		}*/
		component.set('v.coupons', oldCoupon);
		component.set('v.couponCode', '');
		component.set('v.couponDiscount', 0);
		component.set('v.showSpinner', '');
		document.getElementById("applyCouponCode").className = "slds-show";
		document.getElementById("rollbackCouponCode").className = "slds-hide";
	},

	previousStep4 : function(component, event, helper) {
		component.set('v.showSpinner', true);
		helper.showStep4(component.get("v.price")[0] != "0");
		component.set('v.showSpinner', false);
	},

	previousStep5 : function(component, event, helper) {
		component.set('v.showSpinner', true);
		if (component.get("v.checkOldCreditCardResult")[0] != 'notShowPreviousCard') {
			component.set("v.usePreviousCard", true);
		}
		helper.showStep5(component.get("v.usePreviousCard"));
		component.set('v.showSpinner', false);
	},

	backFromNotify : function(component, event, helper) {
		component.set('v.showSpinner', true);
		document.getElementById("editContactDetails").nameField.innerHTML = "Edit Contact Details";
		document.getElementById("secondTab").className = "slds-tabs--path__item slds-is-current";
		document.getElementById("thirdTab").className = "slds-tabs--path__item slds-is-incomplete";
		document.getElementById("notificationBlock").className = "slds-hide";
		document.getElementById("stepTwoBlock").className = "slds-show";
		document.getElementById("btnNotoficationBlock").className = "slds-hide";
		document.getElementById("btnStepTwoBlock").className = "slds-show";
		component.set('v.showSpinner', false);
	},

	backFromFourNotify : function(component, event, helper) {
		component.set('v.showSpinner', true);
		document.getElementById("editContactDetails").innerHTML = "Edit Contact Details";
		document.getElementById("thirdTab").className = "slds-tabs--path__item slds-is-current";
		document.getElementById("fourthTab").className = "slds-tabs--path__item slds-is-incomplete";
		document.getElementById("notificationStepFour").className = "slds-hide";
		document.getElementById("stepThreeBlock").className = "slds-show";
		document.getElementById("btnStepThreeBlock").className = "slds-show";
		document.getElementById("btnNotificationStepFour").className = "slds-hide";
		component.set('v.showSpinner', false);
	},

	changeBillingAddress : function(component, event, helper) {
		if (document.getElementById("BillingAddressIsTheSame").className === "slds-show") {
			document.getElementById("BillingAddressIsTheSame").className = "slds-hide";
			component.set("v.sameBillingAddress", true);
		} else {
			document.getElementById("BillingAddressIsTheSame").className = "slds-show";
			component.set("v.sameBillingAddress", false);
		}
		var sameBillingAddress = component.get("v.sameBillingAddress");
	},

	showCreditCardBlock : function(component, event, helper) {
		if (document.getElementById("FillCreditCardInfo").className === "slds-show") {
			document.getElementById("FillCreditCardInfo").className = "slds-hide";
		} else {
			document.getElementById("FillCreditCardInfo").className = "slds-show";
		}
		var usePreviousCard = component.get("v.usePreviousCard");
		if (usePreviousCard) {
			component.set("v.usePreviousCard", false);
		} else {
			component.set("v.usePreviousCard", true);
		}
	},

	showNode : function(component, event, helper) {
		var node = component.get("v.nodes");
		var id = event.srcElement.id;
		var elems = document.getElementsByClassName(id);

		for (var i=0; i < elems.length; i++) {
			if (elems[i].style.display === '') {
				elems[i].style.display = 'none';

				var childDiv = elems[i].childNodes;
				var childDivId = childDiv[0].getAttribute('id');
				var childClass = document.getElementsByClassName(childDivId);
				if (childDivId === null || childClass.size === 0) {
					for (var j=0; j < childClass.length; j++) {

						if (childClass[j].style.display === '') {
							childClass[j].style.display = 'none';
						}
					}
				} else {
					for (var j2=0; j2 < childClass.length; j2++) {
						if (childClass[j2].style.display === '') {
							childClass[j2].style.display = 'none';

							var childDiv2 = childClass[j2].childNodes;
							var childDivId2 = childDiv2[0].getAttribute('id');
							var childClass2 = document.getElementsByClassName(childDivId2);
							for (var k=0; k < childClass2.length; k++) {

								if (childClass2[k].style.display === '') {
									childClass2[k].style.display = 'none';
								}
							}
						}
					}
				}
			} else {
				elems[i].style.display = '';
			}
		}
	},
	turnOnDeliveryStandard: function(component) {
		component.set('v.showTextCube', false);
		component.set('v.showTextCube2', false);
		component.set('v.isStandardDelivery', true);
		component.set('v.isSecondDate', false);
	},
	turnOnDeliveryStandard2: function(component) {
		component.set('v.showTextCube', false);
		component.set('v.showTextCube2', false);
		component.set('v.isStandardDelivery', true);
		component.set('v.isSecondDate', true);
	},
	turnOffDeliveryStandard: function(component) {
		component.set('v.showTextCube', true);
		component.set('v.showTextCube2', false);
		component.set('v.isStandardDelivery', false);
		component.set('v.isSecondDate', false);
	},
	turnOffDeliveryStandard2: function(component) {
		component.set('v.showTextCube', false);
		component.set('v.showTextCube2', true);
		component.set('v.isStandardDelivery', false);
		component.set('v.isSecondDate', true);
	},
	addressChangeB : function(component, event, helper) {
//		var address = component.get('v.billingAddress');
//		var addressPrevious = component.get('v.addressPreviousB');
//		if (addressPrevious != address){
//			component.set('v.addressPreviousB', address);
//			helper.getAddressesB(component);
//		}
	},
	addressChangeS : function(component, event, helper) {
//		var address = component.get('v.shippingAddress');
//		var addressPrevious = component.get('v.addressPreviousS');
//		if (addressPrevious != address){
//			component.set('v.addressPreviousS', address);
//			helper.getAddressesS(component);
//		}
	},
	addressClickB : function(component, event, helper) {
		component.set('v.billingAddress', event.target.innerHTML);
		component.set('v.addressPreviousB', event.target.innerHTML);
		component.set('v.showAddressesB', false);
	},
	addressClickS : function(component, event, helper) {
		component.set('v.shippingAddress', event.target.innerHTML);
		component.set('v.addressPreviousS', event.target.innerHTML);
		component.set('v.showAddressesS', false);
	},
	yearChange : function(component, event, helper) {
		var year = component.find("cardExpirationYear").get("v.value");
		var curYear = new Date().getFullYear();
		var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
		var curMonth = new Date().getMonth();
		
		if (year == curYear) {
			for (var i = 0; i < curMonth; i++) {
				monthNames.shift();
			}
		}

		component.set("v.experationMonths", monthNames);
		component.set("v.experationMonthValue", monthNames[0]);
	},

	haveCouponCode : function(component, event, helper) {
		component.set('v.showSpinner', true); 
		helper.validateCouponCode(component);
	},

	rollBackDiscount : function(component, event, helper) {
		helper.rollBackCouponWithCode(component);
		document.getElementById("applyCouponCode").className = "slds-show";
		document.getElementById("rollbackCouponCode").className = "slds-hide";
	},

	closeCouponErrorMessage : function(component, event, helper) {
		component.set("v.couponError", '');
	},

	showBumpPopUp : function(component, event, helper) {
		document.getElementById("bumpOffersPopUp").className = "slds-show";
	},

	addBumpOffers : function(component, event, helper) {
		document.getElementById("bumpOffersPopUp").className = "slds-show";
		helper.addBOffers(component);
	},

	editBumpOffers : function(component, event, helper) {
		document.getElementById("bumpOffersPopUp").className = "slds-show";
	},

	closeBumpPopUp : function(component, event, helper) {
		document.getElementById("bumpOffersPopUp").className = "slds-hide";
	},
	upBuy : function(component, event, helper) {
		var childOrder = component.get('v.upsells')[0];
		helper.createChildOrder(component, childOrder);
		var oldUpsells = component.get('v.upsells');
		var oldDownsells = component.get('v.downsells');
		var newUpsells = [];
		var newDownsells = [];
		for(var i = 1; i < oldUpsells.length; i++) {
			newUpsells.push(oldUpsells[i]);
			newDownsells.push(oldDownsells[i]);
		}
		component.set('v.upsells', newUpsells);
		component.set('v.downsells', newDownsells);
		if($A.util.isEmpty(newUpsells) && $A.util.isEmpty(newDownsells)) {
			document.getElementById("upSells").className = "slds-hide";
			document.getElementById("downSells").className = "slds-hide";
		}
		if($A.util.isEmpty(newUpsells)) {
		document.getElementById("upSells").className = "slds-hide";
		}

	},
	next: function (component, event, helper) {
		var oldUpsells = component.get('v.upsells');
		if (!$A.util.isEmpty(oldUpsells)) {
			var newUpsells = [];
			for (var i = 1; i < oldUpsells.length; i++) {
				newUpsells.push(oldUpsells[i]);
			}
			component.set('v.upsells', newUpsells);
			if (!$A.util.isEmpty(component.get('v.downsells'))) {
				document.getElementById("upSells").className = "slds-hide";
				document.getElementById("downSells").className = "slds-show";
			}
			if ($A.util.isEmpty(component.get('v.downsells'))) {
				document.getElementById("upSells").className = "slds-hide";
				document.getElementById("downSells").className = "slds-hide";

			}
		}
	},
	downBuy : function(component, event, helper) {
		var childOrder = component.get('v.downsells')[0];
		helper.createChildOrder(component, childOrder);
		var oldUpsells = component.get('v.downsells');
		var newUpsells = [];
		for(var i = 1; i < oldUpsells.length; i++) {
			newUpsells.push(oldUpsells[i]);
		}
		component.set('v.downsells', newUpsells);
		if (!$A.util.isEmpty(component.get('v.upsells'))) {
			document.getElementById("upSells").className = "slds-show";
			document.getElementById("downSells").className = "slds-hide";
		}
		if ($A.util.isEmpty(component.get('v.upsells'))) {
			document.getElementById("upSells").className = "slds-hide";
			document.getElementById("downSells").className = "slds-hide";

		}
	},
	nextDown : function(component, event, helper) {
		document.getElementById("upSells").className = "slds-hide";
		document.getElementById("downSells").className = "slds-hide";
	},

	changeShippingCountry : function(component, event, helper) {
		component.set('v.newAccount.ShippingState', '');
		component.set('v.newAccount.ShippingStateCode', '');
		helper.getStatePickList(component);
	}

})