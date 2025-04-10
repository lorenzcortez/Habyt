public class CampainMemberTriggerHandler{
    
    
    public static void SyncMembersonParentCampaign(List<CampaignMember> cm){
        Delete [Select id from CampaignMember where Campaign.Name = 'Lincoln 455 - Suite 1U & 1L']; 
        
        List<Campaign> camps = [select id from Campaign Where Name = 'Lincoln 455 - Suite 1U & 1L'];
        List<Campaign> Childcamps = [select id,(Select id,ContactID,Occupancy_Status__c,CampaignID from CampaignMembers) from Campaign Where Name = 'Lincoln 455 - Suite 1L' or Name = 'Lincoln 455 - Suite 1U'];
        
        list<CampaignMember> newCampMemberList = new list<CampaignMember>();
         
        if(Camps.size() > 0 && Childcamps.size() > 0){
            for(Campaign childcamp : Childcamps){
                for(CampaignMember ccm : childcamp.CampaignMembers){
                    ccm.Id = null;
                    ccm.CampaignID = Camps[0].id;
                    newCampMemberList.add(ccm);
                }
            }
        }
        
        if(newCampMemberList.size() > 0){
            insert newCampMemberList;
        }
        
    }

}