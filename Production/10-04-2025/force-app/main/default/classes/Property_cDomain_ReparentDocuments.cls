public without sharing class Property_cDomain_ReparentDocuments extends Paua_SObjectDomain {

    public override void init() {
        domainType = Property_cDomain_ReparentDocuments.class;
    }

    public override void beforeDelete() {
        PropertyService service = new PropertyService();
        service.reparentFilesToOpportunity((List<Property__c>) Trigger.old);
    }
}