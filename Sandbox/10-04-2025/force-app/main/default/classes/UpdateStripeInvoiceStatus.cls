public with sharing class UpdateStripeInvoiceStatus {
    @AuraEnabled
    public static Response updateInvoiceStatus(String invoiceId, String invoiceStatus){

        StripeInvoiceSetting__c stripeSetting = StripeInvoiceSetting__c.getInstance();

        String message              = '';
        Boolean success             = false; 
        String username             = stripeSetting.Username__c;
        String password             = stripeSetting.Password__c;
        Blob headerValue            = Blob.valueOf(username + ':' + password);
        String authorizationHeader  = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        // String endpoint             = 'https://staging.habyt.com/api/v2/stripe/' + invoiceId + '/' + invoiceStatus;

        HttpRequest req     = new HttpRequest(); 
        Organization a_ORG  = [Select Id, Name, IsSandbox from Organization];
        // if(a_ORG.IsSandbox){
        //     System.debug('This is Sandbox');
        //     req.setEndpoint('https://staging.habyt.com/api/v2/stripe/invoices/'+ invoiceId + '/' + invoiceStatus);
        // }
        // else{
        //     System.debug('This is Production'); 
        //     req.setEndpoint('https://www.habyt.com/api/v2/stripe/invoices/'+ invoiceId + '/' + invoiceStatus);
        // }

        req.setEndpoint(stripeSetting.Endpoint_URL__c + 'api/v2/stripe/invoices/' + invoiceId + '/' + invoiceStatus);
        System.debug('***** '+stripeSetting.Endpoint_URL__c + 'api/v2/stripe/invoices/' + invoiceId + '/' + invoiceStatus);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationHeader);
        req.setBody('{"byUser" : "' + UserInfo.getUserEmail() +'" }');
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