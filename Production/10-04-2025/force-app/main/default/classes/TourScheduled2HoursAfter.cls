public class TourScheduled2HoursAfter implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts{
    
    public void execute(SchedulableContext sc) {
        runJob();
    }
    
    @TestVisible
    private void runJob() {
        Database.executeBatch(this,1);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        //System.schedule('Tour Scheduled Hourly job 2 Hours After Scheduled dt', '0 0 * * * ?', new TourScheduled2HoursAfter() );
        
        //2 Hours After Tour_Scheduled_Date_Time__c
        DateTime StartDt = Datetime.newInstance(System.Now().year(), System.Now().month(), System.Now().day(), System.Now().addHours(-3).hour(), 0, 0);
        DateTime EndDt = Datetime.newInstance(System.Now().year(), System.Now().month(), System.Now().day(), System.Now().addHours(-2).hour(), 0, 0);
        
        system.debug('System.Now::'+System.Now());
        system.debug('StartDt::'+StartDt);
        system.debug('EndDt::'+EndDt);
        
        String query = 'SELECT Id, Tour_Scheduled_Date_Time__c, Proposed_Price__c, Opportunity_Record_Type__c, ';
        query += 'Send_Post_Tour_Email__c, Opportunity_Email__c, Brand__c, ';
        query += 'Cancelled__c, Opportunity__c, Opportunity__r.StageName, ';
        query += 'Opportunity__r.RecordTypeId, Opportunity__r.RecordType.DeveloperName, Delighted_Survey_Sent__c, ';
        query += 'Account__c, Account__r.isPersonAccount, Account__r.PersonEmail, Toured_By__c, ';
        query += 'Member_Application_Link__c, Home__c, Home__r.Name, Room__c, Room__r.RentCafe_Application_Link__c, ';
        query += 'Account__r.Preferred_First_Name__c, Home__r.Marketing_Name__c, Owner.FirstName, Account__r.Phone, ';
        query += 'Opportunity__r.Owner.FirstName, Opportunity__r.Owner.LastName, Home__r.Home_Neighborhood__c, Home__r.Home_Neighborhood__r.Name, ';
        query += 'Opportunity__r.Name, Opportunity__r.Owner.Slack_User_ID__c ';
        query += 'FROM Tour__c ';
        query += 'WHERE ';
        query += 'Tour_Scheduled_Date_Time__c >:StartDt AND Tour_Scheduled_Date_Time__c <=:EndDt ';
        query += 'AND Cancelled__c = FALSE AND ';
        query += 'Tour_Scheduled_Date_Time__c != NULL AND ';
        query += 'Opportunity__c != NULL ';
        system.debug('query ::'+query);
        
        system.debug('query::'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Tour__c> scope) {
        
        Id FbCommonRTId = Schema.SObjectType.Feedback__c.getRecordTypeInfosByDeveloperName().get('Common').getRecordTypeId();
        Id FbNoahRTId = Schema.SObjectType.Feedback__c.getRecordTypeInfosByDeveloperName().get('Noah').getRecordTypeId();
        // Id FbKinRTId = Schema.SObjectType.Feedback__c.getRecordTypeInfosByDeveloperName().get('Kin').getRecordTypeId();
         Id FbMilyRTId = Schema.SObjectType.Feedback__c.getRecordTypeInfosByDeveloperName().get('Mily').getRecordTypeId();
        
        list<Feedback__c> FeedbacksToCreate = new list<Feedback__c>();
        list<Opportunity> OppToUpdates = new list<Opportunity>();
        list<SendGrid_Email__e> SendGridEmails = new list<SendGrid_Email__e>();
        list<Twilio_Send_SMS__e> SMSRequests = new list<Twilio_Send_SMS__e>();
        list<Slack_Post__e> SlackPosts = new list<Slack_Post__e>();
        
        for(Tour__c tour : scope){
            
            //Send NPS Tour Survey
            //system.debug('Cancelled::'+tour.Cancelled__c);
            //system.debug('Tour_Scheduled_Date_Time::'+tour.Tour_Scheduled_Date_Time__c);
            //system.debug('Opportunity StageName::'+tour.Opportunity__r.StageName);
            //system.debug('Delighted_Survey_Sent::'+tour.Delighted_Survey_Sent__c);
            if(tour.Cancelled__c == FALSE && tour.Tour_Scheduled_Date_Time__c != null && (tour.Opportunity__r.StageName == 'Tour Held' || test.isRunningTest()) && tour.Delighted_Survey_Sent__c == FALSE){
                Feedback__c fb = new Feedback__c();
                fb.Account__c = tour.Account__c;
                fb.Brand__c = tour.Brand__c;
                fb.Email_Survey__c = TRUE;
                fb.Opportunity__c = tour.Opportunity__c;
                String FBRecordTypeId = FbCommonRTId;
                if(tour.Brand__c == 'noah')
                    FBRecordTypeId = FbNoahRTId;
                else if(tour.Brand__c == 'kin')
                    FBRecordTypeId = FbMilyRTId;
                fb.RecordTypeId = FBRecordTypeId;               
                fb.Related_User__c = tour.Toured_By__c;
                fb.SMS_Survey__c = TRUE;
                fb.Status__c = 'Sent';
                fb.Survey_Template__c = 'NPS - Tour';
                FeedbacksToCreate.add(fb);
            }
            
            //Success Tour - Non-Transfer
            if(tour.Cancelled__c == FALSE &&
               tour.Tour_Scheduled_Date_Time__c != NULL &&
               tour.Opportunity__c != NULL && 
               (tour.Opportunity__r.StageName == 'Tour Held' || tour.Opportunity__r.StageName == 'Tour Scheduled') &&
               tour.Opportunity__r.RecordTypeId != NULL && tour.Opportunity__r.RecordType.DeveloperName != 'Common_Transfer' &&
               tour.Account__c != NULL && tour.Account__r.isPersonAccount == TRUE){
                   
                   Opportunity opp = new Opportunity();
                   opp.Id = tour.Opportunity__c;
                   opp.StageName = 'Tour Held';
                   opp.Tour_Scheduled_Date_Time__c = tour.Tour_Scheduled_Date_Time__c;
                   OppToUpdates.add(opp);
                   
                   if(tour.Proposed_Price__c != null 
                      && tour.Opportunity_Record_Type__c == 'Common - Initial' 
                      && tour.Send_Post_Tour_Email__c == true 
                      && tour.Opportunity_Email__c != null){
                          
                          Map<String, String> myMap = new Map<String, String>();
                          myMap.put('TourID', tour.Id);
                          Flow.Interview.BE_Send_Post_Tour_Email myFlow = new Flow.Interview.BE_Send_Post_Tour_Email(myMap);
                          myFlow.start();
                      }
               }
            
            //Success Tour - Transfer
            if(tour.Cancelled__c == FALSE &&
               tour.Tour_Scheduled_Date_Time__c != NULL &&
               tour.Opportunity__c != NULL && 
               (tour.Opportunity__r.StageName == 'Tour Held' || tour.Opportunity__r.StageName == 'Tour Scheduled') &&
               tour.Opportunity__r.RecordTypeId != NULL && tour.Opportunity__r.RecordType.DeveloperName == 'Common_Transfer' &&
               tour.Account__c != NULL && tour.Account__r.isPersonAccount == TRUE){
                   Opportunity opp = new Opportunity();
                   opp.Id = tour.Opportunity__c;        
                   opp.StageName = 'Tour Held';
                   opp.Stage_Status__c = 'Awaiting Confirmation';
                   OppToUpdates.add(opp);
                   
                   if(tour.Account__r.PersonEmail != null && tour.Home__c != null){
                       
                       String FromEmail = 'transfers@common.com';
                       if(tour.Brand__c == 'noah')
                           FromEmail = 'transfers@noahapartments.com';
                       if(tour.Brand__c == 'kin')
                           FromEmail = 'transfers@milyliving.com';
                       
                       String FromName = 'Common Transfer Support';
                       if(tour.Brand__c == 'noah')
                           FromName = 'Noah Transfer Support';
                       if(tour.Brand__c == 'kin')
                           FromName = 'Mily Transfer Support';
                       
                       String SGTemplateId = 'd-1f3c763925a2428c91914340c2d1ceda';
                       if(tour.Brand__c == 'noah')
                           SGTemplateId = 'd-002024c9ee46494e978b53f69fd424ab';
                       if(tour.Brand__c == 'kin')
                           SGTemplateId = 'd-238aceb129884b25afc7b50142847809';
                       
                       String HomeApplicationLink = tour.Member_Application_Link__c;
                       
                       if(tour.Home__r.Name  == 'The Edge' || tour.Home__r.Name == 'Stella')
                           HomeApplicationLink = tour.Room__r.RentCafe_Application_Link__c;
                       
                       SendGrid_Email__e sgEmail = new SendGrid_Email__e();
                       sgEmail.From_Email__c = FromEmail;
                       sgEmail.From_Name__c = FromName;
                       sgEmail.SendGrid_Template_Id__c = SGTemplateId;
                       sgEmail.To_Email__c = tour.Account__r.PersonEmail;
                       sgEmail.Account_First_Name__c = tour.Account__r.Preferred_First_Name__c;
                       sgEmail.Home_Application_Link__c = HomeApplicationLink;
                       sgEmail.Home_Marketing_Name__c = tour.Home__r.Marketing_Name__c;
                       sgEmail.Owner_First_Name__c = tour.Owner.FirstName;
                       SendGridEmails.add(sgEmail);
                   }
                   
                   if(tour.Account__r.Phone != null){
                       
                       String HomeApplicationLink = tour.Member_Application_Link__c;                       
                       if(tour.Home__r.Name  == 'The Edge' || tour.Home__r.Name == 'Stella')
                           HomeApplicationLink = tour.Room__r.RentCafe_Application_Link__c;
                       
                       String NeighborhoodText = '';
                       if(tour.Home__r.Home_Neighborhood__c != NULL){
                           NeighborhoodText = ' in '+tour.Home__r.Home_Neighborhood__c;
                       }
                       String SMSText = 'Hi '+ tour.Account__r.Preferred_First_Name__c +', I hope you enjoyed your tour of '+tour.Home__r.Marketing_Name__c +NeighborhoodText+'. Remember, rooms come on a first come first serve basis. Click on the following link to reserve the room: {link1}. I\'d be happy to hop on a call and answer any questions regarding the application process! You can reach me at +18446011992.';
                       
                       Twilio_Send_SMS__e req = new Twilio_Send_SMS__e();
                       req.To_Number__c = tour.Account__r.Phone;
                       req.Brand__c = tour.Brand__c == null ? 'common' : tour.Brand__c;
                       req.Message__c = SMSText;
                       req.Link_1__c= HomeApplicationLink;
                       SMSRequests.add(req);
                   }
                   
               }
            
            //Tour Followup After Tour Scheduled Date/Time Updated - Scheduled Process
            Slack_Post__e slackPost = new Slack_Post__e();
            slackPost.Channel_Name__c = 'tour_follow_ups';
            slackPost.RecordId__c = tour.Id;
            String slackMessage = '';
            if(tour.Opportunity__r.Owner.Slack_User_ID__c == null){
                slackMessage = 'Hi '+tour.Opportunity__r.Owner.FirstName +' '+tour.Opportunity__r.Owner.LastName+', please confirm that you have followed up with '+ tour.Opportunity__r.Name+' who just finished their tour.';
            }else{
                slackMessage = '<@' + tour.Opportunity__r.Owner.Slack_User_ID__c + '> please confirm that you have followed up with '+ tour.Opportunity__r.Name+' who just finished their tour.';
            }            
            slackPost.Slack_Message__c = slackMessage;
            SlackPosts.add(slackPost);
            
        }
        
        if(FeedbacksToCreate.size() > 0){
            insert FeedbacksToCreate;
        }
        
        if(OppToUpdates.size() > 0){
            update OppToUpdates;
        }
        
        if(SendGridEmails.size() > 0){
            Eventbus.publish(SendGridEmails);
        }
        
        if(SlackPosts.size() > 0){
            Eventbus.publish(SlackPosts);
        }
        
        if(SMSRequests.size() > 0){
            Eventbus.publish(SMSRequests);
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}