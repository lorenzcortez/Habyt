public class partialAPIHelperClass
{
    @future(callout=true)
    public static void CreateCustomerforAccount(string accID, string CaseID){
        
        Account acc = [select Partially_Customer_ID__c,Partial_ly_Customer_API_Status__c, personemail, phone, firstname, lastname from account where id =:accID];
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://partial.ly/api/customer');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer e63ZQudtH9jQ+yV7OSxWag');
        // Set the body as a JSON object
        request.setBody('{"email": "'+acc.personemail+'", "first_name": "'+acc.firstName+'", "last_name": "'+acc.LastName+'", "phone": "'+acc.Phone+'"}');
        HttpResponse response = null;
        
        if(!test.IsRunningTest()){
            response = http.send(request);
        }
        else{
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-type', 'application/json');
            res.setBody('{"id":"terrsdfdsfdsfdf"}');
            res.setStatusCode(200);
            response = res;
        }
            
        
        // Parse the JSON response
        string CustomerID = null;
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                Case uc = new Case();
                uc.ID = CaseID;
                uc.Create_Partial_ly_Customer__c = False;
                
                acc.Partial_ly_Customer_API_Status__c = 'The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus() +' \n Response Body: '+response.getStatusCode();
                
                update acc;
                update uc;
                
                
        } 
        else 
        {
            System.debug(response.getBody());
            JSONParser parser = JSON.createParser(response.getBody());
            
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id')) {
                        system.debug('In::::'+parser.getText());
                        parser.nextToken();
                        CustomerID = parser.getTEXT();
                        break;       
                 }
                
            }
        
            system.debug('CustomerID=' + CustomerID);
            if(CustomerID != null){
                acc.Partially_Customer_ID__c  = CustomerID;
                update acc;
                
                Case uc = new Case();
                uc.ID = CaseID;
                uc.Create_Partial_ly_Customer__c = False;
                acc.Partial_ly_Customer_API_Status__c = 'Success';
                update uc;
            }
        }
    }
    
    @future(callout=true)
    public static void CreatePaymentPlanForCustomer(string CaseID){
        
        Case c = [select Status,Opportunity__r.Home_Committed__r.Name,User_ID__c, Invoice_ID__c,Partial_ly_Offer__c,Partially_Customer_ID__c,Payment_Plan_ID__c,Partial_ly_API_Status__c, Partial_ly_Payment_Start_Date__c, Opportunity__r.Rent_Amount__c from Case where id =:CaseID];
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://partial.ly/api/payment_plan');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer e63ZQudtH9jQ+yV7OSxWag');
        
        string HomeName = '';
        
        if(c.Opportunity__r.Home_Committed__c != null){
            HomeName = c.Opportunity__r.Home_Committed__r.Name;
        }
        
        // Set the body as a JSON object
        string RequestBody = '{"amount": "'+c.opportunity__r.Rent_Amount__c+'", "customer_id": "'+c.Partially_Customer_ID__c+'", "offer_id": "'+c.Partial_ly_Offer__c.TRIM()+'", "status": "pending", "send_plan_request" :"true", "meta" : {"Invoice_ID" : "'+c.Invoice_ID__c+'", "User_ID" : "'+c.User_ID__c+'", "Home" : "'+HomeName+'"} }';
        system.debug('RequestBody:::::'+RequestBody);
        request.setBody(RequestBody);
        
        HttpResponse response = null;
        
        if(!test.IsRunningTest()){
            response = http.send(request);
        }
        else{
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-type', 'application/json');
            //res.setBody('{"id":"terrsdfdsfdsfdf"}');
            res.setBody('{"payment_plan": {"id":"terrsdfdsfdsfdf"}}');
            res.setStatusCode(200);
            response = res;
        }
        
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                
                c.Partial_ly_API_Status__c = 'The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus() +' \n Response Body: '+response.getStatusCode();
                update c;
        } 
        else 
        {
            System.debug(response.getBody());
            PaymentPlanParser pr = PaymentPlanParser.parse(response.getBody());
            
            if(pr.Payment_plan != null && c.Partial_ly_Payment_Start_Date__c != null){
            
                Http http2 = new Http();
                HttpRequest request2 = new HttpRequest();
                request2.setEndpoint('https://partial.ly/api/payment_schedule');
                request2.setMethod('POST');
                request2.setHeader('Content-Type', 'application/json');
                request2.setHeader('Authorization', 'Bearer e63ZQudtH9jQ+yV7OSxWag');
                
                
                string StartDate = DateTime.newInstance(c.Partial_ly_Payment_Start_Date__c.year(), c.Partial_ly_Payment_Start_Date__c.month(), c.Partial_ly_Payment_Start_Date__c.day()).format('yyyy-MM-dd');
                // Set the body as a JSON object
                request2.setBody('{"payment_plan_id": "'+pr.Payment_plan.ID+'", "amount": "'+c.opportunity__r.Rent_Amount__c+'", "starts_auto" : "false", "starts_date" : "'+StartDate+'"}');
                HttpResponse response2 = null;
                if(!test.IsRunningTest()){
                    response2 = http.send(request2);
                    system.debug(response2);
                    system.debug(response2.getBody());
                }
                else{
                    
                    HttpResponse res2 = new HttpResponse();
                    res2.setHeader('Content-type', 'application/json');
                    res2.setBody('{"id":"terrsdfdsfdsfdf"}');
                    res2.setStatusCode(200);
                    response = res2;
                }
                
                c.Payment_Plan_ID__c = pr.Payment_plan.ID;
                c.Partial_ly_API_Status__c =  'Success';
                update c;
            }
            
            
        }
    }
}