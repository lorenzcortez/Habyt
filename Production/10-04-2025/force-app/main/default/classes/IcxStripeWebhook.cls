@RestResource(urlMapping='/swh/v1/*')
global class IcxStripeWebhook {        
    @HttpPost
    global static void postHandler() {
        RestResponse response = RestContext.response;
        response.addHeader('Content-type','application/json');
        try {
            Map<String, String> header = RestContext.request.headers;

            Map<String, Object> event = (Map<String, Object>) JSON.deserializeUntyped(
                RestContext.request.requestBody.toString()
            );
            StripeEventHandler.handle(RestContext.request.requestBody.toString());
        } catch (Exception e) {
            if(External_API_Key__c.getOrgDefaults().get('STRIPE_Send_Errors__c') != null) {
                String msg = constructMessage(e);
                StripeService.sendStripeErrors(msg);
            }
            Map<String, String> error = new Map<String, String>{
                'type' => e.getTypeName(), 
                'error' => e.getMessage()
            };
            response.responseBody = Blob.valueOf(JSON.serializePretty(error));
            response.statusCode = 500;

            // Create a Stripe Log to keep track of this error
            StripeLogHandler.insertStripeLog(JSON.serializePretty(error), RestContext.request.requestBody.toString());
        }
    }

    private static String constructMessage(Exception e) {
        String msg =  e.getTypeName() + ': '  + e.getMessage() + '\n';
        msg += e.getStackTraceString() + '\n';
        msg += 'Data: \n' + RestContext.request.requestBody.toString();
        return msg;
    }
}