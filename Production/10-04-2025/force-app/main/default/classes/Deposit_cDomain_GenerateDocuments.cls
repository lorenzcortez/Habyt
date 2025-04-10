public with sharing class Deposit_cDomain_GenerateDocuments extends Paua_SObjectDomain {
    public override void init() {
        domainType = Deposit_cDomain_GenerateDocuments.class;
    }

    public override void afterUpdate() {
        DepositService service = new DepositService();

        List<Deposit__c> relevantDeposits = service.getWithNewRelevantStatus(
            (List<Deposit__c>) Trigger.new, 
            (Map<Id, Deposit__c>) Trigger.oldMap,
            DepositService.STATUS_SUBMITTED, 
            DepositService.STATUS_APPROVED
        );  

        service.generateDepositFile(relevantDeposits);
    }
}