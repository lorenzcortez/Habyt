public class NightlyCampaignCityHandler implements Database.Batchable<sObject>, Schedulable {
    public void execute(SchedulableContext sc) {
        runJob();
    }

    @TestVisible
    public static void runJob() {
        Integer batchSize = 1;
        Database.executeBatch(new NightlyCampaignCityHandler(), batchSize);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id from City__c Where Country_Lookup__r.Name = \'United States\' OR Country_Lookup__r.Name = \'Canada\'';
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<city__c> cities = (List<city__c>) scope;
        List<id> cityIds = new List<id>();
        for (city__c c : cities) {
            cityIds.add(c.id);
        }
        SyncCityCampaignMemberHandler.SyncCityCampaignMembers(cityIds);
    }

    public void finish(Database.BatchableContext BC) {
    }
}