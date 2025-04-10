public with sharing class DepositSelectors {
    public virtual class ById extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, Contract__c, Deposit__c, Room__c, Status__c, Name, OriginalAmount__c, AdjustmentAmount__c, ' +
                    'FinalAmount__c, Contract__r.Billing_Entity__r.Name, Contract__r.Room__c, Contract__r.Account.UserId__c, ' +
                    'Contract__r.ContractNumber, Contract__r.Room__r.Name, Contract__r.Property__r.Billing_Entity__r.Name ' +
                'FROM Deposit__c';
        }

        protected virtual override String getWhereClause() {
            return 'Id IN :idSet';
        } 
        
        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> idSet = new Set<Id>();
            if (queryParameters.containsKey('id')) {
                idSet.add((Id) queryParameters.get('id'));
            } else {
                idSet.addAll((Set<Id>) queryParameters.get('idSet'));
            }

            return Database.query(query);
        }
    }
}