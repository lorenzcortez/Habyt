global class CreateDoorCodeTasks implements Database.Batchable<sObject> {
    
    /*
    CreateDoorCodeTasksSchedular cls = new CreateDoorCodeTasksSchedular();
    String sch = '0 0 8 1 JAN,APR,JUL,OCT ? *'; //At 08:00 AM, on day 1 of the month, only in January, April, July, and October
    String jobID = System.schedule('Changing front door code recurring tasks', sch, cls);
    system.debug('Job Id:: '+JobID);
    */
    Set<String> AccessSystems = new set<String>{
        'Kastle',
        'Brivo',
        'Latch',
        'ButterflyMX',
        'ButterflyMX + Physical Key',
        'Physical Key', 
        'Physical Key + Door Code',
        'JustIN',
        'Livvi'
    };
    
    global Map<Id, Property__c> Homes = new Map<Id, Property__c>([SELECT Id, Name,City_object__c, Member_Support_Manager__c, Access_System__c FROM Property__c WHERE (Access_System__r.Name IN : AccessSystems OR (Delivery_Code__c != null AND Delivery_Code__c != 'N/A')) AND Status__c != 'Home Closed']);
    global Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Update_Door_Code').getRecordTypeId();
        
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Name,City_object__c, Member_Support_Manager__c FROM Property__c WHERE (Access_System__r.Name IN : AccessSystems OR (Delivery_Code__c != null AND Delivery_Code__c != \'N/A\')) AND Status__c != \'Home Closed\''
        );
    }
    global void execute(Database.BatchableContext bc, List<Property__c> scope){
        list<Task> TasksToCreate = new list<Task>();
        
        // process each batch of records
        for (Property__c h: scope) {
            Task t = new Task();
            t.Subject = 'Update Door Code';
            t.RecordTypeId = recordTypeId;
            if(h.Member_Support_Manager__c != null){
                t.OwnerId = h.Member_Support_Manager__c; //Assign To Home Member Support Manager
            }
            // else{
            //     t.OwnerId = '0053u000003sQzp'; //Assign To Cassi
            // }
            t.ActivityDate = date.today().AddDays(3);
            t.WhatId = h.Id;
            t.Home__c = h.Id;
            t.City__c = h.City_object__c;
            t.Priority = 'Normal';
            t.Status = 'Open';
            TasksToCreate.add(t);
        }
        
        
        if(TasksToCreate.size() > 0){
            insert TasksToCreate;
            
            list<Sub_Task__c> SubTasksToInsert = new list<Sub_Task__c>();
            
            for(Task t : TasksToCreate){
                
                Sub_Task__c subTask1 = new Sub_Task__c();
                subTask1.Name = 'Create new door code'; //subject
                subTask1.Description__c = 'Include all primary electronic locks as well as sub-locks such as Schlage deadbolts';
                subTask1.Task_ID__c = t.Id;
                subTask1.Due_Date__c = date.today().AddDays(3);
                if(Homes.get(t.Home__c).Member_Support_Manager__c != null){
                    subTask1.OwnerId = Homes.get(t.Home__c).Member_Support_Manager__c; //Assign To Home Member Support Manager
                }
                // else{
                //     subTask1.OwnerId = '0053u000003sQzp'; //Assign To Cassi
                // }
                subTask1.Key_System__c = Homes.get(t.Home__c).Access_System__c;
                subTask1.Home__c = Homes.get(t.Home__c).Id;
                SubTasksToInsert.add(subTask1);
                
                Sub_Task__c subTask2 = new Sub_Task__c();
                subTask2.Name = 'Update "Callbox/Gate Code" and "Delivery Code" field on Home Object'; //subject
                subTask2.Task_ID__c = t.Id;
                subTask2.Due_Date__c = date.today().AddDays(3);
                if(Homes.get(t.Home__c).Member_Support_Manager__c != null){
                    subTask2.OwnerId = Homes.get(t.Home__c).Member_Support_Manager__c; //Assign To Home Member Support Manager
                }
                // else{
                //     subTask2.OwnerId = '0053u000003sQzp'; //Assign To Cassi
                // }
                subTask2.Key_System__c = Homes.get(t.Home__c).Access_System__c;
                subTask2.Home__c = Homes.get(t.Home__c).Id;
                SubTasksToInsert.add(subTask2);
                
                Sub_Task__c subTask3 = new Sub_Task__c();
                subTask3.Name = 'Update USPS'; //subject
                subTask3.Task_ID__c = t.Id;
                subTask3.Due_Date__c = date.today().AddDays(3);
                
                if(Homes.get(t.Home__c).Member_Support_Manager__c != null){
                    subTask3.OwnerId = Homes.get(t.Home__c).Member_Support_Manager__c; //Assign To Home Member Support Manager
                }
                // else{
                //     subTask3.OwnerId = '0053u000003sQzp'; //Assign To Cassi
                // }
                
                
                subTask3.Key_System__c = Homes.get(t.Home__c).Access_System__c;
                subTask3.Home__c = Homes.get(t.Home__c).Id;
                SubTasksToInsert.add(subTask3);
                
                Sub_Task__c subTask4 = new Sub_Task__c();
                subTask4.Name = 'Leave Chatter on this task with Old Code, New Code, and Date of Change'; //subject
                subTask4.Task_ID__c = t.Id;
                subTask4.Due_Date__c = date.today().AddDays(3);
                if(Homes.get(t.Home__c).Member_Support_Manager__c != null){
                    subTask4.OwnerId = Homes.get(t.Home__c).Member_Support_Manager__c; //Assign To Home Member Support Manager
                }
                // else{
                //     subTask4.OwnerId = '0053u000003sQzp'; //Assign To Cassi
                // }
                subTask4.Key_System__c = Homes.get(t.Home__c).Access_System__c;
                subTask4.Home__c = Homes.get(t.Home__c).Id;
                SubTasksToInsert.add(subTask4);
                
                Sub_Task__c subTask5 = new Sub_Task__c();
                subTask5.Name = 'Update Home- or Suite- Move-in Instructions if they mention a door code'; //subject
                subTask5.Description__c = 'List here: https://bit.ly/2VvU5Hz';
                subTask5.Task_ID__c = t.Id;
                subTask5.Due_Date__c = date.today().AddDays(3);
                subTask5.OwnerId = Homes.get(t.WhatId).Member_Support_Manager__c == null ? UserInfo.getUserId() : Homes.get(t.WhatId).Member_Support_Manager__c; //Assigned to Home Manager
                subTask5.Key_System__c = Homes.get(t.Home__c).Access_System__c;
                subTask5.Home__c = Homes.get(t.Home__c).Id;
                SubTasksToInsert.add(subTask5);
                
                Sub_Task__c subTask6 = new Sub_Task__c();
                subTask6.Name = 'Email members moving in the next 2 weeks with new door code'; //subject
                subTask6.Description__c = 'If move-in instructions were updated, email members in home with move-ins in the next 2 weeks. \n See Periscope here: https://bit.ly/38OAd6e';
                subTask6.Task_ID__c = t.Id;
                subTask6.Due_Date__c = date.today().AddDays(3);
                // subTask6.OwnerId = '0056A000000zODlQAM'; //Assign to Lior Torenberg
                subTask6.Key_System__c = Homes.get(t.Home__c).Access_System__c;
                subTask6.Home__c = Homes.get(t.Home__c).Id;
                SubTasksToInsert.add(subTask6);
                
               
                Sub_Task__c subTask8 = new Sub_Task__c();
                subTask8.Name = 'If member\'s home has a delivery code, message members new code'; //subject
                subTask8.Task_ID__c = t.Id;
                subTask8.Due_Date__c = date.today().AddDays(3);
                subTask8.OwnerId = Homes.get(t.WhatId).Member_Support_Manager__c == null ? UserInfo.getUserId() : Homes.get(t.WhatId).Member_Support_Manager__c; //Assigned to Home Manager
                subTask8.Key_System__c = Homes.get(t.Home__c).Access_System__c;
                subTask8.Home__c = Homes.get(t.Home__c).Id;
                SubTasksToInsert.add(subTask8);
                
                
                Sub_Task__c subTask10 = new Sub_Task__c();
                subTask10.Name = 'AFTER ALL OTHER SUBTASKS HAVE BEEN COMPLETED: Deactivate old door code'; //subject
                subTask10.Task_ID__c = t.Id;
                subTask10.Due_Date__c = date.today().AddDays(3);
                if(Homes.get(t.Home__c).Member_Support_Manager__c != null){
                    subTask10.OwnerId = Homes.get(t.Home__c).Member_Support_Manager__c; //Assign To Home Member Support Manager
                }
                // else{
                //     subTask10.OwnerId = '0053u000003sQzp'; //Assign To Cassi
                // }
                subTask10.Key_System__c = Homes.get(t.Home__c).Access_System__c;
                subTask10.Home__c = Homes.get(t.Home__c).Id;
                SubTasksToInsert.add(subTask10);
            }
            
            Insert SubTasksToInsert;
        }
    }
    
    global void finish(Database.BatchableContext bc){
    
    }
}