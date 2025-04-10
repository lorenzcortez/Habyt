public without sharing class ApartmentService {
    public static final Schema.SObjectType SObjectType = Schema.Apartment__c.getSObjectType();

    public void checkApartmentNumber(List<Apartment__c> newList, Map<Id, Apartment__c> oldMap){
        for (Apartment__c nAn: newList) {
            if (oldMap!=null && nAn.Apartment_Number__c != oldMap.get(nAn.Id).Apartment_Number__c) {
                list<Apartment__c> oldApartments = [SELECT Apartment_Number__c FROM Apartment__c where PropertyRef__c=:nAn.PropertyRef__c and Apartment_Number__c=:nAn.Apartment_Number__c ORDER BY Apartment_Number__c DESC NULLS LAST LIMIT 1];
                if(oldApartments.size()>0){
                    nAn.addError('This Apartment Number already exist!');
                }
            }
        }
    }

    public void rollupRooms(Set<Id> apartmentIdSet) {
        List<AggregateResult> roomCount = Paua_SelectorHandler.getSelector(RoomSelectors.RoomCountByApartment.class)
            .setParameter('apartmentIdSet', apartmentIdSet)
            .query();

        Map<Id, Apartment__c> apartments = new Map<Id, Apartment__c>();
        for (AggregateResult ar: roomCount) {
            Id apartmentId = (Id)ar.get('ApartmentRef__c');
            apartments.put(apartmentId, new Apartment__c(
                Id = apartmentId, 
                Bedroom__c = (Decimal)ar.get('expr0')
            ));
        }

        for (Id apartmentId: apartmentIdSet) {
            if (! apartments.containsKey(apartmentId)) {
                apartments.put(apartmentId, new Apartment__c(
                    Id = apartmentId, 
                    Bedroom__c = 0
                ));
            }
        }

        if (! apartments.isEmpty()) {
            Paua_Transaction trans = new Paua_Transaction();
            trans.addForUpdate(apartments.values());
            trans.setPreferredOrder(new List<SObjectType>{Apartment__c.getSObjectType()});
            trans.commitRecords();
        }
    }
}