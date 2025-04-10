/*
 * @who     : Igor Kudryk <igor.kudryk@empaua.com>
 * @when    : 31.08.2021
 * @what    : This class implements a Trigger to update fields on Contracts from Pieces.
 */
public with sharing class ContractDomain_PieceFields extends Paua_SObjectDomain {
    public override void init(){
		domainType = ContractDomain_PieceFields.class;
	}

    public override void beforeInsert(){
        CustomerContractService contractService = new CustomerContractService();

        contractService.syncDataFromPiece(Trigger.New);
    }

    public override void beforeUpdate(){
        CustomerContractService contractService = new CustomerContractService();
        
        List<Contract> withNewPieces = contractService.getWithNewPieceConsiderNull(
            (List<Contract>) Trigger.New, (Map<Id, Contract>) Trigger.oldMap
        );

        contractService.syncDataFromPiece(withNewPieces);
    }
}