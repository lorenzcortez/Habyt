public without sharing class GeneraricAPIInvokable {
    @InvocableMethod
    public static void execute (List<Request> requests) {
        SubscriptionsSettings__c setting = SubscriptionsSettings__c.getOrgDefaults();
        for (Request request : requests) {
            String url = setting.SFDC_Insert_URL__c;
            if(!request.isNew){
                url = setting.SFDC_Update__c;
            }
            executeAPICallout(url, request.recordId);
        }
    }
    
    @future(callout = true)
    public static void executeAPICallout(String url, Id recordId){
        try {
            APIBody newAPIBody = new APIBody();
            newAPIBody.contract_item_id = recordId;
            
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req.setEndpoint(url);
            req.setMethod('POST');
            //req.setHeader('Authorization', 'Bearer sk_test_51NpBdTIiLqF2ZmROAQnPeeJjajfn6YayLZO7SmDj6ajgPR6UqtHP9ScUV1qZQBvkHSz6GTjplePlG0N2QWokMRsZ00NJlFdSiZ');
            //req.setHeader('Stripe-Version', '2019-05-16 ');
            req.setHeader('Content-Type','application/json');
            req.setHeader('Accept', 'application/json');
            
            NewAPIBody newBody = new NewAPIBody();
            newBody.contract_item_id = recordId;
            
            req.setBody(JSON.serialize(newBody));
            req.setTimeout(100000);
            res = h.send(req);
            System.debug('setBody' + JSON.serialize(newAPIBody, true));
            System.debug('res.getBody()' + res.getStatusCode());
            System.debug('res.getBody()' + res.getBody());
            
        } catch (Exception e) {
            System.debug('Exception occurred while making API callout: ' + e.getMessage());
        }
    }
    
    public class APIBody {
        public String contract_item_id {get; set;}
    }

    public class Request {
        @InvocableVariable(label='RecordId to Pass to API' required=true)
        public String recordId;
        @InvocableVariable(label='Is new?' required=true)
        public Boolean isNew;
    }
    
  public class Result {
    @InvocableVariable(label='String for Output'  required=false)
    public List<String> outputMessageString;
  }

}