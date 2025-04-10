({
    loadcheckList: function(component, event, helper) {
        // call the helper function for fetch contact from apex class 
        helper.onLoad(component, event);
    },
    OnCompletedButtonClick : function(component,event,helper){
        helper.SaveCompletedChecklistbuttonHelper(component, event, event.target.id);
    },
    OnOpenButtonClick : function(component,event,helper){
        helper.SaveOpenChecklistbuttonHelper(component, event, event.target.id);     
    },
    handleUploadFinished: function (component,event,helper) {
        var uploadedFiles = event.getParam("files");
        helper.FileUploadedHelper(component,event,uploadedFiles);
    },
    openFileModel: function(component, event, helper) {
        console.log(event.srcElement.id);
        // for Display Model,set the "isOpen" attribute to "true"
        helper.UploadedFileHelper(component,event,event.srcElement.id); 
        component.set("v.isOpen", true);
    },
    
    closeFileModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    
    NavigateToSubTask : function(component,event, helper) {
        console.log('Hey There .. the anchor was clicked');
        var id = event.currentTarget.getAttribute("data-recId");
        console.log("id : " + id);
        $A.get("e.force:navigateToURL").setParams({ 
       "url": "/"+id 
    }).fire();
        
    } 
    
});