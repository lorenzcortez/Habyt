@IsTest
public class SuiteOccupancyTypeUpdateAction_Test {
    
    @TestSetup 
    static void loadTestData() {
        
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.PersonEmail = 'test@test.com';
        insert acc;
        
        City__c c = new City__c();
        c.Name = 'Seattle';
        insert c;

        Brand__c br = new Brand__c(
            Name = 'Test Brand',
            APINameBrand__c = 'Test Brand API'
        );
        insert br;
        
        Property__c h = new Property__c();
        h.Name = 'test';
        h.City_object__c = c.id;
        h.Home_Manager_User__c = UserInfo.getUserId();
        h.Property_Services_Move_out_Task__c = 'Yes';
        h.Maintenance_Tech__c = userinfo.getuserId();
        h.Porter__c = UserInfo.getuserId();
        h.Onboarding_and_Experience_Manager__c = userInfo.getUserId();
        h.Maintenance_Tech__c = UserInfo.getUserId();
        h.Pre_Move_Out_Inspection_Task__c = 'Yes';
        h.Post_Move_Out_Inspection_Task__c = 'Yes';
        h.Leasing_Specialist_Move_out_Task__c = 'Yes';
        h.Onsite_Move_out_Task__c = 'Yes';
        h.Sourcefit_Move_out_Task__c = 'Yes';
        h.Resident_Services_Coordinator__c = UserInfo.getUserId();
        h.Area_Manager__c = UserInfo.getUserId();
        h.BrandRef__c = br.Id;
        insert h;
        
        Home_Committed_Round_Robin__c setting = new Home_Committed_Round_Robin__c();
        setting.Name = 'test';
        setting.Home_Name__c = 'test';
        setting.Queue_No__c = 1;
        insert setting;
        
        Apartment__c s = new Apartment__c();
        s.Name = 'Test';
        s.PropertyRef__c = h.id;
        //s.Product_Type__c = 'coliving';
        s.Product_Type__c = 'Co-living';
        insert s;
        
        Room__c r = new Room__c ();
        r.Name = 'test';
        r.Property__c = h.id;
        r.ApartmentRef__c = s.id;
        insert r;
        
        Id InitialRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Common - Initial').getRecordTypeId();
        
        Opportunity Initopp = new Opportunity();
        Initopp.Name = 'test Opp 1';
        Initopp.StageName = 'Lease Application';
        Initopp.CloseDate = system.today();
        Initopp.AccountID = acc.id;
        Initopp.Phone__c = '2223333';
        Initopp.City_Lookup__c = c.id;
        Initopp.ApartmentRef__c = s.id;
        Initopp.home_committed__c = h.Id;
        Initopp.Start_Date_of_Occupancy__c = system.today().addDays(7);
        Initopp.End_Date_of_Occupancy__c = system.today().addDays(30);
        Initopp.Room_Selected__c = r.id;
        Initopp.RecordTypeId = InitialRecordTypeId;
        Initopp.Early_Termination__c = TRUE;
        Initopp.Early_Termination_Type__c = 'Ghosted';
        Initopp.End_Date_Updated__c = TRUE;
        insert Initopp;
        
        Opportunity OppToUpdate = new Opportunity(Id = InitOpp.Id);
        OppToUpdate.OBL_Status__c = 'Agreements Generated';
        update OppToUpdate;
    }
    
    @IsTest
    static void testBatchClass() {
        
        Apartment__c suite = [SELECT Id, Name FROM Apartment__c WHERE Name = 'Test' LIMIT 1];
        list<Id> SuiteIds = new list<Id> {suite.Id};

        System.debug('suite' + suite);
        System.debug('SuiteIds' + SuiteIds);
        
        // SuiteOccupancyTypeUpdateAction_Batch cls = new SuiteOccupancyTypeUpdateAction_Batch(SuiteIds);
        // Database.executeBatch(cls, 3);
        Test.startTest();
        SuiteOccupancyTypeUpdateAction_Batch.executeInvocableMethod(SuiteIds);
        Test.stopTest();
    }

    @IsTest
    static void testBatchClassDeployment() {
        
        Apartment__c suite = [SELECT Id, Name FROM Apartment__c WHERE Name = 'Test' LIMIT 1];
        list<Id> SuiteIds = new list<Id> {suite.Id};
        System.debug('suite' + suite);
        System.debug('SuiteIds' + SuiteIds);
        
        
        Test.startTest();
            SuiteOccupancyTypeUpdateAction_Batch cls = new SuiteOccupancyTypeUpdateAction_Batch(SuiteIds);
            Database.executeBatch(cls, 3);
        Test.stopTest();
    }
}