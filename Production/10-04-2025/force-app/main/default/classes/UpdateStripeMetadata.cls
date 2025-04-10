public with sharing class UpdateStripeMetadata {
    @AuraEnabled
    public static Response execute(String invoiceId, String billingMonthValue, String billingYearValue){
        StripeInvoiceSetting__c stripeSetting = StripeInvoiceSetting__c.getInstance();
        String message              = '';
        Boolean success             = false; 
        String username             = stripeSetting.Username__c;
        String password             = stripeSetting.Password__c;
        Blob headerValue            = Blob.valueOf(username + ':' + password);
        String authorizationHeader  = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        String jsonBody             = '{"byUser" : "' + UserInfo.getUserEmail() +'", "metadata" : { "BillingYear" : "' + billingYearValue + '", "BillingMonth" : "' + billingMonthValue + '" }}'; 

        HttpRequest req     = new HttpRequest(); 
        Organization a_ORG  = [Select Id, Name, IsSandbox from Organization];
   
        req.setEndpoint(stripeSetting.Endpoint_URL__c + 'api/v2/stripe/invoices/' + invoiceId + '/update-metadata');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationHeader);
        req.setBody(jsonBody);
        HttpResponse resp = (new Http()).send(req);
        
        System.debug('body => ' + req.getBody());
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