public with sharing class HousingConfirmationQueueable implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        CustomerContractService contractService = new CustomerContractService();
        Set<String> forbiddenStatuses = new Set<String> {
            CustomerContractService.STATUS_CANCELLED, 
            CustomerContractService.STATUS_VOIDED
        };
        List<Contract> relevantContracts = (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ByStartDateStatusAndCountry.class)
            .setParameter('forbiddenStatuses', forbiddenStatuses)
            .setParameter('dateValue', System.today())
            .setParameter('countries', CustomerContractService.HOUSING_CONFIRMATION_COUNTRIES)
            .query();
        relevantContracts = contractService.getWithEndAfterDate(relevantContracts, System.today());  

        contractService.createHousingConfirmation(relevantContracts);
    }
}