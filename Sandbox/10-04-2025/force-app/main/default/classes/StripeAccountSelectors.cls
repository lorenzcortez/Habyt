public with sharing class StripeAccountSelectors {
    public virtual class ByName extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Name, secret_key__c FROM Stripe_Account__c';
        }

        protected virtual override String getWhereClause() {
            return 'Name = :accountName';
        } 
        
        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            String accountName = (String) queryParameters.get('accountName');

            return Database.query(query);
        }
    }
}