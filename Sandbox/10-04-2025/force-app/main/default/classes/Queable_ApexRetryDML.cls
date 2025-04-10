public class Queable_ApexRetryDML implements Queueable {
    
    private List<SObject> failedSObjects; 
    
    public Queable_ApexRetryDML(List<SObject> failedSObjects) {
        this.failedSObjects = failedSObjects;
    }

    public void execute(QueueableContext context) {
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { 'development@einsteam.com'};
        message.subject = 'Common - Unable to Row Lock Error From Retry Process';
        message.plainTextBody = 'While performing DML, apex threw Unable to Row Lock Error';
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.sendEmail(messages);
        
        if (failedSObjects != null && !failedSObjects.isEmpty()) {
            try{
                upsert failedSObjects;
            }
            catch(Exception ex){
                if(ex.GetMessage().Contains('UNABLE_TO_LOCK_ROW')){
                    Queable_ApexRetryDML updateJob = new Queable_ApexRetryDML(failedSObjects);
                    System.enqueueJob(updateJob);
                }
            }
            
        }
    }
    
}