public class NightlyCampaignBuildingsHandler implements Database.Batchable<sObject>, Schedulable {
    public static void execute(SchedulableContext sc) {
        runJob();
    }

    @TestVisible
    public static void runJob() {
        Integer batchSize = 25;
        Database.executeBatch(new NightlyCampaignBuildingsHandler(), batchSize);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id from building__c Where Home__r.BrandRef__r.Name = \'Common\'';
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<building__c> buildings = (List<building__c>) scope;
        List<id> buildingIds = new List<id>();
        for (building__c b : buildings) {
            buildingIds.add(b.id);
        }
        SyncBuildingsCampaignMemberHandler.SyncBuildingsMembers(buildingIds);
    }

    public void finish(Database.BatchableContext BC) {
    }
}