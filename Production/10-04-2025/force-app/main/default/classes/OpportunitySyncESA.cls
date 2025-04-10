/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-13-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class OpportunitySyncESA implements Database.Batchable<sObject>, schedulable{
    
    global void execute(SchedulableContext SC) {
        database.executebatch(new OpportunitySyncESA(), 1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
    
        Id CommonRenewal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Common_Renewal').getRecordTypeId();
        Id CommonTransfer = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Common_Transfer').getRecordTypeId();
        Id CommonInitial = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Common_Initial').getRecordTypeId();
        Id CommonMTM = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Common_MTM').getRecordTypeId();
        Id CommonBackfill = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Common_Backfill').getRecordTypeId();

        List<Id> recordTypeIds = new List<Id>();
        recordTypeIds.add(CommonRenewal);
        recordTypeIds.add(CommonTransfer);
        recordTypeIds.add(CommonInitial);
        recordTypeIds.add(CommonMTM);
        recordTypeIds.add(CommonBackfill);
        
        // collect the batches of opportunity records to be passed to execute
        String query = 'SELECT id, Has_ESA__c, StageName, Occupancy_Status__c, AccountID, Name, ApartmentRef__c  ';
        query += 'FROM Opportunity ';
        query += 'WHERE RecordtypeId IN :recordTypeIds';

        if( !Test.isRunningTest() ){
            query += ' AND Has_ESA__c = true AND ApartmentRef__c != NULL';
        }

        return Database.getQueryLocator(query);       
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        if(scope.size() > 0){
            List<Apartment__c> apartmentListToUpdate = new List<Apartment__c>();
            Set<Id> apartmentIds = new Set<Id>();
            for(Opportunity op : scope){
                apartmentIds.add(op.ApartmentRef__c);
            }
            
            List<Apartment__c> apartmentList = [Select Id from Apartment__c WHERE Id IN: apartmentIds];
            
            for(Apartment__c ap : apartmentList){
                Apartment__c a = new Apartment__c();
                a.Id = ap.Id;
                apartmentListToUpdate.add(a);
            }
            
            update apartmentListToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}