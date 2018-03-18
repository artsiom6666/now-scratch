({
	getSettingsHelper: function(component) {
		component.set('v.showSpinner', true);

		var action = component.get('c.getRpSettingsApex');
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (component.isValid() && state === 'SUCCESS') {
				var result = response.getReturnValue();
                result = JSON.parse(result);
                var settings = {};
                settings.selectedStateRefundPeriod = (result['Batch.RefundPeriodStatus']) ? result['Batch.RefundPeriodStatus'] : 'Off';
                settings.selectedExecuteAtRefundPeriod = (result['Batch.RefundPeriodTime']) ? result['Batch.RefundPeriodTime'] : '1';
                settings.selectedExecuteAtRefundPeriodDay = (result['Batch.RefundPeriodDay']) ? result['Batch.RefundPeriodDay'] : '0';
                settings.selectedRefundPeriodValue = (result['Batch.RefundPeriodValue']) ? result['Batch.RefundPeriodValue'] : '14';
				component.set('v.settings', settings);
			}
			component.set('v.showSpinner', false);
		});
		$A.enqueueAction(action);

		var getTime = component.get('c.getRpTimeScheduleJobs');
        getTime.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                result = JSON.parse(result);
                var timeScheduleJob = {};
                if (result.nextRunTime) {
                    var d = new Date(result.nextRunTime);
                    d.setHours(d.getHours() + 1);
                    timeScheduleJob.nextRunTime = ("0" + d.getDate()).slice(-2) + "-" + ("0" + (d.getMonth() + 1)).slice(-2) + "-" + d.getFullYear() + " " + (("0" + d.getHours()).slice(-2)) + ":" + ("0" + d.getMinutes()).slice(-2);
                }

                component.set('v.timeScheduleJob', timeScheduleJob);
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(getTime);
	},

	responseHandler: function(component, event, response) {
		var state = response.getState();
		if (component.isValid() && state === 'SUCCESS') {
			if (response.getReturnValue().indexOf('success') > -1 || response.getReturnValue().indexOf('Success') > -1 ) {
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
	}
})