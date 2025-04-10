public class SyncPropertyCampaignMemberHandler {
    @InvocableMethod(label='Sync Property Campaign Members' description='Creates members for the Property')
    public static void SyncPropertyCampaignMembers(List<ID> ids) {
        List<Opportunity> Opps = [
            SELECT id, Account.PersonContactID, Occupancy_Status__c, Property__c
            FROM Opportunity
            WHERE
                Property__c IN :ids
                AND (Occupancy_Status__c = 'Active'
                OR Occupancy_Status__c = 'Current month-to-month'
                OR Occupancy_Status__c = 'Holdover Tenant')
                AND BrandRef__r.Name = 'Common'
            ORDER BY Occupancy_Status__c DESC
        ];
        Map<string, Opportunity> PropertyOppMap = new Map<string, Opportunity>();
        for (Opportunity o : Opps) {
            PropertyOppMap.put(o.Property__c + '-' + o.Account.PersonContactID, o);
        }

        list<CampaignMember> members = [
            SELECT Occupancy_Status__c, ContactID, Campaign.Property__c
            FROM CampaignMember
            WHERE Campaign.Type = 'Property' AND Campaign.Property__c IN :ids
        ];

        list<CampaignMember> MemberUpdateList = new List<CampaignMember>();
        list<CampaignMember> MemberDeleteList = new List<CampaignMember>();
        list<CampaignMember> MemberInsertList = new List<CampaignMember>();

        set<id> ExistingMemberIDs = new Set<id>();

        for (CampaignMember mem : members) {
            ExistingMemberIDs.add(mem.ContactID);
            if (PropertyOppMap.get(mem.Campaign.Property__c + '-' + mem.ContactID) != null) {
                mem.Occupancy_Status__c = PropertyOppMap.get(mem.Campaign.Property__c + '-' + mem.ContactID)
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

        list<Property__c> properties = [
            SELECT
                id,
                (
                    SELECT id, Account.PersonContactID, Occupancy_Status__c
                    FROM Opportunities__r
                    WHERE
                        Account.PersonContactID NOT IN :ExistingMemberIDs
                        AND (Occupancy_Status__c = 'Active'
                        OR Occupancy_Status__c = 'Current month-to-month'
                        OR Occupancy_Status__c = 'Holdover Tenant')
                        AND BrandRef__r.Name = 'Common'
                    ORDER BY Occupancy_Status__c ASC
                ),
                (SELECT id FROM Campaigns__r WHERE Type = 'Property' LIMIT 1)
            FROM Property__c
            WHERE ID IN :ids
        ];

        for (Property__c p : properties) {
            if (p.Campaigns__r.size() > 0) {
                ID CampaignID = p.Campaigns__r[0].id;
                set<id> UniqueMemberIds = new Set<id>();
                for (Opportunity o : p.Opportunities__r) {
                    if (UniqueMemberIds.add(o.Account.PersonContactID)) {
                        CampaignMember cm = new CampaignMember();
                        cm.Occupancy_Status__c = o.Occupancy_Status__c;
                        cm.ContactID = o.Account.PersonContactID;
                        cm.CampaignID = CampaignID;
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