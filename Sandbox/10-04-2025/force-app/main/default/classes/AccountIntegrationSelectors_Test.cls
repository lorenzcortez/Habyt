@IsTest
public with sharing class AccountIntegrationSelectors_Test {
    private static final String TEST_PERSON_EMAIL = 'test@mail.com';

    @TestSetup
    static void setupTest() {
        Account account = TestRecord_Factory.iPersonAccount;
        account.PersonEmail = TEST_PERSON_EMAIL;
        update account;
    }

    @IsTest
    public static void byPersonEmail_UnitTest() {
        Integer expectedSize = 1;

        Test.startTest();
        List<Account> accounts = (List<Account>) Paua_SelectorHandler.getSelector(AccountIntegrationSelectors.ByPersonEmail.class)
                                            .setParameter('personEmail', TEST_PERSON_EMAIL)
                                            .query();
        Test.stopTest();

        System.assertEquals(expectedSize, accounts.size(), 'Size mismatch');
    }
}