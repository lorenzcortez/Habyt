public with sharing class PhoneMetadataSelectors {
    public virtual class AllPhoneCodes extends Paua_Selector {
        protected override String getBaseQuery() {
            return 'SELECT Id, DeveloperName, MasterLabel, Phone_Code__c FROM Phone_Country_Code__mdt';
        }
    }
}