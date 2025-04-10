@isTest
public class FeedCommentTrigger_Test{
    
    public static testmethod void TestTrigger(){
        
        Id cssRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CSS - Property Issue').getRecordTypeId();
        
        Case c = new Case();
        c.subject = 'test';
        c.RecordTypeId = cssRecordTypeId;
        c.SuppliedEmail = 'members@common.com';
        c.Description = 'development@einsteam.com';
        c.Status = 'New';
        insert c;
        
        FeedItem f = new FeedItem();
        f.ParentId = c.Id;
        f.body = 'test';
        insert f;
        
        c.Status = 'Solved';
        c.Spam__c = true;
        update c;
        
        Test.StartTest();
            FeedComment fc = new FeedComment();
            fc.CommentBody = 'legal test';
            fc.FeedItemId = f.Id;
            insert fc;
        Test.StopTest();
    }
}