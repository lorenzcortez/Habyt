@IsTest
public class IntegrationApi_Test {
    public virtual class APIBasicCredentialOverride extends Paua_Selector {
        public override List<SObject> query(Paua_Selector.QueryClauses clauses) {
            return new List<SObject> {
                new APIBasicCredential__mdt(
                    Username__c = 'test',
                    Password__c = 'test'
                )
            };
        }
    }

    private static void generateRequest(String uri, String method) {
        RestRequest request = new RestRequest();
        request.headers.put('auth', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('test:test')));
        RestResponse response = new RestResponse();
        
        request.requestURI = uri;
        request.httpMethod = method;
        
        RestContext.request = request;
        RestContext.response = response;
    }

    @IsTest
    static void handleAuthorizationGET_Unauthorized_UnitTest() {
        generateRequest('/latest', 'GET');

        IntegrationApiController controller = new IntegrationApiController();
        controller.init(RestContext.request, RestContext.response);

        Test.startTest();
        controller.handleGet();
        Test.stopTest();

        System.assertEquals(IntegrationModels.STATUSCODE_UNAUTHORIZED, RestContext.response.statusCode, 'Expected unauthorized not received');
    }

    @IsTest
    static void handleAuthorizationPOST_Unauthorized_UnitTest() {
        generateRequest('/latest', 'POST');

        IntegrationApiController controller = new IntegrationApiController();
        controller.init(RestContext.request, RestContext.response);

        Test.startTest();
        controller.handlePost();
        Test.stopTest();

        System.assertEquals(IntegrationModels.STATUSCODE_UNAUTHORIZED, RestContext.response.statusCode, 'Expected unauthorized not received');
    }

    @IsTest
    static void customerUserRest_Success_UnitTest() {
        generateRequest('/latest/users', 'POST');

        RestContext.request.requestBody = Blob.valueOf(Json.serialize(IntegrationService_Test.userInput));

        Test.startTest();

        Paua_SelectorHandler.overrideSelectorType(
            APIBasicCredentialSelector.APIBasicCredentialByUsernameAndPass.class, 
            APIBasicCredentialOverride.class
        );
        CustomerUserRest.handlePost();

        Test.stopTest();
       
        System.assertEquals(200, RestContext.response.statusCode, 'Response was not successful');
    }

    @IsTest
    static void customerContractRest_Success_UnitTest() {
        generateRequest('/latest/contracts', 'POST');

        Account account = [SELECT Id, UserId__c FROM Account WHERE Id = :TestRecord_Factory.iPersonAccount.Id];

        Room__c piece = TestRecord_Factory.iRoom;
        piece.AvailableDateTrig__c = System.today().addDays(-1);
        piece.TypePick__c = IntegrationModels.SHARE_PRIVATE_APARTMENT;
        update piece;

        IntegrationModels.ContractRequestPayload input = new IntegrationModels.ContractRequestPayload();
        input.userId = Long.valueOf(account.UserId__c);
        input.referenceId = piece.Name;
        input.startOfContract = IntegrationModels.serializeDate(System.today().addDays(15));
        input.plannedEndOfContract = IntegrationModels.serializeDate(System.today().addYears(1));

        RestContext.request.requestBody = Blob.valueOf(Json.serialize(input));

        Test.startTest();

        Paua_SelectorHandler.overrideSelectorType(
            APIBasicCredentialSelector.APIBasicCredentialByUsernameAndPass.class, 
            APIBasicCredentialOverride.class
        );
        CustomerContractRest.handlePost();

        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode, 'Response was not successful');
    }

    @IsTest
    static void customerRoomRest_Success_UnitTest() {
        generateRequest('/latest/rooms', 'GET');

        Room__c piece = TestRecord_Factory.iRoom;
        piece.TypePick__c = IntegrationModels.SHARE_PRIVATE_APARTMENT;
        update piece;

        RestContext.request.params.put('type', 'UNIT');

        Test.startTest();

        Paua_SelectorHandler.overrideSelectorType(
            APIBasicCredentialSelector.APIBasicCredentialByUsernameAndPass.class, 
            APIBasicCredentialOverride.class
        );
        CustomerRoomRest.handleGet();

        Test.stopTest();
       
        System.assertEquals(200, RestContext.response.statusCode, 'Response was not successful');
    }

    @IsTest
    static void customerRoomRest_Unsuccess_UnitTest() {
        generateRequest('/latest/rooms', 'GET');

        Room__c piece = TestRecord_Factory.iRoom;
        piece.Status__c = 'Reserved';
        piece.TypePick__c = IntegrationModels.SHARE_PRIVATE_APARTMENT;
        update piece;

        RestContext.request.params.put('type', 'UNIT');

        Test.startTest();

        Paua_SelectorHandler.overrideSelectorType(
            APIBasicCredentialSelector.APIBasicCredentialByUsernameAndPass.class, 
            APIBasicCredentialOverride.class
        );
        CustomerRoomRest.handleGet();

        Test.stopTest();
       
        System.debug(EncodingUtil.base64Decode(EncodingUtil.base64Encode(RestContext.response.responseBody)).toString());
        System.assertEquals(200, RestContext.response.statusCode, 'Response was not successful');
    }

    @IsTest
    static void customerCalculationsRest_Success_UnitTest() {
        generateRequest('/latest/calculations/firstRent', 'GET');

        Room__c piece = TestRecord_Factory.iRoom;
        piece.Price__c = 1000;
        piece.TypePick__c = IntegrationModels.SHARE_PRIVATE_APARTMENT;
        update piece;

        RestContext.request.params.put('referenceId', piece.Name);
        RestContext.request.params.put('startOfContract', IntegrationModels.serializeDate(System.today().addDays(3)));

        Test.startTest();

        Paua_SelectorHandler.overrideSelectorType(
            APIBasicCredentialSelector.APIBasicCredentialByUsernameAndPass.class, 
            APIBasicCredentialOverride.class
        );
        CustomerCalculationsRest.handleGet();

        Test.stopTest();
       
        System.assertEquals(200, RestContext.response.statusCode, 'Response was not successful');
    }
}