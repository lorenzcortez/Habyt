@isTest
public class SendGridPlatformEventTrigger_Test{
    
    public static testmethod void UnitTestSuccess(){
    
        SendGrid__c sett = new SendGrid__C();
        sett.API_Key__c = '3242343';
        sett.Name = 'tet';
        sett.Email_Service__c = 'test@emailservice.com';
        insert sett;
        
        list<SendGrid_Email__e> Events1 = new list<SendGrid_Email__e>();

        for(integer i =1; i< 2; i++){
            SendGrid_Email__e event = new SendGrid_Email__e();
            event.First_Name__c = 'Test '+i;
            event.From_Email__c = 'development@einsteam.com';
            event.From_Name__c = 'Einsteam Test';
            event.SendGrid_Template_Id__c = 'd-36d50e2a86014037b545ae0a90602b7c';
            event.To_Email__c = 'development'+i+'@einsteam.com';
            event.Create_a_case_for_communication__c = true;
            event.New_case_record_type_Id__c = '0123u0000019nQO';
            Events1.add(event);
        }
        
        
        test.StartTest();
            EventBus.publish(Events1);
            Test.getEventBus().deliver();
        test.StopTest();
    }
    
}