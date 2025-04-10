public without sharing class DescriptionService {
    public Map<String, List<Description__c>> getByParent(List<SObject> roomsAndAppartments) {
        Map<String, List<Description__c>> descriptionsByParent = new Map<String, List<Description__c>>();

        Set<Id> roomIdSet = new Set<Id>();
        Set<Id> apartmentIdSet = new Set<Id>();
        Set<Id> propertyIdSet = new Set<Id>();
        Set<Id> neighbourhoodIdSet = new Set<Id>();

        for (sObject sobj: roomsAndAppartments) {
            if (sobj.getSObjectType() == RoomService.SObjectType) {
                roomIdSet.add(sobj.Id);
                apartmentIdSet.add((Id) sobj.get('ApartmentRef__c'));
                propertyIdSet.add((Id) sobj.get('Property__c'));
                neighbourhoodIdSet.add((Id) sobj.getSObject('Property__r').get('NeighbourhoodRef__c'));
            } else {
                apartmentIdSet.add(sobj.Id);
                propertyIdSet.add((Id) sobj.get('PropertyRef__c'));
                neighbourhoodIdSet.add((Id) sobj.getSObject('PropertyRef__r').get('NeighbourhoodRef__c'));
            }
        }

        Paua_Selector selector = Paua_SelectorHandler.getSelector(DescriptionSelectors.DescriptionsByParents.class);
        if (! roomIdSet.isEmpty()) { selector.setParameter('roomIdSet', roomIdSet); }
        if (! apartmentIdSet.isEmpty()) { selector.setParameter('apartmentIdSet', apartmentIdSet); }
        if (! propertyIdSet.isEmpty()) { selector.setParameter('propertyIdSet', propertyIdSet); }
        if (! neighbourhoodIdSet.isEmpty()) { selector.setParameter('neighbourhoodIdSet', neighbourhoodIdSet); }
        
        List<String> relevantFieldNames = new List<String>{'RoomRef__c', 'ApartmentRef__c', 'PropertyRef__c', 'NeighbourhoodRef__c'};
        for (SObject sobj: selector.query()) {
            for (String rel: relevantFieldNames) {
                if (sobj.get(rel) != null) {
                    Id relId = (Id) sobj.get(rel);
                    if (! descriptionsByParent.containsKey(relId)) {
                        descriptionsByParent.put(relId, new List<Description__c>());
                    }
                    descriptionsByParent.get(relId).add((Description__c) sobj);
                }
            }
        }

        return descriptionsByParent;
    }

    public List<Description__c> getAllForRecordFromParents(SObject record, Map<String, List<Description__c>> descriptionsByParent) {
        List<Description__c> descriptions = new List<Description__c>();

        if (descriptionsByParent.containsKey(record.Id)) { 
            descriptions.addAll(descriptionsByParent.get(record.Id)); 
        }

        if (record.getSObjectType() == RoomService.SObjectType) {
            if (descriptionsByParent.containsKey((Id) record.get('ApartmentRef__c'))) {
                descriptions.addAll(descriptionsByParent.get((Id) record.get('ApartmentRef__c')));
            }
            if (descriptionsByParent.containsKey((Id) record.get('Property__c'))) {
                descriptions.addAll(descriptionsByParent.get((Id) record.get('Property__c')));
            }
            if (descriptionsByParent.containsKey((Id) record.getSObject('Property__r').get('NeighbourhoodRef__c'))) {
                descriptions.addAll(descriptionsByParent.get((Id) record.getSObject('Property__r').get('NeighbourhoodRef__c')));
            }
        } else {
            if (descriptionsByParent.containsKey((Id) record.get('PropertyRef__c'))) {
                descriptions.addAll(descriptionsByParent.get((Id) record.get('PropertyRef__c')));
            }
            if (descriptionsByParent.containsKey((Id) record.getSObject('PropertyRef__r').get('NeighbourhoodRef__c'))) {
                descriptions.addAll(descriptionsByParent.get((Id) record.getSObject('PropertyRef__r').get('NeighbourhoodRef__c')));
            }
        }

        return descriptions;
    }
}