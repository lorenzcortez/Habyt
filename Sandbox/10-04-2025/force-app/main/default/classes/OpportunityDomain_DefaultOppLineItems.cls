public without sharing class OpportunityDomain_DefaultOppLineItems extends Paua_SObjectDomain{
	
    public override void init(){
		domainType = OpportunityDomain_DefaultOppLineItems.class;
	}

	public override void beforeInsert(){
		CustomerOpportunityService service = new CustomerOpportunityService();
		service.setStandardPricebook((List<Opportunity>)Trigger.new);
	}

	public override void afterInsert(){
		CustomerOpportunityService service = new CustomerOpportunityService();
		List<Opportunity> relevant = service.getWithNewPiece((List<Opportunity>)Trigger.new, null);
		service.syncDefaultOpportunityLineItems(relevant, null);
	}

	public override void afterUpdate(){
		CustomerOpportunityService service = new CustomerOpportunityService();
		List<Opportunity> lstOppsToDeleteProducts = service.checkOldProducts((List<Opportunity>)Trigger.new, (Map<Id, Opportunity>)Trigger.oldMap);
		List<Opportunity> relevant = service.getWithNewPiece((List<Opportunity>)Trigger.new, (Map<Id, Opportunity>)Trigger.oldMap);
		service.syncDefaultOpportunityLineItems(relevant, lstOppsToDeleteProducts);
	}

}