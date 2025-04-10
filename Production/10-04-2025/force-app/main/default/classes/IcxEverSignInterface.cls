public without sharing class IcxEverSignInterface {

    public class EversignException extends Exception {}

    private static String API_URL = 'https://api.eversign.com/api';
    private static String API_ACCESSKEY = External_API_Key__c.getOrgDefaults().EVERSIGN_Access_Key__c;
    private static String API_BUSINESSID = External_API_Key__c.getOrgDefaults().EVERSIGN_Business_ID__c;
    
    
    public IcxEverSignInterface() {}
    public IcxEverSignInterface(ApexPages.StandardController std) {}
    
    public static string CreateDocument(String Payload) {
        String url = API_URL+'/document?access_key='+API_ACCESSKEY+'&business_id='+API_BUSINESSID;
        HttpResponse res;
        res = EverSignService.postRequestAPI(url, Payload);
        
        EverSignModels.hashEverSign hash = (EverSignModels.hashEverSign)JSON.deserialize(res.getBody(), EverSignModels.hashEverSign.class);
        
        if(hash.document_hash == null ) {
            throw new EversignException(res.getBody());
        }
        
        return hash.document_hash;
    }
    
    @RemoteAction
    public static String GetDocumentUrl(Id ContractId) {
        Contract con = [SELECT EverSign_Doc_Hash__c FROM Contract WHERE Id = :ContractId];
        String url = API_URL+'/document?access_key='+API_ACCESSKEY+'&business_id='+API_BUSINESSID+'&document_hash='+con.EverSign_Doc_Hash__c;
        HttpResponse res;
        res = EverSignService.getRequestAPI(url);
        
        
        String status = 'download_raw_document';
        EverSignModels.hashEverSign payload = (EverSignModels.hashEverSign)JSON.deserialize(res.getBody(), EverSignModels.hashEverSign.class);
        if (payload.is_completed == 1) status = 'download_final_document';
        
        if (payload.is_draft == 1) con.EverSign_Doc_Status__c = 'Draft';
        else if (payload.is_completed == 1) con.EverSign_Doc_Status__c = 'Completed';
        else if (payload.is_archived == 1) con.EverSign_Doc_Status__c = 'Archived';
        else if (payload.is_deleted == 1) con.EverSign_Doc_Status__c = 'Deleted';
        else if (payload.is_trashed == 1) con.EverSign_Doc_Status__c = 'Trashed';
        else if (payload.is_cancelled == 1) con.EverSign_Doc_Status__c = 'Cancelled';
        else con.EverSign_Doc_Status__c = 'In Process';
        update con;
        
        String retUrl = API_URL + '/'+status+'?access_key='+API_ACCESSKEY+'&business_id='+API_BUSINESSID+'&document_hash='+con.EverSign_Doc_Hash__c;
        return retUrl;
    }
    
    @RemoteAction
    public static Contract GetContract(Id ContractId) {
        return [SELECT EverSign_Doc_Status__c FROM Contract WHERE Id =: ContractId];
    }

    
    //GET DOC FOR SIGN
    public static String GetDocumentSign(String EverSign_Doc_Hash) {
        String url = API_URL+'/document?access_key='+API_ACCESSKEY+'&business_id='+API_BUSINESSID+'&document_hash='+EverSign_Doc_Hash;
        HttpResponse res = EverSignService.getRequestAPI(url);
        return res.getBody();
    }
    
}