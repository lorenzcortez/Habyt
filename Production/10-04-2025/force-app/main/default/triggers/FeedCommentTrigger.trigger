trigger FeedCommentTrigger on FeedComment (after insert) {
    
    set<id> CaseIds = new set<Id>();
    for(FeedComment fc : trigger.new){
        if(fc.ParentId != null && string.valueOf(fc.ParentId).StartsWith('500')){
            CaseIds.add(fc.ParentId);
        }
    }
    
    system.debug('CaseIds::'+CaseIds);
    if(CaseIds.size() > 0){
    
        set<string> CaseStatuses = new set<string>{'Closed', 'Solved', 'On Hold', 'Pending'};
        
        list<Case> Cases = new list<Case>();
        Cases = [Select Id, Status from Case where Id IN : CaseIds AND recordType.Name like '%CSS%' and Status IN :CaseStatuses];
        
        system.debug('Cases::'+Cases);
        if(Cases.size() > 0){
            for(Case c : Cases){
                c.Status = 'Open';
            }
            update Cases;
        }
    }
}