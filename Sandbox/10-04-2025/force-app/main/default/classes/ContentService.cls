public without sharing class ContentService {
    public ContentService() {}

    public ContentDistribution createContentDistribution(ContentVersion contentVersion) {
        return new ContentDistribution(
            ContentVersionId = contentVersion.Id,
            Name = 'Public',
            PreferencesAllowViewInBrowser= true,
            PreferencesLinkLatestVersion=true,
            PreferencesNotifyOnVisit=false,
            PreferencesPasswordRequired=false,
            PreferencesAllowOriginalDownload= true
        );
    }

    public void createContentDistributions(List<ContentVersion> contentVersions) {
        if (contentVersions == null || contentVersions.isEmpty()) {
            return;
        }
        Paua_Transaction trans = new Paua_Transaction();

        for (ContentDocumentLink link: getLinks(contentVersions)) {
            link.Visibility = 'AllUsers';
            trans.addForUpdate(link);
        }

        for (contentVersion version: contentVersions) {
            trans.addForInsert(createContentDistribution(version));
        }

        trans.setPreferredOrder(new List<SObjectType>{ContentDocumentLink.getSObjectType(), ContentDistribution.getSObjectType()});
        trans.commitRecords();
    }

    public List<ContentDocumentLink> getLinks(List<ContentVersion> versions) {
        Set<Id> documentIdSet = new Set<Id>();
        for (ContentVersion cv: versions) {
            documentIdSet.add(cv.ContentDocumentId);
        }

        return (List<ContentDocumentLink>) Paua_SelectorHandler.getSelector(ContentSelectors.ContentDocumentLinkByDocument.class)
            .setParameter('idSet', documentIdSet)
            .query();
    }

    public Map<Id, List<ContentDistribution>> getDistributionsByEntity(Set<Id> entityIds) {
        Map<Id, List<ContentDistribution>> distros = new Map<Id, List<ContentDistribution>>();
        List<ContentDocumentLink> links = (List<ContentDocumentLink>) Paua_SelectorHandler.getSelector(ContentSelectors.ContentDocumentLinkByLinkedEntity.class)
            .setParameter('idSet', entityIds)
            .query();

        Map<Id, ContentDistribution> allDistros = new Map<Id, ContentDistribution>();
        for (ContentDocumentLink cdl: links) {
            allDistros.put(cdl.ContentDocument.LatestPublishedVersionId, null);
        }

        for (ContentDistribution cd: (List<ContentDistribution>) Paua_SelectorHandler.getSelector(ContentSelectors.DownloadableContent.class)
            .setParameter('idSet', allDistros.keySet())
            .query()
        ) {
            allDistros.put(cd.ContentVersionId, cd);
        }

        for (ContentDocumentLink cdl: links) {
            if (allDistros.get(cdl.ContentDocument.LatestPublishedVersionId) == null) {
                continue;
            }
            
            if (! distros.containsKey(cdl.LinkedEntityId)) {
                distros.put(cdl.LinkedEntityId, new List<ContentDistribution>());
            }

            distros.get(cdl.LinkedEntityId).add(allDistros.get(cdl.ContentDocument.LatestPublishedVersionId));
        }

        return distros;
    }
}