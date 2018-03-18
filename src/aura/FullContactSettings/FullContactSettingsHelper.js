({
	getSettingsHelper: function(component) {
		component.set('v.showSpinner', true);

		var action = component.get('c.getFullContactSettingsApex');
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (component.isValid() && state === 'SUCCESS') {
				var result = response.getReturnValue();
				result = JSON.parse(result);
				var settings = {};
				settings.APIKey = (result['FullContact.APIKey']) ? result['FullContact.APIKey'] : '';
				settings.ReappendOnDays = (result['FullContact.ReappendOnDays']) ? result['FullContact.ReappendOnDays'] : '';
				settings.IgnoreOlderThan = (result['FullContact.IgnoreOlderThan']) ? result['FullContact.IgnoreOlderThan'] : '';
				settings.LeadAppendOnNew = (result['FullContact.LeadAppendOnNew']) ? (result['FullContact.LeadAppendOnNew'] === 'true') : false;
				settings.AccountAppendOnNew = (result['FullContact.AccountAppendOnNew']) ? (result['FullContact.AccountAppendOnNew'] === 'true') : false;
				settings.LeadAppendContactInfo = (result['FullContact.LeadAppendContactInfo']) ? (result['FullContact.LeadAppendContactInfo'] === 'true') : false;
				settings.LeadAppendLocation = (result['FullContact.LeadAppendLocation']) ? (result['FullContact.LeadAppendLocation'] === 'true') : false;
				settings.LeadAppendOrganizations = (result['FullContact.LeadAppendOrganizations']) ? (result['FullContact.LeadAppendOrganizations'] === 'true') : false;
				settings.AccountAppendContactInfo = (result['FullContact.AccountAppendContactInfo']) ? (result['FullContact.AccountAppendContactInfo'] === 'true') : false;
				settings.AccountAppendLocation = (result['FullContact.AccountAppendLocation']) ? (result['FullContact.AccountAppendLocation'] === 'true') : false;
				settings.AccountAppendOrganizations = (result['FullContact.AccountAppendOrganizations']) ? (result['FullContact.AccountAppendOrganizations'] === 'true') : false;
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