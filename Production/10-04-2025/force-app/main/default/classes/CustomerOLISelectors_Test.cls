@IsTest
public class CustomerOLISelectors_Test {
    
    @IsTest
    static void FromProducts_UnitTest() {

        OpportunityLineItem oli_1 = TestRecord_Factory.iOpportunityLineItem;
        Product2 product = TestRecord_Factory.iProduct2;
        Opportunity opp = TestRecord_Factory.iOpportunity;

        Set<Id> setOppIds = new Set<Id>{TestRecord_Factory.iOpportunity.Id};
        Set<Id> setProduct2Ids = new Set<Id>{TestRecord_Factory.iProduct2.Id};

        Integer expected = [SELECT count() FROM OpportunityLineItem WHERE OpportunityId IN :setOppIds AND Product2Id IN :setProduct2Ids ];

        Test.startTest();
        List<OpportunityLineItem> queried = (List<OpportunityLineItem>) Paua_SelectorHandler.getSelector(CustomerOpportunityLineItemSelectors.FromProducts.class)
            .setParameter('setOppIds', setOppIds)
            .setParameter('setProduct2Ids', setProduct2Ids)
            .query();
        Test.stopTest();

        System.assertEquals(expected, queried.size());
    }
}