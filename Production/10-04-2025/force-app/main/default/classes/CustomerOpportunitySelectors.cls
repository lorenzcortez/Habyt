public class CustomerOpportunitySelectors {
    
    public virtual class FromId extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, Name, CurrencyIsoCode, Room__c, ApartmentRef__c, Start_Date__c, PlannedEndofContract__c, OpportunitySourcePick__c, ' +
                'StageName, CloseDate, Contract_Category__c, Utilities_Cap__c, Shared_Expenses__c, ContractEndDate__c, ContractIdAuto__c, IsProductPriceBookErrorTrig__c, Description, DepositAmountAuto__c, ' +

                'Account.MembershipStatusPick__c, ' +

                'Room__r.Price__c, Room__r.CurrencyIsoCode, Room__r.NetPrice__c, Room__r.Property__r.ConditionRef__r.DepositMultiplier__c, ' +
                'Room__r.Property__r.Billing_Entity__c, Room__r.Property__r.Billing_Entity__r.Stripe_Account__c, ' + 
                'Room__r.Property__r.City__c, ApartmentRef__r.PropertyRef__r.City__c, ' +
                
                'ApartmentRef__r.Price__c, ApartmentRef__r.CurrencyIsoCode, ApartmentRef__r.NetPrice__c, ApartmentRef__r.PropertyRef__r.ConditionRef__r.DepositMultiplier__c, ' +
                'ApartmentRef__r.PropertyRef__r.Billing_Entity__c, ApartmentRef__r.PropertyRef__r.Billing_Entity__r.Stripe_Account__c, ' +

                '(SELECT Id, Product2Id, Product2.RecordTypeId, RoomRef__c, ApartmentRef__c, UnitPrice, CurrencyIsoCode, Description FROM OpportunityLineItems) ' +

                'FROM Opportunity';
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