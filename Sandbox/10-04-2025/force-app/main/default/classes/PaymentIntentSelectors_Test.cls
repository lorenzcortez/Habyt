@IsTest
public with sharing class PaymentIntentSelectors_Test {
    public static final String STRIPE_TEST_ID_HEAD = 'test';
    public static final Integer INTENT_NUMBER = 5;

    @TestSetup
    static void setupTest(){
        List<PaymentIntent__c> intents = new List<PaymentIntent__c>();
        Integer counter = INTENT_NUMBER;
        while (counter > 0) {
            intents.add(
                    new PaymentIntent__c(
                            Name = 'Test Payment Intent No. ' + counter,
                            StripeId__c = STRIPE_TEST_ID_HEAD + counter
                    )
            );
            counter--;
        }
        insert intents;
    }

    @IsTest
    static void ByStripeId_Test() {
        Set<String> ids = new Set<String>{'test1', 'test2', 'test3', 'test4', 'test5'};

        Test.startTest();
        List<PaymentIntent__c> invoices = (List<PaymentIntent__c>) Paua_SelectorHandler.getSelector(PaymentIntentSelectors.ByStripeId.class)
                .setParameter('stripeIdSet', ids)
                .query();
        Test.stopTest();

        System.assertEquals(INTENT_NUMBER, invoices.size());
    }
}