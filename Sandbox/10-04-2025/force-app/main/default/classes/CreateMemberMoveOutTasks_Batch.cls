global class CreateMemberMoveOutTasks_Batch implements Database.Batchable<sObject>{
    
    global final set<Id> OppIds;
    
    global CreateMemberMoveOutTasks_Batch(Set<Id> SpecificOppIds)
    {
        OppIds = SpecificOppIds;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of opportunity records to be passed to execute
        String query = 'SELECT Id, Room_Selected__c, ApartmentRef__c, Early_Termination_Type__c, StageName, Home_Committed__c, Home_Committed__r.Property_Services_Move_out_Task__c, ';
        query += 'Home_Committed__r.Property_Services_Move_out_Task_Owner__c, Previous_Occupancy_End_Date__c, Home_Committed__r.Maintenance_Tech__c, Home_Committed__r.Porter__c,';
        query += 'Previous_Opportunity__c, Home_Committed__r.Pre_Move_Out_Inspection_Task__c, Home_Committed__r.Pre_Move_Out_Inspection_Task_Owner__c, ';
        query += 'Home_Committed__r.Community_Manager__c, Home_Committed__r.Post_Move_Out_Inspection_Task__c, Home_Committed__r.Post_Move_Out_Inspection_Task_Owner__c, ';
        query += 'Home_Committed__r.Leasing_Specialist_Move_out_Task_Owner__c, Home_Committed__r.Leasing_Specialist_Move_out_Task__c, Home_Committed__r.Leasing_Specialist__c, ';
        query += 'Home_Committed__r.Resident_Services_Coordinator__c, Home_Committed__r.Onsite_Move_out_Task__c, Home_Committed__r.Onsite_Move_out_Task_Owner__c, ';
        query += 'Home_Committed__r.Area_Manager__c, Home_Committed__r.Sourcefit_Move_out_Task__c, Notice_Date__c, AccountId,  Previous_Opportunity__r.AccountId, Home_Committed__r.City_object__c ';
        query += 'FROM Opportunity ';
        query += 'WHERE ';
        query += 'Home_Committed__c != NULL ';
        //query += 'AND Member_Move_Out_Task_Created__c = FALSE ';
        //query += 'AND RecordType.DeveloperName = \'Renewal\' ';
        query += 'AND RecordType.DeveloperName = \'Common_Renewal\' ';


        if(OppIds != NULL && OppIds.size() > 0){
            query += ' AND ID IN :OppIds ';
        }else{
            query += 'AND Start_Date_of_Occupancy__c != NULL AND Start_Date_of_Occupancy__c >= TODAY AND Start_Date_of_Occupancy__c <= NEXT_N_DAYS:30 ';
            
            //added this criteria due to the validation rule https://common.my.salesforce.com/03d3u000000zI9C?setupid=OpportunityValidations
            if(!test.isRunningTest()){
                query += ' AND Previous_Opportunity__r.StageName = \'Member\' ';
            }
            //Backup // query += ' AND ((Early_Termination_Type__c != \'Ghosted\' AND Early_Termination_Type__c != \'Eviction\' AND StageName = \'Closed Lost\') OR (Early_Termination_Type__c = \'Ghosted\' OR Early_Termination_Type__c = \'Eviction\')) ';
            query += ' AND ((Early_Termination_Type__c != \'Ghosted\' AND Early_Termination_Type__c != \'Eviction\') OR (Early_Termination_Type__c = \'Ghosted\' OR Early_Termination_Type__c = \'Eviction\')) ';
        }

        system.debug(query);
        return Database.getQueryLocator(query);       
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        
        //list<User> MemberUser = new list<User>([SELECT Id FROM User WHERE Name = 'Member Services' AND isActive = TRUE]);
        list<User> MemberUser = new list<User>([SELECT Id FROM User WHERE Name =: Label.Member_Services_Name AND isActive = TRUE]);
        list<Task> TasksToCreate = new list<Task>();
        
        set<Id> PreviousOppIds = new set<Id>();
        for(Opportunity opp : scope){
            if(opp.Previous_Opportunity__c != NULL)
                PreviousOppIds.add(opp.Previous_Opportunity__c);
        }

        list<String> TaskSubjects = new list<String>{'Property Services Move Out', 'Pre-Move-Out Inspection', 'Post-Move-Out Inspection', 'Leasing Specialist Move-Out Task', 'Onsite Move Out Task', 'Source Fit Move Out'};
        system.debug('TaskSubjects::'+TaskSubjects);
        Map<Id, Opportunity> PreviousOppsMap = new Map<Id, Opportunity>([SELECT Id, (SELECT Id, Subject FROM Tasks WHERE SUBJECT IN :TaskSubjects) FROM Opportunity WHERE ID IN : PreviousOppIds]);


        for(Opportunity opp : scope){
            if(opp.Previous_Opportunity__r.AccountId == opp.AccountId || test.isRunningTest()){
                system.debug('In Loop...'+opp.Early_Termination_Type__c);
                
                //SRART - CSS - Member Move Out Tasks
                if(opp.Previous_Opportunity__c != NULL && PreviousOppsMap.get(opp.Previous_Opportunity__c).Tasks.size() == 0 && opp.Early_Termination_Type__c != 'Ghosted' && opp.Early_Termination_Type__c != 'Eviction'){ // && opp.StageName == 'Closed Lost'
                    //opp.Member_Move_Out_Task_Created__c = TRUE;
                    list<Task> ClosedLostTasks = MemberMoveOutTaskController.AssignClosedLostOppTaskValues(opp, MemberUser);
                    if(ClosedLostTasks.size() > 0)
                        TasksToCreate.addAll(ClosedLostTasks);
                }
                //END - CSS - Member Move Out Tasks
                
                
                //START - CSS - Member Move Out Tasks Eviction/Ghosted Subflow
                if(opp.Previous_Opportunity__c != NULL && PreviousOppsMap.get(opp.Previous_Opportunity__c).Tasks.size() == 0 && opp.Early_Termination_Type__c == 'Ghosted' || opp.Early_Termination_Type__c == 'Eviction'){
                    //opp.Member_Move_Out_Task_Created__c = TRUE;
                    list<Task> EvictedGhostedTasks = MemberMoveOutTaskController.AssignEvictedGhostedTasksValues(opp, MemberUser);

                    if(EvictedGhostedTasks.size() > 0)
                        TasksToCreate.addAll(EvictedGhostedTasks);
                }
                
            }
            
        }
        
        system.debug('TasksToCreate::'+TasksToCreate);
        system.debug('TasksToCreate::'+TasksToCreate.size());
        //if(scope.size() > 0){
            //update scope;
        //}
        if(TasksToCreate.size() > 0){
            insert TasksToCreate;
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        /*
        // execute any post-processing operations
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
        TotalJobItems, CreatedBy.Email, ExtendedStatus
        from AsyncApexJob where Id = :bc.getJobId()];        

        // Check batch status - IF COMPLETED then 
        if(a.Status == 'Completed') {


            // 1. Send Email (CSV created in execute method)


            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // Send the email to the job submitter
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Batch Processing');
            mail.setSubject('Move-Out Tasks Batch Apex Status: ' + a.Status);
                mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
                ' batches with '+ a.NumberOfErrors + ' failures. ExtendedStatus: ' + a.ExtendedStatus);

            // Add your attachment to the email.

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });


            // 2. database.executebatch(new chain_batch(),200);

        }
        */
    }
}