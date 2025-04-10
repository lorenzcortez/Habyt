global with sharing class HousingConfirmationSchedulable implements Schedulable {
    global void execute(SchedulableContext ctx) {
        System.enqueueJob(new HousingConfirmationQueueable());
    }
}