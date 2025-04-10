public class BillingEntitySelectors {
    public virtual class FromId extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, ConditionRef__c, ConditionRef__r.Name ' +
                'FROM Billing_Entity__c';
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

    public virtual class FromType extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, Stripe_Account__c, TypePick__c ' +
                'FROM Billing_Entity__c';
        }

        protected virtual override String getWhereClause() {
            return 'TypePick__c = :type';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            String type = (String) queryParameters.get('type');

            return Database.query(query);
        }
    }
}