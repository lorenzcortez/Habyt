@isTest
public class Test_TaskTrigger
{

    @isTest
    static void scenario(){
    
        City__c c = new City__c();
        c.Name = 'Seattle';
        insert c;

        Brand__c br = new Brand__c(Name = 'Test Brand', APINameBrand__c = 'Test Brand API');
        insert br;
        
        Property__c h = new Property__c();
        h.Name = 'test';
        h.City_object__c = c.id;
        h.Home_Manager_User__c = UserInfo.GetUserID();
        h.BrandRef__c = br.Id;
        h.PropertyLocation__latitude__s = 40.44898605;
        h.PropertyLocation__longitude__s = -3.699122906;
        insert h;
        
        Checklist_Setup__c ChecklistSetup = new Checklist_Setup__c ();
        ChecklistSetup.Checklist_Name__c = 'Test Checklist Setup';
        ChecklistSetup.Unit_Type__c = 'All Unit Types';
        ChecklistSetup.Task_Type__c = 'CSS - Source Fit Move In Create eVault Order Task';
        insert ChecklistSetup;
        
        Checklist_Homes__c ch = new Checklist_Homes__c();
        ch.Home__c = h.Id;
        ch.Checklist_Setup__c = ChecklistSetup.Id;
        insert ch;
        
        Test.startTest();
        
        Task t1 = new Task();
        t1.Subject = 'test';
        t1.ActivityDate = system.today();
        t1.Description = 'Call Disposition: sdsd\n';
        t1.recordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('CSS - Source Fit Move In Create eVault Order Task').getRecordTypeId();
        t1.Home__c = h.Id;
        t1.WhatId = h.Id;
        insert t1;
        
        list<sub_task__c> SubTasks = [SELECT Id, Task_ID__c, Is_Completed__c FROM Sub_task__c WHERE Task_ID__c = :t1.Id];
        for(sub_task__c st : SubTasks){
            st.Is_Completed__c = TRUE;
        }
        update SubTasks;
        
        t1.Status = 'Completed';
        update t1;
        
        delete t1;
        
        Task t = new Task();
        t.Subject = 'test';
        t.ActivityDate = system.today();
        t.Description = 'Call Disposition: sdsd\n';
        t.recordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('Real Estate Task').getRecordTypeId();
        insert t;
        
        t.Description = 'On the other hand, we denounce with righteous indignation and dislike men who are so beguiled and demoralized by the charms of pleasure of the moment, so blinded by desire, that they cannot foresee the pain and trouble that are bound to ensue; and equal blame belongs to those who fail in their duty through weakness of will, which is the same as saying through shrinking from toil and pain. These cases are perfectly simple and easy to distinguish. In a free hour, when our power of choice is untrammelled and when nothing prevents our being able to do what we like best, every pleasure is to be welcomed and every pain avoided. But in certain circumstances and owing to the claims of duty or the obligations of business it will frequently occur that pleasures have to be repudiated and annoyances accepted. The wise man therefore always holds in these matters to this principle of selection: he rejects pleasures to secure other greater pleasures, or else he endures pains to avoid worse pains.';
        update t;
        Test.stopTest();
    }

    @isTest
    static void scenario2(){
        Test.startTest();
        Task t = new Task();
        t.Subject = 'test';
        t.ActivityDate = system.today();
        t.Description = 'Call Disposition: sdsd\n';
        t.recordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('Real Estate Task').getRecordTypeId();
        t.Assigned_Task_Owner__c = 'test2@gmail.com';
        insert t;
        
        t.Description = 'Call Disposition code: sdd\n';
        t.Assigned_Task_Owner__c = 'test1@gmail.com';
        update t;
        Test.stopTest();
    }

    // @TestSetup
    // static void createTestData() {
    //     Task t = new Task();
    //     t.Subject = 'test';
    //     t.ActivityDate = system.today();
    //     t.Description = 'Call Disposition: sdsd\n';
    //     t.recordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('Real Estate Task').getRecordTypeId();
    //     insert t;
        
