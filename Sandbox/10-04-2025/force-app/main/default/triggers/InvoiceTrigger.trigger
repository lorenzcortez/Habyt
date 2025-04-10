trigger InvoiceTrigger on Invoice__c (after insert, after update, after delete) {
    
    if(Trigger.isAfter ) {
        if(Trigger.isInsert){
            InvoiceTriggerHandler.executeRollup(Trigger.new);
        } else if(Trigger.isUpdate){
            InvoiceTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }else if(Trigger.isDelete){
            InvoiceTriggerHandler.executeRollup(Trigger.old);
        }
    }
}