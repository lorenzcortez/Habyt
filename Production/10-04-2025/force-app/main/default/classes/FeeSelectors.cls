public class FeeSelectors {
    public virtual class Fees extends Paua_Selector {
        protected override String getBaseQuery() {
            return 'SELECT Id, Name, CurrencyIsoCode, JuncturePick__c, Description__c, Fee__c FROM Fee__c';
        }
    }
}