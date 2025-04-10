public without sharing class RealEstateOpportunityService {
    public static final String RT_REALESTATE_NAME = 'RealEstate';
    public static final Id RT_REALESTATE_ID = Schema.Opportunity.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get(RT_REALESTATE_NAME).getRecordTypeId();

    public static final String STAGE_CLOSEDWON = 'Closed Won';

    public List<Opportunity> getNewClosedWon(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        List<Opportunity> relevant = new List<Opportunity>();
        for (Opportunity opp: newList) {
            if (opp.RecordTypeId == RT_REALESTATE_ID 
                && opp.StageName == STAGE_CLOSEDWON && (
                    oldMap == null || oldMap.get(opp.Id).StageName != opp.StageName
                )
            ) {
                relevant.add(opp);
            }
        }

        return relevant;
    }

    public List<Opportunity> getWithoutProperty(List<Opportunity> records) {
        Paua_Selector selector = Paua_SelectorHandler.getSelector(PropertySelectors.AllProperties.class);
        Set<Id> withProperty = new Set<Id>();
        for (Property__c prop: (List<Property__c>) selector.query()) {
            withProperty.add(prop.Opportunity__c);
        }

        List<Opportunity> relevant = new List<Opportunity>();

        for (Opportunity record: records) {
            if (! withProperty.contains(record.Id)) {
                relevant.add(record);
            }
        }

        return relevant;
    }

    public void createPropertiesForOpportunities(List<Opportunity> records) {
        if (records == null || records.isEmpty()) {
            return;
        }

        PropertyService propertyService = new PropertyService();

        Set<Id> oppIds = new Set<Id>();
        for (Opportunity record: records) {
            oppIds.add(record.Id);
        }

        Paua_Selector selector = Paua_SelectorHandler.getSelector(ContentSelectors.ContentDocumentLinkByLinkedEntity.class)
            .setParameter('idSet', oppIds);

        Map<Id, List<ContentDocumentLink>> documentsByOppId = new Map<Id, List<ContentDocumentLink>>();
        for (ContentDocumentLink cdl: (List<ContentDocumentLink>) selector.query()) {
            if (! documentsByOppId.containsKey(cdl.LinkedEntityId)) {
                documentsByOppId.put(cdl.LinkedEntityId, new List<ContentDocumentLink>());
            }
            documentsByOppId.get(cdl.LinkedEntityId).add(cdl);
        }

        Paua_Transaction trans = new Paua_Transaction();
        
        for (Opportunity opp: records) {

            Decimal roomCount = opp.NumberOfBeds__c;
            Decimal apartmentCount = opp.NumberofApartments__c;
            ID propertyId;

            Property__c property = propertyService.createFromOpportunity(opp);

            try {
                insert property;        
                propertyId = property.Id;
            } catch(DmlException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
            }

            if (propertyId!=null &&  apartmentCount>0 && roomCount>=apartmentCount) {

                //Apartment__c apartment;
                List<Apartment__c> apartments = new List<Apartment__c>();
                List<Apartment__c> insertedApartments = new List<Apartment__c>();
                List<Decimal> rooms = calculateRoomCounts(roomCount, apartmentCount);
                Decimal roomCounts = rooms[0];
                Decimal extraRoomCount = rooms[1];

                for (Integer a=1; a <= apartmentCount ; a++) {
                    Apartment__c apartment = new Apartment__c(
                        Name = property.ApartmentNamePart__c + '-' + String.valueOf(a).leftPad(3,'0'),
                        PropertyRef__c = propertyId,
                        Apartment_Number__c = a,
                        CurrencyIsoCode = property.CurrencyIsoCode
                        );
                    try {
                        apartments.add(apartment);    
                        
                        
                    } catch(DmlException e) {
                        System.debug('An unexpected error has occurred: ' + e.getMessage());
                    }
                }

                insert apartments;

                insertedApartments = [SELECT Id, Name FROM Apartment__c WHERE PropertyRef__c =:propertyId ORDER BY Apartment_Number__c ASC];

                List<Room__c> RoomsList = new List<Room__c>();
                if(insertedApartments.size() > 0){
                    for(Apartment__c apartment: insertedApartments){
                        Boolean addExtraRoom = extraRoomCount > 0;
                        Decimal roomsToCreate = addExtraRoom ? roomCounts + 1 : roomCounts; 

                        if (addExtraRoom) {
                            extraRoomCount = extraRoomCount - 1;
                        }

                        List<Room__c> nRooms = new List<Room__c>(createRooms(roomsToCreate, apartment, property));
                        
                        for (Room__c room : nRooms) {
                            RoomsList.add(room);
                        }
                }
                try {

                    insert RoomsList;  
                    
                } catch(DmlException e) {
                    System.debug('An unexpected error has occurred: ' + e.getMessage());
                }
                }

            }

            if (documentsByOppId.containsKey(opp.Id)) {
                for (ContentDocumentLink cdl: documentsByOppId.get(opp.Id)) {
                    ContentDocumentLink cloned = cdl.clone();
                    cloned.Visibility = 'AllUsers';
                    trans.addForInsert(cloned, ContentDocumentLink.LinkedEntityId, property);
                    trans.addForDelete(cdl);
                }
            }
        }

        trans.setPreferredOrder(new List<SObjectType>{
            Property__c.getSObjectType(), 
            ContentDocumentLink.getSObjectType()
        });

        trans.commitRecords();
    }
    public List<Decimal> calculateRoomCounts(Decimal roomCount, Decimal apartmentCount){
            List<Decimal> rooms = new List<Decimal>();
            Decimal rNum = roomCount/apartmentCount;
            Decimal rrNum = rNum - rNum.setScale(0, RoundingMode.DOWN);
            Decimal roomCounts = rNum - rrNum;
            rooms.add(roomCounts);
            Decimal extraRoomCount = rrNum*apartmentCount;
            rooms.add(extraRoomCount);
            return rooms;
        }

    public List<Room__c> createRooms(Decimal roomCounts, Apartment__c apartment, Property__c property){
        List<Room__c> rooms = new List<Room__c>();

        for (Decimal r = 1; r <= roomCounts; r++) {
            Room__c room = new Room__c(
            Name = apartment.Name + '-' + String.valueOf(r).leftPad(3,'0'),
            Property__c = property.Id,
            ApartmentRef__c = apartment.Id,
            Room_Number__c = r,
            Price__c = property.PricePerRoom__c,
            Status__c = 'Offboarded',
            CurrencyIsoCode = property.currencyIsoCode
            );

            rooms.add(room);
        }
        return rooms;

    }
}