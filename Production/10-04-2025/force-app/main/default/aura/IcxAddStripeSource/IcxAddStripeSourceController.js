({
    doInit : function(component, event, helper) {
        $A.util.addClass(component.find("message"), "slds-hide");  
        
        helper.apex(component, "c.getAccount", {
            ContractId:component.get('v.Contract').Id
        }).then(function(result){
            console.log("completed","c.getAccount")
            component.set("v.Account",result);
            component.set("v.AccountId",result.Id);
        }).catch(function(errors) {
            component.set("v.error",errors)
            $A.util.removeClass(component.find("message"), "slds-hide");
        });
    },
    initSepa : function(component, event, helper) {
        component.set("v.sourceType","sepa_debit");
    },
    initCard : function(component, event, helper) {
        component.set("v.sourceType","card");
    },
    addSource : function(component, event, helper) {
        component.set("v.showSpinner",true);
        
        helper.apex(component, "c.updateContactInfo", {
            accId: component.get('v.Account').Id, 
            ContactEmail:component.get('v.Account').PersonEmail, 
            ContactName:component.get('v.Account').Name
        }).then($A.getCallback(function(result) {
            console.log("completed","c.updateContactInfo", result)
            var source = {
                "type" :component.get("v.sourceType"),
                "currency" : 'EUR',
                "owner" : {
                    "name" : component.find("name").get("v.value"),
                    "email" : component.find("email").get("v.value"),
                    "address" : {
                        "line1" : component.find("line1").get("v.value"),
                        "city" : component.find("city").get("v.value"),
                        "postal_code" : component.find("postal_code").get("v.value"),
                        "country" : component.find("country").get("v.value")
                    }
                }
            }
            
            if(source["type"] == "sepa_debit") source["sepa_debit"] = { "iban" : component.find("IBAN").get("v.value")};
            else source["card"] = { "number" : component.find("number").get("v.value"), "cvc" : component.find("cvc").get("v.value"), "exp_month" : component.find("exp_month").get("v.value"), "exp_year" : component.find("exp_year").get("v.value")};
            
            let obj = helper.toUrl(source,null,helper)
            let contract = JSON.stringify(component.get("v.Contract"));
            return helper.apex(component, 'c.createSourceAndCustomer', {
                contractJson : contract, 
                sourcePayload : obj
            });
        })).then(function(result){
            console.log("completed","c.createSourceAndCustomer")
            return helper.apex(component, 'c.createDepositAndSubscription', {
                opportunityId : component.get("v.Contract").Opportunity__c
            });
        }).then(function(result){
            console.log("completed","c.createDepositAndSubscription")
            const Contract = component.get('v.Contract');
            Contract.Community_Step__c = '3';
            component.set('v.Contract', Contract);
            component.set('v.pathStep', '3')
            
        })
        .catch(function(errors) {
            helper.showError(errors)
            component.set("v.showSpinner",false);
        });
        
        
    }
})