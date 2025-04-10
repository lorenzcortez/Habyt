public class IntegrationSelectors {
    private static Map<String, String> getSalesforceFieldByInput(String type){
        String propertyRef = type == IntegrationModels.TYPE_ROOM ? 'Property__r.' : 'PropertyRef__r.';
        String apartmentRef = type == IntegrationModels.TYPE_ROOM ? 'ApartmentRef__r.' : '';

        Map<String, String> mapping = new Map<String, String>{
            'referenceid' => 'Name',
            'countrycode' =>  propertyRef + 'Country__c',
            'brand' =>  propertyRef + 'BrandRef__r.Name',
            'brandApi' =>  propertyRef + 'BrandRef__r.APINameBrand__c',
            'streetaddress' =>  propertyRef + 'Street__c',
            'postalcode' =>  propertyRef + 'Postal_Code__c',
            'district' =>  propertyRef + 'NeighbourhoodRef__r.Name',
            'latitude' =>  propertyRef + 'PropertyLocation__latitude__s',
            'longitude' =>  propertyRef + 'PropertyLocation__longitude__s',
            'size' =>  'SizeNumber__c',
            'availabledate' =>  'EarliestStartofContractAuto__c',
            'bedrooms' =>  apartmentRef + 'Bedroom__c',
            'latestupdate' =>  'LastModifiedDate'
        };

        return mapping;
    }

    private static String getTypeForRequest(IntegrationModels.RoomRequestPayload input) {
        String type = IntegrationModels.TYPE_ROOM;
        if (input.type != null && input.type.contains(IntegrationModels.TYPE_UNIT)) {
            type = IntegrationModels.TYPE_UNIT;
        }

        return type;
    }

    public static Paua_Selector.QueryClauses getClausesForRequest(IntegrationModels.RoomRequestPayload input) {
        Paua_Selector.QueryClauses qc = new Paua_Selector.QueryClauses();

        if (input.size != null) {
            qc.limitClause = input.size;
        }

        if (input.page != null) {
            qc.offsetClause = input.size * input.page;
        }

        if (input.sortX != null && !input.sortX.isEmpty()) {
            List<String> sortParams = new List<String>();

            Map<String, String> fieldMappings = getSalesforceFieldByInput(getTypeForRequest(input));

            for (String entry: input.sortX) {
                String[] parts = entry.toLowerCase().split(',');
                String fieldName = parts[0];

                if ( fieldMappings.containsKey(fieldName)) {
                    fieldName = fieldMappings.get(fieldName);

                    String sortOrder = parts.size() > 0 ? parts[1] : '';
                    String nullValues = 'nulls first';
                    
                    if (sortOrder == 'desc') {
                        nullValues = 'nulls last';
                    }
                    
                    sortParams.add(fieldname + ' ' + sortOrder + ' ' + nullValues);
                }
            }
            qc.orderByClause = String.join(sortParams, ', ');
        }

        return qc;
    }

    public static Paua_Selector getSelectorForRequest(IntegrationModels.RoomRequestPayload input) {
        String type = getTypeForRequest(input);
        Paua_Selector selector = Paua_SelectorHandler.getSelector(IntegrationSelectors.RoomByDynamicInput.class);
        if (type == IntegrationModels.TYPE_UNIT) {
            input.shareType = new List<String>{IntegrationModels.SHARE_PRIVATE_APARTMENT};
        } else if (input.shareType != null){
            input.shareType = new List<String>{IntegrationModels.SHARE_PRIVATE_ROOM, IntegrationModels.SHARE_SHARED_ROOM};
        }

        if (input.referenceId != null && ! input.referenceId.isEmpty()) {
            selector.setParameter('referenceId', input.referenceId);
        }
        if (input.notReferenceId != null && ! input.notReferenceId.isEmpty()) {
            selector.setParameter('notReferenceId', input.notReferenceId);
        }
        if (input.countryCode != null && ! input.countryCode.isEmpty()) {
            selector.setParameter('countryCode', input.countryCode);
        }
        if (input.brand != null && ! input.brand.isEmpty()) {
            selector.setParameter('brand', input.brand);
        }
        if (input.brandApi != null && ! input.brandApi.isEmpty()) {
            selector.setParameter('brandApi', input.brandApi);
        }
        if (input.shareType != null && ! input.shareType.isEmpty()) {
            selector.setParameter('shareType', input.shareType);
        }

        if (String.isNotBlank(input.streetAddress)) {
            selector.setParameter('streetAddress', '%' + input.streetAddress + '%');
        }
        /* if (String.isNotBlank(input.streetNumber)) {
            selector.setParameter('streetNumber', input.streetNumber);
        } */
        if (String.isNotBlank(input.postalCode)) {
            selector.setParameter('postalCode', input.postalCode);
        }
        if (input.city != null && ! input.city.isEmpty()) {
            selector.setParameter('city', input.city);
        }
        if (input.district != null && ! input.district.isEmpty()) {
            selector.setParameter('district', input.district);
        }

        if (input.latitudeFrom != null) {
            selector.setParameter('latitudeFrom', input.latitudeFrom);
        }
        if (input.latitudeTo != null) {
            selector.setParameter('latitudeTo', input.latitudeTo);
        }
        if (input.longitudeFrom != null) {
            selector.setParameter('longitudeFrom', input.longitudeFrom);
        }
        if (input.longitudeTo != null) {
            selector.setParameter('longitudeTo', input.longitudeTo);
        }

        if (input.sizeFrom != null) {
            selector.setParameter('sizeFrom', input.sizeFrom);
        }
        if (input.sizeTo != null) {
            selector.setParameter('sizeTo', input.sizeTo);
        }

        if (input.bedroomsFrom != null) {
            selector.setParameter('bedroomsFrom', input.bedroomsFrom);
        }
        if (input.bedroomsTo != null) {
            selector.setParameter('bedroomsTo', input.bedroomsTo);
        }

        if (input.availableDateFrom != null) {
            selector.setParameter('availableDateFrom', input.availableDateFrom);
        }
        if (input.availableDateTo != null) {
            selector.setParameter('availableDateTo', input.availableDateTo);
        }

        if (input.latestUpdateFrom != null) {
            selector.setParameter('latestUpdateFrom', input.latestUpdateFrom);
        }
        if (input.latestUpdateTo != null) {
            selector.setParameter('latestUpdateTo', input.latestUpdateTo);
        }
    
        if (input.bookable != null) {
            selector.setParameter('bookable', input.bookable);
        }
    
        return selector;
    }

    public virtual class RoomByDynamicInput extends RoomSelectors.RoomsWithApartmentAndProperty {
        protected override String getWhereClause() {
            List<String> criteria = new List<String>{
                'Property__r.Stage__c IN (\'' + 
                    IntegrationService.STAGE_LAUNCHED  
                    + '\', \'' +
                    IntegrationService.STAGE_PRE_SALES
                + '\')',
                    // changes has been made for pre sales. develop by Holz, deployed by Sithija 07/10/2022
                'IsExcludeFromAPI__c = false',
                'Status__c IN (\'' + 
                    IntegrationService.STATUS_ONLINE +  
                '\')',
                'ApartmentRef__r.Status__c IN (\'' + 
                    IntegrationService.STATUS_ONLINE + 
                '\')'
            };

            if (queryParameters.containsKey('referenceId')) {
                criteria.add('Name IN :referenceId');
            }
            if (queryParameters.containsKey('notReferenceId')) {
                criteria.add('(NOT Name IN :notReferenceId)');
            }
            if (queryParameters.containsKey('countryCode')) {
                criteria.add('Property__r.Country__c IN :countryCode');
            }
            if (queryParameters.containsKey('brand')) {
                criteria.add('Property__r.BrandRef__r.Name IN :brand');
            }
            if (queryParameters.containsKey('brandApi')) {
                criteria.add('Property__r.BrandRef__r.APINameBrand__c IN :brandApi');
            }


            if (queryParameters.containsKey('shareType')) {
                criteria.add('TypePick__c IN :shareType');
            }

            if (queryParameters.containsKey('streetAddress')) {
                criteria.add('Property__r.Street__c LIKE :streetAddress');
            }
            /* if (queryParameters.containsKey('streetNumber')) {
                criteria.add('Property__r.StreetNumber__c = :streetNumber');
            } */
            if (queryParameters.containsKey('postalCode')) {
                criteria.add('Property__r.Postal_Code__c = :postalCode');
            }
            if (queryParameters.containsKey('city')) {
                criteria.add('Property__r.City__c IN :city');
            }
            if (queryParameters.containsKey('district')) {
                criteria.add('Property__r.NeighbourhoodRef__r.Name IN :district');
            }

            if (queryParameters.containsKey('latitudeFrom')) {
                criteria.add('Property__r.PropertyLocation__latitude__s >= :latitudeFrom');
            }
            if (queryParameters.containsKey('latitudeTo')) {
                criteria.add('Property__r.PropertyLocation__latitude__s <= :latitudeTo');
            }
            if (queryParameters.containsKey('longitudeFrom')) {
                criteria.add('Property__r.PropertyLocation__longitude__s >= :longitudeFrom');
            }
            if (queryParameters.containsKey('longitudeTo')) {
                criteria.add('Property__r.PropertyLocation__longitude__s <= :longitudeTo');
            }

            // Amenities must be filtered manually after querying
            // Rent must be filtered manually after querying

            if (queryParameters.containsKey('sizeFrom')) {
                criteria.add('SizeNumber__c >= :sizeFrom');
            }
            if (queryParameters.containsKey('sizeTo')) {
                criteria.add('SizeNumber__c <= :sizeTo');
            }

            if (queryParameters.containsKey('bedroomsFrom')) {
                criteria.add('ApartmentRef__r.Bedroom__c >= :bedroomsFrom');
            }
            if (queryParameters.containsKey('bedroomsTo')) {
                criteria.add('ApartmentRef__r.Bedroom__c <= :bedroomsTo');
            }

            if (queryParameters.containsKey('availableDateFrom')) {
                criteria.add('EarliestStartofContractAuto__c >= :availableDateFrom');
            }
            if (queryParameters.containsKey('availableDateTo')) {
                criteria.add('EarliestStartofContractAuto__c <= :availableDateTo');
            }

            if (queryParameters.containsKey('latestUpdateFrom')) {
                criteria.add('LastModifiedDate >= :latestUpdateFrom');
            }
            if (queryParameters.containsKey('latestUpdateTo')) {
                criteria.add('LastModifiedDate <= :latestUpdateTo');
            }

            if (queryParameters.containsKey('bookable')) {
                criteria.add('IsBookableAuto__c = :bookable');
            }

            return String.join(criteria, ' AND ');
        }

        public override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            List<String> referenceId;
            if (queryParameters.containsKey('referenceId')) {
                referenceId = (List<String>)queryParameters.get('referenceId');
            }
            List<String> notReferenceId;
            if (queryParameters.containsKey('notReferenceId')) {
                notReferenceId = (List<String>)queryParameters.get('notReferenceId');
            }
            List<String> countryCode;
            if (queryParameters.containsKey('countryCode')) {
                countryCode = (List<String>)queryParameters.get('countryCode');
            }
            List<String> brand;
            if (queryParameters.containsKey('brand')) {
                brand = (List<String>)queryParameters.get('brand');
            }
            List<String> brandApi;
            if (queryParameters.containsKey('brandApi')) {
                brandApi = (List<String>)queryParameters.get('brandApi');
            }
            List<String> shareType;
            if (queryParameters.containsKey('shareType')) {
                shareType = (List<String>)queryParameters.get('shareType');
            }

            String streetAddress;
            if (queryParameters.containsKey('streetAddress')) {
                streetAddress = (String) queryParameters.get('streetAddress');
            }
            /* String streetNumber;
                if (queryParameters.containsKey('streetNumber')) {
                    streetNumber = (String) queryParameters.get('streetNumber');
                }
            } */
            String postalCode;
            if (queryParameters.containsKey('postalCode')) {
                postalCode = (String) queryParameters.get('postalCode');
            }
            List<String> city;
            if (queryParameters.containsKey('city')) {
                city = (List<String>) queryParameters.get('city');
            }
            List<String> district;
            if (queryParameters.containsKey('district')) {
                district = (List<String>) queryParameters.get('district');
            }

            Decimal latitudeFrom;
            if (queryParameters.containsKey('latitudeFrom')) {
                latitudeFrom = (Decimal) queryParameters.get('latitudeFrom');
            }
            Decimal latitudeTo;
            if (queryParameters.containsKey('latitudeTo')) {
                latitudeTo = (Decimal) queryParameters.get('latitudeTo');
            }
            Decimal longitudeFrom;
            if (queryParameters.containsKey('longitudeFrom')) {
                longitudeFrom = (Decimal) queryParameters.get('longitudeFrom');
            }
            Decimal longitudeTo;
            if (queryParameters.containsKey('longitudeTo')) {
                longitudeTo = (Decimal) queryParameters.get('longitudeTo');
            }

            Decimal sizeFrom;
            if (queryParameters.containsKey('sizeFrom')) {
                sizeFrom = (Decimal) queryParameters.get('sizeFrom');
            }
            Decimal sizeTo;
            if (queryParameters.containsKey('sizeTo')) {
                sizeTo = (Decimal) queryParameters.get('sizeTo');
            }

            Decimal bedroomsFrom;
            if (queryParameters.containsKey('bedroomsFrom')) {
                bedroomsFrom = (Decimal) queryParameters.get('bedroomsFrom');
            }
            Decimal bedroomsTo;
            if (queryParameters.containsKey('bedroomsTo')) {
                bedroomsTo = (Decimal) queryParameters.get('bedroomsTo');
            }

            Date availableDateFrom;
            if (queryParameters.containsKey('availableDateFrom')) {
                availableDateFrom = (Date) queryParameters.get('availableDateFrom');
            }
            Date availableDateTo;
            if (queryParameters.containsKey('availableDateTo')) {
                availableDateTo = (Date) queryParameters.get('availableDateTo');
            }

            Datetime latestUpdateFrom;
            if (queryParameters.containsKey('latestUpdateFrom')) {
                latestUpdateFrom = (Datetime) queryParameters.get('latestUpdateFrom');
            }
            Datetime latestUpdateTo;
            if (queryParameters.containsKey('latestUpdateTo')) {
                latestUpdateTo = (Datetime) queryParameters.get('latestUpdateTo');
            }

            Boolean bookable;
            if (queryParameters.containsKey('bookable')) {
                bookable = (Boolean) queryParameters.get('bookable');
            }

            return Database.query(query);
        }

        public override Integer count(Paua_Selector.QueryClauses clauses) {
            String query = buildCountFromClauses(clauses);
            
            List<String> referenceId;
            if (queryParameters.containsKey('referenceId')) {
                referenceId = (List<String>)queryParameters.get('referenceId');
            }
            List<String> notReferenceId;
            if (queryParameters.containsKey('notReferenceId')) {
                notReferenceId = (List<String>)queryParameters.get('notReferenceId');
            }
            List<String> countryCode;
            if (queryParameters.containsKey('countryCode')) {
                countryCode = (List<String>)queryParameters.get('countryCode');
            }
            List<String> brand;
            if (queryParameters.containsKey('brand')) {
                brand = (List<String>)queryParameters.get('brand');
            }
            List<String> brandApi;
            if (queryParameters.containsKey('brandApi')) {
                brandApi = (List<String>)queryParameters.get('brandApi');
            }
            List<String> shareType;
            if (queryParameters.containsKey('shareType')) {
                shareType = (List<String>)queryParameters.get('shareType');
            }

            String streetAddress;
            if (queryParameters.containsKey('streetAddress')) {
                streetAddress = (String) queryParameters.get('streetAddress');
            }
            /* String streetNumber;
                if (queryParameters.containsKey('streetNumber')) {
                    streetNumber = (String) queryParameters.get('streetNumber');
                }
            } */
            String postalCode;
            if (queryParameters.containsKey('postalCode')) {
                postalCode = (String) queryParameters.get('postalCode');
            }
            List<String> city;
            if (queryParameters.containsKey('city')) {
                city = (List<String>) queryParameters.get('city');
            }
            List<String> district;
            if (queryParameters.containsKey('district')) {
                district = (List<String>) queryParameters.get('district');
            }

            Decimal latitudeFrom;
            if (queryParameters.containsKey('latitudeFrom')) {
                latitudeFrom = (Decimal) queryParameters.get('latitudeFrom');
            }
            Decimal latitudeTo;
            if (queryParameters.containsKey('latitudeTo')) {
                latitudeTo = (Decimal) queryParameters.get('latitudeTo');
            }
            Decimal longitudeFrom;
            if (queryParameters.containsKey('longitudeFrom')) {
                longitudeFrom = (Decimal) queryParameters.get('longitudeFrom');
            }
            Decimal longitudeTo;
            if (queryParameters.containsKey('longitudeTo')) {
                longitudeTo = (Decimal) queryParameters.get('longitudeTo');
            }

            Decimal sizeFrom;
            if (queryParameters.containsKey('sizeFrom')) {
                sizeFrom = (Decimal) queryParameters.get('sizeFrom');
            }
            Decimal sizeTo;
            if (queryParameters.containsKey('sizeTo')) {
                sizeTo = (Decimal) queryParameters.get('sizeTo');
            }

            Decimal bedroomsFrom;
            if (queryParameters.containsKey('bedroomsFrom')) {
                bedroomsFrom = (Decimal) queryParameters.get('bedroomsFrom');
            }
            Decimal bedroomsTo;
            if (queryParameters.containsKey('bedroomsTo')) {
                bedroomsTo = (Decimal) queryParameters.get('bedroomsTo');
            }

            Date availableDateFrom;
            if (queryParameters.containsKey('availableDateFrom')) {
                availableDateFrom = (Date) queryParameters.get('availableDateFrom');
            }
            Date availableDateTo;
            if (queryParameters.containsKey('availableDateTo')) {
                availableDateTo = (Date) queryParameters.get('availableDateTo');
            }

            Datetime latestUpdateFrom;
            if (queryParameters.containsKey('latestUpdateFrom')) {
                latestUpdateFrom = (Datetime) queryParameters.get('latestUpdateFrom');
            }
            Datetime latestUpdateTo;
            if (queryParameters.containsKey('latestUpdateTo')) {
                latestUpdateTo = (Datetime) queryParameters.get('latestUpdateTo');
            }

            Boolean bookable;
            if (queryParameters.containsKey('bookable')) {
                bookable = (Boolean) queryParameters.get('bookable');
            }
            
            return Database.countQuery(query);
        }
    }

    
    // TODO: Remove this selector as it is not really needed.
    /* public virtual class ApartmentByDynamicInput extends ApartmentSelectors.ApartmentsWithProperty {
        protected override String getWhereClause() {
            List<String> criteria = new List<String>{
                'PropertyRef__r.Stage__c = \''+ IntegrationService.STAGE_LAUNCHED +'\'',
                'Status__c IN (\'' + 
                    IntegrationService.STATUS_ONLINE + '\', \'' + 
                    IntegrationService.STATUS_RESERVED + '\', \'' + 
                    IntegrationService.STATUS_OFFBOARDING + 
                '\')'
            };

            if (queryParameters.containsKey('referenceId')) {
                criteria.add('Name IN :referenceId');
            }
            if (queryParameters.containsKey('notReferenceId')) {
                criteria.add('(NOT Name IN :notReferenceId)');
            }
            if (queryParameters.containsKey('countryCode')) {
                criteria.add('PropertyRef__r.Country__c IN :countryCode');
            }
            if (queryParameters.containsKey('brand')) {
                criteria.add('PropertyRef__r.BrandRef__r.Name IN :brand');
            }
            if (queryParameters.containsKey('brandApi')) {
                criteria.add('PropertyRef__r.BrandRef__r.APINameBrand__c IN :brandApi');
            }


            if (queryParameters.containsKey('streetAddress')) {
                criteria.add('PropertyRef__r.Street__c LIKE :streetAddress');
            }
            /* if (queryParameters.containsKey('streetNumber')) {
                criteria.add('PropertyRef__r.StreetNumber__c = :streetNumber');
            } * /
            if (queryParameters.containsKey('postalCode')) {
                criteria.add('PropertyRef__r.Postal_Code__c = :postalCode');
            }
            if (queryParameters.containsKey('city')) {
                criteria.add('PropertyRef__r.City__c IN :city');
            }
            if (queryParameters.containsKey('district')) {
                criteria.add('PropertyRef__r.NeighbourhoodRef__r.Name IN :district');
            }

            if (queryParameters.containsKey('latitudeFrom')) {
                criteria.add('PropertyRef__r.PropertyLocation__latitude__s >= :latitudeFrom');
            }
            if (queryParameters.containsKey('latitudeTo')) {
                criteria.add('PropertyRef__r.PropertyLocation__latitude__s <= :latitudeTo');
            }
            if (queryParameters.containsKey('longitudeFrom')) {
                criteria.add('PropertyRef__r.PropertyLocation__longitude__s >= :longitudeFrom');
            }
            if (queryParameters.containsKey('longitudeTo')) {
                criteria.add('PropertyRef__r.PropertyLocation__longitude__s <= :longitudeTo');
            }

            // Amenities must be filtered manually after querying
            // Rent must be filtered manually after querying

            if (queryParameters.containsKey('sizeFrom')) {
                criteria.add('SizeNumber__c >= :sizeFrom');
            }
            if (queryParameters.containsKey('sizeTo')) {
                criteria.add('SizeNumber__c <= :sizeTo');
            }

            if (queryParameters.containsKey('bedroomsFrom')) {
                criteria.add('Bedroom__c >= :bedroomsFrom');
            }
            if (queryParameters.containsKey('bedroomsTo')) {
                criteria.add('Bedroom__c <= :bedroomsTo');
            }

            if (queryParameters.containsKey('availableDateFrom')) {
                criteria.add('EarliestStartofContractAuto__c >= :availableDateFrom');
            }
            if (queryParameters.containsKey('availableDateTo')) {
                criteria.add('EarliestStartofContractAuto__c <= :availableDateTo');
            }

            if (queryParameters.containsKey('latestUpdateFrom')) {
                criteria.add('LastModifiedDate >= :latestUpdateFrom');
            }
            if (queryParameters.containsKey('latestUpdateTo')) {
                criteria.add('LastModifiedDate <= :latestUpdateTo');
            }

            if (queryParameters.containsKey('bookable')) {
                criteria.add('IsBookableAuto__c = :bookable');
            }

            return String.join(criteria, ' AND ');
        }

        public override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            List<String> referenceId;
            if (queryParameters.containsKey('referenceId')) {
                referenceId = (List<String>)queryParameters.get('referenceId');
            }
            List<String> notReferenceId;
            if (queryParameters.containsKey('notReferenceId')) {
                notReferenceId = (List<String>)queryParameters.get('notReferenceId');
            }
            List<String> countryCode;
            if (queryParameters.containsKey('countryCode')) {
                countryCode = (List<String>)queryParameters.get('countryCode');
            }
            List<String> brand;
            if (queryParameters.containsKey('brand')) {
                brand = (List<String>)queryParameters.get('brand');
            }
            List<String> brandApi;
            if (queryParameters.containsKey('brandApi')) {
                brandApi = (List<String>)queryParameters.get('brandApi');
            }

            String streetAddress;
            if (queryParameters.containsKey('streetAddress')) {
                streetAddress = (String) queryParameters.get('streetAddress');
            }
            /* String streetNumber;
                if (queryParameters.containsKey('streetNumber')) {
                    streetNumber = (String) queryParameters.get('streetNumber');
                }
            } * /
            String postalCode;
            if (queryParameters.containsKey('postalCode')) {
                postalCode = (String) queryParameters.get('postalCode');
            }
            List<String> city;
            if (queryParameters.containsKey('city')) {
                city = (List<String>) queryParameters.get('city');
            }
            List<String> district;
            if (queryParameters.containsKey('district')) {
                district = (List<String>) queryParameters.get('district');
            }

            Decimal latitudeFrom;
            if (queryParameters.containsKey('latitudeFrom')) {
                latitudeFrom = (Decimal) queryParameters.get('latitudeFrom');
            }
            Decimal latitudeTo;
            if (queryParameters.containsKey('latitudeTo')) {
                latitudeTo = (Decimal) queryParameters.get('latitudeTo');
            }
            Decimal longitudeFrom;
            if (queryParameters.containsKey('longitudeFrom')) {
                longitudeFrom = (Decimal) queryParameters.get('longitudeFrom');
            }
            Decimal longitudeTo;
            if (queryParameters.containsKey('longitudeTo')) {
                longitudeTo = (Decimal) queryParameters.get('longitudeTo');
            }

            Decimal sizeFrom;
            if (queryParameters.containsKey('sizeFrom')) {
                sizeFrom = (Decimal) queryParameters.get('sizeFrom');
            }
            Decimal sizeTo;
            if (queryParameters.containsKey('sizeTo')) {
                sizeTo = (Decimal) queryParameters.get('sizeTo');
            }

            Decimal bedroomsFrom;
            if (queryParameters.containsKey('bedroomsFrom')) {
                bedroomsFrom = (Decimal) queryParameters.get('bedroomsFrom');
            }
            Decimal bedroomsTo;
            if (queryParameters.containsKey('bedroomsTo')) {
                bedroomsTo = (Decimal) queryParameters.get('bedroomsTo');
            }

            Date availableDateFrom;
            if (queryParameters.containsKey('availableDateFrom')) {
                availableDateFrom = (Date) queryParameters.get('availableDateFrom');
            }
            Date availableDateTo;
            if (queryParameters.containsKey('availableDateTo')) {
                availableDateTo = (Date) queryParameters.get('availableDateTo');
            }

            Datetime latestUpdateFrom;
            if (queryParameters.containsKey('latestUpdateFrom')) {
                latestUpdateFrom = (Datetime) queryParameters.get('latestUpdateFrom');
            }
            Datetime latestUpdateTo;
            if (queryParameters.containsKey('latestUpdateTo')) {
                latestUpdateTo = (Datetime) queryParameters.get('latestUpdateTo');
            }

            Boolean bookable;
            if (queryParameters.containsKey('bookable')) {
                bookable = (Boolean) queryParameters.get('bookable');
            }

            return Database.query(query);
        }

        public override Integer count(Paua_Selector.QueryClauses clauses) {
            String query = buildCountFromClauses(clauses);
    
            List<String> referenceId;
            if (queryParameters.containsKey('referenceId')) {
                referenceId = (List<String>)queryParameters.get('referenceId');
            }
            List<String> notReferenceId;
            if (queryParameters.containsKey('notReferenceId')) {
                notReferenceId = (List<String>)queryParameters.get('notReferenceId');
            }
            List<String> countryCode;
            if (queryParameters.containsKey('countryCode')) {
                countryCode = (List<String>)queryParameters.get('countryCode');
            }
            List<String> brand;
            if (queryParameters.containsKey('brand')) {
                brand = (List<String>)queryParameters.get('brand');
            }
            List<String> brandApi;
            if (queryParameters.containsKey('brandApi')) {
                brandApi = (List<String>)queryParameters.get('brandApi');
            }


            String streetAddress;
            if (queryParameters.containsKey('streetAddress')) {
                streetAddress = (String) queryParameters.get('streetAddress');
            }
            /* String streetNumber;
                if (queryParameters.containsKey('streetNumber')) {
                    streetNumber = (String) queryParameters.get('streetNumber');
                }
            } * /
            String postalCode;
            if (queryParameters.containsKey('postalCode')) {
                postalCode = (String) queryParameters.get('postalCode');
            }
            List<String> city;
            if (queryParameters.containsKey('city')) {
                city = (List<String>) queryParameters.get('city');
            }
            List<String> district;
            if (queryParameters.containsKey('district')) {
                district = (List<String>) queryParameters.get('district');
            }

            Decimal latitudeFrom;
            if (queryParameters.containsKey('latitudeFrom')) {
                latitudeFrom = (Decimal) queryParameters.get('latitudeFrom');
            }
            Decimal latitudeTo;
            if (queryParameters.containsKey('latitudeTo')) {
                latitudeTo = (Decimal) queryParameters.get('latitudeTo');
            }
            Decimal longitudeFrom;
            if (queryParameters.containsKey('longitudeFrom')) {
                longitudeFrom = (Decimal) queryParameters.get('longitudeFrom');
            }
            Decimal longitudeTo;
            if (queryParameters.containsKey('longitudeTo')) {
                longitudeTo = (Decimal) queryParameters.get('longitudeTo');
            }

            Decimal sizeFrom;
            if (queryParameters.containsKey('sizeFrom')) {
                sizeFrom = (Decimal) queryParameters.get('sizeFrom');
            }
            Decimal sizeTo;
            if (queryParameters.containsKey('sizeTo')) {
                sizeTo = (Decimal) queryParameters.get('sizeTo');
            }

            Decimal bedroomsFrom;
            if (queryParameters.containsKey('bedroomsFrom')) {
                bedroomsFrom = (Decimal) queryParameters.get('bedroomsFrom');
            }
            Decimal bedroomsTo;
            if (queryParameters.containsKey('bedroomsTo')) {
                bedroomsTo = (Decimal) queryParameters.get('bedroomsTo');
            }

            Date availableDateFrom;
            if (queryParameters.containsKey('availableDateFrom')) {
                availableDateFrom = (Date) queryParameters.get('availableDateFrom');
            }
            Date availableDateTo;
            if (queryParameters.containsKey('availableDateTo')) {
                availableDateTo = (Date) queryParameters.get('availableDateTo');
            }

            Datetime latestUpdateFrom;
            if (queryParameters.containsKey('latestUpdateFrom')) {
                latestUpdateFrom = (Datetime) queryParameters.get('latestUpdateFrom');
            }
            Datetime latestUpdateTo;
            if (queryParameters.containsKey('latestUpdateTo')) {
                latestUpdateTo = (Datetime) queryParameters.get('latestUpdateTo');
            }

            Boolean bookable;
            if (queryParameters.containsKey('bookable')) {
                bookable = (Boolean) queryParameters.get('bookable');
            }
            
            return Database.countQuery(query);
        }
    } */

    public virtual class AllDistricts extends Paua_Selector {
        protected override String getBaseQuery() {
            return 'SELECT Id, Name, CityPick__c ' + 
                'FROM Neighbourhood__c';
        }
    }

    public virtual class S3DocumentsByPiece extends Paua_Selector {
        protected override String getBaseQuery() {
            return 'SELECT S3PublicUrlAuto__c, DragDropToCloud__File_Size_Numeric__c, ApartmentRef__c, PropertyRef__c, RoomRef__c, Weight__c ' +
                'FROM DragDropToCloud__Cloud_Documents__c';
        }

        protected override String getWhereClause() {
            return 'ApartmentRef__c IN :pieceIds OR PropertyRef__c IN :pieceIds OR RoomRef__c IN :pieceIds';
        }

        public override List<SObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> pieceIds = (Set<Id>) queryParameters.get('pieceIds');

            return Database.query(query);
        }
    }
}