global class CreateTransferMoveOutTasks_Batch implements Database.Batchable<sObject>, schedulable{
    
    global void execute(SchedulableContext SC) {
        database.executebatch(new CreateTransferMoveOutTasks_Batch(), 3);
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
    
        /*****
        #1 - if the opp churned is a "renewal in progress" or "transfer in progress", then  link move out tasks to the previous "member" opp (as it does today, but will need to add filter for stage of the opp churned)
        #2 - add logic so that if the opportunity that is churned is a "member", then the tasks link to that same "member" opp and NOT the previous opp
        *****/
        list<Opportunity> opps = [SELECT Id, StageName, previous_Opportunity__c
                                  FROM Opportunity 
                                  WHERE 
                                  (recordType.Name = 'Common - Transfer' OR transfer_Upon_renewal__c = 'Yes') 
                                  AND ((stageName = 'Member' AND Transfer_move_out_Tasks_created__c = false) OR ((stageName = 'Transfer In Progress' OR stageName = 'Renewal In Progress') AND previous_opportunity__r.Transfer_move_out_Tasks_created__c = false))
                                  AND ApartmentRef__c != null AND home_committed__c != null 
                                  AND start_date_of_occupancy__c >= today]; //AND TransferToSameRoom__c = false
        
        Set<Id> OppIds = new Set<Id>();
        Set<Id> PreviousOppIds = new Set<Id>();
        
        for(opportunity o : opps){
            if(o.stageName == 'Transfer In Progress' || o.stageName == 'Renewal In Progress'){
                PreviousOppIds.add(o.previous_Opportunity__c);
            }else if(o.stageName == 'Member'){
                OppIds.add(o.Id);
            }
        }
        
        // collect the batches of opportunity records to be passed to execute
        String query = 'SELECT id, city__c, ApartmentRef__c, StageName, home_committed__c, home_committed__r.Area_Manager__c, ';
        query += 'Home_Committed__r.Property_Services_Move_out_Task__c, ';
        query += 'Home_Committed__r.Property_Services_Move_out_Task_Owner__c, Previous_Occupancy_End_Date__c, Home_Committed__r.Maintenance_Tech__c, Home_Committed__r.Porter__c,';
        query += 'Home_Committed__r.City_object__c, Room_Selected__c, Previous_Opportunity__c, Home_Committed__r.Pre_Move_Out_Inspection_Task__c, Home_Committed__r.Pre_Move_Out_Inspection_Task_Owner__c, ';
        query += 'Home_Committed__r.Community_Manager__c, Home_Committed__r.Post_Move_Out_Inspection_Task__c, Home_Committed__r.Post_Move_Out_Inspection_Task_Owner__c, ';
        query += 'Home_Committed__r.Leasing_Specialist_Move_out_Task_Owner__c, Home_Committed__r.Leasing_Specialist_Move_out_Task__c, Home_Committed__r.Leasing_Specialist__c, ';
        query += 'Home_Committed__r.Resident_Services_Coordinator__c, Home_Committed__r.Onsite_Move_out_Task__c, Home_Committed__r.Onsite_Move_out_Task_Owner__c, ';
        query += 'Home_Committed__r.Sourcefit_Move_out_Task__c, Notice_Date__c, ';
        query += 'Transfer_move_out_Tasks_created__c, Home_Committed__r.City__c,';
        query += 'home_committed_Name_Formula__c, end_date_of_occupancy__c ';
        query += 'FROM Opportunity ';
        query += 'WHERE Id IN : PreviousOppIds OR Id IN : OppIds';

        system.debug(query);
        return Database.getQueryLocator(query);       
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        
        list<User> MemberUser = new list<User>([SELECT Id FROM User WHERE Name = 'Member Services' AND isActive = TRUE]);
        list<Task> TasksToCreate = new list<Task>();
        list<Opportunity> OppsToUpdate = new list<Opportunity>();

        for(Opportunity opp : scope){
            boolean TransferTaskCreated = false;
            if(opp.Home_Committed__r.Property_Services_Move_out_Task__c == 'Yes'){
                
                String PSMoveOutTaskOwner;
                if(opp.Home_Committed__r.Property_Services_Move_out_Task_Owner__c == 'Porter'){
                    PSMoveOutTaskOwner = opp.Home_Committed__r.Porter__c;
                }else {
                    PSMoveOutTaskOwner = opp.Home_Committed__r.Maintenance_Tech__c;
                }
                
                if(PSMoveOutTaskOwner != NULL){
                    Date ActivityDate;
                    if(opp.End_Date_of_Occupancy__c != NULL)
                        ActivityDate = opp.End_Date_of_Occupancy__c.addDays(1);
                    Task t = MemberMoveOutTaskController.InitiateNewTask('Property Services Move Out', ActivityDate, PSMoveOutTaskOwner, System.Label.PSMoveOutTaskOwner, opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Id);
                    TasksToCreate.add(t);
                    TransferTaskCreated = true;
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
                    if(opp.End_Date_of_Occupancy__c != NULL)
                        ActivityDate = opp.End_Date_of_Occupancy__c.addDays(-14);
    
                    Task t = MemberMoveOutTaskController.InitiateNewTask('Pre-Move-Out Inspection', ActivityDate, PreMoveOutInspectionOwner, System.Label.PreMoveOutInspectionOwner, opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Id);
                    TasksToCreate.add(t);
                    TransferTaskCreated = true;
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
                    if(opp.End_Date_of_Occupancy__c != NULL)
                        ActivityDate = opp.End_Date_of_Occupancy__c.addDays(1);
                    Task t = MemberMoveOutTaskController.InitiateNewTask('Post-Move-Out Inspection', ActivityDate, PostMoveOutInspectionOwner, System.Label.PostMoveOutInspectionOwner, opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Id);
                    TasksToCreate.add(t);
                    TransferTaskCreated = true;
                }
            }
            
            
            if(opp.Home_Committed__r.Leasing_Specialist_Move_out_Task__c == 'Yes'){
                String LSMoveOutTaskOwner;
                if(opp.Home_Committed__r.Leasing_Specialist_Move_out_Task_Owner__c == 'Leasing Specialist'){
                    LSMoveOutTaskOwner = opp.Home_Committed__r.Leasing_Specialist__c;
                }else if(opp.Home_Committed__r.Leasing_Specialist_Move_out_Task_Owner__c == 'Community Manager'){
                    LSMoveOutTaskOwner = opp.Home_Committed__r.Community_Manager__c;
                }else{
                    LSMoveOutTaskOwner = opp.Home_Committed__r.Resident_Services_Coordinator__c;
                }
                
                if(LSMoveOutTaskOwner != NULL){
                    Task t = MemberMoveOutTaskController.InitiateNewTask('Leasing Specialist Move Out Task', opp.End_Date_of_Occupancy__c, LSMoveOutTaskOwner, System.Label.LSMoveOutTaskOwner, opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Id);
                    TasksToCreate.add(t);
                    TransferTaskCreated = true;
                }
            }
            
            if(opp.Home_Committed__r.Onsite_Move_out_Task__c == 'Yes'){
                
                String OnsiteMoveOutTaskOwner;
                if(opp.Home_Committed__r.Onsite_Move_out_Task_Owner__c == 'Maintenance Tech'){
                    OnsiteMoveOutTaskOwner = opp.Home_Committed__r.Maintenance_Tech__c;
                }else {
                    OnsiteMoveOutTaskOwner = opp.Home_Committed__r.Area_Manager__c;
                }
                
                if(OnsiteMoveOutTaskOwner != NULL){
                    
                    Task t = MemberMoveOutTaskController.InitiateNewTask('Onsite Move Out Task', opp.End_Date_of_Occupancy__c, OnsiteMoveOutTaskOwner,  System.Label.OnsiteMoveOutTaskOwner, opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Id);
                    TasksToCreate.add(t);
                    TransferTaskCreated = true;
                }
            }
            
            if(opp.Home_Committed__r.Sourcefit_Move_out_Task__c == 'Yes' && MemberUser.size() > 0){
                
                Date ActivityDate;
                if(opp.End_Date_of_Occupancy__c != NULL)
                    ActivityDate = opp.End_Date_of_Occupancy__c.addDays(2);
    
                Task t = MemberMoveOutTaskController.InitiateNewTask('Source Fit Move Out TRANSFER', ActivityDate, MemberUser[0].Id, System.Label.SourceFitMoveOutTRANSFERTaskOwner, opp.Home_Committed__r.City_object__c, opp.Home_Committed__c, opp.Room_Selected__c, opp.ApartmentRef__c, opp.Id);
                TasksToCreate.add(t);
                TransferTaskCreated = true;
            }
            if(TransferTaskCreated){
                Opportunity o = new Opportunity(Id = opp.Id);
                o.Transfer_Move_Out_Tasks_Created__c = TRUE;
                OppsToUpdate.add(o);
            }
        }
        
        if(TasksToCreate.size() > 0){
            insert TasksToCreate;
        }
        if(OppsToUpdate.size() > 0){
            update OppsToUpdate;
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}