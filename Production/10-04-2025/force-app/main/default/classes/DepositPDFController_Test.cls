@IsTest
public with sharing class DepositPDFController_Test {

    @TestSetup
    static void setupTest(){

        Account account = new Account(Name = 'Test Account', Stripe_Customer_Id__c = InvoiceService_Test.CUSTOMER_ID);
        insert account;

        Stripe_Account__c stripeAccount = new Stripe_Account__c(Name = 'Habyt GmbH', Secret_key__c = InvoiceService_Test.KEY);
        insert stripeAccount;

        Contract contract = new Contract(
            AccountId = account.Id, 
            Stripe_Account__c = stripeAccount.Id,
            StartDate = System.today(),
            RecordTypeId = Contract.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Rent').getRecordTypeId()
        );
        insert contract;

        Invoice__c invoice= new Invoice__c( 
            Name = 'Test invoice 1', 
            StripeAccount__c = stripeAccount.Id,
            Description__c = 'Description 1',
            CollectionMethod__c = 'charge_automatically',
            Contract__c = contract.Id,
            Account__c = account.Id
        );
        insert invoice;

        List<InvoiceItem__c> invoiceItems = new List<InvoiceItem__c>(); 
        invoiceItems.add(new InvoiceItem__c(
            Name = 'Test Invoice Item', 
            Invoice__c = invoice.Id, 
            Description__c = 'Description 1',
            Amount__c = 100,
            PeriodStart__c = Date.today(),
            PeriodEnd__c = Date.today()
        ));
        insert invoiceItems;

        Deposit__c deposit = new Deposit__c(Status__c=DepositService.STATUS_SUBMITTED, Contract__c = contract.Id);
        insert deposit;
    }

    @IsTest
    static void generateDepositFile_UnitTest() {
        Deposit__c deposit = [SELECT Id FROM Deposit__c LIMIT 1];
        Integer expectedSize = 1;

        ApexPages.StandardController standardController = new ApexPages.StandardController(deposit);
        PageReference pageRef = Page.DepositPDF;
        pageRef.getParameters().put('id', String.valueOf(deposit.Id));
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DepositPDFController controller = new DepositPDFController(standardController);
        Test.stopTest();

        System.assertEquals(expectedSize, controller.invoiceItems.size(), 'Invoice items size unexpected');
    }
}