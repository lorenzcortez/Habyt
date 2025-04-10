({
    launch: function(action, cb, nostore) {
        if (!nostore) action.setStorable();
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") cb(null, response.getReturnValue())
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) cb(errors[0].message)
                    else cb(errors);
                }
            }
        });
        $A.enqueueAction(action);
    },
    getRoomsInfo: function(component, event, helper) {
        console.log('Room Init')
        const action = component.get('c.getRoomsWithStatus')
        action.setParams({oppId:component.get('v.recordId')})
        helper.launch(action, function(error, result) {
            if (!error) {
                if (result.length < 1) {
                    component.set('v.NoRoomMessage', 'No Room found with the date and critera.');
                } else {
                    console.log('result = ', JSON.parse(result))
                    component.set('v.roomsAvailable', JSON.parse(result));
                }
            } else {
                console.log('error!');
            }
        }, true)
    },
    openObjectTab: function(component, objId) {
        console.log('ObjId = ', objId)
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '/lightning/r/Opportunity/'+objId+'/view',
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
})