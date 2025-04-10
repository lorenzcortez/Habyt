@IsTest
public class CreateContentDistributionBatchTest {

    @TestSetup
    static void setupTests(){
        Property__c property = TestRecord_Factory.iProperty;
        Room__c room = TestRecord_Factory.iRoom;
        Apartment__c apartment = TestRecord_Factory.iApartment;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        List<ContentDocumentLink> lstContentDocumentLink = new List<ContentDocumentLink>();

        ContentVersion cv_1 = new ContentVersion(
            Title = 'Test 1',
            PathOnClient ='test',
            VersionData=EncodingUtil.base64Decode('This is version data for content 1')
        );
        lstContentVersion.add(cv_1);

        ContentVersion cv_2 = new ContentVersion(
            Title = 'Test 2',
            PathOnClient ='test',
            VersionData=EncodingUtil.base64Decode('This is version data for content 2')
        );
        lstContentVersion.add(cv_2);

        insert lstContentVersion;

        List<ContentDocument> lstContentDocument = [SELECT Id FROM ContentDocument LIMIT 2];
        
        lstContentDocumentLink.add(new ContentDocumentLink(ContentDocumentId = lstContentDocument.get(0).Id, LinkedEntityId = property.Id));
        lstContentDocumentLink.add(new ContentDocumentLink(ContentDocumentId = lstContentDocument.get(0).Id, LinkedEntityId = room.Id));
        lstContentDocumentLink.add(new ContentDocumentLink(ContentDocumentId = lstContentDocument.get(0).Id, LinkedEntityId = apartment.Id));
        lstContentDocumentLink.add(new ContentDocumentLink(ContentDocumentId = lstContentDocument.get(1).Id, LinkedEntityId = opp.Id));
        insert lstContentDocumentLink;
    }
    
    @IsTest
    public static void contentDistributionCreation_Test() {
        System.assertEquals(0, [SELECT count() FROM ContentDistribution]);
        
        Test.startTest();
        Database.executeBatch(new CreateContentDistributionBatch(), 200);
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM ContentDistribution]);
    }

    @IsTest
    public static void contentDistributionAlreadyExist_Test() {
        System.assertEquals(0, [SELECT count() FROM ContentDistribution]);

        ContentService service = new ContentService();
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test 1'];
        service.createContentDistributions(new List<ContentVersion>{cv});
        System.assertEquals(1, [SELECT count() FROM ContentDistribution]);

        Test.startTest();
        Database.executeBatch(new CreateContentDistributionBatch(), 200);
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM ContentDistribution]);
    }
}