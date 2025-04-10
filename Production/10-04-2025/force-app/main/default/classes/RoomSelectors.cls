public class RoomSelectors {
    public virtual class RoomsWithApartmentAndProperty extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, Name, CurrencyIsoCode, Room_Number__c, SizeNumber__c, Price__c, NetPrice__c, IsBookableAuto__c, AvailableDateTrig__c, TypePick__c, ' +
                'LastModifiedDate, EarliestStartOfContractAuto__c, LatestStartOfContractAuto__c, UnitSizePick__c, Status__c, ' +

                // Property Fields
                'Property__c, Property__r.Name, Property__r.CurrencyIsoCode, Property__r.Street__c, Property__r.Postal_Code__c, Property__r.NeighbourhoodRef__c, ' + //Property__r.StreetNumber__c,
                'Property__r.NeighbourhoodRef__r.Name, Property__r.City__c, Property__r.Country__c, ' + 
                'Property__r.BrandRef__r.Name, Property__r.BrandRef__r.APINameBrand__c, ' +
                'Property__r.PropertyLocation__latitude__s, Property__r.PropertyLocation__longitude__s, ' +

                // Property Condition
                'Property__r.ConditionRef__c, Property__r.ConditionRef__r.Name, Property__r.ConditionRef__r.CurrencyIsoCode, Property__r.ConditionRef__r.ContractDurationTypePick__c, '+
                'Property__r.ConditionRef__r.MaximumStayNumber__c, Property__r.ConditionRef__r.MaximumStayUnitPick__c, ' +
                'Property__r.ConditionRef__r.MinimumStayNumber__c, Property__r.ConditionRef__r.MinimumStayUnitPick__c, ' +
                'Property__r.ConditionRef__r.NoticePeriodNumber__c, Property__r.ConditionRef__r.NoticePeriodTypePick__c, ' +
                'Property__r.ConditionRef__r.NoticePeriodUnitPick__c, Property__r.ConditionRef__r.DepositMultiplier__c, ' +
                'Property__r.ConditionRef__r.MembershipFee__c, Property__r.ConditionRef__r.DepositRule__c, Property__r.ConditionRef__r.AbsoluteDepositAmount__c, ' +

                // Property Billing Entity
                'Property__r.Billing_Entity__c, Property__r.Billing_Entity__r.Name, Property__r.Billing_Entity__r.CurrencyIsoCode, Property__r.Billing_Entity__r.ConditionRef__c, ' + 

                // Property Billing Entity Condition
                'Property__r.Billing_Entity__r.ConditionRef__r.Name, Property__r.Billing_Entity__r.ConditionRef__r.CurrencyIsoCode, Property__r.Billing_Entity__r.ConditionRef__r.ContractDurationTypePick__c, ' +
                'Property__r.Billing_Entity__r.ConditionRef__r.MaximumStayNumber__c, Property__r.Billing_Entity__r.ConditionRef__r.MaximumStayUnitPick__c, ' +
                'Property__r.Billing_Entity__r.ConditionRef__r.MinimumStayNumber__c, Property__r.Billing_Entity__r.ConditionRef__r.MinimumStayUnitPick__c, ' +
                'Property__r.Billing_Entity__r.ConditionRef__r.NoticePeriodNumber__c, Property__r.Billing_Entity__r.ConditionRef__r.NoticePeriodTypePick__c, ' +
                'Property__r.Billing_Entity__r.ConditionRef__r.NoticePeriodUnitPick__c, Property__r.Billing_Entity__r.ConditionRef__r.DepositMultiplier__c, ' +
                'Property__r.Billing_Entity__r.ConditionRef__r.MembershipFee__c, ' +

                // Apartment Fields
                'ApartmentRef__c, ApartmentRef__r.FloorPick__c, ApartmentRef__r.CurrencyIsoCode, ApartmentRef__r.Bedroom__c, ApartmentRef__r.Number_of_units__c, ApartmentRef__r.UnitSizePick__c, ' +
                'ApartmentRef__r.SizeNumber__c, ApartmentRef__r.Status__c, ApartmentRef__r.Name ' +
            'FROM Room__c';
        }
    }

    public virtual class RoomCountByApartment extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT COUNT(Id), ApartmentRef__c FROM Room__c';
        }

        protected virtual override String getWhereClause() {
            return 'ApartmentRef__c IN :apartmentIdSet GROUP BY ApartmentRef__c';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> apartmentIdSet = (Set<Id>) queryParameters.get('apartmentIdSet');

            return Database.query(query);
        }
    }

    // We don't need this right now, maybe later?

    /* public virtual class RoomsWithDocuments extends Paua_Selector {
        protected override String getBaseQuery() {
            return 'SELECT Id, ApartmentRef__c, Property__c, ' + 
                '(SELECT ContentDocumentId, LatestPublishedVersionId FROM ContentDocumentLinks) ' +
            'FROM Room__c';
        }

        protected override String getWhereClause() {
            List<String> criteria = new List<String>();
            if (queryParameters.containsKey('apartmentIdSet')) {
                criteria.add('ApartmentRef__c IN :apartmentIdSet');
            }
            if (queryParameters.containsKey('roomIdSet')) {
                criteria.add('Id IN :roomIdSet');
            }
            return String.join(criteria, ' OR ');
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> apartmentIdSet = queryParameters.containsKey('apartmentIdSet') ? (Set<Id>) queryParameters.get('apartmentIdSet') : new Set<Id>();
            Set<Id> roomIdSet = queryParameters.containsKey('roomIdSet') ? (Set<Id>) queryParameters.get('roomIdSet') : new Set<Id>();

            return Database.query(query);
        }
    } */
}