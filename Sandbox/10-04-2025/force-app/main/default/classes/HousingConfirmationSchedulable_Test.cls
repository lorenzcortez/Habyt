@IsTest
public class HousingConfirmationSchedulable_Test {
    @TestSetup
    static void setupTest(){
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        List<Contract> contractsToInsert = new List<Contract>();
        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        contractsToInsert.add(contract);

        Contract contract2 = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        contractsToInsert.add(contract2);

        insert contractsToInsert;
    }

    @IsTest
    static void scheduling_UnitTest() {
        String className = 'HousingConfirmationSchedulable';
        String expectedStatusScheduled = 'Queued';
        String expectedStatusQueued = 'Queued';
        String cronExpr = '0 0 12 ? * * *';

        Test.startTest();
        System.schedule(className, cronExpr, new HousingConfirmationSchedulable());
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
        System.debug([SELECT COUNT() FROM ContentVersion]);
        System.assertEquals(1, jobsScheduled.size(), 'Expecting one queueable job');
        System.assertEquals(expectedStatusQueued, jobsScheduled[0].Status, 'Job should be Queued');
    }

    @IsTest
    static void execute_UnitTest() {
        Integer expectedNumberAttachments = 1;
        String expectedStatus = 'Completed';
        List<Contract> contracts = [SELECT Id FROM Contract LIMIT 2];
        contracts[0].StartDate = System.today();
        contracts[0].Contract_End_Date__c = System.today();
        contracts[1].StartDate = System.today();
        contracts[1].Status = CustomerContractService.STATUS_CANCELLED;
        update contracts;

        Test.startTest();
        HousingConfirmationSchedulable confirmationSchedulable = new HousingConfirmationSchedulable();
        confirmationSchedulable.execute(null);
        Test.stopTest();

        Integer countContentVersions = [
            SELECT COUNT()
            FROM ContentVersion
            WHERE (FirstPublishLocationId = :contracts[0].Id) OR (FirstPublishLocationId = :contracts[1].Id)
        ];
        System.assertEquals(expectedNumberAttachments, countContentVersions, 'Unexpected number of attachments');
    }
}