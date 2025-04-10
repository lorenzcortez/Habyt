@IsTest
public class ContractsVoidEversignQueueable_Test {
   @IsTest
    static void execute_UnitTest() {
        Set<String> hashes = new Set<String> {'dochashtest'};
        String expectedStatus = 'Completed';

        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
        Test.startTest();
        System.enqueueJob(new ContractsVoidEversignQueueable(hashes));
        Test.stopTest();

        List<AsyncApexJob> jobsScheduled = [
            SELECT Id, ApexClass.Name, Status, JobType 
            FROM AsyncApexJob 
            WHERE JobType = 'Queueable'
        ];
        System.assertEquals(1, jobsScheduled.size(), 'Expecting one queueable job');
        System.assertEquals(expectedStatus, jobsScheduled[0].Status, 'Job should be ' + expectedStatus);
    }
}