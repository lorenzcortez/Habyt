public without sharing class ContentVersionDomain_PublishContent extends Paua_SObjectDomain {
    public override void init() {
        domainType = ContentVersionDomain_PublishContent.class;
    }

    public override void afterInsert() {
        PropertyService propertyService = new PropertyService();
        List<ContentVersion> relevantVersions = propertyService.getPropertyContent((List<ContentVersion>) Trigger.new);

        if (! relevantVersions.isEmpty()) {
            Queueable job = new PublishContentVersionQueueable(relevantVersions);
            System.enqueueJob(job);
        }
    }
}