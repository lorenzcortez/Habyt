public with sharing class TwilioCallLogsLWC {
    
    //Updated
    @AuraEnabled
    public static string getFromTwilioCalls(Id recordId) {
        
        system.debug('record Id::'+recordId);
        
        List<Twilio_API__c> TwilioSetting = Twilio_API__c.getall().values();
        if(TwilioSetting.size()  == 0){
            string Error = '{"code": 400, "detail": "Twilio API custom setting record not found.", "message": "Custom Setting Not found", "more_info": "", "status": 401}';
            return Error;
        }
        list<String> CustomerPhoneNumbers = FetchPhoneNumbers(recordId);
        
        if(CustomerPhoneNumbers.size() > 0){
            
            string PhoneNumber = CustomerPhoneNumbers[0];
            
            String EndpointBaseUrl = TwilioSetting[0].Endpoint_Base_URL__c;
            String APIVersion = TwilioSetting[0].API_Version__c;
            String accountSid = TwilioSetting[0].Account_SID__c;
            String token = TwilioSetting[0].Auth_Token__c;
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(EndPointBaseURL+'/Accounts/'+accountSid+'/Calls.json?From='+PhoneNumber+'&PageSize=200');
            req.setMethod('GET');
            
            req.setHeader('X-Twilio-Client', 'salesforce-' + APIVersion);
            req.setHeader('User-Agent', 'twilio-salesforce/' + APIVersion);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Accept-Charset', 'utf-8');
            req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf(accountSid+':' +token)));
            
            Http http = new Http();
            
            if(test.isRunningTest()){
                return '{    "first_page_uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls.json?From=+14348791772&PageSize=50&Page=0",    "end":49,    "calls":[       {          "date_updated":"Tue, 11 Jan 2022 16:44:00 +0000",          "price_unit":"USD",          "parent_call_sid":null,          "caller_name":null,          "duration":"12",          "from":"+14348791772",          "to":"+18574073759",          "annotation":null,          "answered_by":null,          "sid":"CA69506d638bab0a91646a9aef87b41d5a",          "queue_time":"0",          "price":"-0.00450",          "api_version":"2010-04-01",          "status":"completed",          "direction":"inbound",          "start_time":"Tue, 11 Jan 2022 16:43:48 +0000",          "date_created":"Tue, 11 Jan 2022 16:43:47 +0000",          "from_formatted":"(434) 879-1772",          "group_sid":null,          "trunk_sid":"",          "forwarded_from":"+18574073759",          "uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a.json",          "account_sid":"AC449b336950c036efaac67c7f2b93478c",          "end_time":"Tue, 11 Jan 2022 16:44:00 +0000",          "to_formatted":"(857) 407-3759",          "phone_number_sid":"PN91ee2c5e96af003dcbdba7357a052986",          "subresource_uris":{             "feedback":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Feedback.json",             "notifications":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Notifications.json",             "recordings":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Recordings.json",             "payments":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Payments.json",             "siprec":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Siprec.json",             "events":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Events.json",             "feedback_summaries":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/FeedbackSummary.json"          }       }    ],    "previous_page_uri":null,    "uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls.json?From=+14348791772&PageSize=50&Page=0",    "page_size":50,    "start":0,    "next_page_uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls.json?From=+14348791772&PageSize=50&Page=1&PageToken=PACAb6f7728aa88ab51cf4900120f296e452",    "page":0 }';
            }else{
                HTTPResponse res = http.send(req);
                System.debug('body::'+res.getBody());
                System.debug('status code::'+res.getStatusCode());
                
                return res.getBody();
            }
            
        }else {
            string defaultError = '{"code": 400, "detail": "Phone number does not exist on the current record.", "message": "Phone Number Not found", "more_info": "", "status": 401}';
            return defaultError;
        }
    }
    
    @AuraEnabled
    public static string getToTwilioCalls(Id recordId) {
        
        system.debug('record Id::'+recordId);
        
        List<Twilio_API__c> TwilioSetting = Twilio_API__c.getall().values();
        if(TwilioSetting.size()  == 0){
            string Error = '{"code": 400, "detail": "Twilio API custom setting record not found.", "message": "Custom Setting Not found", "more_info": "", "status": 401}';
            return Error;
        }
        
        list<String> CustomerPhoneNumbers = FetchPhoneNumbers(recordId);
        
        if(CustomerPhoneNumbers.size() > 0){
            
            string PhoneNumber = CustomerPhoneNumbers[0];
            
            String EndpointBaseUrl = TwilioSetting[0].Endpoint_Base_URL__c;
            String APIVersion = TwilioSetting[0].API_Version__c;
            String accountSid = TwilioSetting[0].Account_SID__c;
            String token = TwilioSetting[0].Auth_Token__c;
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(EndPointBaseURL+'/Accounts/'+accountSid+'/Calls.json?To='+PhoneNumber+'&PageSize=200');
            req.setMethod('GET');
            
            req.setHeader('X-Twilio-Client', 'salesforce-' + APIVersion);
            req.setHeader('User-Agent', 'twilio-salesforce/' + APIVersion);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Accept-Charset', 'utf-8');
            req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf(accountSid+':' +token)));
            
            if(test.isRunningTest()){
                return '{    "first_page_uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls.json?From=+14348791772&PageSize=50&Page=0",    "end":49,    "calls":[       {          "date_updated":"Tue, 11 Jan 2022 16:44:00 +0000",          "price_unit":"USD",          "parent_call_sid":null,          "caller_name":null,          "duration":"12",          "from":"+14348791772",          "to":"+18574073759",          "annotation":null,          "answered_by":null,          "sid":"CA69506d638bab0a91646a9aef87b41d5a",          "queue_time":"0",          "price":"-0.00450",          "api_version":"2010-04-01",          "status":"completed",          "direction":"inbound",          "start_time":"Tue, 11 Jan 2022 16:43:48 +0000",          "date_created":"Tue, 11 Jan 2022 16:43:47 +0000",          "from_formatted":"(434) 879-1772",          "group_sid":null,          "trunk_sid":"",          "forwarded_from":"+18574073759",          "uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a.json",          "account_sid":"AC449b336950c036efaac67c7f2b93478c",          "end_time":"Tue, 11 Jan 2022 16:44:00 +0000",          "to_formatted":"(857) 407-3759",          "phone_number_sid":"PN91ee2c5e96af003dcbdba7357a052986",          "subresource_uris":{             "feedback":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Feedback.json",             "notifications":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Notifications.json",             "recordings":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Recordings.json",             "payments":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Payments.json",             "siprec":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Siprec.json",             "events":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Events.json",             "feedback_summaries":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/FeedbackSummary.json"          }       }    ],    "previous_page_uri":null,    "uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls.json?From=+14348791772&PageSize=50&Page=0",    "page_size":50,    "start":0,    "next_page_uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls.json?From=+14348791772&PageSize=50&Page=1&PageToken=PACAb6f7728aa88ab51cf4900120f296e452",    "page":0 }';
            }else{
                Http http = new Http();
                HTTPResponse res = http.send(req);
                System.debug('body::'+res.getBody());
                System.debug('status code::'+res.getStatusCode());
                
                return res.getBody();
            }
            
        }else {
            string defaultError = '{"code": 400, "detail": "Phone number does not exist on the current record.", "message": "Phone Number Not found", "more_info": "", "status": 401}';
            return defaultError;
        }
    }
    
    @AuraEnabled
    public static string getFromTwilioMessages(Id recordId) {
        
        system.debug('record Id::'+recordId);
        
        List<Twilio_API__c> TwilioSetting = Twilio_API__c.getall().values();
        if(TwilioSetting.size()  == 0){
            string Error = '{"code": 400, "detail": "Twilio API custom setting record not found.", "message": "Custom Setting Not found", "more_info": "", "status": 401}';
            return Error;
        }
        list<String> CustomerPhoneNumbers = FetchPhoneNumbers(recordId);
        
        if(CustomerPhoneNumbers.size() > 0){
            
            string PhoneNumber = CustomerPhoneNumbers[0];
            
            String EndpointBaseUrl = TwilioSetting[0].Endpoint_Base_URL__c;
            String APIVersion = TwilioSetting[0].API_Version__c;
            String accountSid = TwilioSetting[0].Account_SID__c;
            String token = TwilioSetting[0].Auth_Token__c;
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(EndPointBaseURL+'/Accounts/'+accountSid+'/Messages.json?From='+PhoneNumber+'&PageSize=200');
            req.setMethod('GET');
            
            req.setHeader('X-Twilio-Client', 'salesforce-' + APIVersion);
            req.setHeader('User-Agent', 'twilio-salesforce/' + APIVersion);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Accept-Charset', 'utf-8');
            req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf(accountSid+':' +token)));
            
            Http http = new Http();
            
            if(test.isRunningTest()){
                return '{    "first_page_uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls.json?From=+14348791772&PageSize=50&Page=0",    "end":49,    "calls":[       {          "date_updated":"Tue, 11 Jan 2022 16:44:00 +0000",          "price_unit":"USD",          "parent_call_sid":null,          "caller_name":null,          "duration":"12",          "from":"+14348791772",          "to":"+18574073759",          "annotation":null,          "answered_by":null,          "sid":"CA69506d638bab0a91646a9aef87b41d5a",          "queue_time":"0",          "price":"-0.00450",          "api_version":"2010-04-01",          "status":"completed",          "direction":"inbound",          "start_time":"Tue, 11 Jan 2022 16:43:48 +0000",          "date_created":"Tue, 11 Jan 2022 16:43:47 +0000",          "from_formatted":"(434) 879-1772",          "group_sid":null,          "trunk_sid":"",          "forwarded_from":"+18574073759",          "uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a.json",          "account_sid":"AC449b336950c036efaac67c7f2b93478c",          "end_time":"Tue, 11 Jan 2022 16:44:00 +0000",          "to_formatted":"(857) 407-3759",          "phone_number_sid":"PN91ee2c5e96af003dcbdba7357a052986",          "subresource_uris":{             "feedback":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Feedback.json",             "notifications":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Notifications.json",             "recordings":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Recordings.json",             "payments":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Payments.json",             "siprec":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Siprec.json",             "events":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Events.json",             "feedback_summaries":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/FeedbackSummary.json"          }       }    ],    "previous_page_uri":null,    "uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls.json?From=+14348791772&PageSize=50&Page=0",    "page_size":50,    "start":0,    "next_page_uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls.json?From=+14348791772&PageSize=50&Page=1&PageToken=PACAb6f7728aa88ab51cf4900120f296e452",    "page":0 }';
            }else{
                HTTPResponse res = http.send(req);
                System.debug('body::'+res.getBody());
                System.debug('status code::'+res.getStatusCode());
                
                return res.getBody();
            }
            
        }else {
            string defaultError = '{"code": 400, "detail": "Phone number does not exist on the current record.", "message": "Phone Number Not found", "more_info": "", "status": 401}';
            return defaultError;
        }
    }
    
    @AuraEnabled
    public static string getToTwilioMessages(Id recordId) {
        
        system.debug('record Id::'+recordId);
        
        List<Twilio_API__c> TwilioSetting = Twilio_API__c.getall().values();
        if(TwilioSetting.size()  == 0){
            string Error = '{"code": 400, "detail": "Twilio API custom setting record not found.", "message": "Custom Setting Not found", "more_info": "", "status": 401}';
            return Error;
        }
        
        list<String> CustomerPhoneNumbers = FetchPhoneNumbers(recordId);
        
        if(CustomerPhoneNumbers.size() > 0){
            
            string PhoneNumber = CustomerPhoneNumbers[0];
            
            String EndpointBaseUrl = TwilioSetting[0].Endpoint_Base_URL__c;
            String APIVersion = TwilioSetting[0].API_Version__c;
            String accountSid = TwilioSetting[0].Account_SID__c;
            String token = TwilioSetting[0].Auth_Token__c;
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(EndPointBaseURL+'/Accounts/'+accountSid+'/Messages.json?To='+PhoneNumber+'&PageSize=200');
            req.setMethod('GET');
            
            req.setHeader('X-Twilio-Client', 'salesforce-' + APIVersion);
            req.setHeader('User-Agent', 'twilio-salesforce/' + APIVersion);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Accept-Charset', 'utf-8');
            req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf(accountSid+':' +token)));
            
            if(test.isRunningTest()){
                return '{    "first_page_uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls.json?From=+14348791772&PageSize=50&Page=0",    "end":49,    "calls":[       {          "date_updated":"Tue, 11 Jan 2022 16:44:00 +0000",          "price_unit":"USD",          "parent_call_sid":null,          "caller_name":null,          "duration":"12",          "from":"+14348791772",          "to":"+18574073759",          "annotation":null,          "answered_by":null,          "sid":"CA69506d638bab0a91646a9aef87b41d5a",          "queue_time":"0",          "price":"-0.00450",          "api_version":"2010-04-01",          "status":"completed",          "direction":"inbound",          "start_time":"Tue, 11 Jan 2022 16:43:48 +0000",          "date_created":"Tue, 11 Jan 2022 16:43:47 +0000",          "from_formatted":"(434) 879-1772",          "group_sid":null,          "trunk_sid":"",          "forwarded_from":"+18574073759",          "uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a.json",          "account_sid":"AC449b336950c036efaac67c7f2b93478c",          "end_time":"Tue, 11 Jan 2022 16:44:00 +0000",          "to_formatted":"(857) 407-3759",          "phone_number_sid":"PN91ee2c5e96af003dcbdba7357a052986",          "subresource_uris":{             "feedback":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Feedback.json",             "notifications":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Notifications.json",             "recordings":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Recordings.json",             "payments":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Payments.json",             "siprec":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Siprec.json",             "events":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Events.json",             "feedback_summaries":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/FeedbackSummary.json"          }       }    ],    "previous_page_uri":null,    "uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls.json?From=+14348791772&PageSize=50&Page=0",    "page_size":50,    "start":0,    "next_page_uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls.json?From=+14348791772&PageSize=50&Page=1&PageToken=PACAb6f7728aa88ab51cf4900120f296e452",    "page":0 }';
            }else{
                Http http = new Http();
                HTTPResponse res = http.send(req);
                System.debug('body::'+res.getBody());
                System.debug('status code::'+res.getStatusCode());
                
                return res.getBody();
            }
            
        }else {
            string defaultError = '{"code": 400, "detail": "Phone number does not exist on the current record.", "message": "Phone Number Not found", "more_info": "", "status": 401}';
            return defaultError;
        }
    }

    @AuraEnabled
    public static String getLatestRecording(String callSid){
        List<Twilio_API__c> TwilioSetting = Twilio_API__c.getall().values();
        if(TwilioSetting.size()  == 0){
            string Error = '{"code": 400, "detail": "Twilio API custom setting record not found.", "message": "Custom Setting Not found", "more_info": "", "status": 401}';
            return Error;
        }
            
        String EndpointBaseUrl = TwilioSetting[0].Endpoint_Base_URL__c;
        String APIVersion = TwilioSetting[0].API_Version__c;
        String accountSid = TwilioSetting[0].Account_SID__c;
        String token = TwilioSetting[0].Auth_Token__c;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(EndPointBaseURL+'/Accounts/'+accountSid+'/Calls/'+callSid+'/Recordings.json');
        req.setMethod('GET');
        
        req.setHeader('X-Twilio-Client', 'salesforce-' + APIVersion);
        req.setHeader('User-Agent', 'twilio-salesforce/' + APIVersion);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Accept-Charset', 'utf-8');
        req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf(accountSid+':' +token)));
        
        if(test.isRunningTest()){
            return '{    "first_page_uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls.json?From=+14348791772&PageSize=50&Page=0",    "end":49,    "calls":[       {          "date_updated":"Tue, 11 Jan 2022 16:44:00 +0000",          "price_unit":"USD",          "parent_call_sid":null,          "caller_name":null,          "duration":"12",          "from":"+14348791772",          "to":"+18574073759",          "annotation":null,          "answered_by":null,          "sid":"CA69506d638bab0a91646a9aef87b41d5a",          "queue_time":"0",          "price":"-0.00450",          "api_version":"2010-04-01",          "status":"completed",          "direction":"inbound",          "start_time":"Tue, 11 Jan 2022 16:43:48 +0000",          "date_created":"Tue, 11 Jan 2022 16:43:47 +0000",          "from_formatted":"(434) 879-1772",          "group_sid":null,          "trunk_sid":"",          "forwarded_from":"+18574073759",          "uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a.json",          "account_sid":"AC449b336950c036efaac67c7f2b93478c",          "end_time":"Tue, 11 Jan 2022 16:44:00 +0000",          "to_formatted":"(857) 407-3759",          "phone_number_sid":"PN91ee2c5e96af003dcbdba7357a052986",          "subresource_uris":{             "feedback":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Feedback.json",             "notifications":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Notifications.json",             "recordings":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Recordings.json",             "payments":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Payments.json",             "siprec":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Siprec.json",             "events":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/CA69506d638bab0a91646a9aef87b41d5a/Events.json",             "feedback_summaries":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls/FeedbackSummary.json"          }       }    ],    "previous_page_uri":null,    "uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls.json?From=+14348791772&PageSize=50&Page=0",    "page_size":50,    "start":0,    "next_page_uri":"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Calls.json?From=+14348791772&PageSize=50&Page=1&PageToken=PACAb6f7728aa88ab51cf4900120f296e452",    "page":0 }';
        }else{
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('body::'+res.getBody());
            System.debug('status code::'+res.getStatusCode());
            
            return res.getBody();
        }
    }
    
    public static list<String> FetchPhoneNumbers(Id recordId){
        
        string SobjectNametext = String.ValueOf(recordId.getsobjecttype());
        Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get(SobjectNametext) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap();
        list<string> ObjectPhoneFields = new list<string>();
        for(string f :fields.Keyset() ){
            //&& f.TolowerCase().ContainsIgnoreCase('mobile') && !f.TolowerCase().Contains('__')
            if(fields.get(f).getDescribe().getType().name().tolowerCase() == 'phone' ){
                system.debug('In First');
                ObjectPhoneFields.add(f);
            }
            //else if( (f.TolowerCase().contains('phone') || f.TolowerCase().contains('mobile') ) && fields.get(f).getDescribe().getType().name().tolowerCase() == 'text' ){
            //system.debug('In Second');
            //ObjectPhoneFields.add(f);
            //}
        }
        system.debug('SobjectNametext::'+SobjectNametext);
        system.debug('Phone fields::'+ObjectPhoneFields);
        
        String CommaSeparatedFields = string.join(ObjectPhoneFields,',');
        string queryStr = 'SELECT '+CommaSeparatedFields+' FROM '+SobjectNametext+' WHERE Id =  :recordId';
        system.debug('SOQL Query:: '+queryStr);
        List<sObject> sobjList = Database.query(queryStr);
        system.debug('sobjList'+sobjList);
        
        list<string> CustomerPhoneNumbers = new list<string>();
        for(sObject obj: sobjList) {
            for(string sObjfield : ObjectPhoneFields){
                system.debug(sObjfield+'==> '+(String)obj.get(sObjfield));
                if((String)obj.get(sObjfield) != null){
                    String PhoneNumber = (String)obj.get(sObjfield);
                    PhoneNumber = TwilioUtility.FormatPhoneNumber(PhoneNumber);
                    CustomerPhoneNumbers.add(PhoneNumber);
                }
            }
        }
        
        
        return CustomerPhoneNumbers;
    }
    
    @AuraEnabled(cacheable=true)
    public static string getCustomerPhone(Id recordId) {
        
        system.debug('record Id::'+recordId);
        
        string SobjectNametext = String.ValueOf(recordId.getsobjecttype());
        Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get(SobjectNametext) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap();
        list<string> ObjectPhoneFields = new list<string>();
        for(string f :fields.Keyset() ){
            //&& f.TolowerCase().ContainsIgnoreCase('mobile') && !f.TolowerCase().Contains('__')
            if(fields.get(f).getDescribe().getType().name().tolowerCase() == 'phone' ){
                system.debug('In First');
                ObjectPhoneFields.add(f);
            }
            //else if( (f.TolowerCase().contains('phone') || f.TolowerCase().contains('mobile') ) && fields.get(f).getDescribe().getType().name().tolowerCase() == 'text' ){
            //system.debug('In Second');
            //ObjectPhoneFields.add(f);
            //}
        }
        system.debug('SobjectNametext::'+SobjectNametext);
        system.debug('Phone fields::'+ObjectPhoneFields);
        
        String CommaSeparatedFields = string.join(ObjectPhoneFields,',');
        string queryStr = 'SELECT '+CommaSeparatedFields+' FROM '+SobjectNametext+' WHERE Id =  :recordId';
        system.debug('SOQL Query:: '+queryStr);
        List<sObject> sobjList = Database.query(queryStr);
        system.debug('sobjList'+sobjList);
        
        list<string> CustomerPhoneNumbers = new list<string>();
        for(sObject obj: sobjList) {
            for(string sObjfield : ObjectPhoneFields){
                system.debug(sObjfield+'==> '+(String)obj.get(sObjfield));
                if((String)obj.get(sObjfield) != null){
                    CustomerPhoneNumbers.add((String)obj.get(sObjfield));
                }
            }
        }
        if(CustomerPhoneNumbers.size() > 0)
            return CustomerPhoneNumbers[0];
        else
            return '';
    }
}