/**
 * @description       : 
 * @author            : Existing Code
 * @group             : 
 * @last modified on  : 11-14-2023
 * @last modified by  : Bon Karlo Pacante
**/
@isTest
public class AddHomesToChecklistLWC_Test{
    
    public static testmethod void AddHomesToChecklistLWCTest(){
        
        City__c c = new City__c();
        c.Name = 'Seattle';
        insert c;
        
        Brand__c br = new Brand__c(
            Name = 'Test Brand',
            APINameBrand__c = 'Test Brand API'
        );
        insert br;
        
        Property__c h = new Property__c();
        h.Name = 'test';
        h.City_object__c = c.id;
        h.Home_Manager_User__c = userinfo.getUserId();
        h.BrandRef__c = br.Id;
        insert h;
        
        Checklist_Setup__c ChecklistSetup = new Checklist_Setup__c ();
        ChecklistSetup.Checklist_Name__c = 'Test Checklist Setup';
        ChecklistSetup.Unit_Type__c = 'All Unit Types';
        ChecklistSetup.Task_Type__c = 'CSS - Property Services Move In Task Template';
        insert ChecklistSetup;
        
        Checklist_Homes__c ch = new Checklist_Homes__c();
        ch.Home__c = h.Id;
        ch.Checklist_Setup__c = ChecklistSetup.Id;
        insert ch;
        
        test.startTest();
            AddHomesToChecklistLWC.HomesWrapper wrapper = new AddHomesToChecklistLWC.HomesWrapper();
            wrapper = AddHomesToChecklistLWC.fetchHomesList(ChecklistSetup.Id);
            list<Property__c> Homes = new list<Property__c>();
            Homes.add(h);
            AddHomesToChecklistLWC.createChecklistHomes(ChecklistSetup.Id, Homes);
        test.stopTest();
    }
}