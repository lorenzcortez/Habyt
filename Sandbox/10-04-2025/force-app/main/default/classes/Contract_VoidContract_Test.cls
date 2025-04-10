@IsTest
public with sharing class Contract_VoidContract_Test {
    @TestSetup
    static void setupTest() {
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc = TestRecord_Factory.iStripe_Account;

        List<Contract> contractsToInsert = new List<Contract>();
        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        contractsToInsert.add(contract);

        Contract contract2 = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        contractsToInsert.add(contract2);

        Contract contract3 = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        contractsToInsert.add(contract3);

        insert contractsToInsert;
    }

    @IsTest
    static void afterUpdate_unitTest() {
        CustomerContractService contractService = new CustomerContractService();
        String expectedStatus = 'Voided';
        List<Contract> contracts = [
            SELECT Id, Status, Room__c 
            FROM Contract 
            WHERE Status = :CustomerContractService.STATUS_DRAFT
            LIMIT 3
        ];

        Id roomId = contracts.get(0).Room__c;
        for(Contract contract : contracts) {
            contract.Room__c = roomId;
            contract.RecordTypeId = CustomerContractService.RT_ID_RENT;
            contract.EverSign_Doc_Hash__c = '123';
            contract.IsVoidContractTrig__c = false;
        }
        contracts.get(0).Status = CustomerContractService.STATUS_SIGNED; 
        
        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
        Test.startTest();

        update contracts;

        Test.stopTest();

        contracts = [
            SELECT Id, Status 
            FROM Contract 
            WHERE Id = :contracts.get(1).Id OR Id = :contracts.get(2).Id
            LIMIT 2
        ];

        //System.assertEquals(expectedStatus, contracts.get(0).Status, 'Contract status mismatch');
        //System.assertEquals(expectedStatus, contracts.get(1).Status, 'Contract status mismatch');
    
    }
}