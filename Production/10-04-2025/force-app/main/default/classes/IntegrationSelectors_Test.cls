@isTest
public class IntegrationSelectors_Test {
    @IsTest
    static void getClausesForRequest_UnitTest(){
        Integer size = 11;
        Integer page = 2;
        Map<String, String> parameters = new Map<String, String> {
            'size' => String.valueOf(size),
            'page' => String.valueOf(page),
            'sort' => 'streetAddress,asc;brand,desc'
        };

        IntegrationModels.RoomRequestPayload input = new IntegrationModels.RoomRequestPayload(parameters);

        Test.startTest();

        Paua_Selector.QueryClauses clauses = IntegrationSelectors.getClausesForRequest(input);

        Test.stopTest();
        
        System.assertEquals(size, clauses.limitClause, 'Limit Mismatch');
        System.assertEquals(size*page, clauses.offsetClause, 'Offset Mismatch');
    }

    @IsTest
    static void getSelectorForRequest_ROOM_UnitTest() {
        Map<String, String> parameters = new Map<String, String> {
            'referenceId' => 'test-ref',
            'notReferenceId' => 'not-test-ref',
            'type' => IntegrationModels.TYPE_ROOM,
            'countryCode' => 'test-country',
            'brand' => 'testBrand',
            'streetAddress' => 'Teststrasse',
            'postalCode' => '10101',
            'city' => 'Testort',
            'district' => 'Testburg',
            'latitudeFrom' => '-90',
            'latitudeTo' => '90',
            'longitudeFrom' => '-180',
            'longitudeTo' => '180',
            'sizeFrom' => '0',
            'sizeTo' => '100',
            'bedroomsFrom' => '0',
            'bedroomsTo' => '10',
            'availableDateFrom' => IntegrationModels.serializeDate(System.today()),
            'availableDateTo' => IntegrationModels.serializeDate(System.today().addDays(1)),
            'latestUpdateFrom' => IntegrationModels.serializeDatetime(System.now().addDays(-15)),
            'latestUpdateTo' => IntegrationModels.serializeDatetime(System.now())
        };

        IntegrationModels.RoomRequestPayload input = new IntegrationModels.RoomRequestPayload(parameters);
        Test.startTest();

        Paua_Selector selector = IntegrationSelectors.getSelectorForRequest(input);

        Test.stopTest();
        
        System.assert(selector instanceOf IntegrationSelectors.RoomByDynamicInput, 'Wrong selector chosen');
    }

    /* @IsTest
    static void getSelectorForRequest_UNIT_UnitTest() {
        Map<String, String> parameters = new Map<String, String> {
            'type' => IntegrationModels.TYPE_UNIT
        };
        IntegrationModels.RoomRequestPayload input = new IntegrationModels.RoomRequestPayload(parameters);

        Test.startTest();

        Paua_Selector selector = IntegrationSelectors.getSelectorForRequest(input);

        Test.stopTest();
        
        System.assert(selector instanceOf IntegrationSelectors.ApartmentByDynamicInput, 'Wrong selector chosen');
    } */

    @IsTest
    static void RoomByDynamicInput_Count_UnitTest(){
        Room__c room = TestRecord_Factory.iRoom;
        Map<String, String> parameters = new Map<String, String> {
            'referenceId' => room.Name,
            'latestUpdateFrom' => IntegrationModels.serializeDatetime(System.now().addDays(-15)),
            'latestUpdateTo' => IntegrationModels.serializeDatetime(System.now().addDays(1))
        };
        IntegrationModels.RoomRequestPayload input = new IntegrationModels.RoomRequestPayload(parameters);
        Paua_Selector selector = IntegrationSelectors.getSelectorForRequest(input);
        
        Test.startTest();
        Integer actual = selector.count();
        Test.stopTest();
        
        System.assertEquals(1, actual, 'Wrong number of rooms found');
    }

