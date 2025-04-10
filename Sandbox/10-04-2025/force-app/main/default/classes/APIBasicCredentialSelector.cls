public class APIBasicCredentialSelector {
    
    public virtual class APIBasicCredentialByUsernameAndPass extends Paua_Selector {
        protected override String getBaseQuery() {
            return 'SELECT Id, MasterLabel FROM APIBasicCredential__mdt';
        }

        protected override String getWhereClause() {
            return 'Username__c = :varUser AND Password__c = :varPass';
        }

        public override List<SObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            String varUser = (String) queryParameters.get('varUser');
            String varPass = (String) queryParameters.get('varPass');

            return Database.query(query);
        }
    }
}