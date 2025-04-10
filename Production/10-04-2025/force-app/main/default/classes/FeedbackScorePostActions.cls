public class FeedbackScorePostActions implements Schedulable {
    
    public void execute(SchedulableContext ctx) {
        
        //System.schedule('Feedback Score Update Post Actions', '0 0 * * * ?', new FeedbackScorePostActions () );
        
        
        DateTime StartDt = Datetime.newInstance(System.Now().year(), System.Now().month(), System.Now().day(), System.Now().addHours(-2).hour(), 0, 0);
        DateTime EndDt = Datetime.newInstance(System.Now().year(), System.Now().month(), System.Now().day(), System.Now().addHours(-1).hour(), 0, 0);
        
        system.debug('System.Now::'+System.Now());
        system.debug('StartDt::'+StartDt);
        system.debug('EndDt::'+EndDt);
        
        //1 Hours After Move_In_Score_Date_time__c
        list<Feedback__c> Feedbacks = new list<Feedback__c>();
        Feedbacks = [SELECT Id, Survey_Template__c,
                     Opportunity__c, Opportunity__r.Name, Score__c, Opportunity__r.Home_Committed__c, Opportunity__r.Home_Committed__r.Name, Opportunity__r.City__c, Opportunity__r.City_Lookup__r.Name,
                     Account__c, Account__r.FirstName, Account__r.LastName, Case__c, Case__r.Owner.FirstName, Case__r.Owner.LastName, Case__r.Home__c, Case__r.Home__r.Name,
                     Comments__c
                     FROM Feedback__c 
                     WHERE Score__c != NULL 
                     AND Score_Updated_Date_Time__c > :StartDt AND Score_Updated_Date_Time__c <= :EndDt];
        
        system.debug('Feedbacks::'+Feedbacks);
        list<Slack_Post__e> SlackPosts = new list<Slack_Post__e>();
        
        for(Feedback__c fb : Feedbacks){
            
            //Process Builder - Move In CSAT Score Slack Post
            if(fb.Survey_Template__c == 'CSAT Move-In' && fb.Opportunity__c != NULL && fb.Opportunity__r.Home_Committed__c != NULL){
                Slack_Post__e slackPost = new Slack_Post__e();
                slackPost.Channel_Name__c = 'move_ins';
                slackPost.RecordId__c = fb.Id;
                String slackMessage = fb.Opportunity__r.Name+' submitted a '+fb.Score__c+' on their Move-in CSAT survey. \n \n';
                slackMessage += 'Home Name: '+fb.Opportunity__r.Home_Committed__r.Name+'\n'; 
                slackMessage += 'City Name: '+fb.Opportunity__r.City_Lookup__r.Name+'\n \n';
                slackMessage += fb.Comments__c;
                system.debug('slackMessage::'+slackMessage);
                slackPost.Slack_Message__c = slackMessage;
                SlackPosts.add(slackPost);
            }
            
            //Process Builder - CSS & Noah - CSAT Member Survey Response
            system.debug('Survey_Template::'+fb.Survey_Template__c);
            system.debug('Account::'+fb.Account__c);
            system.debug('Case::'+fb.Case__c);
            system.debug('Case__r.Home::'+fb.Case__r.Home__c);
            if(fb.Survey_Template__c == 'CSAT - Member Support Case' && fb.Account__c != NULL && fb.Case__c != NULL && fb.Case__r.Home__c != NULL){
                
                //invoke "CSAT Member Support Feedback Case Updates" flow
                Map<String, String> myMap = new Map<String, String>();
                myMap.put('RecordID', fb.Id);
                Flow.Interview.CSAT_Member_Support_Feedback_Case_Updates myFlow = new Flow.Interview.CSAT_Member_Support_Feedback_Case_Updates(myMap);
                myFlow.start();
                
                
                
                Slack_Post__e slackPost = new Slack_Post__e();
                slackPost.Channel_Name__c = 'ms_case_csat_responses';
                slackPost.RecordId__c = fb.Id;
                String slackMessage = 'You have a new response. Member responded ';
                if(fb.Score__c == 1)
                    slackMessage += ':thumbsup:';
                else if(fb.Score__c == 2)
                    slackMessage += ':thumbsdown:';
                
                slackMessage += ' to the member support survey. \n \n';
                slackMessage += 'Member Full Name: '+ fb.Account__r.FirstName +' '+fb.Account__r.LastName+'\n';
                slackMessage += 'Home: '+fb.Case__r.Home__r.Name +'\n';
                slackMessage += 'Case Owner: '+fb.Case__r.Owner.FirstName +' '+ fb.Case__r.Owner.LastName +'\n';
                slackMessage += 'Comments: '+ fb.Comments__c;
                system.debug('slackMessage::'+slackMessage);
                slackPost.Slack_Message__c = slackMessage;
                SlackPosts.add(slackPost);
            }
        }
        
        system.debug('SlackPosts::'+SlackPosts);
        if(SlackPosts.size() > 0){
            Eventbus.publish(SlackPosts);
        }
        
    }
    
}