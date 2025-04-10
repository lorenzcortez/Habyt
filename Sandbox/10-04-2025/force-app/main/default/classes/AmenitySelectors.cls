public class AmenitySelectors {
    public virtual class RoomAmenitiesByRoom extends Paua_Selector {
        protected override String getBaseQuery() {
            return 'SELECT Id, AmenityRef__r.Name, RoomRef__c, CurrencyIsoCode, RoomRef__r.ApartmentRef__c, RoomRef__r.Property__c FROM RoomAmenity__c';
        }

        protected virtual override String getWhereClause() {
            return 'RoomRef__c IN :roomIdSet';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> roomIdSet = (Set<Id>) queryParameters.get('roomIdSet');

            return Database.query(query);
        }
    }

    public virtual class RoomAmenitiesByApartment extends RoomAmenitiesByRoom {
        protected override String getWhereClause() {
            return 'RoomRef__r.ApartmentRef__c IN :apartmentIdSet';
        }

        public override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> apartmentIdSet = (Set<Id>) queryParameters.get('apartmentIdSet');

            return Database.query(query);
        }
    }

    public virtual class ApartmentAmenitiesByApartment extends Paua_Selector {
        protected override String getBaseQuery() {
            return 'SELECT Id, AmenityRef__r.Name, ApartmentRef__c, CurrencyIsoCode, ApartmentRef__r.PropertyRef__c FROM ApartmentAmenity__c';
        }

        protected override String getWhereClause() {
            return 'ApartmentRef__c IN :apartmentIdSet';
        }

        public override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> apartmentIdSet = (Set<Id>) queryParameters.get('apartmentIdSet');

            return Database.query(query);
        }
    }

    public virtual class PropertyAmenitiesByProperty extends Paua_Selector {
        protected override String getBaseQuery() {
            return 'SELECT Id, AmenityRef__r.Name, CurrencyIsoCode, PropertyRef__c FROM PropertyAmenity__c';
        }

        protected override String getWhereClause() {
            return 'PropertyRef__c IN :propertyIdSet';
        }

        public override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> propertyIdSet = (Set<Id>) queryParameters.get('propertyIdSet');

            return Database.query(query);
        }
    }
}