public with sharing class ContractTriggerController {
    public static void afterUpdate(List<Contract> contracts, Map<Id, Contract> mapOfContracts){ 
        Set<String> contractIds = new Set<String>();
        for( Contract contract : contracts ){
            contractIds.add(contract.Id);
        }
        
        List<Contract> contrs = [SELECT Id, Status, Property__r.Stage__c, Room__c  FROM Contract WHERE Id IN :contractIds ];
        Set<String> roomIds = new Set<String>();
        for( Contract contract : contrs ){
            System.debug('Launched' + contract.Property__r.Stage__c);
            System.debug('Pre-sales' + contract.Property__r.Stage__c);
            System.debug('Voided' + contract.Status);
            System.debug('Signed' + mapOfContracts.get(contract.Id).Status);
            if(( contract.Property__r.Stage__c == 'Launched'  || contract.Property__r.Stage__c == 'Pre-sales' )
                && contract.Status == 'Voided' && mapOfContracts.get(contract.Id).Status == 'Signed'){
                if( String.isNotEmpty( contract.Room__c ) ){
                    roomIds.add(contract.Room__c);
                }
            }
        }

        System.debug('roomIds' + roomIds);

        if( roomIds.size() > 0 ){
            List<Room__c> rooms = [SELECT Id, Name, (SELECT OldValue, NewValue FROM Histories WHERE Field = 'AvailableDateTrig__c' AND DataType = 'DateOnly'  ORDER BY CreatedDate DESC LIMIT 1) FROM Room__c WHERE Id IN :roomIds];

            System.debug('rooms' + rooms);

            List<Room__c> toUpdateRooms = new List<Room__c>();
            if( rooms.size() > 0 ){
                for( Room__c room : rooms ){
                    System.debug('room.Histories' + room.Histories);
                    if( !Test.isRunningTest() ){
                        if( room.Histories.size() > 0){
                            for(Room__History history : room.Histories ){
                                Date field = (Date) history.OldValue;
                                if( field != null ){
                                    Room__c rm = new Room__c();
                                    rm.Id = room.Id;
                                    rm.AvailableDateTrig__c = field;
                                    toUpdateRooms.add(rm);
                                }
                            }
                        }
                    } else {
                        Date availDate = Date.today();
                        Room__c rm = new Room__c();
                        rm.Id = room.Id;
                        rm.AvailableDateTrig__c = availDate;
                        toUpdateRooms.add(rm);
                    }
                }
            }

            if( toUpdateRooms.size() > 0 ){
                System.debug('toUpdateRooms' + toUpdateRooms);
                update toUpdateRooms;
            }
        }
    }
}