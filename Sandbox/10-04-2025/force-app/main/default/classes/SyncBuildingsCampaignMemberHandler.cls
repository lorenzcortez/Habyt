public class SyncBuildingsCampaignMemberHandler {
    @InvocableMethod(label='Sync Buildings Campaign Members' description='Creates members for the Buildings')
    public static void SyncBuildingsMembers(List<ID> ids) {
        List<Opportunity> Opps = [
            SELECT id, Account.PersonContactID, Occupancy_Status__c, ApartmentRef__c, ApartmentRef__r.Building__c
            FROM Opportunity
            WHERE
                ApartmentRef__r.Building__c IN :ids
                AND (Occupancy_Status__c = 'Active'
                OR Occupancy_Status__c = 'Current month-to-month'
                OR Occupancy_Status__c = 'Holdover Tenant')
                AND BrandRef__r.Name = 'Common'
            ORDER BY Occupancy_Status__c DESC
        ];
        Map<string, Opportunity> BuildingOppMap = new Map<string, Opportunity>();
        for (Opportunity o : Opps) {
            BuildingOppMap.put(o.ApartmentRef__r.Building__c + '-' + o.Account.PersonContactID, o);
        }

        map<id, id> buildingcampaignidsmap = new Map<id, id>();
        list<campaign> camps = [SELECT id, Building__c FROM Campaign WHERE Type = 'Building' AND Building__c IN :ids];
        for (campaign c : camps) {
            buildingcampaignidsmap.put(c.building__c, c.id);
        }

        list<CampaignMember> members = [
            SELECT Occupancy_Status__c, ContactID, Campaign.Building__c
            FROM CampaignMember
            WHERE Campaign.Type = 'Building' AND Campaign.Building__c IN :ids
        ];

        list<CampaignMember> MemberUpdateList = new List<CampaignMember>();
        list<CampaignMember> MemberDeleteList = new List<CampaignMember>();
        list<CampaignMember> MemberInsertList = new List<CampaignMember>();

        set<id> ExistingMemberIDs = new Set<id>();

        for (CampaignMember mem : members) {
            ExistingMemberIDs.add(mem.ContactID);

            if (BuildingOppMap.get(mem.Campaign.Building__c + '-' + mem.ContactID) != null) {
                mem.Occupancy_Status__c = BuildingOppMap.get(mem.Campaign.Building__c + '-' + mem.ContactID)
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

        list<Opportunity> activeOppswithoutMembers = [
            SELECT id, Account.PersonContactID, Occupancy_Status__c, ApartmentRef__r.Building__c
            FROM Opportunity
            WHERE
                Account.PersonContactID NOT IN :ExistingMemberIDs
                AND (Occupancy_Status__c = 'Active'
                OR Occupancy_Status__c = 'Current month-to-month'
                OR Occupancy_Status__c = 'Holdover Tenant')
                AND BrandRef__r.Name = 'Common'
                AND ApartmentRef__r.Building__c IN :ids
            ORDER BY Occupancy_Status__c ASC
        ];

        set<id> UniqueMemberIds = new Set<id>();
        for (Opportunity o : activeOppswithoutMembers) {
            ID CampaignID = buildingcampaignidsmap.get(o.ApartmentRef__r.Building__c);
            if (UniqueMemberIds.add(o.Account.PersonContactID)) {
                if (CampaignID != null) {
                    CampaignMember cm = new CampaignMember();
                    cm.Occupancy_Status__c = o.Occupancy_Status__c;
                    cm.ContactID = o.Account.PersonContactID;
                    cm.CampaignID = CampaignID;
                    MemberInsertList.add(cm);
                }
            }
        }

        if (MemberInsertList.size() > 0) {
            insert MemberInsertList;
        }
    }
}