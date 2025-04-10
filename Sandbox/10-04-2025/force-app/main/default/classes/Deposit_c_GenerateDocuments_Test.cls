@IsTest
public with sharing class Deposit_c_GenerateDocuments_Test {
    
    @TestSetup
    static void setupTest(){
        List<Deposit__c> deposits = new List<Deposit__c>();

        deposits.add(new Deposit__c(Status__c=DepositService.STATUS_SUBMITTED));
        deposits.add(new Deposit__c(Status__c=DepositService.STATUS_SUBMITTED));
        deposits.add(new Deposit__c(Status__c=DepositService.STATUS_SUBMITTED));

        insert deposits;
    }

    @IsTest
    static void generateDepositFile_UnitTest() {
        List<Deposit__c> deposits = [SELECT Id, Status__c FROM Deposit__c];
        Set<Id> ids = (new Map<Id, SObject>(deposits)).keySet(); 
        Integer expectedSize = deposits.size();

        for(Deposit__c deposit : deposits) {
            deposit.Status__c = DepositService.STATUS_APPROVED;
        }

        Test.startTest();
        update deposits;
        Test.stopTest();

        Integer documentsSize = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId IN :ids];

        System.assertEquals(expectedSize, documentsSize, 'Filtered deposits size unexpected');
    }

}