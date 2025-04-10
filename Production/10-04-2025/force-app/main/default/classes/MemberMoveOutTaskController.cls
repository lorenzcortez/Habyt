public without sharing class MemberMoveOutTaskController {
    
    public static list<Task> AssignClosedLostOppTaskValues(Opportunity opp, list<User> MemberUser){

        list<Task> TasksToCreate = new list<Task>();

        if(opp.Home_Committed__r.Property_Services_Move_out_Task__c == 'Yes'){
                        
            String PSMoveOutTaskOwner;
            if(opp.Home_Committed__r.Property_Services_Move_out_Task_Owner__c == 'Porter'){
                PSMoveOutTaskOwner = opp.Home_Committed__r.Porter__c;
            }else {
                PSMoveOutTaskOwner = opp.Home_Committed__r.Maintenance_Tech__c;
            }
            
            if(PSMoveOutTaskOwner != NULL){
                Date ActivityDate;
                Id rtId_Property_Services_Move_Out_Task_Template = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Property_Services_Move_Out_Task_Template').getRecordTypeId();
                if(opp.Previous_Occupancy_End_Date__c != NULL)
                    ActivityDate = opp.Previous_Occupancy_End_Date__c.addDays(1);
                //Task t = InitiateNewTask('Property Services Move Out', ActivityDate, PSMoveOutTaskOwner, '0123u000000BUyTAAW', opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);
                Task t = InitiateNewTask('Property Services Move Out', ActivityDate, PSMoveOutTaskOwner, rtId_Property_Services_Move_Out_Task_Template, opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);
                TasksToCreate.add(t);
            }
        }
        
        if(opp.Home_Committed__r.Pre_Move_Out_Inspection_Task__c == 'Yes'){
            
            String PreMoveOutInspectionOwner; 
            if(opp.Home_Committed__r.Pre_Move_Out_Inspection_Task_Owner__c == 'Porter'){
                PreMoveOutInspectionOwner = opp.Home_Committed__r.Porter__c;
            }
            else if(opp.Home_Committed__r.Pre_Move_Out_Inspection_Task_Owner__c == 'Community Manager'){
                PreMoveOutInspectionOwner = opp.Home_Committed__r.Community_Manager__c;
            }else{
                PreMoveOutInspectionOwner = opp.Home_Committed__r.Maintenance_Tech__c;
            }
            
            if(PreMoveOutInspectionOwner != NULL){
                Date ActivityDate;
                Id rtId_Move_Out_Inspection_Task = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Move_Out_Inspection_Task').getRecordTypeId();
                if(opp.Previous_Occupancy_End_Date__c != NULL)
                    ActivityDate = opp.Previous_Occupancy_End_Date__c.addDays(-14);

                /*Task t = InitiateNewTask('Pre-Move-Out Inspection', ActivityDate, PreMoveOutInspectionOwner, '0123u0000019nFBAAY', opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);*/


                Task t = InitiateNewTask('Pre-Move-Out Inspection', ActivityDate, PreMoveOutInspectionOwner, rtId_Move_Out_Inspection_Task, opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);
                TasksToCreate.add(t);
            }
            
        }
        
        if(opp.Home_Committed__r.Post_Move_Out_Inspection_Task__c == 'Yes'){
            
            String PostMoveOutInspectionOwner;
            
            if(opp.Home_Committed__r.Post_Move_Out_Inspection_Task_Owner__c == 'Porter'){
                PostMoveOutInspectionOwner = opp.Home_Committed__r.Porter__c;
            }else if(opp.Home_Committed__r.Post_Move_Out_Inspection_Task_Owner__c == 'Community Manager'){
                PostMoveOutInspectionOwner = opp.Home_Committed__r.Community_Manager__c;
            }else{
                PostMoveOutInspectionOwner = opp.Home_Committed__r.Maintenance_Tech__c;
            }
            
            if(PostMoveOutInspectionOwner != NULL){
                Date ActivityDate;
                Id rtId_Move_Out_Inspection_Task2 = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Move_Out_Inspection_Task').getRecordTypeId();
                if(opp.Previous_Occupancy_End_Date__c != NULL)
                    ActivityDate = opp.Previous_Occupancy_End_Date__c.addDays(1);
                /*Task t = InitiateNewTask('Post-Move-Out Inspection', ActivityDate, PostMoveOutInspectionOwner, '0123u0000019nFBAAY', opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);*/

                Task t = InitiateNewTask('Post-Move-Out Inspection', ActivityDate, PostMoveOutInspectionOwner, rtId_Move_Out_Inspection_Task2, opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);

                TasksToCreate.add(t);
            }
        }
        
        
        if(opp.Home_Committed__r.Leasing_Specialist_Move_out_Task__c == 'Yes'){
            String LSMoveOutTaskOwner; 
            Id rtId_CSS_Leasing_Specialist_Move_Out_Task = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSS_Leasing_Specialist_Move_Out_Task').getRecordTypeId();

            if(opp.Home_Committed__r.Leasing_Specialist_Move_out_Task_Owner__c == 'Leasing Specialist'){
                LSMoveOutTaskOwner = opp.Home_Committed__r.Leasing_Specialist__c;
            }else if(opp.Home_Committed__r.Leasing_Specialist_Move_out_Task_Owner__c == 'Community Manager'){
                LSMoveOutTaskOwner = opp.Home_Committed__r.Community_Manager__c;
            }else{
                LSMoveOutTaskOwner = opp.Home_Committed__r.Resident_Services_Coordinator__c;
            }
            
            if(LSMoveOutTaskOwner != NULL){
                /*Task t = InitiateNewTask('Leasing Specialist Move-Out Task', opp.Previous_Occupancy_End_Date__c, LSMoveOutTaskOwner, '0123u0000019nOxAAI', opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);*/

                Task t = InitiateNewTask('Leasing Specialist Move-Out Task', opp.Previous_Occupancy_End_Date__c, LSMoveOutTaskOwner, rtId_CSS_Leasing_Specialist_Move_Out_Task, opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);

                TasksToCreate.add(t);


            }
        }
        
        if(opp.Home_Committed__r.Onsite_Move_out_Task__c == 'Yes'){
            
            String OnsiteMoveOutTaskOwner;
            Id rtId_CSS_Onsite_Move_Out_Task = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSS_Onsite_Move_Out_Task').getRecordTypeId();

            if(opp.Home_Committed__r.Onsite_Move_out_Task_Owner__c == 'Maintenance Tech'){
                OnsiteMoveOutTaskOwner = opp.Home_Committed__r.Maintenance_Tech__c;
            }else {
                OnsiteMoveOutTaskOwner = opp.Home_Committed__r.Area_Manager__c;
            }
            
            if(OnsiteMoveOutTaskOwner != NULL){
                
                /*Task t = InitiateNewTask('Onsite Move Out Task', opp.Previous_Occupancy_End_Date__c, OnsiteMoveOutTaskOwner,  '0123u0000019nOwAAI', opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);*/

                Task t = InitiateNewTask('Onsite Move Out Task', opp.Previous_Occupancy_End_Date__c, OnsiteMoveOutTaskOwner,  rtId_CSS_Onsite_Move_Out_Task, opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);
                TasksToCreate.add(t);
            }
        }
        
        if(opp.Home_Committed__r.Sourcefit_Move_out_Task__c == 'Yes' && MemberUser.size() > 0){
            
            Date ActivityDate;
            Id rtId_CSS_Source_Fit_Move_Out_Task_Template = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSS_Source_Fit_Move_Out_Task_Template').getRecordTypeId();
            
            if(opp.Previous_Occupancy_End_Date__c != NULL)
                ActivityDate = opp.Previous_Occupancy_End_Date__c.addDays(1);

			/*Task t = InitiateNewTask('Source Fit Move Out', ActivityDate, MemberUser[0].Id, '0123u000000BUyYAAW', opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);*/

            Task t = InitiateNewTask('Source Fit Move Out', ActivityDate, MemberUser[0].Id, rtId_CSS_Source_Fit_Move_Out_Task_Template, opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);
            TasksToCreate.add(t);
        }

        return TasksToCreate;
    }

    
    public static List<Task> AssignEvictedGhostedTasksValues(Opportunity opp, list<User> MemberUser){

        list<Task> TasksToCreate = new list<Task>();

        if(opp.Home_Committed__r.Property_Services_Move_out_Task__c == 'Yes'){
                        
            String PSMoveOutTaskOwner;
            Id rtId_Property_Services_Move_Out_Task_Template2 = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Property_Services_Move_Out_Task_Template').getRecordTypeId();

            if(opp.Home_Committed__r.Property_Services_Move_out_Task_Owner__c == 'Porter'){
                PSMoveOutTaskOwner = opp.Home_Committed__r.Porter__c;
            }else {
                PSMoveOutTaskOwner = opp.Home_Committed__r.Maintenance_Tech__c;
            }
            
            if(PSMoveOutTaskOwner != NULL){
                
                Date ActivityDate;
                if(opp.Notice_Date__c != NULL)
                    ActivityDate = opp.Notice_Date__c.addDays(1);

                /*Task t = InitiateNewTask('Property Services Move Out', ActivityDate, PSMoveOutTaskOwner, '0123u000000BUyTAAW', opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);*/

                Task t = InitiateNewTask('Property Services Move Out', ActivityDate, PSMoveOutTaskOwner, rtId_Property_Services_Move_Out_Task_Template2, opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);

                TasksToCreate.add(t);
            }
        }
                      
        if(opp.Home_Committed__r.Post_Move_Out_Inspection_Task__c == 'Yes'){
            
            String PostMoveOutInspectionOwner;
            Id rtId_Move_Out_Inspection_Task3 = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Move_Out_Inspection_Task').getRecordTypeId();
            
            if(opp.Home_Committed__r.Post_Move_Out_Inspection_Task_Owner__c == 'Porter'){
                PostMoveOutInspectionOwner = opp.Home_Committed__r.Porter__c;
            }else if(opp.Home_Committed__r.Post_Move_Out_Inspection_Task_Owner__c == 'Community Manager'){
                PostMoveOutInspectionOwner = opp.Home_Committed__r.Community_Manager__c;
            }else{
                PostMoveOutInspectionOwner = opp.Home_Committed__r.Maintenance_Tech__c;
            }
            
            if(PostMoveOutInspectionOwner != NULL){
                Date ActivityDate;
                if(opp.Notice_Date__c != NULL)
                    ActivityDate = opp.Notice_Date__c.addDays(1);

                /*Task t = InitiateNewTask('Post-Move-Out Inspection', ActivityDate, PostMoveOutInspectionOwner, '0123u0000019nFBAAY', opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);*/

                Task t = InitiateNewTask('Post-Move-Out Inspection', ActivityDate, PostMoveOutInspectionOwner, rtId_Move_Out_Inspection_Task3, opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);

                TasksToCreate.add(t);
            }
        }
        
        
        if(opp.Home_Committed__r.Leasing_Specialist_Move_out_Task__c == 'Yes'){
            String LSMoveOutTaskOwner; 
            Id rtId_CSS_Leasing_Specialist_Move_Out_Task3 = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSS_Leasing_Specialist_Move_Out_Task').getRecordTypeId();

            if(opp.Home_Committed__r.Leasing_Specialist_Move_out_Task_Owner__c == 'Leasing Specialist'){
                LSMoveOutTaskOwner = opp.Home_Committed__r.Leasing_Specialist__c;
            }else if(opp.Home_Committed__r.Leasing_Specialist_Move_out_Task_Owner__c == 'Community Manager'){
                LSMoveOutTaskOwner = opp.Home_Committed__r.Community_Manager__c;
            }else{
                LSMoveOutTaskOwner = opp.Home_Committed__r.Resident_Services_Coordinator__c;
            }
            
            if(LSMoveOutTaskOwner != NULL){
                /*Task t = InitiateNewTask('Leasing Specialist Move-Out Task', opp.Notice_Date__c, LSMoveOutTaskOwner, '0123u0000019nOxAAI', opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);*/

                Task t = InitiateNewTask('Leasing Specialist Move-Out Task', opp.Notice_Date__c, LSMoveOutTaskOwner, rtId_CSS_Leasing_Specialist_Move_Out_Task3, opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);
                
                TasksToCreate.add(t);
            }
        }
        
        if(opp.Home_Committed__r.Onsite_Move_out_Task__c == 'Yes'){
            
            String OnsiteMoveOutTaskOwner;
            Id rtId_CSS_Onsite_Move_Out_Task2 = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSS_Onsite_Move_Out_Task').getRecordTypeId();

            if(opp.Home_Committed__r.Onsite_Move_out_Task_Owner__c == 'Maintenance Tech'){
                OnsiteMoveOutTaskOwner = opp.Home_Committed__r.Maintenance_Tech__c;
            }else {
                OnsiteMoveOutTaskOwner = opp.Home_Committed__r.Area_Manager__c;
            }
            
            if(OnsiteMoveOutTaskOwner != NULL){
                
                /*Task t = InitiateNewTask('Onsite Move Out Task', opp.Notice_Date__c, OnsiteMoveOutTaskOwner, '0123u0000019nOwAAI', opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);*/

                Task t = InitiateNewTask('Onsite Move Out Task', opp.Notice_Date__c, OnsiteMoveOutTaskOwner, rtId_CSS_Onsite_Move_Out_Task2, opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);

                TasksToCreate.add(t);
            }
        }
        
        if(opp.Home_Committed__r.Sourcefit_Move_out_Task__c == 'Yes' && MemberUser.size() > 0){
            
            Date ActivityDate;
            Id rtId_CSS_Source_Fit_Move_Out_Task_Template2 = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSS_Source_Fit_Move_Out_Task_Template').getRecordTypeId();

            if(opp.Notice_Date__c != NULL)
                ActivityDate = opp.Notice_Date__c.addDays(1);

            /*Task t = InitiateNewTask('Source Fit Move Out', ActivityDate, MemberUser[0].Id, '0123u000000BUyYAAW', opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);*/

            Task t = InitiateNewTask('Source Fit Move Out', ActivityDate, MemberUser[0].Id, rtId_CSS_Source_Fit_Move_Out_Task_Template2, opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Previous_Opportunity__c);

            TasksToCreate.add(t);
        }

        return TasksToCreate;
    }

    public static Task InitiateNewTask(String Subject, Date ActivityDate, String OwnerId, String RecordTypeId, String City, String Home, String Room, String Suite, String WhatId){
        Task t = new Task();
        t.Subject = Subject;
        t.ActivityDate = ActivityDate;
        t.OwnerId = OwnerId;
        t.Priority = 'Normal';
        t.Status = 'Open';
        t.RecordTypeId = RecordTypeId;
        t.City__c = City;
        t.Home__c = Home;
        t.Room__c = Room;
        t.Suite__c = Suite;
        t.WhatId = WhatId;
        if(String.isNotBlank(WhatId) && WhatId.startsWith('006'))
            t.Opportunity__c = WhatId;
        return t;
    }
}