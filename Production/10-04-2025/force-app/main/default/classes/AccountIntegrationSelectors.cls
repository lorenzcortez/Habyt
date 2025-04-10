public with sharing class AccountIntegrationSelectors {
    public virtual class ByPersonEmail extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, PersonEmail ' + 'FROM Account';
        }

        protected virtual override String getWhereClause() {
            return 'PersonEmail = :personEmail';
        } 
        
        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            String personEmail = (String) queryParameters.get('personEmail');

            return Database.query(query);
        }
    }
}