@IsTest
public with sharing class DepositService_Test {
    @TestSetup
    static void setupTest(){
        List<Deposit__c> deposits = new List<Deposit__c>();

        deposits.add(new Deposit__c());
        deposits.add(new Deposit__c());
        deposits.add(new Deposit__c());

        insert deposits;
    }

    @IsTest
    static void getWithNewRelevantStatus_UnitTest() {
        Integer expectedSize = 3;
        List<Deposit__c> deposits = [SELECT Id, Status__c FROM Deposit__c LIMIT 3];

        Deposit__c deposit1 = deposits.get(0); 
        Deposit__c deposit2 = deposits.get(1);
        Deposit__c deposit3 = deposits.get(2);

        Map<Id, Deposit__c> oldMap = new Map<Id, Deposit__c>();
        oldMap.put(deposit1.Id, new Deposit__c(Status__c=DepositService.STATUS_SUBMITTED));
        oldMap.put(deposit2.Id, new Deposit__c(Status__c=DepositService.STATUS_SUBMITTED));
        oldMap.put(deposit3.Id, new Deposit__c(Status__c=DepositService.STATUS_SUBMITTED));

        deposit1.Status__c = DepositService.STATUS_APPROVED;
        deposit2.Status__c = DepositService.STATUS_APPROVED;
        deposit3.Status__c = DepositService.STATUS_APPROVED;

        update deposits;

        Test.startTest();
        List<Deposit__c> relevantDeposits =  new DepositService().getWithNewRelevantStatus(
            deposits, oldMap, DepositService.STATUS_SUBMITTED, DepositService.STATUS_APPROVED
        );
        Test.stopTest();

        System.assertEquals(expectedSize, relevantDeposits.size(), 'Filtered deposits size unexpected');
    }

    @IsTest
    static void generateDepositFile_UnitTest() {
        List<Deposit__c> deposits = [SELECT Id FROM Deposit__c];
        Integer expectedSize = deposits.size();

        Set<Id> ids = (new Map<Id, SObject>(deposits)).keySet();

        Test.startTest();
        new DepositService().generateDepositFile(deposits);
        Test.stopTest();

        Integer documentsSize = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId IN :ids];

        System.assertEquals(expectedSize, documentsSize, 'Filtered deposits size unexpected');
    }

}