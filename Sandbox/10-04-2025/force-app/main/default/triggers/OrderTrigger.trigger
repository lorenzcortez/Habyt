trigger OrderTrigger on Order (Before Update, Before Insert, After Update, After Insert, After Delete) {
    
    Map<Id,Schema.RecordTypeInfo> rtMap = Order.sobjectType.getDescribe().getRecordTypeInfosById();
    
    Id UserId = userinfo.GetUserId();
    Boolean BypassTrigger = [select Bypass_Trigger__c from user where id=:userid].Bypass_Trigger__c;
    if(BypassTrigger == false){
        if(trigger.isBefore){
        
            if(Trigger.IsInsert){
                OrderTriggerHandler.BeforeInsert(trigger.new,rtMap);
                OrderTriggerHandler.BeforeUpdate(trigger.new, trigger.OldMap,rtMap);
                List<Order> NonREOrders = new List<Order>();
                for(Order o : trigger.new){
                    if(o.Record_Type_Developer_Name__c != 'Real_Estate' && o.status != 'Cancelled' && o.product__c != null)
                        NonREOrders.add(o);
                }
                if(NonREOrders.size() > 0)
                OrderTriggerHandler.checkOrderInterference(NonREOrders);
            }
            
            
            if(Trigger.IsUpdate){
                OrderTriggerHandler.BeforeUpdate(trigger.new, trigger.OldMap,rtMap);
                List<Order> NonREOrders = new List<Order>();
                for(Order o : trigger.new){
                    if(o.Record_Type_Developer_Name__c != 'Real_Estate' && o.status != 'Cancelled' && o.product__c != null)
                        NonREOrders.add(o);
                }
                if(NonREOrders.size() > 0)
                OrderTriggerHandler.checkOrderInterference(NonREOrders);
            }
        }
        
        if(trigger.isAfter){
            
            if(Trigger.IsInsert){
                OrderTriggerHandler.AfterInsert(trigger.new,rtMap);
            }
            
            if(Trigger.IsUpdate){
                OrderTriggerHandler.AfterUpdate(trigger.new, trigger.OldMap,rtMap);
            }
            
            if(Trigger.IsDelete){
                OrderTriggerHandler.AfterDelete(trigger.Old,rtMap);
            }
        }
    }
    
}