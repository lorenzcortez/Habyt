global class UpdateMITPriortyBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, StartDate, (SELECT Id FROM Move_In_Trackers__r ORDER BY CreatedDate DESC LIMIT 1 ) FROM Contract WHERE StartDate < TODAY';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Contract> scope){
        System.debug('scope' + scope);
        List<String> moveInTrackerIds = new List<String>();
        for( Contract contract : scope ){
            if( contract.Move_In_Trackers__r.size() > 0 ){
                moveInTrackerIds.add(contract.Move_In_Trackers__r[0].Id);
            }
        }

        System.debug('moveInTrackerIds' + moveInTrackerIds);
        List<Task> moveInTrackerTasks = [SELECT Id FROM Task WHERE Status != 'Completed' AND Move_In_Tracker__c IN :moveInTrackerIds];
        System.debug('moveInTrackerTasks' + moveInTrackerTasks);
        if( moveInTrackerTasks.size() > 0 ){
            for(Task moveInTrackerTask : moveInTrackerTasks){
                moveInTrackerTask.Priority = 'High';
            }
            update moveInTrackerTasks;
        }
    }  

    global void finish(Database.BatchableContext bc){
    	System.debug('Finish');
    }   
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new UpdateMITPriortyBatch());
    }
}