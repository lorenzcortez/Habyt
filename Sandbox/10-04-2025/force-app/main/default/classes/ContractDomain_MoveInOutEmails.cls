public with sharing class ContractDomain_MoveInOutEmails extends Paua_SObjectDomain {
    public override void init(){
        domainType = ContractDomain_MoveInOutEmails.class;
    }

    public override void afterUpdate(){
        CustomerContractService contractService = new CustomerContractService();
        List<Contract> relevant = contractService.getNotTestContract((List<Contract>)Trigger.new);
        relevant = contractService.getWithRecordTypeIds(relevant, new Set<Id>{CustomerContractService.RT_ID_RENT});

        List<Contract> relevantMoveIn = contractService.getWithNewRelevantStatusSet(
            relevant, 
            (Map<Id, Contract>) Trigger.oldMap,
            new Set<String>{CustomerContractService.STATUS_SIGNED, CustomerContractService.STATUS_ACTIVATED}
        );

        relevantMoveIn = contractService.getWithMoveInPeriod(relevantMoveIn);
        relevantMoveIn = contractService.getWithoutMoveInDatetime(relevantMoveIn);

        List<Contract> relevantMoveOut = contractService.getWithNewRelevantStatusSet(
            relevant, 
            (Map<Id, Contract>) Trigger.oldMap,
            new Set<String>{CustomerContractService.STATUS_TERMINATED}
        );
        relevantMoveOut = contractService.getWithEndBeforeDate(
            relevantMoveOut, 
            System.today().addDays(1)
        );
        relevantMoveOut = contractService.getWithoutMoveOutDatetime(relevantMoveOut);

        if (! relevantMoveIn.isEmpty()) {
            //contractService.notifyMoveInContracts(relevantMoveIn);
        }

        if (! relevantMoveOut.isEmpty()) {
            contractService.notifyMoveOutContracts(relevantMoveOut);
        }
    }
}