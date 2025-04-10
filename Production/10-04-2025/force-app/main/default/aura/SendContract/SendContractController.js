({
	doInit : function(component, event, helper) {
        console.log('DoINIT')
        console.log('00X9E000001N8dvUAC')
        console.log('RECORD ID = ', component.get('v.recordId'))
        const action  = component.get('c.getAccountEmail')
        action.setParams({oppId:component.get('v.recordId')})
        helper.launch(action, function(error, result) {
             if(error) console.log(error);
            else {
                console.log('Email == ', result)
                helper.prepareEmail(component, result);
            }
        }, true) 
    	
    }
})