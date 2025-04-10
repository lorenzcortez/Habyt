public class TaskTriggerhandler {
    
    public static void OnAfterInsert(list<Task> NewTasks){
        
        //Set<Id> commonRecordTypeIds = new Set<Id>();
        set<Id> SuiteIds            = new set<Id>();
        set<Id> HomeIDs             = new set<Id>();

        for(Task t : NewTasks){

            //if( commonRecordTypeIds.contains(t.RecordTypeId) ){
                if(t.Suite__c != NULL){
                    SuiteIds.add(t.Suite__c);                
                }
                if(t.Home__c != NULL){
                    HomeIDs.add(t.Home__c);
                }
            //}

           
        }
        Map<ID, Apartment__c> suiteMap = new Map<ID, Apartment__c>([SELECT Id, Product_type__c FROM Apartment__c WHERE ID IN :SuiteIds]);
        
        //written by JT to handle sub task insertion       
        //WHEN ADDING TO THIS LIST MAKE SURE TO ADD IT TO THE SAME LIST IN THE BEFORE INSERT TRIGGER
        List<String> RecordTypesNeedingSubtasksString = new list<String> { 'CSS_Clean_Room_Move_In_Task_Template' , 'CSS_Individual_Move_Out_Task_Template' , 'CSS_Property_Services_Move_In_Task_Template', 
            'CSS_Property_Services_Move_Out_Task_Template', 'CSS_Source_Fit_Move_In_Task_Template', 'CSS_Source_Fit_Move_Out_Task_Template',  'CSS_Source_Fit_Move_In_Create_eVault_Order_Task', 'Move_Out_Inspection_Task', 
            'CSS_Onsite_Move_In_Task', 'CSS_Leasing_Specialist_Move_Out_Task', 'CSS_Edge_Move_Out_Task', 'CSS_Systems_Inspection_Task', 'CSS_Sourcefit_Renters_Insurance_Check_In', 'RE_TSA_1',
            'RE_Support_Task', 'RE_Review_MA', 'RE_Pre_TSA_10', 'RE_Post_TSA_1', 'RE_Post_LOI', 'RE_Negotiate_and_Sign_TSA_2_3', 'RE_Draft_and_Negotiate_MA', 'RE_Business_Development_Task', 'Preventative_Maintenance',
            'CSS_Porter_Task', 'Shared_Goods_Count', 'Weekly_Checklist', 'Daily_Checklist', 'CSS_Noah_Renovation_Inspection'};
                
                
        List<Task> tasksNeedingSubtasks = new List<Task>();
        Map<String, Schema.RecordTypeInfo> RecordTypeInfoMap = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName();
        Map<Id, String> RecordTypeMapbyDevName = new Map<Id, String>();
        Map<String, String> RecordTypeMapbyName = new Map<String, String>();
        if(RecordTypeInfoMap != null){
            for(Schema.RecordTypeInfo rtInfo : RecordTypeInfoMap.values()){
                RecordTypeMapbyDevName.put(rtInfo.getRecordTypeId(), rtInfo.getDeveloperName());
                RecordTypeMapbyName.put(rtInfo.getDeveloperName(), rtInfo.getName());
            }
        }
        //Updated Date: March 4, 2024
        //Description: Added exception handling
        //START
        try {
            for(Task t : NewTasks){
    
                //if( commonRecordTypeIds.contains(t.RecordTypeId) ){
    
                    if(t.Home__c != null && t.RecordTypeId != null && RecordTypeMapbyDevName.get(t.RecordTypeId) != null && RecordTypesNeedingSubtasksString.contains(RecordTypeMapbyDevName.get(t.RecordTypeId)))
                        tasksNeedingSubtasks.add(t);
    
                //}
            }
            System.debug('asdfghjkl');
            if(tasksNeedingSubtasks != null){
                Map<id, Property__c> ID2HomeName = new Map<Id, Property__c>([Select id, name from Property__c WHERE ID IN :HomeIDs]);
                
                List<Checklist_setup__c> checkSetups = [SELECT id, unit_type__c, Checklist_Name__c, Task_Type__c, Is_Photo_Required__c from checklist_setup__c];
                Map<string, List<Checklist_setup__c>> RecordTypeToSubTasks = new Map<string, List<Checklist_setup__c>>();
                
                set<id> checklistids = new set<id>();
                for(String rt : RecordTypesNeedingSubtasksString){
                    List<Checklist_Setup__c> applicableSubTasks = new List<Checklist_Setup__c>();      
                    
                    for(Checklist_Setup__c cs : checkSetups){
                        if(RecordTypeMapbyName.get(rt) != null && cs.Task_Type__c == RecordTypeMapbyName.get(rt)){
                            applicableSubTasks.add(cs);
                            checklistids.add(cs.id);
                        }
                    }
                    
                    if(applicableSubTasks.size() > 0){
                        RecordTypeToSubTasks.put(rt, applicableSubTasks);
                    }
                }
                
                
                List<Sub_task__c> subTasksToInsert = new List<Sub_task__c>();
                
                map<id,list<string>> checklisthomemap = new map<id,list<string>>();
                //Updated Date: March 4, 2024
                //Description: Executes code block if trigger hasn't reach the maximum query row limit
                //START
                if(Limits.getQueryRows() < Limits.getLimitQueryRows()) {
                    
                    list<Checklist_Homes__c> chs = [select id,Home__r.Name,Checklist_Setup__c from Checklist_Homes__c where Checklist_Setup__c in:checklistids];
                
                    for(Checklist_Homes__c ch: chs){
                        if(checklisthomemap.keyset().contains(ch.Checklist_Setup__c)){
                            list<string> templist = checklisthomemap.get(ch.Checklist_Setup__c);
                            templist.add(ch.Home__r.Name);
                            checklisthomemap.put(ch.Checklist_Setup__c,templist );
                        }
                        else{
                            list<string> templist = new list<string>();
                            templist.add(ch.Home__r.Name);
                            checklisthomemap.put(ch.Checklist_Setup__c,templist );
                        }
                    }
                    
                    for(Task t : tasksNeedingSubtasks){
                        List<Checklist_Setup__c> SubTaskNames = RecordTypeToSubTasks.get(RecordTypeMapbyDevName.get(t.RecordTypeid));
                        if(subTaskNames != null){
                        }
                        
                        if(t.Home__c != null){
                            if(subTaskNames != null){
                                for(Checklist_setup__c cs : SubTaskNames){
                                    List<String> picked = checklisthomemap.get(cs.id);
                                    
                                    if(picked != null && picked.contains(ID2HomeName.get(t.Home__c).name)){
                                        if(t.suite__c == null || cs.Unit_Type__c == 'All Unit Types' || (t.Suite__c != NULL && suiteMap.get(t.Suite__c) != NULL && suiteMap.get(t.Suite__c).Product_type__c != NULL && suiteMap.get(t.Suite__c).Product_type__c.equalsIgnoreCase(cs.Unit_Type__c))){
                                            sub_task__c subtask = new Sub_task__c();
                                            subtask.Name = cs.Checklist_Name__c;
                                            subtask.Is_Photo_Required__c = cs.Is_Photo_Required__c;
                                            subtask.Home__c = t.Home__c;
                                            subtask.Suite__c = t.Suite__c;
                                            subtask.Room__c = t.Room__c;
                                            subtask.Task_ID__c = t.Id;
                                            subtask.Due_Date__c = t.ActivityDate;
                                            subtask.Task_Record_Type_Name__c = RecordTypeMapbyDevName.get(t.RecordTypeid);
                                            subtask.Master_Checklist__c = t.Master_Checklist__c;
                                            subTasksToInsert.add(subtask);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    insert subTasksToInsert;
                }
        	}
        }
        catch(Exception e) {
            System.debug('Exception : '+e);
        }
      
        
        set<id> CaseIds = new set<id>();
        for(Task t : NewTasks){

            //if( commonRecordTypeIds.contains(t.RecordTypeId) ){

                if(t.WhatID != null && String.ValueOF(t.WhatID).startsWith('500') && t.Status == 'Completed' && t.type != 'Outbound Email'){
                    CaseIds.add(t.WhatID);
                }       
            
            //}
        }
        
        if(CaseIds.size() > 0){
            UpdateParentCasesToOpen(CaseIds);
        }
        
    }
    
    public static void OnAfterUpdate(list<Task> NewTasks, Map<id,Task> OldTask){

        //Set<Id> commonRecordTypeIds = new Set<Id>();
        set<id> CaseIds             = new set<id>();
        for(Task t : NewTasks){

            //if( commonRecordTypeIds.contains(t.RecordTypeId) ){
                if(t.WhatID != null && String.ValueOF(t.WhatID).startsWith('500') && t.Status == 'Completed' && OldTask.get(t.id).Status != 'Completed' && t.type != 'Outbound Email'){
                    CaseIds.add(t.WhatID);
                }         
            //}   

        }
        
        if(CaseIds.size() > 0){
            UpdateParentCasesToOpen(CaseIds);
        }
        
        // List<Task> TaskListUpdateWorkOrders = new List<Task>();
        // Map<id, Task> TaskMapUpdateWorkOrdersOld = new Map<id, Task>();
        // for(task t: NewTasks){
        //     if(t.Work_Order__c != null && (t.Home__c != OldTask.get(t.id).home__c || t.suite__c != OldTask.get(t.id).suite__c || t.room__c != OldTask.get(t.id).room__c || t.ActivityDate != OldTask.get(t.id).ActivityDate || t.whatid != OldTask.get(t.id).whatid)){
        //         TaskListUpdateWorkOrders.add(t);
        //         TaskMapUpdateWorkOrdersOld.put(t.id, OldTask.get(t.id));
        //     }
        // }

        // if(TaskListUpdateWorkOrders.size() > 0)
        //     UpdateWorkOrders(TaskListUpdateWorkOrders, TaskMapUpdateWorkOrdersOld);
        
        
        List<Task> TaskListDateChanged = new List<Task>();
        for(task t: NewTasks){
            
        }
    }
    
    public static void OnBeforeDelete(Map<id,Task> OldTask){
        Set<Id> WorkOrderIDs = new Set<ID>();
        for(task t: OldTask.values()){
            if(t.work_order__c != null)
                WorkOrderIDs.add(t.Work_Order__c);
        }
        if(WorkORderIds.size() > 0)
            Delete [Select id from workorder where id in: WorkOrderIDs];
        List<sub_task__c> subTasksToDelete = [Select id from sub_task__c where task_id__c in: OldTask.keySet()];
        if(subTasksToDelete.size() > 0)
            delete subTasksToDelete;
    }
    
    public static void UpdateParentCasesToOpen(set<id> CaseIds){
        list<Case> Cases = [select id,Status from Case where Status != 'Open' and 
                            (RecordType.Name like '%CSS%' OR RecordType.Name in 
                             ('NOAH_Lease_and_Billing_Inquiries', 'NOAH_Property_Issue', 
                              'KIN_Lease_and_Billing_Inquiries', 'KIN_Property_Issue')) AND ID IN :CaseIds];
        for(Case c: Cases){
            c.Status = 'Open';
        }
        
        if(Cases.size() > 0)
            update Cases;
    }
    
    public static void OnBeforeInsert(list<Task> NewTasks){
        
        //Set<Id> commonRecordTypeIds = new Set<Id>();

        // createWorkOrders(NewTasks);
        
        
        //Created By JT this part is for creation of master checklist
        
        List<Task> tasksNeedingSubtasks = new List<Task>();
        List<String> RecordTypesNeedingSubtasksString = new list<String> { 'CSS_Clean_Room_Move_In_Task_Template' , '', 'CSS_Individual_Move_Out_Task_Template' , 'CSS_Property_Services_Move_In_Task_Template', 
            'CSS_Property_Services_Move_Out_Task_Template', 'CSS_Source_Fit_Move_In_Task_Template', 'CSS_Source_Fit_Move_Out_Task_Template',  'CSS_Source_Fit_Move_In_Create_eVault_Order_Task', 'Move_Out_Inspection_Task', 
            'CSS_Onsite_Move_In_Task', 'CSS_Leasing_Specialist_Move_Out_Task', 'CSS_Edge_Move_Out_Task', 'CSS_Systems_Inspection_Task', 'CSS_Sourcefit_Renters_Insurance_Check_In', 'RE_TSA_1',
            'RE_Support_Task', 'RE_Review_MA', 'RE_Pre_TSA_10', 'RE_Post_TSA_1', 'RE_Post_LOI', 'RE_Negotiate_and_Sign_TSA_2_3', 'RE_Draft_and_Negotiate_MA', 'RE_Business_Development_Task', 'Preventative_Maintenance',
            'CSS_Porter_Task', 'Shared_Goods_Count', 'Weekly_Checklist', 'Daily_Checklist', 'CSS_Noah_Renovation_Inspection'};
                
                
        Map<String, Schema.RecordTypeInfo> RecordTypeInfoMap = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName();
        Map<Id, String> RecordTypeMapbyDevName = new Map<Id, String>();
        Map<String, String> RecordTypeMapbyName = new Map<String, String>();
        if(RecordTypeInfoMap != null){
            for(Schema.RecordTypeInfo rtInfo : RecordTypeInfoMap.values()){
                RecordTypeMapbyDevName.put(rtInfo.getRecordTypeId(), rtInfo.getDeveloperName());
                RecordTypeMapbyName.put(rtInfo.getDeveloperName(), rtInfo.getName());
            }
        }
        
        for(Task t : NewTasks){
            //if( commonRecordTypeIds.contains(t.RecordTypeId) ){
                if(t.RecordTypeId != null && RecordTypeMapbyDevName.get(t.RecordTypeId) != null && RecordTypesNeedingSubtasksString.contains(RecordTypeMapbyDevName.get(t.RecordTypeId)))
                    tasksNeedingSubtasks.add(t);
            //}
        }
        
        
        List<Master_checklist__c> checklists = new List<Master_checkList__C>();
        for(Task t: tasksNeedingSubtasks){
            Master_Checklist__c mc = new Master_Checklist__c();
            mc.name = t.subject;
            checklists.add(mc);
        }
        
        if(checklists.size() > 0)
            insert checklists;
        
        
        integer index = 0;
        for(Task t: tasksNeedingSubtasks){
            t.Master_Checklist__c = checklists[index].id;
            index++;
        }
        
        
        
        //PopulateWhoWhatId(NewTasks);
        
        list<task> TaskwithDesc = new list<task>();
        
        for(task t: NewTasks){

            //if( commonRecordTypeIds.contains(t.RecordTypeId) ){

                if(t.Description != null){
                    TaskwithDesc.add(t);
                }
            //}
        }
        
        if(TaskwithDesc.size() > 0){
            SetCallDisposition(TaskWithDesc);
        }
        
        PopulateAssignedToFromHome(NewTasks);
        populatecallDisposition(NewTasks);
    }
    
    public static void OnBeforeUpdate(list<Task> NewTasks, Map<id,Task> OldTask){
        //Set<Id> commonRecordTypeIds         = new Set<Id>();
        list<task> TaskwithDesc             = new list<task>();
        list<task> TasksToValidateSubTasks  = new list<task>();
        
        for(task t: NewTasks){

            //if( commonRecordTypeIds.contains(t.RecordTypeId) ){

                if(t.Description != null && t.Description != OldTask.get(t.id).Description){
                    TaskwithDesc.add(t);
                }
                if(t.Status == 'Completed' && OldTask.get(t.Id).Status != 'Completed'){
                    TasksToValidateSubTasks.add(t);
                }

            //}
        }
        
        if(TaskwithDesc.size() > 0){
            SetCallDisposition(TaskWithDesc);
        }
        
        if(TasksToValidateSubTasks.size() > 0){
            ValidateSubTasksCompleted(TasksToValidateSubTasks);
        }
    }
    
    public static void SetCallDisposition(list<task> newTask){
        
        for(task t: newTask){
            if(t.Description != null && ( t.Description.ToLowerCase().contains('call disposition') || t.Description.ToLowerCase().contains('call disposition code') ) ){
                
                list<string> desclines = t.description.split('\n'); 
                String CD = '';
                
                for(string s: desclines ){
                    if(s != null){
                        
                        if(s.ToLowerCase().contains('call disposition code')){
                            if(s.length()> (s.ToLowerCase().IndexOf('call disposition code:')+22))
                                CD = s.substring(s.ToLowerCase().IndexOf('call disposition code:')+22,s.Length());
                        }
                        else if(s.ToLowerCase().contains('call disposition')){
                            if(s.length()> (s.ToLowerCase().IndexOf('call disposition:')+17))
                                CD = s.substring(s.ToLowerCase().IndexOf('call disposition:')+17,s.Length());
                        }
                    }
                    
                    
                }
                
                t.Call_Disposition__c = CD;
            }
        }
    }
    
    //Then make it so IF a task is created with the "Preventative Maintenance" record type AND it’s related to a home THEN reference that field for the task assigned user.
    public static void PopulateAssignedToFromHome(list<Task> NewTasks){
        
        //Set<Id> commonRecordTypeIds = new Set<Id>();
        set<Id> HomeIds             = new set<Id>();
        
        for(Task t : NewTasks){

            //if( commonRecordTypeIds.contains(t.RecordTypeId) ){

                if(t.RecordTypeId != null && t.WhatId != null){
                    string RecordTypeName = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosById().get(t.RecordTypeId).getDeveloperName();
                    string RelatedObject = string.valueOf(t.WhatId.getsobjecttype());
                    
                    if(RecordTypeName == 'Preventative_Maintenance' && RelatedObject == 'Property__c'){
                        HomeIds.add(t.WhatId);
                    }
                }

            //}
        }
        
        
        if(HomeIds.size() > 0){
            map<Id, Property__c> HomesMap = new map<Id, Property__c>([SELECT Id, Name, Maintenance_Tech__c FROM Property__c WHERE Id IN :HomeIds AND Maintenance_Tech__c != null]);
            
            
            for(Task t : NewTasks){

                //if( commonRecordTypeIds.contains(t.RecordTypeId) ){

                    if(t.RecordTypeId != null && t.WhatId != null){
                        string RecordTypeName = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosById().get(t.RecordTypeId).getDeveloperName();
                        string RelatedObject = string.valueOf(t.WhatId.getsobjecttype());
                        
                        if(RecordTypeName == 'Preventative_Maintenance' && RelatedObject == 'Property__c'){
                            if(HomesMap.get(t.WhatId) != null){
                                t.OwnerId = HomesMap.get(t.WhatId).Maintenance_Tech__c;
                            }
                        }
                    }

                //}
            }
            
        }
    }
    
    
    public static void ValidateSubTasksCompleted(list<Task> TasksToValidate){
        
        set<Id> TaskIds = new set<Id>();
        for(Task t : TasksToValidate){
            TaskIds.add(t.Id);
        }
        
        
        list<Sub_Task__c> OpenSubTasks = new list<Sub_Task__c>();
        OpenSubTasks = [Select Task_ID__c FROM Sub_Task__c Where Task_ID__c IN : TaskIds AND Is_Completed__c = false];
        
        if(OpenSubTasks.size() > 0){
            
            //creating map of task id vs list of open sub tasks
            Map<string, list<Sub_Task__c>> OpenSubTasksMap = new Map<string, list<Sub_Task__c>>();
            
            for(Sub_Task__c st : OpenSubTasks){
                if (OpenSubTasksMap.containsKey(st.Task_ID__c)){
                    OpenSubTasksMap.get(st.Task_ID__c).add(st);
                }else{
                    OpenSubTasksMap.put(st.Task_ID__c, new  List <Sub_Task__c> { st });
                }
            }
            
            for(Task t : TasksToValidate){
                if(t.Status == 'Completed' && OpenSubTasksMap.get(t.Id) != null && OpenSubTasksMap.get(t.Id).size() > 0){
                    t.addError('Please complete the sub tasks before marking this task as completed.'); 
                }
            }    
            
        }
        
    }
    
    public static void populatecallDisposition(list<Task> Tasks){
        for(Task t : tasks){
            if(t.Subject != null && t.Subject.ContainsIgnoreCase('[Completed]') && t.Description != null && t.Description.Contains('Outcome:')){
                string callDisposition;
                list<String> CallAttributes = t.Description.split('\n');
                for(string att : CallAttributes){
                    if(att.contains('Outcome:')){
                        callDisposition = att.replace('Outcome:','').trim();
                        //split string to 255 characters if it is more than 255 characters
                        if(callDisposition.length() > 255)
                            callDisposition = callDisposition.substring(0, 255);
                        t.Call_Disposition__c = callDisposition;
                        system.debug(callDisposition);
                    }
                }
            }
        }
    }

    /**
     * Not used in Habyt
     */

    // public static void createWorkOrders(List<Task> tasks){
    //     Map<String, workType> subjectToWorkType = new Map<String, WorkType>();
        
    //     List<WorkType> workTypes = [Select id, Task_Record_Type_ID__c, name, description, priority__c, earliest_Start_date_window__c, due_date_window__c, EstimatedDuration from worktype where sub_issue_Type__C = 'PS Task'];
        
    //     //create list of task recordTypes that need work Types
    //     List<ID> taskrecordTypes = new List<ID>();
    //     ID PSMoveIn;
    //     ID abandonmentRecordType;
    //     id moveOutInspection;
        
    //     Map<String, workType> recordTypeToWorkType = new Map<String, workType>();
        
    //     for(workType wt: workTypes){
    //         if(wt.name.contains('Inspection')){
    //             moveOutInspection = wt.Task_Record_Type_ID__c;
    //         }
    //         if (wt.name == 'Abandonment Task'){
    //             abandonmentRecordType = wt.Task_Record_Type_ID__c;
    //             subjectToWorkType.put(abandonmentRecordType, wt);
    //         }
    //         else{
    //             subjectToWorkType.put(wt.name, wt);
    //         }
    //         taskrecordTypes.add(wt.Task_Record_Type_ID__c);
            
    //         if (wt.name == 'Abandonment Task'){
    //             recordTypeToWorkType.put(wt.Task_Record_Type_ID__c, wt);
    //         }
    //         else if (wt.name == 'Pre-Move-Out Inspection'){
    //             recordTypeToWorkType.put('Pre-Move-Out Inspection', wt);
    //         }
    //         else if (wt.name == 'Post-Move-Out Inspection'){
    //             recordTypeToWorkType.put('Post-Move-Out Inspection', wt);
    //         }
            
    //         else{
    //             recordTypeToWorkType.put(wt.Task_Record_Type_ID__c, wt);
    //         }
    //     }
        
    //     set<Id> SuiteIds = new set<Id>();
    //     set<Id> HomeIDs = new set<Id>();
    //     for(Task t : Tasks){
    //         if(t.Suite__c != NULL){
    //             SuiteIds.add(t.Suite__c);                
    //         }
    //         if(t.Home__c != NULL){
    //             HomeIDs.add(t.Home__c);
    //         }
    //     }
    //     Map<ID, Apartment__c> suiteMap = new Map<ID, Apartment__c>([SELECT Id, Product_type__c FROM Apartment__c WHERE Id IN : SuiteIds]);
    //     Map<ID, Property__c> HomeMap = new Map<ID, Property__c>([SELECT Id, name, service_Territory__c, service_Territory__r.isActive, Turnover_Painting_Responsibility__c, service_Territory__r.state, service_Territory__r.street FROM Property__c WHERE ID IN : HomeIds]);
        
    //     List<Task> tasksNeedingWorkOrders = new List<Task>();        
        
    //     for(task t: Tasks){
    //         if(t.Home__c != null){
    //             if(HomeMap.get(t.Home__c) != NULL && HomeMap.get(t.Home__c).service_Territory__c != null && HomeMap.get(t.Home__c).service_Territory__r.IsActive == true && taskRecordTypes.contains(t.recordTypeid)){
    //                 tasksNeedingWorkOrders.add(t);
    //             }
    //         }
    //     }
        
    //     Map<Id, ServiceAppointment> InitialSAMap = new Map<Id, ServiceAppointment>();
    //     Map<String, WorkOrder> taskWorkOrderMap = new Map<String, WorkOrder>();
        
        
    //     for(task t: tasksNeedingWorkOrders){
    //         workType wt = new WorkType();
    //         Workorder WO = new WorkOrder();
    //         System.debug('JT Subject: ' + t.subject);
    //         if(t.Subject.contains('Property Services Move Out')){
    //             if(t.suite__c != NULL && suiteMap.get(t.suite__c) != NULL && suiteMap.get(t.suite__c).Product_type__c == 'coliving'){
    //                 wt = subjectToWorkType.get( 'Property Services Move Out (Coliving)');
    //             }
    //             else{
    //                 wt = subjectToWorkType.get('Property Services Move Out (Traditional)');
    //             }
                
    //         }
    //         else if(t.recordTypeid == abandonmentRecordType){
    //             wt = recordTypeToWorkType.get(abandonmentRecordType);
    //             WO.caseId = t.WhatId;
    //         }
    //         else if(t.subject.toLowerCase().contains('pre-')){
    //             wt = recordTypeToWorkType.get('Pre-Move-Out Inspection');
    //         }
    //         else if(t.subject.toLowerCase().contains('post-')){
    //             wt = recordTypeToWorkType.get('Post-Move-Out Inspection');
    //         }
    //         else{
    //             wt = recordTypeToWorkType.get(t.recordTypeid);
    //         }
    //         System.debug('WorkType name: ' + wt.Name);
    //         WO.WorkTypeId = wt.id;
    //         WO.accountid = t.AccountId;
    //         WO.City = t.City__c;
    //         WO.CurrencyIsoCode = 'USD';
    //         WO.Home__c = t.Home__c;
    //         WO.Opportunity__c = t.Opportunity__c;
    //         WO.OwnerId = t.OwnerId;
    //         if(t.Home__c != NULL && HomeMap.get(t.Home__c) != NULL && HomeMap.get(t.Home__c).service_Territory__c != NULL){
    //             WO.ServiceTerritoryId = HomeMap.get(t.Home__c).service_Territory__c;
    //             WO.State = HomeMap.get(t.Home__c).service_Territory__r.state;
    //             WO.Street = HomeMap.get(t.Home__c).service_Territory__r.street;
    //         }
    //         WO.Suite__c = t.Suite__c;
    //         WO.Room__c = t.Room__c;
    //         WO.Priority = 'High';
    //         WO.Subject = t.Subject;
    //         WO.total_reschedules__c = 0;
    //         Wo.Status = 'New';
    //         if(wt.Name == 'Property Services Move In' &&  wo.Home__c != NULL && HomeMap.get(wo.home__c) != NULL && (HomeMap.get(wo.home__c).name == 'LINEA' || HomeMap.get(wo.home__c).name == 'The Edge' || HomeMap.get(wo.home__c).name == 'STELLA')){
                
    //         }
    //         else{
    //             taskWorkOrderMap.put(t.whatid + t.Subject, WO);
    //         }
    //     }
        
    //     insert taskWorkOrderMap.values();
    //     List<ServiceAppointment> FollowUpSAs = new List<ServiceAppointment>();
    //     for(task t: tasksNeedingWorkOrders){
    //         workType wt = new WorkType();
    //         ServiceAppointment sa = new ServiceAppointment();
    //         ServiceAppointment SAFollowUp = new ServiceAppointment();
    //         if(t.Subject.contains('Property Services Move Out')){
    //             if(t.suite__c != NULL && suiteMap.get(t.suite__c) != NULL && suiteMap.get(t.suite__c).Product_type__c == 'coliving'){
    //                 wt = subjectToWorkType.get( 'Property Services Move Out (Coliving)');
    //             }
    //             else{
    //                 wt = subjectToWorkType.get('Property Services Move Out (Traditional)');
    //                 if(t.Home__c != NULL && HomeMap.get(t.Home__c) != NULL && HomeMap.get(t.Home__c).Turnover_Painting_Responsibility__c == 'Internal'){
    //                     sa.Needs_Follow_Up_Appointment__c = 'No';
    //                     SAFollowUp.currencyISOCode = 'USD';
    //                     SAFollowUp.FSL__GanttLabel__c = HomeMap.get(t.Home__c).name + ' | ' + wt.Name;
    //                     SAFollowUp.Needs_Follow_Up_Appointment__c = 'Yes';
    //                     SAFollowUp.ServiceTerritoryId = HomeMap.get(t.Home__c).service_Territory__c;
    //                     SAFollowUp.subject = 'Move Out Turnover Painting';
    //                     SAFollowUp.ParentRecordId = taskWorkOrderMap.get(t.whatId + t.Subject).id;
    //                     SAFollowUp.duration = 8;
    //                     SAfollowup.DurationType = 'Hours';
    //                     SAFollowUp.Initial_Appointment__c = false;
    //                     SAFollowUp.Home__c = t.Home__c;
    //                     SAFollowUp.Opportunity__c = t.Opportunity__c;
    //                     SAFollowUp.suite__c = t.Suite__c;
    //                     SAFollowUp.Room__c = t.Room__c;
    //                     SAFollowUp.num_of_reschedules__c = 0;
    //                     SAFollowUp.EarliestStartTime = datetime.newInstance(t.ActivityDate, Time.newInstance(09, 00, 00, 00));
    //                     SAFollowUp.DueDate = datetime.newInstance(t.ActivityDate, Time.newInstance(18, 00, 00, 00));
    //                     SAFollowUp.Description = wt.description;
    //                     SAFollowUp.priority__c = 'High';
    //                     SAFollowUp.Status = 'New';
    //                     SAFollowUp.PTE_notice_sent__c = true;
    //                     FollowUpSAs.add(SAFollowUp);
                        
    //                 }
    //                 else{
    //                     sa.Needs_Follow_Up_Appointment__c = 'No';
    //                 }
    //             }
    //         }
    //         else if(t.recordTypeid == abandonmentRecordType){
    //             wt = recordTypeToWorkType.get(abandonmentRecordType);
    //             sa.case__c = t.WhatId;
    //         }
    //         else if(t.subject.contains('Pre-Move-Out')){
    //             wt = recordTypeToWorkType.get('Pre-Move-Out Inspection');
    //         }
    //         else if(t.subject.contains('Post-Move-Out')){
    //             wt = recordTypeToWorkType.get('Post-Move-Out Inspection');
    //         }
    //         else{
    //             wt = recordTypeToWorkType.get(t.recordTypeid);
    //         }
    //         if(wt.Name == 'Property Services Move In' && t.Home__c != NULL && HomeMap.get(t.home__c) != NULL && (HomeMap.get(t.home__c).name == 'LINEA' || HomeMap.get(t.home__c).name == 'The Edge' || HomeMap.get(t.home__c).name == 'STELLA' || HomeMap.get(t.home__c).name == '5800 Harold')){
                
    //         }
    //         else{
    //             sa.currencyISOCode = 'USD';
    //             sa.FSL__GanttLabel__c = HomeMap.get(t.Home__c).name + ' | ' + wt.Name;
    //             sa.ServiceTerritoryId = HomeMap.get(t.Home__c).service_Territory__c;
    //             sa.subject = t.subject;
    //             sa.ParentRecordId = taskWorkOrderMap.get(t.whatId + t.Subject).id;
    //             sa.duration = wt.estimatedDuration;
    //             sa.Initial_Appointment__c = true;
    //             sa.Home__c = t.Home__c;
    //             sa.Opportunity__c = t.Opportunity__c;
    //             sa.suite__c = t.Suite__c;
    //             sa.Room__c = t.Room__c;
    //             sa.num_of_reschedules__c = 0;
    //             sa.EarliestStartTime = datetime.newInstance(t.ActivityDate.addDays(Integer.valueOf(-wt.Earliest_Start_Date_Window__c)), Time.newInstance(09, 00, 00, 00));
    //             sa.DueDate = datetime.newInstance(t.ActivityDate.addDays(Integer.valueOf(wt.Due_Date_Window__c)), Time.newInstance(18, 00, 00, 00));
    //             sa.Description = wt.description;
    //             sa.priority__c = 'High';
    //             sa.Status = 'New';
    //             sa.PTE_notice_sent__c = true;
    //             InitialSAMap.put(sa.ParentRecordId, sa);
    //         }
    //     }
    //     insert InitialSAMap.values();
        
    //     insert FollowUpSAs;
        
    //     List<String> RecordTypesNeedingSubtasksString = new list<String> { 'CSS_Clean_Room_Move_In_Task_Template' , 'CSS_Individual_Move_Out_Task_Template' , 'CSS_Property_Services_Move_In_Task_Template', 
    //         'CSS_Property_Services_Move_Out_Task_Template', 'CSS_Source_Fit_Move_In_Task_Template', 'CSS_Source_Fit_Move_Out_Task_Template',  'CSS_Source_Fit_Move_In_Create_eVault_Order_Task', 'Move_Out_Inspection_Task', 
    //         'CSS_Onsite_Move_In_Task', 'CSS_Leasing_Specialist_Move_Out_Task', 'CSS_Edge_Move_Out_Task', 'CSS_Sourcefit_Renters_Insurance_Check_In', 'Preventative_Maintenance', 'CIS_Abandonment_Notice',
    //         'CSS_Porter_Task', 'Shared_Goods_Count', 'CSS_Noah_Renovation_Inspection'};
                
                
    //     List<Task> tasksNeedingLineItems = new List<Task>();
    //     Map<String, Schema.RecordTypeInfo> RecordTypeInfoMap = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName();
    //     Map<Id, String> RecordTypeMapbyDevName = new Map<Id, String>();
    //     Map<String, String> RecordTypeMapbyName = new Map<String, String>();
    //     if(RecordTypeInfoMap != null){
    //         for(Schema.RecordTypeInfo rtInfo : RecordTypeInfoMap.values()){
    //             RecordTypeMapbyDevName.put(rtInfo.getRecordTypeId(), rtInfo.getDeveloperName());
    //             RecordTypeMapbyName.put(rtInfo.getDeveloperName(), rtInfo.getName());
    //         }
    //     }
        
    //     for(Task t : tasksNeedingWorkOrders){
    //         //dont set the work order field on the property services move in task on these homes because they dont need work orders
    //         if(t.subject == 'Property Services Move In' && t.Home__c != NULL && HomeMap.get(t.Home__c) != NULL && (HomeMap.get(t.home__c).name == 'LINEA' || HomeMap.get(t.home__c).name == 'The Edge' || HomeMap.get(t.home__c).name == 'STELLA')){
                
    //         } 
            
    //         // else{
    //         //     t.work_order__c = taskWorkOrderMap.get(t.whatId + t.Subject).id;
    //         // }
    //     }
        
    //     for(Task t : tasksNeedingWorkOrders){
    //         if(t.Home__c != null && t.RecordTypeId != null && RecordTypeMapbyDevName.get(t.RecordTypeId) != null && RecordTypesNeedingSubtasksString.contains(RecordTypeMapbyDevName.get(t.RecordTypeId))){
    //             if(t.subject == 'Property Services Move In' && t.Home__c != NULL && HomeMap.get(t.Home__c) != NULL && (HomeMap.get(t.home__c).name == 'LINEA' || HomeMap.get(t.home__c).name == 'The Edge' || HomeMap.get(t.home__c).name == 'STELLA')){
                    
    //             }
    //             else{
    //                 tasksNeedingLineItems.add(t);
    //             }
    //         }
    //     }
        
    //     if(tasksNeedingLineItems != null){
    //         Map<id, home__c> ID2HomeName = new Map<Id, home__c>([Select id, name from home__c WHERE ID IN :HomeIds]);
            
    //         List<Checklist_setup__c> checkSetups = [SELECT id, unit_type__c, Checklist_Name__c, Task_Type__c, Is_Photo_Required__c from checklist_setup__c];
    //         Map<string, List<Checklist_setup__c>> RecordTypeToSubTasks = new Map<string, List<Checklist_setup__c>>();
            
    //         set<id> checklistids = new set<id>();
    //         for(String rt : RecordTypesNeedingSubtasksString){
    //             List<Checklist_Setup__c> applicableSubTasks = new List<Checklist_Setup__c>();      
    //             for(Checklist_Setup__c cs : checkSetups){
                    
    //                 if(RecordTypeMapbyName.get(rt) != null && cs.Task_Type__c == RecordTypeMapbyName.get(rt)){
    //                     applicableSubTasks.add(cs);
    //                     checklistids.add(cs.id);
    //                 }
    //             }
                
    //             if(applicableSubTasks.size() > 0){
    //                 RecordTypeToSubTasks.put(rt, applicableSubTasks);
    //             }
    //         }
            
            
    //         List<WorkOrderLineItem> WOLIToInsert = new List<WorkOrderLineItem>();
            
    //         map<id,list<string>> checklisthomemap = new map<id,list<string>>();
    //         list<Checklist_Homes__c> chs = [select id,Home__r.Name,Checklist_Setup__c from Checklist_Homes__c where Checklist_Setup__c in:checklistids];
            
    //         for(Checklist_Homes__c ch: chs){
    //             if(checklisthomemap.keyset().contains(ch.Checklist_Setup__c)){
    //                 list<string> templist = checklisthomemap.get(ch.Checklist_Setup__c);
    //                 templist.add(ch.Home__r.Name);
    //                 checklisthomemap.put(ch.Checklist_Setup__c,templist );
    //             }
    //             else{
    //                 list<string> templist = new list<string>();
    //                 templist.add(ch.Home__r.Name);
    //                 checklisthomemap.put(ch.Checklist_Setup__c,templist );
    //             }
    //         }
            
    //         for(Task t : tasksNeedingLineItems){
    //             List<Checklist_Setup__c> SubTaskNames = RecordTypeToSubTasks.get(RecordTypeMapbyDevName.get(t.RecordTypeid));
    //             if(t.Home__c != null){
    //                 if(subTaskNames != null){
    //                     for(Checklist_setup__c cs : SubTaskNames){
    //                         List<String> picked = checklisthomemap.get(cs.id);
    //                         if(picked != null && picked.contains(ID2HomeName.get(t.Home__c).name)){
    //                             if(t.suite__c == null || cs.Unit_Type__c == 'All Unit Types' || ( t.Suite__c != NULL && suiteMap.get(t.Suite__c) != NULL && suiteMap.get(t.Suite__c).Product_type__c != NULL && suiteMap.get(t.Suite__c).Product_type__c.equalsIgnoreCase(cs.Unit_Type__c))){
    //                                 WorkORderLineITem WOLI = new WorkOrderLineItem();
    //                                 WOLI.subject = cs.Checklist_Name__c;
    //                                 WOLI.status = 'New';
    //                                 WOLI.WorkOrderId = taskWorkOrderMap.get(t.whatId + t.Subject).id;
    //                                 WOLIToInsert.add(WOLI);
    //                             }
    //                         }
    //                     }
    //                 }
    //             }
    //         }
            
            
    //         insert WOLIToInsert;
    //     }
        
        
    //     //abandonment tasks are not created via the checklist setup so this needs to be done separately, the reason for this is
    //     //the tasks change whether or not its coliving/traditional.
    //     List<WorkOrderLineItem> AbandonmentLineItems = new List<WorkOrderLineItem>();
    //     List<Task> abandonmentTasks = new List<Task>();
    //     for(task t: TasksNeedingWorkOrders){
    //         //check if recordtypeid is abandonment notice
    //         if(t.RecordTypeId == '0123u000000BVb9AAG')
    //             abandonmentTasks.add(t);
    //     }
    //     for(task t: abandonmentTasks){
    //         if(t.Suite__c != NULL && suitemap.get(t.Suite__c) != NULL && suitemap.get(t.Suite__c).Product_type__c == 'coliving'){
    //             WorkORderLineITem WOLI = new WorkOrderLineItem();
    //             WOLI.subject = '1. Take two pictures of closet from different angles';
    //             WOLI.status = 'New';
    //             WOLI.WorkOrderId = taskWorkOrderMap.get(t.whatId + t.Subject).id;
    //             AbandonmentLineItems.add(WOLI);
                
    //             WorkORderLineITem WOLI2 = new WorkOrderLineItem();
    //             WOLI2.subject = '2. Take two pictures of bed area from different angles';
    //             WOLI2.status = 'New';
    //             WOLI2.WorkOrderId = taskWorkOrderMap.get(t.whatId + t.Subject).id;
    //             AbandonmentLineItems.add(WOLI2);
                
    //             WorkORderLineITem WOLI3 = new WorkOrderLineItem();
    //             WOLI3.subject = '3. Take two pictures of ensuite bathroom from different angles (if applicable)';
    //             WOLI3.status = 'New';
    //             WOLI3.WorkOrderId = taskWorkOrderMap.get(t.whatId + t.Subject).id;
    //             AbandonmentLineItems.add(WOLI3);
    //         }
    //         else if(t.Suite__c != NULL && suitemap.get(t.Suite__c) != NULL && suitemap.get(t.Suite__c).Product_type__c == 'traditional'){
    //             WorkORderLineITem WOLI = new WorkOrderLineItem();
    //             WOLI.subject = '1. Take two pictures of kitchen with cabinets open from different angles';
    //             WOLI.status = 'New';
    //             WOLI.WorkOrderId = taskWorkOrderMap.get(t.whatId + t.Subject).id;
    //             AbandonmentLineItems.add(WOLI);
                
    //             WorkORderLineITem WOLI2 = new WorkOrderLineItem();
    //             WOLI2.subject = '2. Take two pictures of living room from different angles';
    //             WOLI2.status = 'New';
    //             WOLI2.WorkOrderId = taskWorkOrderMap.get(t.whatId + t.Subject).id;
    //             AbandonmentLineItems.add(WOLI2);
                
    //             WorkORderLineITem WOLI3 = new WorkOrderLineItem();
    //             WOLI3.subject = '3. Take two pictures of each bedroom from different angles';
    //             WOLI3.status = 'New';
    //             WOLI3.WorkOrderId = taskWorkOrderMap.get(t.whatId + t.Subject).id;
    //             AbandonmentLineItems.add(WOLI3);
    //         }
    //     }
        
    //     insert AbandonmentLineItems;
                
        
    // }
    
    // public static void UpdateWorkOrders(List<Task> tasks, map<id, task> tasksOldMap){
        
    //     set<Id> HomeIds = new set<Id>();
    //     for(Task t: Tasks){
    //         if(t.Home__c != NULL)
    //             HomeIds.add(t.Home__c);
    //     }
        
    //     Map<ID, home__c> homeMap = new Map<ID, home__c>([SELECT Id, service_Territory__c,service_Territory__r.IsActive FROM Home__c WHERE Id IN :HomeIds]);
    //     Map<ID, workType> workTypeMap = new Map<ID, WorkType>([SELECT Id, Earliest_Start_Date_Window__c, Due_Date_Window__c FROM WorkType]);
        
    //     List<WorkOrder> UpdateWOs = new List<WorkOrder>();
    //     List<ServiceAppointment> UpdateSAs = new List<ServiceAppointment>();
        
    //     List<ID> workOrderIDs = new List<Id>();
    //     for(task t : tasks){
    //         workOrderIDs.add(t.work_order__c);
    //     }
    //     Map<id, List<ServiceAppointment>> workOrderIDToSAs = new Map<Id, List<ServiceAppointment>>();
    //     Map<id, WorkOrder> workOrdersMap = new Map<ID, WorkOrder>([SELECT id, workTypeId, (SELECT id, worktypeid, status FROM ServiceAppointments order by createdDate) FROM WorkOrder where id in: WorkOrderIDs]);
    //     For(WorkOrder WO :WorkOrdersMap.values()){
    //         workOrderIDToSAs.put(WO.Id,WO.ServiceAppointments);
    //     }
        
        
    //     for(Task t: Tasks){
    //         WorkOrder wo = new WorkOrder();
            
    //         wo.Id = t.Work_Order__c;
    //         if(t.Home__c != NULL && t.home__r.service_Territory__r.IsActive == true)
    //             wo.ServiceTerritoryId = homeMap.get(t.Home__c).service_territory__c;
    //         wo.Home__c = t.home__c;
    //         wo.suite__c = t.Suite__c;
    //         wo.Room__c = t.Room__c;
    //         String taskWhatID = t.WhatId;
    //         if (taskWhatID.startsWith('006'))
    //             wo.opportunity__c = t.whatid;
    //         UpdateWOs.add(wo);
    //         for(serviceAppointment sa: workOrdersMap.get(t.Work_Order__c).serviceAppointments){
    //             WorkType wt = workTypeMap.get(sa.workTypeID);
    //             sa.EarliestStartTime = datetime.newInstance(t.ActivityDate.addDays(Integer.valueOf(-wt.Earliest_Start_Date_Window__c)), Time.newInstance(09, 00, 00, 00));
    //             sa.DueDate = datetime.newInstance(t.ActivityDate.addDays(Integer.valueOf(wt.Due_Date_Window__c)), Time.newInstance(18, 00, 00, 00));
                
    //             if(t.ActivityDate != tasksOldMap.get(t.id).ActivityDate){
    //                 sa.SchedStartTime = null;
    //                 sa.SchedEndTime = null;
    //                 sa.Status = 'New';
    //             }
                
    //             UpdateSAs.add(SA);
    //         }
    //     }
    //     update UpdateWOs;
    //     update UpdateSAs;
        
    //     //sa.EarliestStartTime = datetime.newInstance(t.ActivityDate.addDays(Integer.valueOf(-wt.Earliest_Start_Date_Window__c)), Time.newInstance(09, 00, 00, 00));
    //     //sa.DueDate = datetime.newInstance(t.ActivityDate.addDays(Integer.valueOf(wt.Due_Date_Window__c)), Time.newInstance(18, 00, 00, 00));
    // }
    
}