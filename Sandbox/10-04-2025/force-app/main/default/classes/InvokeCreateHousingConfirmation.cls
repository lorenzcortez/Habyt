public class InvokeCreateHousingConfirmation {
    
    @InvocableMethod(Description = 'Executes createHousingConfirmation from CustomerContractService' label='Create Housing Confirmation')
    public static List<FlowInput> createHousingConfirmation(List<FlowInput> input) {
        List<FlowInput> inputList = new List<FlowInput>();
        if(input != null) {
            String qry = 'SELECT Id, StartDate, Status, CurrencyIsoCode, RecordTypeId, RecordType.Name, RecordType.DeveloperName, ContractNumber, ' +
            'Stripe_Account__r.secret_key__c, Contract_Category__c, STRIPE_Plan_Id__c, EverSign_Doc_Hash__c, CreatedDate, Contract_End_Date__c, ' +
            'Fiscal_code__c, Country__c, MoveInEmailDatetime__c, MoveOutEmailDatetime__c, ' +
            'Opportunity__c, Opportunity__r.One_off_DIscount__c, Opportunity__r.BrandAuto__c, ' +
            'Opportunity__r.Monthly_Price__c, Opportunity__r.Account.FirstName, Opportunity__r.Account.LastName,' + 

            'AccountId, Account.PersonContactId, Account.IsPersonAccount,Account.Stripe_Customer_Id__c, Account.Name, Account.PersonEmail, Account.LastName, ' +
            'Account.FirstName, Account.PersonMailingStreet, Account.PersonMailingPostalCode, Account.PersonMailingCity, ' + 
            'Account.PersonMailingCountry, Account.UserId__c, Account.IdNumber__c, Account.StripeCustomerJSONMap__c, ' +
            
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
            '(SELECT Id, ProductRef__r.Name, CurrencyIsoCode, PriceTrig__c, Description__c FROM Contract_Items__r), API_Name_Brand__c ' +

            'FROM Contract where id = \''+input[0].contractId+'\' LIMIT 1';
            CreateHousingConfirmationClass.sendEmail(Database.query(qry));
        }
        return inputList;
    }

    public class FlowInput {
        @InvocableVariable 
        public Id contractId;
    }
}