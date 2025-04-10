@IsTest
public class ContentSelectors_Test {
    @TestSetup
    static void setupTests(){
        Id entityId = UserInfo.getUserId();
        ContentVersion cv = new ContentVersion(
            Title = 'Test Content',
            PathOnClient ='test',
            VersionData=EncodingUtil.base64Decode('This is version data'),
            FirstPublishLocationId = entityId
        );
        insert cv;
    }

    @IsTest
    static void ContentDocumentLinkByLinkedEntity_unitTest() {
        Id entityId = UserInfo.getUserId();

        Integer expected = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :entityId];

        Test.startTest();
        
        List<SObject> selected = Paua_SelectorHandler.getSelector(ContentSelectors.ContentDocumentLinkByLinkedEntity.class)
            .setParameter('idSet', new Set<Id>{entityId})
            .query();
        
        Test.stopTest();

        System.assertEquals(expected, selected.size(), 'Did not find the expected amount of results');
    }

    @IsTest
    static void ContentDocumentLinkByDocument_unitTest() {
        List<ContentVersion> versions = [SELECT Id, ContentDocumentId FROM ContentVersion];

        Set<Id> documentIdSet = new Set<Id>();
        for (ContentVersion cv: versions) {
            documentIdSet.add(cv.ContentDocumentId);
        }

        Integer expected = [SELECT COUNT() FROM ContentDocumentLink WHERE ContentDocumentId IN :documentIdSet];

        Test.startTest();

        List<SObject> selected = Paua_SelectorHandler.getSelector(ContentSelectors.ContentDocumentLinkByDocument.class)
            .setParameter('idSet', documentIdSet)
            .query();

        Test.stopTest();

        System.assertEquals(expected, selected.size(), 'Did not find the expected amount of results');
    }

    @IsTest
    static void DownloadableContent_unitTest() {
        List<ContentVersion> versions = [SELECT Id FROM ContentVersion];
        Integer expected = [SELECT COUNT() FROM ContentDistribution WHERE ContentVersionId IN :versions];

        Set<Id> contentVersionIdSet = new Set<Id>();
        for (ContentVersion cv: versions) {
            contentVersionIdSet.add(cv.Id);
        }

        Test.startTest();

        List<ContentDistribution> selected = Paua_SelectorHandler.getSelector(ContentSelectors.DownloadableContent.class)
            .setParameter('idSet', contentVersionIdSet)
            .query();

        Test.stopTest();

        System.assertEquals(expected, selected.size(), 'Did not find the expected amount of results');
    }

    @IsTest
    static void ById_unitTest() {
        List<ContentVersion> versions = [SELECT Id FROM ContentVersion];
        Integer expected =  [SELECT COUNT() FROM ContentVersion];
        Set<Id> idSet = (new Map<Id, SObject>(versions)).keySet();

        Test.startTest();

        List<ContentVersion> selected = (List<ContentVersion>) Paua_SelectorHandler.getSelector(ContentSelectors.ById.class).setParameter('idSet', idSet).query();
        

        Test.stopTest();

        System.assertEquals(expected, selected.size(), 'Did not find the expected amount of results');
    }
}