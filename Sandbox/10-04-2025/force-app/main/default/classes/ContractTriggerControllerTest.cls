@isTest
public class ContractTriggerControllerTest {
    @TestSetup
    static void setupTest() {        
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;
        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;

        room.AvailableDateTrig__c = Date.today();
        update room;

        room.AvailableDateTrig__c = Date.today().addDays(4);
        update room;
        
        Property__c property = TestRecord_Factory.iProperty;
        property.Stage__c = 'Launched';
        update property;

        contract.Status = 'Signed';
        contract.Property__c = property.Id;
        update contract; 
    }

    @isTest
    static void scenario(){
        List<Contract> contract = [SELECT Id FROM Contract];
        Test.startTest();
            contract[0].Status = 'Voided';
            update contract[0];
        Test.stopTest();
    }
}