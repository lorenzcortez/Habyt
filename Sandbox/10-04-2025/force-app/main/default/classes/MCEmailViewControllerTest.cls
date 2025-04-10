@isTest
private class MCEmailViewControllerTest {
    @isTest
    static void testMCEmailViewController() {
        
        MC_Email_Activity__c mc = new MC_Email_Activity__c();
        mc.MC_Email_Raw_HTML__c = '<p>This is a test HTML body.</p>';
        insert mc;
        // Create a test Task record
        Task testTask = new Task(
            Subject = 'Test Task',
            MC_Email_Activity__c = mc.id
        );
        insert testTask;

        // Set the current page parameters for the test
        ApexPages.currentPage().getParameters().put('id', testTask.Id);

        // Instantiate the controller
        MCEmailViewController controller = new MCEmailViewController();

        // Verify that the htmlBody property is set correctly
        System.assertEquals('<p>This is a test HTML body.</p>', controller.htmlBody);
    }
}