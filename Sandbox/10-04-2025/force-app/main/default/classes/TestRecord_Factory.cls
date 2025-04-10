@IsTest
public class TestRecord_Factory{
    private static final String DEFAULT_COUNTRY = 'Germany';
    private static final String DEFAULT_CITY = 'Berlin';

    // Brand__c
    public static Brand__c iBrand{
        get{
            if (iBrand == null){
                iBrand = createBrand();

                insert iBrand;
                System.assert(iBrand.Id != null);
            }
            return iBrand;
        }

        set;
    }

    public static Brand__c createBrand(){
        Brand__c iObject = new Brand__c();
        iObject.Name = 'Habyt';
        iObject.APINameBrand__c = 'Habyt';
        iObject.CurrencyIsoCode = 'EUR';
        return iObject;
    }

    // City Object
    public static City__c iCityObj{
        get{
            if (iCityObj == null){
                iCityObj = createCityObj();

                insert iCityObj;
                System.assert(iCityObj.Id != null);
            }
            return iCityObj;
        }

        set;
    }

    public static City__c createCityObj(){
        City__c iObject = new City__c();
        iObject.Name = 'Berlin';
        iObject.CurrencyIsoCode = 'EUR';
        return iObject;
    }


    // Neighbourhood__c
    public static Neighbourhood__c iNeighbourhood{
        get{
            if (iNeighbourhood == null){
                iNeighbourhood = createNeighbourhood();

                insert iNeighbourhood;
                System.assert(iNeighbourhood.Id != null);
            }
            iNeighbourhood.CurrencyIsoCode = 'EUR';
            return iNeighbourhood;
        }

        set;
    }

    public static Neighbourhood__c createNeighbourhood(){
        Neighbourhood__c iObject = new Neighbourhood__c();
        iObject.Name = 'Test';
        iObject.CurrencyIsoCode = 'EUR';
        iObject.CountryPick__c = DEFAULT_COUNTRY;
        iObject.CityPick__c = DEFAULT_CITY;
        return iObject;
    }

    // Property__c
    public static Property__c iProperty{
        get{
            if (iProperty == null){
                iProperty = createProperty();
                insert iProperty;
                System.assert(iProperty.Id != null);
            }
            iProperty.CurrencyIsoCode = 'EUR';
            iProperty.RecordTypeId = '0121i000000YGUIAA4';
            return iProperty;
        }

        set;
    }

    public static Property__c createProperty(){

        Property__c iObject = new Property__c();
        iObject.Name = 'Test Property';
        iObject.Property_Number__c = 1;
        iObject.Billing_Entity__c = iBilling_Entity.Id;
        iObject.Country__c = DEFAULT_COUNTRY;
        iObject.City_Picklist__c = DEFAULT_CITY;
        iObject.NeighbourhoodRef__c = iNeighbourhood.Id;
        iObject.BrandRef__c = iBrand.Id;
        iObject.ConditionRef__c = iCondition.Id;
        iObject.City_object__c = iCityObj.Id;
        iObject.RecordTypeId = '0121i000000YGUIAA4';
        iObject.Stage__c = 'Launched';
        iObject.CurrencyIsoCode = 'EUR';
        iObject.Website_URL_Slug__c = 'Test.com';
        return iObject;
    }


    // Apartment__c
    public static Apartment__c iApartment{
        get{
            if (iApartment == null){
                iApartment = createApartment();
                insert iApartment;
                System.assert(iApartment.Id != null);
            }
            iApartment.CurrencyIsoCode = 'EUR';
            iApartment.RecordTypeId = '01I1i000000QajW';
            return iApartment;
        }
        set;
    }

    public static Apartment__c createApartment(){
        Apartment__c iObject = new Apartment__c();
        iObject.Name = 'Test Apartment';
        iObject.Apartment_Number__c = 1;
        iObject.PropertyRef__c = iProperty.Id;
        iObject.Price__c = 1000;
        iObject.Status__c = 'Online';
        iObject.CurrencyIsoCode = iProperty.CurrencyIsoCode;
        return iObject;
    }


    // Room_c
    public static Room__c iRoom{
        get{
            if (iRoom == null){
                iRoom = createRoom();
                insert iRoom;
                System.assert(iRoom.Id != null);
            }
            iRoom.CurrencyIsoCode = 'EUR';
            iROOM.RecordTypeId = '0121i000000YGVBAA4';
            return iRoom;
        }
        set;
    }

    public static Room__c createRoom(){
        Room__c iObject = new Room__c();
        iObject.Name = 'Test Room';
        iObject.Room_Number__c = 1;
        iObject.Property__c = iProperty.Id;
        iObject.ApartmentRef__c = iApartment.Id;
        iObject.Price__c = 600;
        iObject.Status__c = 'Online';
        iObject.CurrencyIsoCode = 'EUR';
        return iObject;
    }


