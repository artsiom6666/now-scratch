({
	getSettingsHelper: function(component) {
		component.set('v.showSpinner', true);

		var action = component.get('c.getAuthorizeSettingsApex');
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (component.isValid() && state === 'SUCCESS') {
				var result = response.getReturnValue();
				var endpoint = {};

				endpoint.clientIdEndpoint = (result['Endpoint.ClientId']) ? result['Endpoint.ClientId'] : '';
				endpoint.clientSecretEndpoint = (result['Endpoint.ClientSecret']) ? result['Endpoint.ClientSecret'] : '';
				component.set('v.endpoint', endpoint);
				component.set('v.isLinked', (result['Endpoint.ClientSecret']) ? 'Linked' : 'Unlinked');
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
		component.set('v.showUnlinkMessage', false);
	},

	closeMessageHelper: function(component) {
		component.set('v.showErrorMessage', false);
		// component.set('v.successDelete', false);
		// component.set('v.errorDelete', false);
		// component.set('v.successSave', false);
		// component.set('v.errorSave', false);
	}
})