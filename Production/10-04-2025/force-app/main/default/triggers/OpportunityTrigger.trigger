trigger OpportunityTrigger on Opportunity (before insert, before update, after update, after insert, before Delete) {
    System.debug('TRIGGER IS FIRED');
    
    Deactivate_Triggers__c ProfileSetting = Deactivate_Triggers__c.getInstance(UserInfo.getProfileId());
    Deactivate_Triggers__c UserSetting = Deactivate_Triggers__c.getInstance(UserInfo.getUserId());
    
    if((ProfileSetting != null && ProfileSetting.Deactivate_Triggers__c) || (UserSetting != null && UserSetting.Deactivate_Triggers__c)){
        System.debug('Bypassing OpportunityTrigger trigger due to custom setting');
        return;
    }
    
    if(Trigger.isBefore && Trigger.isInsert){
        OpportunityHandler.OpportunityPhoneValidation(Trigger.New, new Map<Id,Opportunity>());
        
        //Setting Seriel Numbers on Opp of different types on Insert
        OpportunityHandler.PopulateOpportunityName(trigger.new);
        //OpportunityHandler.PopulateTransferOpportunityName(trigger.new);
        
        
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        OpportunityHandler.OpportunityPhoneValidation(Trigger.New, Trigger.oldMap);
        
    }
    
    //Added by einsteam
    if(Trigger.isAfter && Trigger.isUpdate){
        //updates first_Active_opportunity__c field on account 
        OpportunityHandler.updateAccountFirstActiveOpp(Trigger.new, Trigger.oldMap);
        OpportunityHandler.AfterUpdate(Trigger.New, Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        OpportunityHandler.updateAccountFirstActiveOpp(Trigger.new);
        OpportunityHandler.AfterInsert(Trigger.New);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        OpportunityHandler.BeforeUpdate(Trigger.New, Trigger.oldMap);
    }
    if(Trigger.isBefore && Trigger.isInsert){
        OpportunityHandler.BeforeInsert(Trigger.New);
    }
    
    if(Trigger.isBefore && Trigger.isDelete){
        OpportunityHandler.BeforeDelete(Trigger.Old);
    }
}