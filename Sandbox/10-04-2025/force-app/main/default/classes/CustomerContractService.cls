public without sharing class CustomerContractService {
    /* Types */
    public static final String TYPE_RENT = 'Rent';
    public static String TYPE_MEMBERSHIP = 'Membership';
    /* Record Type Names */
    public static final String CONTRACT_RT_RENT = 'Rent';
    public static final String CONTRACT_RT_MEMBERSHIP = 'MembershipFee';
    public static final String PRODUCT_RT_RENT = 'Rent';
    public static final String PRODUCT_RT_MEMBERSHIP = 'MembershipFee';
    /* Record Type Ids */
    public static final String RT_ID_RENT = Contract.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(CONTRACT_RT_RENT).getRecordTypeId();
    public static final String RT_ID_MEMBERSHIP = Contract.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(CONTRACT_RT_MEMBERSHIP).getRecordTypeId();
    public static final String PRODUCT_RT_ID_RENT = Product2.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(PRODUCT_RT_RENT).getRecordTypeId();
    public static final String PRODUCT_RT_ID_MEMBERSHIP = Product2.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(PRODUCT_RT_MEMBERSHIP).getRecordTypeId();
    public static final String PRODUCT_RT_ID_ADD_ITEM = Product2.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('AdditionalItem').getRecordTypeId();

    public static final String STATUS_DRAFT = 'Draft';
    public static final String STATUS_SIGNED = 'Signed';
    public static final String STATUS_ACTIVATED = 'Activated';
    public static final String STATUS_TERMINATED = 'Terminated';
    public static final String STATUS_VOIDED = 'Voided';
    public static final String STATUS_CANCELLED = 'Cancelled';

    public static final String ACCOUNT_MEMBER = 'Member';

    public static final String BILLING_ENTITY_TYPE_HOLDING = 'Holding';
    public static final String PROPERTTY_STAGE_LAUNCHED = 'Launched';
    public static final String DOCUMENT_NAME_DEFAULT = 'Contract.pdf';

    public static final String MOVE_IN_PICKLIST_VALUE = 'Move-In';
    public static final String MOVE_OUT_PICKLIST_VALUE = 'Move-Out';
    public static final Integer MOVE_IN_DAYS = 7;
    public static final Set<String> MOVE_OUT_IN_STATUSES = new Set<String> {
        CustomerContractService.STATUS_ACTIVATED, 
        CustomerContractService.STATUS_SIGNED, 
        CustomerContractService.STATUS_TERMINATED
    };

    public static final Set<String> HOUSING_CONFIRMATION_COUNTRIES = new Set<String> {'Germany'};
    public static final String CONFIRMATION_CONTRACT_NAME_DEFAULT = 'Wohnungsbestätigung';
    public static final String PDF_EXTENSION_NAME = '.pdf';
    public static final String CONFIRMATION_EMAIL_TEMPLATE_NAME = 'HousingConfirmation';

    // Contract Item related 
    public static final STRING FREQ_RECURRING = 'Recurring';
    public static final STRING FREQ_ONE_OFF = 'One Off';

    public List<Contract> getWithNewRelevantStatus(List<Contract> newList, Map<Id, Contract> oldMap, Set<String> relevantStatuses) {
        List<Contract> relevant = new List<Contract>();

        for (Contract contract: newList) {
            if (relevantStatuses.contains(contract.Status) && (
                oldMap == null || contract.Status != oldMap.get(contract.Id).Status
            )) {
                relevant.add(contract);
            }
        }

        return relevant;
    }

    /**
     * This method returns a list of relevant contracts with status value changed from anything else to one of specified
     * values in relevantStatuses. This method is used in a trigger to filter out only specific contracts and notify the 
     * flatmates about move-in or move-out. The difference to getWithNewRelevantStatus is that status changes between relevant 
     * status values are not allowed.
     * 
     * @param newList           List of contracts to be filtered
     * @param oldMap            Map with old versions of contracts with key = Id of contract. Used to track only 
     *                          needed changes in status
     * @param relevantStatuses  Set of relevant status values to filter the contracts
     * @return                  List of filtered contracts
     */
    public List<Contract> getWithNewRelevantStatusSet(List<Contract> newList, Map<Id, Contract> oldMap, Set<String> relevantStatuses) {
        List<Contract> relevant = new List<Contract>();

        for (Contract contract: newList) {
            if (
                (relevantStatuses.contains(contract.Status)) && 
                (oldMap == null || contract.Status != oldMap.get(contract.Id).Status) && 
                (!relevantStatuses.contains(oldMap.get(contract.Id).Status))
            ) {
                relevant.add(contract);
            }
        }

        return relevant;
    }

    private List<Contract> getWithStatuses(List<Contract> contracts, Set<String> statuses){
        List<Contract> relevant = new List<Contract>();

        for (Contract contract: contracts) {
            if (statuses.contains(contract.Status)) {
                relevant.add(contract);
            }
        }

        return relevant;
    } 

    /**
     * Returns contracts with a StartDate sooner than a given date.
     * 
     * @param  contracts the list of contracts to filter
     * @param  dateValue the reference date value
     * @return           the list of contracts matching the criteria
     */
    public List<Contract> getWithStartBeforeDate(List<Contract> contracts, Date dateValue) {
        List<Contract> relevant = new List<Contract>();

        for (Contract contract: contracts) {
            if (contract.StartDate < dateValue) {
                relevant.add(contract);
            }
        }

        return relevant;
    }

    /**
    * Returns contracts with a StartDate that is during the current move-in period (inclusive)
    *
    * @param  contracts  the list of contracts to filter
    * @return            the list of contracts matching the criteria
    */
    public List<Contract> getWithMoveInPeriod(List<Contract> contracts) {
        List<Contract> relevant = new List<Contract>();
        Date today = System.today();

        for (Contract contract: contracts) {
            if (contract?.StartDate != null) {
                Date moveInPeriodStart = contract.StartDate.addDays(-1 * CustomerContractService.MOVE_IN_DAYS);
                Date moveInPeriodEnd = contract.StartDate;
                if (today >= moveInPeriodStart && today <= moveInPeriodEnd) {
                    relevant.add(contract);
                }
            }
        }

        return relevant;
    }

    /**
    * Returns contracts for which the move in email has not been sent yet
    *
    * @param  contracts  the list of contracts to filter
    * @return            the list of contracts matching the criteria
    */
    public List<Contract> getWithoutMoveInDatetime(List<Contract> contracts) {
        List<Contract> relevant = new List<Contract>();

        for (Contract contract: contracts) {
            if (contract.MoveInEmailDatetime__c == null) {
                relevant.add(contract);
            }
        }

        return relevant;
    }

    /**
* Returns contracts for which the move out email has not been sent yet
*
* @param  contracts  the list of contracts to filter
* @return            the list of contracts matching the criteria
*/
    public List<Contract> getWithoutMoveOutDatetime(List<Contract> contracts) {
        List<Contract> relevant = new List<Contract>();

        for (Contract contract: contracts) {
            if (contract.MoveOutEmailDatetime__c == null) {
                relevant.add(contract);
            }
        }

        return relevant;
    }


    /**
     * Returns contracts with a Contract_End_Date__c sooner than a given date.
     * 
     * @param  contracts the list of contracts to filter
     * @param  dateValue the reference date value
     * @return           the list of contracts matching the criteria
     */
    public List<Contract> getWithEndBeforeDate(List<Contract> contracts, Date dateValue) {
        List<Contract> relevant = new List<Contract>();

        for (Contract contract: contracts) {
            if (contract.Contract_End_Date__c < dateValue) {
                relevant.add(contract);
            }
        }
        
        return relevant;
    }

    /**
     * Returns contracts with a Contract_End_Date__c sooner than a given date. This method is used to filter the contracts 
     * for which "Wohnungsbestätigung" PDF document needs to be generated automatically and sent via Email.
     * 
     * @param  contracts the list of contracts to filter
     * @param  dateValue the reference date value
     * @return           the list of contracts matching the criteria
     */
    public List<Contract> getWithEndAfterDate(List<Contract> contracts, Date dateValue) {
        List<Contract> relevant = new List<Contract>();

        for (Contract contract: contracts) {
            if (contract.Contract_End_Date__c == null || contract.Contract_End_Date__c >= dateValue) {
                relevant.add(contract);
            }
        }
        
        return relevant;
    }

    /**
     * Compares the relevant dates in a Contract record to determine whether it is active by a given date.
     * @param  contract  the Contract record to check
     * @param  dateValue the date to check
     * @return           whether it is Active or not
     */
    /**
    public Boolean isActiveByDate(Contract contract, Date dateValue) {
        return contract.StartDate <= dateValue && (
            contract.Contract_End_Date__c == null || contract.Contract_End_Date__c > dateValue
        );
    }
  **/    
  // Updated by Sithija . Date 11/07/2022 
  public Boolean isActiveByDate(Contract contract, Date dateValue) {
    Boolean contractStartedBeforeMoveInContractStart = contract.StartDate <= dateValue;
    Boolean contractHasNoEndDate = contract.Contract_End_Date__c == null;
    Boolean contractEndsAfterMoveInContractStartDate = contract.Contract_End_Date__c > dateValue;
    return 
        contractStartedBeforeMoveInContractStart // I am moving in after this person
        && (
            contractHasNoEndDate // I am not planning to move out
            || 
            contractEndsAfterMoveInContractStartDate // I am moving out after this person comes
    );
  }
  

    public List<Contract> getWithPropertyStage(String stage, List<Contract> contracts) {
        List<Contract> relevant = new List<Contract>();

        for (Contract contract: contracts) {
            if (contract.PropertyStageAuto__c == stage || contract.PropertyStageAuto__c == 'Pre-sales') {
                relevant.add(contract);
            }
        }

        return relevant;
    }

    public List<Contract> getWithOpportunity(List<Contract> contracts) {
        List<Contract> relevant = new List<Contract>();

        for (Contract contract: contracts) {
            if (contract.Opportunity__c != null) {
                relevant.add(contract);
            }
        }

        return relevant;
    }

    public List<Contract> getWithRecordTypeIds(List<Contract> contracts, Set<Id> recordTypeIds) {
        List<Contract> relevant = new List<Contract>();

        for (Contract contract: contracts) {
            if (recordTypeIds.contains(contract.RecordTypeId)) {
                relevant.add(contract);
            }
        }

        return relevant;
    }

    /**
     * This method filters all contracts that have "Move-In" value selected on the picklist field MoveEmailNotifications__c.
     * 
     * @param contracts     List of contracts to be filtered.
     * @return              List of contracts that have move-out value in the picklist.
     */
    public List<Contract> getWithMoveInNotification(List<Contract> contracts){
        List<Contract> relevant = new List<Contract>();

        for(Contract contract : contracts) {
            List<String> selections = contract.Room__r.Property__r.BrandRef__r.MoveEmailNotifications__c?.split(';');

            if(selections != null && selections.contains(MOVE_IN_PICKLIST_VALUE)) {
                relevant.add(contract);
            }
        }

        return relevant;
    } 

    /**
     * This method filters all contracts that have "Move-Out" value selected on the picklist field MoveEmailNotifications__c.
     * 
     * @param contracts     List of contracts to be filtered.
     * @return              List of contracts that have move-out value in the picklist.
     */
    public List<Contract> getWithMoveOutNotification(List<Contract> contracts){
        List<Contract> relevant = new List<Contract>();

        for(Contract contract : contracts) {
            List<String> selections = contract.Room__r.Property__r.BrandRef__r.MoveEmailNotifications__c?.split(';');
            if(selections != null  && selections.contains(MOVE_OUT_PICKLIST_VALUE)) {
                relevant.add(contract);
            }
        }

        return relevant;
    } 

    public List<Contract> getNotTestContract(List<Contract> contracts){
        List<Contract> relevant = new List<Contract>();

        for(Contract contract : contracts) {
            if(!contract.isTestContract__c) {
                relevant.add(contract);
            }
        }

        return relevant;
    } 

    private Id getPieceId(Contract contract) {
        return contract.Room__c != null ? contract.Room__c : contract.ApartmentRef__c;
    }

    public List<Contract> getWithPiece(List<Contract> contracts) {
        List<Contract> relevant = new List<Contract>();

        for (Contract contract: contracts) {
            if (getPieceId(contract) != null) {
                relevant.add(contract);
            }
        }

        return relevant;
    }

    /**
     * This method is used in a trigger to void contracts in eversign that are voided in the salesforce org.
     * 
     * @param contracts     Relevant contracts to void but without hash values
     * @param oldMap        Map of old contracts to get hash value
     */
    public List<Contract> getWithDocHashNotNull(List<Contract> contracts, Map<Id, Contract> oldMap) {
        List<Contract> relevant = new List<Contract>();

        for (Contract contract : contracts) {
            if (oldMap.get(contract.Id).EverSign_Doc_Hash__c != null) {
                relevant.add(contract);
            }
        }

        return relevant;
    } 

    public void updatePieceAvailability(List<Contract> contracts) {
        Paua_Transaction trans = new Paua_Transaction();
        List<Contract> relatedContracts = getRelatedContracts(contracts);
        Map<Id, List<Contract>> pieceIdToContracts = mapContractsByPieceId(relatedContracts);
        Set<Id> addedPieces = new Set<Id>();
        for (Contract contract : contracts) {
            Id pieceId = getPieceId(contract);
            if (addedPieces.contains(pieceId)) {
                continue;
            }
            SObject piece;
            if (pieceId.getSobjectType() == RoomService.SObjectType) {
                piece = new Room__c(Id = pieceId);
            } else {
                piece = new Apartment__c(Id = pieceId);
            }
            Date availabilityDate = calculatePieceAvailability(
                contract, pieceIdToContracts.get(pieceId)
            );
            piece.put('AvailableDateTrig__c', availabilityDate);
            trans.addForUpdate(piece);
            addedPieces.add(pieceId);
        }

        trans.setPreferredOrder(new List<SObjectType>{RoomService.SObjectType, ApartmentService.SObjectType});
        trans.commitRecords();
    }

    private Date calculatePieceAvailability(Contract contract, List<Contract> contracts) {
        if(contract.Status == STATUS_SIGNED || contract.Status == STATUS_ACTIVATED) {
            return null;
        }

        Date latestDate = contract.Contract_End_Date__c;

        if(contracts != null) {
            for(Contract relatedContract : contracts) {
                if(relatedContract.Status == STATUS_SIGNED || relatedContract.Status == STATUS_ACTIVATED) {
                    return null;
                }

                if(relatedContract.Contract_End_date__c != null && (latestDate == null || latestDate < relatedContract.Contract_End_date__c)) {
                    latestDate = relatedContract.Contract_End_date__c;
                }
            }
        }
        if (latestDate == null) {
            return Date.today().addDays(1);
        }
        return latestDate.addDays(1);
    }

    private List<Contract> getRelatedContracts(List<Contract> contracts) {
        Set<Id> pieceIds = new Set<Id>();

        for(Contract contract : contracts) {
            Id pieceId = getPieceId(contract);
            if(pieceId != null) {
                pieceIds.add(pieceId);
            }
        }

        List<Contract> contractsFromPieces = (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ContractsByPieces.class)
                                                .setParameter('idSet', pieceIds)
                                                .query();
        return contractsFromPieces;
    }
    
    private Id getRoomApartment(Contract contract) {
        return contract.Room__r?.ApartmentRef__c != null ? contract.Room__r?.ApartmentRef__c : contract.ApartmentRef__c;
    }

    public Map<Id, List<Contract>> mapContractsByApartment(List<Contract> contracts) {
        Map<Id, List<Contract>> contractsByApartment = new Map<Id, List<Contract>>();
        Set<Id> apartmentIdSet = new Set<Id>();
        for (Contract contract: contracts) {
            apartmentIdSet.add(getRoomApartment(contract));
        }

        for (Contract contract: (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ContractsByPieces.class)
             .setParameter('idSet', apartmentIdSet)
             .query()
        ) {
            Id apartmentId = getRoomApartment(contract);
            if (apartmentId != null) {
                if (! contractsByApartment.containsKey(apartmentId)) {
                    contractsByApartment.put(apartmentId, new List<Contract>());
                }
                contractsByApartment.get(apartmentId).add(contract);
            }
        }

        return contractsByApartment;
    }

    private Map<Id, List<Contract>> mapContractsByPieceId(List<Contract> contracts) {
        Map<Id, List<Contract>> pieceIdToContracts = new Map<Id, List<Contract>>();

        for(Contract contract : contracts) {
            Id pieceId = getPieceId(contract);
            List<Contract> pieceContracts = pieceIdToContracts.get(pieceId);
            
            if(pieceContracts == null) {
                pieceContracts = new List<Contract> {contract};
            } else {
                pieceContracts.add(contract);
            }

            pieceIdToContracts.put(pieceId, pieceContracts);
        }
        
        return pieceIdToContracts;
    }

    public void updateAccountMembership(List<Contract> contracts) {
        Paua_Transaction trans = new Paua_Transaction();
        PersonAccountService accountService = new PersonAccountService();
        List<Account> accountsWithRelatedContracts = getAccountsFromContracts(contracts);
        List<Account> accountsWithNoMembership = accountService.filterAccountsNoMembership(accountsWithRelatedContracts);

        for(Account account : accountsWithNoMembership) {
            account.MembershipStatusPick__c = null;
        }

        trans.setPreferredOrder(new List<SObjectType>{Account.SObjectType});
        trans.addForUpdate(accountsWithNoMembership);
        trans.commitRecords();
    }

    private List<Account> getAccountsFromContracts(List<Contract> contracts) {
        Set<Id> accountsIdsFromContracts = new Set<Id>();

        for(Contract contract : contracts) {
            if(contract.AccountId != null) {
                accountsIdsFromContracts.add(contract.AccountId);
            }
        }

        List<Account> accountsFromContracts = (List<Account>) Paua_SelectorHandler.getSelector(PersonAccountSelectors.FromAccountIds.class)
            .setParameter('accountIds', accountsIdsFromContracts)
            .query();

        return accountsFromContracts;
    }

    public List<Contract> createContracts(Set<Id> setOppIds){
        List<Contract> lstContracts = new List<Contract>();
        List<ContractItem__c> lstContractItems;
        Paua_Transaction trans = new Paua_Transaction();
        Billing_Entity__c holdingBillingEntity = (Billing_Entity__c) Paua_SelectorHandler.getSelector(BillingEntitySelectors.FromType.class)
            .setParameter('type',BILLING_ENTITY_TYPE_HOLDING)
            .query()
            .get(0);

        List<Opportunity> lstOpps = (List<Opportunity>) Paua_SelectorHandler.getSelector(CustomerOpportunitySelectors.FromId.class)
            .setParameter('idSet',setOppIds)
            .query();

        for (Opportunity iOpp : lstOpps) {
            // Create Rent Contract
            Contract rentContract = createContract(iOpp, CustomerContractService.TYPE_RENT, null);
            lstContracts.add(rentContract);
            trans.addForInsert(rentContract);

            // If not a member, create Membership Contract too
            if (iOpp.Account.MembershipStatusPick__c != ACCOUNT_MEMBER && 
            (iOpp.Room__r.Property__r.City__c != 'Hong Kong' || iOpp.ApartmentRef__r.PropertyRef__r.City__c != 'Hong Kong') &&
            (iOpp.Room__r.Property__r.City__c != 'Singapore' || iOpp.ApartmentRef__r.PropertyRef__r.City__c != 'Singapore')) {
                Contract membershipContract = createContract(iOpp, CustomerContractService.TYPE_MEMBERSHIP, holdingBillingEntity);
                lstContracts.add(membershipContract);
                trans.addForInsert(membershipContract);
            }
        }

        // Commit records
        trans.setPreferredOrder(new List<SObjectType>{Contract.getSObjectType()});  //, ContractItem__c.getSObjectType()});
        trans.commitRecords();

        return lstContracts;
    }

    public Contract createContract(Opportunity opp, String contractType, Billing_Entity__c billingEntity){

        System.debug('opp opp opp' + opp);
        System.debug(' opp.ApartmentRef__c' +  opp.ApartmentRef__c);
        System.debug('billingEntity' + billingEntity);
        Contract con = new Contract();
        con.AccountId = opp.AccountId;
        con.Description = opp.Description;
        con.StartDate = opp.Start_Date__c;
        con.Contract_End_Date__c = opp.ContractEndDate__c;
        con.ContractTerm = 6;
        con.Opportunity__c = opp.Id;
        con.Status = STATUS_DRAFT;
        con.CurrencyIsoCode = opp.CurrencyIsoCode;
        con.Utilities_Cap__c = opp.Utilities_Cap__c;
        con.Shared_Expenses__c = opp.Shared_Expenses__c;
        con.Contract_Category__c = opp.Contract_Category__c;

        // Rent contract logic
        if (contractType == CustomerContractService.TYPE_RENT) {
            con.RecordTypeId = CustomerContractService.RT_ID_RENT;
            if (opp.Room__c != null &&  opp?.Room__r?.Property__r?.Billing_Entity__r?.Stripe_Account__c != null) {
                System.debug('Room__c');
                con.Room__c = opp.Room__c;
                con.Billing_Entity__c = opp.Room__r.Property__r.Billing_Entity__c;
                con.Stripe_Account__c = opp.Room__r.Property__r.Billing_Entity__r.Stripe_Account__c;
            } else {
                System.debug('No Room__c' );
                con.ApartmentRef__c = opp.ApartmentRef__c;
                con.Billing_Entity__c = opp.ApartmentRef__r.PropertyRef__r.Billing_Entity__c;
                con.Stripe_Account__c = opp.ApartmentRef__r.PropertyRef__r.Billing_Entity__r.Stripe_Account__c;
            } 
        // Membership contract logic
        } else {
            con.RecordTypeId = CustomerContractService.RT_ID_MEMBERSHIP;
            con.Billing_Entity__c = billingEntity.Id;
            con.Stripe_Account__c = billingEntity.Stripe_Account__c;
        }

        System.debug('con con con con' + con);
        return con;
    }

    public List<ContractItem__c> createDefaultContractItems(List<Contract> contracts) {
        Set<Id> setOppIds = new Set<Id>();
        for (Contract contract: contracts) {
            setOppIds.add(contract.Opportunity__c);
        }

        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>(
            (List<Opportunity>) Paua_SelectorHandler.getSelector(CustomerOpportunitySelectors.FromId.class)
                .setParameter('idSet',setOppIds)
                .query()
        );

        List<ContractItem__c> items = new list<ContractItem__c>();
        for (Contract contract: contracts) {
            items.addAll(createContractItemsForProducts(
                contract, oppsMap.get(contract.Opportunity__c).OpportunityLineItems, contract.RecordTypeId
            ));
        }

        if (!items.isEmpty()) {
            Paua_Transaction trans = new Paua_Transaction();
            trans.addForInsert(items);
            trans.setPreferredOrder(new List<SObjectType>{ContractItem__c.getSObjectType()});
            trans.commitRecords();
        }
    
        return items;
    }

    public List<ContractItem__c> createContractItemsForProducts(Contract contract, List<OpportunityLineItem> lstOppLineItems, Id contractRecordType){
        List<ContractItem__c> lstContractItems = new List<ContractItem__c>();
        ContractItem__c contractItem;
        Set<Id> Oppids = new Set<Id>();
        Set<Id> OppItems = new Set<Id>();
        Map<Id,Decimal> oppRoommap = new Map<Id,Decimal>();
        Room__c roomInfo = new Room__c();
        system.debug('*********& '+contract.Opportunity__c );
        system.debug('*********& '+contract.Room__c ); 
        
        if(contract.Room__c != NULL){
            roomInfo = [Select Id,Discount_Applicable_for_Months__c from Room__c WHERE Id =:contract.Room__c LIMIT 1];
        }
        
        /*for(OpportunityLineItem opt : lstOppLineItems){
            OppItems.add(opt.Id);
        }
        
        for(OpportunityLineItem op : [Select Id,OpportunityId FROM OpportunityLineItem WHERE Id=: OppItems]){
            Oppids.add(op.OpportunityId);
        }
        
        for(Opportunity opp : [Select Id, Room__c,Room__r.Discount_Applicable_for_Months__c FROM Opportunity WHERE Id =: Oppids]){
            if(opp.Room__r.Discount_Applicable_for_Months__c != NULL){
                oppRoommap.put(opp.Id,opp.Room__r.Discount_Applicable_for_Months__c);
            }
            
        }*/

        for (OpportunityLineItem iOLI : lstOppLineItems) {
            
            if ((contractRecordType == RT_ID_RENT && iOLI.Product2.RecordTypeId == PRODUCT_RT_ID_RENT) 
                || (contractRecordType == RT_ID_MEMBERSHIP && iOLI.Product2.RecordTypeId == PRODUCT_RT_ID_MEMBERSHIP)
                || (contractRecordType == RT_ID_RENT && iOLI.Product2.RecordTypeId == PRODUCT_RT_ID_ADD_ITEM)) 
            {
                contractItem = new ContractItem__c();
                contractItem.ContractRef__c = contract.Id;
                contractItem.PriceTrig__c = iOLI.UnitPrice;
                contractItem.ProductRef__c = iOLI.Product2Id;
                contractItem.OpportunityProductRef__c = iOLI.Id;
                contractItem.Description__c = iOLI.Description;
                contractItem.CurrencyIsoCode = iOLI.CurrencyIsoCode;
                //added
                if(contractItem.Description__c == 'Discount - Recurring'){
                    contractItem.NumberOfMonths__c = roomInfo.Discount_Applicable_for_Months__c;
                }

                // Set Piece, only for Rent Contracts
                if(contractRecordType == RT_ID_RENT){
                    if (iOLI.RoomRef__c != null) {
                        contractItem.RoomRef__c = iOLI.RoomRef__c;
                        contractItem.ApartmentRef__c = iOLI.ApartmentRef__c;
                    } else if (iOLI.Product2.RecordTypeId == PRODUCT_RT_ID_RENT) {
                        contractItem.ApartmentRef__c = iOLI.ApartmentRef__c;
                    }
                }
                lstContractItems.add(contractItem);
            }
        }

        return lstContractItems;
    }

    public ContentVersion createDocumentVersion(Id contractId, String versionName, Id previousVersion) {
        ContentVersion version = createDocumentVersion(contractId);
        version.Title = versionName;
        version.ContentDocumentId = previousVersion;
        version.FirstPublishLocationId = null;   

        return version;
    }

    public ContentVersion createDocumentVersion(Id contractId, String versionName) {
        ContentVersion version = createDocumentVersion(contractId);
        version.Title = versionName;
        return version;
    }

    public static ContentVersion createDocumentVersion(Id contractId) {
        PageReference pdfPage = Page.ContractPDFFromContract;
        pdfPage.getParameters().put('id', contractId);

        Blob content;
        if(Test.isRunningTest()) {
            content = Blob.valueOf('TestContract');
        } else if(pdfPage == null) {
            content = Blob.valueOf(''); 
        } else {
            content = pdfPage.getContent();
        }

        ContentVersion version = new ContentVersion();
        version.ContentLocation = 'S'; 
        version.Title = DOCUMENT_NAME_DEFAULT;
        version.PathOnClient = DOCUMENT_NAME_DEFAULT;
        version.VersionData = content;
        version.FirstPublishLocationId = contractId;    
        
        return version;
    }

    /**
     * createDocuments create brand new contracts or a new version of it if there is already one
     *
     * @param contractIds (Set<Id>): Set with the Contract Ids
     */
    @future(callout=true)
    public static void createDocuments(Set<Id> contractIds) {
        List<Contract> relevantContracts = new List<Contract>();
        Paua_Transaction trans = new Paua_Transaction();

        ContentService contentService = new ContentService();
        CustomerContractService contractService = new CustomerContractService();

        List<ContentVersion> newVersions = new List<ContentVersion>();
        
        List<Contract> allContracts = Paua_SelectorHandler.getSelector(CustomerContractSelectors.Contracts.class)
            .setParameter('idSet', contractIds)
            .query();

        // Create the names for the new documents
        Map<Id,String> mapContractId_Name = new Map<Id,String>();
        for (Contract contract : allContracts) {
            // Only process contracts if status is draft and its country is Spain or Germany short-term
            if (contract.Status == STATUS_DRAFT && (contract.Country__c == 'Spain'|| 
            (contract.Country__c == 'Germany' && 
            (((contract.Property__r.ConditionRef__r.MaximumStayUnitPick__c == 'Months' && 
            contract.Property__r.ConditionRef__r.MaximumStayNumber__c <= 3) || 
            contract.Property__r.ConditionRef__r.MaximumStayNumber__c == null) || 
            ((contract.Property__r.ConditionRef__r.MaximumStayUnitPick__c == 'Days' && 
            contract.Property__r.ConditionRef__r.MaximumStayNumber__c <= 90) || 
            contract.Property__r.ConditionRef__r.MaximumStayNumber__c == null))))) {
                relevantContracts.add(contract);
                mapContractId_Name.put(contract.Id, contractService.getContractTitle(contract));
            }
        }

        if (relevantContracts.isEmpty()) {
            return;
        }

        // Check if there are old versions to create a new one from that
        Map<Id,ContentDocumentLink> mapContractId_ContentDocumentLink = new Map<Id,ContentDocumentLink>();
        for (ContentDocumentLink iContentDocumentLink : [SELECT Id, LinkedEntityId, ContentDocumentId 
                                                        FROM ContentDocumentLink 
                                                        WHERE LinkedEntityId IN :mapContractId_Name.keySet() 
                                                        AND ContentDocument.Title IN :mapContractId_Name.values()]) {
            mapContractId_ContentDocumentLink.put(iContentDocumentLink.LinkedEntityId, iContentDocumentLink);
        }

        for (Contract contract : relevantContracts) {
            ContentVersion version;
            String contractBrandName = mapContractId_Name.get(contract.Id);
            if (mapContractId_ContentDocumentLink.containsKey(contract.Id)) {
                // Create a new document version
                version = contractService.createDocumentVersion(contract.Id, 
                                                                contractBrandName, 
                                                                mapContractId_ContentDocumentLink.get(contract.Id).ContentDocumentId);
            } else {
                // Create the document first version
                version = contractService.createDocumentVersion(contract.Id, contractBrandName);
            }
            newVersions.add(version);
            
            trans.addForInsert(version);
            trans.addForInsert(contentService.createContentDistribution(version), ContentDistribution.ContentVersionId, version);
        }
        
        trans.setPreferredOrder(new List<SObjectType>{ContentVersion.getSObjectType(), ContentDistribution.getSObjectType()});
        trans.commitRecords();

        List<ContentDocumentLink> links = Paua_SelectorHandler.getSelector(ContentSelectors.ContentDocumentLinkByLinkedEntity.class)
            .setParameter('idSet', mapContractId_Name.keySet())
            .query();
        
        for (ContentDocumentLink link: links) {
            link.Visibility = 'AllUsers';
            trans.addForUpdate(link);
        }

        trans.setPreferredOrder(new List<SObjectType>{ContentDocumentLink.getSObjectType()});
        trans.commitRecords();

        System.enqueueJob(new PushToEverSignQueueable(mapContractId_Name.keySet()));
    }

    @future(callout=true)
    public static void deleteOldContract(Set<Id> contractIds) {
        Paua_Transaction trans = new Paua_Transaction();

        List<Contract> contracts = Paua_SelectorHandler.getSelector(CustomerContractSelectors.Contracts.class)
            .setParameter('idSet', contractIds)
            .query();

        List<ContentDocumentLink> links = Paua_SelectorHandler.getSelector(ContentSelectors.ContentDocumentLinkByLinkedEntity.class)
            .setParameter('idSet', contractIds)
            .query();

        trans.setPreferredOrder(new List<SObjectType>{ContentDocumentLink.getSObjectType()});
        trans.commitRecords();
    }

    /**
     * Returns the title of the contract. Expects that the brand name is specified on opportunity.
     * The Schema for constructed name is: "BRAND_NAME CONTRACT_TYPE DOCUMENT_NAME_DEFAULT". 
     * 
     * @param contract  the contract where the brand name must be extracted.
     * @return          title with the brand name and type.
    */
    public String getContractTitle(Contract contract) {
        String contractName = '';

        if(contract.Opportunity__r.BrandAuto__c != null) {
            contractName += contract.Opportunity__r.BrandAuto__c + ' ';
        }

        if(contract.RecordTypeId == RT_ID_MEMBERSHIP) {
            contractName += TYPE_MEMBERSHIP + ' ';
        } else if(contract.RecordTypeId == RT_ID_RENT) {
            contractName += TYPE_RENT + ' ';
        }

        return contractName + CustomerContractService.DOCUMENT_NAME_DEFAULT;
    }

    /**
     * This method filters all contracts that have new Rooms or Apartments in comparison to the old values defined in 
     * oldMap parameter. The old or new value might be null.
     * 
     * @param newList   List of changed new contracts
     * @param oldMap    Map<Key, Value> with Key = Contract Id and Value = Contract Record.
     * @return          List of contracts with changed Room or Apartment
     */
    public List<Contract> getWithNewPieceConsiderNull(List<Contract> newList, Map<Id, Contract> oldMap) {
        List<Contract> relevant = new List<Contract>();
        for (Contract contract : newList) {
            if (contract.Room__c != oldMap.get(contract.Id).Room__c || 
                contract.ApartmentRef__c != oldMap.get(contract.Id).ApartmentRef__c
            ) {
                relevant.add(contract);
            }
        }
        return relevant;
    }

    /**
     * This method updates City__c and Country__c fields data from related Rooms or Apartments on every 
     * contract specified in contracts parameter. This method is used in a after update trigger for contracts to 
     * populate fields from room to contract.
     * 
     * @param   contracts       List of contracts to be updated
     */
    public void syncDataFromPiece(List<Contract> contracts) {
        Set<Id> pieceIds = getPieceIds(contracts);

        List<Room__c> roomsRelatedToContracts = (List<Room__c>) Paua_SelectorHandler.getSelector(CustomerRoomSelectors.RoomsByIds.class)
            .setParameter('idsSet', pieceIds)
            .query();
        
        Map<Id, SObject> contractsToPieces = mapContractsToPieces(contracts, (List<SObject>) roomsRelatedToContracts);

        for(Contract contract : contracts) {
            SObject piece = contractsToPieces.get(contract.Id);
            Boolean hasRoom = contract.Room__c != null;

            if(hasRoom) {
                contract.City__c = ((Room__c) piece).Property__r.City__c;
                contract.Country__c = ((Room__c) piece).Property__r.Country__c;
                contract.Property__c = ((Room__c) piece).Property__c;
                contract.ApartmentRef__c = ((Room__c) piece).ApartmentRef__c;
            } else {
                contract.City__c = null;
                contract.Country__c = null;
                contract.Property__c = null;
                contract.ApartmentRef__c = null;
            }
        }
    }

    private Set<Id> getPieceIds(List<Contract> contracts) {
        Set<Id> ids = new Set<Id>();

        for(Contract contract : contracts) {
            ids.add(getPieceId(contract));
        }

        return ids;
    }

    /**
     * This method voids all other contracts related to the room for every contract from the contracts list.
     * First, rooms with all related contracts are queried. Then all contracts with "Draft" status are identified and voided. 
     * It also resets the Stage of the opportunity for this contract to "Close lost". 
     * 
     * 
     * @param contracts     List of contracts to be updated
     */
    public void voidRelatedContracts(List<Contract> contracts) {
        if(contracts == null || contracts.size() == 0) {
            return;
        }
        Set<Id> roomsIds = getPieceIds(contracts);
        List<Room__c> roomsWithContracts = (List<Room__c>) Paua_SelectorHandler.getSelector(CustomerRoomSelectors.RoomsByIdsWithContracts.class)
                                                                               .setParameter('idsSet', roomsIds)
                                                                               .query();

        List<Contract> contractsToVoid = new List<Contract>();
        for(Room__c room : roomsWithContracts) {
            for(Contract contract : room.Contracts__r) {
                if(contract.Status == STATUS_DRAFT) {
                    contractsToVoid.add(contract);
                }
            }
        }

        voidContractsWithFlow(contractsToVoid);
    }

    /**
     * This method invokes SCF03_VoidContractProcessComplete Flow and passes the contract ids to this flow in a loop. 
     * The flow voids the contract and updates the opportunity stage to 'Close Lost'. 
     * 
     * Important: Flow is not bulkified, therefore each contract is updated in a loop.
     * 
     * @param contracts     List of contracts to be voided
     */
    @TestVisible
    private void voidContractsWithFlow(List<Contract> contracts) {
        Map<String, Object> flowParams = new Map<String, Object>();
        for(Contract contract : contracts) {
            flowParams.put('recordId', contract.Id);
            Flow.Interview.SCF03_VoidContractProcessComplete voidingFlow = new Flow.Interview.SCF03_VoidContractProcessComplete(flowParams);
            //voidingFlow.start();
        }
    }
    
    /**
     * This method gets as input two parameters - contracts and pieces. The method goes through the list of contracts
     * and searches for the corresponding piece. 
     * 
     * @param contracts                     List of contracts to be updated
     * @param piecesRelatedToContracts      List of all pieces that are related to contracts. Can be Room or Apartment.
     */
    private Map<Id, SObject> mapContractsToPieces(List<Contract> contracts, List<SObject> piecesRelatedToContracts) {
        Map<Id, SObject> contractsToPieces = new  Map<Id, SObject>();

        for(Contract contract : contracts) {  
            Id pieceId = getPieceId(contract);

            for(SObject piece : piecesRelatedToContracts) {
                if(piece.Id == pieceId) {
                    contractsToPieces.put(contract.Id, piece);
                    break;
                }
            }
        }

        return contractsToPieces;
    }

    public void createStripePlans(List<Contract> lstContracts){
        Decimal recurringAmount;
        Decimal discountAmount;
        lstContracts = Paua_SelectorHandler.getSelector(CustomerContractSelectors.Contracts.class)
            .setParameter('idSet', new Map<Id,Contract>(lstContracts).keySet())
            .query();

        Map<Id,Contract> mapId_Contract = new Map<Id,Contract>(lstContracts);

        Map<Id, List<ContractItem__c>> mapContract_LstContractItems = new Map<Id, List<ContractItem__c>>();
        
        for (ContractItem__c iContractItem : (List<ContractItem__c>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ContractItemsNotAdditionalItems.class)
            .setParameter('idSet', mapId_Contract.keySet())
            .query()
        ) {

            if (!mapContract_LstContractItems.containsKey(iContractItem.ContractRef__c)) {
                mapContract_LstContractItems.put(iContractItem.ContractRef__c, new List<ContractItem__c>());
            }
            mapContract_LstContractItems.get(iContractItem.ContractRef__c).add(iContractItem);
        }

        for (Id contractId : mapContract_LstContractItems.keySet()) {
            recurringAmount = calculateRecurringContractAmount(mapContract_LstContractItems.get(contractId));

            if (recurringAmount != null && recurringAmount != 0 && !System.isQueueable() && !System.isFuture() && !System.isBatch()) {
                generatePlan_Stripe(contractId, recurringAmount);
            }
        }
    }

    /**
     * calculateRecurringContractAmount Sums the Contract Items amounts for the reccurring and non discount ones
     *
     * @param lstContractItems (List<ContractItem__c>): List with Contract Items
     *
     * @return Decimal: Sum amount
     */
    public Decimal calculateRecurringContractAmount(List<ContractItem__c> lstContractItems){
        Decimal amount = 0;
        for (ContractItem__c iContractItem : lstContractItems) {
            if (iContractItem.ProductRef__r.FrequencyPick__c == FREQ_RECURRING && iContractItem.ProductRef__r.RecordTypeId != PRODUCT_RT_ID_ADD_ITEM) {
                amount += iContractItem.PriceTrig__c;
            }
        }
        return amount;
    }

    public static void generatePlan_Stripe(Id recordId){
        generatePlan_Stripe(recordId, null);
    }

    public static void generatePlan_Stripe(Id recordId, Decimal amount){
        System.enqueueJob(new GenerateStripePlanQueueable(recordId, amount));
    }

    private Map<Id, List<Contract>> mapTriggeringContractsByApartment(
        List<Contract> triggeringContracts, 
        Map<Id, List<Contract>> contractsByApartment
    ) {
        Set<Id> triggeringContractIds = new Map<Id, Contract>(triggeringContracts).keySet();
        Map<Id, List<Contract>> triggeringContractsByApartment = new Map<Id, List<Contract>>();
        for (Id apartmentId: contractsByApartment.keySet()) {
            for (Contract contract: contractsByApartment.get(apartmentId)) {
                if (triggeringContractIds.contains(contract.Id)) {
                    if (! triggeringContractsByApartment.containsKey(apartmentId)) {
                        triggeringContractsByApartment.put(apartmentId, new List<Contract>());
                    }
                    triggeringContractsByApartment.get(apartmentId).add(contract);
                }
            }
        }
        return triggeringContractsByApartment;
    }

    private Map<Contract, List<Contract>> mapContractsForNotificationByDateField(List<Contract> contracts, String fieldName) {
        Map<Id, List<Contract>> contractsByApartment = mapContractsByApartment(contracts);
        Map<Id, List<Contract>> triggeringContractsByApartment = mapTriggeringContractsByApartment(contracts, contractsByApartment);

        Map<Contract, List<Contract>> contractsToNotify = new Map<Contract, List<Contract>>();
        for (Id apartmentId: contractsByApartment.keySet()) {
            List<Contract> triggeringContracts = triggeringContractsByApartment.get(apartmentId);
            if(triggeringContracts != null) {
                for (Contract triggeringContract: triggeringContracts) {
                    if (! contractsToNotify.containsKey(triggeringContract)) {
                        contractsToNotify.put(triggeringContract, new List<Contract>());
                    }
    
                    for (Contract contract: contractsByApartment.get(apartmentId)) {
                        if (contract.Id != triggeringContract.Id && isActiveByDate(contract, (Date)triggeringContract.get(fieldName))) {
                            contractsToNotify.get(triggeringContract).add(contract);
                        }
                    }
                }
            }
        }

        return contractsToNotify;
    }

    /**
     * Sends a notification email (based on the property brand) to all active contracts related to a given apartment 
     * when there is a new contract starting.
     * 
     * @param relevant      Contracts starting.
     */

    public void notifyMoveInContracts(List<Contract> contracts) {
        if (contracts.isEmpty()) {
            return;
        }
        Map<Contract, List<Contract>> contractsToNotify = mapContractsForNotificationByDateField(contracts, 'StartDate');

        System.debug('--- Notifying MoveIn Contracts');
        System.debug(contractsToNotify);
    
        if (! contractsToNotify.isEmpty()) {
            sendMoveInEmails(contractsToNotify);
        }
    } 

    /**
     * Sends a notification email (based on the property brand) to all active contracts related to a given apartment 
     * when there is a new contract ending.
     * 
     * @param relevant      Contracts ending.
     */
    public void notifyMoveOutContracts(List<Contract> contracts) {
        Map<Contract, List<Contract>> contractsToNotify = mapContractsForNotificationByDateField(contracts, 'Contract_End_Date__c');

        System.debug('--- Notifying MoveOut Contracts');
        System.debug(contractsToNotify);
    
        if (! contractsToNotify.isEmpty()) {
            sendMoveOutEmails(contractsToNotify);
        }
    } 

    /**
     * This method takes a map as a parameter, creates email wrappers and passes them to EmailService. The method 
     * checks which email templates qualify using a field on the brand record. After that the wrappers are created for 
     * every related contract and passed to the EmailService.
     * 
     * Difference to the sendMoveOutEmails(...) is that only template names for move-in templates are extracted.
     * 
     * @param contractsMap      Map with Key = Relevant Contract, Value = List of related contracts to the same room that 
     *                          will be notified about move-in or move-out of the relevant contract.
     */
    public void sendMoveInEmails(Map<Contract, List<Contract>> contractsMap) {
        if(contractsMap == null || contractsMap.size() == 0) {
            return;
        }

        Set<String> templateNames = extractTemplateNames(contractsMap.keySet(), true);
        List<EmailTemplate> templates = queryTemplatesByNames(templateNames);
        Map<String, EmailTemplate> nameToTemplateMap = createNameToTemplateMap(templates);
        List<EmailService.EmailServiceParameterWrapper> wrappers = constructEmailWrappers(contractsMap, nameToTemplateMap, true);

        EmailService emailService = new EmailService();
        emailService.sendEmails(wrappers, false);
        System.enqueueJob(new SetEmailDatetimeQueueable(new List<Contract>(contractsMap.keySet()),'MoveInEmailDatetime__c'));
    }

    /**
     * For Description @see public void sendMoveInEmails(Map<Contract, List<Contract>> contractsMap)
     * 
     * Difference to the sendMoveInEmails is that only template names for move-out templates are extracted.
     * 
     * @param contractsMap      Map with Key = Relevant Contract, Value = List of related contracts to the same room that 
     *                          will be notified about move-in or move-out of the relevant contract.
     */
    public void sendMoveOutEmails(Map<Contract, List<Contract>> contractsMap) {
        if(contractsMap == null || contractsMap.keySet().size() == 0) {
            return;
        }

        Set<String> templateNames = extractTemplateNames(contractsMap.keySet(), false);
        List<EmailTemplate> templates = queryTemplatesByNames(templateNames);
        Map<String, EmailTemplate> nameToTemplateMap = createNameToTemplateMap(templates);
        List<EmailService.EmailServiceParameterWrapper> wrappers = constructEmailWrappers(contractsMap, nameToTemplateMap, false);

        EmailService emailService = new EmailService();
        emailService.sendEmails(wrappers, false);
        System.enqueueJob(new SetEmailDatetimeQueueable(new List<Contract>(contractsMap.keySet()),'MoveOutEmailDatetime__c'));
    }

    /**
     * sendMassEmailToCurrentTenants Description
     *
     * @param lstRecipients (List<Contract>): All tenants that will receive the email
     * @param subject (String): Email subject
     * @param htmlBody (String): Email body in HTML
     */
    public void sendMassEmailToCurrentTenants(List<Contract> lstRecipients,  String subject, String htmlBody){
        System.debug('+++ lstRecipients: ' + lstRecipients);

        EmailService emailService = new EmailService();
        String brandSupportEmail = lstRecipients.get(0)?.Room__r?.Property__r?.BrandRef__r?.EmailDomain__c;
        if (String.isBlank(brandSupportEmail)) {
            throw new HandledException('The system can not find the Brand email domain. Please review the all relationships with the Room, the Property and the Brand.');
        } else {
            brandSupportEmail = 'support@' + brandSupportEmail;
        }

        Map<String, OrgWideEmailAddress> mapOrgWideEmailAddress = emailService.getOrgWideAddressesByAddress(new Set<String> {brandSupportEmail});
        
        if (!mapOrgWideEmailAddress.containsKey(brandSupportEmail)) {
            throw new HandledException('We have not found any support email for the selected brand. Please contact your Salesforce admin.');
        }

        List<EmailService.EmailServiceParameterWrapper> lstEmailServiceParameterWrapper = constructEmailWrappers(lstRecipients, subject, htmlBody, mapOrgWideEmailAddress.get(brandSupportEmail).Id);
        
        emailService.sendEmails(lstEmailServiceParameterWrapper, true);
    }


    /**
     * This method creates a list of email wrappers for every related contract in the map. The method is used as part of
     * creation of emails for every contract to be notified.
     * 
     * @param contractsMap       Map with Key = Relevant Contract, Value = List of related contracts to the same room that 
     *                           will be notified about move-in or move-out of the relevant contract.
     * @param nameToTemplateMap  Map with Key = Name of template, Value = EmailTemplate record with the key-name. 
     * @param moveIn             Boolean parameter to identify which template (move-in or move-out) should be used.
     * @return                   List of wrappers for every related contract in the map.
     */
    private List<EmailService.EmailServiceParameterWrapper> constructEmailWrappers(
        Map<Contract, List<Contract>> contractsMap, 
        Map<String, EmailTemplate> nameToTemplateMap, 
        Boolean moveIn
    ) {
        EmailService emailService = new EmailService();
        Map<String, OrgWideEmailAddress> addresses = emailService.getOrgWideAddressesByAddress(new Set<String>{'support@%'});

        List<EmailService.EmailServiceParameterWrapper> wrappers = new List<EmailService.EmailServiceParameterWrapper>();

        for(Contract contract : contractsMap.keySet()) {
            for(Contract relatedContract : contractsMap.get(contract)) {
                if(emailQualifies(contract.Account.PersonEmail, relatedContract.Account.PersonEmail, wrappers)) {
                    String expectedSender = 'support@' + contract.Room__r.Property__r.BrandRef__r.EmailDomain__c;

                    EmailService.EmailServiceParameterWrapper wrapper = new EmailService.EmailServiceParameterWrapper();
    
                    wrapper.targetObjectId = relatedContract.Account.PersonContactId;
                    wrapper.whatId = contract.Id;
                    wrapper.displayName = null; // relatedContract.Opportunity__r.BrandAuto__c;
                    wrapper.useSignature = false;
                    wrapper.bcc = false;
                    wrapper.saveAsActivity = true;
                    wrapper.templateId = getTemplateId(contract, moveIn, nameToTemplateMap);
                    wrapper.toAddresses = new List<String> {relatedContract.Account.PersonEmail};
                    wrapper.orgWideEmailAddressId = addresses.containsKey(expectedSender) ? addresses.get(expectedSender).Id : null;
    
                    wrappers.add(wrapper);
                }
                
            }
        }

        return wrappers;
    }

    private Boolean emailQualifies(
        String mainContractEmail, 
        String email, 
        List<EmailService.EmailServiceParameterWrapper> wrappers
    ) {
        if(mainContractEmail != null && mainContractEmail.equals(email)) {
            return false;
        }

        for(EmailService.EmailServiceParameterWrapper wrapper: wrappers) {
            for(String wrapperEmail: wrapper.toAddresses) {
                if(wrapperEmail.equals(email)) {
                    return false;
                }
            }
        }
        
        return true;
    }

    private List<EmailService.EmailServiceParameterWrapper> constructEmailWrappers(List<Contract> lstTenants, String subject, String htmlBody, Id orgWideEmailAddressId) {
        List<EmailService.EmailServiceParameterWrapper> wrappers = new List<EmailService.EmailServiceParameterWrapper>();

        for(Contract iContract : lstTenants) {
            EmailService.EmailServiceParameterWrapper wrapper = new EmailService.EmailServiceParameterWrapper();
            wrapper.whatId = iContract.Account.PersonContactId;
            wrapper.saveAsActivity = false;
            wrapper.subject = subject;
            wrapper.htmlBody = htmlBody;
            wrapper.toAddresses = new List<String> {iContract.Account.PersonEmail};
            wrapper.orgWideEmailAddressId = orgWideEmailAddressId;
            wrappers.add(wrapper);
        }

        return wrappers;
    }

    private Set<String> extractTemplateNames(Set<Contract> contracts, Boolean moveIn) {
        Set<String> names = new Set<String>();

        for(Contract contract : contracts) {
            if(moveIn) {
                names.add(contract.Room__r.Property__r.BrandRef__r.MoveInTemplateName__c);
            } else {
                names.add(contract.Room__r.Property__r.BrandRef__r.MoveOutTemplateName__c);
            }
        }

        return names;
    }

    private Map<String, EmailTemplate> createNameToTemplateMap(List<EmailTemplate> templates) {
        Map<String, EmailTemplate> nameToTemplate = new Map<String, EmailTemplate>();

        for(EmailTemplate template : templates) {
            nameToTemplate.put(template.Name, template);
        }

        return nameToTemplate;
    }

    private List<EmailTemplate> queryTemplatesByNames(Set<String> names) {
        return (List<EmailTemplate>) Paua_SelectorHandler.getSelector(EmailTemplateSelectors.FromTemplateNames.class)
                                                .setParameter('names', names)
                                                .query();
    }

    private Id getTemplateId(Contract contract, Boolean moveIn, Map<String, EmailTemplate> nameToTemplateMap) {
        String templateName = moveIn ? contract.Room__r.Property__r.BrandRef__r.MoveInTemplateName__c :
                                        contract.Room__r.Property__r.BrandRef__r.MoveOutTemplateName__c;

        return nameToTemplateMap.get(templateName)?.Id;
    }

    /**
     * This method cancels all contracts in eversign. The method is used in trigger to void contracts in eversign that are voided
     * in the salesforce org. API Integration needs a hash value to identify which contract should be deleted. However, this 
     * hash value is deleted from contract record in the flow during voiding process. For this reason we need the parameter 
     * oldContracts to pass this value to API. 
     * 
     * Eversign API also doesn't support bulk update.
     * 
     * @param contracts     Contracts to void in Eversign
     * @param oldContract   Needed to get hash value of updated contract
     */
    public void voidContractsInEversign(List<Contract> contracts, Map<Id, Contract> oldContracts) {
        Set<String> hashes = new Set<String>();

        for(Contract contract : contracts) {
            String contractHash = oldContracts.get(contract.id).EverSign_Doc_Hash__c;
            hashes.add(contractHash);
        }

        if (! hashes.isEmpty()) {
            System.enqueueJob(new ContractsVoidEversignQueueable(hashes));
        }
    } 

    /**
     * This method is used to cancel membership contract for account related to the specified contract. The method is called
     * in IcxStripeInterface where the Subscription of Rent contract is cancelled.
     * 
     * @param contracts      List of contracts with account for which the membership contract needs to be canceled.
     */
    public void cancelMembershipForContract(List<Contract> contracts, Date endDate, Date moveOutDate) {
        Paua_Transaction trans = new Paua_Transaction();
        Set<Id> accountIds = getAccountIdsFromContracts(contracts);
        List<Contract> membershipContracts = (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ByAccountId.class)
                                                                        .setParameter('idSet', accountIds)
                                                                        .query();
        membershipContracts = getWithRecordTypeIds(membershipContracts, new Set<Id> { (Id) RT_ID_MEMBERSHIP});
        membershipContracts = getWithStatuses(membershipContracts, new Set<String> {STATUS_ACTIVATED});

        for(Contract membershipContract : membershipContracts) {
            memberShipContract.Status = STATUS_TERMINATED;
            memberShipContract.Contract_End_Date__c = endDate;
            memberShipContract.Move_out_date__c = moveOutDate; 
        }
        
        trans.addForUpdate(membershipContracts);
        trans.setPreferredOrder(new List<SObjectType> {Contract.getSObjectType()});
        trans.commitRecords();
    }

    private Set<Id> getAccountIdsFromContracts(List<Contract> contracts) {
        Set<Id> accountIds = new Set<Id>();

        for(Contract contract : contracts) {
            accountIds.add(contract.AccountId);
        }

        return accountIds;
    } 

    /**
     * This method is used in Housing confirmation process to generate pdf documents for contracts with start date today
     * and send these documents to the customers in order to ensure fulfillment of legal requirements.
     * 
     * @param contracts     List of contracts for that will be notified. A PDF file will be also attached for every contract.
     */
    public void createHousingConfirmation(List<Contract> contracts) {
        ContentService contentService = new ContentService();
        Paua_Transaction trans = new Paua_Transaction();

        List<ContentVersion> contentVersions = createContentVersionsList(contracts);
        trans.addForInsert(contentVersions);
        trans.setPreferredOrder(new List<SObjectType> {ContentVersion.getSObjectType()});
        trans.commitRecords();

        sendConfirmationEmails(contracts, contentVersions);
    } 

    private List<ContentVersion> createContentVersionsList(List<Contract> contracts) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();

        for(Contract contract : contracts) {
            PageReference housingConfirmationPdf = Page.HousingConfirmationPdf;
            housingConfirmationPdf.getParameters().put('id', contract.Id);

            String fileName = getConfirmationTitle(contract);
            ContentVersion contentVersion = new ContentVersion();

            contentVersion.ContentLocation = 'S';
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.VersionData = Test.isRunningTest() ? Blob.valueOf('TestContract') : housingConfirmationPdf.getContent();
            contentVersion.FirstPublishLocationId = contract.Id;

            contentVersions.add(contentVersion);
        }

        return contentVersions;
    }

    private String getConfirmationTitle(Contract contract){
        return CONFIRMATION_CONTRACT_NAME_DEFAULT + ' ' + contract.Account.Name + PDF_EXTENSION_NAME;
    } 

    private void sendConfirmationEmails(List<Contract> contracts, List<ContentVersion> contentVersions) {
        Map<Id, List<ContentVersion>> versionsByContract = new Map<Id, List<ContentVersion>>();
        for (ContentVersion cv: contentVersions) {
            if (! versionsByContract.containsKey(cv.FirstPublishLocationId)) {
                versionsByContract.put(cv.FirstPublishLocationId, new List<ContentVersion>());
            }
            versionsByContract.get(cv.FirstPublishLocationId).add(cv);
        }
        Map<String, Id> templateIdsByBrand = new Map<String, Id>();
        for (Contract contract: contracts) {
            templateIdsByBrand.put(contract.Room__r.Property__r.BrandRef__r.APINameBrand__c, null);
        }
        templateIdsByBrand = getConfirmationTemplatesByBrand(templateIdsByBrand.keySet());

        EmailService emailService = new EmailService();
        Map<String, OrgWideEmailAddress> addresses = emailService.getOrgWideAddressesByAddress(new Set<String>{'support@%'});
        List<EmailService.EmailServiceParameterWrapper> wrappers = new List<EmailService.EmailServiceParameterWrapper>();

        for(Contract contract : contracts) {
            String expectedSender = 'support@' + contract.Room__r.Property__r.BrandRef__r.EmailDomain__c;
            EmailService.EmailServiceParameterWrapper wrapper = new EmailService.EmailServiceParameterWrapper();

            wrapper.targetObjectId = contract.Account.PersonContactId;
            wrapper.whatId = contract.Id;
            wrapper.displayName = null;
            wrapper.useSignature = false;
            wrapper.bcc = false;
            wrapper.saveAsActivity = true;
            wrapper.templateId = templateIdsByBrand.get(contract.Room__r.Property__r.BrandRef__r.APINameBrand__c);
            wrapper.toAddresses = new List<String> {contract.Account.PersonEmail};
            wrapper.orgWideEmailAddressId = addresses.containsKey(expectedSender) ? addresses.get(expectedSender).Id : null;
            wrapper.emailFileAttachments = createFileAttachmentForContract(contract, versionsByContract.get(contract.Id));

            wrappers.add(wrapper);
        }

        emailService.sendEmails(wrappers, false);
    }

    private List<EmailService.EmailFileAttachmentWrapper> createFileAttachmentForContract(
        Contract contract, 
        List<ContentVersion> contentVersions
    ) {
        List<EmailService.EmailFileAttachmentWrapper> attachments = new List<EmailService.EmailFileAttachmentWrapper>();

        for(ContentVersion version : contentVersions) {
            EmailService.EmailFileAttachmentWrapper attachment = new EmailService.EmailFileAttachmentWrapper();

            attachment.body = version.VersionData;
            attachment.fileName = version.Title;

            attachments.add(attachment);
        }

        return attachments;
    } 

    private Map<String, Id> getConfirmationTemplatesByBrand(Set<String> brands) {
        Set<String> tplNames = new Set<String>();
        for (String brand: brands) {
            tplNames.add(CONFIRMATION_EMAIL_TEMPLATE_NAME + '_' + brand);
        }
        List<EmailTemplate> emailTemplates = (List<EmailTemplate>) Paua_SelectorHandler.getSelector(EmailTemplateSelectors.FromTemplateNames.class)
            .setParameter('names', tplNames)
            .query();
        
        Map<String, Id> templatesByBrand = new Map<String, Id>();
        for (EmailTemplate tpl: emailTemplates) {
            String brand = tpl.Name.substringAfterLast('_');
            templatesByBrand.put(brand, tpl.Id);
        }
        return templatesByBrand;
    }

    public without sharing class SetEmailDatetimeQueueable implements Queueable {
        private List<Contract> contracts;
        private Datetime currentDateTime = Datetime.now();
        private String dateTimeFieldName;

        public SetEmailDatetimeQueueable(List<Contract> contracts, String dateTimeFieldName) {
            this.contracts = contracts;
            this.dateTimeFieldName = dateTimeFieldName;
        }

        public void execute(QueueableContext context) {
            for (Contract contract : contracts) {
                contract.put(dateTimeFieldName, currentDateTime);
            }
            update contracts;
        }
    }
    
    @Future (callout=true)
    public static void cancelStripSub(String contractId, Date cancelDate, Date moveoutDate) {
            Contract con = [SELECT Id, AccountId, Stripe_Subscription_Id__c,Stripe_Account__r.secret_key__c, Cancel_Membership_Contract__c, Move_out_date__c FROM Contract WHERE Id = : contractId];
           
            if(con.Stripe_Subscription_Id__c != null) {
                DateTime cancelDateTime = DateTime.newInstanceGmt(cancelDate.year(), cancelDate.month(), cancelDate.day());
                Long cancelDateTimestamp = cancelDateTime.getTime() / 1000; //pass from milliseconds to seconds
                
                Long DTNTimeStamp = Datetime.now().getTime() / 1000;
                String payload = 'cancel_at=' + cancelDateTimestamp;
                System.debug('subscriptions' + payload);
                StripeService.postToStripe('subscriptions/'+con.Stripe_Subscription_Id__c, payload, con.Stripe_Account__r.secret_key__c);
                if(con.Cancel_Membership_Contract__c != null && con.Cancel_Membership_Contract__c) {
                    CustomerContractService contractService = new CustomerContractService();
                    contractService.cancelMembershipForContract(new List<Contract> {con}, cancelDate, moveoutDate);
                }
            }
    }
}