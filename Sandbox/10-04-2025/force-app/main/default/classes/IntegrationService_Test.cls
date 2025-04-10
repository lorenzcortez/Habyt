@IsTest
public class IntegrationService_Test {
    public static IntegrationModels.UserRequestPayload userInput {
        get {
            if (userInput == null) {
                userInput = new IntegrationModels.UserRequestPayload();
                userInput.firstName = 'Tom';
                userInput.lastName = 'Swanson';
                userInput.email = 'email@example.org';
                userInput.companyName = 'Medici Living GmbH';
                userInput.addressLine1 = 'Zossener Str. 55';
                userInput.addressLine2 = 'Building B';
                userInput.addressLine3 = 'C/O Quarters';
                userInput.postalCode = '10961';
                userInput.city = 'Berlin';
                userInput.state = 'Berlin';
                userInput.countryCode = 'Germany';
                userInput.phone = '+495555555555';
                userInput.type = 'MOBILE';
                userInput.idNumber = 'L38F3N4MG';
                userInput.nationality = 'German';
                userInput.gender = 'FEMALE';
                userInput.birthday = '1985-01-03';
                userInput.occupation = 'Employed';
                userInput.incomeLevel = '2500 - 5000';
                userInput.referenceId = 'DE-01-001-01';
            }
            return userInput;
        }
        set;
    }

    @IsTest
    static void upsertUser_UnitTest() {
        IntegrationService service = new IntegrationService();

        Test.startTest();

        IntegrationModels.UserResponsePayload payload = service.upsertUser(userInput);

        Test.stopTest();

        Account account = [SELECT Id, PersonEmail, UserId__c, CustomerStatusPick__c FROM Account WHERE PersonEmail = :userInput.email];
        System.assertNotEquals(null, account, 'Account was successfully inserted');
        System.assertEquals(Long.valueOf(account.UserId__c), payload.userId, 'UserId mismatch');
        System.assertEquals(account.PersonEmail, payload.username, 'Username mismatch');
        System.assertEquals(account.CustomerStatusPick__c, payload.status, 'Status mismatch');
    }

    @IsTest
    static void insertContract_UnitTest() {
        Account account = [SELECT Id, UserId__c FROM Account WHERE Id = :TestRecord_Factory.iPersonAccount.Id];

        Room__c room = TestRecord_Factory.iRoom;
        room.AvailableDateTrig__c = System.today().addDays(-1);
        update room;

        IntegrationModels.ContractRequestPayload input = new IntegrationModels.ContractRequestPayload();
        input.userId = Long.valueOf(account.UserId__c);
        input.referenceId = room.Name;
        input.startOfContract = IntegrationModels.serializeDate(System.today().addDays(15));
        input.plannedEndOfContract = IntegrationModels.serializeDate(System.today().addYears(1));

        IntegrationService service = new IntegrationService();

        Test.startTest();

        IntegrationModels.ContractResponsePayload payload = service.insertContract(input);

        Test.stopTest();

        Opportunity opp = [SELECT ContractIdAuto__c, RecordTypeId FROM Opportunity WHERE AccountId = :account.Id AND Room__c = :room.Id];

        System.assertNotEquals(null, opp, 'Expected opportunity was not created');
        System.assertEquals(CustomerOpportunityService.RECORDTYPE_ID, opp.RecordTypeId, 'Opportunity has wrong record type');
        System.assertEquals(Long.valueOf(opp.ContractIdAuto__c), payload.contractId, 'ContractId mismatched');
    }

