trigger TourTrigger on Tour__c (after insert, after update) {
    
    if(trigger.isAfter && trigger.isInsert){
        TourTriggerHandler.AfterInsert(Trigger.new);
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        TourTriggerHandler.AfterUpdate(Trigger.new, trigger.oldMap);
    }
}