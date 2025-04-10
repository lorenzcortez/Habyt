@isTest
public class TourScheduled2HoursAfter_Test{

    public static testmethod void TourScheduled2HoursAfterTest(){
        
        String jsonBody = '{'+
        '    \"body\": \"Thanks for the message. Configure your number\'s SMS URL to change this message.Reply HELP for help.Reply STOP to unsubscribe.Msg&Data rates may apply.\",'+
        '    \"num_segments\": \"1\",'+
        '    \"direction\": \"outbound-reply\",'+
        '    \"from\": \"+19172424115\",'+
        '    \"to\": \"+14348791772\",'+
        '    \"date_updated\": \"Wed, 09 Jun 2021 09:21:44 +0000\",'+
        '    \"price\": \"-0.00375\",'+
        '    \"errorMessage\": null,'+
        '    \"uri\": \"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Messages/SM375e2215faa8b865d0b603913af3f003.json\",'+
        '    \"account_sid\": \"AC449b336950c036efaac67c7f2b93478c\",'+
        '    \"numMedia\": \"0\",'+
        '    \"status\": \"delivered\",'+
        '    \"messagingServiceSid\": null,'+
        '    \"sid\": \"SM375e2215faa8b865d0b603913af3f003\",'+
        '    \"date_sent\": \"Wed, 09 Jun 2021 09:21:44 +0000\",'+
        '    \"date_created\": \"Wed, 09 Jun 2021 09:21:44 +0000\",'+
        '    \"errorCode\": null,'+
        '    \"price_unit\": \"USD\",'+
        '    \"apiVersion\": \"2010-04-01\",'+
        '    \"subresourceUris\": {'+
        '        \"media\": \"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Messages/SM375e2215faa8b865d0b603913af3f003/Media.json\",'+
        '        \"feedback\": \"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Messages/SM375e2215faa8b865d0b603913af3f003/Feedback.json\"'+
        '    }'+
        '}';
        
        HttpMockFactory mock = new HttpMockFactory(200, 'OK', jsonBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mock);
    
        City__c c = new City__c();
        c.Name = 'Seattle';
        insert c;

        Brand__c br = new Brand__c(Name = 'Test Brand', APINameBrand__c = 'Test Brand API');
        insert br;
        
        Property__c h = new Property__c();
        h.Name = 'test';
        h.City_object__c = c.id;
        h.Home_Manager_User__c = UserInfo.GetUserID();
        h.BrandRef__c = br.Id;
        insert h;
        
        Account acc= new Account();
        acc.LastName = 'test';
        acc.PersonEmail = 'test@test.com';
        acc.Phone = '+1234567890';
        acc.PersonMobilePhone = '+1234567890';
        insert acc;
     
        Id TransferRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Common_Renewal').getRecordTypeId();
        
        Opportunity to = new Opportunity();
        to.Name = 'Test 2';
        to.RecordTypeId = TransferRecordTypeId;
        to.StageName = 'Tour Held';
        to.CloseDate = system.today();
        to.AccountID = acc.id;
        to.Brand__c  = 'noah';
        to.Price__c = '3 Month Price';
        to.Occupancy_Status__c = 'Active';
        to.Opportunity_Source_Detail__c = 'Test Opportunity';
        insert to;
        
        
        list<Tour__c> Tours = new list<Tour__c>();
   
        Tour__c t2 = new Tour__c();
        t2.Opportunity__c = to.id;
        t2.Tour_Scheduled_Date_Time__c = system.Now().addHours(-3);
        t2.Start__c = system.Now().addHours(-2);
        t2.End__c = system.Now().addHours(-2);
        t2.Account__c = Acc.id;
        t2.tour_Type__c = 'Matterport';
        t2.Cancelled__c = false;
        t2.Home__c = h.id;
        t2.Toured_By__c = userInfo.getUserId();
        t2.Tour_Confirmation_Email_Sent__c = false;
        t2.Delighted_Survey_Sent__c = FALSE;
        Tours.add(t2);
        
        insert Tours;
        
        Test.startTest();
            string CRON_EXP = '0 0 0 3 9 ? 2024';
            System.schedule('TourScheduled2HoursAfter test', CRON_EXP, new TourScheduled2HoursAfter());
        Test.stopTest(); 
    }

