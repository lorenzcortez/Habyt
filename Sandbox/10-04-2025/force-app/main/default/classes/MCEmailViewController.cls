public without sharing class MCEmailViewController {
    public String htmlBody { get; set; }
    
    public MCEmailViewController() {
        // Get the current page's record Id
        String recordId = ApexPages.currentPage().getParameters().get('id');
        try {
            Task taskRecord = [SELECT MC_Email_Activity__r.MC_Email_Raw_HTML__c FROM Task WHERE Id = :recordId LIMIT 1];
            htmlBody = taskRecord.MC_Email_Activity__r.MC_Email_Raw_HTML__c;
        } catch (Exception e) {htmlBody = null;}
    }
}