@IsTest
public with sharing class DescriptionSelectors_Test {
    
    @IsTest
    public static void DescriptionsByParents_UnitTest() {
        TestCollection_PropertyManagement.createDescriptionPack();

        Set<Id> roomIdSet = new Set<Id>{TestRecord_Factory.iRoom.Id};
        Set<Id> apartmentIdSet = new Set<Id>{TestRecord_Factory.iApartment.Id};
        Set<Id> propertyIdSet = new Set<Id>{TestRecord_Factory.iProperty.Id};
        Set<Id> neighbourhoodIdSet = new Set<Id>{TestRecord_Factory.iNeighbourhood.Id};

        Test.startTest();
        List<SObject> lstDescription = Paua_SelectorHandler.getSelector(DescriptionSelectors.DescriptionsByParents.class)
                                            .setParameter('roomIdSet', roomIdSet)
                                            .setParameter('apartmentIdSet', apartmentIdSet)
                                            .setParameter('propertyIdSet', propertyIdSet)
                                            .setParameter('neighbourhoodIdSet', neighbourhoodIdSet)
                                            .query();
        Test.stopTest();
        System.assertEquals(4, lstDescription.size());
    }
}