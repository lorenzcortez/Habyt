@isTest
public class CreateDoorCodeTasks_Test{

    public static testmethod void TestRecurringTasks(){
        City__c c = new City__c();
        c.Name = 'Seattle';
        insert c;
        
        Key_System__c AccessSystem = new Key_System__c();
        AccessSystem.Name = 'Brivo';
        insert AccessSystem;
        
        Brand__c br = new Brand__c(
            Name = 'Test Brand',
            APINameBrand__c = 'Test Brand API'
        );
        insert br;
        
        Property__c h = new Property__c();
        h.Name = 'test';
        h.City_object__c = c.id;
        // h.Home_Knowledge_Permission_Set__c = 'Test_Home_Permission';
        h.Home_Type__c = 'Powered by';
        h.Access_System__c = AccessSystem.Id;
        h.BrandRef__c = br.Id;
        //h.Home_Manager_User__c = userInfo.getUserId();
        insert h;
        
        
        // Dummy CRON expression: midnight on March 15.
        // Because this is a test, job executes
        // immediately after Test.stopTest().
        String CRON_EXP = '0 0 0 1 9 ? 2024';
    
    
        Test.StartTest();
        
            String jobId = System.schedule('CreateDoorCodeTasks Test', CRON_EXP, new CreateDoorCodeTasksSchedular());   
            //CreateDoorCodeTasks cls =  new CreateDoorCodeTasks();
            //database.executeBatch(cls);
        Test.StopTest();
    }
}