    //     t.Description = 'Call Disposition code: sdd\n';
    //     update t;
        
        
    //     //Test Preventative Maintenance Tasks
    //     City__c c = new City__c();
    //     c.Name = 'Seattle';
    //     insert c;

    //     Brand__c br = new Brand__c(
    //         Name = 'Test Brand',
    //         APINameBrand__c = 'Test Brand API'
    //     );

    //     insert br;
        
    //     Property__c h = new Property__c();
    //     h.Name = 'test';
    //     h.City_object__c = c.id;
    //     h.BrandRef__c = br.Id;
    //     insert h;
        
    //     Task t2 = new Task();
    //     t2.Subject = 'test';
    //     t2.ActivityDate = system.today();
    //     t2.WhatId = h.Id;
    //     t2.recordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('Real Estate Task').getRecordTypeId();
    //     insert t2;
        
    //     Sub_Task__c checklist = new Sub_Task__c();
    //     checklist.Name = 'Test Check list 1';
    //     checklist.Task_ID__c = t2.Id;
    //     checklist.Is_Completed__c = false;
    //     insert checklist;
        
    //     try{
    //     t2.Status = 'Completed';
    //     update t2;
    //     }catch(exception ex){}
        
    //     checklist.Is_Completed__c = true;
    //     update checklist;
        
    //     t2.Status = 'Completed';
    //     update t2;
    // }
    

    // public Static Void TestMethod2(){
    //     Test.startTest();
    //     Task t = new Task();
    //     t.Subject = 'test';
    //     t.ActivityDate = system.today();
    //     t.Description = 'Call Disposition: sdsd\n';
    //     t.recordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('Real Estate Task').getRecordTypeId();
    //     insert t;
        
    //     t.Description = 'Call Disposition code: sdd\n test ';
    //     update t;
        
        
    //     //Test Preventative Maintenance Tasks
    //     City__c c = new City__c();
    //     c.Name = 'Seattle2';
    //     insert c;
        
    //     /*Home__c h = new Home__c();
    //     h.Name = 'Addams';
    //     h.City1__c = c.id;
    //     insert h;
    //     */
    //     Property__c h = [Select id, name from Property__c where name = 'Addams'];
        
    //     Task t2 = new Task();
    //     t2.Subject = 'test';
    //     t2.ActivityDate = system.today();
    //     t2.WhatId = h.Id;
    //     t2.Home__c = h.id;
    //     t2.recordTypeId =  '0123u000000BUwmAAG';
    //     insert t2;
        
    //     //Sub_Task__c checklist = new Sub_Task__c();
    //     //checklist.Name = 'Test Check list 1';
    //     //checklist.Task_ID__c = t2.Id;
    //     //checklist.Is_Completed__c = false;
    //     //insert checklist;
        
        
    //     try{
    //     t2.Status = 'Completed';
    //     update t2;
    //     }catch(exception ex){}
        
    //     //checklist.Is_Completed__c = true;
    //     //update checklist;
        
        
    //     //t2.Status = 'Completed';
    //     //update t2;
        
    //      Test.stopTest();
    // }
    
    
    //  @isTest(seeAllData=true)
    // public Static Void TestMethod3(){
    //     Opportunity lior = [select id, city__c, Home_Committed__r.Maintenance_Tech__c, accountid, Previous_Occupancy_End_Date__c, home_committed__c, ApartmentRef__c, room_selected__C from opportunity where name = 'Lior Torenberg (Test) - Renewal 1'][0];
    //     task t = new task();
    //     t.Opportunity__c = lior.id;
    //     t.Home__c = lior.home_committed__c;
    //     t.Room__c = lior.Room_Selected__c;
    //     t.Suite__c = lior.ApartmentRef__c;
    //     t.Account__c = lior.AccountId;
    //     t.ActivityDate = lior.Previous_Occupancy_End_Date__c;
    //     t.City__c = lior.City__c;
    //     t.ownerid = lior.Home_Committed__r.Maintenance_Tech__c;
    //     t.Priority = 'Normal';
    //     t.status = 'Open';
    //     t.Subject = 'Onsite Move-Out Task';
    //     t.WhatId = lior.id;
    //     t.RecordTypeId = '0123u0000019nOwAAI';
        
