@IsTest
public class ContractSendMoveEmailsQueueable_Test {
    @TestSetup
    static void setupTest() {
        List<Account> accounts = new List<Account>();
        Account account1 = TestRecord_Factory.createPersonAccount();
        account1.PersonEmail = 'test1@test.com';
        accounts.add(account1);

        Account account2 = TestRecord_Factory.createPersonAccount();
        account2.PersonEmail = 'test2@test.com';
        accounts.add(account2);

        Account account3 = TestRecord_Factory.createPersonAccount();
        account3.PersonEmail = 'test3@test.com';
        accounts.add(account3);
        insert accounts;

        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc = TestRecord_Factory.iStripe_Account;
        Brand__c brand = TestRecord_Factory.iBrand;
        Property__c property = TestRecord_Factory.iProperty;

        Billing_Entity__c holdingBillingEntity = TestRecord_Factory.createBilling_Entity(); 
        holdingBillingEntity.TypePick__c = CustomerContractService.BILLING_ENTITY_TYPE_HOLDING;
        insert holdingBillingEntity;

        List<Contract> contractsToInsert = new List<Contract>();
        Contract contract = TestRecord_Factory.createContract(account1.Id, opp.Id, room.Id, stripeAcc.Id);
        contract.RecordTypeId = CustomerContractService.RT_ID_RENT;
        contractsToInsert.add(contract);

        Contract contract2 = TestRecord_Factory.createContract(account2.Id, opp.Id, room.Id, stripeAcc.Id);
        contract2.RecordTypeId = CustomerContractService.RT_ID_RENT;
        contractsToInsert.add(contract2);

        Contract contract3 = TestRecord_Factory.createContract(account3.Id, opp.Id, room.Id, stripeAcc.Id);
        contract3.RecordTypeId = CustomerContractService.RT_ID_RENT;
        contractsToInsert.add(contract3);

        insert contractsToInsert;
    }

    @IsTest
    static void execute_UnitTest() {
        CustomerContractService contractService = new CustomerContractService();
        Integer expected = 1;
        Date endDate = System.today().addDays(2 * CustomerContractService.MOVE_IN_DAYS);
        Date startDate = System.today().addDays(-CustomerContractService.MOVE_IN_DAYS);

        Brand__c brand = [SELECT Id, MoveEmailNotifications__c, MoveInTemplateName__c, MoveOutTemplateName__c FROM Brand__C LIMIT 1];
        List<EmailTemplate> templates = new List<EmailTemplate>();
        EmailTemplate emailTemplate1 = new EmailTemplate(
            DeveloperName = brand.MoveInTemplateName__c, 
            FolderId = UserInfo.getUserId(), 
            TemplateType='Text', 
            Name = brand.MoveInTemplateName__c,
            IsActive = true
        );
        templates.add(emailTemplate1);

        EmailTemplate emailTemplate2 = new EmailTemplate(
            DeveloperName = brand.MoveOutTemplateName__c, 
            FolderId = UserInfo.getUserId(), 
            TemplateType='Text', 
            Name = brand.MoveOutTemplateName__c,
            IsActive = true
        );
        templates.add(emailTemplate2);
        insert templates;

        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(currentUser) {
            brand.MoveEmailNotifications__c = 'Move-In;Move-Out';
            update brand;

            Property__c property = [
                SELECT Id, BrandRef__c, BrandRef__r.MoveEmailNotifications__c, Property_Type__c 
                FROM Property__c 
                LIMIT 1
            ];

            Room__c room = [SELECT Id FROM Room__c LIMIT 1];
            room.Property__c = property.Id;
            room.TypePick__c = 'Shared Room (2 beds)';
            update room;

            List<Account> accounts = [SELECT Id, PersonEmail FROM Account LIMIT 3];
            List<Contract> contracts = [
                SELECT Contract_End_Date__c, Country__c, StartDate, Status, Room__c, Opportunity__r.BrandRef__r.MoveInTemplateName__c,
                       Opportunity__r.BrandRef__r.MoveOutTemplateName__c, Opportunity__r.BrandRef__r.MoveEmailNotifications__c,
                       Opportunity__r.BrandAuto__c, Room__r.Property__r.Property_Type__c, Account.PersonEmail, AccountId, 
                       Account.Name, Account.FirstName, Account.LastName, Account.PersonContactId
                FROM Contract 
                LIMIT 3
            ];

            accounts[0].PersonEmail = 'test1@test.com';
            accounts[1].PersonEmail = 'test2@test.com';
            accounts[2].PersonEmail = 'test3@test.com';
            update accounts;
            
            // All contracts must be updated separately, otherwise an exception is thrown.
            Contract contract = contracts[0];
            contract.Room__c = room.Id;
            contract.Status = CustomerContractService.STATUS_SIGNED;
            contract.Contract_End_Date__c = System.today().addDays(CustomerContractService.MOVE_IN_DAYS);
            contract.StartDate = System.today().addDays(-CustomerContractService.MOVE_IN_DAYS);
            contract.AccountId = accounts[0].Id;
            update contract; 

            Contract contract2 = contracts[1];
            contract2.Room__c = room.Id;
            contract2.Status = CustomerContractService.STATUS_ACTIVATED;
            contract2.Contract_End_Date__c = System.today().addDays(2 * CustomerContractService.MOVE_IN_DAYS);
            contract2.StartDate = System.today().addDays(-CustomerContractService.MOVE_IN_DAYS);
            contract2.AccountId = accounts[1].Id;
            update contract2;

            Contract contract3 = contracts[2];
            contract3.Room__c = room.Id;
            contract3.Status = CustomerContractService.STATUS_ACTIVATED;
            contract3.Contract_End_Date__c = System.today().addDays(CustomerContractService.MOVE_IN_DAYS);
            contract3.StartDate = System.today().addDays(CustomerContractService.MOVE_IN_DAYS);
            contract3.AccountId = accounts[2].Id;
            update contract3;

            ContractSendMoveEmailsQueueable queueable = new ContractSendMoveEmailsQueueable();
            Test.startTest();
            queueable.execute(null); 
            Integer invocations = Limits.getEmailInvocations();
            Test.stopTest();

           // System.assertEquals(expected, invocations, 'Number of emails unexpected');       
        }
    }
}