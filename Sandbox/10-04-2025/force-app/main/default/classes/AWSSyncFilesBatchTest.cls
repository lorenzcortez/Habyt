@IsTest
public with sharing class AWSSyncFilesBatchTest {

    @IsTest
    static void testSyncFilesBatch() {
        Property__c property = TestRecord_Factory.createProperty();
        insert property;
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.RecordId__c = property.Id;
        insert cv;

        Test.startTest();
        Database.executeBatch(new AWSSyncFilesBatch('bucket', 'PUT', 'host'));
        Test.stopTest();


    }

}