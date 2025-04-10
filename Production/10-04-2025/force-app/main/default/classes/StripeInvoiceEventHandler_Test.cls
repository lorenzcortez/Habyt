@IsTest
public with sharing class StripeInvoiceEventHandler_Test {
    @TestSetup
    static void setupTest() {
        Invoice__c invoice = new Invoice__c(
            Stripe_Invoice_Id__c = StripeEventHandler_Test.INVOICE_TEST_ID,
            Name = StripeEventHandler_Test.INVOICE_TEST_NAME,
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
    public static void handle_UnitTest() {
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
        new StripeInvoiceEventHandler().handle(eventData);
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
    public static void handleSubscription_UnitTest() {
        String expectedInvoiceStripeId = 'in_00000000000000';
        String expectedDescription = 'My First Invoice Item (created for API docs)';
        StaticResource staticResource = [
            SELECT Id, Name, Body
            FROM StaticResource
            WHERE Name = 'StripeInvoiceUpdatedEventJson'
            LIMIT 1
        ];
        String eventData = staticResource.Body.toString();
        eventData = eventData.replace('"subscription": null', '"subscription": "sb_00000000000"');

        Contract contract = [SELECT Id, AccountId FROM Contract LIMIT 1];
        Test.setFixedSearchResults(new List<Id>{contract.Id, contract.AccountId});
        
        Test.startTest();
        new StripeInvoiceEventHandler().handle(eventData);
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
    }
}