public with sharing class InvoiceTriggerHandler {
    public static void executeRollup(List<Invoice__c> invoices){
        //AggregateResult[] groupedResults = new AggregateResult[] ();
        System.debug('invoices*** '+invoices);
        Set<String> setOfAccounts = new Set<String>();
        for( Invoice__c invoice : invoices ){
            setOfAccounts.add(invoice.Account__c);
        }
        AggregateResult[] groupedResults = [SELECT Account__c, SUM(AmountRemaining__c) amountRemaing FROM Invoice__c WHERE 
                                            						Account__c IN :setOfAccounts AND
                                            						Name != 'Upcoming Invoice' AND
                                            						Status__c != 'Void' AND Status__c != 'Uncollectible'
                                            						GROUP BY Account__c]; 
        

        List<Account> toUpdateAccount = new List<Account>();

        for (AggregateResult ar : groupedResults)  {
            System.debug('Account__c' + ar.get('Account__c'));
            System.debug('amountRemaing' + ar.get('amountRemaing'));
            toUpdateAccount.add(new Account(
                Id = String.valueOf(ar.get('Account__c')),
                Sum_of_Open_Invoices__c = Double.valueOf(ar.get('amountRemaing'))
            ));
        }

        if( toUpdateAccount.size() > 0 ){
            update toUpdateAccount;
        }
    }

    public static void afterUpdate(List<Invoice__c> invoices, Map<Id,Invoice__c> mapOfOldInvoices){
        List<Invoice__c> updatedInvoices = new List<Invoice__c>();
        for( Invoice__c invoice : invoices ){
            if(mapOfOldInvoices.containsKey(invoice.Id)){
                if( invoice.AmountRemaining__c != mapOfOldInvoices.get(invoice.Id).AmountRemaining__c ||  
                  		invoice.Status__c != mapOfOldInvoices.get(invoice.Id).Status__c){ 
                    updatedInvoices.add(invoice);
                }
            }
        }

        if( updatedInvoices.size() > 0 ){
            executeRollup(updatedInvoices);
        }
    }
}