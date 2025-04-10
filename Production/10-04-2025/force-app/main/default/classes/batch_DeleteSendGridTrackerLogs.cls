global class batch_DeleteSendGridTrackerLogs implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC){
        integer i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        String query = 'select id,createddate from SendGrid_Email_Tracker__c where createddate != LAST_N_DAYS:30 order by createddate asc';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SendGrid_Email_Tracker__c> scope){
        delete scope;
        Database.emptyRecycleBin(scope);
    }  
    
    global void finish(Database.BatchableContext BC)
    {
    }
  
}