trigger InvoiceTrigger on Invoice__c (after insert, after update, after delete) {
    System.debug('Working');
    if(Trigger.isAfter ) {
        if(Trigger.isDelete || Trigger.isInsert){
            InvoiceTriggerHandler.executeRollup(Trigger.new);
        } else if(Trigger.isUpdate){
            InvoiceTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}