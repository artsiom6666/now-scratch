({
	getSettingsHelper: function(component) {
		component.set('v.showSpinner', true);

		var action = component.get('c.getLeadSettingsApex');
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (component.isValid() && state === 'SUCCESS') {
				var result = response.getReturnValue();
                result = JSON.parse(result);
                var settings = {};
                settings.ValidateEmail = (result['Lead.ValidateEmail']) ? (result['Lead.ValidateEmail'] === 'true') : false;
                settings.CorrectEmail = (result['Lead.CorrectEmail']) ? (result['Lead.CorrectEmail'] === 'true') : false;
                settings.AppendNameAddress = (result['Lead.AppendNameAddress']) ? (result['Lead.AppendNameAddress'] === 'true') : false;
                settings.EnableDemographics = (result['Lead.EnableDemographics']) ? (result['Lead.EnableDemographics'] === 'true') : false;
                settings.EmailActivityMetrics = (result['Lead.EmailActivityMetrics']) ? (result['Lead.EmailActivityMetrics'] === 'true') : false;
                settings.AppendDemographicBasics = (result['Lead.AppendDemographicBasics']) ? (result['Lead.AppendDemographicBasics'] === 'true') : false;
                settings.AppendHousing = (result['Lead.AppendHousing']) ? (result['Lead.AppendHousing'] === 'true') : false;
                settings.AppendInterest = (result['Lead.AppendInterest']) ? (result['Lead.AppendInterest'] === 'true') : false;
                settings.AppendPurchase = (result['Lead.AppendPurchase']) ? (result['Lead.AppendPurchase'] === 'true') : false;

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