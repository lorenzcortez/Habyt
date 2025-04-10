@IsTest
public class PropertySelectors_Test {
    
    @IsTest
    public static void AllProperties_UnitTest() {
        Property__c property = TestRecord_Factory.iProperty;

        Test.startTest();
        List<SObject> lstProperties = Paua_SelectorHandler.getSelector(PropertySelectors.AllProperties.class)
                                                            .query();
        Test.stopTest();

        System.assertEquals(1, lstProperties.size());
    }

    @IsTest
    public static void PropertiesWithDocuments_UnitTest() {
        Property__c property = TestRecord_Factory.iProperty;

        Test.startTest();
        List<SObject> lstProperties = Paua_SelectorHandler.getSelector(PropertySelectors.PropertiesWithDocuments.class)
            .setParameter('propertyIdSet', new Set<Id>{property.Id})
            .query();
        Test.stopTest();

        System.assertEquals(1, lstProperties.size());
    }

    @IsTest
    public static void PropertiesByBrandApiName_UnitTest() {
        Property__c property = TestRecord_Factory.iProperty;
        Brand__c brand = TestRecord_Factory.iBrand;

        Test.startTest();
        List<SObject> lstProperties = Paua_SelectorHandler.getSelector(PropertySelectors.PropertiesByBrandApiName.class)
            .setParameter('brandSet', new Set<String>{brand.APINameBrand__c})
            .query();
        Test.stopTest();

        System.assertEquals(1, lstProperties.size());
    }

}