public with sharing class SendFlatmateEmailInvokable {
    @InvocableMethod(label='Send Flatmate Email')
    public static void sendFlatmateEmail(List<RequestFlowParam> params) {
        try {
            String recordId = params[0].recordId;
            List<Id> contractIdList = params[0].contractList;
            String templateId = params[0].templateId;
            String orgWideId = params[0].orgWideId;

            List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

            Contract getMainContract = [SELECT Id, FirstNameRecipientAuto__c, StartDate FROM Contract WHERE Id =: recordId];
            
            List<Contract> contracts = [SELECT Id, Account_Email2__c, Account.PersonContactId FROM Contract WHERE Id IN :contractIdList];

            for (Contract cont : contracts) {
                if (cont.Account_Email2__c != null && cont.Account.PersonContactId != null) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTemplateId(templateId);
                    email.setTargetObjectId(cont.Account.PersonContactId);
                    email.setWhatId(getMainContract.Id);
                    email.setOrgWideEmailAddressId(orgWideId);
                    email.setSaveAsActivity(false);
                    emailMessages.add(email);
                }
            }

            System.debug('### emailMessages ' + emailMessages);

            if (!emailMessages.isEmpty()) {
                Messaging.sendEmail(emailMessages);
            }
        } catch (Exception err) {
            System.debug('### errorMessage =: ' + err.getMessage() + ' at line ' + err.getLineNumber());
        }
    }
    
    public class RequestFlowParam {
        @InvocableVariable(label='Contract')
        public String recordId;
        @InvocableVariable(label='Contract List')
        public List<Id> contractList;
        @InvocableVariable(label='Template Id')
        public String templateId;
        @InvocableVariable(label='Org Wide Id')
        public String orgWideId;
    }
}