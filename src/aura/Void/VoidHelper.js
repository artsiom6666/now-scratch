({
	getAmountToVoid : function(component) {
		var recordId = component.get('v.recordId');
		var action = component.get('c.getAmount');

		action.setParams({
			"transactionId": recordId
		});

		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var value = response.getReturnValue();
				component.set('v.amountToVoid', value);
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

	doVoid : function(component) {
		var recordId = component.get('v.recordId');
		var inputAmount = component.find("voidInput");
		var amountToVoid = inputAmount.get("v.value");

		var isEmptyAmount = $A.util.isEmpty(amountToVoid);

		if (!isEmptyAmount && amountToVoid >= 1) {
			inputAmount.set("v.errors", null);
			var action = component.get('c.voidNow');

			action.setParams({
				"recordId": recordId,
				"amount": amountToVoid
			});

			action.setCallback(this, function(response){
				var state = response.getState();
				if (state === "SUCCESS") {
					var value = JSON.parse(response.getReturnValue());
					component.set('v.isVoid', true);
					component.set('v.parentId', value.parentId);
					if (value.Status == 'Approved') {
						component.set('v.isSuccessVoid', true);
						component.set('v.messageVoid', value.Message);
					} else {
						component.set('v.isSuccessVoid', false);
						if (value.Message == 'Error transaction Bad Request') {
							component.set('v.messageVoid', value.Description);
						} else {
							component.set('v.messageVoid', value.Message);
						}
					}
				} else {
					component.set('v.isSuccessVoid', false);
					component.set('v.messageVoid', 'Error Void');
				}
				component.set('v.showSpinner', false);
			});
			$A.enqueueAction(action);
		} else {
			inputAmount.set("v.errors", [{message:"The Amount must not be less than 1 Dollar"}]);
			component.set('v.showSpinner', false);
		}
	},

	cancel: function(component, event, helper) {
		// Close the action panel

		// var dismissActionPanel = $A.get("e.force:closeQuickAction");
		// dismissActionPanel.fire();

		var recordId = component.get('v.recordId');
		var parentId = component.get('v.parentId');

		if (parentId && parentId != 'null') {
			recordId = parentId;
		}

		var navEvt = $A.get("e.force:navigateToSObject");
			navEvt.setParams({
			  "recordId": recordId
			});
		navEvt.fire();
	}
})