/*
 * @who     : Igor Kudryk <igor.kudryk@empaua.com>
 * @when    : 31.08.2021
 * @what    : This class implements a Trigger to update fields on Opportunities from Pieces.
 */
public with sharing class OpportunityDomain_PieceFields extends Paua_SObjectDomain {
    public override void init(){
		domainType = OpportunityDomain_PieceFields.class;
	}

    public override void beforeInsert(){
        CustomerOpportunityService opportunityService = new CustomerOpportunityService();

        opportunityService.syncDataFromPiece(Trigger.New);
    }

    public override void beforeUpdate(){
        CustomerOpportunityService opportunityService = new CustomerOpportunityService();

        List<Opportunity> withNewPieces = opportunityService.getWithNewPieceConsiderNull(
            (List<Opportunity>) Trigger.New, (Map<Id, Opportunity>) Trigger.oldMap
        );

        opportunityService.syncDataFromPiece(withNewPieces);
    }
}