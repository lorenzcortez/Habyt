public with sharing class DisputeSelectors {
    public virtual class ByStripeId extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, CreatedInStripe__c, StripeFirstCreatedDatetime__c ' +
                'FROM Dispute__c';
        }

        protected virtual override String getWhereClause() {
            return 'StripeDisputeId__c IN :idSet';
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