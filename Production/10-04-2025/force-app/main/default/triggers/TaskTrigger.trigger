trigger TaskTrigger on Task (Before Insert, Before Update, after insert, after update) {
    
    if(trigger.isBefore & (trigger.IsInsert || trigger.Isupdate) ){
    
        //list<recordType> rectypes =  [select id,developerName from recordType where SobjectType = 'task' and developerName = 'Real_State_Task' limit 1];
        Id recordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('Real Estate Task').getRecordTypeId();
        
        for(Task t : trigger.new){
            
            if(t.description != null && recordTypeId == t.RecordTypeID){
                
                if(Trigger.isUpdate ? Trigger.OldMap.get(t.id).Description != t.Description : true ) {
                    
                    if(t.description.length() > 254)
                        t.subject = t.description.substring(0,254);
                    else
                        t.subject = t.description.substring(0,t.description.length());
                        
                }   
            }
        }
    }
    
    system.debug('OUT::'+trigger.isAfter);
    system.debug('OUT::'+trigger.Isupdate);
    if(trigger.isAfter & trigger.Isupdate){
        system.debug('IN');    
        integer count = 0;
        list<id> taskids = new list<id> ();
        
        for(task t: trigger.new){
            if(t.Assigned_Task_Owner__c != null && t.Assigned_Task_Owner__c != trigger.oldmap.get(t.id).Assigned_Task_Owner__c  ) {
                system.debug('IN 2');            
                if(count <= 100){
                    taskids.add(t.id);
                }
                else{
                    ActivityOwnerReassignmentAsyncApex.AssignOwner(taskids);
                    count = 0;
                    taskids = new list<id> ();
                }
                
                count++;
            }
        }
        
        if(taskids.size() > 0){
            ActivityOwnerReassignmentAsyncApex.AssignOwner(taskids);
        }
    }
    

}