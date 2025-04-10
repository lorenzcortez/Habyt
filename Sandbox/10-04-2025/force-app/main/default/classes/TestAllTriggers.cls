@IsTest
public class TestAllTriggers {
    
    @IsTest
    public static void contentVersion_TriggerTest() {
        ContentVersion cv = TestRecord_Factory.iContentVersion;
    }

    @IsTest
    public static void contract_TriggerTest() {
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;
    }

    @IsTest
    static void contractItem_TriggerTest() {
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;
        Product2 prod = TestRecord_Factory.iProduct;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;

        Test.startTest();
        ContractItem__c ci = TestRecord_Factory.createContractItem(contract, prod.Id, room.Id);
        insert ci;
        Test.stopTest();
    }

    @IsTest
    public static void opportunity_TriggerTest() {
        Opportunity opp = TestRecord_Factory.iOpportunity;
    }

    @IsTest
    public static void property_TriggerTest() {
        Property__c prop = TestRecord_Factory.iProperty;
    }

    @IsTest
    public static void room_TriggerTest() {
        Room__c room = TestRecord_Factory.iRoom;
    }
}