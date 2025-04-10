public class NightlyCampaignApartmentHandler implements Database.Batchable<sObject>, Schedulable {
    public void execute(SchedulableContext sc) {
        runJob();
    }

    @TestVisible
    public static void runJob() {
        Integer batchSize = 100;
        Database.executeBatch(new NightlyCampaignApartmentHandler(), batchSize);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id from Apartment__c Where PropertyRef__r.BrandRef__r.Name = \'Common\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Apartment__c> Apartments = (List<Apartment__c>) scope;
        List<id> apartmentIds = new List<id>();
        for (Apartment__c a : Apartments) {
            apartmentIds.add(a.id);
        }
        SyncApartmentCampaignMemberHandler.SyncApartmentCampaignMembers(apartmentIds);
    }

    public void finish(Database.BatchableContext BC) {
    }
}