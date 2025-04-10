global class BatchDeleteAllTasks implements Database.Batchable<SObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query all tasks
        String query = 'SELECT Id FROM Task';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        try {
            // Cast the list to a list of Task records and delete them
            List<Task> tasksToDelete = (List<Task>) scope;
            delete tasksToDelete;
        } catch (Exception e) {
            // Handle any exceptions that occur during the batch execution
            System.debug('Error occurred during task deletion: ' + e.getMessage());
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Optionally send an email notification or perform any final operations
        System.debug('Batch job finished: All tasks have been deleted.');
    }
}