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
    retrieveRooms: function(component, helper) {
        var action = component.get('c.getRooms');
        var opp = component.get('v.opp');
        action.setParams({ 
            city : opp.City__c,
            country: opp.Country__c,
            recordId: opp.Id
        })
        helper.launch(action, function(error, result) {
            if (!error) {
                var rooms = result.map(function(r){
                    r.status = 'ok';
                    
                    if(r.Contracts__r) {
                        r.Contracts__r.forEach(function(c){
                            //if(c.StartDate <= opp.Start_Date__c && (c.Move_out_date__c == null || addDays(c.Move_out_date__c,2) > opp.Start_Date__c)) r.status = 'error';
                            if(c.StartDate <= opp.Start_Date__c && (c.Move_out_date__c == null || c.Move_out_date__c > opp.Start_Date__c)) r.status = 'error';
                            else if(c.StartDate > opp.Start_Date__c && r.status != 'error') r.status = 'warning';
                        })
                    } else if(r.Opportunities__r) r.status = 'warning';
                    
                    return r;
                })
                console.log(JSON.stringify(rooms))
                component.set('v.rooms', rooms );
                
            } else {
                console.log('error!');
            }
        }, true)
        
        function addDays(dt,days){
            var ms = dt.getTime() + (86400000 * days);
            return new Date(ms);
        }
    }
})