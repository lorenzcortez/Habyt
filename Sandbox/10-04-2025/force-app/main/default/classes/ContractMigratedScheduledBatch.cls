public with sharing class ContractMigratedScheduledBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{
    public void execute(SchedulableContext sc){
        Database.executeBatch(new ContractMigratedScheduledBatch(), 1);
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Contract_End_Date__c, Stripe_Subscription_Id__c, Stripe_Subscription_Status__c, Opportunity__c, Move_out_date__c FROM Contract WHERE Opportunity__r.ReprocessedStatusPick__c = 'Email sent']);
    }

    public void execute(Database.BatchableContext BC, List<Contract> contracts) {
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        for (Contract contract : contracts) {
            if (contract.Contract_End_Date__c != null && contract.Stripe_Subscription_Status__c != 'canceled' && contract.Stripe_Subscription_Id__c != null) {
                IcxStripeInterface.CancelSubscription(contract.Id, contract.Contract_End_Date__c, contract.Move_out_date__c);
                contract.Stripe_Subscription_Status__c = 'canceled';
                opportunityMap.put(contract.Opportunity__c, new Opportunity(Id = contract.Opportunity__c, ReprocessedStatusPick__c = 'Done'));
            } else if (contract.Contract_End_Date__c == null && contract.Stripe_Subscription_Id__c != null) {
                opportunityMap.put(contract.Opportunity__c, new Opportunity(Id = contract.Opportunity__c, ReprocessedStatusPick__c = 'Done'));
            }
        }
        update opportunityMap.values();
        update contracts;
    }

    public void finish(Database.BatchableContext BC) {

    }

}