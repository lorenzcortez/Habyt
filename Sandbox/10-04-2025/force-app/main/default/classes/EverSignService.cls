public with sharing class EverSignService {
    
    private	static Integer EVERSIGN_ISTEST = External_API_Key__c.getOrgDefaults().EVERSIGN_IsTest__c ? 1 :0;

    private static String API_URL = 'https://api.eversign.com/api';
    private static String API_ACCESSKEY = External_API_Key__c.getOrgDefaults().EVERSIGN_Access_Key__c;
    private static String API_BUSINESSID = External_API_Key__c.getOrgDefaults().EVERSIGN_Business_ID__c;

    public static HttpResponse getRequestAPI(String url) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setTimeout(10000);
        res = h.send(req);
        system.debug(url);
        system.debug(res.getBody());
        return res;
    }
    
    public static HttpResponse postRequestAPI(String url, String payLoad) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody(payLoad);
        req.setTimeout(100000);
        res = h.send(req);
        system.debug(url);
        system.debug(JSON.serialize(payload));
        system.debug(res.getBody());
        return res;
    }

    public static HttpResponse deleteRequestAPI(String url) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        req.setEndpoint(url);
        req.setMethod('DELETE');
        req.setTimeout(10000);
        res = h.send(req);
        
        return res;
    }

    //perform request

    public static string CreateDocument(String Payload) {
        String url = API_URL+'/document?access_key='+API_ACCESSKEY+'&business_id='+API_BUSINESSID;
        HttpResponse res;
        res = EverSignService.postRequestAPI(url, Payload);
        
        EverSignModels.hashEverSign hash = (EverSignModels.hashEverSign)JSON.deserialize(res.getBody(), EverSignModels.hashEverSign.class);
        
        if(hash.document_hash == null ) throw new AuraHandledException(res.getBody());
        
        return hash.document_hash;
    }
    
    public static EverSignModels.payloadEverSign getPayloadEverSign(String name, String email, Blob filePDF, String brand) {
        return getPayloadEverSign(name, email, filePDF, brand, 'Contract');
    }

    public static EverSignModels.payloadEverSign getPayloadEverSign(String name, String email, Blob filePDF, String brand, String contractName) {
        EverSignModels.payloadEverSign payload = new EverSignModels.payloadEverSign();
        payload.sandbox = EVERSIGN_ISTEST;
        payload.is_draft = 0;
        payload.embedded = 0;
        payload.title = name + ' ' + contractName;
        payload.message = contractName;
        payload.use_signer_order = 1;
        payload.reminders = 1;
        payload.require_all_signers = 1;
        payload.custom_requester_name = '';
        payload.custom_requester_email = '';
        payload.redirect = '';
        payload.redirect_decline = '';
        payload.client = '';
        payload.expires = Math.round(Datetime.now().addMonths(6).gettime() / 1000);
        payload.embedded_signing_enabled = 1;
        payload.flexible_signing = 0;
        payload.use_hidden_tags = 0;
        payload.files = new List<EverSignModels.fileEverSign>();
        
        EverSignModels.fileEverSign file = new EverSignModels.fileEverSign();
        file.name = contractName;
        file.file_id = '';
        file.file_url = '';
        file.file_base64 = EncodingUtil.base64Encode(filePDF);       
        payload.files.add(file);
        
        payload.signers = new List<EverSignModels.signersEverSign>();
        EverSignModels.signersEverSign signer = new EverSignModels.signersEverSign();
        signer.id = 1;
        signer.name  = name;
        signer.email  = email;
        signer.order = 1;
        signer.pin = 0;
        signer.message = 'Your ' + contractName;
        signer.deliver_email = '';
        signer.language = 'en';
        payload.signers.add(signer);
        
        payload.fields = new List<Object>();
        List<EverSignModels.fieldEverSign> listField = new List<EverSignModels.fieldEverSign>();
        
        EverSignModels.fieldEverSign fieldSignature = new EverSignModels.fieldEverSign();
        fieldSignature.type = 'signature';
        fieldSignature.x = '100';
        fieldSignature.y = brand == 'ErasmosRoom' ? '500' : '433';
        fieldSignature.width = '130';
        fieldSignature.height = '60';
        fieldSignature.page = '1';
        fieldSignature.signer = '1';
        fieldSignature.name = '';
        fieldSignature.identifier = 'unique_field_identifier_1';
        fieldSignature.required = 1;
        fieldSignature.readonly = 0;
        fieldSignature.validation_type = '';
        fieldSignature.text_size = '';
        fieldSignature.text_color = '';
        fieldSignature.text_font ='';
        fieldSignature.text_style = '';
        fieldSignature.value = '';
        listField.add(fieldSignature);        
        payload.fields.add(listField);
        return payload;
    }

    public static String cancelDocument(String documentHash) {
        if(documentHash == null) {
            return '';
        }

        String url = API_URL + '/document?access_key='  + API_ACCESSKEY + '&business_id=' + API_BUSINESSID + 
                     '&document_hash=' + documentHash + '&cancel=1';
        HttpResponse res = EverSignService.deleteRequestAPI(url);
        EverSignModels.CancelEverSign hashResponseWrapper = (EverSignModels.CancelEverSign) JSON.deserialize(res.getBody(), EverSignModels.CancelEverSign.class);
                
        if(hashResponseWrapper.error != null) {
            return String.valueOf(hashResponseWrapper.error);
        } else {
            return String.valueOf(hashResponseWrapper.success);
        }
    }
}