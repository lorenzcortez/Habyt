public class Scheduled_DeleteSendGridTrackerLogs implements Schedulable {
   
   public void execute(SchedulableContext SC) {
       Batch_DeleteSendGridTrackerLogs b = new Batch_DeleteSendGridTrackerLogs();
       database.executebatch(b,1000);  
   }
}