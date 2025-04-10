/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-22-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class RunAssignmentRules_Test {
    
    @testSetup
    static void loadData(){
        Lead l = new Lead(
            LastName='Test',
            Company='Test'
        );
        insert l;
    }
    
    @isTest
    static void testLead(){
        //instantiate List to pass to @InvocableMethod
        List<Id> ids = new List<Id>();
        
        //query for test data and add to List
        Lead l = [SELECT Id, OwnerId FROM Lead];
        ids.add(l.Id);
        
        //call @InvocableMethod
        test.startTest();
        RunAssignmentRules.assignLeads(ids);
        test.stopTest();
        
        //verify that Lead was re-assigned
        Lead res = [SELECT Id, OwnerId FROM Lead];
        System.assert(l.OwnerId != res.OwnerId, res);
    }
}