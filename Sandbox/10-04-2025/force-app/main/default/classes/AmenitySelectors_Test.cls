@IsTest
public with sharing class AmenitySelectors_Test {
    
    @IsTest
    public static void RoomAmenitiesByRoom_UnitTest() {
        RoomAmenity__c iRoomAmenity = TestRecord_Factory.iRoomAmenity;
        Set<Id> roomIdSet = new Set<Id>();
        roomIdSet.add(TestRecord_Factory.iRoom.Id);

        Test.startTest();
        List<SObject> lstAmenitiesByRoom = Paua_SelectorHandler.getSelector(AmenitySelectors.RoomAmenitiesByRoom.class)
                                            .setParameter('roomIdSet', roomIdSet)
                                            .query();
        Test.stopTest();
        System.assertEquals(1, lstAmenitiesByRoom.size());
    }


    @IsTest
    public static void RoomAmenitiesByApartment_UnitTest() {
        RoomAmenity__c iRoomAmenity = TestRecord_Factory.iRoomAmenity;
        Set<Id> apartmentIdSet = new Set<Id>();
        apartmentIdSet.add(TestRecord_Factory.iApartment.Id);

        Test.startTest();
        List<SObject> lstAmenitiesByRoom = Paua_SelectorHandler.getSelector(AmenitySelectors.RoomAmenitiesByApartment.class)
                                            .setParameter('apartmentIdSet', apartmentIdSet)
                                            .query();
        Test.stopTest();
        System.assertEquals(1, lstAmenitiesByRoom.size());
    }


    @IsTest
    public static void ApartmentAmenitiesByApartment_UnitTest() {
        ApartmentAmenity__c iApartmentAmenity = TestRecord_Factory.iApartmentAmenity;
        Set<Id> apartmentIdSet = new Set<Id>();
        apartmentIdSet.add(TestRecord_Factory.iApartment.Id);

        Test.startTest();
        List<SObject> lstAmenitiesByApartment = Paua_SelectorHandler.getSelector(AmenitySelectors.ApartmentAmenitiesByApartment.class)
                                            .setParameter('apartmentIdSet', apartmentIdSet)
                                            .query();
        Test.stopTest();
        System.assertEquals(1, lstAmenitiesByApartment.size());
    }


    @IsTest
    public static void PropertyAmenitiesByProperty_UnitTest() {
        PropertyAmenity__c iPropertyAmenity = TestRecord_Factory.iPropertyAmenity;
        Set<Id> propertyIdSet = new Set<Id>();
        propertyIdSet.add(TestRecord_Factory.iProperty.Id);

        Test.startTest();
        List<SObject> lstAmenitiesByApartment = Paua_SelectorHandler.getSelector(AmenitySelectors.PropertyAmenitiesByProperty.class)
                                            .setParameter('propertyIdSet', propertyIdSet)
                                            .query();
        Test.stopTest();
        System.assertEquals(1, lstAmenitiesByApartment.size());
    }

}