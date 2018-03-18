({
	getPaSettingsHelper: function(component) {
		component.set('v.showSpinner', true);

		var getSettingsApex = component.get('c.getPaymentSettingsApex');
		getSettingsApex.setCallback(this, function(response) {
			var state = response.getState();

			if (component.isValid() && state === 'SUCCESS') {
				var result = response.getReturnValue();

                var settings = JSON.parse(result);

                var getPaymentOptions = component.get('c.getPaymentOptions');
                    getPaymentOptions.setCallback(this, function(funcResponse) {
                        var respState = funcResponse.getState();

                        if (component.isValid() && respState === 'SUCCESS') {
                            var options = JSON.parse(funcResponse.getReturnValue());

                            settings.forEach(function(setting) {

                                options.some(function(option) {

                                    if (option.key === setting.gatewayId) {

                                        setting.gatewayIdLabel = (setting.gatewayId) ? option.value : 'None';
                                        return true;
                                    }
                                    return false;

                                });

                            });

                            options.unshift({ key: "", value: "None"});
                            component.set('v.paymentOptions', options);
                            component.set('v.settings', settings);
                        }
                        component.set('v.showSpinner', false);
                    });
                $A.enqueueAction(getPaymentOptions);

                var getProfOptions = component.get('c.getPaymentProfOptions');
                    getProfOptions.setCallback(this, function(funcResponse) {
                        var respState = funcResponse.getState();

                        if (component.isValid() && respState === 'SUCCESS') {
                            var options = JSON.parse(funcResponse.getReturnValue());
                            settings.forEach(function(setting) {

                                options.some(function(option) {

                                    if (option.key === setting.commValue) {

                                        setting.commValueLabel = (setting.commValue) ? option.value : 'None';
                                        return true;
                                    }
                                    return false;

                                });

                            });
                            options.unshift({ key: "", value: "None"});
                            component.set('v.profOptions', options);
                            component.set('v.settings', settings);
                        }
                        component.set('v.showSpinner', false);
                    });
                $A.enqueueAction(getProfOptions);
			}
			component.set('v.showSpinner', false);
		});
		$A.enqueueAction(getSettingsApex);

	},

	closeMessageHelper: function(component) {
		component.set('v.showErrorMessage', false);
		component.set('v.showSuccessMessage', false);
	}
})