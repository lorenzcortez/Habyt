@IsTest
public class CustomerApartmentSelectors_Test {
    @TestSetup
    static void setupTest(){
        List<Apartment__c> apartments = new List<Apartment__c>();

        Apartment__c apartment1 = TestRecord_Factory.createApartment();
        apartments.add(apartment1);

        Apartment__c apartment2 = TestRecord_Factory.createApartment();
        apartments.add(apartment2);

        Apartment__c apartment3 = TestRecord_Factory.createApartment();
        apartments.add(apartment3);

        insert apartments;
    }

    @IsTest
    static void RoomsByIds_UnitTest() {
        List<Apartment__c> apartments = [SELECT Id FROM Apartment__c];
        Integer expected = apartments.size();
        Set<Id> idsSet = (new Map<Id, Apartment__c>(apartments)).keySet();

        Test.startTest();
        
        List<SObject> queried = Paua_SelectorHandler.getSelector(CustomerApartmentSelectors.ApartmentByIds.class)
                                                    .setParameter('idsSet', idsSet)
                                                    .query();

        Test.stopTest();

        System.assertEquals(expected, queried.size(), 'Unexpected number of results');
    }
}