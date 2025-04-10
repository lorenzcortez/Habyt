trigger FeedItemTrigger on FeedItem (after insert) {
    
    set<id> CaseIds = new set<Id>();
    
    for(FeedItem fi : trigger.new){
        System.debug('fi.Type '+fi.Type);
        if(!fi.Type.equals('ChangeStatusPost'))
        {
            if(String.isNotBlank(fi.Type) && (fi.Type.equals('TextPost') || fi.Type.equals('ContentPost') ||  fi.Type.equals('LinkPost')) && String.isNotBlank(fi.ParentId) && string.valueOf(fi.ParentId).StartsWith('500')){
                CaseIds.add(fi.ParentId);
            }
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