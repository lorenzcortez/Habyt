public with sharing class AWSPrepareFilesBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id FROM Property__c
        ]);
    }

    public void execute(Database.BatchableContext BC, List<Property__c> properties) {
        List<Room__c> rooms = [SELECT Id FROM Room__c WHERE Property__c IN :properties];
        List<Apartment__c> apartments = [SELECT Id FROM Apartment__c WHERE PropertyRef__c IN :properties];

        Set<Id> ids = new Set<Id>();
        ids.addAll((new Map<Id, Property__c>(properties)).keySet());
        ids.addAll((new Map<Id, Room__c>(rooms)).keySet());
        ids.addAll((new Map<Id, Apartment__c>(apartments)).keySet());

        List<ContentDocumentLink> links =[
                SELECT ContentDocumentId,LinkedEntityId, ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :ids
        ];
        Set<Id> contentVersionIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
            contentVersionIds.add(link.ContentDocument.LatestPublishedVersionId);
        }

        Set<Id> publishedContentVersionIds = new Set<Id>();
        for (ContentDistribution contentDistribution : [
                SELECT Id, ContentVersionId
                FROM ContentDistribution
                WHERE ContentVersionId IN :contentVersionIds AND
                PreferencesAllowViewInBrowser = TRUE AND
                PreferencesLinkLatestVersion = TRUE AND
                PreferencesNotifyOnVisit = FALSE AND
                PreferencesPasswordRequired = FALSE AND
                PreferencesAllowOriginalDownload= TRUE
        ]) {
            publishedContentVersionIds.add(contentDistribution.ContentVersionId);
        }

        Map<Id, ContentVersion> versionsToUpdate = new Map<Id, ContentVersion>();
        for (ContentDocumentLink link : links) {
            if (publishedContentVersionIds.contains(link.ContentDocument.LatestPublishedVersionId)) {
                versionsToUpdate.put(link.ContentDocument.LatestPublishedVersionId, new ContentVersion(RecordId__c = link.LinkedEntityId, Id = link.ContentDocument.LatestPublishedVersionId));
            }
        }
        update versionsToUpdate.values();
    }

    public void finish(Database.BatchableContext BC) {

    }

}