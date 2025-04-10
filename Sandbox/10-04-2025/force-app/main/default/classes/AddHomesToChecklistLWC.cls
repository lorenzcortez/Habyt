public without sharing class AddHomesToChecklistLWC{  
    
    @AuraEnabled(cacheable=true)  
    public static HomesWrapper fetchHomesList(string recordId){  
        system.debug(recordId);
        
        HomesWrapper hw = new HomesWrapper();  
        hw.homesList = [SELECT Id, Name, Marketing_Name__c, Home_Type__c From Property__c Order by Name];
        
        list<Checklist_Homes__c> ChecklistHomes = new list<Checklist_Homes__c>();
        CheckListHomes = [Select Home__c, Checklist_Setup__c FROM Checklist_Homes__c WHERE Checklist_Setup__c =:recordId];
        Set<Id> selectedIdSet = new Set<Id>();  
        for(Checklist_Homes__c chHome: ChecklistHomes){  
            selectedIdSet.add(chHome.Home__c);  
        }  
        hw.selectedIdSet = selectedIdSet;  
        system.debug(hw);
        return hw; 
    }  
    @AuraEnabled  
    public static void createChecklistHomes(string recordId, List<Property__c> selectedHomesList){
        try{
            system.debug(recordId);
            system.debug(selectedHomesList);
            list<Checklist_Homes__c> ExistingHomesToDel = new list<Checklist_Homes__c>();
            ExistingHomesToDel = [SELECT Id FROM Checklist_Homes__c WHERE Checklist_Setup__c= :recordId];
            if(ExistingHomesToDel.size() > 0){
                delete ExistingHomesToDel;
            }
            
            list<Checklist_Homes__c> CheckListHomesToCreate = new list<Checklist_Homes__c>();
            
            for(Property__c h : selectedHomesList){
                Checklist_Homes__c ch = new Checklist_Homes__c();
                ch.Home__c = h.Id;
                ch.Checklist_Setup__c = recordId;
                CheckListHomesToCreate.add(ch);
            }
            if(CheckListHomesToCreate.size() > 0){
                insert CheckListHomesToCreate;
            }
        }catch(Exception ex) {
            system.debug('Error::'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }  
    
    public class HomesWrapper{  
        @AuraEnabled 
        public List<Property__c> homesList {get; set;}  
        @AuraEnabled 
        public set<Id> selectedIdSet {get; set;}  
    }  
}