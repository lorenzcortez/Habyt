@isTest
 class IcxStripeInterfaceTest {
    @TestSetup
    static void makeData(){
        Map<String,sObject> testData = TestUtils.getTestData();
        Account acc = (Account)testData.get('Account');
    }
    
    @isTest
    static void testUpdateContract(){
        List<Contract> contract = [SELECT Id, AccountId, Status, StartDate, ContractTerm, Room__c, Opportunity__c, Billing_Entity__c FROM Contract];
        Test.startTest();
        IcxStripeInterface.updateContract(contract[0]);
        IcxStripeInterface.setRoomAvailability(contract[0].Room__c, contract[0].Id, Date.today().addDays(3));
        Test.stopTest();
    }
    
    @isTest
    static void testGetAccount(){
        List<Contract> contract = [SELECT Id, AccountId, Status, StartDate, ContractTerm, Room__c, Opportunity__c, Billing_Entity__c FROM Contract];
        Test.startTest();
        IcxStripeInterface.getAccount(contract[0].Id);
        Map<String, Object> response = new Map<String, Object>();
        IcxStripeInterface.CheckResponse(response);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateStripeInfoCreate(){
        List<Contract> contract = [SELECT Id, AccountId, Status, StartDate, ContractTerm, Room__c, Opportunity__c, Billing_Entity__c FROM Contract];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());
        IcxStripeInterface.createSourceAndCustomer(JSON.serialize(contract[0]), '{"id":"123"}');
        IcxStripeInterface.createDepositAndSubscription(contract[0].Id);
        Test.stopTest();
    }
    
    @isTest
    static void testsubmitTransaction(){

        List<Contract> contract = [SELECT Id, AccountId, Status, StartDate, ContractTerm, Room__c, Opportunity__c, Billing_Entity__c FROM Contract];
        List<Account> accs = [SELECT Id FROM Account];
        accs[0].Stripe_Customer_Id__c = '007';
        update accs[0];
        
        Transaction__c t = new Transaction__c(Account__c = accs[0].Id, Type__c = 'Debit', Amount__c = 100, contract__c  = contract[0].Id);
        insert t;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());
        IcxStripeInterface.submitTransaction(t.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testHandleSubscriptionEvent() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('Stripe-Signature', '(t=1559115229, v1=4b52edae4083dcf6a5bab72daa1424e205c88932f3ec57adc3032a9415edba4b, v0=d32d294bc0e915a56b82cca941b2f6cb484490df5a80115481fb2322b2012c7e)');
        
        req.requestURI = '/services/apexrest/swh/v1/';
        req.requestBody = Blob.valueOf('{"type":"customer.subscription.updated", "data":{"object":{"id":"1234", "status":"Canceled"}}}');
        req.httpMethod = 'POST';  
        RestContext.request = req;
        RestContext.response = res;
        IcxStripeWebhook.postHandler();
        Test.stopTest();
    }  
    
    @isTest
    static void testHandleChargeEvent() {
        insert new Invoice__c (Stripe_Invoice_Id__c = '1234');
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/swh/v1/';
        req.addHeader('Stripe-Signature', '(t=1559115229, v1=4b52edae4083dcf6a5bab72daa1424e205c88932f3ec57adc3032a9415edba4b, v0=d32d294bc0e915a56b82cca941b2f6cb484490df5a80115481fb2322b2012c7e)');
        req.requestBody = Blob.valueOf('{"type":"charge.failed", "data":{"object":{"invoice":"1234", "status":"succeeded"}}}');
        req.httpMethod = 'POST';  
        RestContext.request = req;
        RestContext.response = res;
        IcxStripeWebhook.postHandler();
        Test.stopTest();
    }
    
    @isTest
    static void testHandleInvoiceEventUpdate() {
        insert new Invoice__c (Stripe_Invoice_Id__c = '1234');
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('Stripe-Signature', '(t=1559115229, v1=4b52edae4083dcf6a5bab72daa1424e205c88932f3ec57adc3032a9415edba4b, v0=d32d294bc0e915a56b82cca941b2f6cb484490df5a80115481fb2322b2012c7e)');
        req.requestURI = '/services/apexrest/swh/v1/';
        req.requestBody = Blob.valueOf('{"type":"invoice.payment_succeeded", "data":{"object":{"id":"1234", "status":"succeeded", "amount_due":800, "amount_paid":800,"status_transitions" : { "paid_at" : null}, "hosted_invoice_url" : null, "metadata" : {}}}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IcxStripeWebhook.postHandler();
        Test.stopTest();
    }
    
    @isTest
    static void testHandleInvoiceEventCreate() {
        List<Account> accs = [SELECT Id FROM Account];
        accs[0].Stripe_Customer_Id__c = '1234';
        update accs[0];
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('Stripe-Signature', '(t=1559115229, v1=4b52edae4083dcf6a5bab72daa1424e205c88932f3ec57adc3032a9415edba4b, v0=d32d294bc0e915a56b82cca941b2f6cb484490df5a80115481fb2322b2012c7e)');
        req.requestURI = '/services/apexrest/swh/v1/';
        req.requestBody = Blob.valueOf('{"type":"invoice.created", "data":{"object":{"id":"1234", "status":"succeeded", "subscription":"1234", "customer":"1234" , "amount_due":800, "amount_paid":800 }}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IcxStripeWebhook.postHandler();
        Test.stopTest();
    }
    
    @isTest
    static void testHandleInvoiceEventCreateNoSub() {
        List<Contract> contract = [SELECT Id, AccountId, Status, StartDate, ContractTerm, Room__c, Opportunity__c, Billing_Entity__c FROM Contract];
        List<Account> accs = [SELECT Id FROM Account];
        accs[0].Stripe_Customer_Id__c = '1234';
        update accs[0];

        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('Stripe-Signature', '(t=1559115229, v1=4b52edae4083dcf6a5bab72daa1424e205c88932f3ec57adc3032a9415edba4b, v0=d32d294bc0e915a56b82cca941b2f6cb484490df5a80115481fb2322b2012c7e)');
        req.requestURI = '/services/apexrest/swh/v1/';
        req.requestBody = Blob.valueOf('{"type":"invoice.created", "data":{"object":{"id":"1234", "status":"succeeded", "customer":"1234", "metadata":{"ContractId":"'+contract[0].Id+'"}, "amount_due":800, "amount_paid":800 }}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IcxStripeWebhook.postHandler();
        Test.stopTest();
    }
    
    @isTest
    static void testWeboutCatch() {
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/swh/v1/';
        req.requestBody = Blob.valueOf('{""}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        IcxStripeWebhook.postHandler();
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateContactInfo() {
        List<Account> accs = [SELECT Id FROM Account];
        IcxStripeInterface.updateContactInfo(accs[0].Id, 'testContactName', 'test@email.com');
    }
    
    @isTest
    static void testGetMyProfileUserInfo() {
        try {
            IcxStripeInterface.getMyProfileUserInfo();
        } catch (exception e) {
            system.debug(e.getMessage());
        }
    }
     
    @isTest
    static void testCancelSubscription(){
        List<Contract> contract = [SELECT Id, AccountId, Status, StartDate, ContractTerm, Room__c, Opportunity__c, Billing_Entity__c FROM Contract];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());
        IcxStripeInterface.CancelSubscription(contract[0].Id, date.today(), date.today(), true);
        Test.stopTest();
    }
}