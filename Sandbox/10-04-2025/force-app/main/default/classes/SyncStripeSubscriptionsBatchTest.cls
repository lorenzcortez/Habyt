@IsTest
private class SyncStripeSubscriptionsBatchTest {
    @IsTest
    static void testBatch() {
        Account account = TestRecord_Factory.iPersonAccount;
        account.Stripe_Customer_Id__c = '424234';
        update account;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;
        Contract rentContract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert rentContract;

        insert new StripeCustomer__c(StripeCustomerId__c = account.Stripe_Customer_Id__c, StripeAccountName__c = stripeAcc.Name);

        Test.startTest();
        Database.executeBatch(new SyncStripeSubscriptionsBatch(),1);
        Test.stopTest();
    }
}