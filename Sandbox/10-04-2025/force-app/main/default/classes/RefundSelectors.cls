public with sharing class RefundSelectors {
    public virtual class ByStripeId extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, CreatedInStripe__c, StripeFirstCreatedDatetime__c ' +
                'FROM Refund__c';
        }

        protected virtual override String getWhereClause() {
            return 'StripeRefundId__c IN :idSet';
        } 
        
        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<String> idSet = new Set<String>();
            if (queryParameters.containsKey('id')) {
                idSet.add((String) queryParameters.get('id'));
            } else {
                idSet.addAll((Set<String>) queryParameters.get('idSet'));
            }

            return Database.query(query);
        }
    }
}