    @isTest
    static void test(){
        
        String jsonBody = '{'+
        '    \"body\": \"Thanks for the message. Configure your number\'s SMS URL to change this message.Reply HELP for help.Reply STOP to unsubscribe.Msg&Data rates may apply.\",'+
        '    \"num_segments\": \"1\",'+
        '    \"direction\": \"outbound-reply\",'+
        '    \"from\": \"+19172424115\",'+
        '    \"to\": \"+14348791772\",'+
        '    \"date_updated\": \"Wed, 09 Jun 2021 09:21:44 +0000\",'+
        '    \"price\": \"-0.00375\",'+
        '    \"errorMessage\": null,'+
        '    \"uri\": \"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Messages/SM375e2215faa8b865d0b603913af3f003.json\",'+
        '    \"account_sid\": \"AC449b336950c036efaac67c7f2b93478c\",'+
        '    \"numMedia\": \"0\",'+
        '    \"status\": \"delivered\",'+
        '    \"messagingServiceSid\": null,'+
        '    \"sid\": \"SM375e2215faa8b865d0b603913af3f003\",'+
        '    \"date_sent\": \"Wed, 09 Jun 2021 09:21:44 +0000\",'+
        '    \"date_created\": \"Wed, 09 Jun 2021 09:21:44 +0000\",'+
        '    \"errorCode\": null,'+
        '    \"price_unit\": \"USD\",'+
        '    \"apiVersion\": \"2010-04-01\",'+
        '    \"subresourceUris\": {'+
        '        \"media\": \"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Messages/SM375e2215faa8b865d0b603913af3f003/Media.json\",'+
        '        \"feedback\": \"/2010-04-01/Accounts/AC449b336950c036efaac67c7f2b93478c/Messages/SM375e2215faa8b865d0b603913af3f003/Feedback.json\"'+
        '    }'+
        '}';
        
        HttpMockFactory mock = new HttpMockFactory(200, 'OK', jsonBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mock);
    
        City__c c = new City__c();
        c.Name = 'Seattle';
        insert c;

        Brand__c br = new Brand__c(Name = 'Test Brand', APINameBrand__c = 'Test Brand API');
        insert br;
        
        Property__c h = new Property__c();
        h.Name = 'test';
        h.City_object__c = c.id;
        h.Home_Manager_User__c = UserInfo.GetUserID();
        h.BrandRef__c = br.Id;
        insert h;
        
        Account acc= new Account();
        acc.LastName = 'test';
        acc.PersonEmail = 'test@test.com';
        acc.Phone = '+1234567890';
        acc.PersonMobilePhone = '+1234567890';
        insert acc;
     
        Id Common_Transfer = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Common_Transfer').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Oppp';
        opp.RecordTypeId = Common_Transfer;
        opp.StageName = 'Tour Held';
        opp.CloseDate = system.Today();
        opp.Brand__c  = 'kin';
        opp.AccountID = acc.id;
        opp.Occupancy_Status__c = 'Active';
        opp.Opportunity_Source_Detail__c = 'Test Opportunity';
        insert opp;
        
        Tour__c t2 = new Tour__c();
        t2.Opportunity__c = opp.id;
        t2.Tour_Scheduled_Date_Time__c = system.Now().addHours(-3);
        t2.Start__c = system.Now().addHours(-2);
        t2.End__c = system.Now().addHours(-2);
        t2.Account__c = Acc.id;
        t2.tour_Type__c = 'Matterport';
        t2.Cancelled__c = false;
        t2.Home__c = h.id;
        t2.Toured_By__c = userInfo.getUserId();
        t2.Tour_Confirmation_Email_Sent__c = false;
        t2.Delighted_Survey_Sent__c = FALSE;
        
        insert t2;
        
        Test.startTest();
            string CRON_EXP = '0 0 0 3 9 ? 2024';
            System.schedule('TourScheduled2HoursAfter test', CRON_EXP, new TourScheduled2HoursAfter());
        Test.stopTest(); 
    }

}