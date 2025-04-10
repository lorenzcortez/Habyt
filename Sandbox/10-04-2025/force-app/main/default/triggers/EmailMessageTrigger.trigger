trigger EmailMessageTrigger on EmailMessage (After Insert) {
    
    Boolean IsActive = True;
    
    Trigger_Switcher__c myCS1 = Trigger_Switcher__c.getValues('EmailMessage');
    if(myCS1 != null && myCS1.Active__c != null)
    IsActive = myCS1.Active__c;
    
    if(IsActive)
        EmailMessageTriggerHandler.AfterInsert(Trigger.new);
}