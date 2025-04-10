@IsTest
public with sharing class StripePaymentIntentEventHandler_Test {
    private static final String INVOICE_STRIPE_ID = 'in_000000000000';

    @TestSetup
    static void testSetup() {
        Invoice__c invoice = new Invoice__c(Name = 'TestInvoice', Stripe_Invoice_Id__c = INVOICE_STRIPE_ID);
        insert invoice;

        List<PaymentIntent__c> paymentIntents = new List<PaymentIntent__c>();

        DateTime nowDate = DateTime.now();
        PaymentIntent__c intent1 = new PaymentIntent__c(
            Name = 'Invoice1',
            CreatedInStripe__c = nowDate,
            Invoice__c = invoice.Id
        );
        paymentIntents.add(intent1);

        PaymentIntent__c intent2 = new PaymentIntent__c(
            Name = 'Invoice1',
            CreatedInStripe__c = nowDate,
            Invoice__c = invoice.Id
        );
        paymentIntents.add(intent2);

        insert paymentIntents;
    }

    @IsTest
    static void handle_UnitTest() {
        List<PaymentIntent__c> intents = [SELECT Id, CreatedInStripe__c FROM PaymentIntent__c];
        for(PaymentIntent__c intent : intents) {
            intent.CreatedInStripe__c = null;
        }
        update intents;
        Set<Id> oldIntents = (new Map<Id, SObject>(intents)).keySet();
        Integer expectedSize = 1;
        String expectedTransactionId = 'txn_00000000000000';
        String expectedCurrency = 'USD';
        Decimal expectedAmount = 10;

        StaticResource staticResource = [
            SELECT Id, Name, Body
            FROM StaticResource
            WHERE Name = 'StripePaymentIntentSucceededJson'
            LIMIT 1
        ];
        String eventData = staticResource.Body.toString();

        Test.startTest();
        new StripePaymentIntentEventHandler().handle(eventData);
        Test.stopTest();

        intents = [
            SELECT BalanceTransaction__c, Amount__c, Currency__c
            FROM PaymentIntent__c
            WHERE Id NOT IN :oldIntents
        ];

        System.assertEquals(expectedSize, intents.size());
        System.assertEquals(expectedTransactionId, intents.get(0).BalanceTransaction__c);
        System.assertEquals(expectedCurrency, intents.get(0).Currency__c);
        System.assertEquals(expectedAmount, intents.get(0).Amount__c);
    }

    @IsTest
    static void handleWithInvoice_UnitTest() {
        Integer days = 5;
        String expectedStatus = 'testStatus';

        List<PaymentIntent__c> intents = [
            SELECT CreatedInStripe__c, Status__c
            FROM PaymentIntent__c
        ];

        PaymentIntent__c earliestIntent = intents.get(0);
        earliestIntent.CreatedInStripe__c = DateTime.now().addDays(days);
        earliestIntent.Status__c = expectedStatus;
        update earliestIntent;

        StaticResource staticResource = [
            SELECT Id, Name, Body
            FROM StaticResource
            WHERE Name = 'StripePaymentIntentSucceededJson'
            LIMIT 1
        ];
        String eventData = staticResource.Body.toString();

        Test.startTest();
        new StripePaymentIntentEventHandler().handle(eventData);
        Test.stopTest();

        Invoice__c invoice = [
            SELECT PaymentIntentStatus__c, (SELECT Id, Status__c, CreatedInStripe__c FROM PaymentIntents__r)
            FROM Invoice__c 
            LIMIT 1
        ];
        System.assertEquals(expectedStatus, invoice.PaymentIntentStatus__c, 'Status unexpected');
    }
}