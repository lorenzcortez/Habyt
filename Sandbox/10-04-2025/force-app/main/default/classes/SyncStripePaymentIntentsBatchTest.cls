@IsTest
private class SyncStripePaymentIntentsBatchTest {

    @IsTest
    static void testGetPaymentIntent() {
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;
        Contract rentContract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert rentContract;
        Invoice__c invoice = new Invoice__c(Contract__c = rentContract.Id, Account__c = account.Id);
        insert invoice;
        PaymentIntent__c paymentIntent = new PaymentIntent__c(Invoice__c = invoice.Id, StripeId__c = '32323233', Status__c = 'requires_payment_method');
        insert paymentIntent;

        Test.startTest();
        Database.executeBatch(new SyncStripePaymentIntentsBatch(),1);
        Test.stopTest();
    }
}