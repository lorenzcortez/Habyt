@IsTest
public class PersonAccountService_Test {
    @TestSetup
    static void setupTest() {
        List<Account> accounts = new List<Account>{
            TestRecord_Factory.createAccount(), TestRecord_Factory.createAccount()
        };
        insert accounts;

        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc = TestRecord_Factory.iStripe_Account;

        List<Contract> contractsToInsert = new List<Contract>();
        Contract contract = TestRecord_Factory.createContract(accounts[0].Id, opp.Id, room.Id, stripeAcc.Id);
        contractsToInsert.add(contract);

        Contract contract2 = TestRecord_Factory.createContract(accounts[1].Id, opp.Id, room.Id, stripeAcc.Id);
        contractsToInsert.add(contract2);

        insert contractsToInsert;

        Account personDefaultAccount = [SELECT Id, personEmail FROM Account WHERE Id = :opp.AccountId];
        personDefaultAccount.PersonEmail = 'test' + personDefaultAccount.PersonEmail;
        update personDefaultAccount;
    }

    @IsTest
    static void getCustomerRecordType_UnitTest(){
        RecordType expected = [
            SELECT Id, Name, DeveloperName 
            FROM RecordType 
            WHERE SObjectType = 'Account' AND DeveloperName = :PersonAccountService.RT_CUSTOMER
        ];

        PersonAccountService service = new PersonAccountService();

        Test.startTest();

        RecordType actual = service.getCustomerRecordType();

        Test.stopTest();

        System.assertEquals(expected, actual, 'Result mismatch');
    }

    @IsTest
    static void validateExisting_Existing_UnitTest(){
        PersonAccountService service = new PersonAccountService();

        RecordType customerRT = service.getCustomerRecordType();

        Account personAccount = new Account(
            RecordTypeId = customerRT.Id,
            PersonEmail = TestRecord_Factory.iPersonAccount.PersonEmail
        );

        Test.startTest();

        personAccount = service.validateExisting(personAccount);

        Test.stopTest();
        
        System.assertEquals(TestRecord_Factory.iPersonAccount.Id, personAccount.Id, 'Existing record was not succesfully found');
    }

    @IsTest
    static void validateExisting_NonExisting_UnitTest(){
        PersonAccountService service = new PersonAccountService();

        RecordType customerRT = service.getCustomerRecordType();

        Account personAccount = new Account(RecordTypeId = customerRT.Id, PersonEmail = 'notfound@example.com');

        Test.startTest();

        personAccount = service.validateExisting(personAccount);

        Test.stopTest();
        
        System.assertEquals(null, personAccount.Id, 'Existing record was wrongly found');
    }

    @IsTest
    static void filterAccountsNoMembership_UnitTest(){
        List<Account> allAccounts = [SELECT Id, (SELECT Id, Status, RecordTypeId FROM Contracts) FROM Account];
        Integer expected = allAccounts.size() - 1;

        Contract contract = allAccounts[0].Contracts[0];
        contract.RecordTypeId = CustomerContractService.RT_ID_MEMBERSHIP;
        contract.Status = CustomerContractService.STATUS_ACTIVATED;
        update contract;

        PersonAccountService service = new PersonAccountService();

        Test.startTest();

        allAccounts = service.filterAccountsNoMembership(allAccounts);

        Test.stopTest();

        System.assertEquals(expected, allAccounts.size(), 'Size mismatch');
    }
}