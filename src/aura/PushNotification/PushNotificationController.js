({
    initialize: function (component, event, helper) {
        helper.getTopics(component);
        helper.getAccounts(component);
        helper.getEnvironments(component);
        helper.getIcons(component);
        helper.getClickActions(component);
    },
    getAccounts: function (component, event, helper) {
        helper.getAccounts(component);
    },
    getTopicsInfo: function (component, event, helper) {
        helper.getAccounts(component);
        helper.getTopicsInfo(component);
    },
    getIcons: function (component, event, helper) {
        helper.getIcons(component);
        component.set('v.showUploadIcon', false);
    },
    send: function (component, event, helper) {
        helper.send(component);
    },
    saveClickAction: function (component, event, helper) {
        helper.saveClickAction(component);
    },
    handleChangeTopic: function (component, event) {
        // Get the list of the "value" attribute on all the selected options
        var selectedOptionsList = event.getParam("value");
        var topic = component.get('v.topic');

        if (topic !== 'null' && topic !== undefined) {

            var availableTopics = component.get('v.availableTopics');
            var topicName;
            for (var i = 0; i < availableTopics.length; i++) {
                if (availableTopics[i].value === topic) {
                   topicName = availableTopics[i].label;
                   break;
                }
            }
            component.set('v.topicName', topicName);
        }
    },
    onCheckDevice: function (component, event) {
        // Get the list of the "value" attribute on all the selected options
        var selectedValue = event.getSource().get("v.value");
        var selectedLabel = event.getSource().get("v.label");
        var environments = component.get('v.environments');
        var environment = {
            label : selectedLabel,
            value : selectedValue
        }

        for (var i = 0; i < environments.length; i++) {
            if (environments[i].value === selectedValue) {
               environments.splice(i, 1);
               return;
            }
        }

        environments.push(environment);
        component.set('v.environments', environments);
    },
    onCheckAccount: function (component, event) {
        var isAll = component.get('v.isAll');
        var isParticular = component.get('v.isParticular');
        var selectedLabel = event.getSource().get("v.label");

        if (selectedLabel.indexOf('All') > - 1) {
            isAll = !isAll;
            isParticular = false;
            var chosenAccounts = component.get('v.chosenAccounts');
            chosenAccounts = [];
            component.set('v.chosenAccounts', chosenAccounts);
        }
        else {
            isParticular = !isParticular;
            isAll = false;
        }

        component.set('v.isParticular', isParticular);
        component.set('v.isAll', isAll);
    },
    onSaveTopic: function (component, event) {
        var isSaveTopic = component.get('v.isSaveTopic');
        component.set('v.isSaveTopic', !isSaveTopic);
    },
    closeConfirmMsgCancel: function (component, event) {
        component.set('v.showConfirmMessage', false);
    },
    closeConfirmMsgNo: function (component, event, helper) {
        component.set('v.showConfirmMessage', false);
    },
    closeConfirmMsgYes: function (component, event, helper) {
        component.set('v.showConfirmMessage', false);
        component.set('v.topicName', component.get('v.title'));
        helper.send(component);
    },
    saveTopic: function (component, event, helper) {
        helper.saveTopic(component);
    },
    closeMessage: function (component, event, helper) {
        component.set('v.showErrorMessage', false);
        component.set('v.showSuccessMessage', false);
    },
    showUploadIcon: function (component, event, helper) {
        component.set('v.showUploadIcon', true);
        component.set('v.icon', 'null');
        window.open(window.location.protocol + '//' + window.location.hostname + '/015/o');
    },
    hideUploadIcon: function (component, event, helper) {
        component.set('v.showUploadIcon', false);
    },
    showAddAction: function (component, event, helper) {
        component.set('v.showAddAction', true);
    },
    hideAddAction: function (component, event, helper) {
        component.set('v.showAddAction', false);
    },
})