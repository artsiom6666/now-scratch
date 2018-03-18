({
	getSettingsHelper: function(component) {
		component.set('v.showSpinner', true);

        var getSettingsApex = component.get('c.getPaymentConnectSettingsApex');
        getSettingsApex.setCallback(this, function(response) {
            var state = response.getState();

            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();

                var settings = JSON.parse(result);
                settings.paymentAgentId = (settings.paymentAgentId === null) ? ' ' : settings.paymentAgentId;
                settings.PaymentAgentLabel = 'None';

                var getPaymentOptions = component.get('c.getPaymentOptions');
                    getPaymentOptions.setCallback(this, function(funcResponse) {
                        var respState = funcResponse.getState();

                        if (component.isValid() && respState === 'SUCCESS') {
                            var options = JSON.parse(funcResponse.getReturnValue());


                            options.some(function(option) {

                                if (option.key === settings.paymentAgentId) {

                                    settings.PaymentAgentLabel = (settings.paymentAgentId) ? option.value : 'None';
                                    return true;
                                }
                                return false;

                            });


                            options.unshift({ key: "", value: "None"});
                            component.set('v.paymentOptions', options);
                            component.set('v.settings', settings);
                        }
                        component.set('v.showSpinner', false);
                    });
                $A.enqueueAction(getPaymentOptions);

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
        component.set('v.showCancelMessage', false);
        component.set('v.showSuccessMessage', false);
	}
})