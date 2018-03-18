({
	doInit: function(component, event, helper) {
		component.set('v.showSpinner', true);
		helper.getSettingsHelper(component);
	},

	saveSettings: function(component, event, helper) {
        var settings = component.get('v.settings');

		var action = component.get('c.saveStripeConnect');

		action.setParams({
			'settings': JSON.stringify(settings)
		});
		action.setCallback(this, function(response) {
			helper.responseHandler(component, event, response);
		});
		$A.enqueueAction(action);
	},

	edit: function(component) {
        component.set('v.edit', true);
	},

	cancel: function(component, event, helper) {
		helper.closeMessageHelper(component);
		component.set('v.showCancelMessage', true);
	},

	closeCancelMsgNo: function(component) {
		component.set('v.showCancelMessage', false);
	},

	closeCancelMsgYes: function(component, event, helper) {
	    helper.getSettingsHelper(component, event);
		component.set('v.showCancelMessage', false);
        component.set('v.edit', false);
	}

})