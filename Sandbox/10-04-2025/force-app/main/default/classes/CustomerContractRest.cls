@RestResource(urlMapping='/latest/contracts')
global without sharing class CustomerContractRest {

    @HttpPost
    global static void handlePost() {
        Controller controller = new Controller();
        controller.init(RestContext.request, RestContext.response);
        controller.handlePost();
    }

    public without sharing class Controller extends IntegrationApiController {

        protected override Blob doHandlePost(String payload, String userName) {
            IntegrationService service = new IntegrationService();
            IntegrationModels.ContractRequestPayload requestPayload = (IntegrationModels.ContractRequestPayload) JSON.deserialize(
                payload, IntegrationModels.ContractRequestPayload.class
            );

            IntegrationModels.ContractResponsePayload responsePayload = service.insertContract(requestPayload, userName);
            return Blob.valueOf(JSON.serialize(responsePayload));
        }
    }
}