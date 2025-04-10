({
	init: function(cmp, event, helper) {
       // Set the validate attribute to a function that includes validation logic
       cmp.set('v.validate', function() {
           var userInput = cmp.get('v.Subject');
           console.log('userInput::'+userInput);
           if(userInput && userInput.length>0) {
               // If the component is valid...
               return { isValid: true };
           }
           else if(userInput && userInput.length>255){
				 return { isValid: false, errorMessage: 'Please keep this under 255 Characters' };               
           }
           else {
               // If the component is invalid...
               return { isValid: false, errorMessage: 'A value is required.' };
           }})
	},
    itemsChange: function(cmp, evt) {
        cmp.set("v.Subject",evt.getParam("value"));
        console.log('In Field Name::'+evt.getSource().get("v.fieldName"));
        console.log('In::::'+evt.getParam("value"));
        
        
        var appEvent = $A.get("e.selfService:caseCreateFieldChange");
        appEvent.setParams({
            "modifiedField": "Subject",
            "modifiedFieldValue": evt.getSource().get("v.value")
        });

        appEvent.fire();
       
    }
})