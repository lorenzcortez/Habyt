@IsTest
public class AmenityService_Test {

    @IsTest
    public static void getByParent_unitTest() {
        PropertyAmenity__c propAmenity = TestRecord_Factory.iPropertyAmenity;
        ApartmentAmenity__c appAmenity = TestRecord_Factory.iApartmentAmenity;
        RoomAmenity__c roomAmenity = TestRecord_Factory.iRoomAmenity;

        List<SObject> lstSObjects = new List<SObject>{TestRecord_Factory.iApartment, TestRecord_Factory.iRoom};

        AmenityService amenityService = new AmenityService();

        Test.startTest();
        Map<String, List<Amenity__c>> result = amenityService.getByParent(lstSObjects);
        Test.stopTest();

        System.assertEquals(1, result.get(TestRecord_Factory.iApartment.Id).size());
        System.assertEquals(1, result.get(TestRecord_Factory.iRoom.Id).size());
    }


    @IsTest
    public static void getAllForRecordFromParents_unitTest() {
        PropertyAmenity__c propAmenity = TestRecord_Factory.iPropertyAmenity;
        ApartmentAmenity__c appAmenity = TestRecord_Factory.iApartmentAmenity;
        RoomAmenity__c roomAmenity = TestRecord_Factory.iRoomAmenity;

        List<SObject> lstSObjects = new List<SObject>{TestRecord_Factory.iApartment, TestRecord_Factory.iRoom};

        AmenityService amenityService = new AmenityService();
        Map<String, List<Amenity__c>> mapAmenitiesByParent = amenityService.getByParent(lstSObjects);

        Test.startTest();
        List<Amenity__c> lstAmenitiesForRoom = amenityService.getAllForRecordFromParents(TestRecord_Factory.iRoom, mapAmenitiesByParent);
        List<Amenity__c> lstAmenitiesForApartment = amenityService.getAllForRecordFromParents(TestRecord_Factory.iApartment, mapAmenitiesByParent);
        Test.stopTest();

        System.assertEquals(3, lstAmenitiesForRoom.size());
        System.assertEquals(3, lstAmenitiesForApartment.size());

    }
}