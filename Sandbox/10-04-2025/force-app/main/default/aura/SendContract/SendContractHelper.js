({
    launch: function(action, cb, nostore) {
        if(!nostore) action.setStorable();
        
        action.setCallback(this, (response) => {
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
    prepareEmail: function(cmp, email) {
        
        var action = cmp.get("c.getTemplate");
        action.setParams({ tplId : "00X1i000000gvSaEAI" });
        
        
        this.launch(action,function(error, result){
            if(error) console.log(error);
            else {
                console.log('success')
                var actionAPI = cmp.find("quickActionAPI");
                var args = { 
                    actionName : "SendEmail", 
                    entityName : "Opportunity",
                    targetFields : {
                        //ToAddress: {value: opp.OpportunityContactRoles[0].Contact.Email},
                        ToAddress: {value: email},
                        HtmlBody : { value : result.HtmlValue},
                        Subject : { value : result.Subject}
                    }
                };
                
                console.log('args = ', args)
                
                //doesn't work without
                actionAPI.selectAction(args).then(function(result) {
                    console.log(' work without')
                    console.log(result)
                }).catch(function(e) {
                    console.log(e)
                });
                
                actionAPI.setActionFieldValues(args).then(function(result) {
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }).catch(function(e) {
                    console.error(e);
                });
            }
            
        },true);
    }
})