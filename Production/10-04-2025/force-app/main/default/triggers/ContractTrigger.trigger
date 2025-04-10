trigger ContractTrigger on Contract (after update) {
    if( Trigger.isAfter ){
        ContractTriggerController.afterUpdate(Trigger.New, Trigger.oldMap);
    }
}