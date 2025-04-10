public with sharing class ContractMigrationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    Id rentProductId = [SELECT Id FROM Product2 WHERE Name = 'Rent' LIMIT 1].Id;
    Date digitalPaymentStartDate;

    Map<String, String> contractStatusMap;

    public ContractMigrationBatch(Date digitalPaymentStartDate) {
        this.digitalPaymentStartDate = digitalPaymentStartDate;
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
                        ContractStatus__c
                FROM Opportunity
                WHERE ReprocessedStatusPick__c = 'Open'AND RecordTypeId ='0121i0000009OznAAE'
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
        
        Product2 discountProduct = [
            SELECT Id, (SELECT Id FROM PricebookEntries)
            FROM Product2
            WHERE Name = 'Permanent Discount'
            LIMIT 1
        ];
        
        Map<Id, Decimal> discountByOpp = new Map<Id, Decimal>();
        for (OpportunityLineItem opportunityLineItem : opportunityLineItems) {
            if (opportunityLineItem.Product2.Name == 'Rent') {
                opportunityLineItem.UnitPrice = opportunityLineItem.Opportunity.Monthly_Price__c != null ? opportunityLineItem.Opportunity.Monthly_Price__c : 0;
                discountByOpp.put(opportunityLineItem.OpportunityId, opportunityLineItem.RoomRef__r.Price__c - opportunityLineItem.UnitPrice);
                opportunityLineItemsToUpdate.add(opportunityLineItem);
            } else if (opportunityLineItem.Product2.Name == 'Deposit'){
                opportunityLineItemsToDelete.add(opportunityLineItem);
            } else if (opportunityLineItem.Product2.Name == 'Membership Fee') {
                opportunityLineItemsToDelete.add(opportunityLineItem);
            }
        }

        update opportunityLineItemsToUpdate;
        delete opportunityLineItemsToDelete;

        for (Opportunity opportunity : opportunities) {
            opportunity.ReprocessedStatusPick__c = 'Created';
            opportunity.StageName = 'Contract Out';
        }
        update opportunities;

        List<Contract> newContracts = [
            SELECT Id, Opportunity__r.Room__c, Opportunity__r.Room__r.Price__c, Status,
                Opportunity__r.Move_in_Date__c, Opportunity__r.ContractStatus__c, Opportunity__r.ContractEndDate__c, 
                Opportunity__c, Opportunity__r.Start_Date__c, RecordType.DeveloperName,
                (SELECT Id, PriceTrig__c FROM Contract_Items__r WHERE ProductRef__r.Name = 'Rent')
            FROM Contract 
            WHERE Opportunity__c IN :opportunities
        ];
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        List<Contract> contractsToDelete = new List<Contract>();
        List<Contract> contractsToUpdate = new List<Contract>();

        List<ContractItem__c> itemsToUpsert = new List<ContractItem__c>();
        
        for (Contract contract : newContracts) {

            if (contract.RecordType.DeveloperName == 'MembershipFee') {
                contractsToDelete.add(contract);
                continue;
            }
            contract.IsSignedEmailSendTrig__c = true;
            contract.IsCommunityLinkEmailSendTrig__c = true;
            contract.IsActivatedEmailsSendTrig__c = true;
            contract.IsSecondActivatedEmailSendTrig__c = true;
            contract.Status = contractStatusMap.get(contract.Opportunity__r.ContractStatus__c);
            contract.StartDate = contract.Opportunity__r.Start_Date__c;
            if (contract.Status == CustomerContractService.STATUS_ACTIVATED && contract.Opportunity__r.Start_Date__c < digitalPaymentStartDate) {
                contract.StartDate =  digitalPaymentStartDate;
            }
            contract.Contract_End_Date__c = contract.Opportunity__r.ContractEndDate__c;
            contractsToUpdate.add(contract);

            if (discountByOpp.containsKey(contract.Opportunity__c) && discountByOpp.get(contract.Opportunity__c) > 0) {
                itemsToUpsert.add(
                    new ContractItem__c(
                        ContractRef__c = contract.Id,
                        PriceTrig__c = discountByOpp.get(contract.Opportunity__c),
                        ProductRef__c = discountProduct.Id,
                        RoomRef__c = contract.Opportunity__r.Room__c
                    )
                );
                itemsToUpsert.add(
                    new ContractItem__c(
                        Id = contract.Contract_Items__r[0].Id,
                        PriceTrig__c = contract.Opportunity__r.Room__r.Price__c
                    )
                );
            }

            if ((contract.Contract_End_Date__c != null && contract.Contract_End_Date__c < digitalPaymentStartDate) || contract.Status == 'Voided') {
                Opportunity tmp = new Opportunity(Id = contract.Opportunity__c, ReprocessedStatusPick__c = 'Done');
                if (contract.Status == 'Voided') {
                    tmp.StageName = 'Closed Lost';
                }
                opportunitiesToUpdate.add(tmp);
            }
        }
        if (! itemsToUpsert.isEmpty()) {
            upsert itemsToUpsert;
        }
        delete contractsToDelete;
        update opportunitiesToUpdate;
        update contractsToUpdate;
    }

    public void finish(Database.BatchableContext BC) {
        Database.executeBatch(new ContractCreateStripePlanBatch(),1);
    }

}