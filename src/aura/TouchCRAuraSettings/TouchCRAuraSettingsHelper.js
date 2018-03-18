({
	//Get available services.
	getAvailableServices : function(component) {
		var action = component.get('c.getServices');
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (component.isValid() && state === 'SUCCESS') {
				var result = response.getReturnValue();

				result = JSON.parse(result);
				component.set('v.isAbleMinfraud', result.isAbleMinfraud);
				component.set('v.isAbleUsps', result.isAbleUsps);
				component.set('v.isAbleDataAppend', result.isAbleDataAppend);
//				component.set('v.isAbleFullContact', result.isAbleFullContact);
				component.set('v.isAbleAffiliate', result.isAbleAffiliate);
				component.set('v.isAbleFranchisee', result.isAbleFranchisee);
				if (result.isErrorGetServices == true) {
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						"title": "Error!",
						"type": "error",
						"message": " Can't get available services."
					});
					toastEvent.fire();
				}

			}

		});
		$A.enqueueAction(action);
	}
})