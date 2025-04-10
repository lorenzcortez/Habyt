public class NightlyCampaignPropertyHandler implements Database.Batchable<sObject>, Schedulable {
    public void execute(SchedulableContext sc) {
        runJob();
    }

    @TestVisible
    public static void runJob() {
        Integer batchSize = 10;
        Database.executeBatch(new NightlyCampaignPropertyHandler(), batchSize);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id from Property__c Where BrandRef__r.Name = \'Common\'';
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Property__c> properties = (List<Property__c>) scope;
        List<id> propertyIds = new List<id>();
        for (Property__c p : properties ) {
            propertyIds.add(p.id);
        }
        SyncPropertyCampaignMemberHandler.SyncPropertyCampaignMembers(propertyIds);
    }

    public void finish(Database.BatchableContext BC) {
    }
}