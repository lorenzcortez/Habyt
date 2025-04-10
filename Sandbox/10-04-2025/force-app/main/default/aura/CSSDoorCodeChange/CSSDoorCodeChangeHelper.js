({
    onLoad: function(component, event) {
        
        //call apex class method
        var action = component.get('c.fetchItems');
        action.setParams({ TaskID : component.get("v.TaskId") });
        
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.ChecklistItems', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
    },
    SaveCompletedChecklistbuttonHelper: function(component, event, checklistId) {
        var action = component.get('c.SaveCompletedChecklist');
        // pass the all selected record's Id's to apex method 
        action.setParams({ "lstRecordId":checklistId, "TaskID":component.get("v.TaskId"), "damages":null, "damageDescription":null, "isCompleted":true});
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                
                if (response.getReturnValue() != '') {
                    
                } else {
                    
                }
                // call the onLoad function for refresh the List view    
                
                $A.get('e.force:refreshView').fire();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Checklist Updated Sucessfully!',
                    duration:' 3000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                
            }else if (state === "ERROR"){
                var message = 'Unknown error';
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0 && errors[0].message != undefined) {
                    message = errors[0].message;
                }
                // Fire error toast
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error:',
                    message: message,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(action);
    },
    SaveOpenChecklistbuttonHelper: function(component, event, checklistId) {
        console.log('In:::'); 
        var action = component.get('c.SaveOpenChecklist');
        // pass the all selected record's Id's to apex method 
        action.setParams({ "lstRecordId":checklistId, "TaskID":component.get("v.TaskId")});
        
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                
                if (response.getReturnValue() != '') {
                    
                } else {
                    
                }
                // call the onLoad function for refresh the List view    
                
                $A.get('e.force:refreshView').fire();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Checklist Updated Sucessfully!',
                    duration:' 3000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                
            }else if (state === "ERROR"){
                var message = 'Unknown error';
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0 && errors[0].message != undefined) {
                    message = errors[0].message;
                }
                // Fire error toast
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error:',
                    message: message,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    FileUploadedHelper: function(component, event,uploadedFiles) {
        var FileIds = [];
        for(var i in uploadedFiles){
            FileIds.push(uploadedFiles[i].documentId);
        }
        var action = component.get('c.CloneFiletoParentTask');
        // pass the all selected record's Id's to apex method 
        action.setParams({ "FileIds":FileIds, "TaskID":component.get("v.TaskId")});
        
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Uploaded Sucessfully!',
                    duration:' 3000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                
            }
        });
        $A.enqueueAction(action);
    },
    UploadedFileHelper: function(component, event, ChecklistID) {
        //call apex class method
        var action = component.get('c.getContentDocs');
        action.setParams({ arecordId : ChecklistID });
        
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.UploadedFiles', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);    
    }
})