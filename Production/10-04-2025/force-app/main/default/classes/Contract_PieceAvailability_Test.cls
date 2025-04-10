@IsTest
public class Contract_PieceAvailability_Test {
    @TestSetup
    static void setupTest() {
        Property__c prop = TestRecord_Factory.iProperty;
        prop.Stage__c = CustomerContractService.PROPERTTY_STAGE_LAUNCHED;
        update prop;
        
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;
    }

    @IsTest
    static void afterUpdate_Signed_unitTest(){
        Contract contract = [SELECT Id, Status, Room__c FROM Contract WHERE Room__c != null LIMIT 1];
        contract.Status = CustomerContractService.STATUS_SIGNED;
        
        Test.startTest();

        update contract;

        Test.stopTest();
        
        Room__c room = [SELECT Id, AvailableDateTrig__c FROM Room__c WHERE Id = :contract.Room__c];

        System.assertEquals(null, room.AvailableDateTrig__c, 
            'Available date must be null');
    }

    @IsTest
    static void afterUpdate_Terminated_unitTest(){
        Contract contract = [SELECT Id, Status, Room__c FROM Contract WHERE Room__c != null LIMIT 1];
        contract.Status = CustomerContractService.STATUS_TERMINATED;
        contract.Contract_End_Date__c = System.today();
        
        Test.startTest();

        update contract;

        Test.stopTest();
        
        Room__c room = [SELECT Id, AvailableDateTrig__c FROM Room__c WHERE Id = :contract.Room__c];

        System.assertEquals(contract.Contract_End_Date__c.addDays(1), room.AvailableDateTrig__c, 
            'Available date must be the day after contract end');
    }
}