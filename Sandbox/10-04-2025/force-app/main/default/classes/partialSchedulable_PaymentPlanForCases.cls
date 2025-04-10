/**
*  Schedulable batch job for getting payment plan for cases with customer Id
*  @author    Einsteamn
*  
*/
public class partialSchedulable_PaymentPlanForCases implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {

    public void execute(SchedulableContext sc) {
        runJob();
    }
    
    @TestVisible
    private void runJob() {
        Database.executeBatch(this,50);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        string query = 'Select Status, Partial_ly_API_Status__c,Payment_Plan_ID__c,Partially_Customer_ID__c from Case where Status = \'Payment Plan Sent\' and Payment_Plan_ID__c != null';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Case> cases = (List<Case>)scope;
        system.debug(':size:::::'+cases.size());
        list<Case> UpdateableCases = new list<Case>();
        
        for(Case c: cases){
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://partial.ly/api/payment_plan?customer='+c.Partially_Customer_ID__c);
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer e63ZQudtH9jQ+yV7OSxWag');
            
            HttpResponse response = null;
        
            if(!test.IsRunningTest()){
                response = http.send(request);
            }
            else{
                
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-type', 'application/json');
                
                String json = '{'+
                '    \"total_pages\": 1,'+
                '    \"total_entries\": 1,'+
                '    \"payment_plans\": ['+
                '        {'+
                '            \"user_agent\": null,'+
                '            \"subtotal\": 1000,'+
                '            \"status\": \"open\",'+
                '            \"number\": 140,'+
                '            \"meta\": {'+
                '                \"items\": ['+
                '                    {'+
                '                        \"quantity\": 1,'+
                '                        \"price\": 900,'+
                '                        \"name\": \"Widget\",'+
                '                        \"id\": \"widget-id\"'+
                '                    },'+
                '                    {'+
                '                        \"quantity\": 2,'+
                '                        \"price\": 50,'+
                '                        \"name\": \"Small product\",'+
                '                        \"id\": \"prod-sm\"'+
                '                    }'+
                '                ],'+
                '                \"description\": \"Sample api plan\"'+
                '            },'+
                '            \"merchant_notes\": \"Customer is very happy\",'+
                '            \"ip_address\": null,'+
                '            \"integration_id\": null,'+
                '            \"integration\": null,'+
                '            \"inserted_at\": \"2018-11-28T17:13:14.181300\",'+
                '            \"id\": \"8f999efe-5798-4b51-a6c5-d21b0d04124b\",'+
                '            \"customer_id\": \"e3cbf1dc-0c11-483f-b604-d44fd93aac90\",'+
                '            \"currency\": \"USD\",'+
                '            \"amount_paid\": 256.25,'+
                '            \"amount\": 1025'+
                '        },{'+
                '            \"user_agent\": null,'+
                '            \"subtotal\": 1000,'+
                '            \"status\": \"no open\",'+
                '            \"number\": 140,'+
                '            \"meta\": {'+
                '                \"items\": ['+
                '                    {'+
                '                        \"quantity\": 1,'+
                '                        \"price\": 900,'+
                '                        \"name\": \"Widget\",'+
                '                        \"id\": \"widget-id\"'+
                '                    },'+
                '                    {'+
                '                        \"quantity\": 2,'+
                '                        \"price\": 50,'+
                '                        \"name\": \"Small product\",'+
                '                        \"id\": \"prod-sm\"'+
                '                    }'+
                '                ],'+
                '                \"description\": \"Sample api plan\"'+
                '            },'+
                '            \"merchant_notes\": \"Customer is very happy\",'+
                '            \"ip_address\": null,'+
                '            \"integration_id\": null,'+
                '            \"integration\": null,'+
                '            \"inserted_at\": \"2018-11-28T17:13:14.181300\",'+
                '            \"id\": \"8f999efe-5798-4b51-a6c5-d21b0d04124b\",'+
                '            \"customer_id\": \"e3cbf1dc-0c11-483f-b604-d44fd93aac90\",'+
                '            \"currency\": \"USD\",'+
                '            \"amount_paid\": 256.25,'+
                '            \"amount\": 1025'+
                '        }'+
                ''+
                '    ],'+
                '    \"page_size\": 10,'+
                '    \"page_number\": 1'+
                '}';
                res.setBody(json);
                res.setStatusCode(200);
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
                
                PaymentPlanlistParser pr = PaymentPlanlistParser.parse(response.GETBODY()); 
                system.debug(pr.payment_plans);
                
                for(PaymentPlanlistParser.Payment_plans p : pr.payment_plans ){
                    system.debug('Status::'+p.Status);
                    system.debug('p.id::'+p.id);
                    if(p.status == 'open' && p.id == c.Payment_Plan_ID__c){
                        c.Status = 'Payment Plan Confirmed';
                        c.Partial_ly_API_Status__c = 'Success';
                        UpdateableCases.add(c);
                    }
                }  
            
            }
        }
        
        if(UpdateableCases.size() > 0){
            update UpdateableCases;
        }
        
    }
    
    public void finish(Database.BatchableContext BC) {
    
    }
    
}