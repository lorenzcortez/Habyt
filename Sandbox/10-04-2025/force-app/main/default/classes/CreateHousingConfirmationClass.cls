public class CreateHousingConfirmationClass {

    public static final String CONFIRMATION_CONTRACT_NAME_DEFAULT = 'Wohnungsbestätigung';
    public static final String PDF_EXTENSION_NAME = '.pdf';
    public static final String CONFIRMATION_EMAIL_TEMPLATE_NAME = 'HousingConfirmation';

    public static void sendEmail(Contract c) {

        ContentVersion cv = createContentVersion(c);
        insert cv;

        EmailService emailService = new EmailService();
        Map<String, OrgWideEmailAddress> addresses = emailService.getOrgWideAddressesByAddress(new Set<String>{'support@%'});

        String emailTemplateName = CONFIRMATION_EMAIL_TEMPLATE_NAME + '_' + c.API_Name_Brand__c;
        System.debug('emailTemplateName '+emailTemplateName);
        List<EmailTemplate> emailTemplate = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name =: emailTemplateName LIMIT 1];
		System.debug('emailTemplate '+emailTemplate);
        if(emailTemplate != null) {
            System.debug(' **** Enter emailTemplate not null');
            List<Messaging.RenderEmailTemplateBodyResult> renderEmail = Messaging.renderEmailTemplate(c.Account.PersonContactId, c.Id, new List<String> {emailTemplate[0].HtmlValue});
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            email.setTargetObjectId(c.Account.PersonContactId);
            email.setWhatId(c.Id);
            email.saveAsActivity = true;
            email.sethtmlBody(renderEmail[0].getMergedBody());
            //email.setTemplateId(emailTemplate[0].Id);
            //email.sethtmlBody(emailTemplate[0].HtmlValue);
            email.setsubject(emailTemplate[0].Subject);
            email.setToAddresses(new List<String> {c.Account.PersonEmail});
            //email.setorgWideEmailAddressId(addresses.containsKey(expectedSender) ? addresses.get(expectedSender).Id : null);
            System.debug(' ****** ');
			System.debug('email.orgWideEmailAddressId '+email.orgWideEmailAddressId);
            if(cv != null) {
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(cv.Title);
                attachment.setBody(cv.VersionData);
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
            }
            System.debug('email '+email);
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }

    public static ContentVersion createContentVersion(Contract c) {
        PageReference housingConfirmationPdf = Page.HousingConfirmationPdf;
        housingConfirmationPdf.getParameters().put('id', c.Id);

        String fileName = CONFIRMATION_CONTRACT_NAME_DEFAULT + ' ' + c.Account.Name + PDF_EXTENSION_NAME;
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';
        contentVersion.Title = fileName;
        contentVersion.PathOnClient = fileName;
        contentVersion.VersionData = Test.isRunningTest() ? Blob.valueOf('TestContract') : housingConfirmationPdf.getContent();
        contentVersion.FirstPublishLocationId = c.Id;
        return contentVersion;
    }
}