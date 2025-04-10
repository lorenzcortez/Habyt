@isTest
public class OpportunityHandlerTest {
    @TestSetup
    static void makeData(){

        Deactivate_Triggers__c deactTrigger = new Deactivate_Triggers__c(
            Deactivate_Triggers__c  = false
        );

        insert deactTrigger;
         

        Profile prof = [SELECT Id FROM Profile WHERE Name LIKE 'System Administrator'];
        User user = new User();
        user.firstName = 'Common';
        user.lastName = 'Living';
        user.profileId = prof.id;
        user.username = 'testiver77745@test.com';
        user.email = 'test@test.com';
        user.CompanyName = 'TEST';
        user.Title = 'title';
        user.Alias = 'alias';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        insert user;
        System.assert( user.Id != null, 'User record is created' );

        User user2 = new User();
        user2.firstName = 'Test ';
        user2.lastName = 'User 2';
        user2.profileId = prof.id;
        user2.username = 'test27745@test.com';
        user2.email = 'test27745@test.com';
        user2.CompanyName = 'TEST';
        user2.Title = 'title';
        user2.Alias = 'alias';
        user2.TimeZoneSidKey = 'America/Los_Angeles';
        user2.EmailEncodingKey = 'UTF-8';
        user2.LanguageLocaleKey = 'en_US';
        user2.LocaleSidKey = 'en_US';
        insert user2;
        System.assert( user2.Id != null, 'User2 record is created' );

        Account acct = new Account(
            FirstName = 'Test',
            LastName = 'Account',
            PersonEmail = 'test@test.com'
        );

        insert acct;
        System.assert(acct.Id != null, 'Account record is created');

        City__c c = new City__c(
            Name = 'Seattle1'
        );
        insert c;
        System.assert(c.Id != null, 'City record is created');


        Brand__c br = new Brand__c(
            Name = 'Test Brand',
            APINameBrand__c = 'Test Brand API'
        );
        insert br;

        System.assert(br.Id != null, 'Brand record is created');

        Property__c h = new Property__c(
            Name = 'test',
            City_object__c = c.id,
            Home_Manager_User__c = userInfo.getUserId(),
            Accounts_Receivable_Coordinator__c = userInfo.getUserId(),
            BrandRef__c = br.Id
        );
        
        insert h;
        System.assert(h.Id != null, 'Property record is created');

        Apartment__c s = new Apartment__c();
        s.Name = 'Test';
        s.PropertyRef__c = h.id;
        insert s;
        
        Room__c r = new Room__c (
            Name = 'test',
            Property__c = h.id,
            ApartmentRef__c = s.id,
            Status__c = 'Online'
        );
        
        insert r;

        Id common = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Common - Initial').getRecordTypeId();

        Opportunity opp = new Opportunity(
            Name        = 'Lior Torenberg',
            StageName = 'Lease Application',
            CloseDate = system.today(),
            AccountID = acct.id,
            Occupancy_Status__c = 'Active',
            Phone__c = '2223333',
            City_Lookup__c = c.id,
            ApartmentRef__c = s.id,
            RecordTypeId = common,
            End_Date_of_Occupancy__c = system.today().addDays(10),
            Room_Selected__c = r.id,
            Leasing_Administrator__c = user2.Id,
            Start_Date_of_Occupancy__c = system.today(),
            Vacancy_Date__c = system.today().addDays(25),
            Holdover_Tenant_Move_Out_Date__c = system.today().addDays(25)
            // Home_Committed__c = h.Id
        );
        
        insert opp;
    }

    @isTest
    static void scenario1(){ 

        List<Opportunity> opps = [SELECT Id, Record_Type_Name__c, Home_Committed__c, Subsequent_Opportunity__c, Room_Selected__c FROM Opportunity WHERE StageName = 'Lease Application'];
        List<Property__c> properties = [SELECT Id FROM Property__c WHERE  Name = 'test'];

        Test.startTest();

            OpportunityHandler.UpdateCityFromHomeCommitted(opps);
            OpportunityHandler.CloseMoveOutTasksHoldover(opps);
            OpportunityHandler.HoldoverTenantMoveOutDateAdded(opps);

            Opportunity toUpdate    = new Opportunity();
            toUpdate.Id                                 = opps[0].Id;
            toUpdate.Occupancy_Status__c                = 'Moving In';
            // toUpdate.Home_Committed__c                  = properties[0].Id;
            toUpdate.Holdover_Tenant_Move_Out_Date__c   = System.today().addDays(30);
            toUpdate.Start_Date_of_Occupancy__c         = System.today().addDays(20);
            update toUpdate;

            delete opps;

        Test.stopTest();
    }

    @isTest
    static void scenario2(){ 

        Deactivate_Triggers__c deactTrigg = [SELECT Id FROM Deactivate_Triggers__c];
        deactTrigg.Deactivate_Triggers__c = true;
        update deactTrigg;

        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE StageName = 'Lease Application'];

        Test.startTest();

            Opportunity toUpdate            = new Opportunity();
            toUpdate.Id                     = opps[0].Id;
            toUpdate.Id                     = opps[0].Id;
            toUpdate.Occupancy_Status__c    = 'Holdover Tenant';
            toUpdate.Name                   = 'Update Opportunity';
            update toUpdate;
            delete opps;

        Test.stopTest();
    }
    
    @isTest
    static void scenario3(){ 

        Test.startTest();

        Account acct = new Account(
            FirstName = 'Test',
            LastName = 'Account',
            PersonEmail = 'test1234@test.com'
        );

        insert acct;
        System.assert(acct.Id != null, 'Account record is created');

        City__c c = new City__c(
            Name = 'Seattle1'
        );
        insert c;
        System.assert(c.Id != null, 'City record is created');


        Brand__c br = new Brand__c(
            Name = 'Test Brand',
            APINameBrand__c = 'Test Brand API'
        );
        insert br;

        System.assert(br.Id != null, 'Brand record is created');

        Property__c h = new Property__c(
            Name = 'test ptob',
            City_object__c = c.id,
            Home_Manager_User__c = userInfo.getUserId(),
            Accounts_Receivable_Coordinator__c = userInfo.getUserId(),
            BrandRef__c = br.Id
        );
        
        insert h;
        System.assert(h.Id != null, 'Property record is created');

        Apartment__c s = new Apartment__c();
        s.Name = 'Test';
        s.PropertyRef__c = h.id;
        insert s;
        
        Room__c r = new Room__c (
            Name = 'test',
            Property__c = h.id,
            ApartmentRef__c = s.id
        );
        
        insert r;

        Id common = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Common - Initial').getRecordTypeId();

        List<User> user = [SELECT Id FROM User WHERE Email = 'test27745@test.com' LIMIT 1];

        Opportunity opp = new Opportunity(
            Name        = 'Opportunity Test',
            StageName = 'Member',
            CloseDate = system.today(),
            AccountID = acct.id,
            Occupancy_Status__c = 'Holdover Tenant',
            Phone__c = '2223333',
            City_Lookup__c = c.id,
            ApartmentRef__c = s.id,
            RecordTypeId = common,
            End_Date_of_Occupancy__c = system.today().addDays(10),
            Room_Selected__c = r.id,
            Room__c = r.id,
            Leasing_Administrator__c = user[0].Id,
            Start_Date_of_Occupancy__c = system.today().addDays(10),
            Vacancy_Date__c = system.today().addDays(25)
        );
        
        insert opp;

        Test.stopTest();
    }
}