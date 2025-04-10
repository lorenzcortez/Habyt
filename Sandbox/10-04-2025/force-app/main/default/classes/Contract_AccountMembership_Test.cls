@IsTest
public class Contract_AccountMembership_Test {
    @TestSetup
    static void setupTest() {        
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;
    }

    @IsTest
    static void afterUpdate_Signed_unitTest(){
        Contract contract = [SELECT Id, Status, RecordTypeId, AccountId FROM Contract WHERE AccountId != null LIMIT 1];
        contract.RecordTypeId =  CustomerContractService.RT_ID_MEMBERSHIP;
        contract.Status = CustomerContractService.STATUS_TERMINATED;

        Account account = [SELECT Id, MembershipStatusPick__c FROM Account WHERE Id = :contract.AccountId LIMIT 1];
        account.MembershipStatusPick__c = 'Member';
        update account;
        
        Test.startTest();

        update contract;

        Test.stopTest();
        
        account = [SELECT Id, MembershipStatusPick__c FROM Account WHERE Id = :contract.AccountId LIMIT 1];

        System.assertEquals(null, account.MembershipStatusPick__c, 'Account membership status must be null');
    }
}