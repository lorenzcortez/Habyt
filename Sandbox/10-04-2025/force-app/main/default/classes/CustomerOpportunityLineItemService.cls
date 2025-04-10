public without sharing class CustomerOpportunityLineItemService{
    /* Product names */
    public static final String PRODUCT_RENT_NAME = 'Rent';
    public static final String PRODUCT_DEPOSIT_NAME = 'Deposit';
    public static final String PRODUCT_MEMBERSHIP_FEE_NAME = 'Membership Fee';
    /* Record Type names */
    public static final String RT_MEMBERSHIP_FEE_NAME = 'MembershipFee';
    /* Record Type Ids */
    public static final String RT_MEMBERSHIP_FEE_ID = Product2.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(RT_MEMBERSHIP_FEE_NAME).getRecordTypeId();

    public List<OpportunityLineItem> createDefaultCustomerItems(List<Opportunity> records){
        List<OpportunityLineItem> lstOppLineItems = new List<OpportunityLineItem>();
        List<Product2> lstDefaultProducts = (List<Product2>) Paua_SelectorHandler.getSelector(Product2Selectors.DefaultProducts.class)
            .setParameter('pricebookId', records.get(0).Pricebook2Id)
            .query();

        Set<Id> setRoomIds = new Set<Id>();
        for (Opportunity iOpp : records) {
            setRoomIds.add(iOpp.Room__c);
        }

        List<Room__c> lstRoomsWithConditions = (List<Room__c>) Paua_SelectorHandler.getSelector(CustomerRoomSelectors.RoomsWithPropertyAndConditions.class)
            .setParameter('idsSet', setRoomIds)
            .query();

        Map<Id,Room__c> mapRoomWithConditions = new Map<Id,Room__c>(lstRoomsWithConditions);
        Set<Id> oppPriceBookErrorTrig = new Set<Id>();
        Room__c room;
        for (Opportunity record : records){
            for (Product2 iProduct : lstDefaultProducts) {
                if (iProduct.PricebookEntries.isEmpty() ) {
                    oppPriceBookErrorTrig.add(record.Id);
                    continue;    
                }
                
                if (iProduct.RecordTypeId != RT_MEMBERSHIP_FEE_ID || record.Account.MembershipStatusPick__c != PersonAccountService.MEMBERSHIP_STATUS_MEMBER){
                    room = mapRoomWithConditions.containsKey(record.Room__c) ? mapRoomWithConditions.get(record.Room__c) : null;

                    Boolean hasDeposit = record.DepositAmountAuto__c != null && record.DepositAmountAuto__c > 0;
                    Boolean productIsDeposit = iProduct.Name == PRODUCT_DEPOSIT_NAME;
                    if(!productIsDeposit || hasDeposit) {
                        lstOppLineItems.add(createDefaultProduct(record, iProduct, room));
                    }
                }
            }
        }

        if (!oppPriceBookErrorTrig.isEmpty()) {
            CustomerOpportunityService.setProductPriceBookError(oppPriceBookErrorTrig);
        }

        return lstOppLineItems;
    }


    public OpportunityLineItem createDefaultProduct(Opportunity opp, Product2 prod, Room__c room){
        List<PricebookEntry> lstPriceBookEntries = prod.PricebookEntries;
        PricebookEntry priceBookEntry = lstPriceBookEntries.get(0);
        for (PricebookEntry pbe : lstPriceBookEntries) {
            if (pbe.currencyIsoCode == opp.currencyIsoCode) {
                priceBookEntry = pbe;
            }
        }

        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.Id;
        oli.Product2Id = prod.Id;
        oli.RoomRef__c = room.Id;
        oli.ApartmentRef__c = opp.ApartmentRef__c;
        oli.Quantity = 1;
        oli.PricebookEntryId = priceBookEntry.Id;

        if (prod.Name == PRODUCT_RENT_NAME) {
            oli.UnitPrice = opp.PiecePriceAuto__c;
        } else if (prod.Name == PRODUCT_DEPOSIT_NAME) {
            oli.UnitPrice = opp.DepositAmountAuto__c;
        } else if (prod.Name == PRODUCT_MEMBERSHIP_FEE_NAME) {
            oli.UnitPrice = room?.Property__r?.ConditionRef__r?.MembershipFee__c != null ? room.Property__r.ConditionRef__r.MembershipFee__c : 0;
        }

        return oli;
    }


    public List<OpportunityLineItem> getDefaultOldProducts(Set<Id> setOppIds, Id pricebook2Id){
        
        List<Product2> lstDefaultProducts =  (List<Product2>) Paua_SelectorHandler.getSelector(Product2Selectors.DefaultProducts.class)
                                                                                    .setParameter('pricebookId', pricebook2Id)
                                                                                    .query();
        
        List<OpportunityLineItem> lstDefaultOldProducts = (List<OpportunityLineItem>) Paua_SelectorHandler.getSelector(CustomerOpportunityLineItemSelectors.FromProducts.class)
                                                                                                            .setParameter('setOppIds',setOppIds)
                                                                                                            .setParameter('setProduct2Ids', new Map<Id,Product2>(lstDefaultProducts).keySet())
                                                                                                            .query();
        return lstDefaultOldProducts;
    }

}