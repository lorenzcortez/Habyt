/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-24-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class SendGrid {
    private static final String SG_HEADER_AUTHORIZATION = 'Authorization';
    private static final String SG_HEADER_AUTHORIZATION_TYPE = 'Bearer ';
    private static final String SG_HEADER_CONTENT = 'Content-Type';
    private static final String SG_HEADER_CONTENT_TYPE = 'application/json';
    private static final String SG_HTTP_METHOD = 'POST';        
    
    
    @InvocableMethod(label='Send Email via SendGrid' description='This method takes email and Template Id of Send Grid and send email via SendGrid API.')
    public static void SendEmail_SendGrid(list<SendEmailRequest> Requests) {
        system.debug('@@@@@');
        //Generating map for account selector metadata custom setting - For old method - Some flows still using dynamic contents.   
        map<string,string> APIKeyTemplateIdMap = new map<string,string>();
        list<SendGrid_Account_Selector__mdt> settings = [Select id,SendGrid_Template_ID__c,SendGrid_Account__c from SendGrid_Account_Selector__mdt];
        for(SendGrid_Account_Selector__mdt s: settings){
            APIKeyTemplateIdMap.put(s.SendGrid_Template_ID__c,s.SendGrid_Account__c);
        }
        
        list<Email_Error__c> errorlist = new list<Email_Error__c>();
        for(SendEmailRequest request :Requests){
            if(APIKeyTemplateIdMap.get(Request.TemplateId) != null){
                SendEmail(Request.toEmail, Request.TemplateId,APIKeyTemplateIdMap.get(Request.TemplateId), Request.dynamicContent, Request.FromName, Request.FromEmail, Request.ReplyToName, Request.ReplyToEmail, Request.RecordId, Request.SendEarliest, Request.ccEmails, Request.bccEmails, Request.EmailAttachmentId,null,null,null);
            }
            else{
                Email_Error__c er = new Email_Error__c();
                if(request.RecordId != null && request.RecordId.startsWith('006'))
                        er.Opportunity__c = request.RecordId;
                    if(request.RecordId != null && request.RecordId.startsWith('003'))
                        er.Record_ID__c = request.RecordId;
                er.Status_Code__c = 'SendGrid';
                er.Error_Message__c = 'API key not defined in the Account Selector metadata settings.';
                er.Error_Message__c += '\n RecordId: '+request.RecordId;
                er.Error_Message__c += '\n To Email: '+request.ToEmail;
                errorlist.add(er);
            }
            
        }
        
        if(errorlist.size() > 0){
            insert errorlist;
        }
    }
    
    
    @future(callout=true)
    public static void SendEmailAsync(string ToEmail, string TemplateId, string APIKey, string dynamicContent, string FromName_x, string FromEmail_x, string ReplyToName_x, string ReplyToEmail_x, String RecordId, boolean SendEarliest, String ccEmails, String bccEmails, String EmailAttachmentId,String ChecktheCheckbox,string Description, string Threadid){
        SendEmailCallout(ToEmail, TemplateId, APIKey, dynamicContent, FromName_x, FromEmail_x, ReplyToName_x, ReplyToEmail_x, RecordId, SendEarliest,ccEmails, bccEmails, EmailAttachmentId,ChecktheCheckbox,Description,Threadid);
    }
    
    public static void SendEmail(string ToEmail, string TemplateId, string APIKey, string dynamicContent, string FromName_x, string FromEmail_x, string ReplyToName_x, string ReplyToEmail_x, String RecordId, boolean SendEarliest, String ccEmails, String bccEmails, String EmailAttachmentId,String ChecktheCheckbox,string Description, string Threadid){
        if(System.isBatch()){
            SendEmailCallout(ToEmail, TemplateId, APIKey, dynamicContent, FromName_x, FromEmail_x, ReplyToName_x, ReplyToEmail_x, RecordId, SendEarliest,ccEmails, bccEmails, EmailAttachmentId,ChecktheCheckbox,Description,Threadid);
        }
        else{
            SendEmailAsync(ToEmail, TemplateId, APIKey, dynamicContent, FromName_x, FromEmail_x, ReplyToName_x, ReplyToEmail_x, RecordId, SendEarliest,ccEmails, bccEmails, EmailAttachmentId,ChecktheCheckbox,Description,Threadid);
        }    
    }
    
    
    public static void SendEmailCallout(string ToEmail, string TemplateId, string APIKey, string dynamicContent, string FromName_x, string FromEmail_x, string ReplyToName_x, string ReplyToEmail_x, String RecordId, boolean SendEarliest, String ccEmails, String bccEmails, String EmailAttachmentId,String ChecktheCheckbox,string Description, string Threadid){
        try{
            
            if(SendEarliest == null)
                SendEarliest = false;
            
            Map<string, String> CustomTags = new Map<String, String>();
            CustomTags.put('RecordID',RecordId);
            CustomTags.put('SFUserID',UserInfo.getUserId());
            
            dynamicContent = dynamicContent.replace('\r\n', ' ');
            dynamicContent = dynamicContent.replace('\n', ' ');
            dynamicContent = dynamicContent.replace('\r', ' ');
            dynamicContent= dynamicContent.replace('<br>', ' ');
            dynamicContent= dynamicContent.replace('&', '&amp;');
            
            
            //Remove HTML tags from the dynamic content
            dynamicContent = dynamicContent.stripHtmlTags();

            
            system.debug('dynamicContent::'+dynamicContent);
            
            SendGridEmailBody.To FromEmail = new SendGridEmailBody.To();
            FromEmail.Email = FromEmail_x;
            FromEmail.Name = FromName_x;
            
            
            SendGridEmailBody.To ReplyTo = new SendGridEmailBody.To();
            if(ReplyToName_x != null)
                ReplyTo.Name = ReplyToName_x;
            else
                ReplyTo.Name = FromName_x;
                
            if(ReplyToEmail_x != null)    
                ReplyTo.Email = ReplyToEmail_x;
            else
                ReplyTo.Email = FromEmail_x;
                
            //Setting To Email    
            list<SendGridEmailBody.To> toList = new list<SendGridEmailBody.To>();
            if(toEmail != null){
                List<String> ToEmailsFromParam = toEmail.split(',');
                for(string ss : ToEmailsFromParam){
                    if(ss != null && ss != ''){
                        SendGridEmailBody.To ToEmailvar = new SendGridEmailBody.To();
                        ToEmailvar.Email = ss.trim();
                        toList.add(ToEmailvar);  
                    }  
                }
            }
            system.debug('ToList::'+ToList);
            
            //BCC Emails
            list<SendGridEmailBody.To> bccList = new list<SendGridEmailBody.To>();
            if(System.Label.SendGrid_Activity_Log_Email_Address != null){
                SendGridEmailBody.To bccEmail = new SendGridEmailBody.To();
                bccEmail.Email = System.Label.SendGrid_Activity_Log_Email_Address;
                bccList.add(bccEmail);
            }
            
            if(bccEmails != null){
                List<String> bccEmailsFromParam = bccEmails.split(',');
                for(string ss : bccEmailsFromParam){
                    if(ss != null && ss != ''){
                        SendGridEmailBody.To bccEmailvar = new SendGridEmailBody.To();
                        bccEmailvar.Email = ss.trim();
                        bccList.add(bccEmailvar);  
                    }  
                }
            }
            
            
            //CC Emails
            list<SendGridEmailBody.To> ccList = new list<SendGridEmailBody.To>();
            
            if(ccEmails != null){
            List<String> ccEmailsFromParam = ccEmails.split(',');
                for(string ss : ccEmailsFromParam){
                    if(ss != null && ss != ''){
                        SendGridEmailBody.To ccEmailvar = new SendGridEmailBody.To();
                        ccEmailvar.Email = ss.trim();
                        ccList.add(ccEmailvar);    
                    }
                }
            }
            
            system.debug('ccList::'+ccList);
            system.debug('ccList::'+ccList.size());
            system.debug('bccList::'+bccList);
            
            String body = '';
            SendGridEmailBody EmailBody = new SendGridEmailBody ();
            EmailBody.from_Z = FromEmail;
            EmailBody.reply_to = ReplyTo;
            /**
             * description: Reverted Template ID assignment
             * date Apr-24-2024
             */
            EmailBody.template_id = TemplateId;
            
            /*Opportunity opp = [SELECT Id, Home_Committed__r.Country__c FROM Opportunity WHERE Id =: RecordId LIMIT 1];
            String canadaTemplateId = 'd-cae0baec251d459f9ae64d17f858a990';
            EmailBody.template_id = opp != null && opp?.Home_Committed__r.Country__c == 'Canada'?canadaTemplateId:TemplateId;*/
            
            SendGridEmailBody.Personalizations Personal = new SendGridEmailBody.Personalizations();
            
            personal.to = toList;
            if(ccList.size() > 0)
                personal.cc = ccList;
            if(bccList.size() > 0)
                personal.bcc = bccList;
            Personal.custom_args = CustomTags;
            
            system.debug('Personal::'+personal);
            
            //Send Earliest as Possible Respecting Timezones
            if(SendEarliest){
                Datetime now = Datetime.newInstance(system.now().year(), system.now().month(), system.now().day(), system.now().hour(), system.now().minute(), system.now().second());
                Integer offset = UserInfo.getTimezone().getOffset(now);
                Datetime local = now.addSeconds(offset/1000);
                
                system.debug('local time::'+local);
                datetime EarliestTime;
                if(local.hour() < 10){
                    EarliestTime = Datetime.newInstance(now.year(), now.month(), now.day(), 10, 0, 0);
                }else{
                    EarliestTime = Datetime.newInstance(now.year(), now.month(), now.day(), 10, 0, 0);
                    EarliestTime = EarliestTime.addDays(1);
                }
                
                system.debug('EarliestTime::'+EarliestTime);
                Long ScheduleDateTime = EarliestTime.getTime();
                system.debug(ScheduleDateTime);
                
                Personal.send_at = ScheduleDateTime/1000;
            }
            
            
            list<SendGridEmailBody.Personalizations> personalList = new list<SendGridEmailBody.Personalizations>();
            personalList.add(Personal);
            EmailBody.Personalizations = personalList;
            
            EmailBody.custom_args = CustomTags;
            
            Map<String, Object> lst_JsonParse = (Map<String, Object>)Json.deserializeUntyped(dynamicContent);
            system.debug('lst_JsonParse::'+lst_JsonParse);
            
            map<string, string> MergeFieldsMap = new map<string, string>();
            for(string key : lst_JsonParse.keySet()){
                MergeFieldsMap.put(key, String.valueOf(lst_JsonParse.get(key)) == null ? '' : String.valueOf(lst_JsonParse.get(key)));
            }
            
            system.debug('OUT Merge field section threadid'+Threadid );
            if(Threadid != null){
                system.debug('IN Merge field section');
                MergeFieldsMap.put('Thread_ID',Threadid);
            }
            
            system.debug('MergeFieldsMap::'+MergeFieldsMap);
            system.debug('dynamic content::'+MergeFieldsMap);
            personal.dynamic_template_data = MergeFieldsMap;
            
            system.debug('dynamicContent:::'+JSON.serialize(personal.dynamic_template_data, false));
            
            if(EmailAttachmentId != null){
                
                string ObjectName = String.valueOf(id.valueOf(EmailAttachmentId).getsobjecttype());
                SendGridEmailBody.attachments EmailAttachment = new SendGridEmailBody.attachments();
                
                if(ObjectName == 'Attachment'){
                    list<Attachment> Attach = new list<Attachment>();
                    Attach = [Select Name, Body, ContentType FROM Attachment WHERE ID = :EmailAttachmentId];
                    if(Attach.size() > 0){
                        EmailAttachment.content = EncodingUtil.base64Encode((Attach[0].Body));
                        EmailAttachment.type = Attach[0].ContentType;
                        EmailAttachment.filename = Attach[0].Name;
                    }
                }else if(ObjectName == 'ContentDocument'){
                    list<ContentVersion> ContentVers = new list<ContentVersion>();
                    ContentVers = [SELECT Title, FileExtension, FileType, VersionData FROM ContentVersion WHERE ContentDocumentId = :EmailAttachmentId AND IsLatest = true];
                    if(ContentVers.size() > 0){
                        EmailAttachment.content = EncodingUtil.base64Encode((ContentVers[0].VersionData));
                        
                        
                        EmailAttachment.type = ContentVers[0].FileType;
                        
                        if(ContentVers[0].FileType != null && ContentVers[0].FileType.contains('WORD')){
                            EmailAttachment.filename = ContentVers[0].Title+'.docx';
                        }else{
                            EmailAttachment.filename = ContentVers[0].Title;
                        }
                        
                    }
                }
                
                if(EmailAttachment.content != null && EmailAttachment.filename != null){
                    list<SendGridEmailBody.attachments> AttachmentList = new list<SendGridEmailBody.attachments>();
                    AttachmentList.add(EmailAttachment);
                    EmailBody.attachments = AttachmentList;
                }
            }
            
            if( !String.ISBLANK(MergeFieldsMap.get('Category_Brand')) ||  !String.ISBLANK(MergeFieldsMap.get('Category_Funnel')) ||
            !String.ISBLANK(MergeFieldsMap.get('Category_Template_Id')) ||  !String.ISBLANK(MergeFieldsMap.get('Category_Unit_Type'))){
                
                list<string> cats = new list<string> ();
                
                if( !String.ISBLANK(MergeFieldsMap.get('Category_Template_Id')) ){
                    cats.add(MergeFieldsMap.get('Category_Template_Id'));
                }
                
                if( !String.ISBLANK(MergeFieldsMap.get('Category_Brand')) ){
                    cats.add(MergeFieldsMap.get('Category_Brand'));
                }
                
                if( !String.ISBLANK(MergeFieldsMap.get('Category_Funnel')) ){
                    cats.add(MergeFieldsMap.get('Category_Funnel'));
                }
                
                if( !String.ISBLANK(MergeFieldsMap.get('Category_Unit_Type')) ){
                    cats.add(MergeFieldsMap.get('Category_Unit_Type'));
                }
                
                if(cats.size() > 0){ 
                    emailbody.categories = cats;
                }
                
            }
            
            body = JSON.serialize(EmailBody, false);
            body = body.replace('from_Z','From');
            system.debug('body::'+body);
            
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            req.setEndpoint('https://api.sendgrid.com/v3/mail/send');
            req.setTimeout(120000);
            req.setMethod(SG_HTTP_METHOD);
            req.setHeader(SG_HEADER_CONTENT,SG_HEADER_CONTENT_TYPE);
            req.setHeader(SG_HEADER_AUTHORIZATION,SG_HEADER_AUTHORIZATION_TYPE + APIKey);
            req.setBody(body);
            
            HttpResponse response = http.send(req);
            system.debug('response::'+response);
            system.debug('response::'+response.getBody());
            
            
            if((response.getStatusCode() != 200 || response.getStatusCode() != 201) && response.getBody() != ''){
                SendGridError SGError = SendGridError.parse(response.getBody());
                Email_Error__c er = new Email_Error__c();
                if(RecordId != null && RecordId.startsWith('006')){er.Opportunity__c = RecordId;}
                if(RecordId != null && RecordId.startsWith('003')){er.Record_ID__c = RecordId;}
                er.Status_Code__c = 'SendGrid';
                er.Error_Message__c = '';
                
                for(SendGridError.Errors error : SGError.Errors){ er.Error_Message__c += error.message+ '\n';}
                er.Error_Message__c += '\n RecordId: '+RecordId;
                system.debug(er.Error_Message__c);
            
                insert er;
            }else{
                
                try{
                
                    if( ChecktheCheckbox != null && ChecktheCheckbox != '' && RecordId != null){ 
                        
                        ID stringrecordid = RecordId;
                        string typename  = stringrecordid.getSObjectType().getDescribe().getName();
                        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
                        SObject dynamicobj = targetType.newSObject();
                        dynamicobj.put('ID',recordid);
                        dynamicobj.put(ChecktheCheckbox,true);
                        update dynamicobj;
                        
                    }
                    
                    SendGrid_Email_Tracker__c o = new SendGrid_Email_Tracker__c();
                    o.Email_Address__c = ToEmail; 
                    o.Name = TemplateId;
                    o.Description__c = Description;
                    o.OpportunityId__c = RecordId;
                    Insert o;
                    
                }
                catch(Exception ex){ string ErMessage = 'Error for Template ID: '+ TemplateId +' \n'; ErMessage += ex.GetMessage();
                    Email_Error__c e = new Email_Error__c(Error_Message__c = ErMessage); insert e; }
            }
        
        }catch(exception ex){
            system.debug(ex.getMessage());
            system.debug('Line Number::'+ex.getLineNumber());
            system.debug('Cause::'+ex.getCause());
            
            Email_Error__c er = new Email_Error__c();
            if(RecordId != null && RecordId.startsWith('006'))
                    er.Opportunity__c = RecordId;
                if(RecordId != null && RecordId.startsWith('003'))
                    er.Record_ID__c = RecordId;
            er.Status_Code__c = 'SendGrid';
            er.Error_Message__c = ex.getMessage();
            er.Error_Message__c += '\n RecordId: '+RecordId;
            insert er;
        }
    }
    
    
}