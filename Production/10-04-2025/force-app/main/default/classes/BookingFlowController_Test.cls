@IsTest
private class BookingFlowController_Test {
    public static final String DEFAULT_CITY = 'Berlin';
    public static final String REFERENCE_ID = 'DE-01-001-01Q';
    @TestSetup
    static void setupTest() {
        Neighbourhood__c neighbourhood = TestRecord_Factory.iNeighbourhood;
        Room__c room = TestRecord_Factory.iRoom;
    }
    @IsTest
    static void getDistricts_UnitTest() {
        Test.startTest();
        Map<String, List<Neighbourhood__c>> districts = BookingFlowController.getDistricts();
        Test.stopTest();
        System.assertNotEquals(0, districts.size());
    }
    @IsTest
    static void getRooms_UnitTest() {
        Map<String, String> params = new Map<String, String>{
                'city' => DEFAULT_CITY
        };
        Test.startTest();
        IntegrationModels.RoomResponsePayload rooms = BookingFlowController.getRooms(params);
        Test.stopTest();
        System.assertNotEquals(0, rooms.content.size());
        System.assertEquals(DEFAULT_CITY, rooms.content.get(0).city, 'City unexpected');
    }
    @IsTest
    static void submitApplication_UnitTest() {
        String userPayload = '{\n' +
                '  "firstName": "Tom",\n' +
                '  "lastName": "Swanson",\n' +
                '  "email": "email@example.org",\n' +
                '  "companyName": "Medici Living GmbH",\n' +
                '  "addressLine1": "Zossener Str. 55",\n' +
                '  "addressLine2": "Building B",\n' +
                '  "addressLine3": "C/O Quarters",\n' +
                '  "postalCode": "10961",\n' +
                '  "city": "Berlin",\n' +
                '  "state": "Berlin",\n' +
                '  "countryCode": "DE",\n' +
                '  "phone": "+495555555555",\n' +
                '  "type": "MOBILE",\n' +
                '  "idNumber": "L38F3N4MG",\n' +
                '  "nationality": "German",\n' +
                '  "gender": "FEMALE",\n' +
                '  "birthday": "1985-01-03",\n' +
                '  "occupation": "STUDENT",\n' +
                '  "incomeLevel": "1000 - 2500",\n' +
                '  "referenceId": "' + REFERENCE_ID + '"\n' +
                '}';
        String startOfContract = '2022-01-01';
        Room__c room = [SELECT Id, Name FROM Room__c LIMIT 1];
        room.Name = REFERENCE_ID;
        room.AvailableDateTrig__c = Date.today().addDays(-1);
        update room;
        Test.startTest();
        IntegrationModels.ContractResponsePayload responsePayload = BookingFlowController.submitApplication(
                userPayload, startOfContract
        );
        Test.stopTest();
        List<Account> account = [
                SELECT Id, Name
                FROM Account
                WHERE Name = 'Tom Swanson'
        ];
        System.assertNotEquals(0, account.size());
    }
    @IsTest
    static void getFirstRent_UnitTest() {
        Integer price = 100;
        Integer discount = 20;
        Integer expectedRent = price - discount;
        Map<String, String> params = new Map<String, String>{
                'referenceId' => REFERENCE_ID,
                'startOfContract' => '2022-01-01'
        };
        Room__c room = [SELECT Id, Name, Price__c, Discount__c FROM Room__c LIMIT 1];
        room.Name = REFERENCE_ID;
        room.Price__c = price;
        room.Discount__c = discount;
        update room;
        Test.startTest();
        IntegrationModels.CalculationFirstMonthResponsePayload rent = BookingFlowController.getFirstRent(params);
        Test.stopTest();
        System.assertEquals(expectedRent, rent.firstMonthRent);
    }
    @IsTest
    static void getBrandCities_UnitTest() {
        Brand__c brand = [
                SELECT Id, APINameBrand__c
                FROM Brand__c
                LIMIT 1
        ];
        Test.startTest();
        List<String> brandCities = BookingFlowController.getBrandCities(brand.APINameBrand__c);
        Test.stopTest();
        System.assertNotEquals(0, brandCities.size());
        System.assert(brandCities.contains(DEFAULT_CITY));
    }
    @IsTest
    static void getPhoneCodes_UnitTest() {
        Test.startTest();
        List<Phone_Country_Code__mdt> codes = BookingFlowController.getPhoneCodes();
        Test.stopTest();
        System.assertNotEquals(0, codes.size());
    }
    @IsTest
    static void Exceptions_UnitTest() {
        Test.startTest();
        try {
            BookingFlowController.getFirstRent(null);
            System.assert(false);
        } catch (AuraHandledException e) {
            System.assert(true);
        }
        try {
            BookingFlowController.submitApplication(null, null);
            System.assert(false);
        } catch (AuraHandledException e) {
            System.assert(true);
        }
        try {
            BookingFlowController.getRooms(null);
            System.assert(false);
        } catch (AuraHandledException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
}