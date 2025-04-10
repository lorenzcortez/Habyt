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
                //component.set('v.ChecklistCount', response.getReturnValue().length);    
                
            }
        });
        $A.enqueueAction(action);
        
        var action2 = component.get('c.fetchTaskInfo');
        action2.setParams({ TaskID : component.get("v.TaskId") });
        
        action2.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.taskRecord', response.getReturnValue());
                //component.set('v.ChecklistCount', response.getReturnValue().length);    
                
            }
        });
        $A.enqueueAction(action2);
        
    },
    SaveCompletedChecklistbuttonHelper: function(component, event, checklistId, checklistName, isPhotoRequired) {
        console.log('0');
        //this array is for the subtasks for move out inspection tasks
        //var arrayPhotosRequired = ['Windows and window treatments','HVAC (remote/vents/filters)', 'Furniture', 'Light fixtures/bulbs', 'Living room (Floor, carpet, light, window, wall holes, custom paint)', 'Walls and baseboards (holes or damage larger than a quarter)', 'Doors', 'Floors', 'Mirrors', 'Ceilings', 'Bathroom (cabinet, mirror, sink, toilet, shower, etc.)', 'Kitchen (Cabinet, counter, appliances, sink, floors, walls)', 'Closets', 'Appliances', 'Smoke detectors', 'Balcony', 'Laundry machines'];
        //check if the subtasks subject is in the array outlined before
        var subject = component.get('v.taskRecord.Subject');
        console.log('task record::', component.get('v.taskRecord'));
        console.log('subTaskRecord record::', component.get('v.subTaskRecord'));
        var subtasksList = component.get('v.ChecklistItems');
        var subTaskDamage;
        var damageDescription;
        
        console.log(subtasks);
        for(var i = 0; i< subtasksList.length; i++){
            //console.log(subtasksList[i].Id);
            if(subtasksList[i].Id == checklistId){
                subTaskDamage = subtasksList[i].Damage_Charge__c;
                damageDescription = subtasksList[i].Description__c;
            }
        }
        
        console.log(subTaskDamage + ' JT ' + damageDescription);
        console.log('isPhotoRequired::',isPhotoRequired);
        //if(arrayPhotosRequired.indexOf(checklistName) > -1 && subject == 'Post-Move-Out Inspection' && subTaskDamage && subTaskDamage != 0){ // && subject.includes('Inspection')
        if(isPhotoRequired == 'true' || (subject == 'Post-Move-Out Inspection' && subTaskDamage && subTaskDamage != 0)){
         	var action = component.get('c.getContentDocs');
            action.setParams({ arecordId : checklistId });
            
            action.setCallback(this, function(response) {
                //store state of response
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('response.getReturnValue::',response.getReturnValue().length);
                    if(response.getReturnValue().length != 0){
                        
                    	var action = component.get('c.SaveCompletedChecklist');
                        // pass the all selected record's Id's to apex method 
                        var subtasks = component.get('v.ChecklistItems');
                        var damages;
                        var damageDescription;
                        console.log(subtasks);
                        for(var f in subtasks){
                            if(subtasks[f].Id == checklistId){
                                damages = subtasks[f].Damage_Charge__c;
                                damageDescription = subtasks[f].Description__c;
                            }
                        }
                        console.log('0');
                        action.setParams({ "lstRecordId":checklistId, "TaskID":component.get("v.TaskId"), "damages":damages, "damageDescription":damageDescription, "isCompleted":true});
                        console.log('1');
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
                    }
                    else
                    {
                    	var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'Please upload photo before completing this task.',
                            duration:' 3000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();   
                    }
                }
            });
            $A.enqueueAction(action);    
        }
        else
        {
        	var action = component.get('c.SaveCompletedChecklist');
            // pass the all selected record's Id's to apex method 
             var subtasks = component.get('v.ChecklistItems');
                        var damages;
                        var damageDescription;
                        console.log(subtasks);
                        for(var i = 0; i< subtasks.length; i++){
                            console.log(subtasks[i].Id);
                            if(subtasks[i].Id == checklistId){
                                damages = subtasks[i].Damage_Charge__c ? subtasks[i].Damage_Charge__c : 0;
                                damageDescription = subtasks[i].Description__c;
                                console.log(damages + ' JT' + ' ' + damageDescription);
                            }
                        }
            console.log('2');
            action.setParams({ "lstRecordId":checklistId, "TaskID":component.get("v.TaskId"), "damages":damages, "damageDescription":damageDescription, "isCompleted":true});
            console.log('3');
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
        }
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
            console.log(uploadedFiles[i]);
        }
        var action = component.get('c.CloneFiletoParentTask');
        // pass the all selected record's Id's to apex method 
        action.setParams({ "FileIds":FileIds, "TaskID":component.get("v.TaskId")});
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                
                
                

                // pass the all selected record's Id's to apex method 
                var subtasks = component.get('v.ChecklistItems');
                var damages;
                var damageDescription;
                console.log(subtasks);
             	
                for(var f in subtasks){
                    damages = subtasks[f].Damage_Charge__c;
                    damageDescription = subtasks[f].Description__c;
                    console.log(subtasks[f].Is_Completed__c);
                    if(!subtasks[f].Is_Completed__c){
                        console.log('Fired: ');
                        console.log(subtasks[f]);
                        var saveAction = component.get('c.SaveCompletedChecklist');
                        saveAction.setParams({ "lstRecordId":subtasks[f].Id, "TaskID":component.get("v.TaskId"), "damages":damages, "damageDescription":damageDescription, "isCompleted":false});
                        $A.enqueueAction(saveAction);
                    }
                }
                

                
                
                
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