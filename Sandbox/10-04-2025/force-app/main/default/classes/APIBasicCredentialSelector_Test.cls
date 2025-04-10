@IsTest
public class APIBasicCredentialSelector_Test {
    
    @IsTest
    static void APIBasicCredentialByUsernameAndPass_UnitTest(){
        String username = 'testUser';
        String password = 'testPass';

        Integer expected = [SELECT COUNT() FROM APIBasicCredential__mdt WHERE Username__c = :username AND Password__c = :password];
        
        Test.startTest();
        List<APIBasicCredential__mdt> queried = Paua_SelectorHandler.getSelector(APIBasicCredentialSelector.APIBasicCredentialByUsernameAndPass.class)
            .setParameter('varUser', username)
            .setParameter('varPass', password)
            .query();
        Test.stopTest();
        
        System.assertEquals(expected, queried.size(), 'Did not find the expected amount of results');
    }
}