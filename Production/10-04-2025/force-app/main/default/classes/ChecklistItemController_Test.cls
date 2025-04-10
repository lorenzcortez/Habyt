@istest
public class ChecklistItemController_Test{

    public static testmethod void ChecklistComponentTest(){
    
        Task t = new Task();
        t.Subject = 'test';
        t.ActivityDate = system.today();
        t.Description = 'Call Disposition: sdsd\n';
        t.recordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('Real Estate Task').getRecordTypeId();
        insert t;
        
        list<Sub_Task__c> Checklists = new list<Sub_Task__c>();
        
        Sub_Task__c checklist1 = new Sub_Task__c();
        checklist1.Name = 'Test Check list 1';
        checklist1.Task_ID__c = t.Id;
        checklist1.Is_Completed__c = true;
        Checklists.add(Checklist1);
        
        Sub_Task__c checklist2 = new Sub_Task__c();
        checklist2.Name = 'Test Check list 2';
        checklist2.Task_ID__c = t.Id;
        Checklists.add(Checklist2);
        
        Sub_Task__c checklist3 = new Sub_Task__c();
        checklist3.Name = 'Test Check list 3';
        checklist3.Task_ID__c = t.Id;
        Checklists.add(Checklist3);
        
        
        Sub_Task__c checklist4 = new Sub_Task__c();
        checklist4.Name = 'Test Check list 4';
        checklist4.Task_ID__c = t.Id;
        
        Checklists.add(Checklist4);
        
        insert Checklists;
        
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
 
        // Test INSERT
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink f = [select id,LinkedEntityId,ContentDocumentId,ShareType,Visibility from ContentDocumentLink where ContentDocumentId =:documents[0].ID];
        ContentDocumentLink nf = new ContentDocumentLink();
        nf.LinkedEntityId = Checklists[1].Id;
        nf.ContentDocumentId = f.ContentDocumentId;
        nf.ShareType = f.ShareType;
        nf.Visibility  = f.Visibility;
        insert nf;
        
        list<string> fileids = new list<string>();
        fileids.add(documents[0].id);
        
        ChecklistItemController.CloneFiletoParentTask(fileids,t.id);
        ChecklistItemController.fetchItems(t.Id);
        ChecklistItemController.getContentDocs(Checklists[1].Id);
        ChecklistItemController.SaveCompletedChecklist(Checklists[1].Id, t.Id, 1, 'njwdna', true);
        ChecklistItemController.SaveOpenChecklist(Checklists[1].Id, t.Id);
        ChecklistItemController.RecaculateParentTaskStatus(t.Id);
        
    }
}