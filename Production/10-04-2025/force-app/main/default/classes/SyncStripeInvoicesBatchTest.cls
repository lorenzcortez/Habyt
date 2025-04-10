@IsTest
private class SyncStripeInvoicesBatchTest {
    @IsTest
    static void testBatch() {
        Invoice__c invoice = new Invoice__c(Stripe_Invoice_Id__c = '42424423423', CurrencyIsoCode = 'EUR', SubscriptionId__c = null, ContractId__c = null);
        insert invoice;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;
        //Test.startTest();
        //Database.executeBatch(new SyncStripeInvoicesBatch(),1);
        //Test.stopTest();
    }
}