public without sharing class OpportunityDomain_NewProperties extends Paua_SObjectDomain {
    public override void init() {
        domainType = OpportunityDomain_NewProperties.class;
    }

    public override void afterUpdate() {
        RealEstateOpportunityService service = new RealEstateOpportunityService();

        List<Opportunity> relevant = service.getNewClosedWon((List<Opportunity>) Trigger.new, (Map<Id, Opportunity>)Trigger.oldMap);
        relevant = service.getWithoutProperty(relevant);

        service.createPropertiesForOpportunities(relevant);
    }

}