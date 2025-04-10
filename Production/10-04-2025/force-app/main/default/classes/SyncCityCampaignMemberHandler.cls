public class SyncCityCampaignMemberHandler {
    @InvocableMethod(
        label='Sync City Campaign Members'
        description='Creates members for the City'
    )
    public static void SyncCityCampaignMembers(List<String> Ids) {
        List<Opportunity> Opps = [
            SELECT id, brandref__r.Name, Account.PersonContactID, Occupancy_Status__c, City_Object__r.Name
            FROM Opportunity
            WHERE
                City_Object__c IN :ids
                AND (Occupancy_Status__c = 'Active'
                OR Occupancy_Status__c = 'Current month-to-month'
                OR Occupancy_Status__c = 'Holdover Tenant')
                AND brandref__r.Name = 'Common'
            ORDER BY Occupancy_Status__c DESC
        ];
        Map<string, Opportunity> CityOppMap = new Map<string, Opportunity>();
        for (Opportunity o : Opps) {
            CityOppMap.put(o.City_Object__r.Name + '-' + o.Account.PersonContactID, o);
        }

        list<CampaignMember> members = [
            SELECT Occupancy_Status__c, ContactID, Campaign.City__c
            FROM CampaignMember
            WHERE Campaign.Type = 'City' AND Campaign.City__c IN :ids
        ];
        list<CampaignMember> MemberUpdateList = new List<CampaignMember>();
        list<CampaignMember> MemberDeleteList = new List<CampaignMember>();
        list<CampaignMember> MemberInsertList = new List<CampaignMember>();

        set<id> ExistingMemberIDs = new Set<id>();

        for (CampaignMember mem : members) {
            ExistingMemberIDs.add(mem.ContactID);

            if (CityOppMap.get(mem.Campaign.City__c + '-' + mem.ContactID) != null) {
                mem.Occupancy_Status__c = CityOppMap.get(mem.Campaign.City__c + '-' + mem.ContactID)
                    .Occupancy_Status__c;
                MemberUpdateList.add(mem);
            } else {
                MemberDeleteList.add(mem);
            }
        }

        if (MemberUpdateList.size() > 0) {
            update MemberUpdateList;
        }

        if (MemberDeleteList.size() > 0) {
            delete MemberDeleteList;
        }

        list<City__c> Cities = [
            SELECT
                id,
                (
                    SELECT id, Brandref__r.Name, Account.PersonContactID, Occupancy_Status__c
                    FROM Opportunities__r
                    WHERE
                        Account.PersonContactID NOT IN :ExistingMemberIDs
                        AND (Occupancy_Status__c = 'Active'
                        OR Occupancy_Status__c = 'Current month-to-month'
                        OR Occupancy_Status__c = 'Holdover Tenant') AND brandref__r.Name = 'Common'
                    ORDER BY Occupancy_Status__c ASC
                ),
                (SELECT id FROM Campaigns__r WHERE Type = 'City')
            FROM City__c
            WHERE ID IN :ids
        ];

        for (City__c s : Cities) {
            for (Campaign c : s.Campaigns__r) {
                set<id> UniqueMemberIds = new Set<id>();
                for (Opportunity o : s.Opportunities__r) {
                    if (UniqueMemberIds.add(o.Account.PersonContactID)) {
                        CampaignMember cm = new CampaignMember();
                        cm.Occupancy_Status__c = o.Occupancy_Status__c;
                        cm.ContactID = o.Account.PersonContactID;
                        cm.CampaignID = c.ID;
                        MemberInsertList.add(cm);
                    }
                }
            }
        }

        if (MemberInsertList.size() > 0) {
            insert MemberInsertList;
        }
    }
}