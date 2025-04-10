public without sharing class ContractDomain_AccountMembership extends Paua_SObjectDomain{
    public override void init() {
        domainType = ContractDomain_AccountMembership.class;
    }

    public override void afterUpdate() {
        CustomerContractService contractService = new CustomerContractService();

        List<Contract> relevantForAccounts = contractService.getWithNewRelevantStatus(
            (List<Contract>)Trigger.new, 
            (Map<Id, Contract>)Trigger.oldMap,
            new Set<String>{CustomerContractService.STATUS_ACTIVATED, CustomerContractService.STATUS_TERMINATED}
        ); 
        relevantForAccounts = contractService.getWithRecordTypeIds(
            relevantForAccounts, 
            new Set<Id> {(Id) CustomerContractService.RT_ID_MEMBERSHIP}
        );

        contractService.updateAccountMembership(relevantForAccounts);
    }
}