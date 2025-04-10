@IsTest
public class SendGrid_Test{

    public TestMethod Static Void TestMethod1(){
        
        list<SendEmailRequest> Reqlist1 = new list<SendEmailRequest>();
        list<SendEmailRequest> Reqlist2 = new list<SendEmailRequest>();
        list<SendEmailRequest> Reqlist3 = new list<SendEmailRequest>();
        
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
        //h.Home_Manager_User__c = [SELECT id from User where name = 'JT Holden'][0].id;
        h.Home_Manager_User__c = userInfo.getUserId();
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
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        Account acc = new Account();
        acc.LastName = 'Test Einsteam zzz';
        acc.PersonEmail = 'development+testsendgrid@einsteam.com';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Qualified';
        opp.CloseDate = system.today();
        opp.AccountID = acc.id;
        //opp.Occupancy_Status__c = 'Active';
        opp.Phone__c = '2223333';
        opp.City_Lookup__c = c.id;
        opp.ApartmentRef__c = s.id;
        opp.End_Date_of_Occupancy__c = system.today();
        opp.Room_Selected__c = r.id;
        insert opp;
        
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=opp.id;
        insert attach;
        
        String myJSON = '{ "email":"example@test.com", "Category_Template_Id":"test","Category_Brand":"test","Category_Funnel":"test","Category_Unit_Type":"test"}';
        
        SendEmailRequest req1 = new SendEmailRequest ();
        req1.toEmail = 'development@einsteam.com';
        req1.TemplateId = 'd-36d50e2a86014037b545ae0a90602b7c';
        req1.dynamicContent = myJSON;
        req1.FromName = 'development@einsteam.com';
        req1.FromEmail = 'development@einsteam.com';
        req1.RecordId = opp.id;
        req1.SendEarliest = true;
        req1.ccEmails = 'test@test.comm';
        req1.bccEmails = 'test2@test.com';
        req1.EmailAttachmentId = attach.Id;
        
        
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
 
        // Test INSERT
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        
        
        
        
        SendEmailRequest req2 = new SendEmailRequest ();
        req2.toEmail = 'development@einsteam.com';
        req2.TemplateId = 'd-36d50e2a86014037b545ae0a90602b7c';
        req2.dynamicContent = 'development@einsteam.com';
        req2.FromName = 'development@einsteam.com';
        req2.FromEmail = 'development@einsteam.com';
        req2.RecordId = opp.id;
        req2.SendEarliest = true;
        req2.ccEmails = 'test@test.comm';
        req2.bccEmails = 'test2@test.com';
        req2.EmailAttachmentId = contentVersionSelect.ContentDocumentId;
        
        Reqlist1.add(req1);
        Reqlist2.add(req2);
        
        
        SendEmailRequest req3 = new SendEmailRequest ();
        req3.toEmail = null;
        req3.TemplateId = null;
        req3.dynamicContent = 'development@einsteam.com';
        req3.FromName = 'development@einsteam.com';
        req3.FromEmail = 'development@einsteam.com';
        req3.RecordId = opp.id;
        req3.SendEarliest = true;
        req3.ccEmails = 'test@test.comm';
        req3.bccEmails = 'test2@test.com';
        req3.EmailAttachmentId = contentVersionSelect.ContentDocumentId;
        Reqlist3.add(req3);
        
        SendGrid__c sett = new SendGrid__C();
        sett.API_Key__c = '3242343';
        sett.Name = 'tet';
        sett.Email_Service__c = 'test@emailservice.com';
        insert sett;
        
        SendGrid.SendEmail_SendGrid(Reqlist1);
        SendGrid.SendEmail_SendGrid(Reqlist2);
        SendGrid.SendEmail_SendGrid(Reqlist3);
        
        
        
    }

}