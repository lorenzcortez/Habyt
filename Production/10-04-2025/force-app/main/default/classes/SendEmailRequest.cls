global class SendEmailRequest {

    @InvocableVariable(required=true)
    global String toEmail;
    
    @InvocableVariable(description='comma separated emails')
    global String ccEmails;
    
    @InvocableVariable(description='comma separated emails')
    global String bccEmails;
    
    @InvocableVariable(required=true)
    global String TemplateId;
    
    @InvocableVariable(required=true)
    global String dynamicContent;
    
    @InvocableVariable(required=true)
    global String FromName;
    
    @InvocableVariable(required=true)
    global String FromEmail;
    
    @InvocableVariable
    global String ReplyToName;
    
    @InvocableVariable
    global String ReplyToEmail;
    
    @InvocableVariable(required=true)
    global String RecordId;
    
    @InvocableVariable
    global String SFUserID;
    
    @InvocableVariable
    global Boolean SendEarliest;
    
    @InvocableVariable
    global String EmailAttachmentId;
    
}