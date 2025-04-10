public class SendGrid_CreateSendGridActivity implements Queueable {
    
    
    private Messaging.InboundEmail email; 
    private Messaging.InboundEnvelope envelope;
    private integer counter;
    
    public SendGrid_CreateSendGridActivity(Messaging.InboundEmail emailp, Messaging.InboundEnvelope envelopep, integer counter) {
        this.email = emailp;
        this.envelope = envelopep;
        this.counter = counter;
       
    }
    
    public void execute(QueueableContext context) {
        
        
        system.debug('ccAddresses::'+email.ccAddresses);
        system.debug('fromAddress::'+email.fromAddress);
        system.debug('subject::'+email.subject);
        //system.debug('htmlBody::'+email.htmlBody.length());
        //system.debug('headers::'+email.headers);
        system.debug('toAddresses::'+email.toAddresses);
        //system.debug('plainTextBody::'+email.plainTextBody.length());
        
        
        map<string, Account> AccountMap = new map<string, Account>();
        list<Account> Accs = [Select Id, Name, PersonEmail , OwnerId, PersonContactId
                              FROM Account
                              WHERE PersonEmail IN :email.toAddresses];
        for(Account acc : Accs){
            AccountMap.put(acc.PersonEmail, acc);
        }
        
        map<string, Contact> ContactMap = new map<string, Contact>();
        list<Contact> Conts = [Select Id, Email , OwnerId
                               FROM Contact
                               WHERE Email IN :email.toAddresses AND IsPersonAccount = false];
        for(Contact con : Conts){
            ContactMap.put(con.Email, con);
        }
        
        list<EmailMessage> EmailActivities = new list<EmailMessage>();
        system.debug(ContactMap.get(email.toAddresses[0]));
        if(AccountMap.get(email.toAddresses[0]) != null){
            
            //list<Task> TasksToCreate = new list<Task>();
            EmailMessage EmailActivity = new EmailMessage();
            EmailActivity.Subject                = email.subject;
            EmailActivity.Status                 = '3';
            EmailActivity.ToAddress              = email.toAddresses[0];
            EmailActivity.FromAddress            = email.fromAddress;
            EmailActivity.FromName               = email.fromName;
            //if(email.HtmlBody != null && email.HtmlBody.length() < 32000)
            EmailActivity.HtmlBody               = email.HtmlBody;
            //else
            //EmailActivity.TextBody               = email.plainTextBody;
            
            EmailActivity.Incoming               = false;
            EmailActivity.MessageDate            = DateTime.now();
            EmailActivity.RelatedToId            = AccountMap.get(email.toAddresses[0]).Id;
            EmailActivities.add(EmailActivity);
        }
        else if(ContactMap.get(email.toAddresses[0]) != null){
            
            //list<Task> TasksToCreate = new list<Task>();
            EmailMessage EmailActivity = new EmailMessage();
            EmailActivity.Subject                = email.subject;
            EmailActivity.Status                 = '3';
            EmailActivity.ToAddress              = email.toAddresses[0];
            EmailActivity.FromAddress            = email.fromAddress;
            EmailActivity.FromName               = email.fromName;
            //if(email.HtmlBody != null && email.HtmlBody.length() < 32000)
            EmailActivity.HtmlBody               = email.HtmlBody;
            //else
            //EmailActivity.TextBody               = email.plainTextBody;
            
            EmailActivity.Incoming               = false;
            EmailActivity.MessageDate            = DateTime.now();
            //EmailActivity.RelatedToId            = ContactMap.get(email.toAddresses[0]).Id;
            if(ContactMap.get(email.toAddresses[0]) != null){
                String[] toIds = new String[]{ContactMap.get(email.toAddresses[0]).Id};
                    EmailActivity.toIds = toIds;
            }
            EmailActivities.add(EmailActivity);
        }
        
        list<EmailMessageRelation> EmailMessageRelations = new list<EmailMessageRelation>();
        
        if(EmailActivities.size() > 0){
            try{
                insert EmailActivities;
                
                for(EmailMessage em : EmailActivities){
                    if(em.Id != null){
                        if(ContactMap.get(email.toAddresses[0]) != null){
                            EmailMessageRelation emr = new EmailMessageRelation();
                            emr.EmailMessageId = em.Id;
                            emr.RelationAddress = em.ToAddress;
                            emr.RelationId = ContactMap.get(email.toAddresses[0]).Id;
                            emr.RelationType = 'ToAddress';
                            EmailMessageRelations.add(emr);
                        }
                    }
                }
                
                if(EmailMessageRelations.size() > 0)
                    insert EmailMessageRelations;
                
                if(email.binaryAttachments != null){
                    List<ContentVersion> cvList = new List<ContentVersion>();
                    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                    
                    for (Messaging.InboundEmail.BinaryAttachment binAttach : email.binaryAttachments) {
                        ContentVersion testContentInsert = new ContentVersion();
                        testContentInsert.Title = binAttach.fileName;
                        testContentInsert.VersionData = binAttach.body;
                        testContentInsert.PathOnClient = '/' + binAttach.fileName ;
                        cvList.add(testContentInsert);
                        
                    }
                    insert cvList;
                    cvList = [select id, ContentDocumentId from ContentVersion WHERE Id in :cvList];
                    for (ContentVersion cv : cvList) {
                        for(EmailMessage em : EmailActivities){
                            ContentDocumentLink cl = new ContentDocumentLink();
                            cl.ContentDocumentId = cv.ContentDocumentId;
                            cl.LinkedEntityId = em.Id; //Shared with record ID
                            cl.ShareType = 'V';
                            cl.Visibility = 'AllUsers';
                            cdlList.add(cl);
                        }
                    }
                    insert cdlList; 
                }
            }
            catch(exception ex){
                
                if(ex.getMessage().Contains('UNABLE_TO_LOCK_ROW') && counter <= 3){
                    
                    if(AccountMap.get(email.toAddresses[0]) != null){
                    Email_Error__c er = new Email_Error__c();
                    
                    if(AccountMap.get(email.toAddresses[0]).PersonContactID != null)
                            er.Record_ID__c = AccountMap.get(email.toAddresses[0]).PersonContactID;
                        er.Status_Code__c = 'SendGrid Email log Error From Email Service';
                        er.Error_Message__c = 'Error: '+ex.getMessage()+'\n';
                        er.Error_Message__c += 'Subject: '+email.subject+'\n';
                        er.Error_Message__c += 'To Email: '+email.toAddresses+'\n';
                        insert er;
                    }
                    else if(ContactMap.get(email.toAddresses[0]) != null){
                        Email_Error__c er = new Email_Error__c();
                        if(ContactMap.get(email.toAddresses[0]).Id != null)
                            er.Record_ID__c = ContactMap.get(email.toAddresses[0]).Id;
                        er.Status_Code__c = 'SendGrid Email log Error From Email Service';
                        er.Error_Message__c = 'Error: '+ex.getMessage()+'\n';
                        er.Error_Message__c += 'Subject: '+email.subject+'\n';
                        er.Error_Message__c += 'To Email: '+email.toAddresses+'\n';
                        insert er;
                    }
                    
                    SendGrid_CreateSendGridActivity updateJob = new SendGrid_CreateSendGridActivity(email, envelope,counter++);
                    System.enqueueJob(updateJob);
                }
                
            }
        }
        
    }
    
}