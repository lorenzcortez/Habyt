public with sharing class Invoice_cDomain_CreateDeposit extends Paua_SObjectDomain {
    public override void init() {
        domainType = Invoice_cDomain_CreateDeposit.class;
    }

    public override void afterUpdate() {
        InvoiceService service = new InvoiceService();

        List<Invoice__c> relevantInvoices = service.getWithRemainingOrDepositChange(
            (List<Invoice__c>) Trigger.new, 
            (Map<Id, Invoice__c>) Trigger.oldMap
        );  
        
        service.generateDeposits(relevantInvoices);
    }

    public override void afterInsert() {
        InvoiceService service = new InvoiceService();

        List<Invoice__c> relevantInvoices = service.getRelevantDepositInsertion((List<Invoice__c>) Trigger.new);  
        
        service.generateDeposits(relevantInvoices);
    }
}