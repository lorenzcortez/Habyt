@IsTest
public with sharing class Contract_VoidContractEversign_Test {
    @TestSetup
    static void setupTest() {
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc = TestRecord_Factory.iStripe_Account;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;
    }

    @IsTest
    static void afterUpdate_unitTest() {
        CustomerContractService contractService = new CustomerContractService();

        Contract contract = [SELECT Id, EverSign_Doc_Hash__c FROM Contract LIMIT 1];
        contract.Status = CustomerContractService.STATUS_VOIDED;

        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
        Test.startTest();

        update contract;

        Test.stopTest();
    }
}