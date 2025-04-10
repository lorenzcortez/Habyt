public with sharing class InvoiceSelectors {
    public virtual class ByStripeId extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT id, PaymentIntentStatus__c, PaymentDate__c, Stripe_Invoice_Id__c, Type__c,' + 
                   'CustomerStripeId__c, Description__c, SubscriptionId__c, AutoAdvance__c, CollectionMethod__c, ' +
                   'Currency__c, StripeAccount__r.Secret_key__c, Account__r.Stripe_Customer_Id__c, Contract__r.Stripe_Subscription_Id__c, ' +
                   'DueDate__c, DaysUntilDue__c, Contract__r.Stripe_Account__c, Contract__r.Account.Stripe_Customer_Id__c, ' +
                   'Contract__r.StripeCustomerId__c, Contract__r.AccountId, Contract__r.Stripe_Account__r.Secret_key__c, ' +
                   'CreatedInStripe__c, PaymentStatus__c, Amount_Due__c, Amount_Paid__c, AmountRemaining__c, Status__c, ' +
                   'PeriodStart__c, PeriodEnd__c, Contract__c, AmountDisputed__c, Contract__r.Room__c, Name, DepositDocumentDescription__c, ' +
                    'StripeFirstCreatedDatetime__c, ' +
                   '(SELECT Id, Status__c, CreatedInStripe__c FROM PaymentIntents__r), ' +

                   '(SELECT Id, Invoice__r.CustomerStripeId__c, StripeInvoiceId__c, StripeCustomerId__c, Currency__c,' +
                   'Description__c, Amount__c, Quantity__c, Invoice__r.Stripe_Invoice_Id__c, ' +
                   'PeriodStart__c, PeriodEnd__c, Stripe_Id__c, Invoice__r.Account__r.Stripe_Customer_Id__c, StripeAccount__c, ' +
                   'StripeAccount__r.Secret_key__c, Invoice__r.StripeAccount__r.Secret_key__c, Account__r.Stripe_Customer_Id__c, ' +
                   'Contract__r.Stripe_Account__r.Secret_key__c, Contract__r.Stripe_Account__c, ' + 
                   'Invoice__r.Contract__r.Stripe_Account__r.Secret_key__c, Invoice__r.Contract__r.Stripe_Account__c, Invoice__r.Contract__c, ' +
                   'Invoice__r.Contract__r.AccountId, Contract__r.AccountId, Invoice__r.Contract__r.Account.Stripe_Customer_Id__c, ' +
                   'Contract__r.Account.Stripe_Customer_Id__c, Invoice__r.Contract__r.StripeCustomerId__c, Name ' +
                   'FROM InvoiceItems__r) ' +
                'FROM Invoice__c';
        }

        protected virtual override String getWhereClause() {
            return 'Stripe_Invoice_Id__c IN :stripeInvoiceIdSet';
        } 
        
        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<String> stripeInvoiceIdSet = new Set<String>();
            if (queryParameters.containsKey('stripeInvoiceId')) {
                stripeInvoiceIdSet.add((String) queryParameters.get('stripeInvoiceId'));
            } else {
                stripeInvoiceIdSet.addAll((Set<String>) queryParameters.get('stripeInvoiceIdSet'));
            }

            return Database.query(query);
        }
    }

    public virtual class ById extends ByStripeId {
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