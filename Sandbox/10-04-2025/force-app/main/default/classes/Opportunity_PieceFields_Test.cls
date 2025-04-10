@IsTest
public class Opportunity_PieceFields_Test {
    @TestSetup
    static void setupTest() {        
        Account account = TestRecord_Factory.createPersonAccount();
        account.PersonEmail = 'test1@example.com';
        insert account;

        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;

        Room__c room2 = TestRecord_Factory.createRoom();
        insert room2;
    }

    @IsTest
    static void beforeInsert_unitTest(){
        Room__c room = [SELECT Id, Property__r.City__c, Property__r.Country__c FROM Room__c LIMIT 1];

        Account acc = [SELECT PersonEmail FROM Account WHERE PersonEmail = 'test.account@example.com' LIMIT 1];
        acc.PersonEmail = 'test' + acc.PersonEmail;
        update acc;
        
        Opportunity opp = TestRecord_Factory.createOpportunity();
        opp.Room__c = room.Id;
        
        Test.startTest();
        insert opp;
        Test.stopTest();
        
        opp = [SELECT Id, City__c, Country__c FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals(
            room.Property__r.City__c, opp.City__c, 'City on opportunity must be equal to city on room'
        );
        System.assertEquals(
            opp.Country__c, room.Property__r.Country__c, 'Country on opportunity must be equal to country on room'
        );
    }

    @IsTest
    static void beforeUpdate_unitTest(){
        Room__c room = [SELECT Id, Property__r.City__c, Property__r.Country__c FROM Room__c LIMIT 1];
        Opportunity opp = [SELECT Id, City__c, Country__c FROM Opportunity WHERE Room__c != :room.Id];
        opp.Room__c = room.Id;

        Test.startTest();
        update opp;
        Test.stopTest();
        
        opp = [SELECT Id, City__c, Country__c FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals(
            opp.City__c, room.Property__r.City__c, 'The City field on opportunity must be equal to city on the room'
        );
        System.assertEquals(
            opp.Country__c, room.Property__r.Country__c, 'The Country field on opportunity must be equal to country on the room'
        );
    }
}