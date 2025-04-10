@IsTest
public with sharing class AWSServiceTest {

    @IsTest
     static void testSendFileToS3() {
        Property__c property = TestRecord_Factory.createProperty();
        insert property;
        ContentVersion cv=new Contentversion();
        cv.title='ABC.jpg';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.RecordId__c = property.Id;
        insert cv;
        AWSService awsService = new AWSService('habytsalesforcebucket', 'PUT','s3-eu-central-1.amazonaws.com');
        Test.setMock(HttpCalloutMock.class, new AWSServiceMock());
        Test.startTest();
        awsService.UploadDocuments(cv.RecordId__c, [SELECT VersionData,Title,ContentDocumentId,FileExtension, ContentSize, RecordId__c FROM ContentVersion WHERE Id = :cv.Id]);
        Test.stopTest();
    }

    @IsTest
    static void testContentType() {
        Map<String, String> contentMap = new Map<String, String>{
                'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                'csv' => 'application/vnd.ms-excel',
                'wav' => 'audio/wav',
                'wmv' => 'video/x-ms-wmv',
                'mp3' => 'audio/mpeg',
                'mp4' => 'video/mp4',
                'png' => 'image/png',
                'pdf' => 'application/pdf'
        };

        AWSService awsService = new AWSService(null, null, null);

        Test.startTest();
        for (String contentType : contentMap.keySet()) {
            System.assertEquals(awsService.ContentType(contentType), contentMap.get(contentType));
        }
        Test.stopTest();
    }

}