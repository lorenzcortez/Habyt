@IsTest
public class CustomerOpportunitySelectors_Test {
    @IsTest
    static void FromId_UnitTest() {
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        
        CustomerOpportunityService service = new CustomerOpportunityService();
        Opportunity opp = service.createForAccountAndPiece(account, room, System.today().addMonths(1), null, 'API');
        insert opp;

        Set<Id> idSet = new Set<Id>{opp.Id};

        Integer expected = [SELECT COUNT() FROM Opportunity WHERE Id IN :idSet];

        Test.startTest();
        
        List<SObject> queried = Paua_SelectorHandler.getSelector(CustomerOpportunitySelectors.FromId.class)
            .setParameter('id', opp.Id)
            .query();

        Test.stopTest();
        
        System.assertEquals(expected, queried.size(), 'Unexpected number of results');
    }
}