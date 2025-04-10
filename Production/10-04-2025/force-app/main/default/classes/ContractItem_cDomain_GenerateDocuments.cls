public without sharing class ContractItem_cDomain_GenerateDocuments extends Paua_SObjectDomain {

    public override void init() {
        domainType = ContractItem_cDomain_GenerateDocuments.class;
    }

    public override void afterInsert() {
        Set<Id> contractIds = new Set<Id>();
        for (ContractItem__c ci: (List<ContractItem__c>) Trigger.new) {
            contractIds.add(ci.ContractRef__c);
        }

        if (!System.isBatch() && !System.isFuture() && !System.isQueueable()) {
            CustomerContractService.createDocuments(contractIds);
        }
    }
}