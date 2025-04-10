public without sharing class CustomerOpportunityService{
    public static final Schema.SObjectType SObjectType = Opportunity.SObjectType;

    public static final String ACCOUNT_MEMBER = 'Member';
    public static final String BILLING_ENTITY_TYPE_HOLDING = 'Holding';
    public static final String STAGE_EVALUATION = 'Evaluation';
    public static final String STAGE_CONTRACT_OUT = 'Contract Out';
    /* Record Type names */
    public static final String RECORDTYPE_NAME = 'Sale';
    public static final String PRODUCT_RT_NAME_RENT = 'Rent';
    public static final String PRODUCT_RT_NAME_MEMBERSHIP = 'MembershipFee';
    /* Record Type Ids */
    public static final Id RECORDTYPE_ID = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(RECORDTYPE_NAME).getRecordTypeId();
    public static final String PRODUCT_RT_ID_RENT = Contract.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(PRODUCT_RT_NAME_RENT).getRecordTypeId();
    public static final String PRODUCT_RT_ID_MEMBERSHIP = Contract.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(PRODUCT_RT_NAME_MEMBERSHIP).getRecordTypeId();

    public static final Set<String> PRIORITY_SOURCES = new Set<String>{'API', 'Housing Anywhere', 'Nestpick', 'Uniplaces'};

    public Opportunity createForAccountAndPiece(Account account, SObject piece, Date plannedStart, Date plannedEnd, String source) {
        Boolean isRoom = piece.getSObjectType() == RoomService.SObjectType;
        Boolean isUnit = piece.getSObjectType() == ApartmentService.SObjectType;

        if (! (isRoom || isUnit)) {
            throw new IllegalArgumentException('Piece must be Room or Apartment');
        }

        Opportunity opp = new Opportunity(
            RecordTypeId = RECORDTYPE_ID,
            Name = account.Name + ' - ' + piece.get('Name'),
            AccountId = account.Id,
            Room__c = isRoom ? piece.Id : null,
            ApartmentRef__c = isUnit ? piece.Id : null,
            Start_Date__c = plannedStart,
            PlannedEndofContract__c = plannedEnd,
            OpportunitySourcePick__c = source,
            LeadSource = source,
            StageName = STAGE_EVALUATION,
            CloseDate = plannedStart,
            CurrencyIsoCode = (String) piece.get('CurrencyIsoCode')
        );

        return opp;
    }

    public List<Opportunity> getWithNewPiece(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        List<Opportunity> relevant = new List<Opportunity>();
        for (Opportunity opp: newList) {
            if ((opp.Room__c != null && (oldMap == null || opp.Room__c != oldMap.get(opp.Id).Room__c)) 
                || (opp.ApartmentRef__c != null && (oldMap == null || opp.ApartmentRef__c != oldMap.get(opp.Id).ApartmentRef__c))
            ){
                relevant.add(opp);
            }
        }
        return relevant;
    }

    /** 
     * This method filters all contracts that have new Rooms or Apartments in comparison to the old values defined in 
     * oldMap parameter. The old or new value might be null. The difference from the "getWithNewPiece" method is that 
     * the changes from null values or to null values are also considered.
     * 
     * @param newList   List of changed new contracts
     * @param oldMap    Map<Key, Value> with Key = Contract Id and Value = Contract Record.
     * @return          List of contracts with changed Room or Apartment
     * @author          Igor Kudryk <igor.kudryk@empaua.com>
     */
    public List<Opportunity> getWithNewPieceConsiderNull(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        List<Opportunity> relevant = new List<Opportunity>();
        for (Opportunity opp: newList) {
            if (
                opp.Room__c != oldMap.get(opp.Id).Room__c || 
                opp.ApartmentRef__c != oldMap.get(opp.Id).ApartmentRef__c
            ) {
                relevant.add(opp);
            }
        }
        return relevant;
    }

    public List<Opportunity> getWithPriorityBooking(List<Opportunity> newList) {
        List<Opportunity> relevant = new List<Opportunity>();

        for (Opportunity opp: newList) {
            if (PRIORITY_SOURCES.contains(opp.OpportunitySourcePick__c)) {
                relevant.add(opp);
            }
        }

        return relevant;
    }

    public List<Opportunity> checkOldProducts(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        List<Opportunity> relevant = new List<Opportunity>();
        for (Opportunity opp : newList){
            if ((opp.Room__c != oldMap.get(opp.Id).Room__c && oldMap.get(opp.Id).Room__c != null) || (opp.ApartmentRef__c != oldMap.get(opp.Id).ApartmentRef__c && oldMap.get(opp.Id).ApartmentRef__c != null)){
                relevant.add(opp);
            }
        }
        return relevant;
    }

    public void syncDefaultOpportunityLineItems(List<Opportunity> records, List<Opportunity> lstOppsToDeleteProducts){
        Paua_Transaction trans = new Paua_Transaction();
        CustomerOpportunityLineItemService customerOpportunityLineItemService = new CustomerOpportunityLineItemService();

        // Old Opportunity Line Items created from default products that needs to be deleted
        List<OpportunityLineItem> lstProductsToBeDeleted;
        if (lstOppsToDeleteProducts != null && !lstOppsToDeleteProducts.isEmpty()){
            lstProductsToBeDeleted = customerOpportunityLineItemService.getDefaultOldProducts(new Map<Id, Opportunity>(lstOppsToDeleteProducts).keySet(), lstOppsToDeleteProducts.get(0).Pricebook2Id);
            if (!lstProductsToBeDeleted.isEmpty()){
                trans.addForDelete(lstProductsToBeDeleted);
            }
        }

        if (records != null && !records.isEmpty()){
            trans.addForInsert(customerOpportunityLineItemService.createDefaultCustomerItems(records));
        }

        trans.setPreferredOrder(new List<SObjectType>{OpportunityLineItem.getSObjectType()});
        trans.commitRecords();
    }

    public void setStandardPricebook(List<Opportunity> newList){
        Pricebook2 standardPricebook = (Pricebook2)Paua_SelectorHandler.getSelector(Pricebook2Selectors.StandardPricebook.class)
                                                                        .query()
                                                                        .get(0);

        for (Opportunity iOpp : newList){
            if (iOpp.Pricebook2Id == null && iOpp.RecordTypeId == RECORDTYPE_ID){
                iOpp.Pricebook2Id = standardPricebook.Id;
            }
        }
    }

    @Future
    public static void setProductPriceBookError(Set<Id> setOppIds){
        List<Opportunity> lstOpps = new List<Opportunity>();

        for (Id iOppId : setOppIds){
            lstOpps.add(new Opportunity(Id = iOppId, IsProductPriceBookErrorTrig__c = true));
        }

        update lstOpps;
    }

    public Set<Id> getOppsReadyForContracts(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        Set<Id> relevant = new Set<Id>();
        for (Opportunity opp : newList){
            if (opp.StageName == STAGE_CONTRACT_OUT && oldMap.get(opp.Id).StageName != STAGE_CONTRACT_OUT){
                relevant.add(opp.Id);
            }
        }
        return relevant;
    }

    public void removePieceAvailability(List<Opportunity> records) {
        if (records != null && !records.isEmpty()){
            Paua_Transaction trans = new Paua_Transaction();

            Boolean hasRoom = false;
            Boolean hasApartment = false;

            for (Opportunity opp: records) {
                if (opp.Room__c != null) {
                    trans.addForUpdate(new Room__c(Id = opp.Room__c, AvailableDateTrig__c = null));
                    hasRoom = true;
                } else if (opp.ApartmentRef__c != null) {
                    trans.addForUpdate(new Apartment__c(Id = opp.ApartmentRef__c, AvailableDateTrig__c = null));
                    hasApartment = true;
                }
            }

            List<SObjectType> order = new List<SObjectType>();
            if (hasRoom) {
                order.add(Room__c.getSObjectType());
            }
            if (hasApartment) {
                order.add(Apartment__c.getSObjectType());
            }
            
            if (!order.isEmpty()) {
                trans.setPreferredOrder(order);
                trans.commitRecords();
            }
        }
    }

    /**
     * The method takes a list of opportunities and queries for related rooms/apartments. 
     * After that, the City__c and Country__c fields of the opportunities are populated from related Room or Apartment.
     * 
     * @param opportunities     List of opportunities to be updated
     */
    public void syncDataFromPiece(List<Opportunity> opportunities) {
        Set<Id> pieceIds = getPieceIds(opportunities);

        List<Room__c> roomsRelatedToOpps = (List<Room__c>) Paua_SelectorHandler.getSelector(CustomerRoomSelectors.RoomsByIds.class)
                                                                            .setParameter('idsSet', pieceIds)
                                                                            .query();
                                                                            
        Map<Id, SObject> oppsToPieces = mapOppsToPieces(opportunities, (List<SObject>) roomsRelatedToOpps);
        for(Opportunity opp : opportunities) {
            SObject piece = oppsToPieces.get(opp.Id);
            Boolean hasRoom = opp.Room__c != null;
            Boolean hasApartment = opp.ApartmentRef__c != null;

            if(hasRoom) {
                opp.City__c = ((Room__c) piece).Property__r.City__c;
                opp.Country__c = ((Room__c) piece).Property__r.Country__c;
                opp.Property__c = ((Room__c) piece).Property__c;
                opp.ApartmentRef__c = ((Room__c) piece).ApartmentRef__c;
            } else {
                if( !Test.isRunningTest() ){
                    opp.City__c = null;
                    opp.Country__c = null;
                    opp.Property__c = null;
                    opp.ApartmentRef__c = null;
                }
            }
        }
    }

    private Set<Id> getPieceIds(List<Opportunity> opportunities) {
        Set<Id> ids = new Set<Id>();

        for(Opportunity opp : opportunities) {
            ids.add(getPieceId(opp));
        }

        return ids;
    }

    private Id getPieceId(Opportunity opp) {
        return opp.Room__c != null ? opp.Room__c : opp.ApartmentRef__c;
    }

    /**
     * This method gets as input two parameters - opportunity and pieces. The method goes through the first list 
     * and searches for the corresponding piece. 
     * 
     * @param opportunities         List of opportunities to be updated
     * @param piecesRelatedToOpps   List of all pieces that are related to opportunities. Can be Room or Apartment.
     * @return                      Map<Key, Value> with Key = Opportunity Id and Value = piece id.
     * @author                      Igor Kudryk <igor.kudryk@empaua.com>
     */
    private Map<Id, SObject> mapOppsToPieces(List<Opportunity> opportunities, List<SObject> piecesRelatedToOpps) {
        Map<Id, SObject> oppsToPieces = new  Map<Id, SObject>();

        for(Opportunity opp : opportunities) {
            Id pieceId = getPieceId(opp);
            
            for(SObject piece : piecesRelatedToOpps) {
                if(piece.Id == pieceId) {
                    oppsToPieces.put(opp.Id, piece);
                    break;
                }
            }
        }

        return oppsToPieces;
    }
}