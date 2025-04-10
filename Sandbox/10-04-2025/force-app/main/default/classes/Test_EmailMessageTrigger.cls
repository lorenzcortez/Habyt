@isTest
private class Test_EmailMessageTrigger{

    static testMethod void myUnitTest() {
        //Insert test case record
        Case c = new Case();
        c.Subject = 'Om Test';  
        c.Status ='New';
        c.Priority = 'Medium';
        c.Origin = 'Email';
        insert c;

        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = c.Id; 
        insert email;
        
        Recordtype rt = [Select id,Name from RecordType where SobjectType = 'Case' and Name = 'CSS - Member Support Specialists'];
        
        Case c2 = new Case();
        c2.Subject = 'Om Test';  
        c2.Status ='New';
        c2.Priority = 'Medium';
        c2.Origin = 'Email';
        c2.recordTypeID = rt.id;
        insert c2;
        
        //Insert emailmessage for case
        EmailMessage email2 = new EmailMessage();
        email2.FromAddress = 'test@abc.org';
        email2.Incoming = false;
        email2.ToAddress= 'test@xyz.org';
        email2.Subject = 'Test email';
        email2.HtmlBody = 'Test email body';
        email2.ParentId = c2.Id; 
        insert email2;
        
        Case c3 = new Case();
        c3.Subject = 'Om Test';  
        c3.Status ='Solved';
        c3.Priority = 'Medium';
        c3.Origin = 'Email';
        c3.recordTypeID = rt.id;
        insert c3;
        
        EmailMessage email3 = new EmailMessage();
        email3.FromAddress = 'test@abc.org';
        email3.Incoming = true;
        email3.ToAddress= 'test@xyz.org';
        email3.Subject = 'Test email';
        email3.HtmlBody = 'Test email body';
        email3.ParentId = c3.Id; 
        insert email3;
     }
}