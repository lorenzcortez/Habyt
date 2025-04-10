/*
 * @what    : This class implements a Trigger to cancel / terminate rental contract strip end, and if selected also the membership.
 */
public with sharing class ContractDomain_CancelTerminatStripSub extends Paua_SObjectDomain {
    public override void init(){
        domainType = ContractDomain_CancelTerminatStripSub.class;
    }

    public override void afterUpdate(){
        CustomerContractService contractService = new CustomerContractService();
        List<Contract> relevants = contractService.getWithNewRelevantStatus(
            (List<Contract>)Trigger.new, 
            (Map<Id, Contract>)Trigger.oldMap,
            new Set<String>{CustomerContractService.STATUS_CANCELLED, CustomerContractService.STATUS_TERMINATED}
        );

        System.debug('Come on');

        for (Contract relevant : relevants) {
            if (relevant.Contract_End_Date__c != null && relevant.Stripe_Subscription_Status__c != 'canceled' && relevant.Stripe_Subscription_Id__c != null) {
                CustomerContractService.cancelStripSub(relevant.Id, relevant.Contract_End_Date__c, relevant.Move_out_date__c);
            } 
        }
    }
}