public with sharing class OpportunityDomain_CustomerContract extends Paua_SObjectDomain{
	
    public override void init(){
		domainType = OpportunityDomain_CustomerContract.class;
	}

	public override void afterUpdate(){
		CustomerOpportunityService opportunityService = new CustomerOpportunityService();
        CustomerContractService contractService = new CustomerContractService();
		
        Set<Id> setOppIds = opportunityService.getOppsReadyForContracts((List<Opportunity>)Trigger.new, (Map<Id, Opportunity>)Trigger.oldMap);
        if (!setOppIds.isEmpty()) {
            List<Contract> lstContracts = contractService.createContracts(setOppIds);
        }
	}
}