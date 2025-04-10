trigger Contract on Contract (
    before insert, after insert,
    before update, after update,
    after undelete
) {
    // List of desired record type IDs
    Set<Id> desiredRecordTypeIds = new Set<Id>();
    
    //The the desired record type ids via name
    Id recordtype1 = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Rent').getRecordTypeId();
    Id recordtype2 = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Membership Fee').getRecordTypeId();
    
    //Add more but adding lines above and add it in the set below
    desiredRecordTypeIds.add(recordtype1);
    desiredRecordTypeIds.add(recordtype2);
    
    // Filter by RecordTypeId
    List<Contract> filteredTriggers = new List<Contract>();
    for (Contract l : Trigger.New) {
        if (desiredRecordTypeIds.contains(l.RecordTypeId)) {
            filteredTriggers.add(l);
        }
    }

    if(filteredTriggers.isEmpty()) {
      return;
    }
    
    Paua_TriggerHandler.instance.run();
}