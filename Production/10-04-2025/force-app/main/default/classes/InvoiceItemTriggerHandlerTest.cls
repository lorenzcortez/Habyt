@isTest
public with sharing class InvoiceItemTriggerHandlerTest {

    public static final String CUSTOMER_ID = 'cus_nifweufbiwe';

    @isTest
    static void scenario(){
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Product2 prod = new Product2(
            Name = 'Recurring Item',
            IsActive = true,
            CurrencyIsoCode = 'EUR'
        );
        insert prod;

        Contract rentContract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        rentContract.RecordTypeId = CustomerContractService.RT_ID_RENT;
        insert rentContract;

        ContractItem__c item1 = TestRecord_Factory.createContractItem(rentContract, prod.Id, room.Id);
        insert item1;

        Invoice__c invoice= new Invoice__c(
            Name = 'Test invoice 1', 
            StripeAccount__c = stripeAcc.Id,
            Description__c = 'Description 1',
            CollectionMethod__c = 'charge_automatically',
            Contract__c = rentContract.Id,
            Account__c = account.Id,
            Stripe_Invoice_Id__c = 'TestStripeId',
            CustomerStripeId__c = CUSTOMER_ID
        );
        insert invoice;

       InvoiceItem__c invoiceItem = new InvoiceItem__c(
            Name = 'Test Invoice Item', 
            Invoice__c = invoice.Id, 
            Description__c = 'Description 1',
            Amount__c = 100,
            PeriodStart__c = Date.today(),
            PeriodEnd__c = Date.today(),
            StripeInvoiceId__c = 'TestStripeId',
            Stripe_Plan_Id__c = 'plan_RKysj9EPcYFkhr',
            Contract_Item__c = item1.Id
        );
        insert invoiceItem;

        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());

        Test.startTest();	
            List<InvoiceItem__c> getInvoiceItem = [SELECT Id, Contract_Item__c, Contract_Item_Product__c From InvoiceItem__c WHERE StripeInvoiceId__c = 'TestStripeId' LIMIT 1];
            System.assertEquals(1, getInvoiceItem.size());
            if(getInvoiceItem.size() > 0){
                delete getInvoiceItem;
            }
        Test.stopTest();	
    }

    @isTest
    static void noContractItemTest(){
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Product2 prod = new Product2(
            Name = 'One-off item',
            IsActive = true,
            CurrencyIsoCode = 'EUR'
        );
        insert prod;

        Contract rentContract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        rentContract.RecordTypeId = CustomerContractService.RT_ID_RENT;
        insert rentContract;

        ContractItem__c item1 = TestRecord_Factory.createContractItem(rentContract, prod.Id, room.Id);
        insert item1;

        Invoice__c invoice= new Invoice__c(
            Name = 'Test invoice 1', 
            StripeAccount__c = stripeAcc.Id,
            Description__c = 'Description 1',
            CollectionMethod__c = 'charge_automatically',
            Contract__c = rentContract.Id,
            Account__c = account.Id,
            Stripe_Invoice_Id__c = 'TestStripeId',
            CustomerStripeId__c = CUSTOMER_ID
        );
        insert invoice;

       InvoiceItem__c invoiceItem = new InvoiceItem__c(
            Name = 'Test Invoice Item 1', 
            Invoice__c = invoice.Id, 
            Description__c = 'Description 1',
            Amount__c = 100,
            PeriodStart__c = Date.today(),
            PeriodEnd__c = Date.today(),
            StripeInvoiceId__c = 'TestStripeId',
            Stripe_Plan_Id__c = 'plan_RKysj9EPcYFkhr',
            Contract_Item__c = item1.Id
        );
        insert invoiceItem;

        InvoiceItem__c invoiceItem1 = new InvoiceItem__c(
            Name = 'Test Invoice Item 2', 
            Invoice__c = invoice.Id, 
            Description__c = 'Description 2',
            Amount__c = 100,
            PeriodStart__c = Date.today(),
            PeriodEnd__c = Date.today(),
            StripeInvoiceId__c = 'TestStripeId',
            Stripe_Plan_Id__c = 'plan_RKysj9EPcYFkhr'
        );
        insert invoiceItem1;

        InvoiceItem__c invoiceItem2 = new InvoiceItem__c(
            Name = 'Test Invoice Item 3', 
            Invoice__c = invoice.Id, 
            Description__c = 'Description 3',
            Amount__c = 100,
            PeriodStart__c = Date.today(),
            PeriodEnd__c = Date.today(),
            StripeInvoiceId__c = 'TestStripeId',
            Stripe_Plan_Id__c = 'plan_RKysj9EPcYFkhr'
        );
        insert invoiceItem2;

        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());

        List<InvoiceItem__c> getInvoiceItem = [SELECT Id, Contract_Item__c, Amount__c, Contract_Item_Product__c From InvoiceItem__c WHERE StripeInvoiceId__c = 'TestStripeId'];

        Test.startTest();	
            update getInvoiceItem;
        Test.stopTest();	

        System.assert([SELECT One_Off_Adjustments__c FROM Invoice__c WHERE Id =: invoice.Id].One_Off_Adjustments__c == 300);
    }
}