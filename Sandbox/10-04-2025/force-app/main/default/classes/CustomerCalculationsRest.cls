@RestResource(urlMapping='/latest/calculations/firstRent')  // If further calculations are required we should extend this class
global without sharing class CustomerCalculationsRest {

    @HttpGet
    global static void handleGet() {
        Controller controller = new Controller();
        controller.init(RestContext.request, RestContext.response);
        controller.handleGet();
    }

    public without sharing class Controller extends IntegrationApiController {

        protected override Blob doHandleGet(Map<String, String> parameters) {
            IntegrationService service = new IntegrationService();

            IntegrationModels.CalculationFirstMonthRequestPayload params = new IntegrationModels.CalculationFirstMonthRequestPayload(parameters);
            IntegrationModels.CalculationFirstMonthResponsePayload responsePayload = service.calculateFirstRent(params);

            return Blob.valueOf(JSON.serialize(responsePayload));
        }
    }
}