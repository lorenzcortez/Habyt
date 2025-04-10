public class CustomerOpportunityLineItemSelectors {
    
    public virtual class FromProducts extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id ' +
                'FROM OpportunityLineItem';
        }

        protected virtual override String getWhereClause() {
            return 'OpportunityId IN :setOppIds AND Product2Id IN :setProduct2Ids';
        }
        
        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> setOppIds = (Set<Id>) queryParameters.get('setOppIds');
            Set<Id> setProduct2Ids = (Set<Id>) queryParameters.get('setProduct2Ids');

            return Database.query(query);
        }
    }
}