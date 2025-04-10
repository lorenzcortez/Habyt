/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-05-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class HomeAvailabilityLWCController{
    
    private static final list<String> countries = new list<String>{'United States', 'Canada'}; 

    @AuraEnabled(cacheable = true)
    public static Opportunity GetOpportunityRecord(string OppId) {
        try{
            list<Opportunity> Opps = new list<Opportunity>();
            Opps = [SELECT Id, Name, City_Lookup__c, Home_Committed__c, Max_Budget__c FROM Opportunity Where ID = :OppId limit 1];
            if(Opps.size() > 0){
                return Opps[0];
            }else{
                throw new AuraHandledException('Opportunity record not found..');
            }
        }
        catch(Exception ex) {
            system.debug('Error::'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static Room__c GetRoomRecord(string RoomId) {
        try{
            list<Room__c> Rooms = new list<Room__c>();
            Rooms = [SELECT Id, Name, Property__r.isFeatured__c, ApartmentRef__c, Property__c, En_suite_Bathroom__c, Dedicated_Bathroom__c, 
                    Square_Footage__c, Loft__c, View__c, Skylight__c, Dressing_Gallery__c, Balcony__c, country__c, 
                    Closet__c, Corner_Unit__c, Comments_Notes__c, Kitchenette__c,  ApartmentRef__r.Bedroom__c,
                    Property__r.Current_Concession__c, CurrencyIsoCode, Floor__c, Affordable_Unit__c, AvailableDateTrig__c, Property__r.Allowable_term_lengths__c, Security_Deposit_New__c, 
                    Property__r.X2_Day_Total_Hold_Amount__c, Application_Link__c, 
                    (SELECT Rent__c, Net_Rent__c, Lease_Term_Months__c FROM Pricing_Matrix__r WHERE Beacon_Deleted__c = FALSE AND Is_Move_In_Start_Date__c = TRUE AND Lease_Term_Months__c IN (3, 6, 9, 12)),
                    (SELECT Id, Name FROM Room__r WHERE Beacon_Deleted__c = FALSE Order By Lease_Term_Months__c ASC limit 2) //concession object relation
                    FROM Room__c 
                    Where ID = :RoomId limit 1];
            if(Rooms.size() > 0){
                return Rooms[0];
            }else{
                throw new AuraHandledException('Room record not found..');
            }
        }
        catch(Exception ex) {
            system.debug('Error::'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static Property__c GetHomeRecord(string HomeId) {
        try{
            list<Property__c> homes = new list<Property__c>();
            homes = [SELECT Id, Name, PropertyAddress__c, Total_Suites__c, Traditional_Units__c, Coliving_Bedrooms__c, Obligo_Home__c, Community_Space_Notes__c, Latest_Allowed_Move_In_Date__c, 
                    Sales_Home_Notes__c, Income_Requirements__c, Term_Restrictions__c, Transfer_Restrictions__c, Elevator__c, Amortized__c, Bike_Storage__c,  
                    ADA_Compliant__c, Wellness_Studio__c, Rooftop__c, Wet_Bar__c, Workspace__c, Gym__c, Movie_Room__c, Leasing_Plan__c, 
                    X2_Day_Total_Hold_Amount__c, Move_In_Fee__c, Guarantor_Requirements__c, Allowable_term_lengths__c,  Home_Type__c, 
                    Storage_Cost__c, Cost_of_Parking__c, Backyard__c, Lounge__c, Study_Room__c, Game_Room__c, Kitchen__c, Application_Fee__c, 
                    CurrencyIsoCode, Permit_Street_Parking__c, Bike_Storage_Type__c, Layout_Description__c, Courtyard__c, Dog_Park__c, Playground__c, Picnic_Area__c, 
                    Allows_Section_8__c, BBQ__c, Pet_Fee__c, Max_of_Pets__c, Pet_Rent__c, Pet_Deposit__c, Pet_Restrictions__c, Utility_Information__c, 
                    Parking_Type__c, Laundry_Location__c, Laundry_Type__c, NeighbourhoodRef__c, NeighbourhoodRef__r.Name
                    FROM Property__c Where ID = :HomeId limit 1];
            if(Homes.size() > 0){
                return homes[0];
            }else{
                throw new AuraHandledException('Home record not found..');
            }
        }
        catch(Exception ex) {
            system.debug('Error::'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static Apartment__c GetSuiteRecord(string SuiteId) {
        try{
            list<Apartment__c> Suites = new list<Apartment__c>();
            Suites = [SELECT Id, Name, Comments_Notes__c, Matterport__c, Max_Tenant_Count__c, Bedroom__c, Bathrooms__c, 
                    End_of_contract__c, CurrencyIsoCode
                    FROM Apartment__c 
                    Where ID = :SuiteId limit 1];
            if(Suites.size() > 0){
                return Suites[0];
            }else{
                throw new AuraHandledException('Suite record not found..');
            }
        }
        catch(Exception ex) {
            system.debug('Error::'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static List < Map < String, String >> RetreiveCities() {
        try{
            List < Map < String, String >> options = new List < Map < String, String >> ();
            list<City__c> Cities = new list<City__c>();
            Cities = [Select Id, Name from City__c WHERE Country__c IN :countries AND (NOT Name like '%Test%') AND (NOT Name like '%Blank%') Order By Name asc];
            
            
            if(Cities.size() > 0){
                Map < String, String > BlankValue = new Map < String, String > {
                    'label' => '--None--',
                    'value' => ''
                };
                options.add(BlankValue);
            }
            
            for (city__c c : Cities) {
                Map < String, String > values = new Map < String, String > {
                    'label' => c.Name,
                    'value' => c.Id
                };
                options.add(values);
            }
            return options;
        }
        catch(Exception ex) {
            system.debug('Error::'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled(cacheable = true) 
    public static List < Map < String, String >> RetreiveHomes(string CityId, String Brand, String Neighborhood) {
        try{
            List < Map < String, String >> options = new List < Map < String, String >> ();
            list<Property__c> Homes = new list<Property__c>();
            
            String SoqlStr = ' Select Id, Name FROM Property__c WHERE Country__c IN :countries '; //AND Status__c !=\'Home Closing\' AND Status__c !=\'Home Closed\' AND Status__c != \'Pre-Home Opening\'
                      
            if(!String.isBlank(CityId)){
               SoqlStr += ' AND City_object__c = \''+ CityId + '\' ';
            }
            if(!String.isBlank(Brand)){
               SoqlStr += ' AND BrandRef__c = \''+ Brand+ '\' ';
            }
            if(!String.isBlank(Neighborhood)){
                SoqlStr += 'AND NeighbourhoodRef__c = \''+Neighborhood+ '\'';
            }
            
            SoqlStr += ' AND (NOT Name like \'%Test%\') AND (NOT Name like \'%Blank%\') ';
            SoqlStr += ' Order By Name asc';
            
            Homes = Database.query(SoqlStr);
            if(Homes.size() > 0){
                Map < String, String > BlankValue = new Map < String, String > {
                    'label' => '--None--',
                    'value' => ''
                };
                options.add(BlankValue);
            }
            
            for (Property__c h : Homes) {
                Map < String, String > values = new Map < String, String > {
                    'label' => h.Name,
                    'value' => h.Id
                };
                options.add(values);
            }
            return options;
        }
        catch(Exception ex) {
            system.debug('Error::'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled(cacheable = true) 
    public static List < Map < String, String >> RetreiveNeighborhoods(string CityId) {
        try{
            List < Map < String, String >> options = new List < Map < String, String >> ();
            list<Neighbourhood__c> Neighborhoods = new list<Neighbourhood__c>();
            
            String SoqlStr = ' Select Id, Name FROM Neighbourhood__c WHERE CountryPick__c IN :countries AND Id != null ';
                      
            if(!String.isBlank(CityId)){
               SoqlStr += ' AND City_Lookup__c = \''+ CityId + '\' ';
            }
            //string TestName = '%Test%';
            //string BlankName = '%Blank%';
            
            SoqlStr += ' AND (NOT Name like \'%Test%\')  ';
            SoqlStr += ' Order By Name asc';
            
            Neighborhoods = Database.query(SoqlStr);
            if(Neighborhoods.size() > 0){
                Map < String, String > BlankValue = new Map < String, String > {
                    'label' => '--None--',
                    'value' => ''
                };
                options.add(BlankValue);
            }
            
            for (Neighbourhood__c n : Neighborhoods) {
                Map < String, String > values = new Map < String, String > {
                    'label' => n.Name,
                    'value' => n.Id
                };
                options.add(values);
            }
            return options;
        }
        catch(Exception ex) {
            system.debug('Error::'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static List < Map < String, String >> getPickListValues(String objApiName, String fieldName) {
        
        try{
            system.debug('objApiName::'+objApiName);
            system.debug('fieldName::'+fieldName);
            List < Map < String, String >> options = new List < Map < String, String >> ();
            Map < String, Schema.SObjectType > objGlobalMap = Schema.getGlobalDescribe();
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
            if (objType == null) {
                return options;
            }
            Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
            Map < String, Schema.SObjectField > fieldMap = sobjectDescribe.fields.getMap();
            if (fieldMap.get(fieldName) == null) {
                return options;
            }
            List < Schema.PicklistEntry > pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
            Map < String, String > BlankValue = new Map < String, String > {
                    'label' => '--None--',
                    'value' => ''
                };
                options.add(BlankValue);
            for (Schema.PicklistEntry f: pickListValues) {
                Map < String, String > values = new Map < String, String > {
                    'label' => f.getLabel(),
                    'value' => f.getValue()
                };
                options.add(values);
            }
            return options;
        }
        catch(Exception ex) {
            system.debug('Error::'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }
        
    @AuraEnabled(cacheable = true) 
    public static List<Room__c> GetRooms(string CityId, String HomeId, String Brand, String TermLength, String UnitType, String AffordableUnit, String Neighborhood, decimal Price, decimal BedroomCount, String SortField, string SortBy, list<String> checkboxFilters, integer Month) {
    
        system.debug('checkboxFilters::'+checkboxFilters);
        //try{
            
            if(SortBy == '' || SortBy == null){
                SortBy = 'asc';
            }
            
            list<Room__c> RoomsToReturn = new list<Room__c>();
            
            
            Date CurrentDate = date.today().AddMonths(Month);
            date firstDayOfMonth = CurrentDate.toStartOfMonth();
            Integer numberOfDays = Date.daysInMonth(CurrentDate.year(), CurrentDate.month());
            Date lastDayOfMonth = Date.newInstance(CurrentDate.year(), CurrentDate.month(), numberOfDays);

            String firstDayOfMonthFormatted = String.valueOf(firstDayOfMonth).removeEnd(' 00:00:00');
            String lastDayOfMonthFormatted = String.valueOf(lastDayOfMonth).removeEnd(' 00:00:00');

            String PricingSubQueryStr = '';
            if(Month == 0)
                PricingSubQueryStr += ' Move_In_Start_Date__c <= '+lastDayOfMonthFormatted;
            else
                PricingSubQueryStr += ' Move_In_Start_Date__c >= '+firstDayOfMonthFormatted+' AND Move_In_Start_Date__c <= '+lastDayOfMonthFormatted ;
            

            string soqlString = 'Select Id, Name, Property__r.Name, Property__r.isFeatured__c, En_suite_Bathroom__c, Property__c, ApartmentRef__c, ApartmentRef__r.Name, AvailableDateTrig__c, ' +
                'Parent_City__c, Room_ID__c, Square_Footage__c, Property__r.BrandRef__c, Affordable_Unit__c, ' + 
                'ApartmentRef__r.Bedroom__c, Property__r.Elevator__c, country__c, ' +
                'Property__r.Wellness_Studio__c, Property__r.Amortized__c, Application_Link__c, Floor__c, ' +
                'Comments_Notes__c, Property__r.Allowable_term_lengths__c, Property__r.PropertyAddress__c, ApartmentRef__r.Matterport__c, '+
                'Security_Deposit_New__c, Property__r.X2_Day_Total_Hold_Amount__c, Property__r.Application_Fee__c, Property__r.Obligo_Home__c, Property__r.Current_Concession__c, '+
                '(SELECT Rent__c, Net_Rent__c, Lease_Term_Months__c FROM Pricing_Matrix__r WHERE Beacon_Deleted__c = FALSE AND Is_Move_In_Start_Date__c = TRUE AND '+PricingSubQueryStr+' AND Lease_Term_Months__c IN (3, 6, 9, 12)), '+
                '(SELECT Id, Name FROM Room__r WHERE Beacon_Deleted__c = FALSE Order By Lease_Term_Months__c ASC limit 2) '+ //concession object relation
                'FROM Room__c ';
            
            if(Month == 0)
                soqlString += ' WHERE AvailableDateTrig__c <= '+lastDayOfMonthFormatted;
            else
                soqlString += ' WHERE AvailableDateTrig__c >= '+firstDayOfMonthFormatted+' AND AvailableDateTrig__c <= '+lastDayOfMonthFormatted ;
            
            soqlString += ' AND Status__c != \'Discontinued\' AND Room_Closed__c = false AND country__c IN :countries ';
            
            if(!String.isBlank(CityId)){
               soqlString += ' AND Property__r.City_object__c = \''+ CityId + '\' ';
            }
            if(!String.isBlank(HomeId)){
               soqlString += ' AND Property__c = \''+ HomeId+ '\' ';
            }
            
            if(!String.isBlank(Brand)){
               soqlString += ' AND Property__r.BrandRef__c = \''+ Brand+ '\' ';
            }
            
            if(!String.isBlank(Neighborhood)){
               soqlString += ' AND Property__r.NeighbourhoodRef__c = \''+ Neighborhood+ '\' ';
            }
            
            if(!String.isBlank(TermLength)){
               soqlString += ' AND Property__r.Allowable_term_lengths__c = \''+ TermLength+ '\' ';
            }
            
            if(!String.isBlank(UnitType)){
                if(UnitType.equalsIgnoreCase('coliving')){
                    set<String> ProductTypes = new Set<String>{'Co-living', 'RBR', 'SRO'};
                    soqlString += ' AND ApartmentRef__r.Product_type__c IN :ProductTypes ';
                }else if(UnitType.equalsIgnoreCase('traditional')){
                    soqlString += ' AND ApartmentRef__r.Product_type__c = \'Private\' ';
                }
            }
            if(!String.isBlank(AffordableUnit)){
                soqlString += ' AND '+AffordableUnit+' ';
            }
            
            if(Price != null && Price >= 0){
               //soqlString += ' AND X12_Month_Price__c <= '+ Price;
               soqlString += ' AND ID IN (SELECT Room__c FROM Pricing_Matrix__c WHERE Beacon_Deleted__c = FALSE AND Room__c != NULL AND Is_Move_In_Start_Date__c = TRUE AND Lease_Term_Months__c = 12 AND Rent__c <= :Price) ';
            }else{
                if(String.isNotBlank(SortField) && SortField.equals('Price_Matrix_12_Month')){
                    soqlString += ' AND ID IN (SELECT Room__c FROM Pricing_Matrix__c WHERE Beacon_Deleted__c = FALSE AND Room__c != NULL AND Is_Move_In_Start_Date__c = TRUE AND Lease_Term_Months__c = 12) '; 
                }
            }
            
            if(BedroomCount != null && BedroomCount >= 0){
                soqlString += ' AND ApartmentRef__r.Bedroom__c <= '+ BedroomCount;
            }
            
            
            if(checkboxFilters?.size() > 0){
                system.debug(checkboxFilters.size());
                for(string checkbox : checkboxFilters){
                   system.debug(checkbox);
                   soqlString += ' AND '+checkbox+' ';
                }
            }
            
            if(!String.isBlank(SortField)){
                
                if(SortField.equals('Property__r.IsFeatured__c')){
                    soqlString += ' Order By Property__r.IsFeatured__c '+ SortBy+' NULLS LAST, AvailableDateTrig__c asc';
                }
                else if(SortField.equals('Price_Matrix_12_Month')){

                }
                else{
                    soqlString += ' Order By '+SortField+' '+ SortBy+' NULLS LAST ';
                }
                
                
                
            }else{
                //soqlString += ' Order By X12_Month_Price__c ASC NULLS LAST';
            }
            
            system.debug('soqlString::'+soqlString);
            
            RoomsToReturn = Database.query(soqlString);
            
            return RoomsToReturn;
            
        //}
        //catch(Exception ex) {
            //system.debug('Error::'+ex.getMessage());
            //system.debug('Line Number::'+ex.getLineNumber());
            //throw new AuraHandledException(ex.getMessage());
        //}
    }
    
}