@isTest
public class TwilioCallLogsLWC_Test{

    private testmethod static void TwilioCallLogsLWCTest(){
        //Updated
        Account acc = new Account();
        acc.Name = 'test'; 
        acc.phone = '+1234567890';
        insert acc;
        
        TwilioCallLogsLWC.getFromTwilioCalls(acc.Id);
        TwilioCallLogsLWC.getToTwilioCalls(acc.Id);
        TwilioCallLogsLWC.getFromTwilioMessages(acc.id);
        TwilioCallLogsLWC.getToTwilioMessages(acc.id);
        TwilioCallLogsLWC.getCustomerPhone(acc.id);
        
        
        Twilio_API__c TwilioSetting = new Twilio_API__c();
        TwilioSetting.Name = 'Test Setting';
        TwilioSetting.Account_SID__c = 'ACXXXXXXXXXXXXXXXXXXXXXXX';
        TwilioSetting.Auth_Token__c = 'TESTZZZZZZZZZZZZZZZZZZZZZZ';
        TwilioSetting.Endpoint_Base_URL__c = 'https://api.twilio.com/2010-04-01';
        TwilioSetting.API_Version__c = '3.2.0';
        insert TwilioSetting;
        
        TwilioCallLogsLWC.getFromTwilioCalls(acc.Id);
        TwilioCallLogsLWC.getToTwilioCalls(acc.Id);
        TwilioCallLogsLWC.getFromTwilioMessages(acc.id);
        TwilioCallLogsLWC.getToTwilioMessages(acc.id);
        TwilioCallLogsLWC.getCustomerPhone(acc.id);
        TwilioCallLogsLWC.getLatestRecording('CA69506XXXXXXXXXXXXXXXXXXX');
        TwilioUtility.FormatPhoneNumber('234567890');
    }
}