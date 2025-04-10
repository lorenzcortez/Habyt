trigger PropertyAfterInsert on Property__c (after insert) {
    list<Room__c> newRooms = new list<Room__c>();

    for(Property__c p : Trigger.New) {
        for(Integer i = 0; i < p.Number_of_Beds__c; i++){
            Room__c r = new Room__c(
                Name = p.Name + ' ' + (i+1),
                Property__c = p.Id,
                Price__c = p.PricePerRoom__c
            );
            newRooms.add(r);
        }
    }
    if(newRooms.size()>0){
        upsert newRooms;
    }
}