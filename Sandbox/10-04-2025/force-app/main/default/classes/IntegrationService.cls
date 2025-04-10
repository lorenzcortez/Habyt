public without sharing class IntegrationService {
    public static final String STAGE_LAUNCHED = 'Launched';
    public static final String STAGE_PRE_SALES = 'Pre-sales';

    public static final String STATUS_ONLINE = 'Online';
    public static final String STATUS_RESERVED = 'Reserved';
    public static final String STATUS_OFFBOARDING = 'Offboarding';
    

    public IntegrationModels.UserResponsePayload upsertUser(IntegrationModels.UserRequestPayload input) {
        input.validate();

        Account account = input.toAccount();
        PersonAccountService service = new PersonAccountService();
        account = service.validateExisting(account);

        Paua_Transaction trans = new Paua_Transaction();
        trans.addForUpsert(account);

        trans.setPreferredOrder(new List<SObjectType>{PersonAccountService.SObjectType});
        trans.commitRecords();

        account = (Account) Paua_SelectorHandler.getSelector(PersonAccountSelectors.FromEmail.class)
            .setParameter('emails', new Set<String>{account.PersonEmail})
            .query()[0];

        return new IntegrationModels.UserResponsePayload(account);
    }

    public List<SObject> getPiece(String referenceId) {
        Paua_Selector.QueryClauses clauses = new Paua_Selector.QueryClauses();
        clauses.limitClause = 1;
        
        List<SObject> entries = Paua_SelectorHandler.getSelector(IntegrationSelectors.RoomByDynamicInput.class)
            .setParameter('referenceId', new List<String>{referenceId})
            .query(clauses);

        /* if (entries == null || entries.isEmpty()) {
            entries = Paua_SelectorHandler.getSelector(IntegrationSelectors.ApartmentByDynamicInput.class)
                .setParameter('referenceId', new List<String>{referenceId})
                .query(clauses);
        } */

        return entries;
    }

    public IntegrationModels.ContractResponsePayload insertContract(IntegrationModels.ContractRequestPayload input) {
        return insertContract(input, 'API');
    }
    
    public IntegrationModels.ContractResponsePayload insertContract(IntegrationModels.ContractRequestPayload input, String source) {
        input.validate();

        Date startDate = IntegrationModels.parseDate(input.startOfContract);
        Date endDate = IntegrationModels.parseDate(input.plannedEndOfContract);

        IntegrationModels.BadRequestException e;

        List<SObject> accounts = Paua_SelectorHandler.getSelector(PersonAccountSelectors.FromUserId.class)
            .setParameter('userIds', new Set<String>{String.valueOf(input.userId).leftPad(8, '0')})
            .query();
        
        if (accounts == null || accounts.isEmpty()) {
            e = new IntegrationModels.BadRequestException();
            throw e.init('Could not find userId ' + input.userId);
        }
        Account account = (Account) accounts[0];
        if (account.CustomerStatusPick__c == PersonAccountService.STATUS_CUSTOMER_BLOCKED) {
            e = new IntegrationModels.BadRequestException();
            throw e.init('UserId ' + input.userId + ' is not allowed to book through the api.');
        }

        List<SObject> pieces = getPiece(input.referenceId);

        if (pieces == null || pieces.isEmpty()) {
            e = new IntegrationModels.BadRequestException();
            throw e.init('Could not find referenceId ' + input.referenceId);
        }

        SObject piece = pieces[0];
        Boolean bookable = (Boolean) piece.get('IsBookableAuto__c');
        Date earliestStart = ((Datetime) piece.get('EarliestStartOfContractAuto__c'))?.date();
        Date latestStart = ((Datetime) piece.get('LatestStartOfContractAuto__c'))?.date();
        if (! (bookable || earliestStart > startDate || latestStart < startDate )) {
            e = new IntegrationModels.BadRequestException();
            throw e.init('The piece is not bookable at the planned start');
        }

        String pieceStatus = (String) piece?.get('Status__c');
        String apartmentStatus = (String) piece?.getSObject('ApartmentRef__r')?.get('Status__c');
        if(pieceStatus != STATUS_ONLINE || apartmentStatus != STATUS_ONLINE ) {
            e = new IntegrationModels.BadRequestException();
            throw e.init('The piece is not bookable at this time');
        }
        
        CustomerOpportunityService service = new CustomerOpportunityService();

        Opportunity opp = service.createForAccountAndPiece(account, piece, startDate, endDate, source);
        
        Paua_Transaction trans = new Paua_Transaction();
        trans.addForInsert(opp);
        trans.setPreferredOrder(new List<SObjectType>{CustomerOpportunityService.SObjectType});
        trans.commitRecords();

        opp = (Opportunity) Paua_SelectorHandler.getSelector(CustomerOpportunitySelectors.FromId.class)
            .setParameter('id', opp.Id)
            .query()[0];

        return new IntegrationModels.ContractResponsePayload(opp);
    }

    private Set<Id> extractContentRelevantIds (List<SObject> records) {
        Set<Id> relevantIds = new Set<Id>();

        for (SObject record: records) {
            relevantIds.add(record.Id);
            if (record.getSObjectType() == RoomService.SObjectType) {
                relevantIds.add((Id)record.get('ApartmentRef__c'));
                relevantIds.add((Id)record.get('Property__c'));
            } else if (record.getSObjectType() == ApartmentService.SObjectType) {
                relevantIds.add((Id)record.get('PropertyRef__c'));
                for (SObject room: record.getSObjects('Rooms__r')) {
                    relevantIds.add(room.Id);
                }
            }
        }

        return relevantIds;
    }

    private Map<String, List<DragDropToCloud__Cloud_Documents__c>> getAllContentForEntry(SObject entry, Map<Id, List<DragDropToCloud__Cloud_Documents__c>> contentByEntity) {
        Map<String, List<DragDropToCloud__Cloud_Documents__c>> distros = new Map<String, List<DragDropToCloud__Cloud_Documents__c>>();

        String type = entry.getSObjectType() == RoomService.SObjectType ? IntegrationModels.TYPE_ROOM : IntegrationModels.TYPE_UNIT;
        if (contentByEntity.containsKey(entry.Id)) {
            distros.put(type, contentByEntity.get(entry.Id));
        }

        if (type == IntegrationModels.TYPE_ROOM) {
            if (contentByEntity.containsKey((Id) entry.get('ApartmentRef__c'))) {
                distros.put(IntegrationModels.TYPE_UNIT, contentByEntity.get((Id) entry.get('ApartmentRef__c')));
            }
            if (contentByEntity.containsKey((Id) entry.get('Property__c'))) {
                distros.put(IntegrationModels.TYPE_BUILDING, contentByEntity.get((Id) entry.get('Property__c')));
            }
        } else {
            distros.put(IntegrationModels.TYPE_ROOM, new List<DragDropToCloud__Cloud_Documents__c>());
            if (entry.getSObjects('Rooms__r') != null) {
                for (Room__c room: (List<Room__c>)entry.getSObjects('Rooms__r')) {
                    if (contentByEntity.containsKey(room.Id)) {
                        distros.get(IntegrationModels.TYPE_ROOM).addAll(contentByEntity.get(room.Id));
                    }
                }
            }
            if (contentByEntity.containsKey((Id) entry.get('PropertyRef__c'))) {
                distros.put(IntegrationModels.TYPE_BUILDING, contentByEntity.get((Id) entry.get('PropertyRef__c')));
            }
        }
    
        return distros;
    }

    private Map<Id, List<DragDropToCloud__Cloud_Documents__c>> getS3FilesByPiece(Set<Id> pieceIds) {
        Map<Id, List<DragDropToCloud__Cloud_Documents__c>> results = new Map<Id, List<DragDropToCloud__Cloud_Documents__c>>();

        if (pieceIds != null && !pieceIds.isEmpty()) {
            Paua_Selector.QueryClauses qc = new Paua_Selector.QueryClauses();
            qc.orderByClause = 'Weight__c ASC NULLS LAST';
            
            List<DragDropToCloud__Cloud_Documents__c> allFiles = Paua_SelectorHandler.getSelector(IntegrationSelectors.S3DocumentsByPiece.class)
                .setParameter('pieceIds', pieceIds)
                .query(qc);
            
            List<String> relevantFields = new List<String>{'ApartmentRef__c', 'PropertyRef__c', 'RoomRef__c'};

            for (DragDropToCloud__Cloud_Documents__c file: allFiles) {
                for (String fName: relevantFields) {
                    if (file.get(fName) != null) {
                        Id pieceId = (Id) file.get(fName);
                        if (! results.containsKey(pieceId)) {
                            results.put(pieceId, new List<DragDropToCloud__Cloud_Documents__c>());
                        }
                        results.get(pieceId).add(file);
                    }
                }
            }
        }

        return results;
    }

    public IntegrationModels.RoomResponsePayload retrieveRooms(IntegrationModels.RoomRequestPayload input) {
        input.validate();

        IntegrationModels.RoomResponsePayload response = new IntegrationModels.RoomResponsePayload();
        response.totalElements = 0;
        response.totalPages = 0;

        List<sObject> results = new List<sObject>();
        Paua_Selector selector = IntegrationSelectors.getSelectorForRequest(input);
        Paua_Selector.QueryClauses queryClauses = IntegrationSelectors.getClausesForRequest(input);

        response.initFromInput(input, selector.count());

        if (response.totalElements > 0) {
            results.addAll(selector.query(queryClauses));

            AmenityService amenityService = new AmenityService();
            DescriptionService descriptionService = new DescriptionService();
            PropertyService propertyService = new PropertyService();

            Set<Id> documentEntityIds = extractContentRelevantIds(results);
            Map<Id, List<DragDropToCloud__Cloud_Documents__c>> contentByEntity = getS3FilesByPiece(documentEntityIds);

            Map<String, List<Amenity__c>> amenitiesByParent = amenityService.getByParent(results);
            Map<String, List<Description__c>> descriptionsByParent = descriptionService.getByParent(results);

            List<Fee__c> fees = Paua_SelectorHandler.getSelector(FeeSelectors.Fees.class).query();

            for (SObject entry: results) {
                List<Amenity__c> amenities = amenityService.getAllForRecordFromParents(entry, amenitiesByParent);
                List<Description__c> descriptions = descriptionService.getAllForRecordFromParents(entry, descriptionsByParent);
                Condition__c condition = propertyService.getCondition(propertyService.getFromSObject(entry));
                
                IntegrationModels.Room result = response.add(entry)
                    .setAmenities(amenities)
                    .setDescriptions(descriptions)
                    .setFees(fees)
                    .setCondition(condition, entry);
                
                Map<String, List<DragDropToCloud__Cloud_Documents__c>> entryImages = getAllContentForEntry(entry, contentByEntity);
                for (String type: entryImages.keySet()) {
                    result.addImages(type, entryImages.get(type));
                }
            }
        }

        return response.finalize();
    }

    @TestVisible
    private Decimal calculateFirstRent(SObject entry, Date startOfContract) {
        Decimal fullPrice = (Decimal) entry.get('NetPrice__c');

        Integer daysInMonth = Date.daysInMonth(startOfContract.year(), startOfContract.month());
        Integer outstandingDays = startOfContract.daysBetween(startOfContract.addMonths(1).toStartOfMonth());

        return outstandingDays * (fullPrice / daysInMonth);
    }

    public IntegrationModels.CalculationFirstMonthResponsePayload calculateFirstRent(IntegrationModels.CalculationFirstMonthRequestPayload input) {
        input.validate();
        
        List<SObject> entries = getPiece(input.referenceId);

        if (entries == null || entries.isEmpty()) {
            IntegrationModels.BadRequestException e = new IntegrationModels.BadRequestException();
            throw e.init('Could not find referenceId ' + input.referenceId);
        }

        Decimal firstMonthPrice = calculateFirstRent(entries[0], input.startOfContract);
        return new IntegrationModels.CalculationFirstMonthResponsePayload(firstMonthPrice.setScale(4), (String) entries[0].get('CurrencyIsoCode'));
    }

    public Map<String, List<Neighbourhood__c>> getDistrictsByCity() {
        System.debug('getting districts');
        Map<String, List<Neighbourhood__c>> results = new Map<String, List<Neighbourhood__c>>();
        List<Neighbourhood__c> allNeighbourhoods = (List<Neighbourhood__c>) Paua_SelectorHandler.getSelector(IntegrationSelectors.AllDistricts.class)
            .query();
        System.debug(allNeighbourhoods);

        for (Neighbourhood__c hood: allNeighbourhoods) {
            System.debug(hood);
            if (String.isNotBlank(hood.CityPick__c)) {  // We only want to display districts where we have at least 1 property
                                                                               // and is related to a city.
                if (! results.containsKey(hood.CityPick__c)) {
                    results.put(hood.CityPick__c, new List<Neighbourhood__c>());
                }
                results.get(hood.CityPick__c).add(hood);
            }
        }
        
        return results;
    }

    public List<String> getCitiesByBrand(String brandApi) {
        List<Property__c> brandProperty = Paua_SelectorHandler.getSelector(PropertySelectors.PropertiesByBrandApiName.class)
            .setParameter('brandSet', new Set<String>{brandApi})
            .query();
        
        Set<String> citySet = new Set<String>();
        for (Property__c property: brandProperty) {
            if (String.isNotBlank(property.City__c)) {
                citySet.add(property.City__c);
            }
        }

        return new List<String>(citySet);
    }

    public List<Phone_Country_Code__mdt> getPhoneCodes() {
        List<Phone_Country_Code__mdt> phoneCodes = (List<Phone_Country_Code__mdt>) 
            Paua_SelectorHandler.getSelector(PhoneMetadataSelectors.AllPhoneCodes.class).query();

        return phoneCodes;
    }
}