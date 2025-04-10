@isTest
private class HomeAvailabilityLWCController_Test {
    @testSetup 
    private static void loadTestData() { 
        
        String DEFAULT_COUNTRY = 'United States';
        String DEFAULT_CITY = 'New York';
        String DEFAULT_CURRENCY = 'USD';


        Brand__c brand = new Brand__c();
        brand.Name = 'Habyt';
        brand.APINameBrand__c = 'Habyt';
        brand.CurrencyIsoCode = DEFAULT_CURRENCY;
        insert brand;

        Neighbourhood__c Neighborhood = new Neighbourhood__c();
        Neighborhood.Name = 'My Neighbor';
        Neighborhood.CurrencyIsoCode = DEFAULT_CURRENCY;
        Neighborhood.CountryPick__c = DEFAULT_COUNTRY;
        Neighborhood.CityPick__c = DEFAULT_CITY;
        insert Neighborhood;

        City__c city = new City__c();
        city.Name = DEFAULT_CITY;
        city.Country__c = DEFAULT_COUNTRY;
        city.CurrencyIsoCode = DEFAULT_CURRENCY;
        insert city;


        //String PropertyRecordTypeId = [SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE sObjectType = 'Property__c' AND DeveloperName = 'Common_Living_Property'].Id;
        Property__c home = new Property__c();
        home.Name = 'My Property';
        home.Property_Number__c = 1;
        //home.Billing_Entity__c = iBilling_Entity.Id;
        home.Country__c = DEFAULT_COUNTRY;
        home.City_Picklist__c = DEFAULT_CITY;
        home.NeighbourhoodRef__c = Neighborhood.Id;
        home.BrandRef__c = brand.Id;
        //home.ConditionRef__c = iCondition.Id;
        home.City_object__c = city.Id;
        home.Stage__c = 'Launched';
        home.CurrencyIsoCode = DEFAULT_CURRENCY;
        //home.RecordTypeId = PropertyRecordTypeId;
        insert home;

        Apartment__c apartment = new Apartment__c();
        apartment.Name = 'My Apartment';
        apartment.Apartment_Number__c = 1;
        apartment.PropertyRef__c = home.Id;
        apartment.Price__c = 1000;
        apartment.Status__c = 'Online';
        apartment.CurrencyIsoCode = DEFAULT_CURRENCY;
        insert apartment;

        Room__c room = new Room__c();
        room.Name = 'My Room';
        room.Room_Number__c = 1;
        room.Property__c = home.Id;
        room.ApartmentRef__c = apartment.Id;
        room.Price__c = 600;
        room.Status__c = 'Online';
        room.CurrencyIsoCode = DEFAULT_CURRENCY;
        insert room;

        
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Account'
                AND IsPersonType = true AND Name ='Customer'
        ];
        Account acc = new Account(
            FirstName = 'Test',
            LastName = 'Account',
            PersonEmail = 'test.account@example.com',
            RecordTypeId = rt.Id,
            CurrencyIsoCode = DEFAULT_CURRENCY);
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'Evaluation';
        opp.CloseDate = Date.today();
        opp.BrandRef__c = Brand.Id;
        //opp.BillingEntity__c = iBilling_Entity.Id;
        opp.Start_Date__c = Date.today();
        opp.CurrencyIsoCode = DEFAULT_CURRENCY;
        insert opp;
    }

    @isTest static void testLWCMethods() {
        
        String OpportunityId = [SELECT Id FROM Opportunity].Id;
        String roomId = [SELECT Id FROM Room__c].Id;
        String homeId = [SELECT Id FROM Property__c].Id;
        String SuiteId = [SELECT Id FROM Apartment__c].Id;
        String CityId = [SELECT Id FROM City__c].Id;
        String Brand = [SELECT Id FROM Brand__c].Id;
        String Neighborhood = [SELECT Id FROM Neighbourhood__c].Id;
        String TermLength = '> 2 Months';
        String UnitType = 'Traditional';
        String AffordableUnit = 'Affordable_Unit__c = FALSE';
        Decimal Price = -1;
        decimal BedroomCount = -1;
        String SortField = 'Property__r.isFeatured__c';
        string SortBy = 'asc';
        list<String> checkboxFilters = new list<String>();
        integer Month = 1;

        checkboxFilters.add('Property__r.Elevator__c = TRUE');
        checkboxFilters.add('Loft__c = TRUE');
        checkboxFilters.add('Property__r.Wellness_Studio__c = TRUE');
        checkboxFilters.add('En_suite_Bathroom__c = TRUE');
        checkboxFilters.add('ApartmentRef__r.ESA_in_Suite__c = FALSE');



        HomeAvailabilityLWCController.GetOpportunityRecord(OpportunityId);
        HomeAvailabilityLWCController.GetRoomRecord(roomId);
        HomeAvailabilityLWCController.GetHomeRecord(homeId);
        HomeAvailabilityLWCController.GetSuiteRecord(SuiteId);

        HomeAvailabilityLWCController.RetreiveCities();
        HomeAvailabilityLWCController.RetreiveHomes(CityId, Brand, Neighborhood);
        HomeAvailabilityLWCController.RetreiveNeighborhoods(CityId);
        HomeAvailabilityLWCController.getPickListValues('Property__c', 'Allowable_term_lengths__c');
        HomeAvailabilityLWCController.GetRooms(CityId, HomeId, Brand, TermLength, UnitType, AffordableUnit, Neighborhood, Price, BedroomCount, SortField, SortBy, checkboxFilters, Month);

    }
}