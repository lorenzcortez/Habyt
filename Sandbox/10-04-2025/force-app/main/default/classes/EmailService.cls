public class EmailService {

    /**
     * This method sends email with a specified data in EmailServiceParameterWrapper. EmailServiceParameterWrapper class
     * makes it easier to pass the data to the EmailService. This method is primarily used as wrapper for 
     * Messaging.sendEmail(messages, allOrNone).
     * 
     * @param emailObjects  List of email parameter wrappers. From this list, the emails that need to be sent are extracted
     * @param allOrNone     Specifies whether sendEmail prevents delivery of all other messages when any of the 
     *                      messages fail due to an error.
     */
    public void sendEmails(List<EmailServiceParameterWrapper> emailObjects, Boolean allOrNone) {
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();

        for(EmailServiceParameterWrapper emailObject : emailObjects) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

            if(emailObject.orgWideEmailAddressId != null) {
                message.setOrgWideEmailAddressId(emailObject.orgWideEmailAddressId);
            }

            if(emailObject.displayName != null) {
                message.setSenderDisplayName(emailObject.displayName);
            }

            // Check if its a static email or if it uses a template
            if (String.isNotBlank(emailObject.htmlBody)) {
                message.setSubject(emailObject.subject);
                message.setHtmlBody(emailObject.htmlBody);
            } else {
                message.setUseSignature(emailObject.useSignature);
                message.setBccSender(emailObject.bcc);
                message.setTemplateID(emailObject.templateId); 
                message.setTargetObjectId(emailObject.targetObjectId);
            }
            message.setSaveAsActivity(emailObject.saveAsActivity);
            message.setWhatId(emailObject.whatId);
            message.toAddresses = emailObject.toAddresses;
            if(emailObject.emailFileAttachments != null) {
                message.setFileAttachments(createFileAttachments(emailObject.emailFileAttachments));
            }

            messages.add(message);
        }

        try{
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages, allOrNone);
        } catch (Exception e) {
            System.debug('+++ Emails have not been sent due to an error: ' + e.getMessage());
            throw new HandledException('Emails have not been sent due to an error. Please try again later or contact your Salesforce admin if the problem persists.');
        }
    }

    public Map<String, OrgWideEmailAddress> getOrgWideAddressesByAddress(Set<String> addresses) {
        Map<String, OrgWideEmailAddress> addreses = new Map<String, OrgWideEmailAddress>();
        for (OrgWideEmailAddress address: (List<OrgWideEmailAddress>) Paua_SelectorHandler.getSelector(EmailTemplateSelectors.OrgWideAddressesByAddress.class)
            .setParameter('addresses', addresses)
            .query()
        ) {
            addreses.put(address.Address, address);
        }
        return addreses;
    }

    private List<Messaging.EmailFileAttachment> createFileAttachments(List<EmailFileAttachmentWrapper> emailFileAttachments) {
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();

        for(EmailFileAttachmentWrapper wrapper : emailFileAttachments) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();

            attachment.setFileName(wrapper.fileName);
            attachment.setBody(wrapper.body);

            attachments.add(attachment);
        }

        return attachments;
	} 

    public class EmailServiceParameterWrapper {
        public Id targetObjectId {get; set;}
        public Id templateId {get; set;}
        public Id whatId {get; set;}
        public Id orgWideEmailAddressId {get; set;}

        public String displayName {get; set;}
        public String subject {get; set;}
        public String htmlBody {get; set;}
        public String sender {get; set;}

        public Boolean useSignature {get; set;}
        public Boolean bcc {get; set;}
        public Boolean saveAsActivity {get; set;}
        
        public List<String> toAddresses {get; set;}
        public List<EmailFileAttachmentWrapper> emailFileAttachments {get; set;}
    }

    public class EmailFileAttachmentWrapper {
        public String fileName {get; set;}
        public Blob body {get; set;}
    }
}