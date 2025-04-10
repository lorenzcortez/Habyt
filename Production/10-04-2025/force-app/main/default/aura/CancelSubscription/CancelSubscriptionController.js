({
    init : function(component, event, helper) {
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
    },
    CancelSubscriptionButton : function(component, event, helper) {
        const action = component.get("c.CancelSubscription");
        action.setParams({
            contractId:component.get('v.recordId'),
            cancelDate:component.get('v.CancelDate'),
            moveoutDate:component.get('v.OutDate'),
            cancelMembership:component.get("v.Checkbox")
        })
        helper.launch(action, function(error, result) {
            if (!error) {
                //console.log('Result == ', result)
                if (result != 'OK') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":"error",
                        "title": "Error!",
                        "message": result
                    });
                    
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                    toastEvent.fire();
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":"success",
                        "title": "Success!",
                        "message": 'Cancel Date as been updated!'
                    });
                    
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                    toastEvent.fire();
                }
            }else {
                console.log('error userLog!');
                console.log(error);
            }
        }, true)
    }
})