    // Amenity__c
    public static Amenity__c iAmenity{
        get{
            if (iAmenity == null){
                iAmenity = createAmenity();
                insert iAmenity;
                System.assert(iAmenity.Id != null);
            }
            iAmenity.CurrencyIsoCode = 'EUR';
            return iAmenity;
        }

        set;
    }

    public static Amenity__c createAmenity(){
        Amenity__c iObject = new Amenity__c();
        iObject.Name = 'Amenity Name';
        iObject.CurrencyIsoCode = 'EUR';
        return iObject;
    }


    // Amenity__c type Room
    public static Amenity__c iAmenity_Room{
        get{
            if (iAmenity_Room == null){
                iAmenity_Room = createAmenity();
                iAmenity_Room.TypePick__c = 'Room Amenity';
                insert iAmenity_Room;
                System.assert(iAmenity_Room.Id != null);
            }
            iAmenity_Room.CurrencyIsoCode = 'EUR';
            return iAmenity_Room;
        }

        set;
    }

    // Amenity__c type Apartment
    public static Amenity__c iAmenity_Apartment{
        get{
            if (iAmenity_Apartment == null){
                iAmenity_Apartment = createAmenity();
                iAmenity_Apartment.TypePick__c = 'Apartment Amenity';
                insert iAmenity_Apartment;
                System.assert(iAmenity_Apartment.Id != null);
            }
            iAmenity_Apartment.CurrencyIsoCode = 'EUR';
            return iAmenity_Apartment;
        }

        set;
    }

    // Amenity__c type Property
    public static Amenity__c iAmenity_Property{
        get{
            if (iAmenity_Property == null){
                iAmenity_Property = createAmenity();
                iAmenity_Property.TypePick__c = 'Property Amenity';
                insert iAmenity_Property;
                System.assert(iAmenity_Property.Id != null);
            }
            iAmenity_Property.CurrencyIsoCode = 'EUR';
            return iAmenity_Property;
        }

        set;
    }


    // RoomAmenity__c
    public static RoomAmenity__c iRoomAmenity{
        get{
            if (iRoomAmenity == null){
                iRoomAmenity = createRoomAmenity();
                insert iRoomAmenity;
                System.assert(iRoomAmenity.Id != null);
            }
            iRoomAmenity.CurrencyIsoCode = 'EUR';
            return iRoomAmenity;
        }

        set;
    }

    public static RoomAmenity__c createRoomAmenity(){
        RoomAmenity__c iObject = new RoomAmenity__c();
        iObject.RoomRef__c = iRoom.Id;
        iObject.AmenityRef__c = iAmenity_Room.Id;
        iObject.CurrencyIsoCode = iRoom.CurrencyIsoCode;
        return iObject;
    }
    

    // ApartmentAmenity__c
    public static ApartmentAmenity__c iApartmentAmenity{
        get{
            if (iApartmentAmenity == null){
                iApartmentAmenity = createApartmentAmenity();

                insert iApartmentAmenity;
                System.assert(iApartmentAmenity.Id != null);
            }
            iApartmentAmenity.CurrencyIsoCode = 'EUR';
            return iApartmentAmenity;
        }

        set;
    }

    public static ApartmentAmenity__c createApartmentAmenity(){
        ApartmentAmenity__c iObject = new ApartmentAmenity__c();
        iObject.ApartmentRef__c = iApartment.Id;
        iObject.AmenityRef__c = iAmenity_Apartment.Id;
        iObject.CurrencyIsoCode = iApartment.CurrencyIsoCode;
        return iObject;
    }


    // PropertyAmenity__c
    public static PropertyAmenity__c iPropertyAmenity{
        get{
            if (iPropertyAmenity == null){
                iPropertyAmenity = createPropertyAmenity();

                insert iPropertyAmenity;
                System.assert(iPropertyAmenity.Id != null);
            }
            iPropertyAmenity.CurrencyIsoCode = 'EUR';
            return iPropertyAmenity;
        }

        set;
    }

    public static PropertyAmenity__c createPropertyAmenity(){
        PropertyAmenity__c iObject = new PropertyAmenity__c();
        iObject.PropertyRef__c = iProperty.Id;
        iObject.AmenityRef__c = iAmenity_Property.Id;
        iObject.CurrencyIsoCode = iProperty.CurrencyIsoCode;
        return iObject;
    }


    // Description__c
    public static Description__c iDescription{
        get{
            if (iDescription == null){
                iDescription = createDescription();

                insert iDescription;
                System.assert(iDescription.Id != null);
            }
            iDescription.CurrencyIsoCode = 'EUR';
            return iDescription;
        }

        set;
    }

