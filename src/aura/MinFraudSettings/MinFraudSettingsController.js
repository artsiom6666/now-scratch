({
	doInit: function(component, event, helper) {
		helper.getSettingsHelper(component);
	},

	saveSettings: function(component, event, helper) {
        var settings = component.get('v.settings');

		var action = component.get('c.saveMinFraud');

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

	changeCkeckbox: function(component, event) {
		var settings = component.get('v.settings');
		var name = event.target.id;
		settings[name] = !settings[name];
		component.set('v.settings', settings);
	},

	closeCancelMsgNo: function(component) {
		component.set('v.showCancelMessage', false);
	},

	closeCancelMsgYes: function(component, event, helper) {
		helper.getSettingsHelper(component);
		component.set('v.showCancelMessage', false);
        component.set('v.edit', false);
	}

})