trigger InvoiceItemTrigger on InvoiceItem__c (after insert, after delete, after update) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            InvoiceItemTriggerHandler.onAfterInsertUpdate(Trigger.newMap);
        }
        else if(Trigger.isDelete) {
            InvoiceItemTriggerHandler.onAfterDelete(Trigger.old);
        }
    }
}