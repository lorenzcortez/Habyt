public class RealEstateOpportunitySelectors {
    public virtual class FromId extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, BillingEntity__c, BillingEntity__r.ConditionRef__c, BillingEntity__r.ConditionRef__r.Name ' +
                'FROM Opportunity';
        }

        protected virtual override String getWhereClause() {
            return 'Id IN :idSet';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> idSet = (Set<Id>) queryParameters.get('idSet');

            return Database.query(query);
        }
    }
}