@IsTest
public class FeeSelectors_Test {
    @IsTest
    static void Fees_UnitTest() {
        Fee__c fee = TestRecord_Factory.iFee;

        Integer expected = [SELECT COUNT() FROM Fee__c];

        Test.startTest();

        List<SObject> queried = Paua_SelectorHandler.getSelector(FeeSelectors.Fees.class).query();

        Test.stopTest();
        
        System.assertEquals(expected, queried.size(), 'Result count does not match the expected');
    }
}