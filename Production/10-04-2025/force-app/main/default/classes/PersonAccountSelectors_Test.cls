@IsTest
public class PersonAccountSelectors_Test {
    @IsTest
    static void fromEmails_UnitTest(){
        Account personAccount = TestRecord_Factory.iPersonAccount;
        Set<String> emailSet = new Set<String>{personAccount.PersonEmail};
        Integer expected = [SELECT COUNT() FROM Account WHERE PersonEmail IN :emailSet];

        Test.startTest();
        List<SObject> queried = Paua_SelectorHandler.getSelector(PersonAccountSelectors.FromEmail.class)
            .setParameter('emails', emailSet)
            .query();
        Test.stopTest();
        
        System.assertEquals(expected, queried.size(), 'Result count does not match the expected');
    }

    @IsTest
    static void fromUserId_UnitTest(){
        Account personAccount = TestRecord_Factory.iPersonAccount;
        personAccount = [SELECT Id, UserId__c FROM Account WHERE Id = :personAccount.Id];
        Set<String> userIds = new Set<String>{personAccount.UserId__c};
        
        Integer expected = [SELECT COUNT() FROM Account WHERE UserId__c IN :userIds];

        Test.startTest();
        List<SObject> queried = Paua_SelectorHandler.getSelector(PersonAccountSelectors.FromUserId.class)
            .setParameter('userIds', userIds)
            .query();
        Test.stopTest();
        
        System.assertEquals(expected, queried.size(), 'Result count does not match the expected');
    }

    @IsTest
    static void fromAccountIds_UnitTest(){
        Account personAccount = TestRecord_Factory.iPersonAccount;

        Test.startTest();
        List<SObject> queried = Paua_SelectorHandler.getSelector(PersonAccountSelectors.FromAccountIds.class)
            .setParameter('accountIds', new Set<Id>{personAccount.Id})
            .query();
        Test.stopTest();
        
        System.assertEquals(personAccount.Id, queried[0].Id, 'Account id does not match');
    }
}