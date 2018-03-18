({
	doInit : function(component, event, helper) {
		component.set('v.showSpinner', true);
		helper.getValuesForPicklist(component);
		helper.getInformation(component);
	}, 

	chargeOrder : function(component, event, helper) {
		component.set('v.showSpinner', true);
		var isUsePaymentOptions = component.get('v.isUsePaymentOptions');
		var isValid = true;
		//validation
		if (isUsePaymentOptions == false) {
			var selectCcvInput = component.find("ccvInput").get("v.value");
			var selectCardInput = component.find("cardInput").get("v.value");
			var selectYearInput = component.find("yearInput").get("v.value");
			var selectMonthInput = component.find("monthInput").get("v.value");
			var selectTypeCardInput = component.find("typeCardInput").get("v.value");


			var inputCcv = component.find("ccvInput");
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
				isValid = false;
			} else {
				inputCcv.set("v.errors", null);
			}

			var inputCard = component.find("cardInput");
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
				isValid = false;
			} else {
				inputCard.set("v.errors", null);
			}
		} else {
			var mapField = component.get('v.cards');
			var isPaymentOptionChosen = false;
			for (var i = 0; i < mapField.length; i++) {
				if (mapField[i].isCheck == true) { isPaymentOptionChosen = true; }
			}

			if (isPaymentOptionChosen == false) { 
				isValid = false; 
				component.set('v.isValid', false);
				component.set('v.message', 'Payment Option is not selected');
			} else {
				component.set('v.isValid', true);
				component.set('v.message', null);
			}
		}
		
		var amount = component.find("amountInput").get("v.value");
		var isEmptyAmount = $A.util.isEmpty(amount);
		var inputAmount = component.find("amountInput");

		if (isEmptyAmount || amount < 1) {
			inputAmount.set("v.errors", [{message:"The Amount must not be less than 1 Dollar"}]);
			isValid = false;
		} else if (amount > component.get('v.amountToChargeInOrder')) {
			inputAmount.set("v.errors", [{message:"The Amount can not be greater than Amount To Charge in Order"}]);
			isValid = false;
		} else {
			inputAmount.set("v.errors", null);
		}

		if (isValid) {
			helper.getCharge(component);
			component.set('v.showChargeButton', false);
		} else {
			component.set('v.showSpinner', false);
		}

	},

	clickCard : function(component, event, helper) {
		var mapField = component.get('v.cards');
		var keyField = event.currentTarget.dataset.key;
		for (var i = 0; i < mapField.length; i++) {
			if (mapField[i].paymentOptionId == keyField) {
				mapField[i].isCheck = mapField[i].isCheck ? false : true;
				var chosenPaymentOptionId = mapField[i].isCheck ? mapField[i].paymentOptionId : '';
				component.set('v.chosenPaymentOptionId', chosenPaymentOptionId);
				
				//reset error messages
				component.set('v.message', null);
				component.set('v.isValid', true);
			} else {
				mapField[i].isCheck = false;
			}
		}
		component.set('v.cards', mapField);
	},

	clickUsePaymentOptions : function(component, event, helper) {
		var isUsePaymentOptions = component.get('v.isUsePaymentOptions');
		component.set('v.isUsePaymentOptions', !isUsePaymentOptions);

		//reset error messages
		component.set('v.message', null);
		component.set('v.isValid', true);

		var arePaymentOptionsActive = component.get('v.arePaymentOptionsActive');
		//disable "charge" button, if there isn't payment options
		if (arePaymentOptionsActive == false && !isUsePaymentOptions == true) {
			component.set('v.showChargeButton', false);
		} else {
			component.set('v.showChargeButton', true);
		}
		
		if (!isUsePaymentOptions == false) {
			helper.getValuesForPicklist(component);
		}
	},

	cancelClick: function(component, event, helper) {
		// Close the action panel
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();
	},

	closeClick: function(component, event, helper) {
		// Close the action panel
		var transactionId = component.get('v.transactionId');

		if (transactionId != '') {
			var navEvt = $A.get("e.force:navigateToSObject");
				navEvt.setParams({
				  "recordId": transactionId
				});
			navEvt.fire();
		} else {
			var dismissActionPanel = $A.get("e.force:closeQuickAction");
			dismissActionPanel.fire();
		}
	}
})