({
	doInit: function(component, event, helper) {
        console.log("showUnavailable",component.get('v.showUnavailable'))
        var getOpp = component.get('c.getOppDetails');
        getOpp.setParams({ recordId: component.get('v.recordId') })
        helper.launch(getOpp, function(error, result) {
            if (!error) {
                component.set('v.opp', result);
                if(result.Start_Date__c != null && result.City__c != null && result.Country__c != null) helper.retrieveRooms(component,helper);
            } else {
                console.log('error!');
            }
        }, true)
    },
    openItem: function(component, event, helper) {
        console.log('click openItem',event.getSource().get("v.name"))
        
        var obj = event.getSource().get("v.name");
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '/lightning/r/'+obj.split('-')[0]+'/'+obj.split('-')[1]+'/view',
            focus: true
        }).then(function(response) {
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function(tabInfo) {
                console.log("The recordId for this tab is: " + tabInfo.recordId);
            });
        }).catch(function(error) {
            console.log(error);
        });
    },
    selectThisRoom: function(component, event, helper) {
        const action = component.get('c.setRoomOnOpp')
        action.setParams({oppId:component.get('v.recordId'), RoomId:event.getSource().get("v.name")})
        helper.launch(action, function(error, result) {
            if (!error) {
                $A.get('e.force:refreshView').fire();
                component.set('v.showRoomInfo', false)
            } else {
                console.log('error!');
            }
        }, true)
    }
})