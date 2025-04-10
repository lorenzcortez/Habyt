@IsTest
public class L16MemberApplication_Test {
    
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
        insert Initopp;
        
    }
    
    
    static testMethod void testParse() {
        String json = '{'+
        '   \"operation\": \"member_application/sfdc/create_lead_and_email_app\",'+
        '   \"variables\": {'+
        '       \"property_id\": \"e1000000\",'+
        '       \"originating_source_lead_id\": \"123456\",'+
        '       \"leasing_agent_id\": \"123456\",'+
        '       \"applicants\": [{'+
        '           \"lead_applicant\": true,'+
        '           \"first_name\": \"Buddy\",'+
        '           \"last_name\": \"LePuppy\",'+
        '           \"phone\": \"555-999-8889\",'+
        '           \"email\": \"donald.frederick+buddy101@common.com\"'+
        '       }],'+
        '       \"move_in_date\": \"2023/08/15\",'+
        '       \"min_budget\": 100.00,'+
        '       \"max_budget\": 10000.00'+
        '   }'+
        '}';
        L16MemberApplication obj = L16MemberApplication.parse(json);
        System.assert(obj != null);
        
        list<L16PostOpportunityData.Requests> reqList = new list<L16PostOpportunityData.Requests>();
        L16PostOpportunityData.Requests req = new L16PostOpportunityData.Requests();
        req.recordId = [SELECT Id FROM Opportunity limit 1]?.Id;
        
        reqList.add(req);
        
        L16PostOpportunityData.execute(reqList);
    }
}