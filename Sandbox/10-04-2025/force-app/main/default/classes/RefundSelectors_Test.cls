@IsTest
public with sharing class RefundSelectors_Test {
    public static final Integer REFUNDS_NUMBER = 5;
    public static final String STRIPE_TEST_ID_HEAD = 'dispute_';

    @TestSetup
    static void setupTest(){
        List<Refund__C> refunds = new List<Refund__C>();
        Integer counter = REFUNDS_NUMBER;
        while (counter > 0) {
            refunds.add(new Refund__C(StripeRefundId__c = STRIPE_TEST_ID_HEAD + counter));
            counter--;
        }
        insert refunds;
    }

    @IsTest
    static void ByStripeId_Test() {
        Set<String> ids = new Set<String>{'dispute_1', 'dispute_2', 'dispute_3', 'dispute_4', 'dispute_5'};

        List<Refund__C> refunds = [SELECT Id FROM Refund__C];
        Integer expectedSize = refunds.size();

        Test.startTest();
        refunds = (List<Refund__C>) Paua_SelectorHandler.getSelector(RefundSelectors.ByStripeId.class)
                                                                  .setParameter('idSet', ids)
                                                                  .query();
        Test.stopTest();

        System.assertEquals(expectedSize, refunds.size());
    }
}