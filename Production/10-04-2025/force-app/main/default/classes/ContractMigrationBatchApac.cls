public with sharing class ContractMigrationBatchApac implements Database.Batchable<sObject>, Database.AllowsCallouts{

    Id rentProductId = [SELECT Id FROM Product2 WHERE Name = 'Rent' LIMIT 1].Id;

    Map<String, String> contractStatusMap;

    public ContractMigrationBatchApac() {
        contractStatusMap = new Map<String, String>();

        for (ContractStatusMapping__mdt contractStatusMapping : ContractStatusMapping__mdt.getAll().values()) {
            contractStatusMap.put(contractStatusMapping.MigrationStatus__c, contractStatusMapping.ContractStatusPick__c);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT
                        Id,
                        Room__c,
                        CloseDate,
                        Deposit__c,
                        Monthly_Price__c,
                        Start_Date__c,
                        ContractEndDate__c,
                        Move_in_Date__c,
                        Move_in_Time__c,
                        LeadSource,
                        BillingEntity__c,
                        OpportunitySourcePick__c,
                        AccountId,
                        Amount,
                        Country__c,
                        City__c,
                        Name,
                        ContractStatus__c,
                        CurrencyISOCode
                FROM Opportunity
                WHERE ReprocessedStatusPick__c = 'Open'AND ContractStatus__c != 'Created'
        ]);
    }

    public void execute(Database.BatchableContext BC, List<Opportunity> opportunities) {
        List<OpportunityLineItem> opportunityLineItems = [
            SELECT Id, UnitPrice, Product2.Name, Opportunity.Deposit__c, Opportunity.Monthly_Price__c, 
                Opportunity.Start_Date__c, RoomRef__r.Price__c
            FROM OpportunityLineItem 
            WHERE OpportunityId IN :opportunities
        ];

        List<OpportunityLineItem> opportunityLineItemsToDelete = new List<OpportunityLineItem>();
        List<OpportunityLineItem> opportunityLineItemsToUpdate = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem opportunityLineItem : opportunityLineItems) {
            if (opportunityLineItem.Product2.Name == 'Rent') {
                opportunityLineItem.UnitPrice = opportunityLineItem.Opportunity.Monthly_Price__c != null ? opportunityLineItem.Opportunity.Monthly_Price__c : 0;
                opportunityLineItemsToUpdate.add(opportunityLineItem);
            } else if (opportunityLineItem.Product2.Name == 'Deposit') {
                opportunityLineItem.UnitPrice = opportunityLineItem.Opportunity.Deposit__c != null ? opportunityLineItem.Opportunity.Deposit__c : 0;
                opportunityLineItemsToUpdate.add(opportunityLineItem);
            } else if (opportunityLineItem.Product2.Name == 'Membership Fee') {
                opportunityLineItemsToDelete.add(opportunityLineItem);
            }
        }

        update opportunityLineItemsToUpdate;
        delete opportunityLineItemsToDelete;

        for (Opportunity opportunity : opportunities) {
            opportunity.StageName = 'Contract Out';
            opportunity.ReprocessedStatusPick__c = 'Created';
        }
        update opportunities;

        List<Contract> newContracts = [
            SELECT Id, Opportunity__r.Room__c, Opportunity__r.Room__r.Price__c, Status,
                Opportunity__r.Move_in_Date__c, Opportunity__r.ContractStatus__c, Opportunity__r.ContractEndDate__c, 
                Opportunity__c, Opportunity__r.Start_Date__c, Opportunity__r.Move_in_fee__c, Opportunity__r.Contract_Category__c, Opportunity__r.LeaseStartDate__c, RecordType.DeveloperName, Opportunity__r.Utilities_Cap__c, Opportunity__r.Shared_Expenses__c, Opportunity__r.Move_Out_Date__c,
                (SELECT Id, PriceTrig__c FROM Contract_Items__r)
            FROM Contract
            WHERE Opportunity__c IN :opportunities
        ];
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        List<Contract> contractsToDelete = new List<Contract>();
        List<Contract> contractsToUpdate = new List<Contract>();

        List<ContractItem__c> contractItemsToUpsert = new List<ContractItem__c>();
        
        for (Contract contract : newContracts) {
            if (contract.RecordType.DeveloperName == 'MembershipFee') {
                contractsToDelete.add(contract);
                continue;
            }
            contract.IsSignedEmailSendTrig__c = true;
            contract.IsCommunityLinkEmailSendTrig__c = true;
            contract.IsActivatedEmailsSendTrig__c = true;
            contract.IsSecondActivatedEmailSendTrig__c = true;
            contract.Status = contract.Opportunity__r.ContractStatus__c;
            contract.StartDate = contract.Opportunity__r.Start_Date__c;
            contract.CustomerSignedDate = contract.Opportunity__r.LeaseStartDate__c;
            contract.Contract_End_Date__c = contract.Opportunity__r.ContractEndDate__c;
            contract.Shared_Expenses__c = contract.Opportunity__r.Shared_Expenses__c;
            contract.Utilities_Cap__c = contract.Opportunity__r.Utilities_Cap__c;
            contract.MoveInDate__c = contract.Opportunity__r.Move_in_Date__c;
            contract.Move_out_date__c = contract.Opportunity__r.Move_Out_Date__c;
            contract.Contract_Category__c = contract.Opportunity__r.Contract_Category__c;
            contract.Move_out_cleaning_fee__c = contract.Opportunity__r.Move_in_fee__c;
            

            contractsToUpdate.add(contract);
            
            for (ContractItem__c contractItem : contract.Contract_Items__r) {
                contractItem.Invoice_Status__c = 'paid';
                contractItemsToUpsert.add(contractItem);
            }

            if (contract.Status == 'Voided') {
                Opportunity tmpOpp = new Opportunity(Id = contract.Opportunity__c, ReprocessedStatusPick__c = 'Done');
                tmpOpp.StageName = 'Closed Lost';
                opportunitiesToUpdate.add(tmpOpp);
            }
        }
        if (!contractItemsToUpsert.isEmpty()) {
            upsert contractItemsToUpsert;
        }
        delete contractsToDelete;
        update opportunitiesToUpdate;
        update contractsToUpdate;
    }

    public void finish(Database.BatchableContext BC) {
        Database.executeBatch(new ContractCreateStripePlanBatch(),1);
    }

}