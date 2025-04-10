@IsTest
public with sharing class TestCollection_PropertyManagement {
    
    @IsTest
    public static void createDescriptionPack() {
        Neighbourhood__c iNeighbourhood = TestRecord_Factory.iNeighbourhood;
        Property__c iProperty = TestRecord_Factory.iProperty;
        iProperty.NeighbourhoodRef__c = iNeighbourhood.Id;
        update iProperty;
        
        Description__c description_1 = new Description__c(ApartmentRef__c = TestRecord_Factory.iApartment.Id);
        Description__c description_2 = new Description__c(RoomRef__c = TestRecord_Factory.iRoom.Id);
        Description__c description_3 = new Description__c(PropertyRef__c = TestRecord_Factory.iProperty.Id);
        Description__c description_4 = new Description__c(NeighbourhoodRef__c = TestRecord_Factory.iNeighbourhood.Id);
        List<Description__c> lstDesc = new List<Description__c>();
        lstDesc.add(description_1);
        lstDesc.add(description_2);
        lstDesc.add(description_3);
        lstDesc.add(description_4);
        insert lstDesc;
    }


    @IsTest
    public static void createConditionPack() {
        Billing_Entity__c billingEnt = TestRecord_Factory.iBilling_Entity;
        billingEnt.CurrencyIsoCode = 'EUR';
        Condition__c condition = TestRecord_Factory.iCondition;
        condition.CurrencyIsoCode = 'EUR';
        
        Property__c property = TestRecord_Factory.createProperty();
        property.Billing_Entity__c = billingEnt.Id;
        insert property;

        billingEnt.ConditionRef__c = condition.Id;
        update billingEnt;
    }
}