@IsTest
public class L16PostClosedLostOpportunity_Test {
    
    @testSetup static void loadTestData() {
        
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.PersonEmail = 'test@test.com';
        insert acc;
        
        City__c c = new City__c();
        c.Name = 'Seattle';
        insert c;

        //START
        Brand__c br = new Brand__c(Name = 'Test Brand',
                                    APINameBrand__c = 'Test Brand API');
        insert br;
        //END
        
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
        h.Home_ID__c = 'e12345';
        insert h;
        
        Home_Committed_Round_Robin__c setting = new Home_Committed_Round_Robin__c();
        setting.Name = 'test';
        setting.Home_Name__c = 'test';
        setting.Queue_No__c = 1;
        insert setting;
        
        Apartment__c s = new Apartment__c();
        s.Name = 'Test';
        s.PropertyRef__c = h.id;
        insert s;
        
        Room__c r = new Room__c ();
        r.Name = 'test';
        r.Property__c = h.id;
        r.ApartmentRef__c = s.id;
        insert r;
        
        Id InitialRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Common_Initial').getRecordTypeId();
        
        Opportunity Initopp = new Opportunity();
        Initopp.Name = 'test Opp 1';
        Initopp.StageName = 'Member';
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
        Initopp.Customer_Id__c = 'e12345';
        Initopp.Lease_Interval_Id__c = 'e12345';
        insert Initopp;
        
     }
    
    
    static testMethod void testPostReq() {
        
        list<L16PostClosedLostOpportunity.Requests> reqList = new list<L16PostClosedLostOpportunity.Requests>();
        L16PostClosedLostOpportunity.Requests req = new L16PostClosedLostOpportunity.Requests();
        req.recordId = [SELECT Id FROM Opportunity limit 1]?.Id;
        
        reqList.add(req);
        
        L16PostClosedLostOpportunity.execute(reqList);
    }
}