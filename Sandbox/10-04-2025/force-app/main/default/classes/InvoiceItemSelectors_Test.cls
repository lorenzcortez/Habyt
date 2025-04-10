@IsTest
public with sharing class InvoiceItemSelectors_Test {
    public static final Integer INVOICE_ITEMS_NUMBER = 5;

    @TestSetup
    static void setupTest(){
        List<InvoiceItem__c> invoiceItems = new List<InvoiceItem__c>();
        Integer counter = INVOICE_ITEMS_NUMBER;
        while (counter > 0) {
            invoiceItems.add(new InvoiceItem__c(Name = 'Test Invoice Item No. ' + counter));
            counter--;
        }
        insert invoiceItems;
    }

    @IsTest
    static void ById_Test() {
        List<InvoiceItem__c> invoiceItems = [SELECT Id FROM InvoiceItem__c];
        Integer expectedSize = invoiceItems.size();
        Set<Id> ids = (new Map<Id, SObject>(invoiceItems)).keySet();

        Test.startTest();
        invoiceItems = (List<InvoiceItem__c>) Paua_SelectorHandler.getSelector(InvoiceItemSelectors.ById.class)
                                                                  .setParameter('idSet', ids)
                                                                  .query();
        Test.stopTest();

        System.assertEquals(expectedSize, invoiceItems.size());
    }
}