public class ApartmentSelectors {
    public virtual class ApartmentsWithProperty extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, Name, CurrencyIsoCode, Apartment_Number__c, FloorPick__c, Bedroom__c, Number_of_units__c, UnitSizePick__c, SizeNumber__c, Price__c, NetPrice__c, AvailableDateTrig__c, ' +
                'LastModifiedDate, EarliestStartOfContractAuto__c, LatestStartOfContractAuto__c, IsBookableAuto__c, Status__c, ' +

                // Property Fields
                'PropertyRef__c, PropertyRef__r.CurrencyIsoCode, PropertyRef__r.Street__c, PropertyRef__r.Postal_Code__c, PropertyRef__r.NeighbourhoodRef__c, ' + //PropertyRef__r.StreetNumber__c, 
                'PropertyRef__r.NeighbourhoodRef__r.Name, PropertyRef__r.City__c, PropertyRef__r.Country__c, ' + 
                'PropertyRef__r.BrandRef__r.Name, PropertyRef__r.BrandRef__r.APINameBrand__c, ' +
                'PropertyRef__r.PropertyLocation__latitude__s, PropertyRef__r.PropertyLocation__longitude__s, ' + 

                // Property Condition
                'PropertyRef__r.ConditionRef__c, PropertyRef__r.ConditionRef__r.Name, PropertyRef__r.ConditionRef__r.CurrencyIsoCode, PropertyRef__r.ConditionRef__r.ContractDurationTypePick__c, '+
                'PropertyRef__r.ConditionRef__r.MaximumStayNumber__c, PropertyRef__r.ConditionRef__r.MaximumStayUnitPick__c, ' +
                'PropertyRef__r.ConditionRef__r.MinimumStayNumber__c, PropertyRef__r.ConditionRef__r.MinimumStayUnitPick__c, ' +
                'PropertyRef__r.ConditionRef__r.NoticePeriodNumber__c, PropertyRef__r.ConditionRef__r.NoticePeriodTypePick__c, ' +
                'PropertyRef__r.ConditionRef__r.NoticePeriodUnitPick__c, PropertyRef__r.ConditionRef__r.DepositMultiplier__c, ' +
                'PropertyRef__r.ConditionRef__r.MembershipFee__c, ' +

                // Property Billing Entity
                'PropertyRef__r.Billing_Entity__c, PropertyRef__r.Billing_Entity__r.Name, PropertyRef__r.Billing_Entity__r.CurrencyIsoCode, PropertyRef__r.Billing_Entity__r.ConditionRef__c, ' + 

                // Property Billing Entity Condition
                'PropertyRef__r.Billing_Entity__r.ConditionRef__r.Name, PropertyRef__r.Billing_Entity__r.ConditionRef__r.CurrencyIsoCode, PropertyRef__r.Billing_Entity__r.ConditionRef__r.ContractDurationTypePick__c, ' +
                'PropertyRef__r.Billing_Entity__r.ConditionRef__r.MaximumStayNumber__c, PropertyRef__r.Billing_Entity__r.ConditionRef__r.MaximumStayUnitPick__c, ' +
                'PropertyRef__r.Billing_Entity__r.ConditionRef__r.MinimumStayNumber__c, PropertyRef__r.Billing_Entity__r.ConditionRef__r.MinimumStayUnitPick__c, ' +
                'PropertyRef__r.Billing_Entity__r.ConditionRef__r.NoticePeriodNumber__c, PropertyRef__r.Billing_Entity__r.ConditionRef__r.NoticePeriodTypePick__c, ' +
                'PropertyRef__r.Billing_Entity__r.ConditionRef__r.NoticePeriodUnitPick__c, PropertyRef__r.Billing_Entity__r.ConditionRef__r.DepositMultiplier__c, ' +
                'PropertyRef__r.Billing_Entity__r.ConditionRef__r.MembershipFee__c, ' +

                // Child rooms
                '(SELECT Id FROM Rooms__r) ' +
            'FROM Apartment__c';
        }
    }
}