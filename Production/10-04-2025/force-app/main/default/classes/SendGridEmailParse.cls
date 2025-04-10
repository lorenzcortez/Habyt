global class SendGridEmailParse implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope) {

        SendGrid_CreateSendGridActivity updateJob = new SendGrid_CreateSendGridActivity(email, envelope,0);
        System.enqueueJob(updateJob);
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        result.success = true;
        return result;
    }
    
    
}