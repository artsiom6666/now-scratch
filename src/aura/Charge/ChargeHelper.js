({
	getInformation : function(component) {
		//default value
		component.set('v.chosenPaymentOptionId', '');
		component.set('v.transactionId', '');

		var recordId = component.get('v.recordId');
		var action = component.get('c.getCardsAndGeneralInfo');
		
		action.setParams({
			"recordId": recordId
		});

		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var value = JSON.parse(response.getReturnValue());
				if (value.status == 'success') {
					component.set('v.amountOfCharge', value.amount);
					component.set('v.amountToChargeInOrder', value.amount);
					
					var arePaymentOptionsActive = value.paymentOptions.length > 0 ? true : false;
					component.set('v.arePaymentOptionsActive', arePaymentOptionsActive);
					component.set('v.cards',value.paymentOptions);
				}
			} else {
				//todo
			}
			component.set('v.showSpinner', false);
		});
		$A.enqueueAction(action);
	},

	getValuesForPicklist : function(component) {
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

	getCharge : function(component) {
		var isUsePaymentOptions = component.get('v.isUsePaymentOptions');
		var cardNumber, ccv, selectYearInput, selectMonthInput, chosenPaymentOptionId;
		
		if (isUsePaymentOptions == false) {
			cardNumber = component.get('v.cardNumber');
			ccv = component.get('v.ccv');
			selectYearInput = component.find("yearInput").get("v.value");
			selectMonthInput = component.find("monthInput").get("v.value");
		} else {
			chosenPaymentOptionId = component.get('v.chosenPaymentOptionId');
		}

		var amount = component.get('v.amountOfCharge');
		var recordId = component.get('v.recordId');

		var obj = {};

		obj.newCard = isUsePaymentOptions == true ? false : true;
		obj.chosenPaymentOptionId = isUsePaymentOptions == true ? chosenPaymentOptionId : '';
		obj.cardNumber = isUsePaymentOptions == true ? '' : cardNumber;
		obj.ccv = isUsePaymentOptions == true ? '' : ccv;
		obj.year = isUsePaymentOptions == true ? '' : selectYearInput;
		obj.month = isUsePaymentOptions == true ? '' : selectMonthInput;
		obj.amount = amount;
		obj.orderId = recordId;

		var action = component.get('c.chargeOrderNow');

		action.setParams({
			"chargeData": JSON.stringify(obj)
		});

		action.setCallback(this, function(response){
			var state = response.getState();
			
			component.set('v.isCharge', true);
			if (state === "SUCCESS") {
				var value = JSON.parse(response.getReturnValue());
				if (value.status == 'error') {
					component.set('v.message', value.error);
					component.set('v.transactionId', value.transaction);
				} else {
					component.set('v.message', 'The Transaction is successfully created');
					component.set('v.transactionId', value.transaction);
				}
			} else {
				component.set('v.message', 'Error Transaction Service Unavailable');
			}
			component.set('v.showSpinner', false);
		});
		$A.enqueueAction(action);
	}
})