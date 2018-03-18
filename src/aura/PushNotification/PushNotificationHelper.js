({
    getEnvironments : function(component) {
        component.set('v.showSpinner', true);
        var action = component.get('c.getEnvironmentsApex');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                    result = JSON.parse(result);
                component.set("v.availableEnvironments", result);

            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    getTopics : function(component) {
        component.set('v.showSpinner', true);

        var action = component.get('c.getTopicsApex');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                    result = JSON.parse(result);
                component.set("v.availableTopics", result);
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
	getAccounts : function(component) {
        var topic = component.get('v.topic');
        var environment = component.get('v.environment');
        var availableEnvironments = component.get('v.availableEnvironments');
        var recordId = component.get('v.recordId');
        var searchTerm = component.get('v.searchTerm');
        var chosenAccountIds = component.get('v.chosenAccounts');
        var availableAccounts = component.get('v.availableAccounts');
        var allAccounts = component.get('v.allAccounts');
        var environmentName;

        for (var i = 0; i < availableEnvironments.length; i++) {
            if (availableEnvironments[i].value === environment) {
               environmentName = availableEnvironments[i].label;
               break;
            }
        }

        var action = component.get('c.getAccountsApex');
        action.setParams({
            'topicId': topic,
            'environmentName': environmentName,
            'recordId': recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {

                var result = response.getReturnValue();
                    result = JSON.parse(result);

                component.set("v.allAccounts", allAccounts);
                component.set("v.availableAccounts", allAccounts);

                if (topic !== null && topic !== undefined && topic !== 'null') {
                    var selectedValues = [];
                    for (var i = 0; i < result.length; i++) {
                        selectedValues.push(result[i].value);
                    }
                    component.set("v.chosenAccounts", selectedValues);
                }
                else if (searchTerm) {

                    availableAccounts = allAccounts.filter(o => chosenAccountIds.some(v => v === o.value));

                    for (var i = 0; i < allAccounts.length; i++) {

                        if (allAccounts[i].label.startsWith(searchTerm) && !availableAccounts.find(o => o.value === allAccounts[i].value)) {
                            availableAccounts.push(allAccounts[i]);
                        }
                    }
                    component.set("v.availableAccounts", availableAccounts);
                    component.set("v.chosenAccounts", chosenAccountIds);
                }
                else {
                    component.set("v.allAccounts", result);
                    component.set("v.availableAccounts", result);
                }

            }
        });
        $A.enqueueAction(action);
    },
    getTopicsInfo : function(component) {

        var topic = component.get('v.topic');

        var action = component.get('c.getTopicsInfoApex');
        action.setParams({
            'topicId': topic
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                    result = JSON.parse(result);

                component.set("v.title", result.title);
                component.set("v.body", result.body);
                component.set("v.icon", result.icon);
                component.set("v.clickAction", result.clickAction);
                component.set('v.isAll', result.isAll);
                component.set('v.isParticular', !result.isAll);
            }
        });
        $A.enqueueAction(action);
    },
    getIcons : function(component) {
        component.set('v.showSpinner', true);

        var action = component.get('c.getIconsApex');
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                    result = JSON.parse(result);
                component.set("v.icons", result);

            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    getClickActions : function(component) {
        component.set('v.showSpinner', true);

        var action = component.get('c.getClickActionsApex');
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                    result = JSON.parse(result);
                component.set("v.clickActions", result);

            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    send : function(component) {
        component.set('v.showSpinner', true);

        var notification = {
            chosenAccounts : component.get('v.chosenAccounts'),
            availableAccounts : component.get('v.availableAccounts'),
            title : component.get('v.title'),
            body : component.get('v.body'),
            topicName : component.get('v.topicName'),
            topic : component.get('v.topic'),
            environments : component.get('v.environments'),
            recordId : component.get('v.recordId'),
            icon : component.get('v.icon'),
            clickAction : component.get('v.clickAction'),
            isAll : component.get('v.isAll'),
            isSaveTopic : component.get('v.isSaveTopic')
        }

        if (notification.environments.length === 0) {
            component.set('v.showSpinner', false);
            component.set('v.showErrorMessage', true);
            component.set('v.textMessage', 'Please select at least one Device!');
            return;
        }

        if (notification.recordId) {
            notification.chosenAccounts = [];
            notification.chosenAccounts.push(notification.availableAccounts[0].value);
        }

        if (notification.chosenAccounts.length === 0 && !notification.isAll) {
            component.set('v.showSpinner', false);
            component.set('v.showErrorMessage', true);
            component.set('v.textMessage', 'Please select Recipients!');
            return;
        }
        if (notification.isAll) {
            notification.topicName = notification.title;
            notification.chosenAccounts = [];
            this.saveTopic(component, notification);
        }
        else if (notification.isSaveTopic) {
            notification.topicName = notification.title;
            this.saveTopic(component, notification);
        }
        else {
            this.sendHandler(component, notification);
        }
        component.set('v.topic', null);
        console.log(component.get('v.topic'));
    },
    saveClickAction : function(component) {
        var action = component.get('c.saveClickActionApex');

        var clickAction2SaveName = component.get('v.clickAction2SaveName');
        var clickAction2SaveLink = component.get('v.clickAction2SaveLink');

        action.setParams({
            'name': clickAction2SaveName,
            'link': clickAction2SaveLink
        });
        action.setCallback(this, function(response) {
            component.set('v.showAddAction', false);
            this.getClickActions(component);
            this.responseHandler(component, response);
        });
        $A.enqueueAction(action);
    },
    sendHandler : function(component, notification) {
        var action = component.get('c.sendNotification');
        action.setParams({
            'recipients': (notification.topicName)? notification.topicName : JSON.stringify(notification.chosenAccounts),
            'title': notification.title,
            'icon': notification.icon,
            'clickAction': notification.clickAction,
            'body': notification.body,
            'topicName': notification.topicName,
            'environments': JSON.stringify(notification.environments)
        });
        action.setCallback(this, function(response) {
            this.responseHandler(component, response);
        });
        $A.enqueueAction(action);
    },
    saveTopic : function(component, notification) {
        component.set('v.showSpinner', true);

        notification.chosenAccounts = (notification.chosenAccounts) ? notification.chosenAccounts : component.get('v.chosenAccounts');
        notification.topicName = (notification.topicName) ? notification.topicName : component.get('v.topicName');
        notification.availableTopics = component.get('v.availableTopics');

        var topicId;
        for (var i = 0; i < notification.availableTopics.length; i++) {
            if (notification.availableTopics[i].label === notification.topicName) {
               topicId = notification.availableTopics[i].value;
               break;
            }
        }

        if (topicId) {
            var action = component.get('c.deleteTopic');

            action.setParams({
                'environmentsSerialized': JSON.stringify(notification.environments),
                'recipients': JSON.stringify(notification.chosenAccounts),
                'topicName': notification.topicName,
                'topicId': topicId
            });

            action.setCallback(this, function(response) {
                this.getTopics(component);
                if (notification) {
                    this.saveTopicHandler(component, notification);
                }
                else {
                    this.responseHandler(component, response);
                }
            });
            $A.enqueueAction(action);
        }
        else {
            this.saveTopicHandler(component, notification);
        }
    },
    saveTopicHandler : function(component, notification) {
        component.set('v.showSpinner', true);

        var action = component.get('c.createTopic');

        action.setParams({
            'environmentsSerialized': JSON.stringify(notification.environments),
            'recipientsIds': JSON.stringify(notification.chosenAccounts),
            'topicName': notification.topicName,
            'title': notification.title,
            'icon': notification.icon,
            'clickAction': notification.clickAction,
            'body': notification.body,
        });

        action.setCallback(this, function(response) {
            this.getTopics(component);
            if (notification) {
                this.sendHandler(component, notification);
            }
            else {
                this.responseHandler(component, response);
            }
        });
        $A.enqueueAction(action);
    },
    responseHandler : function(component, response) {
        var state = response.getState();

        if (component.isValid() && state === 'SUCCESS' && response.getReturnValue().indexOf('success') > -1 ) {
            component.set('v.showSuccessMessage', true);
            component.set('v.textMessage', response.getReturnValue());
            setTimeout(function() {
                component.set('v.showSuccessMessage', false);
                component.set('v.showErrorMessage', false);
            }, 4000);
        }
        else {
            component.set('v.showErrorMessage', true);
            component.set('v.textMessage', response.getReturnValue());
        }
        component.set('v.showSpinner', false);
    }
})