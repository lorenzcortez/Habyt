({
    loadcheckList: function(component, event, helper) {
        // call the helper function for fetch contact from apex class 
        helper.onLoad(component, event);
    },
    OnCompletedButtonClick : function(component,event,helper){
        console.log('0');
        console.log('event.target.id::'+event.target.id);
        var itemId = event.target.id.split('||')[0];
        var itemName = event.target.id.split('||')[1];
        var isPhotoRequired = event.target.id.split('||')[2];
		console.log('itemId::'+itemId);
        console.log('itemName::'+itemName);
        console.log('isPhotoRequired::'+isPhotoRequired);
        
        helper.SaveCompletedChecklistbuttonHelper(component, event, itemId, itemName, isPhotoRequired);
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
    
 
    
   
     
});