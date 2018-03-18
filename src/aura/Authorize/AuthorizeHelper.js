({
	getValuesForPicklist : function(component) {
		component.set('v.transactionId', '');

		var yearOpts = [];
		var currentTime = new Date();
		var year = currentTime.getFullYear();

		for (var i = 0; i < 7; i++) {
			yearOpts.push({
				class: 'optionClass',
				label: year + i,
				value: year + i
			});
		}
		component.find("yearInput").set("v.options", yearOpts);

		var months = [];
		var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

		for (var i = 0; i < 12; i++) {
			months.push({
				class: 'optionClass',
				label: monthNames[i],
				value: i + 1
			});
		}
		component.find("monthInput").set("v.options", months);

		var cards = ["Visa", "Mastercard"];
		var cardsOpts = [];

		for (var i = 0; i < cards.length; i++) {
			cardsOpts.push({
				class: 'optionClass',
				label: cards[i],
				value: cards[i]
			});
		}
		component.find("typeCardInput").set("v.options", cardsOpts);
	},

	getAmountToAuthorize : function(component) {
		var recordId = component.get('v.recordId');
		var action = component.get('c.getAmount');

		action.setParams({
			"orderId": recordId
		});

		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var value = response.getReturnValue();
				component.set('v.amountToAuthorize', value);
				if (value != '0') {
					component.set('v.isValidData', true);
				} else {
					component.set('v.isValidData', false);
				}
			}
			component.set('v.showSpinner', false);
		});
		$A.enqueueAction(action);
	},

	authorize : function(component) {
		var recordId = component.get('v.recordId');

		var isValid = true;

		var selectCcvInput = component.find("ccvInput").get("v.value");
		var selectCardInput = component.find("cardInput").get("v.value");
		var selectYearInput = component.find("yearInput").get("v.value");
		var selectMonthInput = component.find("monthInput").get("v.value");
		var selectTypeCardInput = component.find("typeCardInput").get("v.value");
		var amount = component.find("amountInput").get("v.value");

		var inputAmount = component.find("amountInput");
		var isEmptyAmount = $A.util.isEmpty(amount);

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
			component.set('v.showSpinner', false);
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
			component.set('v.showSpinner', false);
		} else {
			inputCard.set("v.errors", null);
		}
		if (isEmptyAmount || amount < 1) {
			inputAmount.set("v.errors", [{message:"The Amount must not be less than 1 Dollar"}]);
			isValid = false;
			component.set('v.showSpinner', false);
		} else {
			inputAmount.set("v.errors", null);
		}

		if (isValid) {
			var action = component.get('c.authorizeOrderNow');

			var authorizeData = {
				"cardNumber": (selectCardInput) ? selectCardInput : '',
				"ccv": (selectCcvInput) ? selectCcvInput : '',
				"cardExpirationMonth": (selectMonthInput) ? selectMonthInput : '',
				"cardExpirationYear": (selectYearInput) ? selectYearInput : '',
				"amount": (amount) ? amount : 0,
				"recordId": recordId
			};

			action.setParams({
				"authorizeData": JSON.stringify(authorizeData)
			});

			action.setCallback(this, function(response){
				var state = response.getState();
				component.set('v.isAuthorize', true);
				if (state === "SUCCESS") {
					var value = JSON.parse(response.getReturnValue());
					if (value.status == 'success') {
						component.set('v.isSuccessAuthorize', true);
						component.set('v.messageAuthorize', 'The Transaction is successfully created');
						component.set('v.transactionId', value.transaction);
					} else {
						component.set('v.isSuccessAuthorize', false);
						component.set('v.messageAuthorize', value.error);
						component.set('v.transactionId', value.transaction);
					}
				} else {
					component.set('v.isSuccessAuthorize', false);
					component.set('v.messageAuthorize', 'Error Transaction Service Unavailable');
				}
				component.set('v.showSpinner', false);
			});
			$A.enqueueAction(action);
		}
	},

	cancel: function(component, event, helper) {
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