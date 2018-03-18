({
	doInit: function(component, event, helper) {
		component.set('v.showSpinner', true);
		helper.getSettingsHelper(component);
	},

	linkOrg: function(component, event, helper) {
        var endpoint = component.get('v.endpoint');

		var action = component.get('c.linkAuthorizeEndpointToken');

		if (!endpoint.clientIdEndpoint) {
			component.set('v.showErrorMessage', true);
			component.set('v.textMessage', 'API Key Id can not be blank!');
			setTimeout(function() {
				component.set('v.showErrorMessage', false);
			}, 2000);
			return;
		}

        if (!endpoint.clientSecretEndpoint) {
			component.set('v.showErrorMessage', true);
			component.set('v.textMessage', 'API Key Secret can not be blank!');
			setTimeout(function() {
				component.set('v.showErrorMessage', false);
			}, 2000);
			return;
		}

		action.setParams({
			'credentials': JSON.stringify(endpoint)
		});
		action.setCallback(this, function(response) {
			helper.responseHandler(component, event, response);
		});
		$A.enqueueAction(action);
	},

	unlinkOrg: function(component, event, helper) {
		var action = component.get('c.unlinkAuthorizeEndpointToken');

		action.setCallback(this, function(response) {
			helper.responseHandler(component, event, response);
		});
		$A.enqueueAction(action);
	},

	edit: function(component, event, helper) {
		var isLinked = component.get('v.isLinked');
		helper.closeMessageHelper(component);

		if (isLinked === 'Linked') {
			component.set('v.showUnlinkMessage', true);
		} else {
			component.set('v.edit', true);
		}

	},

	cancel: function(component, event, helper) {
		helper.closeMessageHelper(component);
		component.set('v.edit', false);
		component.set('v.showUnlinkMessage', false);
	}
})