    public static Description__c createDescription(){
        Description__c iObject = new Description__c();
        iObject.CurrencyIsoCode = iProperty.CurrencyIsoCode;
        return iObject;
    }


    // Account
    public static Account iAccount{
        get{
            if (iAccount == null){
                iAccount = createAccount();

                insert iAccount;
                System.assert(iAccount.Id != null);
            }
            iAccount.CurrencyIsoCode = 'EUR';
            iAccount.RecordTypeId = '0121i000000Y28NAAS';
            return iAccount;
        }

        set;
    }

    public static Account createAccount(){
        Account iObject = new Account();
        iObject.Name = 'Test Acc';
        iObject.CurrencyIsoCode = 'EUR';
        return iObject;
    }


    // Opportunity
    public static Opportunity iOpportunity{
        get{
            if (iOpportunity == null){
                iOpportunity = createOpportunity();

                insert iOpportunity;
                System.assert(iOpportunity.Id != null);
            }
            iOpportunity.CurrencyIsoCode = 'EUR';
            //iOpportunity.RecordTypeId = '0121i000000D3QzAAK';
            return iOpportunity;
        }

        set;
    }

    public static Opportunity createOpportunity(){
        Opportunity iObject = new Opportunity();
        iObject.Name = 'Test Opp';
        iObject.AccountId = iPersonAccount.Id;
        iObject.StageName = 'Evaluation';
        iObject.CloseDate = Date.today();
        iObject.BrandRef__c = iBrand.Id;
        iObject.BillingEntity__c = iBilling_Entity.Id;
        iObject.Start_Date__c = Date.today();
        iObject.CurrencyIsoCode = iPersonAccount.CurrencyIsoCode;
        return iObject;
    }

    
    //Stripe_Account__c
    public static Stripe_Account__c iStripe_Account{
        get{
            if (iStripe_Account == null){
                iStripe_Account = createStripe_Account();

                insert iStripe_Account;
                System.assert(iStripe_Account.Id != null);
            }
            iStripe_Account.CurrencyIsoCode = 'EUR';
            return iStripe_Account;
        }

        set;
    }

    public static Stripe_Account__c createStripe_Account(){
        Stripe_Account__c iObject = new Stripe_Account__c();
        iObject.Name = 'Test Stripe Acc';
        iObject.secret_key__c = 'secret_key_123';
        iObject.CurrencyIsoCode = 'EUR';
        return iObject;
    }


    // Billing_Entity__c
    public static Billing_Entity__c iBilling_Entity{
        get{
            if (iBilling_Entity == null){
                iBilling_Entity = createBilling_Entity();

                insert iBilling_Entity;
                System.assert(iBilling_Entity.Id != null);
            }
            iBilling_Entity.CurrencyIsoCode = 'EUR';
            return iBilling_Entity;
        }

        set;
    }

    public static Billing_Entity__c createBilling_Entity(){
        Billing_Entity__c iObject = new Billing_Entity__c();
        iObject.Name = 'Test Billing Entity';
        iObject.Stripe_Account__c = iStripe_Account.Id;
        iObject.CurrencyIsoCode = 'EUR';
        return iObject;
    }


    // Condition__c
    public static Condition__c iCondition{
        get{
            if (iCondition == null){
                iCondition = createCondition();

                insert iCondition;
                System.assert(iCondition.Id != null);
            }
            iCondition.CurrencyIsoCode = 'EUR';
            return iCondition;
        }

        set;
    }

    public static Condition__c createCondition(){
        Condition__c iObject = new Condition__c();
        iObject.Name = 'Test Condition';
        iObject.TimePeriodEarliestStartofContract__c = 1;
        iObject.TimePeriodLatestStartofContract__c = 3;
        iObject.DepositMultiplier__c = 3;
        iObject.BillingEntityRef__c = iBilling_Entity.Id;
        iObject.CurrencyIsoCode = iBilling_Entity.CurrencyIsoCode;
        return iObject;
    }


    // ContentVersion
    public static ContentVersion iContentVersion{
        get{
            if (iContentVersion == null) {
                iContentVersion = createContentVersion();

                insert iContentVersion;
                System.assert(iContentVersion.Id != null);
            }
            iContentVersion.CurrencyIsoCode = 'EUR';
            return iContentVersion;
        }
        set;
    }

    public static ContentVersion createContentVersion(){
        ContentVersion iObject = new ContentVersion(
            Title = 'Test Content',
            PathOnClient ='test',
            VersionData=EncodingUtil.base64Decode('This is version data'),
            CurrencyIsoCode = 'EUR',
            FirstPublishLocationId = UserInfo.getUserId()
        );
        return iObject;
    }


    //ContentDocumentLink
    public static ContentDocumentLink createContentDocumentLink(Id linkedEntity, Id contentDocument){
        ContentDocumentLink iObject = new ContentDocumentLink(
            LinkedEntityId = linkedEntity,
            ContentDocumentId = contentDocument
        );
        return iObject;
    }

