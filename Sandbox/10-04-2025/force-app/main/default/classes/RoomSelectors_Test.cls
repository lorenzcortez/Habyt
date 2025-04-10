@IsTest
public class RoomSelectors_Test {
    
    @IsTest
    public static void RoomsWithApartmentAndProperty_UnitTest() {
        Room__c room = TestRecord_Factory.iRoom;

        Test.startTest();
        List<SObject> lstRoomsWithApartmentAndProperty = Paua_SelectorHandler.getSelector(RoomSelectors.RoomsWithApartmentAndProperty.class)
                                                            .query();
        Test.stopTest();

        System.assertEquals(1, lstRoomsWithApartmentAndProperty.size());
    }

}