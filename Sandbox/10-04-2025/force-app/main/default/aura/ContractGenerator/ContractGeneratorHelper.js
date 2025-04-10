({
    save: function(component,helper) {
        var action = component.get('c.saveContract')
        action.setParams({ recordId: component.get('v.recordId') })
        helper.launch(action, function(error, result) {
            if (!error) {
                component.set('v.contractId',result)
                helper.createStripePlan(component,helper,result)
            } else {
                console.error('SaveError',JSON.stringify(error))
                component.set('v.errorMessage','Error inserting contract, contact your admin');
                $A.util.toggleClass(component.find('errorMessageDisplay'), "slds-hide");
            }
        }, true)
    },
    createStripePlan: function(component,helper,contractId) {
        var action = component.get('c.generateStripePlan')
        action.setParams({ recordId: contractId })
        helper.launch(action, function(error, result) {
            if (!error) {
                helper.eversignPush(component,helper,contractId)
            } else {
                console.error('createStripePlan',JSON.stringify(error))
                component.set('v.errorMessage','Error setting up stripe plan, contact your admin\n'+error);
                $A.util.toggleClass(component.find('errorMessageDisplay'), "slds-hide");
            }
        }, true)
    },
    eversignPush: function(component,helper,contractId) {
        var action = component.get('c.pushToEversign')
        action.setParams({ recordId: contractId })
        helper.launch(action, function(error, result) {
            if (!error) {
                helper.prepareEmail(component);
                $A.get('e.force:refreshView').fire();
                
            } else {
                console.error('eversignPush',JSON.stringify(error))
                component.set('v.errorMessage','Error sending contract to eversign, contact your admin\n'+error);
                $A.util.toggleClass(component.find('errorMessageDisplay'), "slds-hide");
            }
        }, true)
    },
    prepareEmail: function(cmp) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        var action = cmp.get("c.getEmailData");
        action.setParams({ tplId : "00X1i000000gvSaEAI", recordId : cmp.get('v.recordId') });
        
        this.launch(action,function(error, result){
            if(error) {
                console.error('prepareEmail 1',JSON.stringify(error))
                cmp.set('v.errorMessage','Error preparing email (You can send the Community URL directly)\n'+error);
                $A.util.removeClass(cmp.find('errorMessageDisplay'), "slds-hide");
            } else {
                
                var actionAPI = cmp.find("quickActionAPI");
                var args = { 
                    actionName : "SendEmail", 
                    entityName : "Opportunity",
                    targetFields : {
                        ToAddress: {value: result.email},
                        HtmlBody : { value : result.HtmlValue},
                        Subject : { value : result.subject}
                    }
                };
                
                
                actionAPI.setActionFieldValues(args).then(function(result) {
                    console.log('Action API OK',result)
                    component.set('v.working', false);
                    dismissActionPanel.fire();
                }).catch(function(e) {
                    dismissActionPanel.fire();
                    console.log('Action API Error',e)
                    console.error('prepareEmail 2',JSON.stringify(e))
                    //cmp.set('v.errorMessage','Error preparing email (You can send the Community URL directly)\n'+JSON.stringify(e));
                    //$A.util.removeClass(cmp.find('errorMessageDisplay'), "slds-hide");
                });
            }
            
        },true);
    },
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
    }
})