    //     insert t;
        
    // }
    
    // @isTest(seeAllData=true)
    // public Static Void TestMethod4(){
        
    //     Opportunity lior = [select id, city__c, Home_Committed__r.Maintenance_Tech__c, accountid, Previous_Occupancy_End_Date__c, home_committed__c, ApartmentRef__c, room_selected__C from opportunity where name = 'Lior Torenberg (Test) - Renewal 1'][0];
    //     case c = new Case();
    //     c.Opportunity__c = lior.id;
    //     insert c;
    //     task t = new task();
    //     t.Opportunity__c = lior.id;
    //     t.Home__c = lior.home_committed__c;
    //     t.Room__c = lior.Room_Selected__c;
    //     t.Suite__c = lior.ApartmentRef__c;
    //     t.Account__c = lior.AccountId;
    //     t.ActivityDate = lior.Previous_Occupancy_End_Date__c;
    //     t.City__c = lior.City__c;
    //     t.ownerid = lior.Home_Committed__r.Maintenance_Tech__c;
    //     t.Priority = 'Normal';
    //     t.status = 'Open';
    //     t.Subject = 'Inspection for Lior Torenberg';
    //     t.WhatId = c.Id;
    //     t.RecordTypeId = '0123u000000BVb9AAG';
        
    //     insert t;
        
    //     t.Assigned_Task_Owner__c  = 'smakaron+1@gmail.com.invalid';
    //     update t;
        
    //     t.ActivityDate = t.ActivityDate.addDays(1);
    //     update t;
        
    // }
    
    //  @isTest(seeAllData=true)
    // public Static Void TestMethod5(){
    //     List<task> tasklist = new List<Task>();
        
    //     Opportunity lior = [select id, city__c, Home_Committed__r.Maintenance_Tech__c, accountid, Previous_Occupancy_End_Date__c, home_committed__c, ApartmentRef__c, room_selected__C from opportunity where name = 'Lior Torenberg (Test) - Renewal 1'][0];
    //     task t = new task();
    //     t.Opportunity__c = lior.id;
    //     t.Home__c = lior.home_committed__c;
    //     t.Room__c = lior.Room_Selected__c;
    //     t.Suite__c = lior.ApartmentRef__c;
    //     t.Account__c = lior.AccountId;
    //     t.ActivityDate = lior.Previous_Occupancy_End_Date__c;
    //     t.City__c = lior.City__c;
    //     t.ownerid = lior.Home_Committed__r.Maintenance_Tech__c;
    //     t.Priority = 'Normal';
    //     t.status = 'Open';
    //     t.Subject = 'Pre-Move-Out Inspection';
    //     t.WhatId = lior.Id;
    //     t.RecordTypeId = '0123u0000019nFBAAY';
        
    //     task t2 = new task();
    //     t2.Opportunity__c = lior.id;
    //     t2.Home__c = lior.home_committed__c;
    //     t2.Room__c = lior.Room_Selected__c;
    //     t2.Suite__c = lior.ApartmentRef__c;
    //     t2.Account__c = lior.AccountId;
    //     t2.ActivityDate = lior.Previous_Occupancy_End_Date__c;
    //     t2.City__c = lior.City__c;
    //     t2.ownerid = lior.Home_Committed__r.Maintenance_Tech__c;
    //     t2.Priority = 'Normal';
    //     t2.status = 'Open';
    //     t2.Subject = 'Post-Move-Out Inspection';
    //     t2.WhatId = lior.Id;
    //     t2.RecordTypeId = '0123u0000019nFBAAY';
        
    //     taskList.add(t);
    //     taskList.add(t2);
    //     insert taskList;
        
    //     // task tasks1 = [Select id, work_order__c, work_ordeR__r.workTypeid from task where (id = :t.id)][0];
    //     // System.debug('WorkType pre move out = ' + tasks1.Work_Order__r.workTypeid);
    //     // task tasks2 = [Select id, work_order__c, work_ordeR__r.workTypeid from task where (id =: t2.id)][0];
    //     // System.debug('WorkType post move out = ' + tasks2.Work_Order__r.workTypeid);
        
    // }
}