@IsTest
public class CustomerRoomSelectors_Test {
    @TestSetup
    static void setupTest(){
        Condition__c iCondition = TestRecord_Factory.createCondition();
        iCondition.MembershipFee__c = 200;
        insert iCondition;

        List<Room__c> rooms = new List<Room__c>();

        Room__c room1 = TestRecord_Factory.createRoom();
        rooms.add(room1);

        Room__c room2 = TestRecord_Factory.createRoom();
        rooms.add(room2);

        Room__c room3 = TestRecord_Factory.createRoom();
        rooms.add(room3);

        insert rooms;

        Account account = TestRecord_Factory.iPersonAccount;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc = TestRecord_Factory.iStripe_Account;

        List<Contract> contractsToInsert = new List<Contract>();
        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room1.Id, stripeAcc.Id);
        contractsToInsert.add(contract);

        Contract contract2 = TestRecord_Factory.createContract(account.Id, opp.Id, room2.Id, stripeAcc.Id);
        contractsToInsert.add(contract2);

        Contract contract3 = TestRecord_Factory.createContract(account.Id, opp.Id, room3.Id, stripeAcc.Id);
        contractsToInsert.add(contract3);

        insert contractsToInsert;
    }

    @IsTest
    static void RoomsByIdsWithContracts_UnitTest() {
        List<Room__c> rooms = [SELECT Id, (SELECT Id, Status FROM Contracts__r) FROM Room__c];
        Integer expectedContractsSize = rooms.get(0).Contracts__r.size();
        Set<Id> idsSet = new Set<Id> {rooms.get(0).Id};

        Test.startTest();
        
        List<SObject> queried = Paua_SelectorHandler.getSelector(CustomerRoomSelectors.RoomsByIdsWithContracts.class)
            .setParameter('idsSet', idsSet)
            .query();

        Test.stopTest();

        System.assertEquals(
            expectedContractsSize, 
            ((Room__c) queried.get(0)).Contracts__r.size(), 
            'Unexpected number of contracts related to rooms'
        );
    }

    @IsTest
    static void RoomsByIds_UnitTest() {
        List<Room__c> rooms = [SELECT Id FROM Room__c];
        Integer expected = rooms.size();
        Set<Id> idsSet = (new Map<Id, Room__c>(rooms)).keySet();

        Test.startTest();
        
        List<SObject> queried = Paua_SelectorHandler.getSelector(CustomerRoomSelectors.RoomsByIds.class)
            .setParameter('idsSet', idsSet)
            .query();

        Test.stopTest();

        System.assertEquals(expected, queried.size(), 'Unexpected number of results');
    }

    @IsTest
    static void RoomsWithPropertyAndConditions_UnitTest() {
        List<Room__c> rooms = [SELECT Id FROM Room__c];
        Integer expected = rooms.size();
        Set<Id> idsSet = (new Map<Id, Room__c>(rooms)).keySet();

        Test.startTest();
        
        List<SObject> queried = Paua_SelectorHandler.getSelector(CustomerRoomSelectors.RoomsWithPropertyAndConditions.class)
            .setParameter('idsSet', idsSet)
            .query();

        Test.stopTest();

        System.assertEquals(expected, queried.size(), 'Unexpected number of results');
    }
}