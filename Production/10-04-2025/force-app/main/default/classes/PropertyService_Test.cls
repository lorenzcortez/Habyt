@IsTest
public with sharing class PropertyService_Test {

    @IsTest
    public static void reparentFilesToOpportunity_UnitTest() {
        Opportunity opp = TestRecord_Factory.iOpportunity;
        ContentVersion contentVersion = TestRecord_Factory.iContentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        Property__c property = TestRecord_Factory.createProperty();
        property.Opportunity__c = opp.Id;
        insert property;

        ContentDocumentLink contDocLink = TestRecord_Factory.createContentDocumentLink(property.Id, documents.get(0).Id);
        insert contDocLink;

        PropertyService propertyService = new PropertyService();

        Test.startTest();
        propertyService.reparentFilesToOpportunity(new List<Property__c>{property});
        Test.stopTest();

        System.assertEquals(0, [SELECT count() FROM ContentDocumentLink WHERE LinkedEntityId = :property.Id]);
        System.assertEquals(1, [SELECT count() FROM ContentDocumentLink WHERE LinkedEntityId = :opp.Id]);
    }

    @IsTest
    public static void createFromOpportunity_UnitTest() {
        Opportunity iOpportunity = TestRecord_Factory.createOpportunity();
        insert iOpportunity;

        PropertyService propertyService = new PropertyService();
        
        Test.startTest();
        Property__c property = propertyService.createFromOpportunity(iOpportunity);
        Test.stopTest();

        System.assert(property != null);
    }

    @IsTest
    public static void getFromSObject_UnitTest() {
        Property__c property = TestRecord_Factory.iProperty;

        PropertyService propertyService = new PropertyService();
        
        Test.startTest();
        Property__c propertyTest = propertyService.getFromSObject(property);
        Test.stopTest();

        System.assert(propertyTest != null);
    }

    @IsTest
    public static void filterPropertyLinks_UnitTest() {
        ContentVersion contentVersion = TestRecord_Factory.iContentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        Property__c property = TestRecord_Factory.iProperty;

        ContentDocumentLink contDocLink = TestRecord_Factory.createContentDocumentLink(property.Id, documents.get(0).Id);
        insert contDocLink;

        PropertyService propertyService = new PropertyService();

        Test.startTest();
        List<ContentDocumentLink> lsrContentDocLinks = propertyService.filterPropertyLinks(new List<ContentDocumentLink>{contDocLink});
        Test.stopTest();

        System.assertEquals(1, lsrContentDocLinks.size());
    }

    @IsTest
    public static void publishPropertyContent_UnitTest() {
    }

    @IsTest
    public static void getCondition_UnitTest() {
        TestCollection_PropertyManagement.createConditionPack();
        Property__c property = (Property__c) Paua_SelectorHandler.getSelector(PropertySelectors.AllProperties.class)
                                                            .query()
                                                            .get(0);

        PropertyService propertyService = new PropertyService();
        
        Test.startTest();
        Condition__c conditionTest = propertyService.getCondition(property);
        Test.stopTest();

        System.assert(conditionTest != null);
    }

    @IsTest
    static void getWithoutCondition_UnitTest(){
        Property__c property = TestRecord_Factory.iProperty;

        Integer expected = [SELECT COUNT() FROM Property__c WHERE ConditionRef__c = null];
        List<Property__c> allProperty = [SELECT Id, ConditionRef__c FROM Property__c];
        
        PropertyService service = new PropertyService();

        Test.startTest();

        List<Property__c> relevant = service.getWithoutCondition(allProperty);
        
        Test.stopTest();

        System.assertEquals(expected, relevant.size(), 'Incorrect number of properties counted');
    }

    @IsTest
    static void getWithOpportunity_UnitTest(){
        Property__c property = TestRecord_Factory.iProperty;

        Integer expected = [SELECT COUNT() FROM Property__c WHERE Opportunity__c != null];
        List<Property__c> allProperty = [SELECT Id, Opportunity__c FROM Property__c];
        
        PropertyService service = new PropertyService();

        Test.startTest();

        List<Property__c> relevant = service.getWithOpportunity(allProperty);
        
        Test.stopTest();

        System.assertEquals(expected, relevant.size(), 'Incorrect number of properties counted');
    }

    @IsTest
    static void getWithBillingEntity_UnitTest(){
        Property__c property = TestRecord_Factory.iProperty;

        Integer expected = [SELECT COUNT() FROM Property__c WHERE Billing_Entity__c != null];
        List<Property__c> allProperty = [SELECT Id, Billing_Entity__c FROM Property__c];
        
        PropertyService service = new PropertyService();

        Test.startTest();

        List<Property__c> relevant = service.getWithBillingEntity(allProperty);
        
        Test.stopTest();

        System.assertEquals(expected, relevant.size(), 'Incorrect number of properties counted');
    }

    @IsTest
    static void setDefaultCondition_UnitTest() {
        Billing_Entity__c billingEnt = TestRecord_Factory.iBilling_Entity;
        Property__c property = TestRecord_Factory.iProperty;
        property.Billing_Entity__c = billingEnt.Id;
        update property;

        PropertyService propertyService = new PropertyService();
        
        Test.startTest();

        property = propertyService.setDefaultCondition(new List<Property__c>{property})[0];

        Test.stopTest();

        System.assertEquals(billingEnt.ConditionRef__c, property.ConditionRef__c, 'Unexpected condition set');
    }
}