@isTest
public class Test_ConcessionGiftHelper{
    public static testMethod void Test1(){
        test.startTest();

        Profile prof = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.Username = 'test187e5be2@gmail.com';
        user.email = 'test187e5be2@test.com';
        user.CompanyName = 'TEST';
        user.Title = 'title';
        user.Alias = 'alias';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        insert user;

        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.PersonEmail = 'test1@test1.com';
        insert acc;
        
        City__c c = new City__c();
        c.Name = 'Seattle';
        insert c;

        Brand__c br = new Brand__c(Name = 'Test Brand',
                                    APINameBrand__c = 'Test Brand API');
        insert br;
        
        Property__c h = new Property__c();
        h.Name = 'test';
        h.City_object__c = c.id;
        h.Home_Manager_User__c = user.id;
        h.Tremendous_Bank_Account__c = '34343';
        h.BrandRef__c = br.Id;
        insert h;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Closed Lost';
        opp.CloseDate = system.today();
        opp.AccountID = acc.id;
        opp.Phone__c = '2223333';
        opp.City__c = 'Amsterdam';
        opp.End_Date_of_Occupancy__c = system.today();
        opp.Home_Committed__c = h.id;
        opp.Gift_Card_Amount__c = 3343;
        insert opp;
        list<string> oppids = new list<string>();
        oppids.add(opp.id);
        
        ConcessionGiftHelper.SendConcessionGift(oppids);
        
        test.stopTest();
    }
}