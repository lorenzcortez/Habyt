trigger Apartment on Apartment__c (
    before insert, after insert,
    before update, after update,
    after undelete
) {
    // List of desired record type IDs
    Set<Id> desiredRecordTypeIds = new Set<Id>();
    
    //The the desired record type ids via name
    Id recordtype1 = Schema.SObjectType.Apartment__c.getRecordTypeInfosByName().get('Habyt Apartment').getRecordTypeId();
    
    //Add more but adding lines above and add it in the set below
    desiredRecordTypeIds.add(recordtype1);
    
    // Filter by RecordTypeId
    List<Apartment__c> filteredTriggers = new List<Apartment__c>();
    for (Apartment__c l : Trigger.New) {
        if (desiredRecordTypeIds.contains(l.RecordTypeId)) {
            filteredTriggers.add(l);
        }
    }

    if(filteredTriggers.isEmpty()) {
        return;
    }
    
    Paua_TriggerHandler.instance.run();
}