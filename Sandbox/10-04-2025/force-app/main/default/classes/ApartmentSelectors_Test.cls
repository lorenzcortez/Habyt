@IsTest
public class ApartmentSelectors_Test {
    
    @IsTest
    public static void ApartmentsWithProperty_UnitTest() {
        Apartment__c apartment = TestRecord_Factory.iApartment;

        Test.startTest();
        List<SObject> lstApartments = Paua_SelectorHandler.getSelector(ApartmentSelectors.ApartmentsWithProperty.class)
                                            .query();
        Test.stopTest();
        System.assertEquals(1, lstApartments.size());
    }
}