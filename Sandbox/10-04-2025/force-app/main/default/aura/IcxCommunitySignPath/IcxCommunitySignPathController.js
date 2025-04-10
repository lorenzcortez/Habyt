({
    doInit : function(component, event, helper) {
        var debug = true;
        var urlParams = location.search
            .slice(1)
            .split('&')
            .map(p => p.split('='))
            .reduce((obj, pair) => {
                const [key, value] = pair.map(decodeURIComponent);
                obj[key] = value;
                return obj;
            }, {});
        
        if(debug) console.log('url parameters',  urlParams)
        
        var contract;
        helper.apex(component, "c.retrievedContract", {
            signature: urlParams.signature, 
            contractId: urlParams.contractId
        }).then(function(result){
            if(debug) console.log("completed","c.retrievedContract")
            contract = JSON.parse(result)
            component.set('v.Contract', contract);
            
            if(contract.EverSign_Doc_Status__c == 'Completed' && contract.Community_Step__c == 1) contract.Community_Step__c = 2
            if(contract.Stripe_Subscription_Id__c != null && contract.Community_Step__c != 3) contract.Community_Step__c = 3
            
            component.set('v.currentStep', String(contract.Community_Step__c))

            if(contract.Community_Step__c == 0 || contract.Community_Step__c == 1) {
                
                return helper.apex(component, 'c.getEversignDocument', {
                    EverSign_Doc_Hash : contract.EverSign_Doc_Hash__c
                }); 
            } 
            
        })
        .then(function(result){
            if(contract.Community_Step__c == 0 || contract.Community_Step__c == 1) {
                if(debug) console.log("completed","c.getEversignDocument",JSON.parse(result))
				var eversignResponse = JSON.parse(result);
                if(eversignResponse.error) component.set("v.error",'Error loading your contract:' +eversignResponse.error.type);
                else {
                    component.set('v.currentStep', String(contract.Community_Step__c))
                    component.set('v.eversignDocUrl',eversignResponse.signers[0].embedded_signing_url);       
                }
                
            }
        })
        .catch(function(errors) {
            console.log('init error',errors[0].message)
            component.set("v.error",errors[0].message)
        });
        
        //Eversign Event Handler
        var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
        var eventer = window[eventMethod];
        var messageEvent = eventMethod == "attachEvent" ? "onmessage" : "message";
        
        eventer(messageEvent,function(e) {
            var key = e.message ? "message" : "data";
            var data = e[key];
            if(debug) console.log('everSignEvent', e, data)
            switch (data) {
                case 'event_loaded':
                    $A.util.addClass(component.find("spinner"), "slds-hide");
                    break;
                    
                case 'event_signed':
                    contract.EverSign_Doc_Status__c = 'Completed';
                    contract.Community_Step__c = 2;
                    helper.apex(component, 'c.updateContract', {
                        data : JSON.stringify(contract)
                    }).then(function(result){
                        if(debug) console.log('everSignEvent', 'signed completed' )
                        component.set('v.currentStep', '2')
                    })
                    .catch(function(error) {
                        component.set("v.error",error)
                    });
                    break;
                    
                case 'event_declined':
                    contract.EverSign_Doc_Status__c = 'Cancelled';
                    helper.apex(component, 'c.updateContract', {
                        data : JSON.stringify(contract)
                    }).then(function(result){
                        if(debug) console.log('everSignEvent', 'declined completed' )
                        component.set('v.error', 'Your contract is canceled,  you can close this window');
                    })
                    .catch(function(error) {
                        component.set("v.error",error)
                    });
                    break;
                    
                case 'event_error':
                    component.set('v.error', 'Error Loading your document.<br/>Contact the support')
                    break;
            }
            
        }, false);
    }
})