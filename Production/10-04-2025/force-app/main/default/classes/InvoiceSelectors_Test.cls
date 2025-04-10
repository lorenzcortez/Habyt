@IsTest
public with sharing class InvoiceSelectors_Test {
    public static final String STRIPE_TEST_ID_HEAD = 'test';
    public static final Integer INVOICES_NUMBER = 5;

    @TestSetup
    static void setupTest(){
        List<Invoice__c> invoices = new List<Invoice__c>();
        Integer counter = INVOICES_NUMBER;
        while (counter > 0) {
            invoices.add(
                new Invoice__c(
                    Name = 'Test Invoice No. ' + counter,
                    Stripe_Invoice_Id__c = STRIPE_TEST_ID_HEAD + counter
                )
            );
            counter--;
        }
        insert invoices;
    }

    @IsTest
    static void ByStripeId_Test() {
        Set<String> ids = new Set<String>{'test1', 'test2', 'test3', 'test4', 'test5'};

        Test.startTest();
        List<Invoice__c> invoices = (List<Invoice__c>) Paua_SelectorHandler.getSelector(InvoiceSelectors.ByStripeId.class)
                                                              .setParameter('stripeInvoiceIdSet', ids)
                                                              .query();
        Test.stopTest();

        System.assertEquals(INVOICES_NUMBER, invoices.size());
    }

    @IsTest
    static void ById_Test() {
        List<Invoice__c> invoices = [SELECT Id FROM Invoice__c];
        Integer expectedSize = invoices.size();
        Set<Id> ids = (new Map<Id, SObject>(invoices)).keySet();

        Test.startTest();
        invoices = (List<Invoice__c>) Paua_SelectorHandler.getSelector(InvoiceSelectors.ById.class)
                                                          .setParameter('idSet', ids)
                                                          .query();
        Test.stopTest();

        System.assertEquals(expectedSize, invoices.size());
    }
}