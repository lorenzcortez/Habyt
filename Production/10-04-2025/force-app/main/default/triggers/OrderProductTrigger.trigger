trigger OrderProductTrigger on OrderItem (After Insert, After Delete) {
    
    if(trigger.isAfter){
        if(Trigger.IsInsert){
            OrderProductTriggerHandler.ProcessforRollUp(trigger.new);
        }
        
        if(Trigger.IsDelete){
            OrderProductTriggerHandler.ProcessforRollUp(trigger.Old);
        }
    }
}