@IsTest
public class ContractSendMoveEmailsSchedulable_Test {
    @IsTest
    static void execute_UnitTest() {
        String className = 'ContractSendMoveEmailsSchedulable';
        String expectedStatusScheduled = 'Queued';
        String expectedStatusQueued = 'Queued';
        String cronExpr = '0 0 12 ? * * *';

        Test.startTest();
        System.schedule(className, cronExpr, new ContractSendMoveEmailsSchedulable());
        Test.stopTest();

        List<AsyncApexJob> jobsScheduled = [
            SELECT Id, ApexClass.Name, Status, JobType 
            FROM AsyncApexJob 
            WHERE JobType = 'ScheduledApex'
        ];
        System.assertEquals(1, jobsScheduled.size(), 'Expecting one scheduled job');
        System.assertEquals(className, jobsScheduled[0].ApexClass.Name, 'Expecting specific scheduled job');
        System.assertEquals(expectedStatusScheduled, jobsScheduled[0].Status, 'Job should be Queued');

        jobsScheduled = [
            SELECT Id, ApexClass.Name, Status, JobType 
            FROM AsyncApexJob 
            WHERE JobType = 'Queueable'
        ];
        System.assertEquals(1, jobsScheduled.size(), 'Expecting one queueable job');
        System.assertEquals(expectedStatusQueued, jobsScheduled[0].Status, 'Job should be Queued');

    }
}