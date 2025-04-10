@IsTest
public with sharing class Invoice_c_CreateDeposit_Test {
    public static final String KEY = 'sk_nizvbzv131ibd';
    public static final String CUSTOMER_ID = 'cus_nifweufbiwe';

    @TestSetup
    static void setupTest(){
        Account account = new Account(Name = 'Test Account', Stripe_Customer_Id__c = CUSTOMER_ID);
        insert account;

        Stripe_Account__c stripeAccount = new Stripe_Account__c(Name = 'Habyt GmbH', Secret_key__c = KEY);
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
            Account__c = account.Id,
            Type__c = 'Deposit',
            PaymentStatus__c = 'paid'
        );
        insert invoice;
    }

    @IsTest
    static void ByStripeId_Test() {
        Integer expectedSize = 1;
        List<Invoice__c> invoices = [SELECT Id, AmountRemaining__c FROM Invoice__c LIMIT 1];
        invoices.get(0).AmountRemaining__c = 123;

        Test.startTest();
        update invoices;
        Test.stopTest();

        List<Deposit__c> deposits = [SELECT Id FROM Deposit__c];
        //System.assertEquals(expectedSize, deposits.size());
    }
}