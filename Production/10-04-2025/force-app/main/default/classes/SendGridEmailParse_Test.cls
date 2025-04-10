@IsTest
public class SendGridEmailParse_Test {
    
    public static testmethod void TestEmailParse(){
        
        // setup controller object
        SendGridEmailParse cls = new SendGridEmailParse();
        
        Id PersonAccounRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        Account acc1= new Account();
        acc1.LastName ='Test';
        acc1.RecordTypeId = PersonAccounRecTypeId;
        acc1.PersonEmail = 'example@test.com';
        insert acc1;
        
        
        Contact cont = new Contact();
        cont.LastName = 'Test Contact';
        cont.Email = 'example2@test.com';
        insert cont;
        
        
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        //cls.handleInboundEmail(email, envelope);
        
        //email.subject = 'Test Subject';
        //email.HtmlBody = 'Hello, this a test email body. for testing purposes only. Bye';
        envelope.fromAddress = 'test@common.com';
        
        list<string> ToAdds = new list<string>();
        ToAdds.add(acc1.PersonEmail);
        email.toAddresses = ToAdds;
        
        cls.handleInboundEmail(email, envelope);
        
        Messaging.InboundEmailResult result = cls.handleInboundEmail(email, envelope);
        
        email.subject = 'Test Subject';
        email.HtmlBody = 'Hello, this a test email body. for testing purposes only. Bye';
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
        // add an Text atatchment
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
            
            
        cls.handleInboundEmail(email, envelope);
        
        
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email2 = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope2 = new Messaging.InboundEnvelope();
        
        envelope2.fromAddress = 'test@common.com';
        
        list<string> ToAdds2 = new list<string>();
        ToAdds2.add(cont.Email);
        email2.toAddresses = ToAdds2;
        
        cls.handleInboundEmail(email2, envelope2);
        
        Messaging.InboundEmailResult result2 = cls.handleInboundEmail(email2, envelope2);
        
        email2.subject = 'Test Subject';
        email2.HtmlBody = 'Hello, this a test email body. for testing purposes only. Bye';
        cls.handleInboundEmail(email2, envelope2);
        
    }
}