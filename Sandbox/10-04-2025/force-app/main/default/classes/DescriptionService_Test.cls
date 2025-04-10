@IsTest
public class DescriptionService_Test{
    @IsTest
    public static void getByParent_UnitTest(){
        TestCollection_PropertyManagement.createDescriptionPack();
        
        Room__c room = (Room__c) Paua_SelectorHandler.getSelector(RoomSelectors.RoomsWithApartmentAndProperty.class)
                                                    .query().get(0);

        Apartment__c apartment = (Apartment__c) Paua_SelectorHandler.getSelector(ApartmentSelectors.ApartmentsWithProperty.class)
                                                    .query().get(0);

        List<SObject> roomsAndAppartments = new List<SObject>{room, apartment};
        DescriptionService descriptionService = new DescriptionService();

        Test.startTest();
        Map<String, List<Description__c>> mapResult = descriptionService.getByParent(roomsAndAppartments);
        Test.stopTest();

        System.assert(mapResult.containsKey(room.Id));
    }

    @IsTest
    public static void getAllForRecordFromParents_UnitTest(){
        TestCollection_PropertyManagement.createDescriptionPack();
        
        Room__c room = (Room__c) Paua_SelectorHandler.getSelector(RoomSelectors.RoomsWithApartmentAndProperty.class)
                                                    .query().get(0);

        Apartment__c apartment = (Apartment__c) Paua_SelectorHandler.getSelector(ApartmentSelectors.ApartmentsWithProperty.class)
                                                    .query().get(0);

        DescriptionService descriptionService = new DescriptionService();
        Map<String, List<Description__c>> descriptionsByParent = descriptionService.getByParent(new List<SObject>{room, apartment});

        Test.startTest();
        List<Description__c> lstResultForRoom = descriptionService.getAllForRecordFromParents(room, descriptionsByParent);
        List<Description__c> lstResultForApartment = descriptionService.getAllForRecordFromParents(apartment, descriptionsByParent);
        Test.stopTest();

        System.assertEquals(4, lstResultForRoom.size());
        System.assertEquals(3, lstResultForApartment.size());
        
    }
}