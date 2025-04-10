public class CustomerContractSelectors {

    public virtual class Contracts extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, StartDate, Status, CurrencyIsoCode, RecordTypeId, RecordType.Name, RecordType.DeveloperName, ContractNumber, ' +
                'Stripe_Account__r.secret_key__c, Contract_Category__c, STRIPE_Plan_Id__c, EverSign_Doc_Hash__c, CreatedDate, Contract_End_Date__c, ' +
                'Fiscal_code__c, Country__c, MoveInEmailDatetime__c, MoveOutEmailDatetime__c, ' +
                'Opportunity__c, Opportunity__r.One_off_DIscount__c, Opportunity__r.BrandAuto__c, ' +
                'Opportunity__r.Monthly_Price__c, Opportunity__r.Account.FirstName, Opportunity__r.Account.LastName,' + 

                'AccountId, Account.PersonContactId, Account.Stripe_Customer_Id__c, Account.Name, Account.PersonEmail, Account.LastName, ' +
                'Account.FirstName, Account.PersonMailingStreet, Account.PersonMailingPostalCode, Account.PersonMailingCity, ' + 
                'Account.PersonMailingCountry, Account.UserId__c, Account.IdNumber__c, Account.StripeCustomerJSONMap__c, ' +  
                'Deposit__c, ' +
                
                'Billing_Entity__r.Name, Billing_Entity__r.Street__c, Billing_Entity__r.Postal_Code__c, ' + 
                'Billing_Entity__r.Country__c, Billing_Entity__r.City__c, ' +
                'Billing_Entity__r.LesseeName__c, Billing_Entity__r.LessorName__c, ' +
                'Billing_Entity__r.RENTAL_CONTRACT__c, ' +
                'Billing_Entity__r.TERMS_AND_CONDITIONS_FOR_INTERNET_USE__c, ' +
                'Billing_Entity__r.HOUSE_RULES__c, ' +

                'Room__r.Property__r.BrandRef__r.Name, Room__r.Property__r.BrandRef__r.APINameBrand__c, ' +
                'ApartmentRef__r.PropertyRef__r.BrandRef__r.Name, ApartmentRef__r.PropertyRef__r.BrandRef__r.APINameBrand__c, ' +
                'StripeCustomerId__c, StripeCustomerJSONMap__c, Stripe_Subscription_Id__c, ' +

                'Room__r.Property__r.BrandRef__r.MoveEmailNotifications__c, Room__r.Property__r.BrandRef__r.MoveInTemplateName__c, ' + 
                'Room__r.Property__r.BrandRef__r.MoveOutTemplateName__c, Room__r.Property__r.BrandRef__r.EmailDomain__c, ' +
                'Room__r.Name, Property__r.Name, Property__r.City__c, Property__r.Postal_Code__c, Property__r.Street__c, ' +

                'Property__r.ConditionRef__r.MaximumStayUnitPick__c, Property__r.ConditionRef__r.MaximumStayNumber__c, ' +

                '(SELECT Id FROM Invoices__r), ' +
                '(SELECT Id, ProductRef__r.Name, CurrencyIsoCode, PriceTrig__c, Description__c FROM Contract_Items__r) ' +

            'FROM Contract';
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

    public virtual class ContractsByOpportunity extends Contracts {
        protected virtual override String getWhereClause() {
            return 'Opportunity__c IN :idSet';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> idSet = new Set<Id>();
            if (queryParameters.containsKey('oppId')) {
                idSet.add((Id) queryParameters.get('oppId'));
            } else {
                idSet.addAll((Set<Id>) queryParameters.get('oppIdSet'));
            }

            return Database.query(query);
        }
    }

    public virtual class ActiveContractsByOpportunity extends Contracts {
        protected virtual override String getWhereClause() {
            return 'Opportunity__c IN :idSet ' +
                   'AND (Status IN :relevantStatuses)';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> idSet = new Set<Id>();
            if (queryParameters.containsKey('oppId')) {
                idSet.add((Id) queryParameters.get('oppId'));
            } else {
                idSet.addAll((Set<Id>) queryParameters.get('oppIdSet'));
            }

            Set<String> relevantStatuses = new Set<String>{
                CustomerContractService.STATUS_SIGNED, 
                CustomerContractService.STATUS_ACTIVATED
            };

            return Database.query(query);
        }
    }

    public virtual class ContractsByOpportunityAndRecordType extends Contracts {
        protected virtual override String getWhereClause() {
            return 'Opportunity__c IN :idSet AND RecordTypeId = :recordTypeId';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> idSet = new Set<Id>();
            if (queryParameters.containsKey('id')) {
                idSet.add((Id) queryParameters.get('id'));
            } else {
                idSet.addAll((Set<Id>) queryParameters.get('idSet'));
            }

            Id recordTypeId = (Id) queryParameters.get('rtId');
            return Database.query(query);
        }
    }

    public virtual class ContractItems extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, CurrencyIsoCode, PriceTrig__c, ' + 
                'ProductRef__r.Name, ProductRef__r.Description, ProductRef__r.FrequencyPick__c, ProductRef__r.RecordTypeId, ' + 
                
                'RoomRef__r.Name, RoomRef__r.Property__r.Street__c, RoomRef__r.Property__r.Postal_Code__c, RoomRef__r.SizeNumber__c, ' + 
                'RoomRef__r.Property__r.City__c, RoomRef__r.Property__r.Country__c, RoomRef__r.UnitSizePick__c, ' + 
                
                'ContractRef__r.StartDate, ContractRef__c, ContractRef__r.Stripe_Account__r.secret_key__c, NumberOfMonths__c, ' +
                'StripeCouponId__c, ContractRef__r.Account.Stripe_Customer_Id__c, Name, Description__c ' +
                
                'FROM ContractItem__c';
        }

        protected virtual override String getWhereClause() {
            return 'ContractRef__c IN :idSet ORDER BY ProductRef__r.Name DESC';
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

    public virtual class ContractItemsNotAdditionalItems extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, PriceTrig__c, ' +
                'ProductRef__r.Name, ProductRef__r.Description, ProductRef__r.FrequencyPick__c, ProductRef__r.RecordTypeId, ' +

                'RoomRef__r.Name, RoomRef__r.Property__r.Street__c, RoomRef__r.Property__r.Postal_Code__c, RoomRef__r.SizeNumber__c, ' +
                'RoomRef__r.Property__r.City__c, RoomRef__r.Property__r.Country__c, RoomRef__r.UnitSizePick__c, ' +

                'ContractRef__r.StartDate, ContractRef__c ' +

                'FROM ContractItem__c';
        }

        protected virtual override String getWhereClause() {
            return 'ContractRef__c IN :idSet AND ProductRef__r.RecordType.DeveloperName != \'AdditionalItem\' ORDER BY ProductRef__r.Name DESC';
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

    public virtual class ContractsByPieces extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Contract_End_Date__c, Country__c, StartDate, Status, Room__c, RecordTypeId, MoveInEmailDatetime__c, MoveOutEmailDatetime__c, ' +

                   'Opportunity__r.BrandRef__r.MoveInTemplateName__c, Opportunity__r.BrandRef__r.MoveOutTemplateName__c, ' +
                   'Opportunity__r.BrandRef__r.MoveEmailNotifications__c, ' + 
                   'Opportunity__r.BrandAuto__c, Room__r.Property__r.Property_Type__c, ' + 
            
                   'Account.PersonEmail, AccountId, Account.Name, Account.FirstName, Account.LastName, ' + 
                   'Account.PersonContactId, isTestContract__c, ' + 
            
                   'Room__r.Property__r.BrandRef__r.MoveEmailNotifications__c, Room__r.Property__r.BrandRef__r.MoveInTemplateName__c, ' + 
                   'Room__r.Property__r.BrandRef__r.MoveOutTemplateName__c, Room__r.Property__r.BrandRef__r.EmailDomain__c, ' +
                   'Room__r.Property__r.BrandRef__r.APINameBrand__c, Room__r.ApartmentRef__c, ApartmentRef__c ' +
            'FROM Contract';
        }

        protected virtual override String getWhereClause() {
            return '(Room__c IN :idSet OR ApartmentRef__c IN :idSet) ' + 
                   'AND (Status IN :relevantStatuses)';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> idSet = new Set<Id>();
            if (queryParameters.containsKey('id')) {
                idSet.add((Id) queryParameters.get('id'));
            } else {
                idSet.addAll((Set<Id>) queryParameters.get('idSet'));
            }

            Set<String> relevantStatuses = new Set<String>{
                CustomerContractService.STATUS_SIGNED, 
                CustomerContractService.STATUS_ACTIVATED,
                CustomerContractService.STATUS_TERMINATED
            };

            return Database.query(query);
        }
    }

    public virtual class ByEndDateAndStatus extends ContractsByPieces {
        protected virtual override String getWhereClause() {
            return '(Contract_End_Date__c = :dateValue) AND ' +
                   '(Status IN :relevantStatuses)';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Date dateValue = (Date) queryParameters.get('dateValue');
            Set<String> relevantStatuses = (Set<String>) queryParameters.get('relevantStatuses');
            
            return Database.query(query);
        }
    }

    public virtual class ByStartDateAndStatus extends ByEndDateAndStatus {
        protected virtual override String getWhereClause() {
            return '(StartDate = :dateValue) AND ' +
                   '(Status IN :relevantStatuses)';
        }
    }

    public virtual class ByAccountId extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, Country__c, RecordTypeId, Stripe_Subscription_Id__c, Stripe_Account__r.Secret_key__c, Room__c, Status, ' +
                   'Contract_End_Date__c, Move_out_date__c, AccountId ' + 
            'FROM Contract';
        }

        protected virtual override String getWhereClause() {
            return 'AccountId in :idSet';
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

    public virtual class ByStartDateStatusAndCountry extends ByStartDateAndStatus {
        protected virtual override String getWhereClause() {
            return '(StartDate = :dateValue) AND ' +
                   '(Status NOT IN :forbiddenStatuses) AND ' + 
                   '(Property__r.Country__c in :countries)';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Date dateValue = (Date) queryParameters.get('dateValue');
            Set<String> forbiddenStatuses = (Set<String>) queryParameters.get('forbiddenStatuses');
            Set<String> countries = (Set<String>) queryParameters.get('countries');

            return Database.query(query);
        }
    }

    public virtual class ActiveTodayByPropertyOrApartment extends Contracts {
        protected virtual override String getWhereClause() {
            return '(Contract_End_Date__c > TODAY OR Contract_End_Date__c = null) AND ' +
                'StartDate <= TODAY AND Status IN :relevantStatuses AND ' + 
                'RecordTypeId = :rentRT_Id AND ' +
                (queryParameters.containsKey('propertyId') ? 
                    'Room__r.Property__c = :propertyId' : 'Room__r.ApartmentRef__c = :apartmentId');
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            String rentRT_Id = CustomerContractService.RT_ID_RENT;

            Set<String> relevantStatuses = new Set<String>{
                CustomerContractService.STATUS_SIGNED, 
                CustomerContractService.STATUS_ACTIVATED,
                CustomerContractService.STATUS_TERMINATED
            };

            Id propertyId = (Id) queryParameters.get('propertyId');
            Id apartmentId = (Id) queryParameters.get('apartmentId');
            return Database.query(query);
        }
    }

    public virtual class BySubscriptionId extends Contracts {
        protected virtual override String getWhereClause() {
            return 'Stripe_Subscription_Id__c IN :idSet';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<String> idSet = new Set<String>();
            if (queryParameters.containsKey('subscriptionId')) {
                idSet.add((String) queryParameters.get('subscriptionId'));
            } else {
                idSet.addAll((Set<String>) queryParameters.get('subscriptionIdSet'));
            }

            return Database.query(query);
        }
    }

    public virtual class ById extends Contracts {

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