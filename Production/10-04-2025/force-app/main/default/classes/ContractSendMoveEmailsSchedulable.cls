global  class ContractSendMoveEmailsSchedulable implements Schedulable {
    global void execute(SchedulableContext ctx) {
        System.enqueueJob(new ContractSendMoveEmailsQueueable());
    }
}