@isTest
public class CreateCaseFromInspectionTest {
    
    @isTest
    public static void test() {
        /*
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.PersonEmail = 'test@test.com';
        insert acc;7
        */

        Account acc = new Account();
        acc.FirstName = 'Lior';
        acc.LastName = 'Torenberg';
        acc.PersonEmail = 'test@test.com';
        insert acc;

        //account acc = [Select id from account where name like '%Lior Torenberg%'][0];
        City__c c = new City__c();
        c.Name = 'Seattle1';
        insert c;
        
        /*
        UserRole role = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');	
		insert role;
        
		User u = new User(
        	ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = role.Id
		);
        

		*/

        //START
        Brand__c br = new Brand__c(Name = 'Test Brand',
                                    APINameBrand__c = 'Test Brand API');
        insert br;
        //END

        Property__c h = new Property__c();
        h.Name = 'test';
        h.City_object__c = c.id;
        /*h.Home_Manager_User__c = [SELECT id from User where name = 'JT Holden'][0].id;
        h.Accounts_Receivable_Coordinator__c = [SELECT id from User where name = 'JT Holden'][0].id;*/
        h.Home_Manager_User__c = userInfo.getUserId();
        h.Accounts_Receivable_Coordinator__c = userInfo.getUserId();
        h.BrandRef__c = br.Id;
        insert h;
        
        Property__c h2 = new Property__c();
        h2.Name = 'test2';
        h2.City_object__c = c.id;
        h2.BrandRef__c = br.Id;
        insert h2;
        
        
        Apartment__c s = new Apartment__c();
        s.Name = 'Test';
        s.PropertyRef__c = h.id;
        insert s;
        
        Room__c r = new Room__c ();
        r.Name = 'test';
        r.Property__c = h2.id;
        r.ApartmentRef__c = s.id;
        insert r;
        
        /*
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Lease Application';
        opp.CloseDate = system.today();
        opp.AccountID = acc.id;
        opp.Occupancy_Status__c = 'Active';
        opp.Phone__c = '2223333';
        opp.City_Lookup__c = c.id;
        opp.ApartmentRef__c = s.id;
        opp.End_Date_of_Occupancy__c = system.today();
        opp.Room_Selected__c = r.id;
        insert opp;
        */

        Opportunity opp = new Opportunity();
        opp.Name = 'Lior Torenberg';
        opp.StageName = 'Lease Application';
        opp.CloseDate = system.today();
        opp.AccountID = acc.id;
        opp.Occupancy_Status__c = 'Active';
        opp.Phone__c = '2223333';
        opp.City_Lookup__c = c.id;
        opp.ApartmentRef__c = s.id;
        opp.End_Date_of_Occupancy__c = system.today();
        opp.Room_Selected__c = r.id;
        insert opp;

        //opportunity opp = [Select id from opportunity where name like '%Lior Torenberg%'][0];
        
        //Home__c newHome = [SELECT id, Name from home__c where Name = 'Terry'];
        //id homeId = newHome.id;
        
        CreateCaseFromInspectionTask.Input testInput = new CreateCaseFromInspectionTask.Input();
        Task t = new Task();
        t.Home__c = h.id;
        t.Suite__c = s.id;
        t.Room__c = r.id;
        t.Whatid = opp.id;
        t.Subject = 'Post';
        t.ActivityDate = system.today();
        t.Description = 'Call Disposition: sdsd\n';
        t.recordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('Real Estate Task').getRecordTypeId();
        insert t;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = t.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        testInput.taskID = t.Id;
        List<CreateCaseFromInspectionTask.Input> ttl = new List<CreateCaseFromInspectionTask.Input>();
        ttl.add(testInput);
		CreateCaseFromInspectionTask.CreateCase(ttl);
        
        
    }
    
}