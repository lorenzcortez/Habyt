trigger LeadTrigger on Lead (after update) {
    Set<Id> leadIdSet = new Set<Id>();
    for(Lead l : Trigger.newMap.values()) {
        if(l.Home_Committed__c != null && (l.Home_Committed__c != Trigger.oldMap.get(l.Id).Home_Committed__c)) {
            leadIdSet.add(l.Id);
        }
    }
    if(!leadIdSet.isEmpty()) {
        RunAssignmentRules.assignLeads(new List<Id>(leadIdSet));
    }
}