({
    doInit: function(component, event, helper) {
        console.log('Room Init')
        helper.getRoomsInfo(component, event, helper)
    },
    reloadInfo: function(component, event, helper) {
        helper.getRoomsInfo(component, event, helper)
    },
    searchForRooms: function(component, event, helper) {
        console.log('Recuperer la List des Legs')
        component.set('v.showRoomInfo', false)
        let action = component.get('c.getRoomsAvailable')
        action.setParams({NewRoomStartDate:component.get('v.startDate'), Months:component.get('v.month')})
        helper.launch(action, function(error, result) {
            if (!error) {
                if (result.length < 1) {
                    component.set('v.NoRoomMessage', 'No Room found with the date and critera.');
                } else {
                    console.log('result = ', result)
                    component.set('v.roomsAvailable', result);
                }
            } else {
                console.log('error!');
            }
        }, true)
    },
    showRoom: function(component, event, helper) {
        const roomId = event.currentTarget.dataset.rowRoom;
        const propId = event.currentTarget.dataset.rowProp;
        const contractId = event.currentTarget.dataset.rowContract;
        
        component.set('v.roomPropId', propId)
        component.set('v.roomId', roomId)
        component.set('v.contractId', contractId)
        component.set('v.showRoomInfo', true)
    },
    showList: function(component, event, helper) {
        component.set('v.showRoomInfo', false)
        
    },
    selectThisRoom: function(component, event, helper) {
        const action = component.get('c.setRoomOnOpp')
        action.setParams({oppId:component.get('v.recordId'), RoomId:component.get('v.roomId')})
        helper.launch(action, function(error, result) {
            if (!error) {
                $A.get('e.force:refreshView').fire();
                component.set('v.showRoomInfo', false)
            } else {
                console.log('error!');
            }
        }, true)
    },
    handleSuccess: function(component, event, helper) {
        helper.getRoomsInfo(component, event, helper)
    },
    roomChange: function(component, event, helper) {
        console.log('Room Id =', component.get('v.roomId'))
        component.set('v.showOpps', false);
        let action = component.get('c.getOppsOnThisRoom')
        action.setParams({roomId:component.get('v.roomId'), actualOpp:component.get('v.recordId')})
        helper.launch(action, function(error, result) {
            if (!error) {
                console.log('Opps = ', result)
                if (result.length > 0) {
                    if (result.length > 1) component.set('v.MessageOpp', 'This Room is also preselected on some others Opportunities :')
                    else component.set('v.MessageOpp', 'This Room is also preselected on one other Opportunity :')
                    component.set('v.Opps', result);
                    component.set('v.showOpps', true);
                    
                }
            } else {
                console.log('error!');
            }
        }, true)
    },
    oppSelected : function(component, event, helper) {
        var Id = event.currentTarget.dataset.rowId;
		console.log('Id = ', Id);
        helper.openObjectTab(component, Id);
    },
})