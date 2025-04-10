@isTest
public class TourTrigger_Test{

    static testmethod void TestMethod1(){
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
        h.PropertyLocation__latitude__s = 40.44898605;
        h.PropertyLocation__longitude__s = -3.699122906;
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
        insert t2;
    }
}