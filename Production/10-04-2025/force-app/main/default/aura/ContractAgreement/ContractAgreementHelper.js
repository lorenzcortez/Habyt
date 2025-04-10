({
    loadURL : function (component,event, helper) {
       console.log('****CONTRACT ',JSON.stringify( component.get("v.contract")));
        component.set("v.showSpinner", true);
        var action = component.get("c.getURL"); 
    
        action.setParams({
            "contId":  component.get("v.contract").Id,
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('success');
                var contentDist = response.getReturnValue();
                if (contentDist != null) {
                    component.set("v.contractUrl", contentDist.DistributionPublicUrl);
                } else {
                    component.set('v.pathStep', '1');
                }
                component.set("v.showSpinner", false);
            }else if (state === "ERROR") {
                console.log("ERROR loadURL");

                var errors = response.getError();
                if (errors) {
                    console.log("Errors: " , errors);
                    if (errors[0] && errors[0].message) {

                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error on agreeAction");
                }
            }
        });

        $A.enqueueAction(action);
    },

    agreeAction : function (component,event, helper) {
        
        component.set("v.showSpinner", true);
        var action = component.get("c.activateContract"); 
    
        action.setParams({
            "contId":  component.get("v.contract").Id,
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('success');
                component.set("v.showSpinner", false);

                component.set('v.pathStep', '1');

            }else if (state === "ERROR") {
                console.log("ERROR");

                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error on agreeAction");
                }
            }
        });

        $A.enqueueAction(action);
    },

  



})