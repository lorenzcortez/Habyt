@isTest
public class CreateMemberMoveOutTasks_Test{
    
    @isTest
    public Static Void TestMethod1(){
        
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
        
        
        Id RenewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Common_Renewal').getRecordTypeId();
        Id InitialRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Common_Initial').getRecordTypeId();
        
        Opportunity Initopp = new Opportunity();
        Initopp.Name = 'test Opp 1';
        Initopp.StageName = 'Member';
        Initopp.CloseDate = system.today();
        Initopp.AccountID = acc.id;
        Initopp.Phone__c = '2223333';
        Initopp.City_Lookup__c = c.id;
        Initopp.ApartmentRef__c = s.id;
        Initopp.Start_Date_of_Occupancy__c = system.today().addDays(7);
        Initopp.End_Date_of_Occupancy__c = system.today().addDays(30);
        Initopp.Room_Selected__c = r.id;
        Initopp.RecordTypeId = InitialRecordTypeId;
        Initopp.Early_Termination__c = TRUE;
        Initopp.Early_Termination_Type__c = 'Ghosted';
        Initopp.End_Date_Updated__c = TRUE;
        insert Initopp;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Closed Lost';
        opp.CloseDate = system.today();
        opp.AccountID = acc.id;
        opp.Phone__c = '2223333';
        opp.City_Lookup__c = c.id;
        opp.ApartmentRef__c = s.id;
        opp.Start_Date_of_Occupancy__c = system.today().addDays(7);
        opp.End_Date_of_Occupancy__c = system.today().addDays(30);
        opp.Room_Selected__c = r.id;
        opp.RecordTypeId = RenewalRecordTypeId;
        opp.Previous_Opportunity__c = Initopp.Id;
        opp.Home_Committed__c = h.Id;
        
        test.startTest();
            
            insert opp;
            
            String year = string.valueOf(date.today().Addyears(1).year());
            String CRON_EXP = '0 0 0 3 9 ? '+year;
            String jobId = System.schedule('CreateMemberMoveOutTasks_Schedulable', CRON_EXP, new CreateMemberMoveOutTasks_Schedulable());
            
            list<CreateMoveOutTasksforOpp_Invocable.Request> requestList = new list<CreateMoveOutTasksforOpp_Invocable.Request>();
            CreateMoveOutTasksforOpp_Invocable.Request req = new CreateMoveOutTasksforOpp_Invocable.Request();
            req.Opportunities = new list<Opportunity>{ opp };
            requestList.add(req);
            CreateMoveOutTasksforOpp_Invocable.execute(requestList);
        Test.stopTest();        
    }
    
    @isTest
    public Static Void TestMethod2(){
        
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
        h.Onboarding_and_Experience_Manager__c = userInfo.getUserId();
        h.Porter__c = UserInfo.getuserId();
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
        
        
        Id RenewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Common_Renewal').getRecordTypeId();
        
        Id InitialRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Common_Initial').getRecordTypeId();
        
        Opportunity Initopp = new Opportunity();
        Initopp.Name = 'test Opp 1';
        Initopp.StageName = 'Member';
        Initopp.CloseDate = system.today();
        Initopp.AccountID = acc.id;
        Initopp.Phone__c = '2223333';
        Initopp.City_Lookup__c = c.id;
        Initopp.ApartmentRef__c = s.id;
        Initopp.Start_Date_of_Occupancy__c = system.today().addDays(7);
        Initopp.End_Date_of_Occupancy__c = system.today().addDays(30);
        Initopp.Room_Selected__c = r.id;
        Initopp.RecordTypeId = InitialRecordTypeId;
        Initopp.Early_Termination__c = TRUE;
        Initopp.Early_Termination_Type__c = 'Ghosted';
        Initopp.End_Date_Updated__c = TRUE;
        insert Initopp;
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test Opp 2';
        opp.StageName = 'Closed Lost';
        opp.CloseDate = system.today();
        opp.AccountID = acc.id;
        opp.Phone__c = '2223333';
        opp.City_Lookup__c = c.id;
        opp.ApartmentRef__c = s.id;
        opp.Start_Date_of_Occupancy__c = system.today().addDays(7);
        opp.End_Date_of_Occupancy__c = system.today().addDays(30);
        opp.Room_Selected__c = r.id;
        opp.RecordTypeId = RenewalRecordTypeId;
        opp.Early_Termination__c = TRUE;
        opp.Early_Termination_Type__c = 'Ghosted';
        opp.End_Date_Updated__c = TRUE;
        opp.Previous_Opportunity__c = Initopp.Id;
        opp.Home_Committed__c = h.Id;
        test.startTest();
        
            insert opp;
        
            String year = string.valueOf(date.today().Addyears(1).year());
            String CRON_EXP = '0 0 0 3 9 ? '+year;
            String jobId = System.schedule('CreateMemberMoveOutTasks_Schedulable', CRON_EXP, new CreateMemberMoveOutTasks_Schedulable());
            
            list<CreateMoveOutTasksforOpp_Invocable.Request> requestList = new list<CreateMoveOutTasksforOpp_Invocable.Request>();
            CreateMoveOutTasksforOpp_Invocable.Request req = new CreateMoveOutTasksforOpp_Invocable.Request();
            req.Opportunities = new list<Opportunity>{ opp };
            requestList.add(req);
            CreateMoveOutTasksforOpp_Invocable.execute(requestList);
            
        Test.stopTest();        
    }
    
    
}