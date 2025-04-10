@IsTest
public class ContentService_Test {
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
    static void createContentDistribution_unitTest(){
        ContentVersion version = [SELECT Id FROM ContentVersion LIMIT 1];

        ContentService service = new ContentService();
        Test.startTest();

        ContentDistribution distro = service.createContentDistribution(version);

        Test.stopTest();

        System.assertNotEquals(null, distro, 'Unexpected NULL');
        System.assertEquals(null, distro.get('Id'), 'Distro should not be inserted');
        System.assertEquals(version.Id, distro.ContentVersionId, 'Id mismatch');
    }

    @IsTest
    static void createContentDistributions_unitTest(){
        List<ContentVersion> versions = [SELECT Id, ContentDocumentId FROM ContentVersion];

        ContentService service = new ContentService();

        Test.startTest();

        service.createContentDistributions(versions);
        
        Test.stopTest();

        List<ContentDistribution> distros = [SELECT Id FROM ContentDistribution WHERE ContentVersionId IN :versions];
        System.assertEquals(versions.size(), distros.size(), 'Did not find the expected amount of results');
    }

    @IsTest
    static void getLinks_unitTest(){
        List<ContentVersion> versions = [SELECT Id, ContentDocumentId FROM ContentVersion];

        ContentService service = new ContentService();

        Test.startTest();

        List<ContentDocumentLink> selected = service.getLinks(versions);

        Test.stopTest();

        // TODO: come up with a proper assertion for this test.
    }
}