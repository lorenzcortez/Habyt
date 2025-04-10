public class Product2Selectors {

    public virtual class DefaultProducts extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, Name, RecordTypeId, (SELECT Id, CurrencyIsoCode FROM PricebookEntries WHERE IsActive = true AND Pricebook2Id = :pricebookId) FROM Product2';
        }

        protected virtual override String getWhereClause() {
            return 'IsDefaultContractProduct__c = TRUE';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Id pricebookId = (Id) queryParameters.get('pricebookId');

            return Database.query(query);
        }
    }

    public virtual class ProductsByFrecuencyAndRecordType extends DefaultProducts {
        protected virtual override String getWhereClause() {
            return 'FrequencyPick__c = :frequency AND IsActive = TRUE AND RecordTypeId = :recordTypeId';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            String frequency = (String) queryParameters.get('frequency');
            String recordTypeId = (String) queryParameters.get('recordTypeId');
            Id pricebookId = (Id) queryParameters.get('pricebookId');

            return Database.query(query);
        }
    }

}