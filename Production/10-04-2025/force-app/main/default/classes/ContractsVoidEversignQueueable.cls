public with sharing class ContractsVoidEversignQueueable implements Queueable, Database.AllowsCallouts {
    private Set<String> hashes;

    public ContractsVoidEversignQueueable(Set<String> hashes) {
        this.hashes = hashes;
    }

    public void execute(QueueableContext context) {
        for(String hash : hashes) {
            EverSignService.cancelDocument(hash);
        }
    }
}