trigger PropertyBeforeDelete on Property__c (before delete) {
    map<Id,Id> flatsToOpps = new map<Id,Id>();
    for(Property__c p : Trigger.Old){
        flatsToOpps.put(p.Id, p.Opportunity__c);
    }
    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
    List<ContentDocumentLink> cdlExt = new List<ContentDocumentLink>();
    
    list<ContentDocumentLink> linkedFlatsEntityIds = [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType FROM ContentDocumentLink WHERE LinkedEntityId IN :flatsToOpps.keyset()];
    for(ContentDocumentLink cdl : linkedFlatsEntityIds){
        ContentDocumentLink cloned = cdl.clone();
        cloned.LinkedEntityId = flatsToOpps.get(cdl.linkedEntityId);
        //cloned.ShareType = cdl.ShareType;
        cdlList.add(cloned);
        cdlExt.add(cdl);
    }
    
    insert cdlList; // new CDL records
    delete cdlExt; // delete old CDL records
}