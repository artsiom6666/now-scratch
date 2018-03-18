({
	doInit: function(component, event, helper) {
		component.set('v.showSpinner', true);
		helper.getAmountToRefund(component);
	},

	refundClick : function(component, event, helper) {
		component.set('v.showSpinner', true);
		helper.doRefund(component);
	},

	cancelClick : function(component, event, helper) {
		helper.cancelClick(component);
	}
})