/*
 * @who     : Igor Kudryk <igor.kudryk@empaua.com>
 * @when    : 02.09.2021
 * @what    : This class implements a Trigger to void related contracts to the room the is booked
 */
public with sharing class ContractDomain_VoidContract extends Paua_SObjectDomain {
    public override void init(){
        domainType = ContractDomain_VoidContract.class;
    }

    public override void afterUpdate(){
        CustomerContractService contractService = new CustomerContractService();
        List<Contract> relevant = contractService.getWithNewRelevantStatus(
            (List<Contract>)Trigger.new, 
            (Map<Id, Contract>)Trigger.oldMap,
            new Set<String>{CustomerContractService.STATUS_SIGNED}
        );

        contractService.voidRelatedContracts(relevant);
    }
}