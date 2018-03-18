({
	getAmountToRefund : function(component) {
		var recordId = component.get('v.recordId');
		var action = component.get('c.getAmount');

		action.setParams({
			"transactionId": recordId
		});

		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var value = response.getReturnValue();
				component.set('v.amountToRefund', value);
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

	doRefund : function(component) {
		var recordId = component.get('v.recordId');
		var inputAmount = component.find("amountInput");
		var amountToRefund = inputAmount.get("v.value");
		var isEmptyAmount = $A.util.isEmpty(amountToRefund);

		if (!isEmptyAmount && amountToRefund >= 1) {
			var action = component.get('c.refund');

			action.setParams({
				"recordId": recordId,
				"amount": amountToRefund
			});

			action.setCallback(this, function(response){
				var state = response.getState();
				if (state === "SUCCESS") {
					var value = JSON.parse(response.getReturnValue());
					component.set('v.isRefund', true);
					component.set('v.parentId', value.parentId);
					if (value.Status == 'Approved') {
						component.set('v.isSuccessRefund', true);
						component.set('v.messageRefund', value.Message);
					} else {
						component.set('v.isSuccessRefund', false);
						if (value.Message == 'Error transaction Bad Request') {
							component.set('v.messageRefund', value.Description);
						} else {
							component.set('v.messageRefund', value.Message);
						}
					}
				} else {
					component.set('v.isSuccessRefund', false);
					component.set('v.messageRefund', 'Error Refund');
				}
				component.set('v.showSpinner', false);
			});
			$A.enqueueAction(action);
		} else {
			inputAmount.set("v.errors", [{message:"The Amount must not be less than 1 Dollar"}]);
			component.set('v.showSpinner', false);
		}
	},

	cancelClick: function(component, event, helper) {
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