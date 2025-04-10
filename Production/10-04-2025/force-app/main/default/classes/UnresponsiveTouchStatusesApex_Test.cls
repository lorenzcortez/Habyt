@isTest
public class UnresponsiveTouchStatusesApex_Test
{
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
        
        Brand__c b = new Brand__c(Name = 'Test Brand', APINameBrand__c = 'Test API Brand');
        insert b;
        
        Property__c h = new Property__c();
        h.Name = 'test';
        h.City_object__c = c.id;
        h.Home_Manager_User__c = userinfo.getUserId();
        h.BrandRef__c = b.Id;
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
        opp.Stage_Status__c = 'Transfer Link Sent - Unresponsive Touch 1';
        opp.CloseDate = system.today();
        opp.AccountID = acc.id;
        opp.Phone__c = '2223333';
        opp.City_Object__c = c.id;
        opp.ApartmentRef__c = s.id;
        opp.End_Date_of_Occupancy__c = system.today();
        opp.Room_Selected__c = r.id;
        insert opp;
        
        Opportunity OppToUpdate = new Opportunity(Id = opp.Id);
        //OppToUpdate.Stage_Status_Change_Date_Time__c = system.now().addDays(-2);
        OppToUpdate.Last_Stage_Change_Date__c = system.now().addDays(-2);
        update OppToUpdate;
        
        //Opportunity opp1 = [SELECT Id, Name, StageName, Stage_Status__c, Stage_Status_Changed_Since__c FROM Opportunity WHERE Id =:opp.Id];
		Opportunity opp1 = [SELECT Id, Name, StageName, Stage_Status__c, Last_Stage_Change_Date__c FROM Opportunity WHERE Id =:opp.Id];
        system.debug('opp1::'+opp1);
        
        UnresponsiveTouchStatusesSchedulable cls = new UnresponsiveTouchStatusesSchedulable ();
        cls.execute(null);
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
        
        Brand__c b = new Brand__c(Name = 'Test Brand', APINameBrand__c = 'Test API Brand');
        insert b;
        
        Property__c h = new Property__c();
        h.Name = 'test';
        h.City_object__c = c.id;
        h.Home_Manager_User__c = userinfo.getUserId();
        h.BrandRef__c = b.Id;
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
        opp.StageName = 'Lease Application';
        opp.Stage_Status__c = 'Awaiting Docs';
        opp.CloseDate = system.today();
        opp.AccountID = acc.id;
        opp.Phone__c = '2223333';
        opp.City_Object__c = c.id;
        opp.ApartmentRef__c = s.id;
        opp.End_Date_of_Occupancy__c = system.today();
        opp.Room_Selected__c = r.id;
        insert opp;
        
        Opportunity OppToUpdate = new Opportunity(Id = opp.Id);
        //OppToUpdate.Stage_Status_Change_Date_Time__c = system.now().addDays(-1);
        OppToUpdate.Last_Stage_Change_Date__c = system.now().addDays(-1);
        update OppToUpdate;
        
        //Opportunity opp1 = [SELECT Id, Name, StageName, Stage_Status__c, Stage_Status_Changed_Since__c FROM Opportunity WHERE Id =:opp.Id];
		Opportunity opp1 = [SELECT Id, Name, StageName, Stage_Status__c, Last_Stage_Change_Date__c FROM Opportunity WHERE Id =:opp.Id];
        system.debug('opp2::'+opp1);
        
        
        UnresponsiveTouchStatusesSchedulable cls = new UnresponsiveTouchStatusesSchedulable ();
        cls.execute(null);
        
    }
    
}