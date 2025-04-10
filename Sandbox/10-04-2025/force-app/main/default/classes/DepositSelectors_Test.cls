@IsTest
public with sharing class DepositSelectors_Test {
    public static final Integer DEPOSITS_NUMBER = 5;
    public static final String STRIPE_TEST_ID_HEAD = 'deposit_';

    @TestSetup
    static void setupTest(){
        List<Deposit__c> deposits = new List<Deposit__c>();
        Integer counter = DEPOSITS_NUMBER;
        while (counter > 0) {
            deposits.add(new Deposit__c(Name = STRIPE_TEST_ID_HEAD + counter));
            counter--;
        }
        insert deposits;
    }

    @IsTest
    static void ById_Test() {
        List<Deposit__c> deposits = [SELECT Id FROM Deposit__c];
        Integer expectedSize = deposits.size();

        Set<Id> ids = new Set<Id>{
            deposits.get(0).Id, deposits.get(1).Id, deposits.get(2).Id, deposits.get(3).Id, deposits.get(4).Id
        };

        Test.startTest();
        deposits = (List<Deposit__c>) Paua_SelectorHandler.getSelector(DepositSelectors.ById.class)
                                                                  .setParameter('idSet', ids)
                                                                  .query();
        Test.stopTest();

        System.assertEquals(expectedSize, deposits.size());
    }
}