({
	getSettingsHelper: function(component) {
		component.set('v.showSpinner', true);

		var action = component.get('c.getGlobalSettingsApex');
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (component.isValid() && state === 'SUCCESS') {
				var result = response.getReturnValue();
                result = JSON.parse(result);
                var settings = {};
                settings.APIKey = (result['Global.APIKey']) ? result['Global.APIKey'] : '';
                settings.AppendOnNewAccount = (result['Global.AppendOnNewAccount']) ? (result['Global.AppendOnNewAccount'] === 'true') : false;
                settings.AppendOnNewLead = (result['Global.AppendOnNewLead']) ? (result['Global.AppendOnNewLead'] === 'true') : false;
                settings.EmailOn = (result['Global.EmailOn']) ? (result['Global.EmailOn'] === 'true') : false;
                settings.IgnoreOlderThan = (result['Global.IgnoreOlderThan']) ? result['Global.IgnoreOlderThan'] : '';
                settings.License = (result['Global.License']) ? result['Global.License'] : '';
                settings.ReappendOnDays = (result['Global.ReappendOnDays']) ? result['Global.ReappendOnDays'] : '';

				component.set('v.settings', settings);
			}
			component.set('v.showSpinner', false);
		});
		$A.enqueueAction(action);
	},

	responseHandler: function(component, event, response) {
		var state = response.getState();
		if (component.isValid() && state === 'SUCCESS') {
			if (response.getReturnValue().indexOf('success') > -1 ) {
				component.set('v.showSuccessMessage', true);
				component.set('v.textMessage', response.getReturnValue());
				setTimeout(function() {
					component.set('v.showSuccessMessage', false);
				}, 2000);
			} else {
				component.set('v.showErrorMessage', true);
				component.set('v.textMessage', response.getReturnValue());
				setTimeout(function() {
					component.set('v.showErrorMessage', false);
				}, 2000);
			}
		} else {
			component.set('v.showErrorMessage', true);
			component.set('v.textMessage', response.getReturnValue());
			setTimeout(function() {
				component.set('v.showErrorMessage', false);
			}, 2000);
		}
		this.getSettingsHelper(component, event);
		component.set('v.edit', false);
		component.set('v.showSpinner', false);
	},

	closeMessageHelper: function(component) {
		component.set('v.showErrorMessage', false);
		// component.set('v.successDelete', false);
		// component.set('v.errorDelete', false);
		// component.set('v.successSave', false);
		// component.set('v.errorSave', false);
	}
})