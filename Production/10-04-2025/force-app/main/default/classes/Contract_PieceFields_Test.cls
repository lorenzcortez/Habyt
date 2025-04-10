@IsTest
public class Contract_PieceFields_Test {
    @TestSetup
    static void setupTest() {        
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;

        Room__c room2 = TestRecord_Factory.createRoom();
        insert room2;
    }

    @IsTest
    static void beforeInsert_unitTest(){
        Account account = [SELECT Id FROM Account LIMIT 1];
        Room__c room = [SELECT Id, Property__r.City__c, Property__r.Country__c FROM Room__c LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Stripe_Account__c stripeAcc = [SELECT Id FROM Stripe_Account__c LIMIT 1];

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        contract.Room__c = room.Id;
        
        Test.startTest();

        insert contract;

        Test.stopTest();
        
        contract = [SELECT Id, City__c, Country__c FROM Contract WHERE Id = :contract.Id];

        System.assertEquals(
            room.Property__r.City__c, contract.City__c, 'City on the contract must be equal to city on the room'
        );
        System.assertEquals(
            room.Property__r.Country__c, contract.Country__c, 'Country on the contract must be equal to country on the room'
        );
    }

    @IsTest
    static void beforeUpdate_unitTest(){
        Contract contract = [SELECT Id, City__c, Country__c, Room__c FROM Contract WHERE Room__c != null LIMIT 1];

        Room__c room = [
            SELECT Id, Property__r.City__c, Property__r.Country__c 
            FROM Room__c 
            WHERE Id != :contract.Room__c 
            LIMIT 1
        ];
        contract.Room__c = room.Id;

        Test.startTest();

        update contract;

        Test.stopTest();
        
        contract = [SELECT Id, City__c, Country__c FROM Contract WHERE Id = :contract.Id LIMIT 1];
        room = [SELECT Id, Property__r.City__c, Property__r.Country__c FROM Room__c WHERE Id = :room.Id LIMIT 1];
        System.assertEquals(
            room.Property__r.City__c, contract.City__c, 'City on the contract must be equal to city on the room'
        );
        System.assertEquals(
            room.Property__r.Country__c, contract.Country__c, 'Country on the contract must be equal to country on the room'
        );
    }
}