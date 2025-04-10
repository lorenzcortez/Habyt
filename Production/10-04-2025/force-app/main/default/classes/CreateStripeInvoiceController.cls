public with sharing class CreateStripeInvoiceController {
    @AuraEnabled
    public static Response createInvoice(String jsonBody){
        StripeInvoiceSetting__c stripeSetting = StripeInvoiceSetting__c.getInstance();
        String message      = '';
        Boolean success     = false;
        String username     = stripeSetting.Username__c;
        String password     = stripeSetting.Password__c;
        Blob headerValue    = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        Map<String, Object> mapOfData = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
        mapOfData.put('byUser', UserInfo.getUserEmail());

        System.debug('mapOfData' + mapOfData);
        HttpRequest req = new HttpRequest(); 
        // req.setEndpoint('https://habyt-web-git-hdps-373-defcreate-stripe-invoice-from-sfdc-habyt.vercel.app/api/v2/stripe/invoice');
        
        // Organization a_ORG = [Select Id, Name, IsSandbox from Organization];
        // if(a_ORG.IsSandbox){
        //     System.debug('This is Sandbox'); 
        //     req.setEndpoint('https://staging.habyt.com/api/v2/stripe/invoice');
        // }
        // else{
        //     System.debug('This is Production'); 
        //     req.setEndpoint('https://www.habyt.com/api/v2/stripe/invoice');
        // }

        req.setEndpoint(stripeSetting.Endpoint_URL__c + 'api/v2/stripe/invoice');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationHeader);
        req.setBody(JSON.serialize(mapOfData));
        HttpResponse resp = (new Http()).send(req);

         System.debug('req => ' + req.getEndpoint());
        System.debug('req => ' + req.getBody());
        System.debug('HttpResponse => ' + resp.getBody());
        System.debug('getStatusCode => ' + resp.getStatusCode());

        if( resp.getStatusCode() != 200 ){
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
            message = (String) results.get('message');
        }

        return new Response(resp.getStatusCode(), message);
    }

    public class Response {
        @AuraEnabled
        public Integer statusCode {get; set;}
        @AuraEnabled
        public String message {get; set;}

        public Response(Integer statusCode,  String message){
            this.statusCode = statusCode;
            this.message = message;
        }
    }
}