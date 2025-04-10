// Developed by Einsteam
// This is invocable apex class which can be invoked from the process/flow.
// Getting opportunity details and sending gift to tremendous via API.
// After send gift using API, it's creating GIFT record related to an account. 
// Updating status of the API in Concession_Gift_Card_API_Status__c field.
public class ConcessionGiftHelper{

    @InvocableMethod(label='Send Concession Gift' description='This method takes Opportunity ID as a paramter and then send concession gift for that opportunity via API.')
    public static void SendConcessionGift(list<String> Oppids) {
        for(string oppid : oppids){
            SendGiftusingTremendousAPI(oppid);
        }
    }
    
    @future (callout = true)
    public static void SendGiftusingTremendousAPI(string OppID){
        Opportunity opp = [select id, AccountID, City__c,Home_Committed__c , Home_Committed__r.Tremendous_Bank_Account__c, Concession_Gift_Card_API_Status__c,
        Gift_Card_Amount__c,Account.FirstName, Account.LastName, Account.PersonEmail
         from Opportunity where id =:OppID];
         
        if(string.ISBLANK(opp.Home_Committed__r.Tremendous_Bank_Account__c)){
            opp.Concession_Gift_Card_API_Status__c = 'Bank Account ID not added on the home record.';
            update opp;
        }
        else{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://www.tremendous.com/api/v2/orders');
            request.setMethod('POST');
            String body = '{ "external_id": "'+opp.Id+'","payment": { "funding_source_id": "'+opp.Home_Committed__r.Tremendous_Bank_Account__c+'" },  "reward": {    "value":{"denomination":'+opp.Gift_Card_Amount__c+', "currency_code": "USD"},    "campaign_id": "CZKQL0EIH9BR",    "recipient": {      "name": "'+opp.Account.FirstName +' '+ opp.Account.LastName +'", "email": "'+opp.Account.PersonEmail+'"},    "delivery": {      "method": "EMAIL",      "meta": {}    }  }}';
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('Authorization', 'Bearer '+System.Label.TremendousAPIKey);
            request.setBody(body);
            HttpResponse response = null;
            
            if(test.isRunningTest()){
                HttpResponse res = new HttpResponse();
                res.setStatusCode(200);
                response = res;
            }
            else
            {
                response = http.send(request);
            }
            
            if(response.getStatusCode() == 200){
                opp.Concession_Gift_Card_API_Status__c = 'Gift successfully sent';
                Gifts__c g = new Gifts__c();
                
                try
                {
                    g.Name = 'Concession Gift Card';
                    g.Account__c = opp.AccountID;
                    g.Attendees__c = 1;
                    g.Category__c = 'Concession';
                    g.Cost__c = opp.Gift_Card_Amount__c;
                    g.Date_Purchased__c = system.today();
                    g.Status__c = 'Complete';
                    g.Home__c = opp.Home_Committed__c;
                    g.City_Budgeted_To__c =  opp.City__c;
                    insert g;
                }
                catch (exception ex){ if(ex.GetMessage().Contains('UNABLE_TO_LOCK_ROW')){ list<SObject> failedSObjects = new list<SObject>(); failedSObjects.add(g);
                        Queable_ApexRetryDML updateJob = new Queable_ApexRetryDML(failedSObjects); System.enqueueJob(updateJob); }
                }
                
            }
            else if(response.getStatusCode() == 201){
                opp.Concession_Gift_Card_API_Status__c = 'Gift already been sent or has been cancelled on tremendous with external ID '+opp.Id;
            }
            else{
                opp.Concession_Gift_Card_API_Status__c = 'Error Status: '+response.getStatus()+'\n Status Code: '+response.getStatusCode()+'\n Message: '+response.getBody();
            }
            
            update opp;
        }
        
        
    }
 
}