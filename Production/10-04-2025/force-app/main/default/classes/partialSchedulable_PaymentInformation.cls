/**
*  Schedulable batch job for getting payment plan payment information for opened cases with payment plan Id
*  @author    Einsteamn
*  
*/
public class partialSchedulable_PaymentInformation implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {

    public void execute(SchedulableContext sc) {
        runJob();
    }
    
    @TestVisible
    private void runJob() {
        Database.executeBatch(this,50);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        string query = 'Select id,Amount_Refunded__c,Amount_Paid__c, Balance__c,Payment_Plan_ID__c,Partial_ly_API_Status__c from Case where IsClosed = False and Payment_Plan_ID__c != null';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Case> cases = (List<Case>)scope;
        system.debug(':size:::::'+cases.size());
        list<Case> UpdateableCases = new list<Case>();
        
        for(Case c: cases){
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://partial.ly/api/payment_plan/'+c.Payment_Plan_ID__c);
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer e63ZQudtH9jQ+yV7OSxWag');
            
            HttpResponse response = null;
        
            if(!test.IsRunningTest()){
                response = http.send(request);
            }
            else{
                
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-type', 'application/json');
                res.setBody('test');
                res.setStatusCode(300);
                response = res;
            }
            // Parse the JSON response
            
            system.debug('response.getStatusCode()::'+response.getStatusCode());
            system.debug('response.getStatusCode()::'+response.getStatus());
            system.debug('response.getStatusCode()::'+response.GETBODY());
            
            if (response.getStatusCode() != 200) {
                c.Partial_ly_API_Status__c = 'The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus() +' \n Response Body: '+response.getStatusCode();
                UpdateableCases.add(c);
            } else {
                
                PaymentPlanParser pr = PaymentPlanParser.parse(response.getBody());
                system.debug(pr.Payment_plan);
                
                if(pr.Payment_plan.amount_refunded != null){ c.Amount_Refunded__c = Decimal.ValueOF( pr.Payment_plan.amount_refunded); }
                if(pr.Payment_plan.amount_paid != null){ c.Amount_Paid__c = Decimal.ValueOF( pr.Payment_plan.amount_paid); }
                if(pr.Payment_plan.balance != null){ c.Balance__c = Decimal.ValueOF( pr.Payment_plan.balance); }
                    
                UpdateableCases.add(c);
            }
        }
        
        if(UpdateableCases.size() > 0){
            update UpdateableCases;
        }
        
    }
    
    public void finish(Database.BatchableContext BC) {
    
    }
    
}