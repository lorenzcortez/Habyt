({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleSelfRegister: function (component, event, helpler) {
        
    },
    
    getExtraFields : function (component, event, helpler) {
        var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.extraFields',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    setBrandingCookie: function (component, event, helpler) {        
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
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
    },
    
    updateContract: function(component, helper) {    
        const Contract = component.get('v.Contract');
        console.log("Contract", Contract)
        const action = component.get("c.updateContract");
        action.setParams({con:Contract})
        helper.launch(action, function(error, result) {
            if (!error) {
                console.log('Updated!')
            }else {
                console.log('error updateContract!');
                console.log(error);
            }
        }, true)
    },
    getAccountInfo: function(component, helper) {
        const action = component.get("c.getAcc");
        action.setParams({accId:component.get('v.accountId')})
        helper.launch(action, function(error, result) {
            if (!error) {
                console.log('Acc == ', result)
                
                component.set('v.prefillFirstname', result.FirstName)
                component.set('v.prefillLastname', result.LastName);
                component.set('v.prefillEmail', result.PersonEmail);
            }else {
                console.log('error updateContract!');
                console.log(error);
            }
        }, true)
    },
    isUserLogged: function(component, helper) {
        console.log('isUserLogged')
        const action = component.get("c.isUserLogged");
        action.setParams({accId:component.get('v.accountId')})
        helper.launch(action, function(error, result) {
            if (!error) {
                console.log('isUserLog == ', result)
                component.set('v.UserIsLog', result)
            }else {
                console.log('error userLog!');
                console.log(error);
                component.set('v.error', error)
                $A.util.removeClass(component.find("message"), "slds-hide");  
            }
        }, true)
    },
    doesUserExist: function(component, helper) {
        console.log('doesUserExist')
        const action = component.get("c.doesUserExist");
        action.setParams({accId:component.get('v.accountId')})
        helper.launch(action, function(error, result) {
            if (!error) {
                console.log('USER EXIST == ', result)
                component.set('v.UserExist', result)
            }else {
                console.log('error userExist!');
                console.log(error);
                
                component.set('v.error', error)
                $A.util.removeClass(component.find("message"), "slds-hide");  
            }
        }, true)
    },
})