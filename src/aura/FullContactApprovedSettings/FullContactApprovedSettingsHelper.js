({
	getSettingsHelper: function(component) {
		component.set('v.showSpinner', true);

		var getSettingsApex = component.get('c.getFcApprovedSettingsApex');

		var getUsersApex = component.get('c.getFcApprovedUsersApex');

		getUsersApex.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                //console.log(result);
                result.unshift({Id: '', Name: 'None'});
                component.set('v.users', result);
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(getUsersApex);

		getSettingsApex.setCallback(this, function(response) {
			var state = response.getState();
			if (component.isValid() && state === 'SUCCESS') {
				var result = response.getReturnValue();
                result = JSON.parse(result);
                //console.log(result);
                var settings = {};
                settings.FCLimit = (result.FCLimit) ? +result.FCLimit : 0;
                settings.Excess = (result.Excess) ? +result.Excess : 0;
                settings.Approver1 = (result.Approver1) ? result.Approver1 : {Id: '', Name: 'None'};
                settings.Approver2 = (result.Approver2) ? result.Approver2 : {Id: '', Name: 'None'};
                settings.Approver3 = (result.Approver3) ? result.Approver3 : {Id: '', Name: 'None'};

				component.set('v.settings', settings);
			}
			component.set('v.showSpinner', false);
		});
		$A.enqueueAction(getSettingsApex);
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