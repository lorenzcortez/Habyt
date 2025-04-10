@IsTest
public with sharing class StripeEventHandler_Test {
    public static final String INVOICE_TEST_ID = 'in_00000000000000';
    public static final String INVOICE_TEST_NAME = 'Test Invoice Name';

    @TestSetup
    static void setupTest() {
        Invoice__c invoice = new Invoice__c(
            Stripe_Invoice_Id__c = INVOICE_TEST_ID,
            Name = INVOICE_TEST_NAME,
            PaymentStatus__c = StripeChargeEventHandler.INVOICE_SUCCESS_STATUS
        );
        insert invoice;

        Account account = TestRecord_Factory.iAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc = TestRecord_Factory.iStripe_Account;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;
    }

    @IsTest
    public static void handle_ChargeEvent_UnitTest() {
        Date expectedDate = System.today();
        Invoice__c invoice = [SELECT Stripe_Invoice_Id__c FROM Invoice__c LIMIT 1];
        String eventData = '{"id":"evt_1CiPtv2eZvKYlo2CcUZsDcO6","object":"event",' +
                            '"data":{"object":{"id":"' + invoice.Stripe_Invoice_Id__c + '","status":"' + 
                            StripeChargeEventHandler.INVOICE_SUCCESS_STATUS + '"}},' + '"type": "charge.update"}';


        Test.startTest();
        StripeEventHandler.handle(eventData);
        Test.stopTest();

        invoice = [SELECT PaymentDate__c FROM Invoice__c LIMIT 1];

        System.assertEquals(expectedDate, invoice.PaymentDate__c, 'Date unexpected');
    }

    @IsTest
    public static void handle_InvoiceEvent_UnitTest() {
        String expectedInvoiceStripeId = 'in_00000000000000';
        String expectedDescription = 'My First Invoice Item (created for API docs)';
        StaticResource staticResource = [
            SELECT Id, Name, Body
            FROM StaticResource
            WHERE Name = 'StripeInvoiceUpdatedEventJson'
            LIMIT 1
        ];
        String eventData = staticResource.Body.toString();

        Contract contract = [SELECT Id, AccountId FROM Contract LIMIT 1];
        Test.setFixedSearchResults(new List<Id>{contract.Id, contract.AccountId});
        
        Test.startTest();
        StripeEventHandler.handle(eventData);
        Test.stopTest();

        Invoice__c invoice = [
            SELECT Stripe_Invoice_Id__c, PaymentDate__c
            FROM Invoice__c 
            WHERE Stripe_Invoice_Id__c = :expectedInvoiceStripeId
            LIMIT 1
        ];
        List<InvoiceItem__c> invoiceItems = [SELECT Id, Description__c FROM InvoiceItem__c];
        System.assertNotEquals(0, invoiceItems.size(), 'No invoice items found');
        System.assertNotEquals(null, invoice, 'Stripe invoice is null');

        for(InvoiceItem__c lineItem : invoiceItems) {
            System.assertEquals(expectedDescription, lineItem.Description__c, 'Wrong line item description');
        }
    }

    @IsTest
    public static void handle_SubscriptionsEvent_UnitTest() {
        String subscriptionId = 'su_1J5AnUI4AG1fjzDfxcIQcclH';
        String expectedStatus = 'active';
        String customerId = 'cus_ibibi3b123';

        Contract contract = [
            SELECT Id, StripeCustomerJSONMap__c, AccountId
            FROM Contract
            LIMIT 1
        ];
        contract.Stripe_Subscription_Id__c = subscriptionId;
        update contract;

        String eventData = '{"id":"evt_1CiPtv2eZvKYlo2CcUZsDcO6","object":"event",' +
                            '"data":{"object":{"id":"' + subscriptionId + '","status":"' + expectedStatus + 
                            '", "customer":"' + customerId + '"}},' + '"type": "customer.subscription.active"}';

        
        Test.setFixedSearchResults(new List<Id>{contract.Id, contract.AccountId});
        Test.startTest();
        StripeEventHandler.handle(eventData);
        Test.stopTest();

        contract = [
            SELECT Id, Stripe_Subscription_Status__c, StripeCustomerJSONMap__c
            FROM Contract
            WHERE Id = :contract.Id
            LIMIT 1
        ];
        System.assertEquals(expectedStatus, contract.Stripe_Subscription_Status__c); 
    }

    @IsTest
    public static void handle_PaymentIntentEvent_UnitTest() {
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
        StripeEventHandler.handle(eventData);
        Test.stopTest();

        List<PaymentIntent__c> intents = [
            SELECT BalanceTransaction__c, Amount__c, Currency__c
            FROM PaymentIntent__c
        ];

        System.assertEquals(expectedSize, intents.size());
        System.assertEquals(expectedTransactionId, intents.get(0).BalanceTransaction__c);
        System.assertEquals(expectedCurrency, intents.get(0).Currency__c);
        System.assertEquals(expectedAmount, intents.get(0).Amount__c);
    }
}