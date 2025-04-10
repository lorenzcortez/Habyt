@isTest
Public class EinsteamTaskTrigger_Test{ 
    
    public static testmethod void UnitTest(){
        
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
        h.BrandRef__c = br.Id;
        insert h;
        
        // Property__c h2 = new Property__c();
        // h2.Name = 'test2';
        // h2.City_object__c = c.id;
        // h.BrandRef__c = br.Id;
        // insert h2;
        
        Home_Committed_Round_Robin__c setting = new Home_Committed_Round_Robin__c();
        setting.Name = 'test';
        setting.Queue_No__c = 1;
        setting.Home_Name__c = h.Id;
        insert setting;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test Opportunity';
        opp1.StageName = 'Closed Lost';
        opp1.AccountId = acc.Id;
        opp1.CloseDate = date.today().addDays(30);
        opp1.Occupancy_Status__c = 'Active';
        opp1.Phone__c = '2223333';
        opp1.City__c = 'Amsterdam';
        insert opp1;
        
        system.debug('---->'+opp1.Name);
        
        test.startTest();
            
            Task t1 = new Task();
            t1.Subject = 'test subject';
            t1.ActivityDate = date.today();
            t1.Company_Name__c = 'Test Account';
            //t1.is_BaseCamp_imported__c = true;
            insert t1;
            
            Task t2 = new Task();
            t2.Subject = 'test subject2';
            t2.ActivityDate = date.today();
            //t2.is_BaseCamp_imported__c = true;
            insert t2;
            
            Task t3 = new Task();
            t3.Subject = 'test subject3';
            t3.ActivityDate = date.today();
            //t3.is_BaseCamp_imported__c = true;
            insert t3;

            t3.Subject = 'test subject4';
            update t3;

            delete t2;
            
            //TaskTriggerhandler.UnitTest();
        test.stopTest();
    }
}