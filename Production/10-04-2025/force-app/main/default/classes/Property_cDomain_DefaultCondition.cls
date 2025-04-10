public without sharing class Property_cDomain_DefaultCondition extends Paua_SObjectDomain {
    public override void init() {
        domainType = Property_cDomain_DefaultCondition.class;
    }

    public override void beforeInsert() {
        PropertyService service = new PropertyService();
        
        List<Property__c> relevant = service.getWithoutCondition((List<Property__c>) Trigger.new);
        relevant = service.getWithBillingEntity(relevant);

        if (! relevant.isEmpty()) {
            service.setDefaultCondition(relevant);
        }
    }

    public override void beforeUpdate() {
        PropertyService service = new PropertyService();
        service.checkPropertyNumber((List<Property__c>) Trigger.new, (Map<Id, Property__c>) Trigger.oldMap);
    }
}