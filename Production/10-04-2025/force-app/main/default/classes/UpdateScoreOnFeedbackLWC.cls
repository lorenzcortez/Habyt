public without sharing class UpdateScoreOnFeedbackLWC{
    
    @AuraEnabled
    public static void UpdateScoreOnFeedback(string recordId, string score){
        try{
            if(!String.isBlank(recordId) && !String.isBlank(score)){
                Feedback__c Feedback = new Feedback__c();
                Feedback.Id = recordId;
                Feedback.Score__c = decimal.valueOf(score.trim());
                Feedback.Completion_DateTime__c = system.now();
                update Feedback;
            }
        }catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        } 
    }
}