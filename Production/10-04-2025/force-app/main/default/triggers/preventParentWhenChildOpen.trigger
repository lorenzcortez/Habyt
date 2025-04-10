trigger preventParentWhenChildOpen  on Case (before update) {

    Set<Id> commomnRecordTypeIds = new Set<Id>();

    if( commomnRecordTypeIds.contains(Trigger.New[0].RecordTypeId) ){
        if (Trigger.New[0].Status=='Closed'){
            Integer close = [Select count() from Case where ParentId = :Trigger.New[0].id and isClosed != true];
    
            if (close > 0){
                Trigger.New[0].addError('There are still Child Cases Open - Please close those first, and try again!');
            }
    
        }
    }
   
}