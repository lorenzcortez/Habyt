public without sharing class PublishContentVersionQueueable implements Queueable {
    private List<ContentVersion> versions;

    public PublishContentVersionQueueable(List<ContentVersion> newVersions) {
        versions = newVersions;
    }

    public void execute(QueueableContext context) {
        ContentService service = new ContentService();
        service.createContentDistributions(versions);
    }
}