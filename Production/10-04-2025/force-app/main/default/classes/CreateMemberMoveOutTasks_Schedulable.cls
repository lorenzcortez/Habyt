global class CreateMemberMoveOutTasks_Schedulable implements Schedulable {
    
    global void execute(SchedulableContext sc)        
    {
        
        CreateMemberMoveOutTasks_Batch b = new CreateMemberMoveOutTasks_Batch(NULL);
        database.executeBatch(b, 3);
        
    }
    
}