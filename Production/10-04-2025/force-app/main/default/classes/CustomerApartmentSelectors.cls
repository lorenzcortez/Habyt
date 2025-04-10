public class CustomerApartmentSelectors {
    public virtual class ApartmentByIds extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, Name, PropertyRef__r.City__c, PropertyRef__r.Country__c ' +
    
            'FROM Apartment__c';
        }
    
        protected virtual override String getWhereClause() {
            return 'Id IN :idsSet';
        }
    
        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);
    
            Set<Id> idsSet = (Set<Id>) queryParameters.get('idsSet');
    
            return Database.query(query);
        }
    }
}