@IsTest
private class ContractMigratedScheduledBatchTest {
    @IsTest
    static void testSchedule() {
        Test.startTest();
        System.schedule('Test', '0 0 * * * ?',new ContractMigratedScheduledBatch());
        Test.stopTest();
    }

    @IsTest
    static void testCanceledContract() {
        Opportunity opportunity = TestRecord_Factory.iOpportunity;
        opportunity.ReprocessedStatusPick__c = 'Email Sent';
        update opportunity;

        Stripe_Account__c stripeAccount = new Stripe_Account__c(secret_key__c = 'test_key');
        insert stripeAccount;
        Account acc = new Account(LastName = 'TestAcc');
        insert	acc;
        Contract con = new Contract(AccountId = acc.Id, Status = 'Draft', StartDate = Date.today(), ContractTerm = 6, Stripe_Subscription_Id__c = 'sub_TEST', Stripe_Account__c = stripeAccount.Id, Opportunity__c = opportunity.Id, Contract_End_Date__c = Date.today());
        insert con;
        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());
        Test.startTest();
        Database.executeBatch(new ContractMigratedScheduledBatch(), 1);
        Test.stopTest();
        System.assertEquals('Done', [SELECT Id, ReprocessedStatusPick__c FROM Opportunity WHERE Id = :opportunity.Id].ReprocessedStatusPick__c);
    }

    @IsTest
    static void testContract() {
        Opportunity opportunity = TestRecord_Factory.iOpportunity;
        opportunity.ReprocessedStatusPick__c = 'Email Sent';
        update opportunity;

        Stripe_Account__c stripeAccount = new Stripe_Account__c(secret_key__c = 'test_key');
        insert stripeAccount;
        Account acc = new Account(LastName = 'TestAcc');
        insert	acc;
        Contract con = new Contract(AccountId = acc.Id, Status = 'Draft', StartDate = Date.today(), ContractTerm = 6, Stripe_Subscription_Id__c = 'sub_TEST', Stripe_Account__c = stripeAccount.Id, Opportunity__c = opportunity.Id);
        insert con;
        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());
        Test.startTest();
        Database.executeBatch(new ContractMigratedScheduledBatch(), 1);
        Test.stopTest();
        System.assertEquals('Done', [SELECT Id, ReprocessedStatusPick__c FROM Opportunity WHERE Id = :opportunity.Id].ReprocessedStatusPick__c);
    }
}