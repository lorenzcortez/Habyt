@IsTest
public class RealEstateOpportunitySelectors_Test {
    @IsTest
    static void fromId_UnitTest() {
        Opportunity opp = TestRecord_Factory.iOpportunity;

        Test.startTest();

        List<SObject> opportunities = Paua_SelectorHandler.getSelector(RealEstateOpportunitySelectors.FromId.class)
            .setParameter('idSet', new Set<Id>{opp.Id})
            .query();
        
        Test.stopTest();
        
        System.assertEquals(1, opportunities.size(), 'Unexpected number of results returned');
    }
}