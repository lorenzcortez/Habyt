public without sharing class Room_cDomain_RollupToApartment extends Paua_SObjectDomain {

    public override void init() {
        domainType = Room_cDomain_RollupToApartment.class;
    }

    public override void beforeUpdate() {
        RoomService service = new RoomService();
        service.checkRoomNumber((List<Room__c>) Trigger.new, (Map<Id, Room__c>) Trigger.oldMap);
    }

    public override void afterUpdate() {
        RoomService service = new RoomService();
        service.rollupBedrooms((List<Room__c>) Trigger.new, (Map<Id, Room__c>) Trigger.oldMap);
    }

    public override void afterDelete() {
        RoomService service = new RoomService();
        service.rollupBedrooms((List<Room__c>) Trigger.old, null);
    }

    public override void afterUndelete() {
        RoomService service = new RoomService();
        service.rollupBedrooms((List<Room__c>) Trigger.new, null);
    }
}