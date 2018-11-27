({
    doInit: function(component, event, helper) {
        helper.frameApexInput(component, event);
    },

    valueChanged: function(component, event, helper) {
        //console.log('Apex input is ', component.get('v.apexInput'));
        try {
            var accCmp = component.find('acch');
            var evt = accCmp.getEvent('rebuildhierarchy');
            evt.fire();
        } catch (e) {
            //console.log('Exception in firing event is', e);
        }

    },

    rootNodeClicked: function(component, event, helper) {
        var node = event.getParam('node');
        //window.location = '/one/one.app/sObject/' + node.id + '/view';
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": node.id,
            "slideDevName": "detail"
        });
        navEvt.fire()
    },

    leftIconClicked: function(component, event, helper) {
        var node = event.getParam('node');
        var data = JSON.parse(node.data);
        //window.location = 'tel:' + data.phone;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": 'tel:' + data.phone
        });
        urlEvent.fire();
    },

    righticonclicked: function(component, event, helper) {
        var node = event.getParam('node');
        var data = JSON.parse(node.data);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": data.website
        });
        urlEvent.fire();

    },

    nodeClicked: function(component, event, helper) {

    }


})