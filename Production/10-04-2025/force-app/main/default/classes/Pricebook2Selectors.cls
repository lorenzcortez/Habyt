public class Pricebook2Selectors {
    
    public virtual class StandardPricebook extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id FROM Pricebook2';
        }

        protected virtual override String getWhereClause() {
            return 'IsStandard = TRUE';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            if (Test.isRunningTest()) {
                return new List<SObject>{new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true)};
            }
            
            String query = buildQueryFromClauses(clauses);
            return Database.query(query);
        }
    }

}