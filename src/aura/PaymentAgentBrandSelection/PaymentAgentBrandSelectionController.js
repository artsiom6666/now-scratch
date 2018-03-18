({
	doInit: function(component, event, helper) {
		helper.getPaSettingsHelper(component);
	},

	editPaSetting: function(component, event, helper) {
		helper.closeMessageHelper(component);
		var key = event.currentTarget.dataset.record;
		var paymentAgentSettings = component.get('v.settings');
		var paymentAgent2Save = paymentAgentSettings[key];

		component.set('v.paymentAgent2Save', paymentAgent2Save);
		component.set('v.showPopup', true);

	},

	saveSetting: function(component, event, helper) {
		component.set('v.showSpinner', true);
		helper.closeMessageHelper(component);
		var paymentAgent2Save = component.get('v.paymentAgent2Save');
        var paymentAgent2SaveStr = JSON.stringify(paymentAgent2Save);

        var action = component.get('c.savePaymentSettings');
        action.setParams({
            'settings': paymentAgent2SaveStr
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            //console.log(state);
            if (component.isValid() && state === 'SUCCESS') {
                if (response.getReturnValue().indexOf('success') > -1) {
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
            component.set('v.showSpinner', false);
            helper.getPaSettingsHelper(component);
            component.set('v.showPopup', false);
        });
        $A.enqueueAction(action);
	},

	showModalDeleteSetting: function(component, event) {
		var key = event.currentTarget.dataset.record;
        var paymentAgentSettings = component.get('v.paymentAgentSettings');
		key = paymentAgentSettings[key].Name;
		component.set('v.keyDeleteRecord', key);
		component.set('v.showDeleteMessage', true);
	},

	closeMessage: function(component, event, helper) {
		helper.closeMessageHelper(component, event);
	},

	closeModal: function(component, event, helper) {
		helper.getPaSettingsHelper(component);
		helper.closeMessageHelper(component, event);
		component.set('v.showPopup', false);
	},

	changeCkeckbox: function(component, event) {
		var paymentAgent2Save = component.get('v.paymentAgent2Save');
		var name = event.target.id;
		paymentAgent2Save[name] = !paymentAgent2Save[name];
		component.set('v.paymentAgent2Save', paymentAgent2Save);
	}
})