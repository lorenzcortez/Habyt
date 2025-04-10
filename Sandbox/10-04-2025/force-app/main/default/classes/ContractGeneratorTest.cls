@IsTest 
class ContractGeneratorTest {

    Public	Static	Account		acc;
    Public	Static	Opportunity	opp; 
    Public	Static	Contract	con;
    
    Static
    {
        String	firstStageNameValue = Opportunity.StageName.getDescribe().getPicklistValues()[0].getValue();
        String	firstContractStatus = Contract.Status.getDescribe().getPicklistValues()[0].getValue();
        
        acc = new Account(LastName = 'TestAcc');
        insert acc;
        
        Stripe_Account__c sa  = TestRecord_Factory.iStripe_Account;
        
        // TODO: refactor this into the factory
        Billing_Entity__c holding = TestRecord_Factory.createBilling_Entity();
        holding.TypePick__c = CustomerContractService.BILLING_ENTITY_TYPE_HOLDING;
        insert holding;

        Property__c	p = TestRecord_Factory.iProperty;
        // Test refactor this into the factory
        Room__c	room = TestRecord_Factory.iRoom;
        room.Price__c = 1000;
        update room;
        
        opp = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, CloseDate = Date.today(), StageName = firstStageNameValue, Room__c = room.Id, Start_Date__c = Date.today(), CurrencyIsoCode = 'EUR', Monthly_Price__c = 1000);
        insert opp;
        
        con = new Contract(AccountId = acc.Id, Status = 'Draft', StartDate = Date.today(), ContractTerm = 6, Room__c = room.Id, Opportunity__c = opp.Id, CurrencyIsoCode = 'EUR', Stripe_Account__c = sa.id);
        insert con;
        
    }
    
    Static	testmethod	void	testSave() {
        ContractGeneratorController.saveContract(opp.Id);
    }
    
    Static	testmethod	void	testPushToEversign() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());
        ContractGeneratorController.pushToEversign(con.Id);
        Test.stopTest();
    }
    
    Static	testmethod	void	testhandleManualContract() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());
        ContractGeneratorController.handleManualContract(con.Id);
        Test.stopTest();
    }
    
    Static	testmethod	void	testGenerateStripePlan() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());
        ContractGeneratorController.generateStripePlan(con.Id);
        Test.stopTest();
    }
    
    
    
    Static	testmethod	void	testGetEmailData() {
        ContractGeneratorController.getEmailData('00X1i000000gvSa', opp.Id);
    }
    
}