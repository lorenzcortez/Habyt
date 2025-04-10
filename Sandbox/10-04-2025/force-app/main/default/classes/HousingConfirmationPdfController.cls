public without sharing class HousingConfirmationPdfController {
    @AuraEnabled
    public String brand {get; set;}
    @AuraEnabled
    public String stamp {get; set;}

    public HousingConfirmationPdfController(ApexPages.StandardController standardController) {
        Id contractId = ((Contract) standardController.getRecord()).Id;
        List<Contract> contracts = (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.Contracts.class)
            .setParameter('id', contractId)
            .query();
        
        Contract contract = contracts[0];
        
        String brandName = contract.Room__r?.Property__r?.BrandRef__c != null ? 
            contract.Room__r.Property__r.BrandRef__r.APINameBrand__c : 
            contract.ApartmentRef__r?.PropertyRef__r?.BrandRef__r?.APINameBrand__c;

        if (String.isNotBlank(brandName)) {
            brand = 'logos/' + brandName.toLowerCase() + '.jpg';
            stamp = 'stamps/' + brandName.toLowerCase() + '.jpg';
        }
    }
}