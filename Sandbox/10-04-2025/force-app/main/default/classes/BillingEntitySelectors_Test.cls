@IsTest
public class BillingEntitySelectors_Test {
    @IsTest
    static void fromId_UnitTest() {
        Billing_Entity__c entity = TestRecord_Factory.iBilling_Entity;

        Test.startTest();

        List<SObject> entities = Paua_SelectorHandler.getSelector(BillingEntitySelectors.FromId.class)
            .setParameter('idSet', new Set<Id>{entity.Id})
            .query();
        
        Test.stopTest();
        
        System.assertEquals(1, entities.size(), 'Unexpected number of results returned');
    }

    @IsTest
    static void fromType_UnitTest() {
		List<Schema.PicklistEntry> ple = Billing_Entity__c.TypePick__c.getDescribe().getPicklistValues();
		String type = ple.get(0).getValue();
        
        Billing_Entity__c entity = TestRecord_Factory.createBilling_Entity();
        entity.TypePick__c = type;
        insert entity;

        Test.startTest();

        List<SObject> entities = Paua_SelectorHandler.getSelector(BillingEntitySelectors.FromType.class)
            .setParameter('type', type)
            .query();
        
        Test.stopTest();
        
        System.assertEquals(1, entities.size(), 'Unexpected number of results returned');
    }
}