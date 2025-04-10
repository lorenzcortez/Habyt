public class EscalateSkillsPSRTiers implements Queueable {
    
    private List<String> CasesString;
    public EscalateSkillsPSRTiers(List<String> records) {
        this.CasesString = records;
    }
    
    public void execute(QueueableContext context) {
        List<String> CaseIDs = new list<String>();
        try{
            Group renewalCaseQueue = [select id, name from group where name = 'Renewal Case'][0];
            
            //create list of the case objects
            List<Skill> skillsList = [select id, developerName from skill];
            String T1;
            String T2;
            String T3;
            String T4;
            
            for(skill s : skillsList){
                if(s.developerName == 'Escalation_Tier_1'){
                    T1 = s.id;
                }
                if(s.developerName == 'Escalation_Tier_2'){
                    T2 = s.id;
                }
                if(s.developerName == 'Escalation_Tier_3'){
                    T3 = s.id;
                }
                if(s.developerName == 'Escalation_Tier_4'){
                    T4 = s.id;
                }
            }
            
            
            List<skill_junction__c> SJs = [Select id, sub_issue_Type__C, tier__c, skill_id__c from skill_junction__C];
            map<string, skill_junction__c> subIssueMap = new map<String, skill_junction__c>();
            
            for(skill_junction__C sj: sjs){
                subIssueMap.put(sj.sub_issue_type__c, sj);
            }
            
            
            List<Case> caseObjects = [SELECT Id, work_order__c, ownerid, sub_issue_type__c, tier__c, origin, home__r.Member_support_manager__r.Name, escalation_reason__c, recordType.developerName, subject, Description FROM Case WHERE Id in :casesString and home__r.bypass_skills_routing__C = false];
            
            //if a case in this list is a renewal, remove it from both the caseObjects list and the casesString list, making it not route.
            integer index = 0;
            List<integer> indicesToRemove = new List<integer>();
            List<integer> indicesToRemove2 = new List<integer>();
            for(case c : caseObjects){
                if((c.sub_issue_type__c != null && c.sub_issue_type__c == 'Renewals') || c.ownerid == renewalCaseQueue.id){
                    integer index2 = 0;
                    indicesToRemove.add(index);
                    for(String s: casesString){
                        if(s == c.Id)
                            indicesToRemove2.add(index2);
                     	index2++;
                    }
                }
                index++;
            }
            
            for(integer x :indicesToRemove)
                caseObjects.remove(x);
            
            for(integer x :indicesToRemove2)
                casesString.remove(x);
            
            //create list of PendingServiceRouting Objects
            List<PendingServiceRouting> PSRs = new List<PendingServiceRouting>();
            
            //create a map of PSR id to the case Object associated with it, this will be used to 
            //determine the skills needed for the job by checking the home
            
            Map<id, Case> PSRID2Case = new Map<id, Case>();
            //loop through cases and create a PSR object and add it to the psr List
            for (Case caseObj : caseObjects) {
                CaseIDs.add(caseObj.id);
                caseObj.ownerid = '00G3u000002O6HhEAK';
                // Add SkillsBased PendingServiceRouting
                //String psroldid = [select id from PendingServiceRouting where workItemid = :caseObj.id][0].id;
                PendingServiceRouting psrObj = new PendingServiceRouting(
                    CapacityWeight = 14,
                    IsReadyForRouting = FALSE,
                    RoutingModel  = 'MostAvailable',
                    RoutingPriority = 2,
                    RoutingType = 'SkillsBased',
                    ServiceChannelId = '0N93u000000lYPXCA2',
                    WorkItemId = caseObj.Id
                );
                
                
                PSRs.add(psrObj);
            }
            
            update caseObjects;
            //delete currentPSRs;            
            List<PendingServiceRouting> PSRsOld = [Select id from pendingServiceRouting where workItemID in: CasesString];
            if(PSRsOld.size() > 0)
                delete PSRsOld;
            
            //insert new PSRs
            insert PSRs;
            //reCreate the PSR List object with ids that just got created from inserting it
            //PSRs = [select id, IsReadyForRouting, workitemId from PendingServiceRouting where workItemId in : cases];
            
            //create the map between PSRid and case object
            
            
            for(pendingServiceRouting psrTemp : PSRs){
                for(Case c : CaseObjects){
                    if(psrTemp.workItemId == c.id){
                        PSRID2Case.put(psrTemp.id, c);
                        break;
                    }
                }
            }
            
            
            
            
            //create a list of the skill requirement object, and set the skill id based on the home.
            List<SkillRequirement> Skills = new List<SkillRequirement>();
            id dispatchSkill = [select id from skill where developername = 'Dispatcher_skill'][0].id;
            for(pendingServiceRouting psrTemp : PSRs){
                SkillRequirement srObj = new SkillRequirement();
                String tier = PSRID2Case.get(psrTemp.id).tier__c;
                if(PSRID2Case.get(psrTemp.id).sub_issue_type__c != null){
                    srObj.SkillId = subIssueMap.get(PSRID2Case.get(psrTemp.id).sub_issue_type__c).skill_id__c;
                    srObj.RelatedRecordId = psrTemp.id;
                    skills.add(srObj);
                }
                
                
                SkillRequirement srObj2 = new SkillRequirement();
                srObj2.RelatedRecordId = psrTemp.id;
                String skillID;
                
                //Add 1 to tier
                if(String.isBlank(tier)){
                    skillID = T2;
                }
                
                else if(tier.containsIgnoreCase('1')){
                    skillID = T2;
                }
                else if(tier.containsIgnoreCase('2')){
                    skillID = T3;
                }
                else if(tier.containsIgnoreCase('3')){
                    skillID = T4;
                }
                else{
                    skillID = T4;
                }
                srObj2.SkillId = skillID;
                
                skills.add(srObj2);
                
                if(PSRID2Case.get(psrTemp.id).tier__c != 'Tier 4' && !String.isBlank(tier)){
                    PSRID2Case.get(psrTemp.id).tier__c = 'Tier ' + String.valueOf(Integer.valueOf(tier.substring(5))+1);
                }
                else if(PSRID2Case.get(psrTemp.id).tier__c == 'Tier 4'){
                    PSRID2Case.get(psrTemp.id).tier__c = 'Tier 4';
                }
                else{
                    PSRID2Case.get(psrTemp.id).tier__c = 'Tier 2';
                }
                
                PSRID2Case.get(psrTemp.id).isEscalated = false;
                
                //dispatch skill stuff
                /* 
                SkillRequirement srObj3 = new SkillRequirement();
                if(PSRID2Case.get(psrTemp.id).work_order__c != null){
                    srObj3.SkillId = dispatchSkill;
                    srObj3.RelatedRecordId = psrTemp.id;
                    skills.add(srObj3);
            	}
            */
                
            }
            update PSRID2Case.values();
            insert Skills;
            // After inserting skill requirements, update PendingServiceRouting as IsReadyForRouting
            for(PendingServiceRouting psrReady : PSRs){
                psrReady.IsReadyForRouting = TRUE;
            }
            update PSRs;
            if(CasesString != null)
            	sendSuccessEmail(CasesString);
        }
        catch(exception e){
            System.debug(e.getCause());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            sendEmailtoSFDCAdmins(e, CasesString);
        }
        
        
    }
    
    
    public static void sendEmailtoSFDCAdmins(exception e, List<String> CaseIDs){
        
        Messaging.reserveSingleEmailCapacity(2);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Strings to hold the email addresses to which you are sending the email.
        String[] toAddresses = new String[] {'sfdc-admins@common.com'}; 
            String[] ccAddresses = new String[] {'james.holden+1235@common.com'};
                
                
                // Assign the addresses for the To and CC lists to the mail object.
                mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        
        // Specify the address used when the recipients reply to the email. 
        mail.setReplyTo('sfdc-admins@common.com');
        
        // Specify the name used as the display name.
        mail.setSenderDisplayName('JT Error messaging');
        
        // Specify the subject line for your email address.
        mail.setSubject('Error on queueable apex: EscalateSkillsPSRTiers');
        
        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);
        
        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);
        
        // Specify the text content of the email.
        mail.setPlainTextBody(e.getMessage() + ' Cases: ' + CaseIDs + '\n' + 'Line Number: ' + e.getLineNumber() + '\n' + 'cause: ' + e.getCause() + '\n' + 'StackTrace: ' + e.getStackTraceString());
        
        mail.setHtmlBody('');
        
        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static void sendSuccessEmail(List<String> CaseIDs){
        
        Messaging.reserveSingleEmailCapacity(2);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Strings to hold the email addresses to which you are sending the email.
        String[] toAddresses = new String[] {'james.Holden+1234@common.com'}; 
            
            
            // Assign the addresses for the To and CC lists to the mail object.
            mail.setToAddresses(toAddresses);
        
        // Specify the address used when the recipients reply to the email. 
        mail.setReplyTo('sfdc-admins@common.com');
        
        // Specify the name used as the display name.
        mail.setSenderDisplayName('JT Success messaging');
        
        // Specify the subject line for your email address.
        mail.setSubject('Success on EscalateSkillsPSRTiers');
        
        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);
        
        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);
        
        // Specify the text content of the email.
        mail.setPlainTextBody(' Cases: ' + CaseIDs);
        
        mail.setHtmlBody('');
        
        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}