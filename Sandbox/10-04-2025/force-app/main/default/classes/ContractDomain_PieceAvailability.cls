public without sharing class ContractDomain_PieceAvailability extends Paua_SObjectDomain {
    public override void init(){
        domainType = ContractDomain_PieceAvailability.class;
    }

    public override void afterUpdate(){
        CustomerContractService contractService = new CustomerContractService();
        
        List<Contract> relevant = contractService.getWithNewRelevantStatus(
            (List<Contract>)Trigger.new, 
            (Map<Id, Contract>)Trigger.oldMap,
            new Set<String>{CustomerContractService.STATUS_SIGNED, CustomerContractService.STATUS_TERMINATED, CustomerContractService.STATUS_VOIDED, CustomerContractService.STATUS_CANCELLED}
        );
        relevant = contractService.getWithPropertyStage(CustomerContractService.PROPERTTY_STAGE_LAUNCHED, relevant);
        relevant = contractService.getWithPiece(relevant);
        contractService.updatePieceAvailability(relevant);
    }
}