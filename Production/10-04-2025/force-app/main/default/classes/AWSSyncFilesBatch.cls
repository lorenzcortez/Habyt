public with sharing class AWSSyncFilesBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    String bucket;
    String method;
    String host;

    public AWSSyncFilesBatch(String bucket, String method, String host) {
        this.bucket = bucket;
        this.method = method;
        this.host = host;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT VersionData,Title,ContentDocumentId,FileExtension, ContentSize, RecordId__c FROM ContentVersion WHERE RecordId__c != NULL AND IsLatest = TRUE AND IsMigrateToS3__c = FALSE
        ]);
    }

    public void execute(Database.BatchableContext BC, List<ContentVersion> contentVersions) {
        AWSService awsService = new AWSService(this.bucket, this.method,this.host);
        for (ContentVersion contentVersion : contentVersions) {
            if (!Test.isRunningTest()) {
                awsService.UploadDocuments(contentVersion.RecordId__c, new List<ContentVersion>{contentVersion});
            }
        }
    }

    public void finish(Database.BatchableContext BC) {

    }





}