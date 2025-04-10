public class CustomerRoomSelectors {
    public virtual class RoomsByIds extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, Name, Property__r.City__c, Property__r.Country__c, ApartmentRef__c, Property__c, '+ 
                   '(SELECT Id, Status, RecordTypeId, Contract_End_Date__c, StartDate, AccountId, Account.Name FROM Contracts__r) ' + 
                   'FROM Room__c';
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

    //TODO: remove this once all references are replaced
    public virtual class RoomsByIdsWithContracts extends RoomsByIds {}


    public virtual class RoomsWithPropertyAndConditions extends RoomSelectors.RoomsWithApartmentAndProperty {
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