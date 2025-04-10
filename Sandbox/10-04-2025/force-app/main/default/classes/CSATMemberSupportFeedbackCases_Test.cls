@isTest
public class CSATMemberSupportFeedbackCases_Test{

    static testmethod void CSATMemberSupportFeedbackCasesTest(){
        
        City__c c = new City__c();
        c.Name = 'Test City';
        insert c;

        Brand__c br = new Brand__c(
            Name = 'Test Brand',
            APINameBrand__c = 'Test Brand API'
        );
        insert br;
        
        Property__c h = new Property__c();
        h.Name = 'Test Home';
        h.City_object__c = c.id;
        h.Home_Manager_User__c = userinfo.getUserId();
        h.BrandRef__c = br.Id;
        insert h;
        
        Home_Committed_Round_Robin__c setting = new Home_Committed_Round_Robin__c();
        setting.Name = 'test';
        setting.Home_Name__c = 'Test Home';
        setting.Queue_No__c = 1;
        insert setting;
        
        Apartment__c s = new Apartment__c();
        s.Name = 'Test Suite';
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
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Closed Lost';
        opp.CloseDate = system.today();
        opp.AccountID = acc.id;
        opp.Phone__c = '2223333';
        opp.Home_Committed__c = h.Id;
        opp.City__c = 'Amsterdam';
        opp.ApartmentRef__c = s.id;
        opp.End_Date_of_Occupancy__c = system.today();
        opp.Room_Selected__c = r.id;
        insert opp;
        
        Account acc1 = [SELECT PersonContactId FROM Account WHERE Id = :acc.Id limit 1];
        test.startTest();
            Id RTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CSS_Events_and_Community').getRecordTypeId();
        
        Case c0 = new Case();
        c0.AccountId = acc.Id;
        c0.ContactId = acc1.PersonContactId;
        c0.Opportunity__c = opp.Id;
        c0.subject = 'Test Case';
        c0.Suite__c = s.Id;
        c0.Home__c = h.Id;
        c0.Description = 'test description';
        c0.SuppliedEmail = 'development@einsteam.com';
        c0.RecordTypeId = RTId;
        c0.Status = 'Solved';
        c0.Issue_Type__c = 'Shared Goods + Cleaning';
        c0.Sub_Issue_Type__c = 'WiFi Issue';
        c0.Send_CSAT_Survey__c = TRUE;
        c0.Sent_CSAT_Survey__c = FALSE;
        insert c0;
        
        Case c1 = [SELECT Id, ClosedDate, ContactId, AccountId, Account__c, Opportunity__c, Brand__c, OwnerId, SuppliedEmail, Opportunity__r.Brand__c, Opportunity__r.OwnerId,
                    Status, RecordTypeId, RecordType.Name, RecordType.DeveloperName, Sent_CSAT_Survey__c, Send_CSAT_Survey__c
                            FROM Case
                            WHERE Id = :c0.Id];
                            system.debug('c1::'+c1);
                            system.debug('RecordType.Name::'+c1.RecordType.Name);
                            system.debug('RecordType.Name::'+c1.RecordType.DeveloperName);
                            system.debug('RecordType.Opportunity__cs::'+c1.Opportunity__c);
                            
            CSATMemberSupportFeedbackCases cls = new CSATMemberSupportFeedbackCases();
            cls.execute(null);
        test.stopTest();
        
    }
}