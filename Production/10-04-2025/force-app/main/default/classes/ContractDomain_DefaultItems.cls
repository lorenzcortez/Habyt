public without sharing class ContractDomain_DefaultItems extends Paua_SObjectDomain {
    public override void init(){
        domainType = ContractDomain_DefaultItems.class;
    }

    public override void afterInsert(){
        CustomerContractService contractService = new CustomerContractService();
        List<Contract> relevant = contractService.getWithOpportunity(Trigger.new);

        if (!relevant.isEmpty()) {
            contractService.createDefaultContractItems(relevant);
            contractService.createStripePlans(relevant);
        }
    }
}