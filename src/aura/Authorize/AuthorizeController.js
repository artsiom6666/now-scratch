({
	doInit : function(component, event, helper) {
		component.set('v.showSpinner', true);
		helper.getValuesForPicklist(component);
		helper.getAmountToAuthorize(component);
	},

	authorizeClick : function(component, event, helper) {
		component.set('v.showSpinner', true);
		helper.authorize(component);
	},

	cancelClick: function(component, event, helper) {
		component.set('v.showSpinner', true);
		helper.cancel(component);
	}
})