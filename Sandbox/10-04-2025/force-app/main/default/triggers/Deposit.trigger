trigger Deposit on Deposit__c (
    before insert, after insert,
    before update, after update,
    before delete, after delete,
    after undelete
) {
    Paua_TriggerHandler.instance.run();
}