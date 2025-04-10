public without sharing class TenantContractService {

    public static final STRING FREC_RECURRING = 'Recurring';
    public static final STRING FREC_ONE_OFF = 'One Off';
    public static final Id ADDITIONAL_ITEM_RT = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('AdditionalItem').getRecordTypeId();

    public List<Contract> createDepositAndSubscription(Id opportunityId){
        List<Contract> lstUpdatedContracts = new List<Contract>();
        List<Contract> lstContracts = Paua_SelectorHandler.getSelector(CustomerContractSelectors.ActiveContractsByOpportunity.class)
                                                            .setParameter('oppId', opportunityId)
                                                            .query();

        Map<Id,Contract> mapId_Contract = new Map<Id,Contract>(lstContracts);
        Map<Id, List<ContractItem__c>> mapContract_LstContractItems = new Map<Id, List<ContractItem__c>>();
        List<ContractItem__c> contractItems = (List<ContractItem__c>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ContractItems.class)
                                                                                          .setParameter('idSet', mapId_Contract.keySet())
                                                                                          .query();
        
        for (ContractItem__c iContractItem : contractItems) {
            if (!mapContract_LstContractItems.containsKey(iContractItem.ContractRef__c)) {
                mapContract_LstContractItems.put(iContractItem.ContractRef__c, new List<ContractItem__c>());
            }
            mapContract_LstContractItems.get(iContractItem.ContractRef__c).add(iContractItem);
        }

        for (Id contractId : mapContract_LstContractItems.keySet()) {
            lstUpdatedContracts.addAll(processAllPaymentsForContract(mapId_Contract.get(contractId), mapContract_LstContractItems.get(contractId)));
        }

        return lstUpdatedContracts;
    }

    public List<Contract> processAllPaymentsForContract(Contract contract, List<ContractItem__c> lstContractItems){
        Decimal recurringAmount = 0;
        String couponId;
        List<Contract> lstContracts = new List<Contract>();
        List<ContractItem__c> oneOffDicounts = new List<ContractItem__c>();
        List<ContractItem__c> recurringDicounts = new List<ContractItem__c>();
        String stripeCustomerJSONMap = contract.StripeCustomerJSONMap__c != null ? contract.StripeCustomerJSONMap__c : contract.Account.StripeCustomerJSONMap__c;
        Map<String,Object> mapStripeSecretKey_CustomerId = (Map<String,Object>) JSON.deserializeUntyped(stripeCustomerJSONMap);
        String customerId = (String) mapStripeSecretKey_CustomerId.get(contract.Stripe_Account__r.secret_key__c);

        for (ContractItem__c iContractItem : lstContractItems) {
            // if (iContractItem.ProductRef__r.FrequencyPick__c == FREC_RECURRING && String.isBlank(contract.STRIPE_Plan_Id__c)) {
            if (iContractItem.ProductRef__r.FrequencyPick__c == FREC_RECURRING) {
                throw new TenantContractServiceException('We\'re sorry but there seems to be some issue with your contract details.');
            }

            // Process only payments not additional items
            if (iContractItem.ProductRef__r.RecordTypeId != ADDITIONAL_ITEM_RT) {
                // Recurring payments
                if (iContractItem.ProductRef__r.FrequencyPick__c == FREC_RECURRING) {
                    recurringAmount += iContractItem.PriceTrig__c;
                } else {
                    // One-off payments
                    generateInvoice_Stripe(contract, iContractItem, customerId);
                }
            }

            if (String.isNotEmpty(iContractItem.StripeCouponId__c)) {
                couponId = iContractItem.StripeCouponId__c;
            }
        }

        if (recurringAmount != 0) {
            // Recurring payments
            lstContracts.add(generateSubscription_Stripe(contract, customerId, couponId));
        }

        return lstContracts;
    }


    public static Contract generateSubscription_Stripe(Contract contract, String customerId, String couponId){
        StripeModels.Subscription subscription = new StripeModels.Subscription(
            customerId,
            contract.STRIPE_Plan_Id__c,
            contract.Stripe_Account__r.secret_key__c,
            contract.StartDate,
            couponId
        );

        subscription = StripeService.upsertSubscription(subscription);
        
        return new Contract(Id = contract.Id, Stripe_Subscription_Id__c = subscription.Id, Stripe_Subscription_Status__c = subscription.status);
    }

    /**
     * Makes a callout to stripe through stripe service. None of the parameters can be null.
     */
    public static void generateInvoice_Stripe(Contract contract, ContractItem__c contractItem, String customerId){
        StripeModels.Invoice invoice = new StripeModels.Invoice(
            String.valueOf(contract.Id),
            contractItem.ProductRef__r.Name, 
            customerId, 
            contract.Stripe_Account__r.secret_key__c, 
            contractItem.PriceTrig__c,
            contractItem.ProductRef__r.Name
        );

        StripeService.createInvoice(invoice);
    }

    public class TenantContractServiceException extends Exception{}
}