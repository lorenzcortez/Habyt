public with sharing class LWC_MassEmailController {
    
    /**
     * getActiveTenants Fetch all tenants with active contracts related to an aparment or a property
     *
     * @param recordId (Id): The aparment or property Id
     * @return List<Contract>: All active tenants
     */
    @AuraEnabled (cacheable = true)
    public static List<Contract> getActiveTenants(Id recordId){
        List<Contract> lstActiveContracts = new List<Contract>();
        String parameterName = 'apartmentId';

        if (String.isBlank(recordId)) {
            throw new AuraHandledException('Id from the record can´t be empty. Please contact your Salesforce admin.');
        }

        if (recordId.getSobjectType() == Property__c.sObjectType) {
            parameterName = 'propertyId';
        }

        lstActiveContracts = (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ActiveTodayByPropertyOrApartment.class)
            .setParameter(parameterName, recordId)
            .query();

        return lstActiveContracts;
    }

    /**
     * sendMassEmail Send an email to many tenants
     *
     * @param lstRecipients (List<Id>): List with the tenant Ids that should receive the email
     * @param subject (String): Email subject
     * @param htmlBody (String): Email body
     * @return String: The process result 
     */
    @AuraEnabled
    public static String sendMassEmail(List<Id> lstRecipients, String subject, String htmlBody){
        String result = 'Success';

        // Data validation
        if (lstRecipients.isEmpty()) {
            throw new HandledException('Please select at least one tenant.');
        }
        if (String.isBlank(subject)) {
            throw new HandledException('Please fill the subject.');
        }
        if (String.isBlank(htmlBody)) {
            throw new HandledException('Please fill the body.');
        }

        // Fetch contracts selected
        // List<Contract> lstActiveContracts = (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.Contracts.class)
        //     .setParameter('idSet', new Set<Id>(lstRecipients))
        //     .query();

        
        // CustomerContractService customerContractService = new CustomerContractService();
        // try {
        //     customerContractService.sendMassEmailToCurrentTenants(lstActiveContracts, subject, htmlBody);
        // } catch (Exception e) {
        //     throw new AuraHandledException(e.getMessage());
        // }

        // Start of the Updates
        // January 26, 2025

        List<Contract> lstActiveContracts = [SELECT Id, Room__r.Property__r.BrandRef__r.EmailDomain__c, Account.PersonContactId, Account.PersonEmail FROM Contract WHERE Id IN :lstRecipients];

        String brandSupportEmail = lstActiveContracts.get(0)?.Room__r?.Property__r?.BrandRef__r?.EmailDomain__c;
        // System.debug('brandSupportEmail brandSupportEmail' + brandSupportEmail);

        if (String.isBlank(brandSupportEmail)) {
            throw new HandledException('The system can not find the Brand email domain. Please review the all relationships with the Room, the Property and the Brand.');
        } else {
            brandSupportEmail = 'support@' + brandSupportEmail;
        }
        
        List<OrgWideEmailAddress> orgwideAddresses = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :brandSupportEmail];
        
        if (orgwideAddresses.size() == 0) {
            throw new HandledException('We have not found any support email for the selected brand. Please contact your Salesforce admin.');
        }

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        if(lstActiveContracts.size() > 0){
            for (Contract contract : lstActiveContracts) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(contract.Account.PersonContactId);
                mail.toAddresses = new String[] {contract.Account.PersonEmail};
                mail.setSubject(subject);
                mail.setHtmlBody(htmlBody);
                mail.setSaveAsActivity(true);
                mail.setOrgWideEmailAddressId(orgwideAddresses[0].Id);
                mails.add(mail);
            }
        }
       
        // System.debug('mails mails mails' + mails);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);

        for (Messaging.SendEmailResult res : results) {
            if(res.isSuccess()) {
                System.debug('Email sent successfully');
            } else {
                System.debug('The following errors occurred: ' + res.getErrors());                 
            }
        }
        

        return result;
    }

    
}