    @IsTest
    static void insertContractException_UnitTest() {
        Account account = [SELECT Id, UserId__c FROM Account WHERE Id = :TestRecord_Factory.iPersonAccount.Id];

        Room__c room = TestRecord_Factory.iRoom;
        room.AvailableDateTrig__c = System.today().addDays(-1);
        update room;

        IntegrationModels.ContractRequestPayload input = new IntegrationModels.ContractRequestPayload();
        input.userId = Long.valueOf(account.UserId__c);
        input.referenceId = room.Name;
        input.startOfContract = IntegrationModels.serializeDate(System.today().addDays(15));
        input.plannedEndOfContract = IntegrationModels.serializeDate(System.today().addYears(1));

        IntegrationService service = new IntegrationService();
        String expectedErrorMessage = 'The piece is not bookable at this time';
        Test.startTest();
        try {
            IntegrationModels.ContractResponsePayload payload = service.insertContract(input);
            System.assert(true, 'No exception is thrown');
        } catch(IntegrationModels.BadRequestException e) {
            System.assertEquals(expectedErrorMessage, e.payload.errorMessage, 'Error message mismatch');
        } catch(Exception e) {
            System.debug(e);
            System.assert(false, 'Wrong exception is thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void insertContractOnline_UnitTest() {
        Account account = [SELECT Id, UserId__c FROM Account WHERE Id = :TestRecord_Factory.iPersonAccount.Id];

        Room__c room = TestRecord_Factory.iRoom;
        room.AvailableDateTrig__c = System.today().addDays(-1);
        room.Status__c = IntegrationService.STATUS_ONLINE;
        update room;

        IntegrationModels.ContractRequestPayload input = new IntegrationModels.ContractRequestPayload();
        input.userId = Long.valueOf(account.UserId__c);
        input.referenceId = room.Name;
        input.startOfContract = IntegrationModels.serializeDate(System.today().addDays(15));
        input.plannedEndOfContract = IntegrationModels.serializeDate(System.today().addYears(1));

        IntegrationService service = new IntegrationService();

        Test.startTest();

        IntegrationModels.ContractResponsePayload payload = service.insertContract(input);

        Test.stopTest();

        Opportunity opp = [SELECT ContractIdAuto__c, RecordTypeId FROM Opportunity WHERE AccountId = :account.Id AND Room__c = :room.Id];

        System.assertNotEquals(null, opp, 'Expected opportunity was not created');
        System.assertEquals(CustomerOpportunityService.RECORDTYPE_ID, opp.RecordTypeId, 'Opportunity has wrong record type');
        System.assertEquals(Long.valueOf(opp.ContractIdAuto__c), payload.contractId, 'ContractId mismatched');
    }

    @IsTest
    static void retrieveRooms_UnitTest() {
        Room__c room = TestRecord_Factory.iRoom;
        Property__c property = TestRecord_Factory.iProperty;

        Map<String, String> parameters = new Map<String, String> {
            'referenceId' => room.Name
        };

        IntegrationModels.RoomRequestPayload input = new IntegrationModels.RoomRequestPayload(parameters);
        
        IntegrationService service = new IntegrationService();

        Test.startTest();

        IntegrationModels.RoomResponsePayload payload = service.retrieveRooms(input);

        Test.stopTest();
        
        // TODO: implement assertions
    }

    @IsTest
    static void calculateFirstRent_UnitTest() {
        Room__c room = TestRecord_Factory.iRoom;
        room.Price__c = 1000;
        update room;

        Map<String, String> parameters = new Map<String, String> {
            'referenceId' => room.Name,
            'startOfContract' => IntegrationModels.serializeDate(System.today())
        };

        IntegrationModels.CalculationFirstMonthRequestPayload input = new IntegrationModels.CalculationFirstMonthRequestPayload(parameters);
        
        IntegrationService service = new IntegrationService();

        Test.startTest();

        IntegrationModels.CalculationFirstMonthResponsePayload payload = service.calculateFirstRent(input);

        Test.stopTest();
        
        room = [SELECT Id, NetPrice__c FROM Room__c WHERE Id = :room.Id];
        Decimal expected = service.calculateFirstRent(room, System.today());

        System.assertEquals(expected.setScale(4), payload?.firstMonthRent, 'Expected rent does not match calculated');
    }

    @IsTest
    static void getDistrictsByCity_UnitTest() {
        Neighbourhood__c hood = TestRecord_Factory.iNeighbourhood;
        Integer expectedSize = 1;
        Id expectedId = hood.Id;

        IntegrationService service = new IntegrationService();
        Test.startTest();
        Map<String, List<Neighbourhood__c>> returned = service.getDistrictsByCity();
        Test.stopTest();

        System.assertNotEquals(null, returned, 'Map is null');
        System.assertEquals(expectedSize, returned.size(), 'Map does not have expected size');
        System.assertEquals(expectedId, (returned.values().get(0).get(0)).Id, 'Map does not store the right record');
    }

    @IsTest
    static void getCitiesByBrand_UnitTest() {
        Property__c property = TestRecord_Factory.iProperty;
        String brandApiName = 'Habyt';
        integer expectedSize = 1;
        String expectedCity = property.City__c;

        IntegrationService service = new IntegrationService();
        Test.startTest();
        List<String> returned = service.getCitiesByBrand(brandApiName);
        Test.stopTest();

        System.assertNotEquals(null, returned, 'List is null');
        System.assertEquals(expectedSize, returned.size(), 'Returned list does not have expected size');
        //System.assertEquals(expectedCity, returned.get(0), 'City mismatch');
    }

    @IsTest
    static void getPhoneCodes_UnitTest() {
        Integer expectedSize = [SELECT COUNT() FROM Phone_Country_Code__mdt];

        IntegrationService service = new IntegrationService();
        Test.startTest();
        List<Phone_Country_Code__mdt> returned = service.getPhoneCodes();
        Test.stopTest();

        System.assertNotEquals(null, returned, 'List is null');
        System.assertEquals(expectedSize, returned.size(), 'Returned list does not have expected size');
    }
}