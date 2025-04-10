trigger CaseTrigger on Case (Before Insert, Before Update, After Insert, After Update) {
    
    // if(trigger.isBefore){
    //     if(trigger.IsInsert){
    //         CaseTriggerHandler.BeforeInsert(trigger.new);
    //     }
    //     if(trigger.isUpdate){
    //         CaseTriggerHandler.BeforeUpdate(trigger.new, trigger.oldMap);
    //     }
    // }
    
    // if(trigger.isAfter){
    //     if(trigger.IsUpdate){
    //         CaseTriggerHandler.AfterUpdate(trigger.new,trigger.oldMap);
    //     }
        
    //     if(trigger.IsInsert){
    //         CaseTriggerHandler.AfterInsert(trigger.new);
    //     }
    // }
}