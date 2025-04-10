({
    doInit : function(component, event, helper) {
        helper.loadURL(component, event, helper);
    },

    doAgree: function(component, event, helper) {
        console.log('doAgree');
        helper.agreeAction(component,event, helper);
    },

   
})