@isTest
private class Test_LWC_MCEmailHTMLViewerController  {

    @isTest
    static void testGetTaskEmailHtml() {
        MC_Email_Activity__c mc = new MC_Email_Activity__c();
        mc.MC_Email_Raw_HTML__c = '<p>Test HTML Body</p>';
        insert mc;
        
        // Create a test Task record
        Task testTask = new Task(
            Subject = 'Test Task',
            ActivityDate = Date.today(),
            Status = 'Completed',
            MC_Email_Activity__c = mc.id
        );
        insert testTask;


        // Call the method in the TaskController to get the Email HTML
        String emailHtml = LWC_MCEmailHTMLViewerController.getTaskEmailHtml(testTask.Id);

        // Assert that the returned Email HTML is as expected
        System.assertEquals('<p>Test HTML Body</p>', emailHtml, 'Incorrect Email HTML');

    }
}