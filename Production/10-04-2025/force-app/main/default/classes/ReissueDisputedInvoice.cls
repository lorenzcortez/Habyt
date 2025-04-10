public with sharing class ReissueDisputedInvoice {
    @AuraEnabled
    public static Response duplicateInvoice(String invoiceId){
		System.debug('********* '+invoiceId);
        StripeInvoiceSetting__c stripeSetting = StripeInvoiceSetting__c.getInstance();

        String message              = '';
        Boolean success             = false; 
        String username             = stripeSetting.Username__c;
        String password             = stripeSetting.Password__c;
        Blob headerValue            = Blob.valueOf(username + ':' + password);
        String authorizationHeader  = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        HttpRequest req     = new HttpRequest(); 
        // Organization a_ORG  = [Select Id, Name, IsSandbox from Organization];
        // if(a_ORG.IsSandbox){
        //     System.debug('This is Sandbox');
        //     req.setEndpoint('https://staging.habyt.com/api/v2/stripe/invoices/'+ invoiceId + '/duplicate');
        // }
        // else{
        //     System.debug('This is Production'); 
        //     req.setEndpoint('https://www.habyt.com/api/v2/stripe/invoices/'+ invoiceId + '/duplicate');
        // }
        req.setEndpoint(stripeSetting.Endpoint_URL__c + 'api/v2/stripe/invoices/' + invoiceId + '/duplicate');
		System.debug('***** '+stripeSetting.Endpoint_URL__c + 'api/v2/stripe/invoices/' + invoiceId + '/duplicate');
        req.setMethod('POST');
        req.setBody('{"byUser" : "' + UserInfo.getUserEmail() +'" }');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationHeader);
        HttpResponse resp = (new Http()).send(req);
        System.debug('HttpResponse => ' + resp.getBody());
        System.debug('getStatusCode => ' + resp.getStatusCode());

        if( resp.getStatusCode() != 200 ){
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
            message = (String) results.get('message');
        }
        
        if(resp.getStatusCode() == 200 ){
            updateDisputeReissued(invoiceId);
        }

        return new Response(resp.getStatusCode(), message);
    }
    
    @future
    public static void updateDisputeReissued(String invoiceId){   
         List<Invoice__c> invList = [Select Id FROM invoice__c WHERE Stripe_Invoice_Id__c =:invoiceId 
                                     								order by createddate DESC LIMIT 1];
        if(invList.size() > 0){
            List<Dispute__c> disputeList = [Select Id FROM Dispute__c WHERE Invoice__c =:invList[0].Id
																		order by createddate DESC LIMIT 1];
            
            if(disputeList.size() > 0){
                Dispute__c disputeRec = new Dispute__c();
                disputeRec.Id = disputeList[0].Id;
				disputeRec.Reissued__c = TRUE;
				update disputeRec;             
            }
        }
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