({
	doInit: function(component, event, helper) {
		component.set('v.showSpinner', true);
		helper.getAmountToVoid(component);
	},

	voidClick : function(component, event, helper) {
		component.set('v.showSpinner', true);
		helper.doVoid(component);
	},

	cancelClick : function(component, event, helper) {
		helper.cancel(component);
	}
})