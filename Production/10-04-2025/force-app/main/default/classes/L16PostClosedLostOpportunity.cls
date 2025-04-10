public without sharing class L16PostClosedLostOpportunity {
    
    public class Requests {
        
        @InvocableVariable(label='Opportunity Id' required=true)
        public string RecordId;
    }
    
    @InvocableMethod(label='L16 - Post Closed Lost Opportunity' iconName='slds:standard:opportunity')
    public static void execute (List<Requests> requestList) {
        
        for(Requests req : requestList){
            PostDataToL16(req.RecordId);
        }
    }
    
    
    @future(Callout=true)
    public static void PostDataToL16(String RecordId){
        
        Opportunity opp = [SELECT Id, Customer_Id__c, Home_Committed__c, Home_Committed__r.Home_ID__c, Account.PersonEmail, Lease_Interval_Id__c
                   FROM Opportunity WHERE Id = :RecordId limit 1];

        string homeId = '';
        if(opp.Home_Committed__c != NULL && opp.Home_Committed__r.Home_ID__c != NULL)
            homeId = opp.Home_Committed__r.Home_ID__c;
        String customer_id = '';
        if(opp.Customer_Id__c != NULL)
            customer_id = opp.Customer_Id__c;
        String lease_interval_id = '';
        if(opp.Lease_Interval_Id__c != NULL)
            lease_interval_id = opp.Lease_Interval_Id__c;
        String email = opp.Account.PersonEmail == NULL ? '' : opp.Account.PersonEmail;
        
        String JSONRequest = '{'+
            '"operation": "member_application/sfdc/cancel_lead",'+
            '"variables": {'+
                '"property_id": "'+homeId+'",'+
                '"customer_id": "'+customer_id+'",'+
                '"interval_id": "'+lease_interval_id+'",'+
                '"email": "'+email+'"'+
            '}'+
        '}';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Common_Louis');
        req.setMethod('POST');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('X-SFDC-SECRET-TOKEN', '{!$Credential.Password}');
        req.setTimeout(120000);
        system.debug(JSONRequest);
        req.setBody(JSONRequest);
        

        Http http = new Http();
        
        if(!test.isRunningTest()){
            HTTPResponse res = http.send(req);
            System.debug(res.getStatusCode());
            System.debug(res.getBody());
            
            /*
            if(String.isNotBlank(RecordId) && RecordId.StartsWith('006')){
                Opportunity OppToUpdate = new Opportunity();
                OppToUpdate.Id = RecordId;
                //OppToUpdate.L16_Entrata_API_Response__c = res.getBody();
                update OppToUpdate;
            }
            */
        }
        
    }
    
}