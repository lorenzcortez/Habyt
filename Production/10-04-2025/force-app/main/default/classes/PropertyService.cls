public without sharing class PropertyService {
    public static final Schema.SObjectType SObjectType = Schema.Property__c.getSObjectType();

    public void reparentFilesToOpportunity(List<Property__c> records) {
        Paua_Transaction trans = new Paua_Transaction();

        Map<Id,Id> flatsToOpps = new Map<Id,Id>();
        for(Property__c record : records){
            flatsToOpps.put(record.Id, record.Opportunity__c);
        }
        
        Paua_Selector selector = Paua_SelectorHandler.getSelector(ContentSelectors.ContentDocumentLinkByLinkedEntity.class)
            .setParameter('idSet', flatsToOpps.keySet());

        List<ContentDocumentLink> documentLinks = (List<ContentDocumentLink>) selector.query();

        for(ContentDocumentLink cdl : documentLinks){
            ContentDocumentLink cloned = cdl.clone();
            cloned.LinkedEntityId = flatsToOpps.get(cdl.linkedEntityId);

            trans.addForInsert(cloned);
            trans.addForDelete(cdl);
        }
        
        trans.setPreferredOrder(new List<SObjectType>{ContentDocumentLink.getSObjectType()});

        trans.commitRecords();
    }

    public Property__c createFromOpportunity(Opportunity opp) {

        String city = opp.city__c;

        //set Property_Number
        list<Property__c> properties = [SELECT Property_Number__c FROM Property__c WHERE City__c=:city ORDER BY Property_Number__c DESC NULLS LAST LIMIT 1];
        Decimal propertyNumber;
        if (properties.size()>0 && properties[0].Property_Number__c != null) {
            propertyNumber = properties[0].Property_Number__c + 1;
        } else {
            propertyNumber = 1;
        }

        //set property City_Model
        list<City__c> cityModel = [SELECT id, Country_Code__c, Number__c FROM City__c WHERE Name=:city LIMIT 1];
        String ApartmentName;
        Id CityModelId;
        if (cityModel.size()>0) {
            CityModelId = cityModel[0].id;
            ApartmentName = cityModel[0].Country_Code__c + '-' + String.valueOf(cityModel[0].Number__c).leftPad(2,'0') + '-' + String.valueOf(propertyNumber).leftPad(3,'0');
        }

        return new Property__c(
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
            ProductType__c = opp.ProductType__c,
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
            LOI__c = opp.LOI__c,
            NeighbourhoodRef__c = opp.NeighbourhoodRef__c,
            BrandRef__c = opp.BrandRef__c,
            City_object__c = CityModelId,
            Property_Number__c = propertyNumber,
            ApartmentNamePart__c = ApartmentName,
            CurrencyIsoCode = opp.CurrencyIsoCode,
            Studio_Design_Fee__c = opp.Studio_Design_Fee__c,
            Product_Tier__c = opp.Product_Tier__c,
			Studio_Design_Scope__c = opp.Studio_Design_Scope__c,
            Contract_type__c = opp.Contract_type__c,
			Building_type__c = opp.Building_type__c,		
			RecordTypeId = '0121i000000YGUIAA4' // add new Property record type Id related habyt properties

        );
    }

    public void checkPropertyNumber(List<Property__c> newList, Map<Id, Property__c> oldMap){
        for (Property__c nPn: newList) {
            if (oldMap!=null && nPn.Property_Number__c != oldMap.get(nPn.Id).Property_Number__c) {
                list<Property__c> oldProperties = [SELECT Property_Number__c FROM Property__c where City__c=:nPn.City__c and Property_Number__c=:nPn.Property_Number__c ORDER BY Property_Number__c DESC NULLS LAST LIMIT 1];
                if(oldProperties.size()>0){
                    nPn.addError('This Property Number already exist!');
                }
            }

        }
    }

    public Property__c getFromSObject(SObject record) {
        SObjectType sobjType = record.getSObjectType();
        Property__c property;
        try {
            if (sobjType == PropertyService.SObjectType) {
                property = (Property__c) record;
            } else if (sobjType == RoomService.SObjectType) {
                property = (Property__c) record.getSObject('Property__r');
            } else if (sobjType == ApartmentService.SObjectType) {
                property = (Property__c) record.getSObject('PropertyRef__r');
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }

        return property;
    }

    public List<ContentDocumentLink> filterPropertyLinks(List<ContentDocumentLink> links) {
        List<ContentDocumentLink> relevant = new List<ContentDocumentLink>();

        // For convenience this method covers Property__c, Apartment__c and Room__c records.
        Set<SObjectType> relevantTypes = new Set<SObjectType>{
            PropertyService.SObjectType, 
            ApartmentService.SObjectType, 
            RoomService.SObjectType
        };

        for (ContentDocumentLink link: links) {
            if (relevantTypes.contains(link.LinkedEntityId.getSObjectType())) {
                relevant.add(link);
            }
        }

        return relevant;
    }

    public List<ContentVersion> getPropertyContent(List<ContentVersion> versions) {
        ContentService service = new ContentService();

        Map<Id, List<ContentVersion>> versionsByDocumentId = new Map<Id, List<ContentVersion>>();
        for (ContentVersion cv: (versions)) {
            if (!versionsByDocumentId.containsKey(cv.ContentDocumentId)) {
                versionsByDocumentId.put(cv.ContentDocumentId, new List<ContentVersion>());    
            }
            versionsByDocumentId.get(cv.ContentDocumentId).add(cv);
        }

        List<ContentDocumentLink> relevantLinks = filterPropertyLinks(
            service.getLinks(versions)
        );

        List<ContentVersion> relevantVersions = new List<ContentVersion>();
        for (ContentDocumentLink cdl: relevantLinks) {
            relevantVersions.addAll(versionsByDocumentId.get(cdl.ContentDocumentId));
        }

        return relevantVersions;
    }

    public Condition__c getCondition(Property__c property) {
        Condition__c condition = (Condition__c) property.getSObject('ConditionRef__r');
        if (condition == null && property.getSObject('Billing_Entity__r') != null) {
            condition = (Condition__c) property.getSObject('Billing_Entity__r').getSObject('ConditionRef__r');
        }

        return condition;
    }

    public List<Property__c> getWithoutCondition(List<Property__c> records) {
        List<Property__c> relevant = new List<Property__c>();

        for (Property__c record: records) {
            if (record.ConditionRef__c == null) {
                relevant.add(record);
            }
        }

        return relevant;
    }

    public List<Property__c> getWithOpportunity(List<Property__c> records) {
        List<Property__c> relevant = new List<Property__c>();

        for (Property__c record: records) {
            if (record.Opportunity__c != null) {
                relevant.add(record);
            }
        }

        return relevant;
    }

    public List<Property__c> getWithBillingEntity(List<Property__c> records) {
        List<Property__c> relevant = new List<Property__c>();

        for (Property__c record: records) {
            if (record.Billing_Entity__c != null) {
                relevant.add(record);
            }
        }

        return relevant;
    }

    public List<Property__c> setDefaultCondition(List<Property__c> records) {
        return setDefaultCondition(records, false);
    }

    public List<Property__c> setDefaultCondition(List<Property__c> records, Boolean commitChanges) {
        Map<Id, Billing_Entity__c> entitiesById = new Map<Id, Billing_Entity__c>();
        
        for (Property__c record: records) {
            entitiesById.put(record.Billing_Entity__c, null);
        }

        Paua_Selector selector = Paua_SelectorHandler.getSelector(BillingEntitySelectors.FromId.class)
            .setParameter('idSet', entitiesById.keySet());

        entitiesById = new Map<Id, Billing_Entity__c>((List<Billing_Entity__c>) selector.query());

        Paua_Transaction trans = new Paua_Transaction();
        for (Property__c record: records) {
            record.ConditionRef__c = entitiesById.get(record.Billing_Entity__c).ConditionRef__c;
            if (commitChanges) {
                trans.addForUpsert(record);
            }
        }

        if (commitChanges) {
            trans.setPreferredOrder(new List<SObjectType>{Property__c.getSObjectType()});
            trans.commitRecords();
        }
        
        return records;
    }
}