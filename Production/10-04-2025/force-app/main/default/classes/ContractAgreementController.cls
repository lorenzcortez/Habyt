public without sharing class ContractAgreementController {  public static final String DOC_AGREE_NAME =  'Membership Agreement ';
    public static final String ACTIVE_STATUS = 'Activated';

    @AuraEnabled
    public static Contract getMembershipContract(Id contId){
        try {
            Contract contract = (Contract) Paua_SelectorHandler.getSelector(CustomerContractSelectors.Contracts.class)
                                                                .setParameter('id', contId)
                                                                .query().get(0);
            List<Contract> membershipCont = (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ContractsByOpportunityAndRecordType.class)
                                                                            .setParameter('id', contract.Opportunity__c)
                                                                            .setParameter('rtId', CustomerContractService.RT_ID_MEMBERSHIP)
                                                                            .query();
            return membershipCont.isEmpty() ? null: membershipCont.get(0);
                        
        } catch (Exception e) {
            throw new AuraHandledException('Error ContractAgreementController.getMembershipContract ' + e.getMessage());
        }
    }


    @AuraEnabled
    public static void activateContract(Id contId){
        try {
            Contract memberContract = getMembershipContract(contId);

            Contract contract = (Contract) Paua_SelectorHandler.getSelector(CustomerContractSelectors.Contracts.class)
                .setParameter('id', contId)
                .query().get(0);
            
            Paua_Transaction trans = new Paua_Transaction();

            trans.addForUpdate(new Account(Id = contract.AccountId, MembershipStatusPick__c = 'Member'));
            trans.addForUpdate(new Contract(Id = contId, Community_Step__c = 1));

            if (memberContract != null) {
                trans.addForUpdate(new Contract(Id = memberContract.Id, Status = ACTIVE_STATUS));
            }

            trans.setPreferredOrder(new List<SObjectType>{Account.getSObjectType(), Contract.getSObjectType()});
            trans.commitRecords();
        } catch (Exception e) {
            System.debug('+++ e: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ContentDistribution getURL(Id contId){
        try {
            Contract memberContract = ContractAgreementController.getMembershipContract(contId);
            if (memberContract == null) {
                return null;
            }

            Id memberContId = memberContract.Id;
            
            Set<Id> contentDocs = new Set<Id> ();
            for(ContentDocumentLink iCdl: (List<ContentDocumentLink>)Paua_SelectorHandler.getSelector(ContentSelectors.ContentDocumentLinkByLinkedEntity.class)
                                                                                        .setParameter('idSet', new Set<Id>{memberContId})
                                                                                        .query()){
                contentDocs.add(iCdl.ContentDocumentId);
            }

            CustomerContractService contractService = new CustomerContractService();
            String contractDocName = contractService.getContractTitle(memberContract);
            List<ContentVersion> contentVersions = Paua_SelectorHandler.getSelector(ContentSelectors.ContentVersionByDocumentAndTitle.class)
                .setParameter('title', contractDocName)
                .setParameter('docIds', contentDocs)
                .query();
            
            ContentDistribution returnCd;
            if(!contentVersions.isEmpty()){
                returnCd =(ContentDistribution) Paua_SelectorHandler.getSelector(ContentSelectors.DownloadableContent.class)
                                                                    .setParameter('idSet', new Set<Id>{contentVersions.get(0).Id})
                                                                    .query().get(0);
            }
           
            return returnCd;
                        
        } catch (Exception e) {
            System.debug('*** getURL' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
}