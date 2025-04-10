public without sharing class DescriptionSelectors {
    public virtual class DescriptionsByParents extends Paua_Selector {
        protected override String getBaseQuery() {
            return 'SELECT Id, LanguagePick__c, Description__c, ' +
                'RoomRef__c, ApartmentRef__c, PropertyRef__c, NeighbourhoodRef__c ' +
                'FROM Description__c';
        }

        protected virtual override String getWhereClause() {
            List<String> clauses = new List<String>();

            if (queryParameters.containsKey('roomIdSet')) {
                clauses.add('RoomRef__c IN :roomIdSet');
            }
            if (queryParameters.containsKey('apartmentIdSet')) {
                clauses.add('ApartmentRef__c IN :apartmentIdSet');
            }
            if (queryParameters.containsKey('propertyIdSet')) {
                clauses.add('PropertyRef__c IN :propertyIdSet');
            }
            if (queryParameters.containsKey('neighbourhoodIdSet')) {
                clauses.add('NeighbourhoodRef__c IN :neighbourhoodIdSet');
            }

            return String.join(clauses, ' OR ');
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            System.debug(query);

            Set<Id> roomIdSet = (Set<Id>) queryParameters.get('roomIdSet');
            Set<Id> apartmentIdSet = (Set<Id>) queryParameters.get('apartmentIdSet');
            Set<Id> propertyIdSet = (Set<Id>) queryParameters.get('propertyIdSet');
            Set<Id> neighbourhoodIdSet = (Set<Id>) queryParameters.get('neighbourhoodIdSet');

            return Database.query(query);
        }
    }
}