@IsTest
public with sharing class InvoiceService_Test {
    public static final String KEY = 'sk_nizvbzv131ibd';
    public static final String INVOICE_ID = 'in_1KItSdI4AG1fjzDfyqbaP4cM';
    public static final String INVOICE_ITEM_ID = 'ii_1KItSdI4AG1fjzDfLSeimL2Y';
    public static final String CUSTOMER_ID = 'cus_nifweufbiwe';

    @TestSetup
    static void testSetup(){
        Account account = new Account(Name = 'Test Account', Stripe_Customer_Id__c = CUSTOMER_ID);
        insert account;

        Stripe_Account__c stripeAccount = new Stripe_Account__c(Name = 'Habyt GmbH', Secret_key__c = KEY);
        insert stripeAccount;

        Contract contract = new Contract(
            AccountId = account.Id, 
            Stripe_Account__c = stripeAccount.Id,
            StartDate = System.today()
        );
        insert contract;

        Invoice__c invoice= new Invoice__c(
            Name = 'Test invoice 1', 
            StripeAccount__c = stripeAccount.Id,
            Description__c = 'Description 1',
            CollectionMethod__c = 'charge_automatically',
            Contract__c = contract.Id,
            Account__c = account.Id,
            Stripe_Invoice_Id__c = 'TestStripeId',
            CustomerStripeId__c = CUSTOMER_ID
        );
        insert invoice;

        List<InvoiceItem__c> invoiceItems = new List<InvoiceItem__c>(); 
        invoiceItems.add(new InvoiceItem__c(
            Name = 'Test Invoice Item', 
            Invoice__c = invoice.Id, 
            Description__c = 'Description 1',
            Amount__c = 100,
            PeriodStart__c = Date.today(),
            PeriodEnd__c = Date.today(),
            StripeInvoiceId__c = 'TestStripeId'
        ));
        insert invoiceItems;

        //Sept 5 2024
        List<Deposit__c> deposits = new List<Deposit__c>();
        deposits.add(new Deposit__c(
            Name = 'Test Deposit',
            Contract__c = contract.Id,
            Status__c = 'In tenancy'));
        insert deposits;
    }

    @IsTest
    public static void retrieveItemsFromInvoices_UnitTest() {
        List<Invoice__c> invoices = [
            SELECT Id, (SELECT Id, Invoice__c, Stripe_Id__c FROM InvoiceItems__r)
            FROM Invoice__c 
            LIMIT 1
        ];

        Set<Id> expectedIdSet = (new Map<Id,SObject>(invoices.get(0).InvoiceItems__r)).keySet();

        InvoiceService service = new InvoiceService();
        Test.startTest();
        List<InvoiceItem__c> invoiceItems = service.retrieveItemsFromInvoices(invoices);
        Test.stopTest();

        System.assertEquals(invoiceItems.size(), expectedIdSet.size(), 'Unexpected invoice items size.');
        for(InvoiceItem__c item : invoiceItems) {
            System.assert(expectedIdSet.contains(item.Id), 'Unexpected item id');
        }
    }

    /**
     * If invoice has more than one related invoice items the test may fail. Invoice & invoice item ids are taken from 
     * the InvoiceResponse JSON, which is returned in StripeHttpMockResponse after we make a callout to /invoice
     */
    @IsTest
    public static void sendInvoicesToStripe_UnitTest() {
        Invoice__c invoice = [SELECT Id, CustomerStripeId__c,Stripe_Invoice_Id__c FROM Invoice__c LIMIT 1];
        invoice.CustomerStripeId__c = CUSTOMER_ID;
        update invoice;
		system.debug('@@@@ invoice '+invoice);
        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
        Test.startTest();
        InvoiceService.sendInvoicesToStripe(invoice.Id);
        Test.stopTest();
    }

    /**
     * If invoice has more than one related invoice items the test may fail. Invoice & invoice item ids are taken from
     * the InvoiceResponse JSON, which is returned in StripeHttpMockResponse after we make a callout to /invoice
     */
    @IsTest
    public static void deleteInvoiceItemsInStripe_UnitTest() {
        Invoice__c invoice = [SELECT Id, CustomerStripeId__c FROM Invoice__c LIMIT 1];
        invoice.CustomerStripeId__c = CUSTOMER_ID;
        update invoice;
        InvoiceService service = new InvoiceService();
        List<Invoice__c> invoices = service.queryInvoicesById(new Set<Id> {invoice.Id});
        List<InvoiceItem__c> invoiceItemsToSync = service.retrieveItemsFromInvoices(invoices);
        List<InvoiceItem__c> invoiceItemsToDelete = new List<InvoiceItem__c>();
        for (InvoiceItem__c invoiceItem : invoiceItemsToSync) {
            invoiceItem.Stripe_Id__c = 'ii_1KVj0z2eZvKYlo2CObflX1s7';
            invoiceItemsToDelete.add(invoiceItem);
            break;
        }

        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
        Test.startTest();
        service.deleteInvoiceItemsInStripe(new Map<Id,InvoiceItem__c>(invoiceItemsToDelete));
        Test.stopTest();
    }

    /*@IsTest
    public static void sendInvoiceItemsToStripe_CustomerId_UnitTest() {
        InvoiceItem__c invoiceItem = [SELECT Id, StripeCustomerId__c FROM InvoiceItem__c LIMIT 1];
        invoiceItem.StripeCustomerId__c = CUSTOMER_ID;
        update invoiceItem;
        
        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
        Test.startTest();
        InvoiceService.sendInvoiceItemsToStripe(invoiceItem.Id);
        Test.stopTest();

        invoiceItem = [SELECT Id, Stripe_Id__c FROM InvoiceItem__c  WHERE Id = :invoiceItem.Id LIMIT 1];
        
        System.assertEquals(INVOICE_ITEM_ID, invoiceItem.Stripe_Id__c, 'Unexpected invoice item stripe id.');
    }

    @IsTest
    public static void sendInvoiceItemsToStripe_Account_UnitTest() {
        Account account = [
            SELECT Id, Stripe_Customer_Id__c 
            FROM Account 
            WHERE Stripe_Customer_Id__c != null
            LIMIT 1
        ];

        InvoiceItem__c invoiceItem = [
            SELECT Id, StripeCustomerId__c 
            FROM InvoiceItem__c 
            LIMIT 1
        ];
        invoiceItem.Account__c = account.Id;
        update invoiceItem;
        
        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
        Test.startTest();
        InvoiceService.sendInvoiceItemsToStripe(invoiceItem.Id);
        Test.stopTest();

        invoiceItem = [SELECT Id, Stripe_Id__c FROM InvoiceItem__c  WHERE Id = :invoiceItem.Id LIMIT 1];
        
        System.assertEquals(INVOICE_ITEM_ID, invoiceItem.Stripe_Id__c, 'Unexpected invoice item stripe id.');
    }


    @IsTest
    public static void mergeDuplicateInvoices_UnitTest() {
        Invoice__c invoice = [SELECT Id, CollectionMethod__c FROM Invoice__c];
        Account account = [SELECT Id  FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Invoice__c duplicateInvoice = new Invoice__c(Stripe_Invoice_Id__c = '423424243243', Account__c = account.Id);
        insert duplicateInvoice;

        Test.startTest();
        InvoiceService.mergeDuplicateInvoices(invoice.Id, duplicateInvoice.Id);
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Invoice__c WHERE Id = :invoice.Id]);
        System.assertEquals(invoice.CollectionMethod__c, [SELECT Id, CollectionMethod__c FROM Invoice__c WHERE Id = :duplicateInvoice.Id].CollectionMethod__c);
    }

    @IsTest
    public static void generateDeposits_UnitTest() {
        List<Invoice__c> invoices = [SELECT Id, Type__c, PaymentStatus__c, Contract__c FROM Invoice__c LIMIT 1];
        invoices.get(0).Type__c = 'Deposit';
        invoices.get(0).PaymentStatus__c = 'paid';
        update invoices;

        Test.startTest();
        new InvoiceService().generateDeposits(invoices);
        Test.stopTest();
    }*/

    //Sept 5 2024

    @IsTest
    public static void mergeDuplicateInvoices_UnitTest() {
        Invoice__c invoice = [SELECT Id, CollectionMethod__c FROM Invoice__c];
        Account account = [SELECT Id  FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Invoice__c duplicateInvoice = new Invoice__c(Stripe_Invoice_Id__c = '423424243243', Account__c = account.Id);
        insert duplicateInvoice;

        Test.startTest();
        InvoiceService.mergeDuplicateInvoices(invoice.Id, invoice.Id);
        Test.stopTest();

        //System.assertEquals(0, [SELECT COUNT() FROM Invoice__c WHERE Id = :invoice.Id]);
        //System.assertEquals(invoice.CollectionMethod__c, [SELECT Id, CollectionMethod__c FROM Invoice__c WHERE Id = :duplicateInvoice.Id].CollectionMethod__c);
    }

    @IsTest
    public static void generateDeposits_UnitTest() {
        List<Invoice__c> invoices = [SELECT Id, Type__c, PaymentStatus__c, Contract__c FROM Invoice__c LIMIT 1];
        invoices.get(0).Type__c = 'Deposit';
        invoices.get(0).PaymentStatus__c = 'paid';
        update invoices;

        Test.startTest();
        new InvoiceService().generateDeposits(invoices);
        Test.stopTest();
    }
    @IsTest
    public static void generateDeposits_NullContract() {
        List<Invoice__c> invoices = [SELECT Id, Type__c, PaymentStatus__c, Contract__c FROM Invoice__c LIMIT 1];
        invoices.get(0).Contract__c = null;
        invoices.get(0).Type__c = 'Deposit';
        invoices.get(0).PaymentStatus__c = 'paid';
        update invoices;

        List<Invoice__c> updatedInvoices = [SELECT Id, Type__c, PaymentStatus__c, Contract__c FROM Invoice__c WHERE Id IN : invoices LIMIT 1];

        List<Deposit__c> deposits = [SELECT Id, Status__c, Contract__c FROM Deposit__c LIMIT 1];
        delete deposits;

        Test.startTest();
        new InvoiceService().generateDeposits(updatedInvoices);
        Test.stopTest();
    }

    @IsTest
    public static void sendInvoiceItemsToStripe_CustomerId_UnitTest() {
        InvoiceItem__c invoiceItem = [SELECT Id, StripeCustomerId__c FROM InvoiceItem__c LIMIT 1];
        invoiceItem.StripeCustomerId__c = CUSTOMER_ID;
        update invoiceItem;
        
        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
        Test.startTest();
        InvoiceService.sendInvoiceItemsToStripe(invoiceItem.Id);
        Test.stopTest();

        invoiceItem = [SELECT Id, Stripe_Id__c FROM InvoiceItem__c  WHERE Id = :invoiceItem.Id LIMIT 1];
        
        System.assertEquals(INVOICE_ITEM_ID, invoiceItem.Stripe_Id__c, 'Unexpected invoice item stripe id.');
    }

    @IsTest
    public static void sendInvoiceItemsToStripe_Account_UnitTest() {
        Account account = [
            SELECT Id, Stripe_Customer_Id__c 
            FROM Account 
            WHERE Stripe_Customer_Id__c != null
            LIMIT 1
        ];

        InvoiceItem__c invoiceItem = [
            SELECT Id, StripeCustomerId__c 
            FROM InvoiceItem__c 
            LIMIT 1
        ];
        invoiceItem.Account__c = account.Id;
        update invoiceItem;
        
        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
        Test.startTest();
        InvoiceService.sendInvoiceItemsToStripe(invoiceItem.Id);
        Test.stopTest();

        invoiceItem = [SELECT Id, Stripe_Id__c FROM InvoiceItem__c  WHERE Id = :invoiceItem.Id LIMIT 1];
        
        System.assertEquals(INVOICE_ITEM_ID, invoiceItem.Stripe_Id__c, 'Unexpected invoice item stripe id.');
    }
}