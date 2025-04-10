@istest
public class FeedbackScorePostActions_Test{
    
    public testmethod static void TestFeedbackScorePostActions1(){
    
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.PersonEmail = 'test@test.com';
        acc.Phone = '1234567890';
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
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Closed Lost';
        opp.CloseDate = system.today();
        opp.AccountID = acc.id;
        opp.Phone__c = '2223333';
        opp.Home_Committed__c = h.Id;
        opp.City_Lookup__c = c.id;
        opp.ApartmentRef__c = s.id;
        opp.End_Date_of_Occupancy__c = system.today();
        opp.Room_Selected__c = r.id;
        insert opp;
        
        Feedback__c Feedback = new Feedback__c();
        Feedback.Opportunity__c = opp.Id;
        Feedback.Account__c = acc.Id;
        Feedback.Score__c = 4;
        Feedback.Comments__c = 'Test Comments';
        Feedback.Survey_Template__c = 'CSAT Move-In';
        Feedback.Score_Updated_Date_Time__c = system.now();
        insert Feedback;
        
        Feedback.Score_Updated_Date_Time__c = system.now().addHours(-2);
        update Feedback;
        
        Test.startTest();
            FeedbackScorePostActions cls = new FeedbackScorePostActions();
            cls.execute(null);
        Test.stopTest();
    }
    
    public testmethod static void TestFeedbackScorePostActions2(){
    
        
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
        h.BrandRef__c = br.Id;
        h.Home_Manager_User__c = UserInfo.getUserId();
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
        
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.PersonEmail = 'test@test.com';
        acc.Phone = '1234567890';
        insert acc;
        
        Case case1 = new Case();
        case1.Subject = 'Test Case';
        case1.Status = 'New';
        case1.Account__c = acc.Id;
        case1.Home__c = h.Id;
        case1.City__c = c.Id;
        insert case1;
        
        case1.Home__c = h.Id;
        update case1;
        
        Feedback__c Feedback2 = new Feedback__c();
        Feedback2.Account__c = acc.Id;
        Feedback2.Score__c = 2;
        Feedback2.Comments__c = 'Test Comments';
        Feedback2.Survey_Template__c = 'CSAT - Member Support Case';
        Feedback2.Score_Updated_Date_Time__c = system.now();
        Feedback2.Case__c = case1.Id;
        insert Feedback2;
        
        Feedback2.Score_Updated_Date_Time__c = system.now().addHours(-2);
        update Feedback2;
        
        Test.startTest();
            FeedbackScorePostActions cls = new FeedbackScorePostActions();
            cls.execute(null);
        Test.stopTest();
    }

}