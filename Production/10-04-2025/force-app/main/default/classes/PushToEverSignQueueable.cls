public without sharing class PushToEverSignQueueable implements Queueable, Database.AllowsCallouts {
	private static String HMACSECRETKEY = 'HMACKEY';

    private List<Contract> contracts;

    public PushToEverSignQueueable(Set<Id> contractIds) {
        contracts = Paua_SelectorHandler.getSelector(CustomerContractSelectors.Contracts.class)
            .setParameter('idSet', contractIds)
            .query();
    }

    public void execute(QueueableContext context) {
        // TODO: refactor this into a service
        Contract contract;
        CustomerContractService contractService = new CustomerContractService();
        while (!contracts.isEmpty() && contract == null) {
            contract = contracts.remove(0);
            if (contract.RecordTypeId == CustomerContractService.RT_ID_RENT) {
                EverSignModels.payloadEverSign payload;
                if (Test.isRunningTest()) {
                    String contractName = contractService.getContractTitle(contract);
                    ContentVersion version = contractService.createDocumentVersion(contract.Id, contractName);
                    payload = EverSignService.getPayloadEverSign(
                        contract.Account.Name, 
                        contract.Account.PersonEmail, 
                        Blob.valueOf('Unit Test'), 
                        contract.Room__r.Property__r.BrandRef__r.APINameBrand__c,
                        contractName
                    );
                } else {
                    String contractName = contractService.getContractTitle(contract);
                    ContentVersion version = contractService.createDocumentVersion(contract.Id, contractName);
                    payload = EverSignService.getPayloadEverSign(
                        contract.Account.Name, 
                        contract.Account.PersonEmail, 
                        version.VersionData, 
                        contract.Room__r.Property__r.BrandRef__r.APINameBrand__c,
                        contractName
                    );
                }

                System.debug(payload);
                String eversignHash = IcxEverSignInterface.CreateDocument(JSON.serialize(payload));
                System.debug(eversignHash);
                // TODO: how to process failures;
                contract.EverSign_Doc_Hash__c = eversignHash;

                Blob hmacData = Crypto.generateMac('HmacSHA256', Blob.valueOf(contract.Id + '.' + eversignHash), Blob.valueOf(HMACSECRETKEY));
                String Hmac = EncodingUtil.convertToHex(hmacData);
                String communityURL = External_API_Key__c.getOrgDefaults().Community_BaseURL__c;//'https://icxdev-weareproject.cs88.force.com/s/notconnected?';
                communityURL += 'contractId=' + contract.Id;
                communityURL += '&signature=' + Hmac;
                System.debug(communityURL);
                contract.Community_URL__c = communityURL;

                update contract;  // God forgive me
            } else {
                contract = null;
            }
        }

        if (!(contracts.isEmpty() || Test.isRunningTest())) {
            System.enqueueJob(this);
        }
    }
}