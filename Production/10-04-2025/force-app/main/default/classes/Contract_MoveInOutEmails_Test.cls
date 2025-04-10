@IsTest
public class Contract_MoveInOutEmails_Test {
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

        List<Contract> contractsToInsert = new List<Contract>();
        Contract contract = TestRecord_Factory.createContract(account1.Id, opp.Id, room.Id, stripeAcc.Id);
        contractsToInsert.add(contract);

        Contract contract2 = TestRecord_Factory.createContract(account2.Id, opp.Id, room.Id, stripeAcc.Id);
        contractsToInsert.add(contract2);

        Contract contract3 = TestRecord_Factory.createContract(account3.Id, opp.Id, room.Id, stripeAcc.Id);
        contractsToInsert.add(contract3);

        insert contractsToInsert;
    }

    @IsTest
    static void afterUpdate_unitTest(){
      CustomerContractService contractService = new CustomerContractService();
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
            property.BrandRef__c = brand.Id;
            update property;

            Room__c room = [SELECT Id FROM Room__c LIMIT 1];
            room.Property__c = property.Id;
            room.TypePick__c = 'Shared Room (2 beds)';
            update room;

            List<Account> accounts = [SELECT Id, PersonEmail FROM Account LIMIT 3];
            List<Contract> contracts = [
                SELECT Contract_End_Date__c, StartDate, Status, Room__c, Opportunity__r.BrandRef__r.MoveInTemplateName__c,
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
            
            Test.startTest();

            Contract contract = contracts[0];
            contract.Room__c = room.Id;
            contract.Status = CustomerContractService.STATUS_SIGNED;
            contract.Contract_End_Date__c = null;
            contract.StartDate = System.today();
            contract.AccountId = accounts[0].Id;
            update contract;

            Contract contract2 = contracts[1];
            contract2.Room__c = room.Id;
            contract2.Status = CustomerContractService.STATUS_SIGNED;
            contract2.Contract_End_Date__c = null;
            contract2.StartDate = System.today();
            contract2.AccountId = accounts[1].Id;
            update contract2;

            Contract contract3 = contracts[2];
            contract3.Room__c = room.Id;
            contract3.Status = CustomerContractService.STATUS_SIGNED;
            contract3.Contract_End_Date__c = null;
            contract3.StartDate = System.today();
            contract3.AccountId = accounts[2].Id;
            update contract3;

            // check that activated -> signed does not trigger email
            contract3.Status = CustomerContractService.STATUS_ACTIVATED; 
            update contract3;

            // check if terminated status triggers an email. Resulting in 2. email call
            contract2.Status = CustomerContractService.STATUS_TERMINATED;
            update contract2;

            Test.stopTest();

            // TODO: come up with a proper way of asserting results. 
            //       Issue with simply checking email invocations is other processes may be sending emails as well.
        }
    }

}