public with sharing class ContractDomain_VoidContractEversign extends Paua_SObjectDomain {
    public override void init(){
        domainType = ContractDomain_VoidContractEversign.class;
    }

    public override void afterUpdate(){
        CustomerContractService contractService = new CustomerContractService();

        List<Contract> relevant = contractService.getWithNewRelevantStatus(
            (List<Contract>) Trigger.new, 
            (Map<Id, Contract>) Trigger.oldMap,
            new Set<String>{CustomerContractService.STATUS_VOIDED}
        );
        relevant = contractService.getWithDocHashNotNull(relevant, (Map<Id, Contract>) Trigger.oldMap);

        contractService.voidContractsInEversign(relevant, (Map<Id, Contract>) Trigger.oldMap);
    }
}