@IsTest
private class ContractMigrationBatchTest {

    static Map<String, ContractStatusMapping__mdt> contractStatusMappingMap = ContractStatusMapping__mdt.getAll();

    @TestSetup
    static void createData(){
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;

        Billing_Entity__c holdingBillingEntity = TestRecord_Factory.createBilling_Entity();
        holdingBillingEntity.TypePick__c = CustomerContractService.BILLING_ENTITY_TYPE_HOLDING;
        insert holdingBillingEntity;

        Condition__c condition = TestRecord_Factory.iCondition;
        update new Property__c(Id = room.Property__c, Billing_Entity__c = condition.BillingEntityRef__c, ConditionRef__c = condition.Id);
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;
        update new Billing_Entity__c(Id = condition.BillingEntityRef__c, Stripe_Account__c = stripeAcc.Id);

        Product2 product2 = TestRecord_Factory.iProduct2;
        product2.Name = 'Rent';
        update product2;
        product2 = TestRecord_Factory.createProduct2();
        product2.Name = 'Permanent Discount';
        insert product2;

        Opportunity opportunity = TestRecord_Factory.iOpportunity;
        opportunity.ReprocessedStatusPick__c = 'Open';
        opportunity.BillingEntity__c = condition.BillingEntityRef__c;
        opportunity.Room__c = room.Id;
        opportunity.Monthly_Price__c = room.Price__c - 10;
        update opportunity;

        OpportunityLineItem oli = TestRecord_Factory.iOpportunityLineItem;
        oli.RoomRef__c = room.Id;
        oli.UnitPrice = room.Price__c - 10;
        update oli;
    }

    @IsTest
    static void testContractMigrationBatchActive() {
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE ReprocessedStatusPick__c = 'Open'];
        opportunity.ContractStatus__c = 'signed';
        update opportunity;

        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());
        Test.startTest();
        Database.executeBatch(new ContractMigrationBatch(Date.newInstance(2021,10,1)));
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Contract WHERE Opportunity__c = :opportunity.Id]);
        System.assertEquals('Contracts Processed', [SELECT Id, ReprocessedStatusPick__c FROM Opportunity WHERE Id = :opportunity.Id LIMIT 1].ReprocessedStatusPick__c);
    }

    @IsTest
    static void testContractMigrationBatchVoided() {
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE ReprocessedStatusPick__c = 'Open'];
        opportunity.ContractStatus__c = 'revoked';
        update opportunity;

        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());
        Test.startTest();
        Database.executeBatch(new ContractMigrationBatch(Date.newInstance(2021,10,1)));
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Contract WHERE Opportunity__c = :opportunity.Id]);
        System.assertEquals('Done', [SELECT Id, ReprocessedStatusPick__c FROM Opportunity WHERE Id = :opportunity.Id LIMIT 1].ReprocessedStatusPick__c);
    }

}