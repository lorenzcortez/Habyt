@IsTest
public class HousingConfirmationQueueable_Test {
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
    static void execute_UnitTest() {
        Integer expectedNumberAttachments = 1;
        String expectedStatus = 'Completed';

        Brand__c brand = [SELECT Id, APINameBrand__c FROM Brand__C LIMIT 1];
        EmailTemplate emailTemplate = new EmailTemplate(
            DeveloperName = CustomerContractService.CONFIRMATION_EMAIL_TEMPLATE_NAME + '_' + brand.APINameBrand__c, 
            FolderId = UserInfo.getUserId(), 
            TemplateType = 'Text', 
            Name = CustomerContractService.CONFIRMATION_EMAIL_TEMPLATE_NAME + '_' + brand.APINameBrand__c,
            IsActive = true
        );
        insert emailTemplate;

        User currentUser = new User(Id = UserInfo.getUserId());
        System.runAs(currentUser) {
            List<Contract> contracts = [SELECT Id FROM Contract LIMIT 2];
            contracts[0].StartDate = System.today();
            contracts[0].Contract_End_Date__c = System.today();
            contracts[1].StartDate = System.today();
            contracts[1].Status = CustomerContractService.STATUS_CANCELLED;
            update contracts;

            Test.startTest();
            System.enqueueJob(new HousingConfirmationQueueable());
            Test.stopTest();
    
            List<AsyncApexJob> jobsScheduled = [
                SELECT Id, ApexClass.Name, Status, JobType 
                FROM AsyncApexJob 
                WHERE JobType = 'Queueable'
            ];
    
            Integer countContentVersions = [
                SELECT COUNT()
                FROM ContentVersion
                WHERE (FirstPublishLocationId = :contracts[0].Id) OR (FirstPublishLocationId = :contracts[1].Id)
            ];
            System.assertEquals(1, jobsScheduled.size(), 'Expecting one queueable job');
            System.assertEquals(expectedStatus, jobsScheduled[0].Status, 'Job should be ' + expectedStatus);
            System.assertEquals(expectedNumberAttachments, countContentVersions, 'Unexpected number of attachments');
        }
    }
}