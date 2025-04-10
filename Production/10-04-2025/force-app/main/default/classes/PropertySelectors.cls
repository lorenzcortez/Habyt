public class PropertySelectors {
    public virtual class AllProperties extends Paua_Selector {
        protected override String getBaseQuery() {
            return 'SELECT Id, City__c, City_Picklist__c, Opportunity__c, ConditionRef__c, Property_Number__c, ApartmentNamePart__c, ConditionRef__r.Name, ' +
                        'Billing_Entity__c, Billing_Entity__r.ConditionRef__c, Billing_Entity__r.ConditionRef__r.Name ' +
                    'FROM Property__c';
        }
    }

    public virtual class PropertiesWithDocuments extends Paua_Selector {
        protected override String getBaseQuery() {
            return 'SELECT Id, (SELECT ContentDocumentId FROM ContentDocumentLinks) FROM Property__c';
        }

        protected override String getWhereClause() {
            return 'Id IN :propertyIdSet';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> propertyIdSet = (Set<Id>) queryParameters.get('propertyIdSet');

            return Database.query(query);
        }
    }

    public virtual class PropertiesByBrandApiName extends AllProperties {
        protected override String getWhereClause() {
            return 'BrandRef__r.APINameBrand__c IN :brandSet';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<String> brandSet = (Set<String>) queryParameters.get('brandSet');

            return Database.query(query);
        }
    }
}