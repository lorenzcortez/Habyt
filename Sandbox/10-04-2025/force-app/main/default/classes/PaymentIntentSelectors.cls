public with sharing class PaymentIntentSelectors {
    public virtual class ByStripeId extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, Invoice__c, StripeId__c, StripeInvoiceId__c, CreatedInStripe__c, StripeFirstCreatedDatetime__c '+
                    'FROM PaymentIntent__c';
        }

        protected virtual override String getWhereClause() {
            return 'StripeId__c IN :stripeIdSet';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<String> stripeIdSet = new Set<String>();
            if (queryParameters.containsKey('stripeId')) {
                stripeIdSet.add((String) queryParameters.get('stripeId'));
            } else {
                stripeIdSet.addAll((Set<String>) queryParameters.get('stripeIdSet'));
            }

            return Database.query(query);
        }
    }
}