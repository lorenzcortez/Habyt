@isTest
public class UpdateScoreOnFeedbackLWC_Test{
    
    public static testmethod void UpdateScoreTest(){
        Feedback__c feedback = new Feedback__c();
        insert Feedback;
        
        UpdateScoreOnFeedbackLWC.UpdateScoreOnFeedback(Feedback.Id, '5');
    }
}