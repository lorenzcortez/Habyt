trigger CampainMemberTrigger on CampaignMember (After insert, After Update, After Delete) {
    
    list<CampaignMember> FinalList = new list<CampaignMember>();
    
    if(Trigger.IsInsert){
        for(CampaignMember cm : trigger.new){
            if(cm.Parent_Campaign_Name__c == 'Lincoln 455 - Suite 1U' || cm.Parent_Campaign_Name__c == 'Lincoln 455 - Suite 1L'){
                FinalList.add(cm);
            }
        }
    }
    
    if(Trigger.IsUpdate){
        for(CampaignMember cm : trigger.new){
            if(cm.Occupancy_Status__c != Trigger.OldMap.get(cm.Id).Occupancy_Status__c && (cm.Parent_Campaign_Name__c == 'Lincoln 455 - Suite 1U' || cm.Parent_Campaign_Name__c == 'Lincoln 455 - Suite 1L') ){
                FinalList.add(cm);
            }
        }
    }
    
    list<CampaignMember> CmDelete = new list<CampaignMember>();
    if(Trigger.IsDelete){
        for(CampaignMember cm : trigger.Old){
            if(cm.Parent_Campaign_Name__c == 'Lincoln 455 - Suite 1U' || cm.Parent_Campaign_Name__c == 'Lincoln 455 - Suite 1L'){
                    FinalList.add(cm);
            }
        }
    }
    
    if(FinalList.size() > 0 ){
        CampainMemberTriggerHandler.SyncMembersonParentCampaign(FinalList);
    }
    
}