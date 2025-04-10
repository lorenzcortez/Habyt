public class PersonAccountSelectors {

    public virtual class FromEmail extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, Name, PersonEmail, UserId__c, CustomerStatusPick__c FROM Account';
        }

        protected virtual override String getWhereClause() {
            return 'PersonEmail IN :emails';
        }
        
        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<String> emails = (Set<String>) queryParameters.get('emails');

            return Database.query(query);
        }
    }

    public virtual class FromUserId extends FromEmail {
        protected virtual override String getWhereClause() {
            return 'UserId__c IN :userIds';
        }
        
        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<String> userIds = (Set<String>) queryParameters.get('userIds');

            return Database.query(query);
        }
    }

    public virtual class FromAccountIds extends FromEmail {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, PersonEmail, PersonContactId, FirstName, LastName, ' + 
                   '(SELECT Id, Status, RecordTypeId, Contract_End_Date__c, StartDate FROM Contracts) ' + 
                   'FROM Account';
        }

        protected virtual override String getWhereClause() {
            return 'Id IN :accountIds';
        }
        
        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> accountIds = (Set<Id>) queryParameters.get('accountIds');

            return Database.query(query);
        }
    }
}