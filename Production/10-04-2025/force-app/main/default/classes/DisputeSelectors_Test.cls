@IsTest
public with sharing class DisputeSelectors_Test {
    public static final Integer DISPUTES_NUMBER = 5;
    public static final String STRIPE_TEST_ID_HEAD = 'dispute_';

    @TestSetup
    static void setupTest(){
        List<Dispute__c> disputes = new List<Dispute__c>();
        Integer counter = DISPUTES_NUMBER;
        while (counter > 0) {
            disputes.add(new Dispute__c(StripeDisputeId__c = STRIPE_TEST_ID_HEAD + counter));
            counter--;
        }
        insert disputes;
    }

    @IsTest
    static void ByStripeId_Test() {
        Set<String> ids = new Set<String>{'dispute_1', 'dispute_2', 'dispute_3', 'dispute_4', 'dispute_5'};

        List<Dispute__c> disputes = [SELECT Id FROM Dispute__c];
        Integer expectedSize = disputes.size();

        Test.startTest();
        disputes = (List<Dispute__c>) Paua_SelectorHandler.getSelector(DisputeSelectors.ByStripeId.class)
                                                                  .setParameter('idSet', ids)
                                                                  .query();
        Test.stopTest();

        System.assertEquals(expectedSize, disputes.size());
    }
}