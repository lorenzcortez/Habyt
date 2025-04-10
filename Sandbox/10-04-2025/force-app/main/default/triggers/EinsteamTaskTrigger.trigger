trigger EinsteamTaskTrigger on Task (before insert, before update, After Insert, After Update, before Delete){
    
    if(Trigger.isInsert && Trigger.Isbefore){
        TaskTriggerhandler.OnBeforeInsert(trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.Isbefore){
        TaskTriggerhandler.OnBeforeUpdate(trigger.new,Trigger.OldMap);
    }
    
    if(Trigger.isInsert && Trigger.IsAfter){
        TaskTriggerhandler.OnAfterInsert(trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.IsAfter){
        TaskTriggerhandler.OnAfterUpdate(trigger.new,Trigger.OldMap);
    }
    if(Trigger.isDelete && Trigger.IsBefore){
        TaskTriggerhandler.OnBeforeDelete(Trigger.OldMap);
    }
}