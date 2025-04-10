/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-29-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class LeadTriggerTest {
    private static testMethod void onAfterUpdate() {
        Lead l = new Lead(LastName = 'Test Lname',
                         Status = 'Open');
		insert l;
        
        Property__c property = TestRecord_Factory.createProperty();
        insert property;
        
        Test.startTest();
            l.Home_Committed__c = property.id;
            update l;
        Test.stopTest();
        System.assert([SELECT Id, Home_Committed__c FROM Lead WHERE Id =: l.Id]?.Home_Committed__c != null);
    }
}