public without sharing class IcxCommunityInterface {
    
    @AuraEnabled
    public	static String retrievedContract(String signature, Id contractId) {
        System.debug('+++ signature: ' + signature);
        System.debug('+++ contractId: ' + contractId);
        Contract con = [
            SELECT Id, Community_Step__c, AccountId, Opportunity__c,StartDate,
                EverSign_Doc_Status__c, EverSign_Doc_Hash__c,
                Stripe_Account__c, Stripe_Subscription_Id__c, STRIPE_Plan_Id__c,
                Room__r.Property__r.BrandRef__r.APINameBrand__c, ApartmentRef__r.PropertyRef__r.BrandRef__r.APINameBrand__c
            FROM Contract 
            WHERE Id = :contractId
        ];

        if(con == null) throw new AuraHandledException('Contract Not Found');
        if(con.EverSign_Doc_Status__c == 'Cancelled') throw new AuraHandledException('This contract has been declined');
        if(con.EverSign_Doc_Status__c == 'Voided') throw new AuraHandledException('Your contract is not active anymore, get in touch with us to get a new one!');

        // if (con.Stripe_Account__c == null || String.isBlank(con.STRIPE_Plan_Id__c) || con.StartDate == null) {

        if (con.Stripe_Account__c == null || con.StartDate == null) {
            String domain = 'habyt.com';
            String brand = con.Room__r != null ? con.Room__r.Property__r.BrandRef__r.APINameBrand__c : 
                con.ApartmentRef__r.PropertyRef__r.BrandRef__r.APINameBrand__c;
            
            if (brand == 'Quarters') {
                domain = 'quarters.com';
            } else if (brand == 'MediciLiving') {
                domain = 'medici-living.com';
            } else if (brand == 'ErasmosRoom') {
                domain = 'erasmosroom.com';
            }
            
            String msg = 'We\'re sorry but there seems to be some issue with your contract details. ' + 
                'Please reach out to bookings@' + domain + ' in order to clarify it.';
            
                throw new AuraHandledException(msg);
        }
        
        System.debug('+++ signature: ' + signature);
        String expected = generateHmacSHA256Signature(contractId  + '.' + con.EverSign_Doc_Hash__c, 'HMACKEY');
        System.debug('+++ expected: ' + expected);
        
        if (expected == signature) return JSON.serialize(con);
        else throw new AuraHandledException('Invalid URL');
    }
    
    private static String generateHmacSHA256Signature(String saltValue, String secretKeyValue) {
        System.debug('+++ saltValue: ' + saltValue);
        String algorithmName = 'HmacSHA256';
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(saltValue), Blob.valueOf(secretKeyValue));
        return EncodingUtil.convertToHex(hmacData);
    }
    
    @AuraEnabled
    public static String getEversignDocument(String EverSign_Doc_Hash) {
        return IcxEverSignInterface.GetDocumentSign(EverSign_Doc_Hash);
    }
    
    @AuraEnabled
    public static void updateContract(String data) {
        update (Contract) JSON.deserialize(data, Contract.class);
    }
}