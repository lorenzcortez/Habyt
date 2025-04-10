public with sharing class InvoiceItemSelectors {
    public virtual class ById extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, Invoice__r.CustomerStripeId__c, StripeInvoiceId__c, StripeCustomerId__c, Currency__c, ' + 
                   'Description__c, Amount__c, Quantity__c, Invoice__r.Stripe_Invoice_Id__c, ' +
                   'PeriodStart__c, PeriodEnd__c, Stripe_Id__c, Invoice__r.Account__r.Stripe_Customer_Id__c, ' +
                   'Account__r.Stripe_Customer_Id__c, Contract__r.Stripe_Account__r.Secret_key__c, Contract__r.Stripe_Account__c, ' +
                   'Invoice__r.Contract__c, Invoice__r.Contract__r.Stripe_Account__c, Invoice__r.Contract__r.Stripe_Account__r.Secret_key__c, ' +
                   'Invoice__r.Contract__r.AccountId, Contract__r.AccountId, Invoice__r.Contract__r.StripeCustomerId__c, ' +
                   'Invoice__r.Contract__r.Account.Stripe_Customer_Id__c, Contract__r.StripeCustomerId__c ' +
                'FROM InvoiceItem__c';
        }

        protected virtual override String getWhereClause() {
            return 'Id IN :idSet';
        } 
        
        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> idSet = new Set<Id>();
            if (queryParameters.containsKey('id')) {
                idSet.add((Id) queryParameters.get('id'));
            } else {
                idSet.addAll((Set<Id>) queryParameters.get('idSet'));
            }

            return Database.query(query);
        }
    }
}