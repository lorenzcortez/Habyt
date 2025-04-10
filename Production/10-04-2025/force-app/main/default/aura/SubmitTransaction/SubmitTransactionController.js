({
    confirm : function(component, event, helper) {
        var action = component.get("c.submitTransaction");
        action.setParams({ recordId : component.get('v.recordId') })
        helper.launch(action, function(error, result) {
            if (!error) {
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            } else {
                console.log(error);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"error",
                    "title": "Error!",
                    "message": error
                });
                
                $A.get("e.force:closeQuickAction").fire();
                toastEvent.fire();
            }
        }, true)
    }
})