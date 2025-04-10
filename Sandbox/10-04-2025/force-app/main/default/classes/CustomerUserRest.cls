@RestResource(urlMapping='/latest/users')
global without sharing class CustomerUserRest {

    @HttpPost
    global static void handlePost() {
        Controller controller = new Controller();
        controller.init(RestContext.request, RestContext.response);
        controller.handlePost();
    }
    
    public without sharing class Controller extends IntegrationApiController {

        protected override Blob doHandlePost(String payload, String userName) {
            IntegrationService service = new IntegrationService();
            IntegrationModels.UserRequestPayload requestPayload = (IntegrationModels.UserRequestPayload) JSON.deserialize(
                payload, IntegrationModels.UserRequestPayload.class
            );

            IntegrationModels.UserResponsePayload responsePayload = service.upsertUser(requestPayload);
            return Blob.valueOf(JSON.serialize(responsePayload));
        }
    }
}