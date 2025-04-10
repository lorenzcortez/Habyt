public with sharing class ContractCreateStripePlanBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id FROM Opportunity WHERE ReprocessedStatusPick__c = 'Created']);
    }

    public void execute(Database.BatchableContext BC, List<Opportunity> opportunities) {
        List<Contract> contracts = [SELECT Id, EverSign_Doc_Hash__c, STRIPE_Plan_Id__c, Room__c FROM Contract WHERE Opportunity__c IN :opportunities];
        String HMACSECRETKEY = 'HMACKEY';
        Set<Id> roomIds = new Set<Id>();
        for (Contract contract : contracts) {
            if (contract.STRIPE_Plan_Id__c == null) {
                ContractGeneratorController.generateStripePlan(contract.Id);
            }

            if (contract.EverSign_Doc_Hash__c == null) {
                contract.EverSign_Doc_Hash__c = '-';
                //init community url
                Blob hmacData = Crypto.generateMac('HmacSHA256', Blob.valueOf(contract.Id + '.-'), Blob.valueOf(HMACSECRETKEY));
                String Hmac = EncodingUtil.convertToHex(hmacData);
                String communityURL = External_API_Key__c.getOrgDefaults().Community_BaseURL__c;
                communityURL += 'contractId=' + contract.Id;
                communityURL += '&signature=' + Hmac;
                contract.Community_Step__c = 2;
                contract.Community_URL__c = communityURL;
            }
            roomIds.add(contract.Room__c);
        }

        Set<Id> roomsWithActiveContract = new Set<Id>();
        Map<Id, Date> roomToLatestContractEndDate = new Map<Id, Date>();
        for (Contract contract : [SELECT Id, Room__c, StartDate, Contract_End_Date__c, Status FROM Contract WHERE Room__c IN :roomIds]) {
            if (contract.Contract_End_Date__c == null && contract.Status != 'Voided') {
                roomsWithActiveContract.add(contract.Room__c);
            } else {
                if (!roomToLatestContractEndDate.containsKey(contract.Room__c) || roomToLatestContractEndDate.get(contract.Room__c) < contract.Contract_End_Date__c) {
                    roomToLatestContractEndDate.put(contract.Room__c, contract.Contract_End_Date__c);
                }
            }
        }
        List<Room__c> roomsToUpdate = new List<Room__c>();
        for (Id roomId : roomToLatestContractEndDate.keySet()) {
            if (!roomsWithActiveContract.contains(roomId)) {
                if (roomToLatestContractEndDate.get(roomId) != null) {
                    roomsToUpdate.add(new Room__c(Id = roomId, AvailableDateTrig__c = roomToLatestContractEndDate.get(roomId).addDays(1)));
                } else {
                    roomsToUpdate.add(new Room__c(Id = roomId, AvailableDateTrig__c = Date.today()));
                }
            }
        }

        for (Opportunity opportunity : opportunities) {
            opportunity.ReprocessedStatusPick__c = 'Contracts Processed';
            opportunity.StageName = 'Closed Won';
        }

        update contracts;
        update opportunities;
        update roomsToUpdate;
    }


    public void finish(Database.BatchableContext BC) {

    }

}