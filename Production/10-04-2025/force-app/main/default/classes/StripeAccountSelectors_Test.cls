@IsTest
public with sharing class StripeAccountSelectors_Test {
    private static final String TEST_NAME = 'Habyt Germany GmbH';
    private static final String TEST_SECRET_KEY = 'pk_test_51HTpVAI4AG1fjzDfOdO8AQJCoS00RpwPdZD8';

    @TestSetup
    static void setupTest() {
        insert new Stripe_Account__c(Name = TEST_NAME, secret_key__c = TEST_SECRET_KEY);
    }

    @IsTest
    public static void byPersonEmail_UnitTest() {
        Integer expectedSize = 1;

        Test.startTest();
        List<Stripe_Account__c> accounts = (List<Stripe_Account__c>) Paua_SelectorHandler.getSelector(StripeAccountSelectors.ByName.class)
                                            .setParameter('accountName', TEST_NAME)
                                            .query();
        Test.stopTest();

        System.assertEquals(expectedSize, accounts.size(), 'Size mismatch');
    }
}