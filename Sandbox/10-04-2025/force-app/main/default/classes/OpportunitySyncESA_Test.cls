/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-13-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class OpportunitySyncESA_Test {
    
    @TestSetup
    static void makeData(){

        Account acct = new Account(
            FirstName = 'Test',
            LastName = 'Account',
            PersonEmail = 'test@test.com'
        );

        insert acct;
        System.assert(acct.Id != null, 'Account record is created');

        City__c c = new City__c(
            Name = 'Seattle1'
        );
        insert c;
        System.assert(c.Id != null, 'City record is created');


        Brand__c br = new Brand__c(
            Name = 'Test Brand',
            APINameBrand__c = 'Test Brand API'
        );
        insert br;

        System.assert(br.Id != null, 'Brand record is created');

        Property__c h = new Property__c(
            Name = 'test',
            City_object__c = c.id,
            Home_Manager_User__c = userInfo.getUserId(),
            Accounts_Receivable_Coordinator__c = userInfo.getUserId(),
            BrandRef__c = br.Id
        );
        
        insert h;
        System.assert(h.Id != null, 'Property record is created');

        Apartment__c s = new Apartment__c();
        s.Name = 'Test';
        s.PropertyRef__c = h.id;
        insert s;

        Id common = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Common - Initial').getRecordTypeId();

        Opportunity opp = new Opportunity(
            Name        = 'Lior Torenberg',
            StageName = 'Lease Application',
            CloseDate = system.today(),
            AccountID = acct.id,
            Occupancy_Status__c = 'Active',
            Phone__c = '2223333',
            City_Lookup__c = c.id,
            ApartmentRef__c = s.id,
            RecordTypeId = common,
            Has_ESA__c = TRUE
        );
        
        insert opp;
    }
    
    @isTest
    public static void scenario1(){ 
        Test.startTest();
        Database.executeBatch(new OpportunitySyncESA(), 1);
        Test.stopTest();
    }

}