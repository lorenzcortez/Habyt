@RestResource(urlMapping='/latest/rooms')
global without sharing class CustomerRoomRest {

    @HttpGet
    global static void handleGet() {
        Controller controller = new Controller();
        controller.init(RestContext.request, RestContext.response);
        controller.handleGet();
    }

    public without sharing class Controller extends IntegrationApiController {

        protected override Blob doHandleGet(Map<String, String> parameters) {
            IntegrationModels.RoomRequestPayload params = new IntegrationModels.RoomRequestPayload(parameters);
            IntegrationService service = new IntegrationService();
            IntegrationModels.RoomResponsePayload responsePayload = service.retrieveRooms(params);
            return Blob.valueOf(responsePayload.toJson());
        }
    }
}