    public static Fee__c iFee {
        get {
            if (iFee == null) {
                iFee = createFee();
                insert iFee;

                System.assert(iFee.Id != null);
            }
            iFee.CurrencyIsoCode = 'EUR';
            return iFee;
        }
        set;
    }

    public static Fee__c createFee() {
        Fee__c iObject = new Fee__c(
            Name = 'Test Fee',
            Description__c = 'Just for testing',
            Fee__c = 100,
            CurrencyIsoCode = 'EUR'
        );
        return iObject;
    }

    public static Account iPersonAccount {
        get {
            if (iPersonAccount == null) {
                iPersonAccount = createPersonAccount();
                insert iPersonAccount;

                System.assert(iPersonAccount.Id != null);
            }
            iPersonAccount.CurrencyIsoCode = 'EUR';
            iPersonAccount.RecordTypeId ='0121i000000Y28NAAS'; //Added By sithija 23.08.2023
            return iPersonAccount;
        }
        set;
    }

    public static Account createPersonAccount() {
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Account'
                AND IsPersonType = true AND Name ='Customer'
        ];
        Account iObject = new Account(
            FirstName = 'Test',
            LastName = 'Account',
            PersonEmail = 'test.account@example.com',
            RecordTypeId = rt.Id,
            CurrencyIsoCode = 'EUR'
        );
        return iObject;
    }

    public static Contract createContract(Id accId, Id oppId, Id roomId, Id stripeAccId ) {
        Contract iObject = new Contract(
            Name = 'Test Contract',
            AccountId = accId,
            Room__c = roomId,
            Opportunity__c = oppId,
            Stripe_Account__c = stripeAccId,
            CurrencyIsoCode = 'EUR'
        );
        return iObject;
    }

    public static Product2 iProduct {
        get {
            if (iProduct == null) {
                iProduct = createProduct();
                insert iProduct;

                System.assert(iProduct.Id != null);
            }
            iProduct.CurrencyIsoCode = 'EUR';
            return iProduct;
        }
        set;
    }

    public static Product2 createProduct() {
        Product2 iObject = new Product2(
            Name = 'Test',
            IsActive = true,
            CurrencyIsoCode = 'EUR'
        );
        return iObject;
    }

    public static ContractItem__c createContractItem(Contract contract, Id productId, Id roomId) {
        ContractItem__c iObject = new ContractItem__c(
            ContractRef__c = contract.Id,
            ProductRef__c = productId,
            PriceTrig__c = 15,
            RoomRef__c = roomId,
            CurrencyIsoCode = contract.CurrencyIsoCode
        );
        return iObject;
    }

    // OpportunityLineItem
    public static OpportunityLineItem iOpportunityLineItem{
        get{
            if (iOpportunityLineItem == null){
                iOpportunityLineItem = createOpportunityLineItem();

                insert iOpportunityLineItem;
                System.assert(iOpportunityLineItem.Id != null);
            }
            return iOpportunityLineItem;
        }

        set;
    }

    public static OpportunityLineItem createOpportunityLineItem(){
        OpportunityLineItem iObject = new OpportunityLineItem();
        iObject.OpportunityId = iOpportunity.Id;
        iObject.Product2Id = iProduct2.Id;
        iObject.Quantity = 1;
        iObject.TotalPrice = 100;
        iObject.PricebookEntryId = iPricebookEntry.Id;
        return iObject;
    }


    // PricebookEntry
    public static PricebookEntry iPricebookEntry{
        get{
            if (iPricebookEntry == null){
                iPricebookEntry = createPricebookEntry();

                insert iPricebookEntry;
                System.assert(iPricebookEntry.Id != null);
            }
            return iPricebookEntry;
        }

        set;
    }

    public static PricebookEntry createPricebookEntry(){
        PricebookEntry iObject = new PricebookEntry();
        iObject.Product2Id = iProduct2.Id;
        iObject.UnitPrice = 100.00;
        iObject.IsActive = true;
        iObject.Pricebook2Id = Test.getStandardPricebookId();
        iObject.CurrencyIsoCode = 'EUR';
        return iObject;
    }

    // Product2
    public static Product2 iProduct2{
        get{
            if (iProduct2 == null){
                iProduct2 = createProduct2();

                insert iProduct2;
                System.assert(iProduct2.Id != null);
            }
            iProduct2.CurrencyIsoCode = 'EUR';
            return iProduct2;
        }

        set;
    }

    public static Product2 createProduct2(){
        Product2 iObject = new Product2();
        iObject.Name = 'Product Name';
        iObject.CurrencyIsoCode = 'EUR';
        return iObject;
    }
}