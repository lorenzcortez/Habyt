global class CreateMoveOutTasksforOpp_Invocable{
    
    @InvocableMethod(label='Create Move Out tasks for Opportunities' description='This function takes the opportunity Id and creates move out tasks related to its previous opportunity, if they do not exist.')
    public static void execute(list<Request> Requests) {
        
        set<Id> OppIds = new set<Id>();
        for(Request req : Requests){
            if(req.Opportunities != NULL){
                for(Opportunity opp : req.Opportunities){
                    OppIds.add(opp.Id);
                }
            }
        }
        
        if(OppIds.size() > 0){
            CreateMemberMoveOutTasks_Batch cls = new CreateMemberMoveOutTasks_Batch(OppIds);
            database.executeBatch(cls, 3);
        }
        
    }
    
    global class Request{
        @InvocableVariable(required=true description='Opportunities')
        global list<Opportunity> Opportunities;
    }
}