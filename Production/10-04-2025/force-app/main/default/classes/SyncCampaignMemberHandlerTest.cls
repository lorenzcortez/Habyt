@isTest
public class SyncCampaignMemberHandlerTest {
    @TestSetup
    static void testData() {
        Account a = new Account();
        a.LastName = 'test';
        a.PersonEmail = 'test@test.com';
        insert a;

        Brand__c b = new Brand__c(Name = 'Common', APINameBrand__c = 'Common');
        insert b;

        Country__c coun = new Country__c(Name = 'United States');
        insert coun;

        City__c c = new City__c(Name = 'New York', Country__c = 'United States', Country_Lookup__c = Coun.Id);
        insert c;

        Stripe_Account__c sp = new Stripe_Account__c();
        sp.Name = 'test';
        sp.secret_key__c = '2323';
        insert sp;

        Billing_Entity__c be = new Billing_Entity__c();
        be.Name = 'test';
        be.CurrencyIsoCode = 'EUR';
        be.Stripe_Account__c = sp.Id;
        insert be;

        Condition__c cond = new Condition__c();
        cond.Name = 'test';
        cond.CurrencyISOcode = 'EUR';
        cond.MembershipFee__c = 22;
        cond.BillingEntityRef__c = be.Id;
        cond.DepositMultiplier__c = 2;
        cond.TimePeriodEarliestStartofContract__c = 1;
        cond.TimePeriodLatestStartofContract__c = 2;
        insert cond;

        Property__c p = new Property__c();
        p.City_object__c = c.Id;
        p.Name = 'test';
        p.BrandRef__c = b.id;
        p.ConditionRef__c = cond.id;
        p.Billing_Entity__c = be.Id;
        p.Country__c = 'United States';
        p.City_object__c = c.Id;
        insert p;

        Building__c bl = new Building__c();
        bl.Home__c = p.Id;
        bl.Name = 'test';
        insert bl;

        Apartment__c ap = new Apartment__c();
        ap.Building__c = bl.Id;
        ap.Name = 'test';
        ap.PropertyRef__c = p.Id;
        insert ap;

        Room__c r = new Room__c();
        r.Property__c = p.id;
        r.Name = 'test';
        r.ApartmentRef__c = ap.Id;
        insert r;

        // Create test data
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Won',
            CloseDate = System.today(),
            brandref__c = b.Id,
            AccountId = a.Id,
            Occupancy_Status__c = 'Active',
            City_Object__c = c.Id,
            Property__c = p.id,
            ApartmentRef__c = ap.Id,
            Room__c = r.Id,
            Country__c = 'United States'
        );
        insert opp;

        Campaign campaign = new Campaign(Name = 'Test Campaign', Type = 'City', City__c = c.Id);
        insert campaign;

        Campaign campaign1 = new Campaign(
            Name = 'Test Campaign',
            Type = 'Property',
            Property__c = p.Id,
            ParentId = campaign.id
        );
        insert campaign1;

        Campaign campaign2 = new Campaign(
            Name = 'Test Campaign',
            Type = 'Building',
            Building__c = bl.Id,
            ParentId = campaign1.id
        );
        insert campaign2;

        Campaign campaign3 = new Campaign(
            Name = 'Test Campaign',
            Type = 'Apartment',
            Apartment__c = ap.Id,
            ParentId = campaign2.id
        );
        insert campaign3;
    }

    @isTest
    static void testSyncCityCampaignMembers() {
        City__c c = [SELECT id FROM City__c WHERE Name = 'New York'];
        Test.startTest();
        List<String> ids = new List<String>{ c.Id };
        SyncCityCampaignMemberHandler.SyncCityCampaignMembers(ids);
        Test.stopTest();
    }

    @isTest
    static void testSyncPropertyCampaignMembers() {
        Property__c p = [
            SELECT id, (SELECT id, BrandRef__r.Name FROM Opportunities__r)
            FROM Property__c
            WHERE Name = 'test'
        ];
        system.debug(p.Id);
        system.debug(p.Opportunities__r);
        Test.startTest();
        List<String> ids = new List<String>{ p.Id };
        SyncPropertyCampaignMemberHandler.SyncPropertyCampaignMembers(ids);
        Test.stopTest();
    }

    @isTest
    static void testSyncBuildingCampaignMembers() {
        Building__c bl = [SELECT id FROM Building__c WHERE Name = 'test'];
        Test.startTest();
        List<String> ids = new List<String>{ bl.Id };
        SyncBuildingsCampaignMemberHandler.SyncBuildingsMembers(ids);
        Test.stopTest();
    }

    @isTest
    static void testSyncApartmentCampaignMembers() {
        Apartment__c ap = [SELECT id FROM Apartment__c WHERE Name = 'test'];
        Test.startTest();
        List<String> ids = new List<String>{ ap.Id };
        SyncApartmentCampaignMemberHandler.SyncApartmentCampaignMembers(ids);
        Test.stopTest();
    }

    @isTest
    static void testBatchJobCampaignMembers() {
        Test.startTest();
        NightlyCampaignCityHandler.runJob();
        NightlyCampaignPropertyHandler.runJob();
        NightlyCampaignBuildingsHandler.runJob();
        NightlyCampaignApartmentHandler.runJob();
        Test.stopTest();
    }
}