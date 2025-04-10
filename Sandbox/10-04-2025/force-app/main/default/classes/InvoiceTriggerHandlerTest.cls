@isTest
public class InvoiceTriggerHandlerTest {
    @isTest
    static void scenario(){
        Account account = new Account(Name = 'Test Account', Stripe_Customer_Id__c = 'cus_nifweufbiwe');
        insert account;

        Stripe_Account__c stripeAccount = new Stripe_Account__c(Name = 'Habyt GmbH', Secret_key__c = 'sk_nizvbzv131ibd');
        insert stripeAccount;

        Contract contract = new Contract(
            AccountId = account.Id, 
            Stripe_Account__c = stripeAccount.Id,
            StartDate = System.today(),
            RecordTypeId = Contract.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Rent').getRecordTypeId()
        );
        insert contract;

        Invoice__c invoice = new Invoice__c(
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

        invoice.AmountRemaining__c = 100;
        update invoice;
    }
    
    @isTest
    static void scenario2(){
        Account account = new Account(Name = 'Test Account', Stripe_Customer_Id__c = 'cus_nifweufbiwe');
        insert account;

        Stripe_Account__c stripeAccount = new Stripe_Account__c(Name = 'Habyt GmbH', Secret_key__c = 'sk_nizvbzv131ibd');
        insert stripeAccount;

        Contract contract = new Contract(
            AccountId = account.Id, 
            Stripe_Account__c = stripeAccount.Id,
            StartDate = System.today(),
            RecordTypeId = Contract.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Rent').getRecordTypeId()
        );
        insert contract;

        Invoice__c invoice = new Invoice__c(
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
        
		List<Invoice__c> updatedInvoices = new List<Invoice__c>();
        Map<Id,Invoice__c> mapOfOldInvoices = new Map<Id,Invoice__c>();
        
        updatedInvoices.add(invoice);
        
        invoice.AmountRemaining__c = 100;
        update invoice;
        
        mapOfOldInvoices.put(invoice.Id,invoice);
        
        
        
        Test.startTest();	
        	InvoiceTriggerHandler.afterUpdate(updatedInvoices, mapOfOldInvoices);
        Test.stopTest();
        
    }
}