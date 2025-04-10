@isTest
global class TestUtils implements HttpCalloutMock {
    static testmethod void test_getTestData() {
        getTestData();
    }
    
    global static Map<String,String> getTestMetaData() {
        // TODO: this prolly requires a more accurate value
        return new Map<String,String>{
            'Opportunity_Won_Stage' => 'Offre gagnée'
        };
    }
    
    global static Map<String,sObject> getTestData() {
        Account acc;
        Opportunity opp;    
        Contract con;

        String firstStageNameValue = Opportunity.StageName.getDescribe().getPicklistValues()[0].getValue();
        String firstContractStatus = Contract.Status.getDescribe().getPicklistValues()[0].getValue();

        acc = new Account(LastName = 'TestAcc', CurrencyIsoCode = 'EUR', PersonEmail='test@example.com', Stripe_Customer_Id__c = 'Stripe_Customer_Id');
        insert acc;

        Stripe_Account__c sa = new Stripe_Account__c(Name = 'test', CurrencyIsoCode = 'EUR', secret_key__c = 'xxx');
        insert sa;

        Billing_Entity__c be = TestRecord_Factory.iBilling_Entity;

        Condition__c condition = TestRecord_Factory.iCondition;

        Property__c p = TestRecord_Factory.iProperty;

        //TODO: refactor this into the record factory
        Room__c room = TestRecord_Factory.iRoom;
        room.Price__c = 500;
        room.CurrencyIsoCode = 'EUR';
        update room;

        opp = new Opportunity(
            Name = 'TestOpp', 
            AccountId = acc.Id, 
            CloseDate = Date.today(), 
            StageName = firstStageNameValue, 
            Room__c = room.Id, 
            Description = 'Description!',
            Start_Date__c = Date.today(), 
            Deposit__c = 800,
            Monthly_Price__c = 800, 
            ContractEndDate__c = Date.today().addMonths(6),
            CurrencyIsoCode = 'EUR'
        );
        insert opp;

        con = new Contract(
            AccountId = acc.Id, 
            Status = 'Draft', 
            StartDate = Date.today(), 
            ContractTerm = 6, 
            Room__c = room.Id, 
            Opportunity__c = opp.Id, 
            Billing_Entity__c = be.id, 
            Stripe_Account__c = sa.id, 
            Stripe_Subscription_Id__c = '1234', 
            EverSign_Doc_Hash__c = 'test',
            CurrencyIsoCode = 'EUR'
        );
        insert con;

        Transaction__c trans = new Transaction__c(
            Account__c = acc.Id, 
            Type__c = 'Debit', 
            Amount__c = 100, 
            Contract__c = con.Id,
            CurrencyIsoCode = 'EUR'
        );
        insert trans;

        return new Map<String,sObject>{
            'Opportunity' => opp,
            'Account' => acc,
            'Contract' => con,
            'Room__c' => room,
            'Transaction__c' => trans
        };
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id":"test"}');
        res.setStatusCode(200);
        return res;
    }
}