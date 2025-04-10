@IsTest
public class EmailService_Test {
    @TestSetup
    static void setupTests(){
        EmailTemplate emailTemplate = new EmailTemplate(
            DeveloperName = 'Habyt_MoveIn', 
            FolderId = UserInfo.getUserId(), 
            TemplateType='Text', 
            Name = 'Habyt_MoveIn'
        );

        insert emailTemplate;
    }
    
    @IsTest
    static void sendEmails_Test() {
        List<EmailService.EmailServiceParameterWrapper> emailObjects = new List<EmailService.EmailServiceParameterWrapper>();
        EmailService emailService = new EmailService();
        Integer expected = 1;
        EmailTemplate template = [SELECT Id FROM EmailTemplate LIMIT 1];

        EmailService.EmailServiceParameterWrapper wrapper = new EmailService.EmailServiceParameterWrapper();

        wrapper.targetObjectId = UserInfo.getUserId();
        wrapper.displayName = 'Test Name';
        wrapper.useSignature = false;
        wrapper.bcc = true;
        wrapper.saveAsActivity = false;
        wrapper.templateId = template.Id;
        wrapper.toAddresses = new List<String> {'test@email.com'};

        emailObjects.add(wrapper);

        Test.startTest();
        emailService.sendEmails(emailObjects, false);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(expected, invocations, 'Number of emails unexpected');
    }
}