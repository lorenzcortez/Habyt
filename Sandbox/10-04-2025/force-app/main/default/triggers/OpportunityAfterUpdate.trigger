trigger OpportunityAfterUpdate on Opportunity (after update) {
    list<Property__c> newProperties = new list<Property__c>();
    
    list<Property__c> oldPropertiesLinked = [SELECT Opportunity__c FROM Property__c];
    list<Id> oldPropertiesLinkedIds = new list <Id>();
    
    for(Property__c p : oldPropertiesLinked){
        oldPropertiesLinkedIds.add(p.Opportunity__c);
    }
    
    for(Opportunity opp : Trigger.New) {
        if(opp.StageName == 'Closed Won' && !oldPropertiesLinkedIds.contains(opp.Id) && Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosById().get(opp.RecordTypeId).getDeveloperName() == 'RealEstate'){
            Property__c p = new Property__c(
                Name = opp.FlatCode__c,
                Billing_Entity__c = opp.BillingEntity__c,
                Opportunity__c = opp.Id,
                Account__c = opp.AccountId,
                PricePerRoom__c = opp.PricePerRoom__c,
                Number_of_Beds__c = opp.NumberOfBeds__c,
                Number_of_apartments__c = opp.NumberofApartments__c,
                NetLeasableArea__c = opp.NetLeasableArea__c,
                Country__c = opp.Country__c,
                City_Picklist__c = opp.City__c,
                Area__c = opp.Area__c,
                Street__c = opp.PropertyAddress__c,
                PropertyAddress__c = opp.PropertyAddress__c,
                PropertyType__c = opp.PropertyType__c,
                //ProductType__c = opp.ProductType__c,
                Deposit__c = opp.Deposit__c,
                rent_to_LL__c = opp.rent_to_LL__c,
                COGS__c = opp.COGS__c,
                CAPEX__c = opp.CAPEX__c,
                LeaseStartDate__c = opp.LeaseStartDate__c,
                HandoverContact__c = opp.HandoverContact__c,
                HandoverDate__c = opp.HandoverDate__c,
                BreakEvenPrice__c = opp.BreakEvenPrice__c,
                OfferLink__c = opp.OfferLink__c,
                Floorplans__c = opp.Floorplans__c,
                UnfurnishedPictures__c = opp.UnfurnishedPictures__c,
                Contract__c = opp.Contract__c,
                LOI__c = opp.LOI__c
            );
            newProperties.add(p);
        }
    }
    if(newProperties.size()>0){
        insert newProperties;
        
        map<Id,Id> oppsToFlats = new map<Id,Id>();
        for(Property__c p : newProperties){
            oppsToFlats.put(p.Opportunity__c, p.Id);
        }
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<ContentDocumentLink> cdlExt = new List<ContentDocumentLink>();
        
        list<ContentDocumentLink> linkedOppsEntityIds = [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType FROM ContentDocumentLink WHERE LinkedEntityId IN :oppsToFlats.keyset()];
        for(ContentDocumentLink cdl : linkedOppsEntityIds){
            ContentDocumentLink cloned = cdl.clone();
            cloned.LinkedEntityId = oppsToFlats.get(cdl.linkedEntityId);
            //cloned.ShareType = cdl.ShareType;
            cdlList.add(cloned);
            cdlExt.add(cdl);
        }
        
        insert cdlList; // new CDL records
        delete cdlExt; // delete old CDL records
    }
    
    
    
}