    @IsTest
    static void RoomByDynamicInput_Query_UnitTest(){
        Room__c room = TestRecord_Factory.iRoom;
        Map<String, String> parameters = new Map<String, String> {
            'referenceId' => room.Name,
            'notReferenceId' => 'not-test-ref',
            'latestUpdateFrom' => IntegrationModels.serializeDatetime(System.now().addDays(-15)),
            'latestUpdateTo' => IntegrationModels.serializeDatetime(System.now().addDays(1))
        };
        IntegrationModels.RoomRequestPayload input = new IntegrationModels.RoomRequestPayload(parameters);
        Paua_Selector selector = IntegrationSelectors.getSelectorForRequest(input);
        
        Test.startTest();
        List<SObject> results = selector.query();
        Test.stopTest();
        
        System.assertEquals(room.Id, results[0]?.Id, 'Wrong Room found (or none)');
    }

    @IsTest
    static void RoomByDynamicInput_AllowedStatuses_Query_UnitTest(){
        Integer expectedSize = 2;
        List<Room__c> rooms = new List<Room__c>();

        Room__c room = TestRecord_Factory.createRoom();
        room.Status__c = IntegrationService.STATUS_ONLINE;
        rooms.add(room);

        Room__c room2 = TestRecord_Factory.createRoom();
        room2.Status__c = IntegrationService.STATUS_ONLINE;
        rooms.add(room2);

        upsert rooms;

        Map<String, String> parameters = new Map<String, String> {
            'latestUpdateFrom' => IntegrationModels.serializeDatetime(System.now().addDays(-15)),
            'latestUpdateTo' => IntegrationModels.serializeDatetime(System.now().addDays(1))
        };
        IntegrationModels.RoomRequestPayload input = new IntegrationModels.RoomRequestPayload(parameters);
        Paua_Selector selector = IntegrationSelectors.getSelectorForRequest(input);

        Test.startTest();
        List<SObject> results = selector.query();
        Test.stopTest();

        System.assertEquals(expectedSize, results.size(), 'Result count mismatch');
    }

    /* @IsTest
    static void ApartmentByDynamicInput_Count_UnitTest(){
        Apartment__c apartment = TestRecord_Factory.iApartment;
        Map<String, String> parameters = new Map<String, String> {
            'referenceId' => apartment.Name,
            'type' => IntegrationModels.TYPE_UNIT,
            'latestUpdateFrom' => IntegrationModels.serializeDatetime(System.now().addDays(-15)),
            'latestUpdateTo' => IntegrationModels.serializeDatetime(System.now().addDays(1))
        };
        IntegrationModels.RoomRequestPayload input = new IntegrationModels.RoomRequestPayload(parameters);
        Paua_Selector selector = IntegrationSelectors.getSelectorForRequest(input);
        
        Test.startTest();
        Integer actual = selector.count();
        Test.stopTest();
        
        System.assertEquals(1, actual, 'Wrong number of apartments found');
    }

    @IsTest
    static void ApartmentByDynamicInput_Query_UnitTest(){
        Apartment__c apartment = TestRecord_Factory.iApartment;
        Map<String, String> parameters = new Map<String, String> {
            'referenceId' => apartment.Name,
            'notReferenceId' => 'not-test-ref',
            'type' => IntegrationModels.TYPE_UNIT,
            'latestUpdateFrom' => IntegrationModels.serializeDatetime(System.now().addDays(-15)),
            'latestUpdateTo' => IntegrationModels.serializeDatetime(System.now().addDays(1))
        };
        IntegrationModels.RoomRequestPayload input = new IntegrationModels.RoomRequestPayload(parameters);
        Paua_Selector selector = IntegrationSelectors.getSelectorForRequest(input);
        
        Test.startTest();
        List<SObject> results = selector.query();
        Test.stopTest();
        
        System.assertEquals(apartment.Id, results[0]?.Id, 'Wrong Apartment found (or none)');
    } */
}