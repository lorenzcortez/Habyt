@IsTest
public with sharing class AWSPrepareFilesBatchTest {

    @IsTest
    static void testFilePrepare() {
        Property__c property = TestRecord_Factory.createProperty();
        insert property;
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;

        insert new ContentDocumentLink(LinkedEntityId = property.Id, ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId);

        insert new ContentDistribution(
        ContentVersionId = cv.Id,
        Name = 'Public',
        PreferencesAllowViewInBrowser= true,
        PreferencesLinkLatestVersion=true,
        PreferencesNotifyOnVisit=false,
        PreferencesPasswordRequired=false,
        PreferencesAllowOriginalDownload= true
        );

        Test.startTest();
        Database.executeBatch(new AWSPrepareFilesBatch());
        Test.stopTest();

        ContentVersion contentVersion = [SELECT Id, RecordId__c, IsMigrateToS3__c FROM ContentVersion WHERE Id = :cv.Id];
        System.assertEquals(property.Id, contentVersion.RecordId__c);
    }

}