@isTest public class OpportunityAfterUpdateTest {
    
    @isTest
    private static void propertyAndDocumentInsertAndDeleteTest(){
        // TODO: refactor to use Factory
       /* Brand__c brand = new Brand__c(Name = 'Habyt', APINameBrand__c = 'Habyt');
        insert brand;

        Billing_Entity__c entity = TestRecord_Factory.iBilling_Entity;
        entity.ConditionRef__c = TestRecord_Factory.iCondition.Id;
        update entity;

        Opportunity o = new Opportunity();
        o.Name = 'Opp_Test_Name';
        o.StageName = 'Negotiation';
        o.CloseDate = Date.today();
        o.FlatCode__c = 'Opp_Test_flat_code';
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RealEstate').getRecordTypeId();
        o.BillingEntity__c = entity.Id;
        o.BrandRef__c = brand.id;
        Insert o;
        
        ContentVersion doc = new ContentVersion();
        doc.FirstPublishLocationId = o.ID; // automatically create the contentDocumentLink
        doc.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        doc.Title = 'Test';
        doc.PathOnClient = 'Test.pdf';
        doc.IsMajorVersion = true;
        doc.VersionData = blob.valueOf('Test');
        Insert doc;

        Neighbourhood__c neighbourhood = new Neighbourhood__c();
        neighbourhood.CityPick__c = 'Berlin';
        neighbourhood.CountryPick__c = 'Germany';
        neighbourhood.ID_hmfly__c = 'testtesttest';
        neighbourhood.Name = 'Test';

        insert neighbourhood;
        
        o.StageName = 'Closed Won';
        o.NeighbourhoodRef__c = neighbourhood.Id;
        o.Floorplans__c = true;
        o.UnfurnishedPictures__c = true;
        o.Contract__c = true;
        o.LOI__c = true;
       // o.NeighbourhoodRef__r = TestRecord_Factory.iNeighbourhood;
        Update o;
        
        list<Property__c> ps = [SELECT ID, Opportunity__c FROM Property__c WHERE Name = :o.FlatCode__c AND Opportunity__c = :o.ID];
        System.assertEquals(1, ps.size());
        
        list<ContentDocumentLink> cdls1 = [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType FROM ContentDocumentLink WHERE LinkedEntityId = :(ps.get(0)).ID];
        System.assertEquals(1, cdls1.size());
        
        Property__c p = ps.get(0);
        ID idP = p.ID;
        ID idPOpp = p.Opportunity__c;
        Delete p;
        list<ContentDocumentLink> cdls2 = [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType FROM ContentDocumentLink WHERE LinkedEntityId = :idP];
        System.assertEquals(0, cdls2.size());
        
        list<ContentDocumentLink> cdls3 = [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType FROM ContentDocumentLink WHERE LinkedEntityId = :idPOpp];
        System.assertEquals(1, cdls3.size());*/
    }
}