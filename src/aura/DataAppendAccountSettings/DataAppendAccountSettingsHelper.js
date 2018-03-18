({
	getSettingsHelper: function(component) {
		component.set('v.showSpinner', true);

		var action = component.get('c.getAccountSettingsApex');
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (component.isValid() && state === 'SUCCESS') {
				var result = response.getReturnValue();
                result = JSON.parse(result);
                var settings = {};
                settings.ValidateEmail = (result['Account.ValidateEmail']) ? (result['Account.ValidateEmail'] === 'true') : false;
                settings.CorrectEmail = (result['Account.CorrectEmail']) ? (result['Account.CorrectEmail'] === 'true') : false;
                settings.AppendNameAddress = (result['Account.AppendNameAddress']) ? (result['Account.AppendNameAddress'] === 'true') : false;
                settings.EnableDemographics = (result['Account.EnableDemographics']) ? (result['Account.EnableDemographics'] === 'true') : false;
                settings.EmailActivityMetrics = (result['Account.EmailActivityMetrics']) ? (result['Account.EmailActivityMetrics'] === 'true') : false;
                settings.AppendDemographicBasics = (result['Account.AppendDemographicBasics']) ? (result['Account.AppendDemographicBasics'] === 'true') : false;
                settings.AppendHousing = (result['Account.AppendHousing']) ? (result['Account.AppendHousing'] === 'true') : false;
                settings.AppendInterest = (result['Account.AppendInterest']) ? (result['Account.AppendInterest'] === 'true') : false;
                settings.AppendPurchase = (result['Account.AppendPurchase']) ? (result['Account.AppendPurchase'] === 'true') : false;

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