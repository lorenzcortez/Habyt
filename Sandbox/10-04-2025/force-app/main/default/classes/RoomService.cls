public without sharing class RoomService {
    public static final Schema.SObjectType SObjectType = Schema.Room__c.getSObjectType();

    public void checkRoomNumber(List<Room__c> newList, Map<Id, Room__c> oldMap){
        for (Room__c nRn: newList) {
            if (oldMap!=null && nRn.Room_Number__c != oldMap.get(nRn.Id).Room_Number__c) {
                list<Room__c> oldRooms = [SELECT Room_Number__c FROM Room__c where ApartmentRef__c=:nRn.ApartmentRef__c and Room_Number__c=:nRn.Room_Number__c ORDER BY Room_Number__c DESC NULLS LAST LIMIT 1];
                if(oldRooms.size()>0){
                    nRn.addError('This Room Number already exist!');
                }
            }
        }
    }

    public List<Room__c> rollupBedrooms(List<Room__c> rooms, Map<Id, Room__c> old) {
        List<Room__c> relevantRooms = getWithNewApartment(rooms, old);
        Set<Id> apartmentIdSet = extractAllAparmentIds(relevantRooms, old);

        ApartmentService service = new ApartmentService();
        service.rollupRooms(apartmentIdSet);

        return relevantRooms;
    }

    public List<Room__c> getWithNewApartment(List<Room__c> rooms, Map<Id, Room__c> old) {
        List<Room__c> relevant = new List<Room__c>();
        for (Room__c room: rooms) {
            Room__c oldRoom;
            if (old != null && old.containsKey(room.Id)) {
                oldRoom = old.get(room.Id);
            }

            if (oldRoom == null || room.ApartmentRef__c != oldRoom.ApartmentRef__c) {
                relevant.add(room);
            }
        }

        return relevant;
    }

    public Set<Id> extractAllAparmentIds(List<Room__c> rooms, Map<Id, Room__c> old) {
        Set<Id> relevant = new Set<Id>();

        for (Room__c room: rooms) {
            if (room.ApartmentRef__c != null) {
                relevant.add(room.ApartmentRef__c);
            }

            if (old != null && old.containsKey(room.Id) && old.get(room.Id).ApartmentRef__c != null) {
                relevant.add(old.get(room.Id).ApartmentRef__c);
            }
        }

        return relevant;
    }
}