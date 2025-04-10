@IsTest
public with sharing class RealEstateOpportunityService_Test {
    
    @IsTest
    public static void getWithoutProperty_UnitTest() {
        Opportunity oppWithProperty = TestRecord_Factory.createOpportunity();
        Opportunity oppWithoutProperty = TestRecord_Factory.createOpportunity();
        List<Opportunity> lstOpps = new List<Opportunity>{oppWithProperty,oppWithoutProperty};
        insert lstOpps;

        Property__c property = TestRecord_Factory.createProperty();
        property.Opportunity__c = oppWithProperty.Id;
        insert property;

        RealEstateOpportunityService realEstateOpportunityService = new RealEstateOpportunityService();

        Test.startTest();
        List<Opportunity> lstResult = realEstateOpportunityService.getWithoutProperty(lstOpps);
        Test.stopTest();

        System.assertEquals(1, lstResult.size());
    }


    @IsTest
    public static void createPropertiesForOpportunities_UnitTest() {
        Billing_Entity__c be = TestRecord_Factory.iBilling_Entity;
        be.ConditionRef__c = TestRecord_Factory.iCondition.Id;
        be.CurrencyIsoCode = TestRecord_Factory.iCondition.CurrencyIsoCode;
        update be;

        Opportunity oppWithProperty = TestRecord_Factory.createOpportunity();
        oppWithProperty.BillingEntity__c = be.Id;
        oppWithProperty.BrandRef__c = TestRecord_Factory.iBrand.Id;

        Opportunity oppWithoutProperty = TestRecord_Factory.createOpportunity();
        oppWithoutProperty.BillingEntity__c = be.Id;
        oppWithoutProperty.BrandRef__c = TestRecord_Factory.iBrand.Id;
        
        List<Opportunity> lstOpps = new List<Opportunity>{oppWithProperty,oppWithoutProperty};
        insert lstOpps;

        Property__c property = TestRecord_Factory.createProperty();
        property.Opportunity__c = oppWithProperty.Id;
        insert property;

        RealEstateOpportunityService realEstateOpportunityService = new RealEstateOpportunityService();

        Test.startTest();
        realEstateOpportunityService.createPropertiesForOpportunities(lstOpps);
        Test.stopTest();
    }
}