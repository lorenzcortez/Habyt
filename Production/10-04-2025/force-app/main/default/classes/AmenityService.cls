public without sharing class AmenityService {

    public Map<String, List<Amenity__c>> getByParent(List<SObject> roomsAndAppartments) {
        Map<String, List<Amenity__c>> amenitiesByParent = new Map<String, List<Amenity__c>>();

        Set<Id> roomIdSet = new Set<Id>();
        Set<Id> apartmentIdSet = new Set<Id>();
        Set<Id> fullApartmentIdSet = new Set<Id>();
        Set<Id> propertyIdSet = new Set<Id>();

        for (sObject sobj: roomsAndAppartments) {
            if (sobj.getSObjectType() == RoomService.SObjectType) {
                roomIdSet.add(sobj.Id);
                apartmentIdSet.add((Id) sobj.get('ApartmentRef__c'));
                propertyIdSet.add((Id) sobj.get('Property__c'));
            } else if (sobj.getSObjectType() == ApartmentService.SObjectType){
                apartmentIdSet.add(sobj.Id);
                fullApartmentIdSet.add(sobj.Id);
                propertyIdSet.add((Id) sobj.get('PropertyRef__c'));
            }
        }

        if (! roomIdSet.isEmpty()) {
            for (SObject amenity: Paua_SelectorHandler.getSelector(AmenitySelectors.RoomAmenitiesByRoom.class)
                                    .setParameter('roomIdSet', roomIdSet)
                                    .query()
            ) {
                Id roomId = (Id) amenity.get('RoomRef__c');
                if (! amenitiesByParent.containsKey(roomId)) {
                    amenitiesByParent.put(roomId, new List<Amenity__c>());
                }
                amenitiesByParent.get(roomId).add((Amenity__c) amenity.getSObject('AmenityRef__r'));
            }
        }
        
        if (! apartmentIdSet.isEmpty()) {
            for (SObject amenity: Paua_SelectorHandler.getSelector(AmenitySelectors.ApartmentAmenitiesByApartment.class)
                                    .setParameter('apartmentIdSet', apartmentIdSet)
                                    .query()
            ) {
                Id apartmentId = (Id) amenity.get('ApartmentRef__c');
                if (! amenitiesByParent.containsKey(apartmentId)) {
                    amenitiesByParent.put(apartmentId, new List<Amenity__c>());
                }
                amenitiesByParent.get(apartmentId).add((Amenity__c) amenity.getSObject('AmenityRef__r'));
            }
        }
        
        if (! fullApartmentIdSet.isEmpty()) {
            for (SObject amenity: Paua_SelectorHandler.getSelector(AmenitySelectors.RoomAmenitiesByApartment.class)
                                    .setParameter('apartmentIdSet', fullApartmentIdSet)
                                    .query()
            ) {
                String apartmentId = 'full_' + (Id) amenity.getSObject('RoomRef__r').get('ApartmentRef__c');
                if (! amenitiesByParent.containsKey(apartmentId)) {
                    amenitiesByParent.put(apartmentId, new List<Amenity__c>());
                }
                amenitiesByParent.get(apartmentId).add((Amenity__c) amenity.getSObject('AmenityRef__r'));
            }
        }
        
        if (! propertyIdSet.isEmpty()) {
            for (SObject amenity: Paua_SelectorHandler.getSelector(AmenitySelectors.PropertyAmenitiesByProperty.class)
                                    .setParameter('propertyIdSet', propertyIdSet)
                                    .query()
            ) {
                Id propertyId = (Id) amenity.get('PropertyRef__c');
                if (! amenitiesByParent.containsKey(propertyId)) {
                    amenitiesByParent.put(propertyId, new List<Amenity__c>());
                }
                amenitiesByParent.get(propertyId).add((Amenity__c) amenity.getSObject('AmenityRef__r'));
            }
        }

        return amenitiesByParent;
    }

    public List<Amenity__c> getAllForRecordFromParents(SObject record, Map<String, List<Amenity__c>> amenitiesByParent) {
        List<Amenity__c> amenities = new List<Amenity__c>();

        if (amenitiesByParent.containsKey(record.Id)) { 
            amenities.addAll(amenitiesByParent.get(record.Id)); 
        }

        if (record.getSObjectType() == RoomService.SObjectType) {
            if (amenitiesByParent.containsKey((Id) record.get('ApartmentRef__c'))) {
                amenities.addAll(amenitiesByParent.get((Id) record.get('ApartmentRef__c')));
            }
            if (amenitiesByParent.containsKey((Id) record.get('Property__c'))) {
                amenities.addAll(amenitiesByParent.get((Id) record.get('Property__c')));
            }
        } else {
            if (amenitiesByParent.containsKey('full_' + (Id) record.Id)) {
                amenities.addAll(amenitiesByParent.get('full_' + (Id) record.Id));
            }
            if (amenitiesByParent.containsKey((Id) record.get('PropertyRef__c'))) {
                amenities.addAll(amenitiesByParent.get((Id) record.get('PropertyRef__c')));
            }
        }

        return amenities;
    }
}