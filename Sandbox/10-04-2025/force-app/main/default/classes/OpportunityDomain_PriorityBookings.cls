public with sharing class OpportunityDomain_PriorityBookings extends Paua_SObjectDomain {

    public override void init() {
        domainType = OpportunityDomain_PriorityBookings.class;
    }

    public override void afterInsert() {
        CustomerOpportunityService service = new CustomerOpportunityService();
        List<Opportunity> relevant = service.getWithPriorityBooking((List<Opportunity>)Trigger.new);

        if (! relevant.isEmpty()) {
            service.removePieceAvailability(relevant);
        }
    }
}