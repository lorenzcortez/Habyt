({
    doInit : function(component, event, helper) {
        $A.util.addClass(component.find("message"), "slds-hide");
        console.log('INIT')
		console.log('recordId = ', component.get('v.recordId'))
        
        var action = component.get("c.getMyProfileUserInfo");
        helper.launch(action, function(error, res) {
            if (!error) {
                component.set('v.Contract', JSON.parse(res))
            } else {
                component.set("v.error",error)
                $A.util.removeClass(component.find("message"), "slds-hide");
            }
        }, true)
        
    },
    initSepa : function(component, event, helper) {
        component.set("v.sourceType","sepa_debit");
    },
    initCard : function(component, event, helper) {
        component.set("v.sourceType","card");
    },
    addSource : function(component, event, helper) {
        component.set("v.error",null)
        $A.util.addClass(component.find("message"), "slds-hide");

        if(component.get("v.sourceType") == "sepa_debit" && (component.find("IBAN").get("v.value") == null || component.find("name").get("v.value") == null)) {
            component.set("v.error","Please complete all required fields")
            $A.util.removeClass(component.find("message"), "slds-hide");
            return;
        } else if(component.get("v.sourceType") == "card" && (component.find("number").get("v.value") == null || component.find("cvc").get("v.value") == null || component.find("exp_month").get("v.value") == null || component.find("exp_year").get("v.value") == null)){
            component.set("v.error","Please complete all required fields")
            $A.util.removeClass(component.find("message"), "slds-hide");
            return;
        }
        
        var source = {
            "type" :component.get("v.sourceType"),
            "currency" : 'EUR',
            "owner" : {
                "name" : component.find("name").get("v.value")
            }
        }
        
        if(source["type"] == "sepa_debit") source["sepa_debit"] = { "iban" : component.find("IBAN").get("v.value")};
        else source["card"] = { "number" : component.find("number").get("v.value"), "cvc" : component.find("cvc").get("v.value"), "exp_month" : component.find("exp_month").get("v.value"), "exp_year" : component.find("exp_year").get("v.value")};
        
        //console.log("source",source)
        let obj = helper.toUrl(source,null,helper)
        
        var action = component.get("c.createSourceAndCustomer");
        let contract = JSON.stringify(component.get("v.Contract"));

        action.setParams({
            contractJson : contract, 
            sourcePayload : obj
        })
        
        helper.launch(action, function(error, res) {
            if (!error) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Your payment method has been updated successfully",
                    "type": "success"
                });
                toastEvent.fire();
            } else {
                component.set("v.error",error)
                $A.util.removeClass(component.find("message"), "slds-hide");
            }
        }, true)
        
    }
})