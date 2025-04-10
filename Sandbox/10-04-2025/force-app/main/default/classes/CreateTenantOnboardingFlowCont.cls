public with sharing class CreateTenantOnboardingFlowCont {
    @AuraEnabled
    public static Response getOnboardingStepsRecord(String recordId){
        Response responseBody = new Response();
        responseBody.isSuccess = false;

        List<Contract> contractList = [SELECT Id, ContractNumber, Opportunity__c, Property__c, Property__r.TOF_Variant__c FROM Contract WHERE Id =: recordId];
        if(!contractList.isEmpty()){
            Contract cont = contractList[0];
            responseBody.contractId = cont.Id;
           
          
            responseBody.contractNumber = cont.ContractNumber;
            if(cont.Opportunity__c != null){
                responseBody.oppId = cont.Opportunity__c;
                List<Contract> getContract = [SELECT Id, ContractNumber FROM Contract WHERE Opportunity__c =: cont.Opportunity__c AND RecordType.Name = 'Membership Fee' ORDER BY CreatedDate DESC LIMIT 1];
                if(!getContract.isEmpty()){
                    responseBody.memberContractId = getContract[0].Id;
                    responseBody.memberContractNumber = getContract[0].ContractNumber;
                }
            }
            if(cont.Property__c != null){
                String variant = cont.Property__r.TOF_Variant__c;
                responseBody.flowVariant = variant;

                StripeInvoiceSetting__c stripeSetting = StripeInvoiceSetting__c.getInstance();
                String username = stripeSetting.Username__c;
                String password = stripeSetting.Password__c;
                Blob headerValue = Blob.valueOf(username + ':' + password);
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                // String url = 'https://habyt-7qppmqqjf-habyt.vercel.app/api/v3/admin/tof/' + variant;
                // String url = 'https://habyt-web-git-rob-csf-v2-habyt.vercel.app/api/v3/admin/tof/' + variant;

                Http h = new Http();
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();

                Organization a_ORG = [Select Id, Name, IsSandbox from Organization];
                if(a_ORG.IsSandbox){
                    // req.setEndpoint('https://habyt-web-git-rob-csf-v2-habyt.vercel.app/api/v3/admin/tof/' + variant);
                    req.setEndpoint('https://staging.habyt.com/api/v3/admin/tof/' + variant);
                } else {
                    req.setEndpoint('https://www.habyt.com/api/v3/admin/tof/' + variant);
                }

                req.setMethod('GET');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', authorizationHeader);
                // req.setTimeout(100000);
                res = h.send(req);
    
                System.debug('getOnboardingStepsRecord New Endpoint'+ req.getEndpoint());
                System.debug('getOnboardingStepsRecord New Endpoint'+ res.getStatusCode());
                System.debug('getOnboardingStepsRecord New Endpoint' + res.getBody());
    
                if(res.getStatusCode() == 200){
                    responseBody.isSuccess = true;
                    TenantOnboardingWrapper getData = (TenantOnboardingWrapper) JSON.deserialize(res.getBody(), TenantOnboardingWrapper.class);
                    if(getData.statusCode == 200){
                        Map<Integer, Boolean> mapRowToValue = new Map<Integer, Boolean>();
                        List<StepsWrapper> stepsData = new List<StepsWrapper>();

                        if(getData.data != null){
                            if(getData.data.stepsIncluded != null){
                                List<Boolean> stepsInclude = getData.data.stepsIncluded;
                                Integer i = 1;
                                for(Boolean val : stepsInclude){
                                    if(!mapRowToValue.containsKey(i)){
                                        mapRowToValue.put(i, val);
                                    }
                                    i++;
                                }
                            }

                            system.debug('mapRowToValue ' + mapRowToValue );
    
                            if(getData.data.steps != null){
                                List<String> steps = getData.data.steps;
                                Integer i = 1;
                                for(String step : steps){
                                    StepsWrapper stepData = new StepsWrapper();
                                    stepData.row = i;
                                    stepData.fieldName = fieldLabelMap.containsKey(step) ? fieldLabelMap.get(step): step;
                                    stepData.apiName = step;
                                    stepData.value = mapRowToValue.containsKey(i) ? mapRowToValue.get(i) : false;
                                    system.debug('mapRowToValue ' + mapRowToValue.get(i) );
                                    stepsData.add(stepData);
                                    i++;
                                }
                            }
                        }

                        responseBody.stepsData = stepsData;
                    } else {
                        responseBody.isSuccess = false;
                    }
                } else {
                    responseBody.isSuccess = false;
                }
            }
        }

        return responseBody;
    }

    @AuraEnabled
    public static TenantOnboardingResWrapper createTenantOnboardingRecords(String jsonBody){
        TenantOnboardingResWrapper newResWrap = new TenantOnboardingResWrapper();
        try {
            System.debug('### JSONBODY ' + jsonBody);
            Response resData = (Response) JSON.deserialize(jsonBody, Response.class);
            System.debug('### resData ' + resData);

            TenantOnboardingReqWrapper newReqWrap = new TenantOnboardingReqWrapper();
            newReqWrap.rentContractId = resData.contractId;
            newReqWrap.membershipContractId = resData.memberContractId;

            List<Boolean> stepsData = new List<Boolean>();
            if(resData.stepsData != null){
                for(StepsWrapper step : resData.stepsData){
                    System.debug('### fieldName ' + step.fieldName);
                    System.debug('### value ' + step.value);
                    stepsData.add(step.value);
                }
            }

            newReqWrap.stepsIncluded = stepsData;

            System.debug('### stepsData ' + JSON.serialize(newReqWrap));

            StripeInvoiceSetting__c stripeSetting = StripeInvoiceSetting__c.getInstance();
            String username = stripeSetting.Username__c;
            String password = stripeSetting.Password__c;
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            // String url = 'https://habyt-7qppmqqjf-habyt.vercel.app/api/v3/admin/tof/' + resData.flowVariant;
            // String url = 'https://habyt-web-git-rob-csf-v2-habyt.vercel.app/api/v3/admin/tof/' + resData.flowVariant;
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Organization a_ORG = [Select Id, Name, IsSandbox from Organization];
            if(a_ORG.IsSandbox){
                // req.setEndpoint('https://habyt-web-git-rob-csf-v2-habyt.vercel.app/api/v3/admin/tof/' + resData.flowVariant);
                req.setEndpoint('https://staging.habyt.com/api/v3/admin/tof/' + resData.flowVariant);
            } else {
                req.setEndpoint('https://www.habyt.com/api/v3/admin/tof/' + resData.flowVariant);
            }
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', authorizationHeader);
            req.setBody(JSON.serialize(newReqWrap));
            req.setTimeout(100000);
            res = h.send(req);

            System.debug('createTenantOnboardingRecords New Endpoint'+ res.getStatusCode());
            System.debug('createTenantOnboardingRecords New Endpoint' + res.getBody());

            if(res.getStatusCode() == 200){
                newResWrap.isSuccess = true;
            }else{
                newResWrap.isSuccess = false;
            }

            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if (responseMap.containsKey('message')) {
                newResWrap.message = (String) responseMap.get('message');
            } else {
                newResWrap.message = 'Unknown error occurred';
            }

            // List<Tenant_Onboarding_Step__c> tenantStepList = new List<Tenant_Onboarding_Step__c>();

            // Tenant_Onboarding_Flow__c tenant = new Tenant_Onboarding_Flow__c(
            //     Rent_Contract__c = resData.contractId,
            //     Opportunity__c = resData.oppId,
            //     TOF_Variant__c = resData.flowVariant
            // );
            // insert tenant;

            // if(resData.stepsData != null){
            //     for(StepsWrapper step : resData.stepsData){
            //         if(step.value == false){
            //             Tenant_Onboarding_Step__c tenantStep = new Tenant_Onboarding_Step__c(
            //                 Tenant_Onboarding_Flow__c = tenant.Id,
            //                 Step_Name__c = step.apiName
            //             );
            //             tenantStepList.add(tenantStep);
            //         }
            //     }
            // }

            // if(!tenantStepList.isEmpty()){
            //     insert tenantStepList;
            // }

            return newResWrap;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + ' ' + e.getLineNumber());
            newResWrap.isSuccess = false;
            newResWrap.message = 'Error: ' + e.getMessage() + ' ' + e.getLineNumber();
            return newResWrap;
        }
    }

    @AuraEnabled
    public static List<PicklistWrapp> getPicklistValues(String sObjectAPI, String fieldAPI){
        List<PicklistWrapp> plValues = new List<PicklistWrapp>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectAPI);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get(fieldAPI).getDescribe();
        List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
        for(Schema.PicklistEntry plv: picklistvalues) {
            PicklistWrapp wrapp = new PicklistWrapp();
            wrapp.label = plv.getLabel();
            wrapp.value = plv.getValue();
            plValues.add(wrapp);
        }
        return plValues;
    }

    public class PicklistWrapp{
        @AuraEnabled 
        public String label;
        @AuraEnabled 
        public String value;
    }

    public class FieldLabelWrapper{
        @AuraEnabled
        public Integer index;
        @AuraEnabled 
        public String label;
        @AuraEnabled 
        public String apiName;
    }

    public class Response {
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String contractId;
        @AuraEnabled
        public String contractNumber;
        @AuraEnabled
        public String memberContractId;
        @AuraEnabled
        public String memberContractNumber;
        @AuraEnabled
        public String oppId;
        @AuraEnabled
        public String flowVariant;
        @AuraEnabled
        public List<StepsWrapper> stepsData;
    }

    public class StepsWrapper{
        @AuraEnabled
        public Integer row;
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String apiName;
        @AuraEnabled
        public Boolean value;
    }

    public class TenantOnboardingWrapper {
        @AuraEnabled
        public Integer statusCode;
        @AuraEnabled
        public DataWrapper data;
        @AuraEnabled
        public String message;
    }

    public class DataWrapper{
        @AuraEnabled
        public List<String> steps;
        @AuraEnabled
        public List<Boolean> stepsIncluded;
    }

    public class TenantOnboardingReqWrapper {
        public String rentContractId;
        public String membershipContractId;
        public List<Boolean> stepsIncluded;
    }

    public class TenantOnboardingResWrapper {
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String message;
    }


    public static Map<String, String> fieldLabelMap = new Map<String, String>{
        'tenantDetails' => 'Tenant Details',
        'membershipAgreement' => 'Membership Agreement',
        'itRentAgreement' => 'Rent Agreement',
        'deRentAgreement' => 'Rent Agreement',
        'ptRentAgreement' => 'Rent Agreement',
        'esMaRentAgreement' => 'Rent Agreement',
        'esMlRentAgreement' => 'Rent Agreement',
        'esVallecasRentAgreement' => 'Rent Agreement',
        'frMaRentAgreement' => 'Rent Agreement',
        'frMlRentAgreement' => 'Rent Agreement',
        'beRentAgreement' => 'Rent Agreement',
        'atRentAgreement' => 'Rent Agreement',
        'membershipPayment' => 'Membership Payment',
        'depositPayment' => 'Deposit Payment',
        'itRegulationAgreement' => 'Regulation Agreement',
        'itBookingAgreement' => 'Booking Agreement',
        'nlAddendumAgreement' => 'Addendum Agreement',
        'nlColivingAgreement' => 'Living Agreement',
        'nlLeaseAgreement' => 'Lease Agreement'
    };
        Map<String, String> stepsFields = new Map<String, String>();
}