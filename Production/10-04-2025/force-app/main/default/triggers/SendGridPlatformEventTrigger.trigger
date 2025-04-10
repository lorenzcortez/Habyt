trigger SendGridPlatformEventTrigger on SendGrid_Email__e (after insert) {
    
    try{
        
        //Generating map for account selector metadata custom setting
        map<string,string> APIKeyTemplateIdMap = new map<string,string>();
        list<SendGrid_Account_Selector__mdt> settings = [Select id,SendGrid_Template_ID__c,SendGrid_Account__c from SendGrid_Account_Selector__mdt];
        for(SendGrid_Account_Selector__mdt s: settings){
            APIKeyTemplateIdMap.put(s.SendGrid_Template_ID__c,s.SendGrid_Account__c);
        }
        
        List<Schema.SObjectType> SGobjects = new List<Schema.SObjectType>{ SendGrid_Email__e.SObjectType};
            
        set<string> eventemails = new set<string>();
        set<string> eventtemplateids = new set<string>();
        set<string> eventoppids = new set<string>();
        
        for(SendGrid_Email__e SGEvent : trigger.new){
            if(SGEvent.To_Email__c != null){
                eventemails.add(SGEvent.To_Email__c);
            }
            
            if(SGEvent.SendGrid_Template_Id__c != null){
                eventtemplateids.add(SGEvent.SendGrid_Template_Id__c); 
            }
            
            if(SGEvent.Opportunity_ID__c != null){
                eventoppids.add(SGEvent.Opportunity_ID__c); 
            }
        }
        
        list<SendGrid_Email_Tracker__c> DupLogs = new list<SendGrid_Email_Tracker__c>();
        Map<string,boolean> DupLogsMap = new Map<string,boolean>();
        if(eventemails.size() > 0 && eventtemplateids.size() > 0 && eventoppids.size() > 0){
            DupLogs = [select id,Name,Email_Address__c,OpportunityID__c from SendGrid_Email_Tracker__c where Email_Address__c in:eventemails AND Name in:eventtemplateids AND OpportunityID__c in:eventoppids and IsDeleted = false];
            for(SendGrid_Email_Tracker__c d : DupLogs){
                DupLogsMap.put(d.Name+'_'+d.Email_Address__c+'_'+d.OpportunityID__c,true);
            }
        }
        
        list<Email_Error__c> emailerrorlist = new list<Email_Error__c>();
        
        for(SendGrid_Email__e SGEvent : trigger.new){
            
            Boolean IsDuplicateEmail = False;
            
            if(SGEvent.Avoid_Duplicate_Email__c == True && DupLogsMap.get(SGEvent.SendGrid_Template_Id__c+'_'+SGEvent.To_Email__c+'_'+SGEvent.Opportunity_ID__c) == true ){
                IsDuplicateEmail = True;
            }
            
            if(SGEvent.SendGrid_Template_Id__c != null && APIKeyTemplateIdMap.get(SGEvent.SendGrid_Template_Id__c) != null && SGEvent.To_Email__c != null && IsDuplicateEmail == False){ 
                
                boolean SendEarliest = false;
                string EmailAttachmentId;
                
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                for(Schema.SObjectType objType: SGobjects ){
                    for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){
                        String FieldAPIName = fld.getDescribe().getName();                    
                        System.debug('API Field Name =  '+FieldAPIName);
                        if(FieldAPIName.Contains('__c')){
                            String fieldType = String.ValueOf(fld.getDescribe().getType());
                            
                            if(SGEvent.get(FieldAPIName) == null){
                                gen.writeStringField(FieldAPIName.removeEnd('__c'),'');
                            }else{
                                if(FieldType == 'DATE'){
                                    gen.writeStringField(FieldAPIName.removeEnd('__c'),date.valueOf(SGEvent.get(FieldAPIName)).format());
                                    
                                }else{
                                    gen.writeStringField(FieldAPIName.removeEnd('__c'),String.ValueOf(SGEvent.get(FieldAPIName)));
                                }
                            }
                        }
                        
                    }
                }
                
                gen.writeEndObject();  
                string dynamicContent = gen.getAsString();
                system.debug('dynamicContent::'+dynamicContent);
                system.debug('OUT Future method 1::');
                
                String FromName = SGEvent.From_Name__c;
                String FromEmail = SGEvent.From_Email__c;
                String ReplyToName = SGEvent.Reply_To_Name__c;
                String ReplyToEmail = SGEvent.Reply_To_Email__c;
                string ccEmails = SGEvent.CC_Emails__c;
                string bccEmails = SGEvent.BCC_Emails__c;
                
                system.debug('OUT Future method::');
                
                string CaseThreadid = null;
                
                if(SGEvent.Create_a_case_for_communication__c && !string.IsBlank( SGEvent.New_case_record_type_Id__c ) ){
                    case c = new case();
                    c.recordtypeid = SGEvent.New_case_record_type_Id__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.recordtypeid = SGEvent.New_case_record_type_Id__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.recordtypeid = SGEvent.New_case_record_type_Id__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.recordtypeid = SGEvent.New_case_record_type_Id__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.recordtypeid = SGEvent.New_case_record_type_Id__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.recordtypeid = SGEvent.New_case_record_type_Id__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.recordtypeid = SGEvent.New_case_record_type_Id__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.recordtypeid = SGEvent.New_case_record_type_Id__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.recordtypeid = SGEvent.New_case_record_type_Id__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.recordtypeid = SGEvent.New_case_record_type_Id__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.recordtypeid = SGEvent.New_case_record_type_Id__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.recordtypeid = SGEvent.New_case_record_type_Id__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.recordtypeid = SGEvent.New_case_record_type_Id__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.recordtypeid = SGEvent.New_case_record_type_Id__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    c.recordtypeid = SGEvent.New_case_record_type_Id__c;
                    c.subject = SGEvent.Case_Subject__c;
                    c.suppliedemail = SGEvent.To_Email__c;
                    
                    if( !string.IsBlank(SGEvent.Case_Owner_Id__c) ){
                        c.Ownerid = SGEvent.Case_Owner_Id__c;
                    }
                    else if( !string.IsBlank(SGEvent.Case_Default_Queue_Id__c) ) {
                        c.Ownerid = SGEvent.Case_Default_Queue_Id__c;
                    }
                    else
                    {
                        c.Ownerid = '0056A000000xcIn';
                    }
                    
                    if( !string.IsBlank(SGEvent.Case_Status__c) ){
                        c.status = SGEvent.Case_Status__c;
                    }
                    else{
                        c.status = 'Open';
                    }
                    
                    if(SGEvent.Opportunity_ID__c != null){
                        if(SGEvent.Opportunity_ID__c.startsWith('006')){
                            c.opportunity__c =  SGEvent.Opportunity_ID__c;
                        }
                    }
                    
                    c.Origin = 'Email';
                    insert c; 
                    
                    CaseThreadid = [select id, Thread_ID__c from case where id=:c.id].Thread_ID__c;
                }
                
                if(!Test.isRunningTest()){
                    system.debug('IN Future method::');
                    SendGrid.SendEmail(SGEvent.To_Email__c, SGEvent.SendGrid_Template_Id__c, APIKeyTemplateIdMap.get(SGEvent.SendGrid_Template_Id__c), dynamicContent, FromName, FromEmail, ReplyToName, ReplyToEmail, SGEvent.Opportunity_ID__c, SendEarliest, ccEmails, bccEmails, SGEvent.Attachment_ID__c,SGEvent.Check_the_Checkbox__c,SGEvent.Process_Description_For_Tracking_Only__c,CaseThreadid);
                }
                
            }
            else{
                Email_Error__c er = new Email_Error__c();
                er.Status_Code__c = 'SendGrid';
                if(SGEvent.SendGrid_Template_Id__c == null || SGEvent.SendGrid_Template_Id__c == ''){ er.Error_Message__c = 'SendGrid Template Id not Provided.'; }
                else if(APIKeyTemplateIdMap.get(SGEvent.SendGrid_Template_Id__c) == null || APIKeyTemplateIdMap.get(SGEvent.SendGrid_Template_Id__c) == ''){ er.Error_Message__c = 'API key not defined in the Account Selector metadata settings.'; }
                
                if(SGEvent.To_Email__c == null || SGEvent.To_Email__c == ''){ er.Error_Message__c = 'To Email not Provided.'; }
                if(IsDuplicateEmail == true){ er.Error_Message__c = 'Email with same template id already exist in the email tracker object so we cannot send duplicate email.'; }
                
                er.Error_Message__c += '\n RecordId: '+SGEvent.Opportunity_ID__c;
                er.Error_Message__c += '\n To Email: '+SGEvent.To_Email__c;
                
                if(SGEvent.Opportunity_ID__c != null) { if(SGEvent.Opportunity_ID__c.startsWith('006')){ er.Opportunity__c = SGEvent.Opportunity_ID__c; }
                                                       if(SGEvent.Opportunity_ID__c.startsWith('003')){ er.Record_ID__c = SGEvent.Opportunity_ID__c; }}
                emailerrorlist.add(er);
            }
        }
        
        if(emailerrorlist.size() > 0){
            insert emailerrorlist;
        }
        
    }
    catch(Exception ex){
        list<Email_Error__c> emailerrorlist = new list<Email_Error__c>();
        for(SendGrid_Email__e SGEvent : trigger.new){ 
            Email_Error__c er = new Email_Error__c();
            
            if(SGEvent.Opportunity_ID__c != null) { 
                if(SGEvent.Opportunity_ID__c.startsWith('006')){ er.Opportunity__c = SGEvent.Opportunity_ID__c; }
                if(SGEvent.Opportunity_ID__c.startsWith('003')){ er.Record_ID__c = SGEvent.Opportunity_ID__c; }
            }
            
            er.Status_Code__c = 'SendGrid';
            er.Error_Message__c = ex.getMessage();
            er.Error_Message__c += '\n RecordId: '+SGEvent.Opportunity_ID__c;
            er.Error_Message__c += '\n To Email: '+SGEvent.To_Email__c;
            er.Error_Message__c += '\n Template ID: '+SGEvent.SendGrid_Template_Id__c;
            
            emailerrorlist.add(er);
        }
        
        insert emailerrorlist;
    }
    
}