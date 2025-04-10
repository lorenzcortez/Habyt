public class SyncApartmentCampaignMemberHandler {
    @InvocableMethod(label='Sync Apartment Campaign Members' description='Creates members for the Apartments')
    public static void SyncApartmentCampaignMembers(List<ID> ids) {
        List<Opportunity> Opps = [
            SELECT id, Account.PersonContactID, Occupancy_Status__c, ApartmentRef__c
            FROM Opportunity
            WHERE
                ApartmentRef__c IN :ids
                AND (Occupancy_Status__c = 'Active'
                OR Occupancy_Status__c = 'Current month-to-month'
                OR Occupancy_Status__c = 'Holdover Tenant')
                AND BrandRef__r.Name = 'Common'
            ORDER BY Occupancy_Status__c DESC
        ];
        Map<string, Opportunity> ApartmentOppMap = new Map<string, Opportunity>();
        for (Opportunity o : Opps) {
            ApartmentOppMap.put(o.ApartmentRef__c+ '-' + o.Account.PersonContactID, o);
        }

        list<CampaignMember> members = [
            SELECT Occupancy_Status__c, ContactID, Campaign.Apartment__c
            FROM CampaignMember
            WHERE Campaign.Type = 'Apartment' AND Campaign.Apartment__c IN :ids
        ];

        list<CampaignMember> MemberUpdateList = new List<CampaignMember>();
        list<CampaignMember> MemberDeleteList = new List<CampaignMember>();
        list<CampaignMember> MemberInsertList = new List<CampaignMember>();

        set<id> ExistingMemberIDs = new Set<id>();

        for (CampaignMember mem : members) {
            ExistingMemberIDs.add(mem.ContactID);

            if (ApartmentOppMap.get(mem.Campaign.Apartment__c + '-' + mem.ContactID) != null) {
                mem.Occupancy_Status__c = ApartmentOppMap.get(mem.Campaign.Apartment__c + '-' + mem.ContactID)
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

        list<Apartment__c> Apartments = [
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
                (SELECT id FROM Campaigns__r WHERE Type = 'Apartment' LIMIT 1)
            FROM Apartment__c
            WHERE ID IN :ids
        ];

        for (Apartment__c a : Apartments) {
            if (a.Campaigns__r.size() > 0) {
                ID CampaignID = a.Campaigns__r[0].id;
                set<id> UniqueMemberIds = new Set<id>();

                for (Opportunity o : a.Opportunities__r) {
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