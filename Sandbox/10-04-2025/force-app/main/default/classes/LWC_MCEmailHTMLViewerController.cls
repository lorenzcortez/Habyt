public with sharing class LWC_MCEmailHTMLViewerController {
    @AuraEnabled(cacheable=true)
    public static String getTaskEmailHtml(String recordId) {
        try {
            Task taskRecord = [SELECT MC_Email_Activity__r.MC_Email_Raw_HTML__c FROM Task WHERE Id = :recordId LIMIT 1];
            return taskRecord.MC_Email_Activity__r.MC_Email_Raw_HTML__c;
        } catch (Exception e) {return null;}
    }
}