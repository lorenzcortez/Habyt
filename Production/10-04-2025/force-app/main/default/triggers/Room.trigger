trigger Room on Room__c (
    before insert, after insert,
    before update, after update,
    after undelete
) {
    // List of desired record type IDs
    Set<Id> desiredRecordTypeIds = new Set<Id>();
    
    //The the desired record type ids via name
    Id recordtype1 = Schema.SObjectType.Room__c.getRecordTypeInfosByName().get('Habyt Room').getRecordTypeId();
    
    //Add more but adding lines above and add it in the set below
    desiredRecordTypeIds.add(recordtype1);
    
    // Filter by RecordTypeId
    List<Room__c> filteredTriggers = new List<Room__c>();
    for (Room__c l : Trigger.New) {
        if (desiredRecordTypeIds.contains(l.RecordTypeId)) {
            filteredTriggers.add(l);
        }
    }

    if(filteredTriggers.isEmpty()) {
        return;
    }
    
    Paua_TriggerHandler.instance.run();
}